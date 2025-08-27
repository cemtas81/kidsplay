import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class Invitation {
  final String id;
  final String email;
  final String invitedBy;
  final String childId;
  final String childName;
  final List<String> permissions;
  final DateTime sentAt;
  final DateTime expiresAt;
  final String status; // pending, cancelled, accepted, expired

  Invitation({
    required this.id,
    required this.email,
    required this.invitedBy,
    required this.childId,
    required this.childName,
    required this.permissions,
    required this.sentAt,
    required this.expiresAt,
    required this.status,
  });

  factory Invitation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Invitation(
      id: doc.id,
      email: d['email'] ?? '',
      invitedBy: d['invitedBy'] ?? '',
      childId: d['childId'] ?? '',
      childName: d['childName'] ?? '',
      permissions: List<String>.from(d['permissions'] ?? const []),
      sentAt: FirestoreService.toDate(d['sentAt']) ?? DateTime.now(),
      expiresAt: FirestoreService.toDate(d['expiresAt']) ?? DateTime.now().add(const Duration(days: 7)),
      status: d['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'invitedBy': invitedBy,
        'childId': childId,
        'childName': childName,
        'permissions': permissions,
        'sentAt': Timestamp.fromDate(sentAt),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'status': status,
      };
}