import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/activity_recommendation_engine.dart';
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
  DateTime _lastUpdated = DateTime.now();

  // Mock data for children profiles
  final List<Map<String, dynamic>> _childrenData = [
    {
      "id": 1,
      "name": "Emma Rodriguez",
      "age": 4,
      "gender": "Female",
      "profileImage":
          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
      "todayActivities": 3,
      "dailyGoal": 5,
      "currentStreak": 7,
      "badges": [
        {"name": "Creative", "icon": "palette"},
        {"name": "Active", "icon": "directions_run"},
        {"name": "Explorer", "icon": "explore"}
      ],
      "hobbies": ["Drawing", "Dancing", "Building blocks"],
      "screenTime": "2 hours",
      "lastActivity": "Creative Drawing",
      "completionRate": 85
    },
    {
      "id": 2,
      "name": "Lucas Chen",
      "age": 6,
      "gender": "Male",
      "profileImage":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
      "todayActivities": 5,
      "dailyGoal": 6,
      "currentStreak": 12,
      "badges": [
        {"name": "Scientist", "icon": "science"},
        {"name": "Builder", "icon": "construction"},
        {"name": "Reader", "icon": "menu_book"}
      ],
      "hobbies": ["Science experiments", "Lego building", "Reading"],
      "screenTime": "1.5 hours",
      "lastActivity": "Nature Explorer",
      "completionRate": 92
    },
    {
      "id": 3,
      "name": "Sophia Williams",
      "age": 3,
      "gender": "Female",
      "profileImage":
          "https://images.unsplash.com/photo-1518717758536-85ae29035b6d?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
      "todayActivities": 2,
      "dailyGoal": 4,
      "currentStreak": 3,
      "badges": [
        {"name": "Musical", "icon": "music_note"},
        {"name": "Helper", "icon": "volunteer_activism"}
      ],
      "hobbies": ["Singing", "Helping mom", "Playing with dolls"],
      "screenTime": "1 hour",
      "lastActivity": "Musical Time",
      "completionRate": 78
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
    return _childrenData.isEmpty
        ? EmptyStateWidget(onAddChild: _addNewChild)
        : RefreshIndicator(
            onRefresh: _refreshData,
            color: Theme.of(context).primaryColor,
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: 1.h,
                bottom: 10.h, // Space for FAB
              ),
              itemCount: _childrenData.length + 1, // +1 for last updated info
              itemBuilder: (context, index) {
                if (index == _childrenData.length) {
                  return _buildLastUpdatedInfo();
                }

                final child = _childrenData[index];
                return ChildProfileCard(
                  childData: child,
                  onTap: () => _selectChild(child),
                  onStartActivity: () => _startActivity(child),
                  onViewProgress: () => _viewProgress(child),
                  onEditProfile: () => _editProfile(child),
                  onPauseActivities: () => _pauseActivities(child),
                  onShareProgress: () => _shareProgress(child),
                  onArchiveProfile: () => _archiveProfile(child),
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
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });

    // Provide haptic feedback
    HapticFeedback.mediumImpact();
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
    // Create a sample activity for demonstration
    final sampleActivity = Activity(
      id: 'sample_activity_1',
      name: 'Creative Drawing',
      description: 'Draw your favorite animal using colors and imagination',
      relatedHobbies: ['Drawing', 'Art'],
      requiredTools: ['Paper', 'Crayons'],
      duration: 30,
      minAge: 2,
      maxAge: 6,
      activityType: 'creative',
      requiresParent: false,
      needsCamera: false,
      needsCameraEvaluation: false,
      energyLevel: 'low',
      hasAudioInstructions: true,
      hasVisualInstructions: true,
      hasPoints: true,
      allowsResultUpload: true,
      expectedOutput: 'image',
      needsParentFeedback: false,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailScreen(
          activity: sampleActivity,
          child: childData,
        ),
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
      'Are you sure you want to archive ${child["name"]}\'s profile? This action can be undone later.',
      () {
        setState(() {
          _childrenData.removeWhere((c) => c["id"] == child["id"]);
        });
      },
    );
  }

  void _addNewChild() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/child-profile-creation');
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
    // Create a sample child for the progress dashboard
    final sampleChild = Child(
      id: 'sample_child_1',
      name: 'Emma',
      surname: 'Rodriguez',
      birthDate: DateTime.now().subtract(Duration(days: 4 * 365)),
      gender: 'Female',
      hobbies: ['Drawing', 'Dancing', 'Building blocks'],
      hasScreenDependency: true,
      screenDependencyLevel: 'normal',
      usesScreenDuringMeals: false,
      wantsToChange: true,
      dailyPlayTime: '1h',
      parentIds: ['parent1'],
      relationshipToParent: 'mother',
      hasCameraPermission: true,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressDashboardScreen(child: sampleChild),
      ),
    );
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
