import 'dart:async';
import '../models/child.dart';

/// Mock storage service for demo/offline mode
/// Provides in-memory storage that persists during app session
class MockStorageService {
  MockStorageService._();
  static final instance = MockStorageService._();
  
  // In-memory storage for children data
  // Key: userId, Value: Map of childId -> Child
  final Map<String, Map<String, Child>> _childrenStorage = {};
  
  // Stream controllers for real-time updates like Firestore
  final Map<String, StreamController<List<Child>>> _childrenStreamControllers = {};
  
  /// Get children for a specific user
  List<Child> getChildrenOf(String uid) {
    final userChildren = _childrenStorage[uid] ?? {};
    return userChildren.values.toList();
  }
  
  /// Watch children of a user (returns a stream like Firestore)
  Stream<List<Child>> watchChildrenOf(String uid) {
    // Create stream controller if it doesn't exist
    if (!_childrenStreamControllers.containsKey(uid)) {
      _childrenStreamControllers[uid] = StreamController<List<Child>>.broadcast();
      // Send initial data
      _childrenStreamControllers[uid]!.add(getChildrenOf(uid));
    }
    return _childrenStreamControllers[uid]!.stream;
  }
  
  /// Save a child to mock storage
  Future<void> saveChild(String uid, Child child) async {
    // Simulate async operation like Firestore
    await Future.delayed(Duration(milliseconds: 50));
    
    // Initialize user storage if needed
    if (!_childrenStorage.containsKey(uid)) {
      _childrenStorage[uid] = {};
    }
    
    // Save the child
    _childrenStorage[uid]![child.id] = child;
    
    // Notify listeners
    if (_childrenStreamControllers.containsKey(uid)) {
      _childrenStreamControllers[uid]!.add(getChildrenOf(uid));
    }
    
    print('📱 Mock Storage: Saved child "${child.name}" for user $uid');
  }
  
  /// Delete a child from mock storage
  Future<void> deleteChild(String uid, String childId) async {
    // Simulate async operation like Firestore
    await Future.delayed(Duration(milliseconds: 50));
    
    if (_childrenStorage.containsKey(uid)) {
      final removedChild = _childrenStorage[uid]!.remove(childId);
      
      // Notify listeners
      if (_childrenStreamControllers.containsKey(uid)) {
        _childrenStreamControllers[uid]!.add(getChildrenOf(uid));
      }
      
      if (removedChild != null) {
        print('📱 Mock Storage: Deleted child "${removedChild.name}" for user $uid');
      }
    }
  }
  
  /// Update sharing settings for a child
  Future<void> removeSharingKeepOwner({required String ownerUid, required String childId}) async {
    // Simulate async operation like Firestore
    await Future.delayed(Duration(milliseconds: 50));
    
    if (_childrenStorage.containsKey(ownerUid) && 
        _childrenStorage[ownerUid]!.containsKey(childId)) {
      final child = _childrenStorage[ownerUid]![childId]!;
      
      // Create updated child with only owner in parentIds
      final updatedChild = Child(
        id: child.id,
        name: child.name,
        surname: child.surname,
        birthDate: child.birthDate,
        gender: child.gender,
        hobbies: child.hobbies,
        hasScreenDependency: child.hasScreenDependency,
        screenDependencyLevel: child.screenDependencyLevel,
        usesScreenDuringMeals: child.usesScreenDuringMeals,
        wantsToChange: child.wantsToChange,
        dailyPlayTime: child.dailyPlayTime,
        parentIds: [ownerUid], // Keep only owner
        relationshipToParent: child.relationshipToParent,
        hasCameraPermission: child.hasCameraPermission,
      );
      
      _childrenStorage[ownerUid]![childId] = updatedChild;
      
      // Notify listeners
      if (_childrenStreamControllers.containsKey(ownerUid)) {
        _childrenStreamControllers[ownerUid]!.add(getChildrenOf(ownerUid));
      }
      
      print('📱 Mock Storage: Updated sharing for child "${child.name}"');
    }
  }
  
  /// Clear all data (useful for testing)
  void clearAll() {
    _childrenStorage.clear();
    for (final controller in _childrenStreamControllers.values) {
      controller.close();
    }
    _childrenStreamControllers.clear();
    print('📱 Mock Storage: Cleared all data');
  }
  
  /// Get storage stats for debugging
  Map<String, dynamic> getStats() {
    final totalUsers = _childrenStorage.keys.length;
    final totalChildren = _childrenStorage.values
        .map((userChildren) => userChildren.length)
        .fold(0, (sum, count) => sum + count);
    
    return {
      'totalUsers': totalUsers,
      'totalChildren': totalChildren,
      'users': _childrenStorage.keys.toList(),
    };
  }
}