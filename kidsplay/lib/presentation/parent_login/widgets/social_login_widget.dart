import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../services/auth_service.dart';

class SocialLoginWidget extends StatelessWidget {
  final Function(String provider) onSocialLogin;
  final bool isLoading;

  const SocialLoginWidget({
    super.key,
    required this.onSocialLogin,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(height: 4.h),

        // Social Login Title
        Text(
          'Or continue with',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 3.h),

        // Social Login Buttons
        Row(
          children: [
            // Google Login - disabled in mock mode
            Expanded(
              child: AuthService.isUsingMockAuth 
                ? Tooltip(
                    message: 'Google Sign-In not available in demo mode.\nUse: demo@demo.com / demo1234',
                    child: _SocialLoginButton(
                      onTap: () => _showMockModeMessage(context),
                      icon: 'g_translate',
                      label: 'Google',
                      backgroundColor: (isDark ? const Color(0xFF1F1F1F) : Colors.white).withValues(alpha: 0.5),
                      borderColor: theme.dividerColor.withValues(alpha: 0.5),
                      textColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      isLoading: false,
                      isDisabled: true,
                    ),
                  )
                : _SocialLoginButton(
                    onTap: () => _handleSocialLogin(context, 'google'),
                    icon: 'g_translate',
                    label: 'Google',
                    backgroundColor:
                        isDark ? const Color(0xFF1F1F1F) : Colors.white,
                    borderColor: theme.dividerColor,
                    textColor: theme.colorScheme.onSurface,
                    isLoading: isLoading,
                  ),
            ),

            SizedBox(width: 3.w),

            // Apple Login
            Expanded(
              child: _SocialLoginButton(
                onTap: () => _handleSocialLogin(context, 'apple'),
                icon: 'apple',
                label: 'Apple',
                backgroundColor: isDark ? Colors.white : Colors.black,
                borderColor: Colors.transparent,
                textColor: isDark ? Colors.black : Colors.white,
                isLoading: isLoading,
              ),
            ),

            SizedBox(width: 3.w),

            // Facebook Login
            Expanded(
              child: _SocialLoginButton(
                onTap: () => _handleSocialLogin(context, 'facebook'),
                icon: 'facebook',
                label: 'Facebook',
                backgroundColor: const Color(0xFF1877F2),
                borderColor: Colors.transparent,
                textColor: Colors.white,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleSocialLogin(BuildContext context, String provider) {
    if (!isLoading) {
      HapticFeedback.lightImpact();
      onSocialLogin(provider);
    }
  }

  void _showMockModeMessage(BuildContext context) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Google Sign-In not available in demo mode.\nPlease use demo credentials:\nEmail: demo@demo.com\nPassword: demo1234',
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final String icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isLoading;
  final bool isDisabled;

  const _SocialLoginButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || isDisabled) ? null : onTap,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 7.h,
        ),
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != Colors.transparent
              ? Border.all(color: borderColor, width: 1)
              : null,
          boxShadow: isDisabled 
              ? [] 
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: icon,
                    color: textColor,
                    size: 20,
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}
