import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/onboarding_navigation_widget.dart';
import './widgets/onboarding_slide_widget.dart';
import './widgets/page_indicator_widget.dart';
import './widgets/privacy_policy_widget.dart';

class ParentOnboarding extends StatefulWidget {
  const ParentOnboarding({super.key});

  @override
  State<ParentOnboarding> createState() => _ParentOnboardingState();
}

class _ParentOnboardingState extends State<ParentOnboarding>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _autoAdvanceTimer;

  int _currentPage = 0;
  bool _isUserInteracting = false;
  bool _isRTL = false;

  // Mock onboarding data
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Reduce Screen Time Naturally",
      "imageUrl":
          "https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "bulletPoints": [
        "Transform screen addiction into healthy play habits",
        "Age-appropriate activities for children 1.5-6 years",
        "Gentle transition from digital to physical activities"
      ]
    },
    {
      "title": "Engaging Physical Activities",
      "imageUrl":
          "https://images.unsplash.com/photo-1544717297-fa95b6ee9643?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "bulletPoints": [
        "Personalized activities based on your child's interests",
        "Indoor and outdoor play options for any weather",
        "Creative projects that boost imagination and motor skills"
      ]
    },
    {
      "title": "Track Progress & Growth",
      "imageUrl":
          "https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "bulletPoints": [
        "Monitor your child's development milestones",
        "Visual progress tracking with badges and rewards",
        "Detailed analytics on activity completion and engagement"
      ]
    },
    {
      "title": "Multi-Parent Collaboration",
      "imageUrl":
          "https://images.unsplash.com/photo-1609220136736-443140cffec6?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "bulletPoints": [
        "Share parenting responsibilities seamlessly",
        "Invite grandparents, caregivers, and co-parents",
        "Synchronized activity tracking across all devices"
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _detectLanguageDirection();
    _startAutoAdvance();
  }

  void _initializeControllers() {
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  void _detectLanguageDirection() {
    final locale = Localizations.localeOf(context);
    _isRTL = locale.languageCode == 'ar';
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(
      const Duration(seconds: 8),
      (timer) {
        if (!_isUserInteracting && mounted) {
          _nextPage();
        }
      },
    );
  }

  void _pauseAutoAdvance() {
    setState(() {
      _isUserInteracting = true;
    });

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
        });
      }
    });
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/parent-registration');
  }

  void _getStarted() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, '/parent-registration');
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPrivacyPolicyModal(),
    );
  }

  Widget _buildPrivacyPolicyModal() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.textDisabledDark
                  : AppTheme.textDisabledLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Privacy Policy',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Protection',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'We use industry-standard encryption to protect all personal data. Your child\'s information is never shared with third parties without explicit consent.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Camera & Recording',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Video recordings are stored locally on your device and in secure cloud storage for 15 days. You have full control over recording permissions and can disable this feature at any time.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Parental Controls',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'All app access requires parental authentication. Children cannot exit the app or access settings without parent approval.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Skip Button
              Positioned(
                top: 2.h,
                right: _isRTL ? null : 6.w,
                left: _isRTL ? 6.w : null,
                child: _currentPage < _onboardingData.length - 1
                    ? TextButton(
                        onPressed: _skipOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Skip',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            CustomIconWidget(
                              iconName: _isRTL ? 'arrow_back' : 'arrow_forward',
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                              size: 16,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Main Content
              Column(
                children: [
                  // Page View
                  Expanded(
                    child: GestureDetector(
                      onTap: _pauseAutoAdvance,
                      onPanStart: (_) => _pauseAutoAdvance(),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                          _pauseAutoAdvance();
                        },
                        itemCount: _onboardingData.length,
                        itemBuilder: (context, index) {
                          final slide = _onboardingData[index];
                          return OnboardingSlideWidget(
                            imageUrl: slide["imageUrl"] as String,
                            title: slide["title"] as String,
                            bulletPoints: (slide["bulletPoints"] as List)
                                .map((point) => point as String)
                                .toList(),
                            isRTL: _isRTL,
                          );
                        },
                      ),
                    ),
                  ),

                  // Privacy Policy (only on last slide)
                  if (_currentPage == _onboardingData.length - 1)
                    PrivacyPolicyWidget(
                      onPrivacyPolicyTap: _showPrivacyPolicy,
                    ),

                  // Page Indicator
                  PageIndicatorWidget(
                    currentPage: _currentPage,
                    totalPages: _onboardingData.length,
                    pageController: _pageController,
                  ),

                  // Navigation Buttons
                  OnboardingNavigationWidget(
                    currentPage: _currentPage,
                    totalPages: _onboardingData.length,
                    onNext: _nextPage,
                    onGetStarted: _getStarted,
                    onSkip: _skipOnboarding,
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
