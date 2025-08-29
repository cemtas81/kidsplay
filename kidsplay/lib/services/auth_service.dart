import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

class AuthService {
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _initialized = true;
    }
  }

  static Future<User> ensureInitializedAndSignedIn() async {
    await _ensureInitialized();
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

  // Email/Password Authentication methods
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    await _ensureInitialized();
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    await _ensureInitialized();
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
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
    await _ensureInitialized();
    return FirebaseAuth.instance.currentUser;
  }

  // Stream of authentication state changes
  Stream<User?> get authStateChanges {
    return FirebaseAuth.instance.authStateChanges();
  }
}