import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child.dart';
import '../services/firestore_service.dart';

class ChildRepository {
  final _fs = FirestoreService.instance;

  // children stored per user to keep it simple
  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _fs.col('users/$uid/children');

  Stream<List<Child>> watchChildrenOf(String uid) {
    return _col(uid).snapshots().map((s) => s.docs.map(Child.fromDoc).toList());
  }

  Future<void> saveChild(String uid, Child child) async {
    await _col(uid).doc(child.id).set(child.toMap(), SetOptions(merge: true));
  }

  Future<void> removeSharingKeepOwner({required String ownerUid, required String childId}) async {
    // For simplicity: set parentIds to only [ownerUid]
    await _col(ownerUid).doc(childId).set({'parentIds': [ownerUid]}, SetOptions(merge: true));
  }
}