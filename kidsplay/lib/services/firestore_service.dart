import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();
  
  FirebaseFirestore get _db {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase not initialized. Please ensure Firebase.initializeApp() is called in main.dart');
    }
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>> col(String path) {
    print('🗄️ Accessing Firestore collection: $path');
    return _db.collection(path);
  }
  
  DocumentReference<Map<String, dynamic>> doc(String path) {
    print('📄 Accessing Firestore document: $path');
    return _db.doc(path);
  }

  static DateTime? toDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }

  static Timestamp fromDate(DateTime d) => Timestamp.fromDate(d);
}