import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Authentication middleware to protect routes
class AuthGuard {
  static final AuthService _authService = AuthService();

  // Add method to clear auth cache when needed
  static void clearAuthCache() {
    _AuthGuardWidgetState._lastAuthCheck = null;
    _AuthGuardWidgetState._lastAuthResult = null;
  }

  /// Check if user is authenticated and redirect if not
  static Future<bool> requireAuth(BuildContext context) async {
    // TODO: TEMPORARY MOCK AUTH HANDLING - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
    // Check if user is authenticated using AuthService (handles both mock and real auth)
    if (_authService.isAuthenticated()) {
      return true;
    }
    
    // User is not authenticated, redirect to login
    Navigator.pushReplacementNamed(context, '/parent-login');
    return false;
  }

  /// Check if user is authenticated without redirecting
  static bool isAuthenticated() {
    // TODO: TEMPORARY MOCK AUTH HANDLING - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
    // Use AuthService which handles both mock and real authentication
    final authService = AuthService();
    return authService.isAuthenticated();
  }

  /// Check if user email is verified
  static bool isEmailVerified() {
    // TODO: TEMPORARY MOCK AUTH HANDLING - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
    final authService = AuthService();
    final user = authService.getCurrentUser();
    return user?.emailVerified ?? false;
  }

  /// Require email verification or redirect to verification screen
  static Future<bool> requireEmailVerification(BuildContext context) async {
    if (!isAuthenticated()) {
      Navigator.pushReplacementNamed(context, '/parent-login');
      return false;
    }

    if (!isEmailVerified()) {
      // Navigate to email verification screen (could be implemented)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email address to continue'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    return true;
  }

  /// Show authentication required dialog
  static void showAuthRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text('You need to be signed in to access this feature.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/parent-login');
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  /// Auto-logout on session expiry
  static Future<void> startSessionMonitoring(BuildContext context) async {
    // TODO: TEMPORARY MOCK AUTH HANDLING - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
    // For mock auth, we'll use a simplified session monitoring approach
    final authService = AuthService();
    
    // Monitor auth state changes
    // Note: In mock mode, this will be a simplified implementation
    try {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null && context.mounted && !authService.isAuthenticated()) {
          // User signed out, redirect to login
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/parent-login', 
            (route) => false,
          );
        }
      });
    } catch (e) {
      // If Firebase isn't available, use periodic checks instead
      print('⚠️ Firebase auth state monitoring unavailable, using periodic checks');
    }

    // Periodic session validation (every 30 minutes)
    _startPeriodicSessionCheck(context);
  }

  static void _startPeriodicSessionCheck(BuildContext context) {
    const duration = Duration(minutes: 30);
    
    void checkSession() async {
      if (!context.mounted) return;
      
      try {
        // TODO: TEMPORARY MOCK AUTH HANDLING - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
        // In mock mode, we'll skip the complex session expiry logic
        final authService = AuthService();
        if (!authService.isAuthenticated() && context.mounted) {
          await authService.signOut();
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/parent-login', 
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your session has expired. Please sign in again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        // Ignore errors in periodic checks
      }
      
      // Schedule next check
      if (context.mounted) {
        Future.delayed(duration, checkSession);
      }
    }
    
    // Start the periodic checks
    Future.delayed(duration, checkSession);
  }
}

/// Widget wrapper that requires authentication
class AuthGuardWidget extends StatefulWidget {
  final Widget child;
  final bool requireEmailVerification;
  
  const AuthGuardWidget({
    super.key,
    required this.child,
    this.requireEmailVerification = false,
  });

  @override
  State<AuthGuardWidget> createState() => _AuthGuardWidgetState();
}

class _AuthGuardWidgetState extends State<AuthGuardWidget> {
  bool _isChecking = true;
  bool _isAuthorized = false;
  static DateTime? _lastAuthCheck;
  static bool? _lastAuthResult;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Cache authentication result for 30 seconds to reduce overhead
    if (_lastAuthCheck != null && 
        _lastAuthResult != null && 
        DateTime.now().difference(_lastAuthCheck!).inSeconds < 30) {
      setState(() {
        _isChecking = false;
        _isAuthorized = _lastAuthResult!;
      });
      
      if (_lastAuthResult!) {
        // Start session monitoring for this screen
        AuthGuard.startSessionMonitoring(context);
      }
      return;
    }
    
    bool authorized = await AuthGuard.requireAuth(context);
    
    if (authorized && widget.requireEmailVerification) {
      authorized = await AuthGuard.requireEmailVerification(context);
    }

    // Cache the result
    _lastAuthCheck = DateTime.now();
    _lastAuthResult = authorized;

    if (mounted) {
      setState(() {
        _isChecking = false;
        _isAuthorized = authorized;
      });

      if (authorized) {
        // Start session monitoring for this screen
        AuthGuard.startSessionMonitoring(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Show loading while checking authentication
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthorized) {
      // This shouldn't normally be reached as navigation happens in _checkAuth
      return const Scaffold(
        body: Center(
          child: Text('Authentication required'),
        ),
      );
    }

    return widget.child;
  }
}