import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PageController pageController;

  const PageIndicatorWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 6.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalPages,
          (index) => _buildDot(context, index, isDark),
        ),
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index, bool isDark) {
    final isActive = currentPage == index;

    return GestureDetector(
      onTap: () {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isActive ? 8.w : 2.w,
        height: 1.h,
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
              : (isDark
                  ? AppTheme.textDisabledDark.withValues(alpha: 0.3)
                  : AppTheme.textDisabledLight.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(0.5.h),
        ),
      ),
    );
  }
}
