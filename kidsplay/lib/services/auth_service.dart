import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'mock_firebase.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;
  MockFirebaseAuth? _mockAuth;
  bool _useFirebase = true;

  // Initialize Firebase or fallback to mock
  void _initializeAuth() {
    try {
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
    } catch (e) {
      debugPrint('Firebase not available, using mock auth: $e');
      _useFirebase = false;
      _mockAuth = MockFirebaseAuth.instance;
    }
  }

  // Get current user
  User? get currentUser {
    _initializeAuth();
    if (_useFirebase) {
      return _auth?.currentUser;
    } else {
      final mockUser = _mockAuth?.currentUser;
      return mockUser != null ? _mockUserToFirebaseUser(mockUser) : null;
    }
  }
  
  // Stream of auth state changes
  Stream<User?> get authStateChanges {
    _initializeAuth();
    if (_useFirebase) {
      return _auth?.authStateChanges() ?? Stream.empty();
    } else {
      return _mockAuth!.authStateChanges.map((mockUser) {
        return mockUser != null ? _mockUserToFirebaseUser(mockUser) : null;
      });
    }
  }

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Convert MockUser to User-like object
  User? _mockUserToFirebaseUser(MockUser mockUser) {
    return MockFirebaseUser(
      uid: mockUser.uid,
      email: mockUser.email,
      displayName: mockUser.displayName,
    );
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _initializeAuth();
      
      if (_useFirebase) {
        final UserCredential userCredential = await _auth!.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Update display name
        await userCredential.user?.updateDisplayName(fullName);
        
        return userCredential;
      } else {
        final mockCredential = await _mockAuth!.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        await mockCredential.user?.updateDisplayName(fullName);
        
        return MockFirebaseUserCredential(
          user: _mockUserToFirebaseUser(mockCredential.user!),
        );
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _initializeAuth();
      
      if (_useFirebase) {
        final UserCredential userCredential = await _auth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return userCredential;
      } else {
        final mockCredential = await _mockAuth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        return MockFirebaseUserCredential(
          user: _mockUserToFirebaseUser(mockCredential.user!),
        );
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _initializeAuth();
      
      if (_useFirebase) {
        // Trigger the Google authentication flow
        final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
        
        if (googleUser == null) {
          throw Exception('Google sign-in was cancelled');
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        return await _auth!.signInWithCredential(credential);
      } else {
        // Mock Google sign-in
        final mockCredential = await _mockAuth!.signInWithCredential('mock_google_credential');
        
        return MockFirebaseUserCredential(
          user: _mockUserToFirebaseUser(mockCredential.user!),
        );
      }
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _initializeAuth();
      
      if (_useFirebase) {
        await Future.wait([
          _auth!.signOut(),
          _googleSignIn?.signOut() ?? Future.value(),
        ]);
      } else {
        await _mockAuth!.signOut();
      }
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      _initializeAuth();
      
      if (_useFirebase) {
        await _auth!.sendPasswordResetEmail(email: email);
      } else {
        await _mockAuth!.sendPasswordResetEmail(email: email);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

// Mock implementations for fallback
class MockFirebaseUser implements User {
  @override
  final String uid;
  
  @override
  final String? email;
  
  @override
  String? displayName;

  MockFirebaseUser({
    required this.uid,
    this.email,
    this.displayName,
  });

  @override
  Future<void> updateDisplayName(String? name) async {
    displayName = name;
  }

  @override
  Future<void> delete() async {
    // Mock deletion
  }

  // Implement other User interface methods as needed
  @override
  bool get emailVerified => true;
  
  @override
  bool get isAnonymous => false;
  
  @override
  UserMetadata get metadata => MockUserMetadata();
  
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
  Future<void> reload() async {}
  
  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'mock_token';
  
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> linkWithCredential(AuthCredential credential) async {}
  
  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) async {
    throw UnimplementedError();
  }
  
  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async {
    throw UnimplementedError();
  }
  
  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async {
    throw UnimplementedError();
  }
  
  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}
  
  @override
  Future<User> unlink(String providerId) async => this;
  
  @override
  Future<void> updateEmail(String newEmail) async {}
  
  @override
  Future<void> updatePassword(String newPassword) async {}
  
  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {}
  
  @override
  Future<void> updatePhotoURL(String? photoURL) async {}
  
  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    this.displayName = displayName;
  }
  
  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {}
}

class MockUserMetadata implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
  
  @override
  DateTime? get lastSignInTime => DateTime.now();
}

class MockFirebaseUserCredential implements UserCredential {
  @override
  final User? user;
  
  MockFirebaseUserCredential({this.user});
  
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
  
  @override
  AuthCredential? get credential => null;
}