import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/auth_service.dart';
import '../../repositories/child_repository.dart';
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
  bool _isBiometricAvailable = false; // Disabled until local_auth package is properly integrated
  String? _errorMessage;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use Firebase Authentication
      final authService = AuthService();
      final user = await authService.signInWithEmailAndPassword(email, password);
      
      if (user != null && mounted) {
        HapticFeedback.lightImpact();
        
        // Check if user has children to determine navigation
        final childRepository = ChildRepository();
        final children = await childRepository.watchChildrenOf(user.uid).first;
        
        if (mounted) {
          if (children.isNotEmpty) {
            Navigator.pushReplacementNamed(context, '/child-selection-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/child-profile-creation');
          }
        }
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(error.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email address.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address format.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed login attempts. Please try again later.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.contains('Firebase not initialized')) {
      return 'App initialization error. Please restart the app and try again.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Email/password sign-in is not enabled. Please contact support.';
    } else if (error.contains('configuration-not-found')) {
      return 'Authentication service is currently unavailable. For demo purposes, use:\n\nEmail: demo@demo.com\nPassword: demo1234';
    } else if (error.contains('invalid-credential')) {
      return 'Authentication service is currently unavailable. For demo purposes, use:\n\nEmail: demo@demo.com\nPassword: demo1234';
    } else {
      return 'Login failed. Please check your credentials and try again.\n\nIf authentication service is unavailable, use demo credentials:\nEmail: demo@demo.com\nPassword: demo1234';
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

  Future<void> _handleMockSignIn() async {
    if (!mounted) return;
    
    // Show snackbar if not in mock mode (fallback safety)
    if (!AuthService.isUsingMockAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Direct login is only available in mock mode.'),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use AuthService mock sign-in
      final authService = AuthService();
      final user = await authService.signInAsMockUser();
      
      if (user != null && mounted) {
        HapticFeedback.lightImpact();
        
        // Check if user has children to determine navigation
        final childRepository = ChildRepository();
        final children = await childRepository.watchChildrenOf(user.uid).first;
        
        if (mounted) {
          // Use post-frame callback for safe navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (children.isNotEmpty) {
                Navigator.pushReplacementNamed(context, '/child-selection-dashboard');
              } else {
                Navigator.pushReplacementNamed(context, '/child-profile-creation');
              }
            }
          });
        }
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        setState(() {
          _errorMessage = 'Demo sign-in failed. Please try using the demo credentials manually:\nEmail: demo@demo.com\nPassword: demo1234';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    // Navigate to password reset screen
    Navigator.pushNamed(context, '/password-reset');
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user;
      
      if (provider == 'google') {
        // Use Firebase Google Authentication
        final authService = AuthService();
        user = await authService.signInWithGoogle();
      } else {
        // Handle other providers in the future (Facebook, Apple, etc.)
        throw Exception('Provider $provider not yet implemented');
      }
      
      if (user != null && mounted) {
        HapticFeedback.lightImpact();
        
        // Check if user has children to determine navigation
        final childRepository = ChildRepository();
        final children = await childRepository.watchChildrenOf(user.uid).first;
        
        if (mounted) {
          if (children.isNotEmpty) {
            Navigator.pushReplacementNamed(context, '/child-selection-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/child-profile-creation');
          }
        }
      } else if (user == null && mounted) {
        // User canceled the sign-in
        setState(() {
          _errorMessage = null; // Don't show error for user cancellation
        });
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        setState(() {
          _errorMessage = _getSocialLoginErrorMessage(provider, error.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getSocialLoginErrorMessage(String provider, String error) {
    if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.contains('account-exists-with-different-credential')) {
      return 'An account already exists with this email using a different sign-in method.';
    } else if (error.contains('invalid-credential')) {
      return 'The credential is invalid or has expired.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Google sign-in is not enabled. Please contact support.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (error.contains('Firebase not initialized')) {
      return 'App initialization error. Please restart the app and try again.';
    } else {
      return '$provider sign-in failed. Please try again.';
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

                    // Mock Direct Login (Development Mode Only)
                    if (AuthService.isUsingMockAuth) ...[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 2.h),
                        child: Column(
                          children: [
                            // Direct Login Button
                            Tooltip(
                              message: 'Quick sign-in with demo user (demo@demo.com)',
                              child: GestureDetector(
                                onTap: _isLoading ? null : _handleMockSignIn,
                                child: Container(
                                  width: 12.w,
                                  height: 12.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: _isLoading
                                      ? Center(
                                          child: SizedBox(
                                            width: 4.w,
                                            height: 4.w,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                theme.colorScheme.secondary,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: CustomIconWidget(
                                            iconName: 'fingerprint',
                                            color: theme.colorScheme.secondary,
                                            size: 6.w,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            SizedBox(height: 1.h),

                            // Direct Login Text
                            Text(
                              _isLoading
                                  ? 'Signing in...'
                                  : 'Quick Demo Sign-In',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 2.h),

                            // Divider with "OR"
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
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                          ],
                        ),
                      ),
                    ],

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