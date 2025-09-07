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

  /// Formlar koleksiyonundaki verileri service_history koleksiyonuna migrate eder
  Future<Result<Unit, app.Failure>> migrateFormsToServiceHistory() async {
    try {
      // Önce formlar koleksiyonundaki tüm verileri al
      final formsSnapshot = await _firestore.collection(FirestorePaths.forms).get();
      
      // Service_history koleksiyonundaki mevcut verileri al
      final serviceHistorySnapshot = await _firestore.collection(FirestorePaths.serviceHistory).get();
      final existingIds = serviceHistorySnapshot.docs.map((doc) => doc.id).toSet();
      
      final batch = _firestore.batch();
      int migratedCount = 0;
      
      for (final formDoc in formsSnapshot.docs) {
        // Eğer bu form verisi zaten service_history'de varsa atla
        if (existingIds.contains(formDoc.id)) continue;
        
        // Form verisini ServiceHistory nesnesine çevir
        final serviceHistory = _fromForms(formDoc.id, formDoc.data());
        
        // Service_history koleksiyonuna ekle
        final serviceHistoryRef = _firestore
            .collection(FirestorePaths.serviceHistory)
            .doc(formDoc.id);
        
        final serviceHistoryData = _toFirestoreMap(serviceHistory, id: formDoc.id);
        batch.set(serviceHistoryRef, serviceHistoryData);
        
        migratedCount++;
      }
      
      if (migratedCount > 0) {
        await batch.commit();
        print('Migration tamamlandı: $migratedCount kayıt aktarıldı.');
      } else {
        print('Migration gerekli değil: Tüm veriler zaten mevcut.');
      }
      
      return Result.ok(const Unit());
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Unit, app.Failure>> add(ServiceHistory history) async {
    try {
      final batch = _firestore.batch();
      final recordsRef = _firestore
          .collection(FirestorePaths.serviceHistory)
          .doc(history.id);

      final recordData = _toFirestoreMap(history, id: recordsRef.id);
      batch.set(recordsRef, recordData);

      // Stok düş: Sadece envanterdeki gerçek parçalarda uygula
      for (final used in history.kullanilanParcalar) {
        if (used.id.isEmpty) continue;
        if (used.id.startsWith('custom_')) continue; // "Diğer Parça" ise stoktan düşme
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
      // Fetch from new top-level service_history collection
      final snapshot = await _firestore
          .collection(FirestorePaths.serviceHistory)
          .orderBy('created_at', descending: true)
          .get();
      final list = snapshot.docs
          .map((d) => _fromFirestore(d.id, d.data()))
          .toList();

      // Formlar koleksiyonundan veri çekmeyi güvenli hale getir
      List<ServiceHistory> formsList = [];
      try {
        final formsSnap = await _firestore.collection(FirestorePaths.forms).get();
        formsList = formsSnap.docs
            .map((d) {
              try {
                return _fromForms(d.id, d.data());
              } catch (e) {
                print('Form verisi dönüştürme hatası (ID: ${d.id}): $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<ServiceHistory>()
            .toList();
      } catch (e) {
        print('Formlar koleksiyonu okuma hatası: $e');
        // Formlar koleksiyonunda hata varsa sadece service_history verilerini döndür
      }

      // Merge and sort by date desc
      final merged = <ServiceHistory>[...list, ...formsList]
        ..sort((a, b) => b.date.compareTo(a.date));

      return Result.ok(merged);
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
      final serviceHistorySnap = await _firestore
          .collection(FirestorePaths.serviceHistory)
          .orderBy('created_at', descending: true)
          .limit(count * 3)
          .get();
      final list = serviceHistorySnap.docs
          .map((d) => _fromFirestore(d.id, d.data()))
          .toList();

      // Formlar koleksiyonundan veri çekmeyi güvenli hale getir
      List<ServiceHistory> formsList = [];
      try {
        final formsSnap = await _firestore
            .collection(FirestorePaths.forms)
            .get();
        formsList = formsSnap.docs
            .map((d) {
              try {
                return _fromForms(d.id, d.data());
              } catch (e) {
                print('Form verisi dönüştürme hatası (ID: ${d.id}): $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<ServiceHistory>()
            .toList();
      } catch (e) {
        print('Formlar koleksiyonu okuma hatası: $e');
        // Formlar koleksiyonunda hata varsa sadece service_history verilerini döndür
      }

      final merged = <ServiceHistory>[...list, ...formsList]
        ..sort((a, b) => b.date.compareTo(a.date));

      final limited = merged.take(count).toList();
      return Result.ok(limited);
    } on FirebaseException catch (e) {
      return Result.err(_toFailure(e));
    } catch (e) {
      return Result.err(app.UnknownFailure(e.toString()));
    }
  }

  ServiceHistory _fromForms(String id, Map<String, dynamic> data) {
    try {
      DateTime when = DateTime.now();
      final dynamic rawTarih = data['TARİH'] ?? data['TARIH'] ?? data['tarih'] ?? data['created_at'] ?? data['date'];
      if (rawTarih is Timestamp) {
        when = rawTarih.toDate();
      } else if (rawTarih is String) {
        final parsed = DateTime.tryParse(rawTarih);
        if (parsed != null) when = parsed;
      }

      String readString(List<String> keys) {
        for (final k in keys) {
          final v = data[k];
          if (v == null) continue;
          final s = v.toString().trim();
          if (s.isNotEmpty) return s;
        }
        return '';
      }

      // Firebase formlar koleksiyonundaki alan isimleri
      final cihazAdi = readString(['CİHAZ ADI', 'CIHAZ ADI', 'cihaz_adi', 'device_name']);
      final marka = readString(['MARKA', 'marka', 'brand']);
      final model = readString(['MODEL', 'model']);
      final seriNo = readString(['SERİ NO', 'SERI NO', 'seri_no', 'serial_number']);
      final firma = readString(['FİRMA', 'firma', 'customer_name']);
      final lokasyon = readString(['LOKASYON', 'lokasyon', 'location']);
      final yapilanIslem = readString(['YAPILAN İŞLEM', 'YAPILAN ISLEM', 'yapilan_islem', 'description']);
      final teknisyen = readString(['TEKNİSYEN', 'TEKNISYEN', 'teknisyen', 'technician']);
      // final durum = readString(['DURUM', 'durum', 'status']); // Şu an kullanılmıyor
      


      // Seri numarasını string olarak formatla
       String serialNumber = seriNo;
       if (serialNumber.isEmpty && data['SERİ NO'] != null) {
         // Numeric seri numaralarını string'e çevir
         final rawSerial = data['SERİ NO'];
         if (rawSerial is num) {
           serialNumber = rawSerial.toString();
         }
       }

       // Cihaz bilgilerini birleştir (şu an kullanılmıyor)
       // final deviceInfo = [cihazAdi, marka, model].where((e) => e.isNotEmpty).join(' - ');
       // final deviceLabel = deviceInfo.isNotEmpty ? deviceInfo : 'Bilinmeyen Cihaz';

       return ServiceHistory(
         id: id,
         date: when,
         serialNumber: serialNumber.isNotEmpty ? serialNumber : id,
         musteri: firma.isNotEmpty ? firma : 'Bilinmeyen Müşteri',
         description: yapilanIslem.isNotEmpty ? yapilanIslem : 'Kurulum/Bakım işlemi yapıldı',
         technician: teknisyen.isNotEmpty ? teknisyen : 'Sistem',
         status: 'Kurulum', // Formlar koleksiyonundaki veriler kurulum olarak işaretlenir
         location: lokasyon,
         kullanilanParcalar: const <StockPart>[],
         photos: const <String>[],
         deviceName: cihazAdi,
         brand: marka,
         model: model,
       );
     } catch (e) {
       // Hata durumunda varsayılan bir ServiceHistory nesnesi döndür
       print('Form verisi dönüştürme hatası (ID: $id): $e');
       return ServiceHistory(
         id: id,
         date: DateTime.now(),
         serialNumber: id,
         musteri: 'Bilinmeyen Müşteri',
         description: 'Veri dönüştürme hatası',
         technician: 'Sistem',
         status: 'Hata',
         location: '',
         kullanilanParcalar: const <StockPart>[],
         photos: const <String>[],
         deviceName: 'Bilinmeyen Cihaz',
         brand: '',
         model: '',
       );
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
      'device_id': history.serialNumber,
      'technician_id': history.technician,
      'technician_name': history.technician,
       'service_type': history.status,
       'description': history.description,
       'location': history.location,
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
      'service_start': history.serviceStart != null ? Timestamp.fromDate(history.serviceStart!) : null,
      'service_end': history.serviceEnd != null ? Timestamp.fromDate(history.serviceEnd!) : null,
      'device_name': history.deviceName,
      'brand': history.brand,
      'model': history.model,
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
       serviceStart: (data['service_start'] is Timestamp) ? (data['service_start'] as Timestamp).toDate() : null,
       serviceEnd: (data['service_end'] is Timestamp) ? (data['service_end'] as Timestamp).toDate() : null,
       serialNumber: (data['device_id'] ?? '') as String,
      musteri: (data['customer_name'] ?? '') as String,
       description: (data['description'] ?? '') as String,
      technician: technicianStr,
       status: (data['service_type'] ?? '') as String,
       location: (data['location'] ?? '') as String,
       kullanilanParcalar: usedParts,
       photos: (data['images'] as List<dynamic>? ?? []).cast<String>(),
       deviceName: (data['device_name'] ?? '') as String,
       brand: (data['brand'] ?? '') as String,
       model: (data['model'] ?? '') as String,
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
