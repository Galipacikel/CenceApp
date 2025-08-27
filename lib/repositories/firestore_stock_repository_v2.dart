import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cence_app/core/error/failures.dart' as app;
import 'package:cence_app/core/result/result.dart';
import 'package:cence_app/core/result/unit.dart';
import 'package:cence_app/domain/repositories/stock_part_repository.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/services/firestore_paths.dart';

class FirestoreStockRepositoryV2 implements StockPartRepositoryV2 {
  final FirebaseFirestore _firestore;

  FirestoreStockRepositoryV2({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<StockPart>, app.Failure>> getAll() async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.spareParts)
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
  Future<Result<Unit, app.Failure>> decreaseQuantity(
    String partCode,
    int amount,
  ) async {
    try {
      final docRef = _firestore
          .collection(FirestorePaths.spareParts)
          .doc(partCode);
      await docRef.update({
        'stock_quantity': FieldValue.increment(-1 * amount),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return Result.ok(const Unit());
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  StockPart _fromFirestore(String id, Map<String, dynamic> data) {
    final clRaw = data['critical_level'];
    int critical = 0;
    if (clRaw is int) {
      critical = clRaw;
    } else if (clRaw is num) {
      critical = clRaw.toInt();
    }

    return StockPart(
      id: id,
      parcaAdi: (data['part_name'] ?? data['name'] ?? '') as String,
      parcaKodu: (data['stock_code'] ?? '') as String,
      stokAdedi: (data['stock_quantity'] ?? 0) as int,
      criticalLevel: critical,
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
