import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cence_app/core/error/failures.dart' as app;
import 'package:cence_app/core/result/result.dart';
import 'package:cence_app/core/result/unit.dart';
import 'package:cence_app/domain/repositories/device_repository.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/services/firestore_paths.dart';

class FirestoreDeviceRepositoryV2 implements DeviceRepositoryV2 {
  final FirebaseFirestore _firestore;

  FirestoreDeviceRepositoryV2({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<Device>, app.Failure>> getAll() async {
    try {
      final snapshot = await _firestore.collection(FirestorePaths.devices).get();
      final list = snapshot.docs.map((d) => _fromFirestore(d.id, d.data())).toList();
      return Result.ok(list);
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Unit, app.Failure>> add(Device device) async {
    try {
      final devicesRef = _firestore.collection(FirestorePaths.devices);
      await devicesRef.add(_toFirestoreMap(device));
      return Result.ok(const Unit());
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Unit, app.Failure>> update(Device device) async {
    try {
      await _firestore
          .collection(FirestorePaths.devices)
          .doc(device.id)
          .update(_toFirestoreMap(device));
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
      await _firestore.collection(FirestorePaths.devices).doc(id).delete();
      return Result.ok(const Unit());
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Device, app.Failure>> findById(String id) async {
    try {
      final doc = await _firestore.collection(FirestorePaths.devices).doc(id).get();
      if (!doc.exists) {
        return Result.err(app.NotFoundFailure('Cihaz bulunamadı', code: 'not-found'));
      }
      final device = _fromFirestore(doc.id, doc.data() ?? {});
      return Result.ok(device);
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  Map<String, dynamic> _toFirestoreMap(Device device) {
    return {
      'barcode_number': device.id,
      'serial_number': device.serialNumber,
      'brand': device.modelName,
      'model': device.modelName,
      'institution_name': device.customer,
      'installation_date': device.installDate,
      'warranty_end_date': device.warrantyEndDate,
    };
  }

  Device _fromFirestore(String id, Map<String, dynamic> data) {
    final warrantyTs = data['warranty_end_date'];
    DateTime? warrantyEndDate;
    if (warrantyTs != null) {
      if (warrantyTs is Timestamp) {
        warrantyEndDate = warrantyTs.toDate();
      } else if (warrantyTs is DateTime) {
        warrantyEndDate = warrantyTs;
      }
    }

    return Device(
      id: id,
      modelName: (data['model'] ?? data['brand'] ?? '') as String,
      serialNumber: (data['serial_number'] ?? '') as String,
      customer: (data['institution_name'] ?? '') as String,
      installDate: (data['installation_date']?.toString() ?? ''),
      warrantyStatus: warrantyEndDate != null && DateTime.now().isBefore(warrantyEndDate)
          ? 'Devam Ediyor'
          : 'Bitti',
      lastMaintenance: '',
      warrantyEndDate: warrantyEndDate,
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