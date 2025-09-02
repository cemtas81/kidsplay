import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';

// ==========================================
// AUTHENTICATION MODE CONFIGURATION
// ==========================================
// Set this flag to control authentication behavior:
// - true:  Use mock authentication (demo mode) - works offline, uses demo credentials
// - false: Use Firebase authentication (production mode) - requires Firebase connection
//
// DEMO CREDENTIALS (when _useMockAuth = true):
// Email: demo@demo.com
// Password: demo1234
//
// This allows the app to work seamlessly whether Firebase is available or not.
// ==========================================

// Mock User Implementation for Development and Offline Testing
// This allows the app to function without Firebase connectivity during development
class MockUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool emailVerified;
  @override
  final bool isAnonymous;
  
  MockUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.emailVerified = true,
    this.isAnonymous = false,
  });
  
  // Implement all other required User methods with stubs
  @override
  ActionCodeInfo? get actionCodeInfo => null;
  
  @override
  DateTime? get creationTime => DateTime.now();
  
  @override
  DateTime? get lastSignInTime => DateTime.now();
  
  @override
  String? get phoneNumber => null;
  
  @override
  String? get photoURL => null;
  
  @override
  List<UserInfo> get providerData => [];
  
  @override
  String? get refreshToken => null;
  
  @override
  String? get tenantId => null;
  
  @override
  UserMetadata get metadata => _MockUserMetadata();
  
  @override
  MultiFactor get multiFactor => throw UnimplementedError('Mock user does not support multifactor');
  
  @override
  Future<void> delete() async {
    throw UnimplementedError('Mock user deletion not implemented');
  }
  
  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    return 'mock-id-token';
  }
  
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    throw UnimplementedError('Mock user token result not implemented');
  }
  
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    throw UnimplementedError('Mock user linking not implemented');
  }
  
  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) async {
    throw UnimplementedError('Mock user phone linking not implemented');
  }
  
  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) async {
    throw UnimplementedError('Mock user popup linking not implemented');
  }
  
  @override
  Future<void> linkWithRedirect(AuthProvider provider) async {
    throw UnimplementedError('Mock user redirect linking not implemented');
  }
  
  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async {
    throw UnimplementedError('Mock user provider linking not implemented');
  }
  
  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async {
    throw UnimplementedError('Mock user reauthentication not implemented');
  }
  
  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) async {
    throw UnimplementedError('Mock user popup reauthentication not implemented');
  }
  
  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) async {
    throw UnimplementedError('Mock user redirect reauthentication not implemented');
  }
  
  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) async {
    throw UnimplementedError('Mock user provider reauthentication not implemented');
  }
  
  @override
  Future<void> reload() async {
    // Mock reload - do nothing
  }
  
  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {
    print('📧 Mock: Email verification sent to $email');
  }
  
  @override
  Future<User> unlink(String providerId) async {
    throw UnimplementedError('Mock user unlink not implemented');
  }
  
  @override
  Future<void> updateDisplayName(String? displayName) async {
    print('👤 Mock: Display name updated to $displayName');
  }
  
  @override
  Future<void> updateEmail(String newEmail) async {
    throw UnimplementedError('Mock user email update not implemented');
  }
  
  @override
  Future<void> updatePassword(String newPassword) async {
    throw UnimplementedError('Mock user password update not implemented');
  }
  
  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {
    throw UnimplementedError('Mock user phone update not implemented');
  }
  
  @override
  Future<void> updatePhotoURL(String? photoURL) async {
    print('📷 Mock: Photo URL updated to $photoURL');
  }
  
  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    print('👤 Mock: Profile updated - name: $displayName, photo: $photoURL');
  }
  
  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {
    throw UnimplementedError('Mock user email verification not implemented');
  }
}

class _MockUserMetadata implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
  
  @override
  DateTime? get lastRefreshTime => DateTime.now();
  
  @override
  DateTime? get lastSignInTime => DateTime.now();
}

class AuthService {
  // ==========================================
  // AUTHENTICATION MODE CONFIGURATION
  // ==========================================
  // CRITICAL: Set this flag to control authentication mode
  // - true:  Mock authentication (demo/offline mode) 
  // - false: Firebase authentication (production mode)
  static const bool _useMockAuth = true; // Set to false when real auth is restored
  
  // Public getter to expose mock mode status for other services
  static bool get isUsingMockAuth => _useMockAuth;
  
  // ==========================================
  // MOCK AUTHENTICATION SETTINGS
  // ==========================================
  static const String _mockUserId = 'mock-user-12345';
  static User? _mockUser; // Store mock user for session persistence
  
  // Demo credentials for testing (both mock and Firebase fallback)
  static const String _demoEmail = 'demo@demo.com';
  static const String _demoPassword = 'demo1234';
  
  // ==========================================
  // PERFORMANCE OPTIMIZATION
  // ==========================================
  // Cache for authentication state to reduce Firebase calls
  static DateTime? _lastAuthCheck;
  static bool? _lastAuthResult;
  
  // ==========================================
  // FIREBASE INITIALIZATION AND SAFETY CHECKS
  // ==========================================
  static Future<void> _ensureFirebaseReady() async {
    // Skip Firebase initialization check in mock mode
    if (_useMockAuth) {
      print('🎭 Mock authentication mode enabled - bypassing Firebase');
      print('ℹ️ Use demo credentials: $_demoEmail / $_demoPassword');
      return;
    }
    
    // Just verify Firebase is ready, don't initialize again
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase not initialized. Please ensure Firebase.initializeApp() is called in main.dart');
    }
    print('✅ Firebase is ready for authentication');
  }

  // ==========================================
  // USER MANAGEMENT UTILITIES
  // ==========================================
  static Future<User> ensureInitializedAndSignedIn() async {
    try {
      if (_useMockAuth && _mockUser != null) {
        print('✅ Mock user already authenticated: ${_mockUser!.email}');
        return _mockUser!;
      }
      
      await _ensureFirebaseReady();
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        throw Exception('No authenticated user found. Please login first.');
      }
      print('✅ Firebase user authenticated: ${auth.currentUser!.email}');
      return auth.currentUser!;
    } catch (e) {
      print('❌ Authentication check failed: $e');
      throw Exception('Authentication required. Please login to continue. Error: $e');
    }
  }

  static Future<String> getUid() async {
    try {
      if (_useMockAuth && _mockUser != null) {
        return _mockUser!.uid;
      }
      
      final user = await ensureInitializedAndSignedIn();
      return user.uid;
    } catch (e) {
      print('❌ Failed to get user ID: $e');
      throw Exception('Could not retrieve user ID. Please ensure you are logged in. Error: $e');
    }
  }

  // ==========================================
  // AUTHENTICATION CREDENTIAL VALIDATION
  // ==========================================
  // Check if using demo credentials
  bool _isDemoCredentials(String email, String password) {
    return email.toLowerCase() == _demoEmail && password == _demoPassword;
  }

  // ==========================================
  // EMAIL/PASSWORD AUTHENTICATION
  // ==========================================
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // MOCK AUTHENTICATION MODE
      if (_useMockAuth) {
        print('🎭 Mock authentication mode - validating credentials');
        
        // Only allow the specific demo credentials
        if (_isDemoCredentials(email, password)) {
          print('✅ Mock login successful for: $email');
          
          // Create and store mock user
          _mockUser = MockUser(
            uid: _mockUserId,
            email: email,
            displayName: 'Demo User',
            emailVerified: true,
            isAnonymous: false,
          );
          
          // Clear auth cache
          _lastAuthCheck = DateTime.now();
          _lastAuthResult = true;
          
          return _mockUser;
        } else {
          print('❌ Mock login failed - invalid credentials provided');
          print('ℹ️ Demo credentials required: $_demoEmail / $_demoPassword');
          throw FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Authentication service is in demo mode. Please use demo credentials:\nEmail: $_demoEmail\nPassword: $_demoPassword',
          );
        }
      }
      
      // FIREBASE AUTHENTICATION MODE
      await _ensureFirebaseReady();
      
      // Handle demo credentials with fallback if Firebase fails
      if (_isDemoCredentials(email, password)) {
        try {
          print('🔐 Attempting to sign in user: $email');
          final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('✅ Firebase sign in successful for user: ${credential.user?.email}');
          _clearAuthCache();
          return credential.user;
        } catch (e) {
          print('⚠️ Firebase sign in failed, but demo credentials provided: $e');
          print('🎭 Falling back to demo mode for development');
          
          // For demo purposes, use anonymous authentication as fallback
          try {
            final anonCredential = await FirebaseAuth.instance.signInAnonymously();
            print('✅ Demo mode: Anonymous user created for development');
            return anonCredential.user;
          } catch (anonError) {
            print('❌ Anonymous authentication also failed: $anonError');
            print('🚨 Firebase appears to be completely unavailable');
            throw FirebaseAuthException(
              code: 'firebase-unavailable',
              message: 'Authentication service is temporarily unavailable. Please try again later or contact support.',
            );
          }
        }
      }
      
      // Regular Firebase authentication for non-demo credentials
      print('🔐 Attempting to sign in user: $email');
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Sign in successful for user: ${credential.user?.email}');
      _clearAuthCache();
      return credential.user;
      
    } catch (e) {
      print('❌ Sign in failed: $e');
      _clearAuthCache();
      
      // Provide user-friendly error messages
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw FirebaseAuthException(
              code: e.code,
              message: 'No account found with this email address. Please check your email or create a new account.',
            );
          case 'wrong-password':
            throw FirebaseAuthException(
              code: e.code,
              message: 'Incorrect password. Please check your password or use "Forgot Password" to reset it.',
            );
          case 'invalid-email':
            throw FirebaseAuthException(
              code: e.code,
              message: 'Please enter a valid email address.',
            );
          case 'user-disabled':
            throw FirebaseAuthException(
              code: e.code,
              message: 'This account has been disabled. Please contact support for assistance.',
            );
          case 'too-many-requests':
            throw FirebaseAuthException(
              code: e.code,
              message: 'Too many failed login attempts. Please try again later or reset your password.',
            );
          default:
            rethrow;
        }
      }
      rethrow;
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      // MOCK AUTHENTICATION MODE
      if (_useMockAuth) {
        print('🎭 Mock registration mode - validating credentials');
        
        // Only allow the specific demo credentials for registration too
        if (_isDemoCredentials(email, password)) {
          print('✅ Mock registration successful for: $email');
          
          // Create and store mock user (same as login for demo purposes)
          _mockUser = MockUser(
            uid: _mockUserId,
            email: email,
            displayName: 'Demo User',
            emailVerified: true,
            isAnonymous: false,
          );
          
          // Clear auth cache
          _lastAuthCheck = DateTime.now();
          _lastAuthResult = true;
          
          return _mockUser;
        } else {
          print('❌ Mock registration failed - invalid credentials provided');
          print('ℹ️ Demo credentials required: $_demoEmail / $_demoPassword');
          throw FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Registration service is in demo mode. Please use demo credentials:\nEmail: $_demoEmail\nPassword: $_demoPassword',
          );
        }
      }
      
      // FIREBASE AUTHENTICATION MODE
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
          _clearAuthCache();
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
            throw FirebaseAuthException(
              code: 'firebase-unavailable',
              message: 'Registration service is temporarily unavailable. Please try again later or contact support.',
            );
          }
        }
      }
      
      // Regular Firebase user creation for non-demo credentials
      print('👤 Attempting to create user: $email');
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ User creation successful for: ${credential.user?.email}');
      _clearAuthCache();
      return credential.user;
      
    } catch (e) {
      print('❌ User creation failed: $e');
      _clearAuthCache();
      
      // Provide user-friendly error messages
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            throw FirebaseAuthException(
              code: e.code,
              message: 'An account with this email already exists. Please use a different email or try signing in.',
            );
          case 'invalid-email':
            throw FirebaseAuthException(
              code: e.code,
              message: 'Please enter a valid email address.',
            );
          case 'weak-password':
            throw FirebaseAuthException(
              code: e.code,
              message: 'Password is too weak. Please use at least 6 characters with a mix of letters and numbers.',
            );
          case 'operation-not-allowed':
            throw FirebaseAuthException(
              code: e.code,
              message: 'Email/password registration is not enabled. Please contact support.',
            );
          default:
            rethrow;
        }
      }
      rethrow;
    }
  }

  // ==========================================
  // SESSION MANAGEMENT
  // ==========================================
  Future<void> signOut() async {
    try {
      // MOCK AUTHENTICATION MODE
      if (_useMockAuth) {
        print('🎭 Mock sign out');
        _mockUser = null;
        _clearAuthCache();
        print('✅ Mock user signed out successfully');
        return;
      }
      
      // FIREBASE AUTHENTICATION MODE
      await _ensureFirebaseReady();
      await FirebaseAuth.instance.signOut();
      _clearAuthCache();
      print('✅ Firebase user signed out successfully');
      
    } catch (e) {
      print('❌ Sign out failed: $e');
      // Clear cache anyway in case of errors
      _clearAuthCache();
      rethrow;
    }
  }

  User? getCurrentUser() {
    try {
      // MOCK AUTHENTICATION MODE
      if (_useMockAuth) {
        return _mockUser;
      }
      
      // FIREBASE AUTHENTICATION MODE
      return FirebaseAuth.instance.currentUser;
      
    } catch (e) {
      print('❌ Failed to get current user: $e');
      return null;
    }
  }

  // ==========================================
  // AUTHENTICATION STATE CHECKING
  // ==========================================
  bool isAuthenticated() {
    try {
      // Use cached result if available and recent (within 30 seconds)
      if (_lastAuthCheck != null && 
          _lastAuthResult != null && 
          DateTime.now().difference(_lastAuthCheck!).inSeconds < 30) {
        return _lastAuthResult!;
      }
      
      // Check authentication based on current mode
      bool result;
      if (_useMockAuth) {
        result = _mockUser != null && !_mockUser!.isAnonymous;
        if (result) {
          print('✅ Mock user is authenticated: ${_mockUser!.email}');
        } else {
          print('ℹ️ No mock user authenticated');
        }
      } else {
        final user = FirebaseAuth.instance.currentUser;
        result = user != null && !user.isAnonymous;
        if (result) {
          print('✅ Firebase user is authenticated: ${user.email}');
        } else {
          print('ℹ️ No Firebase user authenticated');
        }
      }
      
      // Cache the result
      _lastAuthCheck = DateTime.now();
      _lastAuthResult = result;
      
      return result;
      
    } catch (e) {
      print('❌ Authentication check failed: $e');
      _clearAuthCache();
      return false;
    }
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================
  void _clearAuthCache() {
    _lastAuthCheck = null;
    _lastAuthResult = null;
  }

  // ==========================================
  // FIREBASE-SPECIFIC UTILITIES (Not available in mock mode)
  // ==========================================
  
  // Get current user safely with error handling
  static Future<User?> getCurrentUserSafely() async {
    try {
      if (_useMockAuth) {
        print('ℹ️ getCurrentUserSafely called in mock mode - returning mock user');
        return _mockUser;
      }
      
      await _ensureFirebaseReady();
      return FirebaseAuth.instance.currentUser;
    } catch (e) {
      print('❌ Failed to get current user safely: $e');
      return null;
    }
  }

  // Stream of authentication state changes
  Stream<User?> get authStateChanges {
    if (_useMockAuth) {
      print('⚠️ authStateChanges not available in mock mode - returning empty stream');
      return Stream.empty();
    }
    return FirebaseAuth.instance.authStateChanges();
  }

  // Password reset functionality
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (_useMockAuth) {
        print('🎭 Mock password reset email sent to: $email');
        print('ℹ️ In demo mode, password reset is simulated');
        return;
      }
      
      await _ensureFirebaseReady();
      
      print('📧 Sending password reset email to: $email');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent successfully');
      
    } catch (e) {
      print('❌ Failed to send password reset email: $e');
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw FirebaseAuthException(
              code: e.code,
              message: 'No account found with this email address. Please check your email or create a new account.',
            );
          case 'invalid-email':
            throw FirebaseAuthException(
              code: e.code,
              message: 'Please enter a valid email address.',
            );
          default:
            rethrow;
        }
      }
      rethrow;
    }
  }

  // Email verification methods
  Future<void> sendEmailVerification() async {
    try {
      if (_useMockAuth) {
        print('🎭 Mock email verification sent to: ${_mockUser?.email}');
        print('ℹ️ In demo mode, email verification is simulated');
        return;
      }
      
      await _ensureFirebaseReady();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null && !user.emailVerified) {
        print('📧 Sending email verification to: ${user.email}');
        await user.sendEmailVerification();
        print('✅ Email verification sent successfully');
      } else if (user?.emailVerified == true) {
        print('ℹ️ Email already verified for: ${user?.email}');
      } else {
        throw Exception('No user found to send verification email');
      }
    } catch (e) {
      print('❌ Failed to send email verification: $e');
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      if (_useMockAuth) {
        print('🎭 Mock user data reloaded');
        return;
      }
      
      await _ensureFirebaseReady();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        await user.reload();
        print('🔄 User data reloaded');
      }
    } catch (e) {
      print('❌ Failed to reload user: $e');
      rethrow;
    }
  }

  bool get isEmailVerified {
    try {
      if (_useMockAuth) {
        return _mockUser?.emailVerified ?? false;
      }
      
      final user = FirebaseAuth.instance.currentUser;
      return user?.emailVerified ?? false;
    } catch (e) {
      print('❌ Failed to check email verification: $e');
      return false;
    }
  }

  // ==========================================
  // USER PROFILE MANAGEMENT
  // ==========================================
  
  // Update user profile methods
  Future<void> updateDisplayName(String displayName) async {
    try {
      if (_useMockAuth) {
        print('🎭 Mock display name updated to: $displayName');
        if (_mockUser != null) {
          // Note: MockUser displayName is final, so we simulate the update
          print('✅ Mock display name update successful');
        }
        return;
      }
      
      await _ensureFirebaseReady();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
        print('✅ Display name updated to: $displayName');
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      print('❌ Failed to update display name: $e');
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      if (_useMockAuth) {
        print('🎭 Mock email update to: $newEmail (verification simulated)');
        print('✅ Mock email update verification sent');
        return;
      }
      
      await _ensureFirebaseReady();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        print('✅ Email update verification sent to: $newEmail');
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      print('❌ Failed to update email: $e');
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'requires-recent-login':
            throw FirebaseAuthException(
              code: e.code,
              message: 'This operation requires recent authentication. Please sign in again and try again.',
            );
          case 'email-already-in-use':
            throw FirebaseAuthException(
              code: e.code,
              message: 'This email address is already in use by another account.',
            );
          case 'invalid-email':
            throw FirebaseAuthException(
              code: e.code,
              message: 'Please enter a valid email address.',
            );
          default:
            rethrow;
        }
      }
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      if (_useMockAuth) {
        print('🎭 Mock password update successful');
        return;
      }
      
      await _ensureFirebaseReady();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        await user.updatePassword(newPassword);
        print('✅ Password updated successfully');
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      print('❌ Failed to update password: $e');
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'requires-recent-login':
            throw FirebaseAuthException(
              code: e.code,
              message: 'This operation requires recent authentication. Please sign in again and try again.',
            );
          case 'weak-password':
            throw FirebaseAuthException(
              code: e.code,
              message: 'Password is too weak. Please use at least 6 characters with a mix of letters and numbers.',
            );
          default:
            rethrow;
        }
      }
      rethrow;
    }
  }

  // ==========================================
  // RE-AUTHENTICATION AND SECURITY
  // ==========================================
  
  // Re-authentication for sensitive operations
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      if (_useMockAuth) {
        print('🎭 Mock re-authentication successful');
        return;
      }
      
      await _ensureFirebaseReady();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        print('✅ User re-authenticated successfully');
      } else {
        throw Exception('No authenticated user found or email missing');
      }
    } catch (e) {
      print('❌ Re-authentication failed: $e');
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            throw FirebaseAuthException(
              code: e.code,
              message: 'Incorrect password. Please check your password and try again.',
            );
          case 'user-not-found':
            throw FirebaseAuthException(
              code: e.code,
              message: 'User account not found. Please sign in again.',
            );
          default:
            rethrow;
        }
      }
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      if (_useMockAuth) {
        print('🎭 Mock account deletion successful');
        _mockUser = null;
        _clearAuthCache();
        return;
      }
      
      await _ensureFirebaseReady();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        await user.delete();
        _clearAuthCache();
        print('✅ User account deleted successfully');
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      print('❌ Failed to delete account: $e');
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'requires-recent-login':
            throw FirebaseAuthException(
              code: e.code,
              message: 'This operation requires recent authentication. Please sign in again and try again.',
            );
          default:
            rethrow;
        }
      }
      rethrow;
    }
  }

  // ==========================================
  // GOOGLE SIGN-IN (Firebase only)
  // ==========================================
  
  // Google Sign-in methods
  Future<User?> signInWithGoogle() async {
    try {
      if (_useMockAuth) {
        print('⚠️ Google Sign-In not available in mock mode');
        print('ℹ️ Please use demo credentials: $_demoEmail / $_demoPassword');
        throw FirebaseAuthException(
          code: 'operation-not-supported',
          message: 'Google Sign-In is not available in demo mode. Please use demo credentials:\nEmail: $_demoEmail\nPassword: $_demoPassword',
        );
      }
      
      await _ensureFirebaseReady();
      
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
      _clearAuthCache();
      return userCredential.user;
    } catch (e) {
      print('❌ Google Sign-In failed: $e');
      _clearAuthCache();
      rethrow;
    }
  }

  Future<void> signOutGoogle() async {
    try {
      if (_useMockAuth) {
        print('🎭 Mock Google sign out');
        return;
      }
      
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      _clearAuthCache();
      print('✅ Google Sign-Out successful');
    } catch (e) {
      print('❌ Google Sign-Out failed: $e');
      _clearAuthCache();
      rethrow;
    }
  }

  // ==========================================
  // SESSION MONITORING AND VALIDATION
  // ==========================================
  
  // Session management
  bool get hasValidSession {
    try {
      if (_useMockAuth) {
        return _mockUser != null && !_mockUser!.isAnonymous;
      }
      
      final user = FirebaseAuth.instance.currentUser;
      return user != null && !user.isAnonymous;
    } catch (e) {
      print('❌ Session validation failed: $e');
      return false;
    }
  }

  Future<bool> isSessionExpired() async {
    try {
      if (_useMockAuth) {
        // Mock sessions don't expire
        return _mockUser == null;
      }
      
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
      if (_useMockAuth) {
        print('🎭 Mock session refresh');
        return;
      }
      
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