import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(height: 8.h),

        // App Logo
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'child_care',
              color: theme.colorScheme.primary,
              size: 12.w,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // App Name
        Text(
          'KidsPlay',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: 1.h),

        // Welcome Message
        Text(
          'Welcome back!',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 1.h),

        // Subtitle
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            'Sign in to continue managing your child\'s screen time and activities',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 5.h),
      ],
    );
  }
}
