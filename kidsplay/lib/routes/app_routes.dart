import 'package:flutter/material.dart';
import '../presentation/parent_login/parent_login.dart';
import '../presentation/child_profile_creation/child_profile_creation.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/parent_onboarding/parent_onboarding.dart';
import '../presentation/parent_registration/parent_registration.dart';
import '../presentation/child_selection_dashboard/child_selection_dashboard.dart';
import '../presentation/multi_parent_management/multi_parent_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String parentLogin = '/parent-login';
  static const String childProfileCreation = '/child-profile-creation';
  static const String splash = '/splash-screen';
  static const String parentOnboarding = '/parent-onboarding';
  static const String parentRegistration = '/parent-registration';
  static const String childSelectionDashboard = '/child-selection-dashboard';
  static const String multiParentManagement = '/multi-parent-management';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    parentLogin: (context) => const ParentLogin(),
    childProfileCreation: (context) => const ChildProfileCreation(),
    splash: (context) => const SplashScreen(),
    parentOnboarding: (context) => const ParentOnboarding(),
    parentRegistration: (context) => const ParentRegistration(),
    childSelectionDashboard: (context) => const ChildSelectionDashboard(),
    multiParentManagement: (context) => const MultiParentScreen(),
    // TODO: Add your other routes here
  };
}
