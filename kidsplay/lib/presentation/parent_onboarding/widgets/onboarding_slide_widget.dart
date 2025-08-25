import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingSlideWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<String> bulletPoints;
  final bool isRTL;

  const OnboardingSlideWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.bulletPoints,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'Onboarding slide: $title',
      child: Container(
        width: 100.w,
        // Remove fixed height constraint
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Change to min
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration - Reduce height
            Container(
              width: 85.w,
              height: 40.h, // Reduced from 50.h
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black
                            .withOpacity(0.3) // Fixed withValues to withOpacity
                        : Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomImageWidget(
                  imageUrl: imageUrl,
                  width: 85.w,
                  height: 40.h, // Reduced from 50.h
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 2.h), // Reduced from 4.h

            // Title
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 2.h), // Reduced from 3.h

            // Bullet Points - Wrap in ConstrainedBox with fixed height
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 25.h),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Add this
                  children: bulletPoints
                      .map((point) => _buildBulletPoint(
                            context,
                            point,
                            isDark,
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text, bool isDark) {
    return Container(
      width: 85.w,
      margin: EdgeInsets.only(bottom: 1.5.h), // Reduced from 2.h
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(
              top: 0.8.h, // Reduced from 1.h
              right: isRTL ? 0 : 3.w,
              left: isRTL ? 3.w : 0,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    height: 1.4, // Reduced from 1.5
                    fontWeight: FontWeight.w400,
                  ),
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
