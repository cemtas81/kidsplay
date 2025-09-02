import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/activity_recommendation_engine.dart';
import '../../models/child.dart';
import '../../repositories/child_repository.dart';
import '../../services/auth_service.dart';
import '../../services/auth_guard.dart';
import './widgets/child_profile_card.dart';
import './widgets/custom_tab_navigation.dart';
import './widgets/dashboard_header.dart';
import './widgets/empty_state_widget.dart';
// Import new screens
import '../activity_detail/activity_detail_screen.dart';
import '../child_activity/child_activity_screen.dart';
import '../progress_tracking/progress_dashboard_screen.dart';
import '../multi_parent_management/multi_parent_screen.dart';
import '../subscription/subscription_screen.dart';

class ChildSelectionDashboard extends StatefulWidget {
  const ChildSelectionDashboard({super.key});

  @override
  State<ChildSelectionDashboard> createState() =>
      _ChildSelectionDashboardState();
}

class _ChildSelectionDashboardState extends State<ChildSelectionDashboard> {
  int _currentTabIndex = 0;
  bool _isRefreshing = false;
  bool _isLoading = true;
  DateTime _lastUpdated = DateTime.now();
  
  // Real data from database
  List<Child> _children = [];
  String? _currentUserId;
  final ChildRepository _childRepository = ChildRepository();
  
  // Cache authentication state to avoid repeated calls
  User? _cachedUser;
  DateTime? _lastAuthCheck;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  // Check if we need to refresh authentication (cache for 5 minutes)
  bool _needsAuthRefresh() {
    if (_cachedUser == null || _lastAuthCheck == null) return true;
    return DateTime.now().difference(_lastAuthCheck!).inMinutes > 5;
  }

  Future<void> _loadChildren() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Check cached authentication first
      if (_needsAuthRefresh()) {
        final authService = AuthService();
        final currentUser = authService.getCurrentUser();
        
        if (currentUser == null) {
          // User is not authenticated at all, redirect to login
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/parent-login');
          }
          return;
        }
        
        // Cache the user and timestamp
        _cachedUser = currentUser;
        _lastAuthCheck = DateTime.now();
        
        // For anonymous users (demo mode), still allow access
        if (currentUser.isAnonymous) {
          print('📝 Demo mode: Using anonymous user');
        }
      }
      
      // Use cached user if available, otherwise ensure signed in
      User user;
      if (_cachedUser != null) {
        user = _cachedUser!;
      } else {
        try {
          user = await AuthService.ensureInitializedAndSignedIn()
              .timeout(Duration(seconds: 10)); // 10 second timeout
          _cachedUser = user;
          _lastAuthCheck = DateTime.now();
        } on TimeoutException {
          throw Exception('Authentication timeout - please check your connection');
        }
      }
      
      if (mounted) {
        setState(() {
          _currentUserId = user.uid;
        });
      }
      
      // Listen to children updates with better error handling
      _childRepository.watchChildrenOf(user.uid).listen(
        (children) {
          if (mounted) {
            setState(() {
              _children = children;
              _lastUpdated = DateTime.now();
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          print('Error in children stream: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            // Show error message to user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load children: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () => _loadChildren(),
                ),
              ),
            );
          }
        },
      );
    } catch (error) {
      print('Error loading children: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // If authentication fails, redirect to login
        if (error.toString().contains('authentication') || 
            error.toString().contains('permission')) {
          Navigator.pushReplacementNamed(context, '/parent-login');
        } else {
          // Show generic error with retry option
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading children: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => _loadChildren(),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuardWidget(
      requireEmailVerification: true,
      child: _buildDashboard(context),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Show loading indicator while loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor:
            isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              ),
              SizedBox(height: 2.h),
              Text(
                'Loading your children...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark 
                      ? AppTheme.textSecondaryDark 
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // Show exit confirmation dialog
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit KidsPlay'),
            content: Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: Text('Exit'),
              ),
            ],
          ),
        );
        
        if (shouldExit == true) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        body: Column(
          children: [
            DashboardHeader(
              parentName: "Sarah",
              notificationCount: 3,
              onProfileTap: () => _navigateToProfile(),
              onSettingsTap: () => _navigateToSettings(),
            onNotificationsTap: () => _navigateToNotifications(),
          ),
          CustomTabNavigation(
            currentIndex: _currentTabIndex,
            onTabChanged: _onTabChanged,
          ),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
      floatingActionButton:
          _currentTabIndex == 0 ? _buildFloatingActionButton() : null,
    ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildActivitiesContent();
      case 2:
        return _buildProgressContent();
      case 3:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return _children.isEmpty
        ? EmptyStateWidget(onAddChild: _addNewChild)
        : RefreshIndicator(
            onRefresh: _refreshData,
            color: Theme.of(context).primaryColor,
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: 1.h,
                bottom: 10.h, // Space for FAB
              ),
              itemCount: _children.length + 1, // +1 for last updated info
              itemBuilder: (context, index) {
                if (index == _children.length) {
                  return _buildLastUpdatedInfo();
                }

                final child = _children[index];
                final childData = _convertChildToMap(child);
                return ChildProfileCard(
                  childData: childData,
                  onTap: () => _selectChild(childData),
                  onStartActivity: () => _startActivity(childData),
                  onViewProgress: () => _viewProgress(childData),
                  onEditProfile: () => _editProfile(childData),
                  onPauseActivities: () => _pauseActivities(childData),
                  onShareProgress: () => _shareProgress(childData),
                  onArchiveProfile: () => _archiveProfile(childData),
                );
              },
            ),
          );
  }

  Widget _buildActivitiesContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'explore',
            color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            size: 20.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Activities',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Browse and manage activities for your children',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'analytics',
            color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            size: 20.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Progress',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Track your children\'s development and achievements',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Text(
            'Settings & Management',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildSettingsCard(
            icon: 'people',
            title: 'Multi-Parent Management',
            subtitle: 'Invite and manage other parents',
            onTap: () => _navigateToMultiParent(),
          ),
          SizedBox(height: 2.h),
          _buildSettingsCard(
            icon: 'subscriptions',
            title: 'Subscription & Billing',
            subtitle: 'Manage your subscription plan',
            onTap: () => _navigateToSubscription(),
          ),
          SizedBox(height: 2.h),
          _buildSettingsCard(
            icon: 'analytics',
            title: 'Progress Dashboard',
            subtitle: 'View detailed progress reports',
            onTap: () => _navigateToProgressDashboard(),
          ),
          SizedBox(height: 2.h),
          _buildSettingsCard(
            icon: 'logout',
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () => _showSignOutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                  size: 24,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastUpdatedInfo() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.5)
            : AppTheme.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'sync',
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Last updated: ${_formatLastUpdated()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FloatingActionButton.extended(
      onPressed: _addNewChild,
      backgroundColor:
          isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight,
      foregroundColor:
          isDark ? AppTheme.onSecondaryDark : AppTheme.onSecondaryLight,
      elevation: 4,
      icon: CustomIconWidget(
        iconName: 'add',
        color: isDark ? AppTheme.onSecondaryDark : AppTheme.onSecondaryLight,
        size: 24,
      ),
      label: Text(
        'Add Child',
        style: theme.textTheme.titleMedium?.copyWith(
          color: isDark ? AppTheme.onSecondaryDark : AppTheme.onSecondaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });

    // Provide haptic feedback
    HapticFeedback.selectionClick();
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return; // Prevent multiple simultaneous refreshes
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Force refresh authentication cache
      _cachedUser = null;
      _lastAuthCheck = null;
      
      // Refresh children data from database
      await _loadChildren();

      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _lastUpdated = DateTime.now();
        });

        // Provide haptic feedback
        HapticFeedback.mediumImpact();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dashboard refreshed'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _refreshData(),
            ),
          ),
        );
      }
    }
  }

  // Helper method to convert Child object to Map format for ChildProfileCard
  Map<String, dynamic> _convertChildToMap(Child child) {
    final age = DateTime.now().difference(child.birthDate).inDays ~/ 365;
    return {
      "id": child.id,
      "name": child.name,
      "age": age,
      "gender": child.gender,
      "profileImage": null, // Could be enhanced to support profile images
      "todayActivities": 0, // Could be enhanced with real activity tracking
      "dailyGoal": 5, // Default goal
      "currentStreak": 0, // Could be enhanced with real streak tracking
      "badges": [], // Could be enhanced with real badge system
      "hobbies": child.hobbies,
      "screenTime": child.dailyPlayTime,
      "lastActivity": "None yet",
      "completionRate": 0, // Could be enhanced with real progress tracking
    };
  }

  void _selectChild(Map<String, dynamic> child) {
    HapticFeedback.lightImpact();
    // Navigate to child's main activity interface
    final childData = _createChildFromMap(child);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildActivityScreen(child: childData),
      ),
    );
  }

  void _startActivity(Map<String, dynamic> child) {
    HapticFeedback.lightImpact();
    // Navigate to activity selection for this child
    final childData = _createChildFromMap(child);
    // Navigate to the child's activity screen which shows recommendations
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildActivityScreen(child: childData),
      ),
    );
  }

  void _viewProgress(Map<String, dynamic> child) {
    HapticFeedback.lightImpact();
    // Navigate to progress view for this child
    final childData = _createChildFromMap(child);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressDashboardScreen(child: childData),
      ),
    );
  }

  // Helper method to convert Map to Child object
  Child _createChildFromMap(Map<String, dynamic> childMap) {
    return Child(
      id: childMap['id'].toString(),
      name: childMap['name'] ?? '',
      surname: '',
      birthDate: DateTime.now().subtract(Duration(days: (childMap['age'] ?? 3) * 365)),
      gender: childMap['gender'] ?? 'Unknown',
      hobbies: List<String>.from(childMap['hobbies'] ?? []),
      hasScreenDependency: true,
      screenDependencyLevel: 'normal',
      usesScreenDuringMeals: false,
      wantsToChange: true,
      dailyPlayTime: '1h',
      parentIds: ['parent1'],
      relationshipToParent: 'mother',
      hasCameraPermission: true,
    );
  }

  void _editProfile(Map<String, dynamic> child) {
    HapticFeedback.lightImpact();
    // Navigate to profile editing
    Navigator.pushNamed(context, '/child-profile-creation');
  }

  void _pauseActivities(Map<String, dynamic> child) {
    HapticFeedback.lightImpact();
    // Show confirmation dialog and pause activities
    _showConfirmationDialog(
      'Pause Activities',
      'Are you sure you want to pause activities for ${child["name"]}?',
      () {
        // Implement pause logic
      },
    );
  }

  void _shareProgress(Map<String, dynamic> child) {
    HapticFeedback.lightImpact();
    // Share progress report
    Navigator.pushNamed(context, '/parent-login');
  }

  void _archiveProfile(Map<String, dynamic> child) {
    HapticFeedback.lightImpact();
    // Show confirmation dialog and archive profile
    _showConfirmationDialog(
      'Archive Profile',
      'Are you sure you want to archive ${child["name"]}\'s profile? This will remove the profile from the app.',
      () async {
        try {
          // Delete the child from the database
          await _childRepository.deleteChild(_currentUserId!, child["id"]);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${child["name"]}\'s profile archived successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to archive profile: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
  }

  void _addNewChild() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/child-profile-creation').then((_) {
      // When returning from child creation, refresh the dashboard
      print('Returned from child creation, refreshing dashboard...');
      _refreshData();
    });
  }

  void _navigateToProfile() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/parent-login');
  }

  void _navigateToSettings() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/parent-registration');
  }

  void _navigateToNotifications() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/parent-onboarding');
  }

  void _navigateToMultiParent() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MultiParentScreen(),
      ),
    );
  }

  void _navigateToSubscription() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SubscriptionScreen(),
      ),
    );
  }

  void _navigateToProgressDashboard() {
    HapticFeedback.lightImpact();
    
    // Check if we have children
    if (_children.isEmpty) {
      // No children available, suggest adding a child first
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add a child profile first to view progress'),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Add Child',
            onPressed: () => Navigator.pushNamed(context, '/child-profile-creation'),
          ),
        ),
      );
      return;
    }
    
    // Use the first child for the progress dashboard
    final firstChild = _children.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressDashboardScreen(child: firstChild),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleSignOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await AuthService().signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/parent-login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showConfirmationDialog(
      String title, String message, VoidCallback onConfirm) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.dialogDark : AppTheme.dialogLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              foregroundColor:
                  isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
            ),
            child: Text(
              'Confirm',
              style: theme.textTheme.titleMedium?.copyWith(
                color:
                    isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
