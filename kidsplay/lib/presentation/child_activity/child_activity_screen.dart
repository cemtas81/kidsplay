import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/activity_recommendation_engine.dart';
import '../../widgets/custom_app_bar.dart';
import '../progress_tracking/progress_dashboard_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../activity_detail/activity_detail_screen.dart';

class ChildActivityScreen extends StatefulWidget {
  final Child child;

  const ChildActivityScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ChildActivityScreen> createState() => _ChildActivityScreenState();
}

class _ChildActivityScreenState extends State<ChildActivityScreen> {
  int _totalPoints = 1250;
  int _currentStreak = 7;
  List<Activity> _recommendedActivities = [];
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock recommended activities
    _recommendedActivities = [
      Activity(
        id: '1',
        name: 'Creative Drawing',
        description: 'Draw your favorite animal using different colors',
        activityType: 'creative',
        energyLevel: 'low',
        duration: 15,
        minAge: 3,
        maxAge: 6,
        requiresParent: false,
        needsCamera: false,
        needsCameraEvaluation: false,
        hasAudioInstructions: true,
        hasVisualInstructions: true,
        hasPoints: true,
        allowsResultUpload: true,
        expectedOutput: 'image',
        needsParentFeedback: true,
        relatedHobbies: ['Drawing', 'Art'],
        requiredTools: ['Paper', 'Crayons'],
      ),
      Activity(
        id: '2',
        name: 'Nature Explorer',
        description: 'Find and collect different types of leaves',
        activityType: 'educational',
        energyLevel: 'medium',
        duration: 20,
        minAge: 4,
        maxAge: 6,
        requiresParent: true,
        needsCamera: true,
        needsCameraEvaluation: true,
        hasAudioInstructions: true,
        hasVisualInstructions: true,
        hasPoints: true,
        allowsResultUpload: true,
        expectedOutput: 'image',
        needsParentFeedback: true,
        relatedHobbies: ['Nature', 'Science'],
        requiredTools: ['Basket', 'Magnifying glass'],
      ),
      Activity(
        id: '3',
        name: 'Dance Party',
        description: 'Dance to your favorite songs with fun moves',
        activityType: 'physical',
        energyLevel: 'high',
        duration: 10,
        minAge: 2,
        maxAge: 6,
        requiresParent: false,
        needsCamera: false,
        needsCameraEvaluation: false,
        hasAudioInstructions: true,
        hasVisualInstructions: true,
        hasPoints: true,
        allowsResultUpload: false,
        expectedOutput: 'none',
        needsParentFeedback: true,
        relatedHobbies: ['Dancing', 'Music'],
        requiredTools: ['Music player'],
      ),
    ];

    // Mock achievements
    _achievements = [
      Achievement(
        id: '1',
        name: 'Creative Master',
        description: 'Completed 10 creative activities',
        icon: 'palette',
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        type: 'skill',
      ),
      Achievement(
        id: '2',
        name: 'Nature Explorer',
        description: 'Completed 5 outdoor activities',
        icon: 'nature',
        unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
        type: 'milestone',
      ),
      Achievement(
        id: '3',
        name: 'Dance Star',
        description: 'Completed 8 physical activities',
        icon: 'music_note',
        unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
        type: 'skill',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: CustomAppBar(
        title: 'Hi ${widget.child.name}!',
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () {
              // Show help
            },
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            SizedBox(height: 3.h),
            _buildQuickStats(context),
            SizedBox(height: 3.h),
            _buildNextActivitySection(context),
            SizedBox(height: 3.h),
            _buildRecommendedActivities(context),
            SizedBox(height: 3.h),
            _buildAchievementsSection(context),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            isDark ? AppTheme.primaryVariantDark : AppTheme.primaryVariantLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppTheme.onPrimaryDark
                          : AppTheme.onPrimaryLight,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.child.name[0].toUpperCase(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merhaba ${widget.child.name}!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark
                              ? AppTheme.onPrimaryDark
                              : AppTheme.onPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Bugün ne yapmak istiyorsun?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.onPrimaryDark
                              : AppTheme.onPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Points',
            '$_totalPoints',
            'stars',
            isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildStatCard(
            context,
            'Streak',
            '$_currentStreak days',
            'local_fire_department',
            isDark ? AppTheme.successDark : AppTheme.successLight,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildStatCard(
            context,
            'Badges',
            '12',
            'emoji_events',
            isDark ? AppTheme.accentDark : AppTheme.accentLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      String icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextActivitySection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_recommendedActivities.isEmpty) return const SizedBox.shrink();

    final nextActivity = _recommendedActivities.first;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Next Activity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${nextActivity.duration} min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.onPrimaryDark
                          : AppTheme.onPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: _getActivityIcon(nextActivity.activityType),
                    color: isDark
                        ? AppTheme.onPrimaryDark
                        : AppTheme.onPrimaryLight,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextActivity.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        nextActivity.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailScreen(
                        activity: nextActivity,
                        child: widget.child,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? AppTheme.onPrimaryDark
                        : AppTheme.onPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedActivities(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Activities',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 25.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedActivities.length,
            itemBuilder: (context, index) {
              return Container(
                width: 60.w,
                margin: EdgeInsets.only(right: 3.w),
                child: _buildActivityCard(_recommendedActivities[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 12.h,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getActivityIcon(activity.activityType),
                  color:
                      isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                  size: 32,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              activity.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              activity.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${activity.duration} min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.onPrimaryDark
                          : AppTheme.onPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailScreen(
                          activity: activity,
                          child: widget.child,
                        ),
                      ),
                    );
                  },
                  icon: CustomIconWidget(
                    iconName: 'play_arrow',
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Achievements',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 20.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _achievements.length,
            itemBuilder: (context, index) {
              return Container(
                width: 50.w,
                margin: EdgeInsets.only(right: 3.w),
                child: _buildAchievementCard(_achievements[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.icon,
              style: TextStyle(fontSize: 32.sp),
            ),
            SizedBox(height: 1.h),
            Text(
              achievement.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              achievement.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'creative':
        return const Color(0xFFE91E63);
      case 'physical':
        return const Color(0xFF4CAF50);
      case 'musical':
        return const Color(0xFF9C27B0);
      case 'educational':
        return const Color(0xFF2196F3);
      case 'free_play':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  String _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'creative':
        return 'brush';
      case 'physical':
        return 'directions_run';
      case 'musical':
        return 'music_note';
      case 'educational':
        return 'school';
      case 'free_play':
        return 'child_care';
      default:
        return 'check_circle';
    }
  }

  String _getActivityTypeText(String activityType) {
    switch (activityType) {
      case 'creative':
        return 'Yaratıcı';
      case 'physical':
        return 'Fiziksel';
      case 'musical':
        return 'Müzikal';
      case 'educational':
        return 'Eğitici';
      case 'free_play':
        return 'Serbest';
      default:
        return 'Oyun';
    }
  }

  String _getEnergyLevelText(String energyLevel) {
    switch (energyLevel) {
      case 'low':
        return 'Düşük';
      case 'medium':
        return 'Orta';
      case 'high':
        return 'Yüksek';
      default:
        return 'Orta';
    }
  }

  void _startActivity(Activity activity) {
    // Navigate to activity detail screen
    Navigator.pushNamed(
      context,
      '/activity-detail',
      arguments: {
        'activity': activity,
        'child': widget.child,
      },
    );
  }
}
