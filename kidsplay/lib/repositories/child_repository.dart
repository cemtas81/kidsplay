import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child.dart';
import '../services/firestore_service.dart';
import '../services/mock_storage_service.dart';
import '../services/auth_service.dart';

class ChildRepository {
  final _fs = FirestoreService.instance;
  final _mockStorage = MockStorageService.instance;

  // children stored per user to keep it simple
  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _fs.col('users/$uid/children');

  /// Watch children for a user - works in both mock and real modes
  Stream<List<Child>> watchChildrenOf(String uid) {
    try {
      // Check if we're using mock authentication
      if (AuthService.isUsingMockAuth) {
        print('📱 Using mock storage for watching children of user: $uid');
        return _mockStorage.watchChildrenOf(uid);
      } else {
        print('🔥 Using Firestore for watching children of user: $uid');
        return _col(uid).snapshots().map((s) => s.docs.map(Child.fromDoc).toList());
      }
    } catch (error) {
      print('❌ Error in watchChildrenOf: $error');
      // Fallback to mock storage if Firestore fails
      print('🔄 Falling back to mock storage due to error');
      return _mockStorage.watchChildrenOf(uid);
    }
  }

  /// Save a child - works in both mock and real modes
  Future<void> saveChild(String uid, Child child) async {
    try {
      // Check if we're using mock authentication
      if (AuthService.isUsingMockAuth) {
        print('📱 Using mock storage for saving child: ${child.name}');
        await _mockStorage.saveChild(uid, child);
        return;
      } else {
        print('🔥 Using Firestore for saving child: ${child.name}');
        await _col(uid).doc(child.id).set(child.toMap(), SetOptions(merge: true));
        return;
      }
    } catch (error) {
      print('❌ Error saving child to primary storage: $error');
      
      // If we're in real mode but Firestore fails, try mock storage as fallback
      if (!AuthService.isUsingMockAuth) {
        print('🔄 Firestore failed, falling back to mock storage');
        try {
          await _mockStorage.saveChild(uid, child);
          print('✅ Successfully saved child to mock storage as fallback');
          return;
        } catch (mockError) {
          print('❌ Mock storage fallback also failed: $mockError');
        }
      }
      
      // Re-throw the original error with additional context
      throw Exception('Failed to save child "${child.name}": $error');
    }
  }

  /// Remove sharing but keep owner - works in both mock and real modes
  Future<void> removeSharingKeepOwner({required String ownerUid, required String childId}) async {
    try {
      if (AuthService.isUsingMockAuth) {
        print('📱 Using mock storage for removing sharing of child: $childId');
        await _mockStorage.removeSharingKeepOwner(ownerUid: ownerUid, childId: childId);
      } else {
        print('🔥 Using Firestore for removing sharing of child: $childId');
        await _col(ownerUid).doc(childId).set({'parentIds': [ownerUid]}, SetOptions(merge: true));
      }
    } catch (error) {
      print('❌ Error removing sharing for child: $error');
      
      // Fallback to mock storage if in real mode and Firestore fails
      if (!AuthService.isUsingMockAuth) {
        print('🔄 Firestore failed, falling back to mock storage');
        try {
          await _mockStorage.removeSharingKeepOwner(ownerUid: ownerUid, childId: childId);
          print('✅ Successfully updated sharing in mock storage as fallback');
          return;
        } catch (mockError) {
          print('❌ Mock storage fallback also failed: $mockError');
        }
      }
      
      throw Exception('Failed to update sharing for child: $error');
    }
  }

  /// Delete a child - works in both mock and real modes
  Future<void> deleteChild(String uid, String childId) async {
    try {
      if (AuthService.isUsingMockAuth) {
        print('📱 Using mock storage for deleting child: $childId');
        await _mockStorage.deleteChild(uid, childId);
      } else {
        print('🔥 Using Firestore for deleting child: $childId');
        await _col(uid).doc(childId).delete();
      }
    } catch (error) {
      print('❌ Error deleting child: $error');
      
      // Fallback to mock storage if in real mode and Firestore fails
      if (!AuthService.isUsingMockAuth) {
        print('🔄 Firestore failed, falling back to mock storage');
        try {
          await _mockStorage.deleteChild(uid, childId);
          print('✅ Successfully deleted child from mock storage as fallback');
          return;
        } catch (mockError) {
          print('❌ Mock storage fallback also failed: $mockError');
        }
      }
      
      throw Exception('Failed to delete child: $error');
    }
  }

  /// Get mock storage stats for debugging (only works in mock mode)
  Map<String, dynamic>? getMockStorageStats() {
    if (AuthService.isUsingMockAuth) {
      return _mockStorage.getStats();
    }
    return null;
  }

  /// Clear mock storage (only works in mock mode, useful for testing)
  void clearMockStorage() {
    if (AuthService.isUsingMockAuth) {
      _mockStorage.clearAll();
    }
  }
}