import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationFormWidget extends StatefulWidget {
  final Function(String fullName, String email, String password) onSubmit;
  final bool isLoading;

  const RegistrationFormWidget({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;

  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    setState(() {
      switch (score) {
        case 0:
        case 1:
          _passwordStrength = 'Very Weak';
          _passwordStrengthColor = const Color(0xFFD67B7B);
          break;
        case 2:
          _passwordStrength = 'Weak';
          _passwordStrengthColor = const Color(0xFFE8B86D);
          break;
        case 3:
          _passwordStrength = 'Fair';
          _passwordStrengthColor = const Color(0xFFE8B86D);
          break;
        case 4:
          _passwordStrength = 'Good';
          _passwordStrengthColor = const Color(0xFF7BA05B);
          break;
        case 5:
          _passwordStrength = 'Strong';
          _passwordStrengthColor = const Color(0xFF6B8E6B);
          break;
      }
    });
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool get _isFormValid {
    return _formKey.currentState?.validate() == true &&
        _agreedToTerms &&
        _agreedToPrivacy &&
        _passwordStrength != 'Very Weak';
  }

  void _handleSubmit() {
    if (_isFormValid) {
      widget.onSubmit(
        _fullNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          Text(
            'Full Name',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _fullNameController,
            focusNode: _fullNameFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator: _validateFullName,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person_outline',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: _fullNameController.text.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.getSuccessColor(!isDark),
                        size: 20,
                      ),
                    )
                  : null,
            ),
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 3.h),

          // Email Field
          Text(
            'Email Address',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'email_outlined',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: _emailController.text.isNotEmpty &&
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(_emailController.text.trim())
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.getSuccessColor(!isDark),
                        size: 20,
                      ),
                    )
                  : null,
            ),
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 3.h),

          // Password Field
          Text(
            'Password',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            textInputAction: TextInputAction.next,
            obscureText: !_isPasswordVisible,
            validator: _validatePassword,
            onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock_outline',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName:
                        _isPasswordVisible ? 'visibility_off' : 'visibility',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),
            onChanged: (value) {
              _checkPasswordStrength(value);
              setState(() {});
            },
          ),

          // Password Strength Indicator
          if (_passwordController.text.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                Text(
                  'Password Strength: ',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  _passwordStrength,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _passwordStrengthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 3.h),

          // Confirm Password Field
          Text(
            'Confirm Password',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            textInputAction: TextInputAction.done,
            obscureText: !_isConfirmPasswordVisible,
            validator: _validateConfirmPassword,
            onFieldSubmitted: (_) => _handleSubmit(),
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock_outline',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() =>
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: _isConfirmPasswordVisible
                        ? 'visibility_off'
                        : 'visibility',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 4.h),

          // Terms and Privacy Checkboxes
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 6.w,
                height: 6.w,
                child: Checkbox(
                  value: _agreedToTerms,
                  onChanged: (value) =>
                      setState(() => _agreedToTerms = value ?? false),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 6.w,
                height: 6.w,
                child: Checkbox(
                  value: _agreedToPrivacy,
                  onChanged: (value) =>
                      setState(() => _agreedToPrivacy = value ?? false),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _agreedToPrivacy = !_agreedToPrivacy),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Create Account Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed:
                  _isFormValid && !widget.isLoading ? _handleSubmit : null,
              child: widget.isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Create Account',
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
