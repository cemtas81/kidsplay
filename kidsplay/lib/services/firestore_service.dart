import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> col(String path) => _db.collection(path);
  DocumentReference<Map<String, dynamic>> doc(String path) => _db.doc(path);

  static DateTime? toDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }

  static Timestamp fromDate(DateTime d) => Timestamp.fromDate(d);
}