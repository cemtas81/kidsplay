import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  static const String _demoPassword = 'parent123';
  
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
}