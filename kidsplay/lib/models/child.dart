import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class Child {
  final String id;
  final String name;
  final String surname;
  final DateTime birthDate;
  final String gender;
  final List<String> hobbies;
  final bool hasScreenDependency;
  final String screenDependencyLevel;
  final bool usesScreenDuringMeals;
  final bool wantsToChange;
  final String dailyPlayTime;
  final List<String> parentIds;
  final String relationshipToParent;
  final bool hasCameraPermission;

  Child({
    required this.id,
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.gender,
    required this.hobbies,
    required this.hasScreenDependency,
    required this.screenDependencyLevel,
    required this.usesScreenDuringMeals,
    required this.wantsToChange,
    required this.dailyPlayTime,
    required this.parentIds,
    required this.relationshipToParent,
    required this.hasCameraPermission,
  });

  factory Child.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Child(
      id: doc.id,
      name: d['name'] ?? '',
      surname: d['surname'] ?? '',
      birthDate: FirestoreService.toDate(d['birthDate']) ?? DateTime(2019, 1, 1),
      gender: d['gender'] ?? 'unknown',
      hobbies: List<String>.from(d['hobbies'] ?? const []),
      hasScreenDependency: d['hasScreenDependency'] ?? false,
      screenDependencyLevel: d['screenDependencyLevel'] ?? 'low',
      usesScreenDuringMeals: d['usesScreenDuringMeals'] ?? false,
      wantsToChange: d['wantsToChange'] ?? false,
      dailyPlayTime: d['dailyPlayTime'] ?? '',
      parentIds: List<String>.from(d['parentIds'] ?? const []),
      relationshipToParent: d['relationshipToParent'] ?? '',
      hasCameraPermission: d['hasCameraPermission'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender,
      'hobbies': hobbies,
      'hasScreenDependency': hasScreenDependency,
      'screenDependencyLevel': screenDependencyLevel,
      'usesScreenDuringMeals': usesScreenDuringMeals,
      'wantsToChange': wantsToChange,
      'dailyPlayTime': dailyPlayTime,
      'parentIds': parentIds,
      'relationshipToParent': relationshipToParent,
      'hasCameraPermission': hasCameraPermission,
    };
  }
}