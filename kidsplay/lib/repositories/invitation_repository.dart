import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invitation.dart';
import '../services/firestore_service.dart';

class InvitationRepository {
  final _fs = FirestoreService.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _fs.col('users/$uid/invitations');

  Stream<List<Invitation>> watchInvitations(String uid) {
    return _col(uid).orderBy('sentAt', descending: true).snapshots().map(
          (s) => s.docs.map(Invitation.fromDoc).toList(),
        );
  }

  Future<void> invite({
    required String uid,
    required String email,
    required String invitedBy,
    required String childId,
    required String childName,
    required List<String> permissions,
    Duration validity = const Duration(days: 7),
  }) async {
    final now = DateTime.now();
    await _col(uid).add(Invitation(
      id: 'auto',
      email: email,
      invitedBy: invitedBy,
      childId: childId,
      childName: childName,
      permissions: permissions,
      sentAt: now,
      expiresAt: now.add(validity),
      status: 'pending',
    ).toMap());
  }

  Future<void> resend(String uid, String invitationId) async {
    await _col(uid).doc(invitationId).set(
      {
        'sentAt': Timestamp.fromDate(DateTime.now()),
        'status': 'pending',
      },
      SetOptions(merge: true),
    );
  }

  Future<void> cancel(String uid, String invitationId) async {
    await _col(uid).doc(invitationId).set(
      {'status': 'cancelled'},
      SetOptions(merge: true),
    );
  }
}