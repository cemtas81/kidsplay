import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/login_header_widget.dart';
import './widgets/signup_prompt_widget.dart';
import './widgets/social_login_widget.dart';

class ParentLogin extends StatefulWidget {
  const ParentLogin({super.key});

  @override
  State<ParentLogin> createState() => _ParentLoginState();
}

class _ParentLoginState extends State<ParentLogin> {
  bool _isLoading = false;
  bool _isBiometricAvailable = true; // Mock availability
  String? _errorMessage;
  final _scrollController = ScrollController();

  // Mock credentials for demo
  final Map<String, dynamic> _mockCredentials = {
    "parent@kidsplay.com": {
      "password": "parent123",
      "name": "Sarah Johnson",
      "hasChildren": true,
    },
    "demo@kidsplay.com": {
      "password": "demo123",
      "name": "Demo Parent",
      "hasChildren": false,
    },
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Check mock credentials
      if (_mockCredentials.containsKey(email.toLowerCase())) {
        final userCredentials = _mockCredentials[email.toLowerCase()]!;
        if (userCredentials["password"] == password) {
          // Successful login
          HapticFeedback.lightImpact();

          if (mounted) {
            // Navigate based on user state
            if (userCredentials["hasChildren"] == true) {
              Navigator.pushReplacementNamed(
                  context, '/child-selection-dashboard');
            } else {
              Navigator.pushReplacementNamed(
                  context, '/child-profile-creation');
            }
          }
          return;
        }
      }

      // Invalid credentials
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = 'Invalid email or password. Please try again.';
      });
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage =
            'Login failed. Please check your connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBiometricSuccess() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/child-selection-dashboard');
  }

  void _handleBiometricError(String error) {
    HapticFeedback.heavyImpact();
    setState(() {
      _errorMessage = error;
    });
  }

  void _handleForgotPassword() {
    // Show forgot password dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text(
          'Password reset functionality will be implemented in the next version. '
          'For demo purposes, use:\n\n'
          'Email: parent@kidsplay.com\n'
          'Password: parent123',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate social login delay
      await Future.delayed(const Duration(milliseconds: 2000));

      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/child-selection-dashboard');
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = 'Social login failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSignUp() {
    Navigator.pushNamed(context, '/parent-registration');
  }

  void _handleBackPress() {
    Navigator.pushReplacementNamed(context, '/splash-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _handleBackPress,
                    icon: CustomIconWidget(
                      iconName: 'arrow_back_ios',
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Sign In',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 12.w), // Balance the back button
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const LoginHeaderWidget(),

                    // Error Message
                    if (_errorMessage != null) ...[
                      Container(
                        margin: EdgeInsets.only(bottom: 3.h),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                theme.colorScheme.error.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'error_outline',
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Biometric Authentication
                    BiometricAuthWidget(
                      onBiometricSuccess: _handleBiometricSuccess,
                      onBiometricError: _handleBiometricError,
                      isAvailable: _isBiometricAvailable,
                    ),

                    // Login Form
                    LoginFormWidget(
                      onLogin: _handleLogin,
                      onForgotPassword: _handleForgotPassword,
                      isLoading: _isLoading,
                    ),

                    // Social Login
                    SocialLoginWidget(
                      onSocialLogin: _handleSocialLogin,
                      isLoading: _isLoading,
                    ),

                    // Sign Up Prompt
                    SignupPromptWidget(
                      onSignUpTap: _handleSignUp,
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}