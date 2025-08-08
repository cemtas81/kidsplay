import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PrivacyPolicyWidget extends StatelessWidget {
  final VoidCallback onPrivacyPolicyTap;

  const PrivacyPolicyWidget({
    super.key,
    required this.onPrivacyPolicyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 85.w,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.8)
            : AppTheme.surfaceLight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.primaryDark.withValues(alpha: 0.3)
              : AppTheme.primaryLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Security Icon
          Container(
            width: 12.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryDark.withValues(alpha: 0.2)
                  : AppTheme.primaryLight.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'security',
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 24,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Title
          Text(
            'Child Safety & Data Protection',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.5.h),

          // Description
          Text(
            'We prioritize your child\'s safety and privacy. All data is encrypted and stored securely with parental controls.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Privacy Policy Link
          GestureDetector(
            onTap: onPrivacyPolicyTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'policy',
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Read Privacy Policy',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color:
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
