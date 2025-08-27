import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_plan.dart';
import '../services/firestore_service.dart';

class SubscriptionRepository {
  final _fs = FirestoreService.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _fs.doc('users/$uid/subscription');

  Stream<SubscriptionPlan?> watchCurrentPlan(String uid) {
    return _doc(uid).snapshots().map((d) {
      if (!d.exists) return null;
      final data = d.data()!;
      final planId = data['planId'] as String? ?? 'free';
      return SubscriptionPlan.byId(planId);
    });
  }

  Future<void> setPlan(String uid, String planId, {String? voucherCode}) async {
    await _doc(uid).set(
      {
        'planId': planId,
        if (voucherCode != null) 'voucherCode': voucherCode,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'status': 'active',
      },
      SetOptions(merge: true),
    );
  }

  Future<void> cancel(String uid) async {
    await _doc(uid).set(
      {
        'status': 'cancelled',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(merge: true),
    );
  }

  // Dummy voucher validation: looks up a code doc in "vouchers"
  Future<bool> validateVoucher(String code) async {
    final snap = await _fs.doc('vouchers/$code').get();
    if (!snap.exists) return false;
    final data = snap.data()!;
    final validUntil = data['validUntil'] as Timestamp?;
    if (validUntil == null) return true;
    return validUntil.toDate().isAfter(DateTime.now());
  }
}