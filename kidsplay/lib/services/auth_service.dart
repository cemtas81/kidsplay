import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';

class AuthService {
  // Firebase is already initialized in main.dart, no need to initialize again
  
  static Future<void> _ensureFirebaseReady() async {
    // Just verify Firebase is ready, don't initialize again
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase not initialized. Please ensure Firebase.initializeApp() is called in main.dart');
    }
    print('✅ Firebase is ready for authentication');
  }

  static Future<User> ensureInitializedAndSignedIn() async {
    await _ensureFirebaseReady();
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      throw Exception('No authenticated user found. Please login first.');
    }
    return auth.currentUser!;
  }

  static Future<String> getUid() async {
    final user = await ensureInitializedAndSignedIn();
    return user.uid;
  }

  // Demo credentials for testing
  static const String _demoEmail = 'parent@kidsplay.com';
  static const String _demoPassword = 'Parent123';
  
  // Check if using demo credentials
  bool _isDemoCredentials(String email, String password) {
    return email.toLowerCase() == _demoEmail && password == _demoPassword;
  }

  // Email/Password Authentication methods
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    await _ensureFirebaseReady();
    
    // Handle demo credentials with fallback if Firebase fails
    if (_isDemoCredentials(email, password)) {
      try {
        print('🔐 Attempting to sign in user: $email');
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Sign in successful for user: ${credential.user?.email}');
        return credential.user;
      } catch (e) {
        print('⚠️ Firebase sign in failed, but demo credentials provided: $e');
        print('🎭 Using demo mode for development');
        
        // For demo purposes, use anonymous authentication as fallback
        try {
          final anonCredential = await FirebaseAuth.instance.signInAnonymously();
          print('✅ Demo mode: Anonymous user created for development');
          return anonCredential.user;
        } catch (anonError) {
          print('❌ Anonymous authentication also failed: $anonError');
          print('🚨 Firebase appears to be completely unavailable');
          rethrow; // If even anonymous auth fails, Firebase is completely down
        }
      }
    }
    
    try {
      print('🔐 Attempting to sign in user: $email');
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Sign in successful for user: ${credential.user?.email}');
      return credential.user;
    } catch (e) {
      print('❌ Sign in failed: $e');
      rethrow;
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    await _ensureFirebaseReady();
    
    // Handle demo credentials for user creation
    if (_isDemoCredentials(email, password)) {
      try {
        print('👤 Attempting to create user: $email');
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ User creation successful for: ${credential.user?.email}');
        return credential.user;
      } catch (e) {
        print('⚠️ User creation failed, but demo credentials provided: $e');
        print('🎭 Using demo mode - signing in with anonymous user');
        
        // For demo purposes, use anonymous authentication as fallback
        try {
          final anonCredential = await FirebaseAuth.instance.signInAnonymously();
          print('✅ Demo mode: Anonymous user created for development');
          return anonCredential.user;
        } catch (anonError) {
          print('❌ Anonymous authentication also failed: $anonError');
          print('🚨 Firebase appears to be completely unavailable');
          rethrow; // If even anonymous auth fails, Firebase is completely down
        }
      }
    }
    
    try {
      print('👤 Attempting to create user: $email');
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ User creation successful for: ${credential.user?.email}');
      return credential.user;
    } catch (e) {
      print('❌ User creation failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  // Check if user is authenticated (not anonymous)
  bool isAuthenticated() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && !user.isAnonymous;
  }

  // Get current user safely with error handling
  static Future<User?> getCurrentUserSafely() async {
    await _ensureFirebaseReady();
    return FirebaseAuth.instance.currentUser;
  }

  // Stream of authentication state changes
  Stream<User?> get authStateChanges {
    return FirebaseAuth.instance.authStateChanges();
  }

  // Password reset functionality
  Future<void> sendPasswordResetEmail(String email) async {
    await _ensureFirebaseReady();
    
    try {
      print('📧 Sending password reset email to: $email');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent successfully');
    } catch (e) {
      print('❌ Failed to send password reset email: $e');
      rethrow;
    }
  }

  // Email verification methods
  Future<void> sendEmailVerification() async {
    await _ensureFirebaseReady();
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null && !user.emailVerified) {
      try {
        print('📧 Sending email verification to: ${user.email}');
        await user.sendEmailVerification();
        print('✅ Email verification sent successfully');
      } catch (e) {
        print('❌ Failed to send email verification: $e');
        rethrow;
      }
    } else if (user?.emailVerified == true) {
      print('ℹ️ Email already verified for: ${user?.email}');
    } else {
      throw Exception('No user found to send verification email');
    }
  }

  Future<void> reloadUser() async {
    await _ensureFirebaseReady();
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      await user.reload();
      print('🔄 User data reloaded');
    }
  }

  bool get isEmailVerified {
    final user = FirebaseAuth.instance.currentUser;
    return user?.emailVerified ?? false;
  }

  // Update user profile methods
  Future<void> updateDisplayName(String displayName) async {
    await _ensureFirebaseReady();
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        await user.updateDisplayName(displayName);
        await user.reload();
        print('✅ Display name updated to: $displayName');
      } catch (e) {
        print('❌ Failed to update display name: $e');
        rethrow;
      }
    } else {
      throw Exception('No authenticated user found');
    }
  }

  Future<void> updateEmail(String newEmail) async {
    await _ensureFirebaseReady();
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        await user.verifyBeforeUpdateEmail(newEmail);
        print('✅ Email update verification sent to: $newEmail');
      } catch (e) {
        print('❌ Failed to update email: $e');
        rethrow;
      }
    } else {
      throw Exception('No authenticated user found');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    await _ensureFirebaseReady();
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        print('✅ Password updated successfully');
      } catch (e) {
        print('❌ Failed to update password: $e');
        rethrow;
      }
    } else {
      throw Exception('No authenticated user found');
    }
  }

  // Re-authentication for sensitive operations
  Future<void> reauthenticateWithPassword(String password) async {
    await _ensureFirebaseReady();
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null && user.email != null) {
      try {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        print('✅ User re-authenticated successfully');
      } catch (e) {
        print('❌ Re-authentication failed: $e');
        rethrow;
      }
    } else {
      throw Exception('No authenticated user found or email missing');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    await _ensureFirebaseReady();
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        await user.delete();
        print('✅ User account deleted successfully');
      } catch (e) {
        print('❌ Failed to delete account: $e');
        rethrow;
      }
    } else {
      throw Exception('No authenticated user found');
    }
  }

  // Google Sign-in methods
  Future<User?> signInWithGoogle() async {
    await _ensureFirebaseReady();
    
    try {
      print('🔐 Attempting Google Sign-In');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        print('⚠️ Google Sign-In canceled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      print('✅ Google Sign-In successful for user: ${userCredential.user?.email}');
      return userCredential.user;
    } catch (e) {
      print('❌ Google Sign-In failed: $e');
      rethrow;
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      print('✅ Google Sign-Out successful');
    } catch (e) {
      print('❌ Google Sign-Out failed: $e');
      rethrow;
    }
  }

  // Session management
  bool get hasValidSession {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && !user.isAnonymous;
  }

  Future<bool> isSessionExpired() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return true;
      
      // Get fresh token to check if session is still valid
      await user.getIdToken(true);
      return false;
    } catch (e) {
      print('⚠️ Session check failed: $e');
      return true;
    }
  }

  Future<void> refreshSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.getIdToken(true);
        print('🔄 Session refreshed successfully');
      }
    } catch (e) {
      print('❌ Session refresh failed: $e');
      rethrow;
    }
  }
}