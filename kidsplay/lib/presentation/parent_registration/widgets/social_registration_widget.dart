import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialRegistrationWidget extends StatelessWidget {
  final VoidCallback? onGoogleSignUp;
  final VoidCallback? onAppleSignUp;
  final bool isLoading;

  const SocialRegistrationWidget({
    super.key,
    this.onGoogleSignUp,
    this.onAppleSignUp,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.dividerColor,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.dividerColor,
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Social Registration Buttons
        Column(
          children: [
            // Google Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: OutlinedButton(
                onPressed: isLoading ? null : onGoogleSignUp,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.dividerColor,
                    width: 1.5,
                  ),
                  backgroundColor:
                      isDark ? theme.colorScheme.surface : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImageWidget(
                      imageUrl:
                          'https://developers.google.com/identity/images/g-logo.png',
                      width: 5.w,
                      height: 5.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Continue with Google',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Apple Sign Up Button (iOS only or web)
            if (defaultTargetPlatform == TargetPlatform.iOS || kIsWeb) ...[
              SizedBox(
                width: double.infinity,
                height: 7.h,
                child: OutlinedButton(
                  onPressed: isLoading ? null : onAppleSignUp,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.dividerColor,
                      width: 1.5,
                    ),
                    backgroundColor:
                        isDark ? theme.colorScheme.surface : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'apple',
                        color: theme.colorScheme.onSurface,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Continue with Apple',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
