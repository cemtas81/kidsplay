import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Utility class for authentication-related operations
class AuthUtils {
  static final AuthService _authService = AuthService();

  /// Get current user safely through AuthService
  static User? get currentUser => _authService.getCurrentUser();

  /// Check if user is fully authenticated (not anonymous and email verified)
  static bool get isFullyAuthenticated {
    final user = currentUser;
    return user != null && !user.isAnonymous && (user.emailVerified || user.isAnonymous);
  }

  /// Get user display name or email as fallback
  static String get userDisplayName {
    final user = currentUser;
    if (user == null) return 'Guest';
    
    return user.displayName?.isNotEmpty == true 
        ? user.displayName! 
        : user.email?.split('@').first ?? 'User';
  }

  /// Get user email safely
  static String get userEmail {
    return currentUser?.email ?? '';
  }

  /// Check if current user is using demo credentials
  static bool get isDemoUser {
    final email = userEmail.toLowerCase();
    return email == 'parent@kidsplay.com';
  }

  /// Show authentication required dialog with custom actions
  static void showAuthRequiredDialog(
    BuildContext context, {
    String title = 'Authentication Required',
    String message = 'You need to be signed in to access this feature.',
    VoidCallback? onSignIn,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onSignIn != null) {
                onSignIn();
              } else {
                Navigator.pushReplacementNamed(context, '/parent-login');
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  /// Show email verification required dialog
  static void showEmailVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Email Verification Required'),
        content: const Text(
          'Please verify your email address to continue using all features of the app.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/email-verification');
            },
            child: const Text('Verify Email'),
          ),
        ],
      ),
    );
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  static String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null; // Password is valid
  }

  /// Generate a user-friendly error message for Firebase Auth errors
  static String getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'invalid-credential':
        return 'The credential is invalid or has expired.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Safe navigation that checks authentication
  static Future<bool> safeNavigate(
    BuildContext context,
    String routeName, {
    bool requireAuth = true,
    bool requireEmailVerification = false,
  }) async {
    if (requireAuth && !isFullyAuthenticated) {
      showAuthRequiredDialog(context);
      return false;
    }

    if (requireEmailVerification && currentUser != null && !currentUser!.emailVerified) {
      showEmailVerificationDialog(context);
      return false;
    }

    Navigator.pushNamed(context, routeName);
    return true;
  }

  /// Logout with confirmation
  static Future<void> logoutWithConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        await _authService.signOut();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/parent-login',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign out failed: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Check and refresh session if needed
  static Future<bool> ensureValidSession() async {
    try {
      final isExpired = await _authService.isSessionExpired();
      if (isExpired) {
        await _authService.signOut();
        return false;
      }
      
      // Refresh session to extend validity
      await _authService.refreshSession();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get time until session expires (approximate)
  static Duration? getSessionTimeRemaining() {
    final user = currentUser;
    if (user == null) return null;
    
    // Firebase tokens are valid for 1 hour by default
    // This is an approximation since we don't have exact token issue time
    return const Duration(hours: 1);
  }
}