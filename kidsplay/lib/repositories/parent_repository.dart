import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parent.dart';
import '../services/firestore_service.dart';

class ParentRepository {
  final _fs = FirestoreService.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _fs.col('users/$uid/parents');

  Stream<List<Parent>> watchParents(String uid) {
    return _col(uid).snapshots().map(
          (s) => s.docs
              .map((d) => Parent.fromMap(d.id, d.data()))
              .toList()
              ..sort((a, b) => a.name.compareTo(b.name)),
        );
  }

  Future<void> removeParent(String uid, String parentId) async {
    await _col(uid).doc(parentId).delete();
  }

  Future<void> addOrUpdateParent(String uid, Parent parent) async {
    await _col(uid).doc(parent.id).set(parent.toMap(), SetOptions(merge: true));
  }
}