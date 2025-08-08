import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String email, String password) onLogin;
  final VoidCallback onForgotPassword;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.onLogin,
    required this.onForgotPassword,
    this.isLoading = false,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  bool get _isFormValid {
    return _emailError == null &&
        _passwordError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  void _handleLogin() {
    if (_isFormValid && !widget.isLoading) {
      HapticFeedback.lightImpact();
      widget.onLogin(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _emailError != null
                    ? theme.colorScheme.error
                    : theme.dividerColor,
                width: _emailError != null ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: true,
              enabled: !widget.isLoading,
              onChanged: _validateEmail,
              decoration: InputDecoration(
                hintText: 'Enter your email address',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: CustomIconWidget(
                    iconName: 'email',
                    color: _emailError != null
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),

          // Email Error Message
          if (_emailError != null) ...[
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                _emailError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],

          SizedBox(height: 3.h),

          // Password Field
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _passwordError != null
                    ? theme.colorScheme.error
                    : theme.dividerColor,
                width: _passwordError != null ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              enabled: !widget.isLoading,
              onChanged: _validatePassword,
              onSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: CustomIconWidget(
                    iconName: 'lock',
                    color: _passwordError != null
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: widget.isLoading
                      ? null
                      : () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                  icon: CustomIconWidget(
                    iconName:
                        _isPasswordVisible ? 'visibility_off' : 'visibility',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),

          // Password Error Message
          if (_passwordError != null) ...[
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                _passwordError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],

          SizedBox(height: 2.h),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading ? null : widget.onForgotPassword,
              child: Text(
                'Forgot Password?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Remember Me Checkbox
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: widget.isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Remember me for faster login',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Sign In Button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed:
                  _isFormValid && !widget.isLoading ? _handleLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.12),
                disabledForegroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.38),
                elevation: _isFormValid && !widget.isLoading ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Sign In',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
