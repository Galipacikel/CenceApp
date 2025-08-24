import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/device.dart';
import '../services/firestore_paths.dart';

abstract class FormsRepositoryBase {
  Future<List<Device>> searchDevices(String text);
}

/// Firebase'deki 'formlar' koleksiyonundaki cihaz kayıtlarını sorgulamak için basit repository
class FormsRepository implements FormsRepositoryBase {
  final FirebaseFirestore _firestore;

  FormsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Tek bir metin girdisiyle model veya seri no üzerinden arama (OR mantığı)
  @override
  Future<List<Device>> searchDevices(String text) async {
    final query = text.trim();
    if (query.isEmpty) return [];

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
      } catch (e) {
        // yoksay
      }
    }

    // 1) Prefix aramalar (başlayanla)
    await tryQuery(col.orderBy('MODEL').startAt([qUpper]).endAt(['$qUpper\uf8ff']).limit(20).get());
    await tryQuery(col.orderBy('MODEL').startAt([qExact]).endAt(['$qExact\uf8ff']).limit(20).get());
    await tryQuery(col.orderBy('SERİ NO').startAt([qExact]).endAt(['$qExact\uf8ff']).limit(20).get());

    // 2) Hiç sonuç yoksa veya index hatasından ötürü başarısız olduysa eşitlik fallback
    if (seen.isEmpty) {
      await tryQuery(col.where('SERİ NO', isEqualTo: qExact).limit(20).get());
      await tryQuery(col.where('MODEL', isEqualTo: qExact).limit(20).get());
      await tryQuery(col.where('MODEL', isEqualTo: qUpper).limit(20).get());
    }

    return seen.entries.map((e) => _mapFormToDevice(e.key, e.value)).toList();
  }

  Device _mapFormToDevice(String id, Map<String, dynamic> data) {
    final model = (data['MODEL'] ?? '').toString();
    final serial = (data['SERİ NO'] ?? '').toString();
    final marka = (data['MARKA'] ?? '').toString();
    final cihazAdi = (data['CİHAZ ADI'] ?? '').toString();
    final firma = (data['FİRMA'] ?? '').toString();

    // Model adı: MARKA + MODEL veya CİHAZ ADI + MODEL
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
}