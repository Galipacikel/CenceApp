import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_history.dart';
import 'firestore_paths.dart';

class ServiceRecordService {
  final FirebaseFirestore _firestore;

  ServiceRecordService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> archiveAndDelete({
    required String deviceId,
    required String recordId,
  }) async {
    final recordRef = _firestore
        .collection(FirestorePaths.deviceServiceRecords(deviceId))
        .doc(recordId);
    final archiveRef = _firestore
        .collection(FirestorePaths.serviceRecordsArchive)
        .doc(recordId);

    return _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(recordRef);
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>;
      txn.set(archiveRef, data);
      txn.delete(recordRef);
    });
  }

  Future<void> createWithStockDecreaseWithId(
    String recordId,
    ServiceHistory history,
  ) async {
    // Creates a record with provided id; stock decrease should be handled by Cloud Function onCreate
    final recordRef = _firestore
        .collection(FirestorePaths.deviceServiceRecords(history.deviceId))
        .doc(recordId);

    await recordRef.set({
      'device_id': history.deviceId,
      'technician_id': history.technician,
      'service_type': history.status,
      'description': history.description,
      'actions_taken': '',
      'images': history.photos ?? <String>[],
      'used_parts': history.kullanilanParcalar
          .map(
            (p) => {
              'part_id': p.id,
              'part_name': p.parcaAdi,
              'quantity': p.stokAdedi,
            },
          )
          .toList(),
      'created_at': FieldValue.serverTimestamp(),
      'is_synced': true,
    });
  }
}
