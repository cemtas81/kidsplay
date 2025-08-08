import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddChild;

  const EmptyStateWidget({
    super.key,
    required this.onAddChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(context),
            SizedBox(height: 4.h),
            _buildTitle(context),
            SizedBox(height: 2.h),
            _buildDescription(context),
            SizedBox(height: 4.h),
            _buildAddChildButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primaryDark.withValues(alpha: 0.1)
            : AppTheme.primaryLight.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'child_care',
          color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
          size: 20.w,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      'Welcome to KidsPlay!',
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      'Start your journey by adding your first child\'s profile. Create personalized activities and track their development progress.',
      style: theme.textTheme.bodyLarge?.copyWith(
        color:
            isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAddChildButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onAddChild,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
          foregroundColor:
              isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'add',
              color: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Add Your First Child',
              style: theme.textTheme.titleMedium?.copyWith(
                color:
                    isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}