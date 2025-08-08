import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiometricAuthWidget extends StatefulWidget {
  final VoidCallback onBiometricSuccess;
  final Function(String) onBiometricError;
  final bool isAvailable;

  const BiometricAuthWidget({
    super.key,
    required this.onBiometricSuccess,
    required this.onBiometricError,
    this.isAvailable = false,
  });

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isAvailable) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating || !widget.isAvailable) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(milliseconds: 1500));

      // Mock successful authentication for demo
      HapticFeedback.lightImpact();
      widget.onBiometricSuccess();
    } catch (e) {
      HapticFeedback.heavyImpact();
      widget.onBiometricError(
          'Biometric authentication failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!widget.isAvailable) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 3.h),
      child: Column(
        children: [
          // Biometric Icon Button
          GestureDetector(
            onTap: _authenticateWithBiometrics,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isAuthenticating ? 1.0 : _pulseAnimation.value,
                  child: Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: _isAuthenticating
                        ? Center(
                            child: SizedBox(
                              width: 6.w,
                              height: 6.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: CustomIconWidget(
                              iconName: 'fingerprint',
                              color: theme.colorScheme.primary,
                              size: 8.w,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),

          // Biometric Text
          Text(
            _isAuthenticating
                ? 'Authenticating...'
                : 'Touch to sign in with biometrics',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 3.h),

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
    );
  }
}