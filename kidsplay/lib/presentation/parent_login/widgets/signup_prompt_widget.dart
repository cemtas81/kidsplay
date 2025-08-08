import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class SignupPromptWidget extends StatelessWidget {
  final VoidCallback onSignUpTap;

  const SignupPromptWidget({
    super.key,
    required this.onSignUpTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(top: 4.h, bottom: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New to the app? ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          GestureDetector(
            onTap: onSignUpTap,
            child: Text(
              'Sign Up',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
