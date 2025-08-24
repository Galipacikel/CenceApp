import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cence_app/core/error/failures.dart' as app;
import 'package:cence_app/core/result/result.dart';
import 'package:cence_app/domain/repositories/forms_repository.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/services/firestore_paths.dart';

class FormsRepositoryV2Impl implements FormsRepositoryV2 {
  final FirebaseFirestore _firestore;

  FormsRepositoryV2Impl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<Device>, app.Failure>> searchDevices(String text) async {
    try {
      final query = text.trim();
      if (query.isEmpty) return Result.ok(<Device>[]);

      final col = _firestore.collection(FirestorePaths.forms);

      final qUpper = query.toUpperCase();
      final qExact = query;

      final seen = <String, Map<String, dynamic>>{};

      Future<void> tryQuery(Future<QuerySnapshot<Map<String, dynamic>>> f) async {
        try {
          final s = await f;
          for (final d in s.docs) {
            seen[d.id] = d.data();
          }
        } catch (_) {}
      }

      await tryQuery(col.orderBy('MODEL').startAt([qUpper]).endAt(['$qUpper\uf8ff']).limit(20).get());
      await tryQuery(col.orderBy('MODEL').startAt([qExact]).endAt(['$qExact\uf8ff']).limit(20).get());
      await tryQuery(col.orderBy('SERİ NO').startAt([qExact]).endAt(['$qExact\uf8ff']).limit(20).get());

      if (seen.isEmpty) {
        await tryQuery(col.where('SERİ NO', isEqualTo: qExact).limit(20).get());
        await tryQuery(col.where('MODEL', isEqualTo: qExact).limit(20).get());
        await tryQuery(col.where('MODEL', isEqualTo: qUpper).limit(20).get());
      }

      final list = seen.entries.map((e) => _mapFormToDevice(e.key, e.value)).toList();
      return Result.ok(list);
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  Device _mapFormToDevice(String id, Map<String, dynamic> data) {
    final model = (data['MODEL'] ?? '').toString();
    final serial = (data['SERİ NO'] ?? '').toString();
    final marka = (data['MARKA'] ?? '').toString();
    final cihazAdi = (data['CİHAZ ADI'] ?? '').toString();
    final firma = (data['FİRMA'] ?? '').toString();

    final modelName = [if (marka.isNotEmpty) marka, if (model.isNotEmpty) model].join(' ').trim();

    return Device(
      id: id,
      modelName: modelName.isNotEmpty ? modelName : (cihazAdi.isNotEmpty ? cihazAdi : model),
      serialNumber: serial,
      customer: firma,
      installDate: '',
      warrantyStatus: 'Bilinmiyor',
      lastMaintenance: '',
      warrantyEndDate: null,
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