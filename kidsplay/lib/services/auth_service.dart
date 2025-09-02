import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';

// TODO: TEMPORARY MOCK USER CLASS - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
// This mock user implementation is used when Firebase auth is unavailable
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
  // Firebase is already initialized in main.dart, no need to initialize again
  
  // TODO: TEMPORARY MOCK AUTHENTICATION - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
  // This is a temporary workaround while the authentication service is unavailable
  static const bool _useMockAuth = true; // Set to false when real auth is restored
  static const String _mockUserId = 'mock-user-12345';
  static User? _mockUser; // Store mock user for session persistence
  
  // Cache for authentication state to reduce Firebase calls
  static DateTime? _lastAuthCheck;
  static bool? _lastAuthResult;
  
  static Future<void> _ensureFirebaseReady() async {
    // Skip Firebase initialization check in mock mode
    if (_useMockAuth) {
      print('🎭 Mock authentication mode enabled - bypassing Firebase');
      return;
    }
    
    // Just verify Firebase is ready, don't initialize again
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase not initialized. Please ensure Firebase.initializeApp() is called in main.dart');
    }
    print('✅ Firebase is ready for authentication');
  }

  static Future<User> ensureInitializedAndSignedIn() async {
    if (_useMockAuth && _mockUser != null) {
      return _mockUser!;
    }
    
    await _ensureFirebaseReady();
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      throw Exception('No authenticated user found. Please login first.');
    }
    return auth.currentUser!;
  }

  static Future<String> getUid() async {
    if (_useMockAuth && _mockUser != null) {
      return _mockUser!.uid;
    }
    
    final user = await ensureInitializedAndSignedIn();
    return user.uid;
  }

  // TODO: TEMPORARY MOCK CREDENTIALS - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
  // Demo credentials for testing during auth service downtime
  static const String _demoEmail = 'demo@demo.com';
  static const String _demoPassword = 'demo1234';
  
  // Check if using demo credentials
  bool _isDemoCredentials(String email, String password) {
    return email.toLowerCase() == _demoEmail && password == _demoPassword;
  }

  // Email/Password Authentication methods
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    // TODO: TEMPORARY MOCK AUTHENTICATION - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
    if (_useMockAuth) {
      print('🎭 Mock authentication mode - checking credentials');
      
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
        
        return _mockUser;
      } else {
        print('❌ Mock login failed - invalid credentials provided');
        print('ℹ️ Only demo credentials are accepted: $_demoEmail / $_demoPassword');
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Authentication service is currently unavailable. Please use demo credentials: $_demoEmail / $_demoPassword',
        );
      }
    }
    
    // Original Firebase authentication logic (when mock mode is disabled)
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
    // TODO: TEMPORARY MOCK AUTHENTICATION - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
    if (_useMockAuth) {
      print('🎭 Mock registration mode - checking credentials');
      
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
        
        return _mockUser;
      } else {
        print('❌ Mock registration failed - invalid credentials provided');
        print('ℹ️ Only demo credentials are accepted: $_demoEmail / $_demoPassword');
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Registration service is currently unavailable. Please use demo credentials: $_demoEmail / $_demoPassword',
        );
      }
    }
    
    // Original Firebase authentication logic (when mock mode is disabled)
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
    // TODO: TEMPORARY MOCK AUTH HANDLING - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
    if (_useMockAuth) {
      print('🎭 Mock sign out');
      _mockUser = null;
      // Clear auth cache
      _lastAuthCheck = null;
      _lastAuthResult = null;
      return;
    }
    
    await FirebaseAuth.instance.signOut();
    // Clear auth cache
    _lastAuthCheck = null;
    _lastAuthResult = null;
  }

  User? getCurrentUser() {
    // TODO: TEMPORARY MOCK AUTH HANDLING - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
    if (_useMockAuth) {
      return _mockUser;
    }
    
    return FirebaseAuth.instance.currentUser;
  }

  // Check if user is authenticated (not anonymous)
  bool isAuthenticated() {
    // Use cached result if available and recent (within 30 seconds)
    if (_lastAuthCheck != null && 
        _lastAuthResult != null && 
        DateTime.now().difference(_lastAuthCheck!).inSeconds < 30) {
      return _lastAuthResult!;
    }
    
    // TODO: TEMPORARY MOCK AUTH HANDLING - REMOVE WHEN REAL AUTH SERVICE IS RESTORED
    bool result;
    if (_useMockAuth) {
      result = _mockUser != null && !_mockUser!.isAnonymous;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      result = user != null && !user.isAnonymous;
    }
    
    // Cache the result
    _lastAuthCheck = DateTime.now();
    _lastAuthResult = result;
    
    return result;
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