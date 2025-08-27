import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

// Mock Firebase implementation for demo purposes
class MockFirebaseAuth {
  static MockFirebaseAuth? _instance;
  static MockFirebaseAuth get instance => _instance ??= MockFirebaseAuth._();
  MockFirebaseAuth._();

  MockUser? _currentUser;
  final _authStateController = ValueNotifier<MockUser?>(null);

  MockUser? get currentUser => _currentUser;
  ValueListenable<MockUser?> get authStateChanges => _authStateController;

  Future<MockUserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('mock_users') ?? [];
    
    // Check if user already exists
    for (String userJson in users) {
      final userData = json.decode(userJson);
      if (userData['email'] == email) {
        throw Exception('An account already exists for this email.');
      }
    }
    
    final user = MockUser(
      uid: 'mock_${Random().nextInt(100000)}',
      email: email,
      displayName: null,
    );
    
    // Save user to local storage
    users.add(json.encode({
      'uid': user.uid,
      'email': email,
      'password': password,
      'displayName': user.displayName,
    }));
    await prefs.setStringList('mock_users', users);
    
    _currentUser = user;
    _authStateController.value = user;
    
    return MockUserCredential(user: user);
  }

  Future<MockUserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('mock_users') ?? [];
    
    for (String userJson in users) {
      final userData = json.decode(userJson);
      if (userData['email'] == email && userData['password'] == password) {
        final user = MockUser(
          uid: userData['uid'],
          email: userData['email'],
          displayName: userData['displayName'],
        );
        
        _currentUser = user;
        _authStateController.value = user;
        
        return MockUserCredential(user: user);
      }
    }
    
    throw Exception('Invalid email or password.');
  }

  Future<MockUserCredential> signInWithCredential(dynamic credential) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final user = MockUser(
      uid: 'google_${Random().nextInt(100000)}',
      email: 'google.user@example.com',
      displayName: 'Google User',
    );
    
    _currentUser = user;
    _authStateController.value = user;
    
    return MockUserCredential(user: user);
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _authStateController.value = null;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock success - in real app this would send an email
  }
}

class MockUser {
  final String uid;
  final String? email;
  String? displayName;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
  });

  Future<void> updateDisplayName(String? name) async {
    displayName = name;
  }

  Future<void> delete() async {
    // Mock deletion
  }
}

class MockUserCredential {
  final MockUser? user;
  
  MockUserCredential({this.user});
}

class MockFirestore {
  static MockFirestore? _instance;
  static MockFirestore get instance => _instance ??= MockFirestore._();
  MockFirestore._();

  MockCollectionReference collection(String path) {
    return MockCollectionReference(path);
  }
}

class MockCollectionReference {
  final String path;
  
  MockCollectionReference(this.path);

  MockDocumentReference doc([String? documentId]) {
    final id = documentId ?? 'mock_${Random().nextInt(100000)}';
    return MockDocumentReference('$path/$id');
  }

  Future<MockQuerySnapshot> get() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('mock_$path') ?? [];
    
    final docs = data.map((item) {
      final docData = json.decode(item);
      return MockQueryDocumentSnapshot(docData['id'], docData['data']);
    }).toList();
    
    return MockQuerySnapshot(docs);
  }

  MockQuery where(String field, {dynamic isEqualTo, dynamic arrayContains}) {
    return MockQuery(path, field, isEqualTo);
  }

  MockQuery orderBy(String field, {bool descending = false}) {
    return MockQuery(path, field, null);
  }

  Future<MockDocumentReference> add(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final docId = 'mock_${Random().nextInt(100000)}';
    
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('mock_$path') ?? [];
    
    items.add(json.encode({
      'id': docId,
      'data': data,
    }));
    
    await prefs.setStringList('mock_$path', items);
    
    return MockDocumentReference('$path/$docId');
  }
}

class MockQuery {
  final String path;
  final String? field;
  final dynamic value;
  
  MockQuery(this.path, this.field, this.value);

  MockQuery where(String field, {dynamic isEqualTo}) {
    return MockQuery(path, field, isEqualTo);
  }

  MockQuery orderBy(String field, {bool descending = false}) {
    return MockQuery(path, field, value);
  }

  Future<MockQuerySnapshot> get() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('mock_$path') ?? [];
    
    final docs = data.where((item) {
      if (field == null) return true;
      final docData = json.decode(item);
      return docData['data'][field] == value;
    }).map((item) {
      final docData = json.decode(item);
      return MockQueryDocumentSnapshot(docData['id'], docData['data']);
    }).toList();
    
    return MockQuerySnapshot(docs);
  }

  Stream<MockQuerySnapshot> snapshots() {
    return Stream.periodic(const Duration(seconds: 1), (i) {
      return get();
    }).asyncMap((future) => future);
  }
}

class MockDocumentReference {
  final String path;
  
  MockDocumentReference(this.path);

  Future<void> set(Map<String, dynamic> data, [dynamic options]) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock set operation
  }

  Future<void> update(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock update operation
  }

  Future<MockDocumentSnapshot> get() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDocumentSnapshot({}, true);
  }
}

class MockDocumentSnapshot {
  final Map<String, dynamic> _data;
  final bool _exists;
  
  MockDocumentSnapshot(this._data, this._exists);

  bool get exists => _exists;
  
  Map<String, dynamic>? data() => _exists ? _data : null;
}

class MockQuerySnapshot {
  final List<MockQueryDocumentSnapshot> docs;
  
  MockQuerySnapshot(this.docs);
}

class MockQueryDocumentSnapshot {
  final String id;
  final Map<String, dynamic> _data;
  
  MockQueryDocumentSnapshot(this.id, this._data);

  Map<String, dynamic> data() => _data;
}