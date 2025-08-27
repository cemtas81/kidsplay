import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _childrenCollection = 'children';

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create or update user profile
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phoneNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userData = {
        'uid': userId,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'hasChildren': false,
        'isActive': true,
        ...?additionalData,
      };

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(data);
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
      final childData = {
        'parentId': parentId,
        'name': name,
        'age': age,
        'gender': gender,
        'hobbies': hobbies ?? [],
        'profileImageUrl': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'todayActivities': 0,
        'dailyGoal': 5,
        'currentStreak': 0,
        'badges': [],
        'screenTime': '0 minutes',
        'lastActivity': null,
        ...?additionalData,
      };

      final docRef = await _firestore
          .collection(_childrenCollection)
          .add(childData);

      // Update parent's hasChildren flag
      await updateUserProfile(parentId, {'hasChildren': true});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create child profile: ${e.toString()}');
    }
  }

  // Get children for a parent
  Future<List<Map<String, dynamic>>> getChildrenForParent(String parentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_childrenCollection)
          .where('parentId', isEqualTo: parentId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get children: ${e.toString()}');
    }
  }

  // Update child profile
  Future<void> updateChildProfile(String childId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(_childrenCollection)
          .doc(childId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update child profile: ${e.toString()}');
    }
  }

  // Delete child profile (soft delete)
  Future<void> deleteChildProfile(String childId) async {
    try {
      await _firestore
          .collection(_childrenCollection)
          .doc(childId)
          .update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete child profile: ${e.toString()}');
    }
  }

  // Stream of children for real-time updates
  Stream<List<Map<String, dynamic>>> streamChildrenForParent(String parentId) {
    return _firestore
        .collection(_childrenCollection)
        .where('parentId', isEqualTo: parentId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
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