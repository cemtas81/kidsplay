import 'package:flutter/material.dart';
import '../presentation/parent_login/parent_login.dart';
import '../presentation/child_profile_creation/child_profile_creation.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/parent_onboarding/parent_onboarding.dart';
import '../presentation/parent_registration/parent_registration.dart';
import '../presentation/child_selection_dashboard/child_selection_dashboard.dart';
import '../presentation/multi_parent_management/multi_parent_screen.dart';
import '../presentation/password_reset/password_reset_screen.dart';
import '../presentation/email_verification/email_verification_screen.dart';
import '../presentation/progress_tracking/progress_dashboard_screen.dart';
import '../models/child.dart';

class AppRoutes {
  // Application route constants
  static const String initial = '/';
  static const String parentLogin = '/parent-login';
  static const String childProfileCreation = '/child-profile-creation';
  static const String splash = '/splash-screen';
  static const String parentOnboarding = '/parent-onboarding';
  static const String parentRegistration = '/parent-registration';
  static const String childSelectionDashboard = '/child-selection-dashboard';
  static const String multiParentManagement = '/multi-parent-management';
  static const String passwordReset = '/password-reset';
  static const String emailVerification = '/email-verification';
  static const String progressTracking = '/progress-tracking';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    parentLogin: (context) => const ParentLogin(),
    childProfileCreation: (context) => const ChildProfileCreation(),
    splash: (context) => const SplashScreen(),
    parentOnboarding: (context) => const ParentOnboarding(),
    parentRegistration: (context) => const ParentRegistration(),
    childSelectionDashboard: (context) => const ChildSelectionDashboard(),
    multiParentManagement: (context) => const MultiParentScreen(),
    passwordReset: (context) => const PasswordResetScreen(),
    emailVerification: (context) => const EmailVerificationScreen(),
    progressTracking: (context) {
      final child = ModalRoute.of(context)?.settings.arguments as Child?;
      if (child != null) {
        return ProgressDashboardScreen(child: child);
      } else {
        // Fallback to a default/mock child if no argument provided
        return ProgressDashboardScreen(
          child: Child(
            id: 'mock-child-id',
            name: 'Demo Child',
            surname: 'Demo',
            birthDate: DateTime(2020, 1, 1),
            gender: 'unknown',
            hobbies: [],
            hasScreenDependency: false,
            screenDependencyLevel: 'low',
            usesScreenDuringMeals: false,
            wantsToChange: false,
            dailyPlayTime: '1-2 hours',
            parentIds: ['mock-parent-id'],
            relationshipToParent: 'parent',
            hasCameraPermission: false,
          ),
        );
      }
    },
  };
}
