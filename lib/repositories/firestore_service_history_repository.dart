import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_history.dart';
import '../models/stock_part.dart';
import '../services/firestore_paths.dart';

class FirestoreServiceHistoryRepository implements ServiceHistoryRepository {
  final FirebaseFirestore _firestore;

  FirestoreServiceHistoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> add(ServiceHistory history) async {
    final batch = _firestore.batch();
    final recordsRef = _firestore
        .collection(FirestorePaths.deviceServiceRecords(history.deviceId))
        .doc();

    final recordData = _toFirestoreMap(history, id: recordsRef.id);
    batch.set(recordsRef, recordData);

    for (final used in history.kullanilanParcalar) {
      if (used.id.isEmpty) continue;
      final partDoc = _firestore
          .collection(FirestorePaths.spareParts)
          .doc(used.id);
      batch.update(partDoc, {
        'stock_quantity': FieldValue.increment(-1 * (used.stokAdedi)),
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  @override
  Future<List<ServiceHistory>> getAll() async {
    // CollectionGroup ile tüm cihazlardaki serviceRecords alt koleksiyonlarını sorgula
    final snapshot = await _firestore
        .collectionGroup(FirestorePaths.serviceRecords)
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((d) => _fromFirestore(d.id, d.data())).toList();
  }

  @override
  Future<List<ServiceHistory>> getRecent({int count = 3}) async {
    final snapshot = await _firestore
        .collectionGroup(FirestorePaths.serviceRecords)
        .orderBy('created_at', descending: true)
        .limit(count)
        .get();
    return snapshot.docs.map((d) => _fromFirestore(d.id, d.data())).toList();
  }

  @override
  Future<void> update(String id, ServiceHistory history) async {
    // Find the document in the collection group
    final snapshot = await _firestore
        .collectionGroup(FirestorePaths.serviceRecords)
        .where(FieldPath.documentId, isEqualTo: id)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final recordData = _toFirestoreMap(history, id: id);
      await doc.reference.update(recordData);
    }
  }

  @override
  Future<void> delete(String id) async {
    // Find the document in the collection group
    final snapshot = await _firestore
        .collectionGroup(FirestorePaths.serviceRecords)
        .where(FieldPath.documentId, isEqualTo: id)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      await doc.reference.delete();
    }
  }

  Map<String, dynamic> _toFirestoreMap(
    ServiceHistory history, {
    required String id,
  }) {
    return {
      'device_id': history.deviceId,
      'technician_id': history.technician,
      'service_type': history.status, // reusing status until UI separates
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
      'created_at': Timestamp.fromDate(history.date),
      'is_synced': true,
    };
  }

  ServiceHistory _fromFirestore(String id, Map<String, dynamic> data) {
    final createdAt = data['created_at'];
    DateTime when = DateTime.now();
    if (createdAt is Timestamp) when = createdAt.toDate();

    final usedParts = (data['used_parts'] as List<dynamic>? ?? [])
        .map(
          (raw) => StockPart(
            id: (raw['part_id'] ?? '') as String,
            parcaAdi: (raw['part_name'] ?? '') as String,
            parcaKodu: (raw['stock_code'] ?? '') as String,
            stokAdedi: (raw['quantity'] ?? 1) as int,
            criticalLevel: 0,
          ),
        )
        .toList();

    return ServiceHistory(
      id: id,
      date: when,
      deviceId: (data['device_id'] ?? '') as String,
      musteri: '',
      description: (data['description'] ?? '') as String,
      technician: (data['technician_id'] ?? '') as String,
      status: (data['service_type'] ?? '') as String,
      kullanilanParcalar: usedParts,
      photos: (data['images'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}
