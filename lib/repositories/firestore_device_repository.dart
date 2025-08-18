import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/device.dart';
import '../services/firestore_paths.dart';

class FirestoreDeviceRepository implements DeviceRepository {
  final FirebaseFirestore _firestore;

  FirestoreDeviceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> add(Device device) async {
    final devicesRef = _firestore.collection(FirestorePaths.devices);
    await devicesRef.add(_toFirestoreMap(device));
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(FirestorePaths.devices).doc(id).delete();
  }

  @override
  Future<List<Device>> getAll() async {
    final snapshot = await _firestore.collection(FirestorePaths.devices).get();
    return snapshot.docs.map((d) => _fromFirestore(d.id, d.data())).toList();
  }

  @override
  Future<Device?> findById(String id) async {
    final doc = await _firestore
        .collection(FirestorePaths.devices)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return _fromFirestore(doc.id, doc.data() ?? {});
  }

  @override
  Future<void> update(Device device) async {
    await _firestore
        .collection(FirestorePaths.devices)
        .doc(device.id)
        .update(_toFirestoreMap(device));
  }

  Map<String, dynamic> _toFirestoreMap(Device device) {
    return {
      'barcode_number': device.id, // local id as barcode placeholder if needed
      'serial_number': device.serialNumber,
      'brand': device
          .modelName, // our modelName may contain brand+model; adjust UI later
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
      warrantyStatus:
          warrantyEndDate != null && DateTime.now().isBefore(warrantyEndDate)
          ? 'Devam Ediyor'
          : 'Bitti',
      lastMaintenance: '',
      warrantyEndDate: warrantyEndDate,
    );
  }
}
