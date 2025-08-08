import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChildProfileCard extends StatelessWidget {
  final Map<String, dynamic> childData;
  final VoidCallback onTap;
  final VoidCallback onStartActivity;
  final VoidCallback onViewProgress;
  final VoidCallback onEditProfile;
  final VoidCallback? onPauseActivities;
  final VoidCallback? onShareProgress;
  final VoidCallback? onArchiveProfile;

  const ChildProfileCard({
    super.key,
    required this.childData,
    required this.onTap,
    required this.onStartActivity,
    required this.onViewProgress,
    required this.onEditProfile,
    this.onPauseActivities,
    this.onShareProgress,
    this.onArchiveProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: Dismissible(
        key: Key('child_${childData["id"]}'),
        direction: DismissDirection.startToEnd,
        background: _buildSwipeBackground(context),
        confirmDismiss: (direction) async {
          _showQuickActions(context);
          return false;
        },
        child: Container(
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
                _buildChildHeader(context),
                SizedBox(height: 2.h),
                _buildActivityStatus(context),
                SizedBox(height: 2.h),
                _buildStreakBadges(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: childData["profileImage"] != null
                ? CustomImageWidget(
                    imageUrl: childData["profileImage"] as String,
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: isDark
                        ? AppTheme.primaryDark.withValues(alpha: 0.2)
                        : AppTheme.primaryLight.withValues(alpha: 0.2),
                    child: Center(
                      child: Text(
                        (childData["name"] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                childData["name"] as String,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                '${childData["age"]} years old • ${childData["gender"]}',
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
          color:
              isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildActivityStatus(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final completedActivities = childData["todayActivities"] as int? ?? 0;
    final totalActivities = childData["dailyGoal"] as int? ?? 5;
    final progress =
        totalActivities > 0 ? completedActivities / totalActivities : 0.0;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$completedActivities/$totalActivities',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor:
                isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            ),
            minHeight: 6,
          ),
          SizedBox(height: 1.h),
          Text(
            _getProgressMessage(completedActivities, totalActivities),
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

  Widget _buildStreakBadges(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentStreak = childData["currentStreak"] as int? ?? 0;
    final badges = (childData["badges"] as List<dynamic>?) ?? [];

    return Row(
      children: [
        if (currentStreak > 0) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.secondaryDark.withValues(alpha: 0.2)
                  : AppTheme.secondaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'local_fire_department',
                  color:
                      isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  '$currentStreak day streak',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppTheme.secondaryDark
                        : AppTheme.secondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
        ],
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: badges.take(3).map<Widget>((badge) {
                return Container(
                  margin: EdgeInsets.only(right: 2.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.accentDark.withValues(alpha: 0.2)
                        : AppTheme.accentLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: badge["icon"] as String? ?? 'star',
                        color:
                            isDark ? AppTheme.accentDark : AppTheme.accentLight,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        badge["name"] as String? ?? 'Badge',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppTheme.accentDark
                              : AppTheme.accentLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeBackground(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primaryDark.withValues(alpha: 0.2)
            : AppTheme.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'play_arrow',
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Quick Actions',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(top: 2.h, bottom: 3.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildQuickActionTile(
                context,
                'Start Activity',
                'play_arrow',
                onStartActivity,
              ),
              _buildQuickActionTile(
                context,
                'View Progress',
                'analytics',
                onViewProgress,
              ),
              _buildQuickActionTile(
                context,
                'Edit Profile',
                'edit',
                onEditProfile,
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(top: 2.h, bottom: 3.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (onPauseActivities != null)
                _buildQuickActionTile(
                  context,
                  'Pause Activities',
                  'pause',
                  onPauseActivities!,
                ),
              if (onShareProgress != null)
                _buildQuickActionTile(
                  context,
                  'Share Progress',
                  'share',
                  onShareProgress!,
                ),
              if (onArchiveProfile != null)
                _buildQuickActionTile(
                  context,
                  'Archive Profile',
                  'archive',
                  onArchiveProfile!,
                  isDestructive: true,
                ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDestructive
        ? (isDark ? AppTheme.errorDark : AppTheme.errorLight)
        : (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight);

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: color,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  String _getProgressMessage(int completed, int total) {
    if (completed == 0) {
      return 'Ready to start today\'s activities!';
    } else if (completed < total) {
      return '${total - completed} more activities to reach daily goal';
    } else {
      return 'Daily goal completed! Great job!';
    }
  }
}
