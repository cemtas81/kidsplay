import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/auth_provider.dart';
import '../../services/demo_data_helper.dart';
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
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    // Listen to auth provider changes
    _authProvider.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    if (_authProvider.errorMessage != null) {
      setState(() {
        _errorMessage = _authProvider.errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _authProvider.signIn(
        email: email,
        password: password,
      );

      if (success && mounted) {
        HapticFeedback.lightImpact();
        // Navigation will be handled by auth state listener in splash or main app
        if (_authProvider.hasChildren) {
          Navigator.pushReplacementNamed(context, '/child-selection-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/child-profile-creation');
        }
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (email) async {
                if (email.isNotEmpty) {
                  Navigator.of(context).pop();
                  final success = await _authProvider.resetPassword(email);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Get email from text field - simplified for demo
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enter email in the field above and press Enter'),
                ),
              );
            },
            child: const Text('Send'),
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
      bool success = false;
      
      if (provider == 'google') {
        success = await _authProvider.signInWithGoogle();
      }
      
      if (success && mounted) {
        HapticFeedback.lightImpact();
        // Navigation will be handled by the auth state
        if (_authProvider.hasChildren) {
          Navigator.pushReplacementNamed(context, '/child-selection-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/child-profile-creation');
        }
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

                    // Demo Data Button
                    TextButton(
                      onPressed: () => DemoDataHelper.showDemoDataDialog(context),
                      child: Text(
                        'Try Demo Account',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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