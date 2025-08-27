import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';

class AuthProvider extends ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;
  AuthProvider._internal() {
    _initializeAuthListener();
  }

  final AuthService _authService = AuthService();
  final UserDataService _userDataService = UserDataService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;
  bool _hasChildren = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get hasChildren => _hasChildren;

  void _initializeAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      _errorMessage = null;

      if (user != null) {
        // Load user profile data
        await _loadUserProfile();
      } else {
        _userProfile = null;
        _hasChildren = false;
      }

      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;

    try {
      _userProfile = await _userDataService.getUserProfile(_user!.uid);
      _hasChildren = await _userDataService.userHasChildren(_user!.uid);
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (userCredential?.user != null) {
        // Create user profile in Firestore
        await _userDataService.createUserProfile(
          userId: userCredential!.user!.uid,
          email: email,
          fullName: fullName,
        );
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential?.user != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential?.user != null) {
        // Check if user profile exists, if not create one
        final existingProfile = await _userDataService.getUserProfile(userCredential!.user!.uid);
        
        if (existingProfile == null) {
          await _userDataService.createUserProfile(
            userId: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            fullName: userCredential.user!.displayName ?? 'User',
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update hasChildren status
  Future<void> updateHasChildren(bool hasChildren) async {
    _hasChildren = hasChildren;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}