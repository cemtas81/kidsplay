import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingNavigationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  const OnboardingNavigationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onGetStarted,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = currentPage == totalPages - 1;

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip Button
          if (!isLastPage)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                minimumSize: Size(20.w, 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Skip',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            SizedBox(width: 20.w),

          // Next/Get Started Button
          ElevatedButton(
            onPressed: isLastPage ? onGetStarted : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              foregroundColor:
                  isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
              elevation: 2,
              shadowColor: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              minimumSize: Size(35.w, 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLastPage ? 'Get Started' : 'Next',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark
                        ? AppTheme.onPrimaryDark
                        : AppTheme.onPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: isLastPage ? 'rocket_launch' : 'arrow_forward',
                  color:
                      isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
