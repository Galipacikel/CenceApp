import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cence_app/core/error/failures.dart' as app;
import 'package:cence_app/core/result/result.dart';
import 'package:cence_app/core/result/unit.dart';
import 'package:cence_app/domain/repositories/service_history_repository.dart';
import 'package:cence_app/models/service_history.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/services/firestore_paths.dart';

class FirestoreServiceHistoryRepositoryV2
    implements ServiceHistoryRepositoryV2 {
  final FirebaseFirestore _firestore;

  FirestoreServiceHistoryRepositoryV2({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<Unit, app.Failure>> add(ServiceHistory history) async {
    try {
      final batch = _firestore.batch();
      final recordsRef = _firestore
          .collection(FirestorePaths.serviceHistory)
          .doc(history.id);

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
      return Result.ok(const Unit());
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ServiceHistory>, app.Failure>> getAll() async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.serviceHistory)
          .orderBy('created_at', descending: true)
          .get();
      final list = snapshot.docs
          .map((d) => _fromFirestore(d.id, d.data()))
          .toList();
      return Result.ok(list);
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ServiceHistory>, app.Failure>> getRecent({
    int count = 3,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.serviceHistory)
          .orderBy('created_at', descending: true)
          .limit(count)
          .get();
      final list = snapshot.docs
          .map((d) => _fromFirestore(d.id, d.data()))
          .toList();
      return Result.ok(list);
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Unit, app.Failure>> update(
    String id,
    ServiceHistory history,
  ) async {
    try {
      final recordData = _toFirestoreMap(history, id: id);
      await _firestore
          .collection(FirestorePaths.serviceHistory)
          .doc(id)
          .update(recordData);
      return Result.ok(const Unit());
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Unit, app.Failure>> delete(String id) async {
    try {
      await _firestore
          .collection(FirestorePaths.serviceHistory)
          .doc(id)
          .delete();
      return Result.ok(const Unit());
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  Map<String, dynamic> _toFirestoreMap(
    ServiceHistory history, {
    required String id,
  }) {
    return {
      'device_id': history.deviceId,
      'technician_id': history.technician,
      'technician_name': history.technician,
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
       'created_at': Timestamp.fromDate(history.date),
      'customer_name': history.musteri,
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

    final String technicianStr = (data['technician_name'] ?? data['technician_id'] ?? '') as String;

     return ServiceHistory(
       id: id,
       date: when,
       deviceId: (data['device_id'] ?? '') as String,
      musteri: (data['customer_name'] ?? '') as String,
       description: (data['description'] ?? '') as String,
      technician: technicianStr,
       status: (data['service_type'] ?? '') as String,
       kullanilanParcalar: usedParts,
       photos: (data['images'] as List<dynamic>? ?? []).cast<String>(),
     );
   }

  app.Failure _toFailure(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return app.PermissionFailure('İzin reddedildi', code: e.code);
      case 'unavailable':
      case 'network-request-failed':
        return app.NetworkFailure('Ağ hatası', code: e.code);
      case 'not-found':
        return app.NotFoundFailure('Kayıt bulunamadı', code: e.code);
      default:
        return app.UnknownFailure(e.message ?? 'Bilinmeyen hata', code: e.code);
    }
  }
}
