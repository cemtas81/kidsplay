import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../repositories/child_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _loadingOpacityAnimation;
  
  String _targetRoute = '/parent-onboarding'; // Default route

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Defer context-dependent work until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashSequence();
    });
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Loading animation controller
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Logo scale animation with bounce effect
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Loading indicator opacity animation
    _loadingOpacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // Start logo animation
    _logoAnimationController.forward();

    // Perform background initialization tasks
    await _initializeApp();

    // Navigate to appropriate screen after splash duration
    await Future.delayed(const Duration(milliseconds: 2500));
    _navigateToNextScreen();
  }

  Future<void> _initializeApp() async {
    try {
      // Check Firebase authentication state
      final user = FirebaseAuth.instance.currentUser;
      
      String targetRoute = '/parent-onboarding'; // Default route
      
      if (user != null) {
        // User is signed in, check if email is verified and if they have children
        if (user.emailVerified || user.isAnonymous) {
          // Check if user has children profiles
          final childRepository = ChildRepository();
          final children = await childRepository.watchChildrenOf(user.uid).first;
          
          // Determine navigation decision
          if (children.isNotEmpty) {
            targetRoute = '/child-selection-dashboard';
          } else {
            targetRoute = '/child-profile-creation';
          }
          
          debugPrint('✅ User authenticated, navigating to: $targetRoute');
        } else {
          // User exists but email not verified
          targetRoute = '/email-verification';
          debugPrint('⚠️ User email not verified, redirecting to email verification');
        }
      } else {
        // No authenticated user
        debugPrint('ℹ️ No authenticated user, showing onboarding');
      }

      // Store navigation decision safely after async operations complete
      if (mounted) {
        setState(() {
          _targetRoute = targetRoute;
        });
      }

      // Simulate loading time for better UX
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('⚠️ Initialization error: $e');
      if (mounted) {
        setState(() {
          _targetRoute = '/parent-onboarding';
        });
      }
    }
  }

  void _navigateToNextScreen() {
    // Navigate based on authentication state determined during initialization
    if (mounted) {
      Navigator.pushReplacementNamed(context, _targetRoute);
      debugPrint('🚀 Navigating to: $_targetRoute');
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
              AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer to push content to center
              const Spacer(flex: 2),

              // Animated logo section
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: _buildLogo(),
                    ),
                  );
                },
              ),

              SizedBox(height: 6.h),

              // App name with fade-in animation
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Text(
                      'KidsPlay',
                      style:
                          AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

              SizedBox(height: 2.h),

              // Tagline
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacityAnimation.value * 0.8,
                    child: Text(
                      'Fun Activities, Less Screen Time',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

              const Spacer(flex: 1),

              // Animated loading indicator
              AnimatedBuilder(
                animation: _loadingAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loadingOpacityAnimation.value,
                    child: _buildLoadingIndicator(),
                  );
                },
              ),

              SizedBox(height: 4.h),

              // Loading text
              Text(
                'Preparing your activities...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'child_care',
          color: Colors.white,
          size: 12.w,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _loadingAnimationController,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue =
                (_loadingAnimationController.value - delay).clamp(0.0, 1.0);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              child: Transform.scale(
                scale: 0.8 + (0.4 * animationValue),
                child: Container(
                  width: 3.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 0.6 + (0.4 * animationValue),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
