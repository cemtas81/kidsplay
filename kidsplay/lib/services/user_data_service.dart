import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mock_firebase.dart';

class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  FirebaseFirestore? _firestore;
  MockFirestore? _mockFirestore;
  final FirebaseAuth? _auth = null;
  bool _useFirebase = true;

  // Initialize Firestore or fallback to mock
  void _initializeFirestore() {
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore not available, using mock: $e');
      _useFirebase = false;
      _mockFirestore = MockFirestore.instance;
    }
  }

  // Collections
  static const String _usersCollection = 'users';
  static const String _childrenCollection = 'children';

  // Get current user ID (mock implementation)
  String? get currentUserId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (e) {
      // Return mock user ID if Firebase not available
      return 'mock_current_user';
    }
  }

  // Create or update user profile
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phoneNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _initializeFirestore();
      
      final userData = {
        'uid': userId,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'hasChildren': false,
        'isActive': true,
        ...?additionalData,
      };

      if (_useFirebase) {
        await _firestore!
            .collection(_usersCollection)
            .doc(userId)
            .set(userData);
      } else {
        await _mockFirestore!
            .collection(_usersCollection)
            .doc(userId)
            .set(userData);
      }
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      _initializeFirestore();
      
      if (_useFirebase) {
        final doc = await _firestore!
            .collection(_usersCollection)
            .doc(userId)
            .get();
        
        return doc.exists ? doc.data() : null;
      } else {
        final doc = await _mockFirestore!
            .collection(_usersCollection)
            .doc(userId)
            .get();
        
        return doc.exists ? doc.data() : null;
      }
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      _initializeFirestore();
      
      data['updatedAt'] = DateTime.now().toIso8601String();
      
      if (_useFirebase) {
        await _firestore!
            .collection(_usersCollection)
            .doc(userId)
            .update(data);
      } else {
        await _mockFirestore!
            .collection(_usersCollection)
            .doc(userId)
            .update(data);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Create child profile
  Future<String> createChildProfile({
    required String parentId,
    required String name,
    required int age,
    required String gender,
    List<String>? hobbies,
    String? profileImageUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _initializeFirestore();
      
      final childData = {
        'parentId': parentId,
        'name': name,
        'age': age,
        'gender': gender,
        'hobbies': hobbies ?? [],
        'profileImageUrl': profileImageUrl,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isActive': true,
        'todayActivities': 0,
        'dailyGoal': 5,
        'currentStreak': 0,
        'badges': [],
        'screenTime': '0 minutes',
        'lastActivity': null,
        ...?additionalData,
      };

      String docId;
      if (_useFirebase) {
        final docRef = await _firestore!
            .collection(_childrenCollection)
            .add(childData);
        docId = docRef.id;
      } else {
        final docRef = await _mockFirestore!
            .collection(_childrenCollection)
            .add(childData);
        docId = 'mock_child_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Update parent's hasChildren flag
      await updateUserProfile(parentId, {'hasChildren': true});

      return docId;
    } catch (e) {
      throw Exception('Failed to create child profile: ${e.toString()}');
    }
  }

  // Get children for a parent
  Future<List<Map<String, dynamic>>> getChildrenForParent(String parentId) async {
    try {
      _initializeFirestore();
      
      if (_useFirebase) {
        final querySnapshot = await _firestore!
            .collection(_childrenCollection)
            .where('parentId', isEqualTo: parentId)
            .where('isActive', isEqualTo: true)
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      } else {
        final querySnapshot = await _mockFirestore!
            .collection(_childrenCollection)
            .where('parentId', isEqualTo: parentId)
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }
    } catch (e) {
      throw Exception('Failed to get children: ${e.toString()}');
    }
  }

  // Update child profile
  Future<void> updateChildProfile(String childId, Map<String, dynamic> data) async {
    try {
      _initializeFirestore();
      
      data['updatedAt'] = DateTime.now().toIso8601String();
      
      if (_useFirebase) {
        await _firestore!
            .collection(_childrenCollection)
            .doc(childId)
            .update(data);
      } else {
        await _mockFirestore!
            .collection(_childrenCollection)
            .doc(childId)
            .update(data);
      }
    } catch (e) {
      throw Exception('Failed to update child profile: ${e.toString()}');
    }
  }

  // Delete child profile (soft delete)
  Future<void> deleteChildProfile(String childId) async {
    try {
      _initializeFirestore();
      
      final deleteData = {
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      if (_useFirebase) {
        await _firestore!
            .collection(_childrenCollection)
            .doc(childId)
            .update(deleteData);
      } else {
        await _mockFirestore!
            .collection(_childrenCollection)
            .doc(childId)
            .update(deleteData);
      }
    } catch (e) {
      throw Exception('Failed to delete child profile: ${e.toString()}');
    }
  }

  // Stream of children for real-time updates
  Stream<List<Map<String, dynamic>>> streamChildrenForParent(String parentId) {
    _initializeFirestore();
    
    if (_useFirebase) {
      return _firestore!
          .collection(_childrenCollection)
          .where('parentId', isEqualTo: parentId)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } else {
      return _mockFirestore!
          .collection(_childrenCollection)
          .where('parentId', isEqualTo: parentId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    }
  }

  // Check if user has children
  Future<bool> userHasChildren(String userId) async {
    try {
      final children = await getChildrenForParent(userId);
      return children.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}