import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_provider.dart';
import './widgets/app_logo_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/social_registration_widget.dart';

class ParentRegistration extends StatefulWidget {
  const ParentRegistration({super.key});

  @override
  State<ParentRegistration> createState() => _ParentRegistrationState();
}

class _ParentRegistrationState extends State<ParentRegistration> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isSocialLoading = false;
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    _authProvider.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    if (_authProvider.errorMessage != null) {
      _showErrorToast(_authProvider.errorMessage!);
      setState(() {
        _isLoading = false;
        _isSocialLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration(
      String fullName, String email, String password) async {
    setState(() => _isLoading = true);

    try {
      final success = await _authProvider.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (success && mounted) {
        _showSuccessToast('Account created successfully!');
        
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/child-profile-creation');
        }
      }
    } catch (e) {
      _showErrorToast('Registration failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isSocialLoading = true);

    try {
      final success = await _authProvider.signInWithGoogle();

      if (success && mounted) {
        _showSuccessToast('Google sign-up successful!');

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/child-profile-creation');
        }
      }
    } catch (e) {
      _showErrorToast('Google sign-up failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSocialLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignUp() async {
    setState(() => _isSocialLoading = true);

    try {
      // Apple Sign-In not implemented yet, show message
      _showErrorToast('Apple sign-in coming soon!');
    } catch (e) {
      _showErrorToast('Apple sign-up failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSocialLoading = false);
      }
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.getSuccessColor(
          Theme.of(context).brightness == Brightness.light),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.error,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/parent-login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/parent-onboarding'),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 2.h),

              // App Logo
              const AppLogoWidget(),
              SizedBox(height: 4.h),

              // Welcome Text
              Text(
                'Create Your Account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),

              Text(
                'Join KidsPlay to help your child develop healthy screen habits through fun activities',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),

              // Registration Form
              RegistrationFormWidget(
                onSubmit: _handleRegistration,
                isLoading: _isLoading,
              ),
              SizedBox(height: 4.h),

              // Social Registration
              SocialRegistrationWidget(
                onGoogleSignUp: _handleGoogleSignUp,
                onAppleSignUp: _handleAppleSignUp,
                isLoading: _isSocialLoading,
              ),
              SizedBox(height: 4.h),

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToLogin,
                    child: Text(
                      'Sign In',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
