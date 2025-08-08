import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DashboardHeader extends StatelessWidget {
  final String parentName;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onNotificationsTap;
  final int notificationCount;

  const DashboardHeader({
    super.key,
    required this.parentName,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onNotificationsTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopRow(context),
            SizedBox(height: 2.h),
            _buildGreeting(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'KidsPlay',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          children: [
            Stack(
              children: [
                IconButton(
                  onPressed: onNotificationsTap,
                  icon: CustomIconWidget(
                    iconName: 'notifications_outlined',
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    size: 24,
                  ),
                  splashRadius: 20,
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppTheme.errorDark : AppTheme.errorLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        notificationCount > 99
                            ? '99+'
                            : notificationCount.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              onPressed: onSettingsTap,
              icon: CustomIconWidget(
                iconName: 'settings_outlined',
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
                size: 24,
              ),
              splashRadius: 20,
            ),
            IconButton(
              onPressed: onProfileTap,
              icon: CustomIconWidget(
                iconName: 'account_circle_outlined',
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
                size: 24,
              ),
              splashRadius: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final greeting = _getTimeBasedGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Welcome back, $parentName',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning! ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon! 🌤️';
    } else {
      return 'Good Evening! 🌙';
    }
  }
}
