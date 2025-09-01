import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _isCheckingVerification = false;
  String? _errorMessage;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _initializeUserEmail();
  }

  void _initializeUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email ?? 'your email';
    });
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.sendEmailVerification();
      
      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        HapticFeedback.heavyImpact();
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

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isCheckingVerification = true;
      _errorMessage = null;
    });

    try {
      // Reload user data from Firebase
      await _authService.reloadUser();
      
      if (_authService.isEmailVerified) {
        if (mounted) {
          HapticFeedback.lightImpact();
          // Email is verified, navigate to appropriate screen
          Navigator.pushReplacementNamed(context, '/child-selection-dashboard');
        }
      } else {
        if (mounted) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not yet verified. Please check your inbox.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        setState(() {
          _errorMessage = _getErrorMessage(error.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('too-many-requests')) {
      return 'Too many requests. Please wait before requesting another verification email.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.contains('Firebase not initialized')) {
      return 'App initialization error. Please restart the app and try again.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/parent-login');
      }
    } catch (e) {
      // Handle sign out error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Verify Email',
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _signOut,
            child: Text(
              'Sign Out',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 4.h),
              
              // Header Icon
              Center(
                child: Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.mark_email_read,
                    size: 12.w,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              
              SizedBox(height: 4.h),
              
              // Title
              Text(
                'Check Your Email',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 2.h),
              
              // Subtitle
              Text(
                'We\'ve sent a verification link to:\n$_userEmail\n\nPlease check your email and click the verification link to continue.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 4.h),
              
              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 5.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
              ],
              
              // Check Verification Button
              ElevatedButton(
                onPressed: _isCheckingVerification ? null : _checkVerificationStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 4.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isCheckingVerification
                    ? SizedBox(
                        height: 5.w,
                        width: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'I\'ve Verified My Email',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              SizedBox(height: 2.h),
              
              // Resend Email Button
              OutlinedButton(
                onPressed: _isLoading ? null : _resendVerificationEmail,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.primary),
                  padding: EdgeInsets.symmetric(vertical: 4.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 5.w,
                        width: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      )
                    : Text(
                        'Resend Verification Email',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              const Spacer(),
              
              // Help Text
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 6.w,
                    ),
                    SizedBox(height: 2.w),
                    Text(
                      'Didn\'t receive the email?',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '• Check your spam/junk folder\n'
                      '• Make sure you entered the correct email\n'
                      '• Wait a few minutes for the email to arrive\n'
                      '• Try resending the verification email',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}