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
      child: SingleChildScrollView(
        child: Container(
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration - Make more responsive
              Flexible(
                flex: 3,
                child: Container(
                  width: 85.w,
                  height: MediaQuery.of(context).size.height < 600 ? 30.h : 35.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
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
                      height: MediaQuery.of(context).size.height < 600 ? 30.h : 35.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 1.5.h),

              // Title - Make more flexible
              Flexible(
                flex: 1,
                child: Text(
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
              ),

              SizedBox(height: 1.5.h),

              // Bullet Points - Make flexible and scrollable
              Flexible(
                flex: 2,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height < 600 ? 15.h : 20.h,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
              ),
            ],
          ),
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
