import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cence_app/repositories/firestore_service_history_repository_v2.dart';

class MigrationTestScreen extends StatefulWidget {
  const MigrationTestScreen({super.key});

  @override
  State<MigrationTestScreen> createState() => _MigrationTestScreenState();
}

class _MigrationTestScreenState extends State<MigrationTestScreen> {
  bool _isLoading = false;
  String _result = '';
  final FirestoreServiceHistoryRepositoryV2 _repository = 
      FirestoreServiceHistoryRepositoryV2();

  Future<void> _runMigration() async {
    setState(() {
      _isLoading = true;
      _result = 'Migration başlatılıyor...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      
      // Formlar koleksiyonundaki tüm verileri al
      final formsSnapshot = await firestore.collection('formlar').get();
      
      int migratedCount = 0;
      int skippedCount = 0;
      
      for (final doc in formsSnapshot.docs) {
        final data = doc.data();
        final formId = doc.id;
        
        // Service_history koleksiyonunda bu kayıt var mı kontrol et
        final existingDoc = await firestore
            .collection('service_history')
            .where('original_id', isEqualTo: formId)
            .get();
            
        if (existingDoc.docs.isNotEmpty) {
          skippedCount++;
          continue;
        }
        
        // Tarihi parse et
        DateTime serviceDate = DateTime.now();
        final rawDate = data['TARİH'] ?? data['TARIH'] ?? data['tarih'];
        if (rawDate is Timestamp) {
          serviceDate = rawDate.toDate();
        } else if (rawDate is String) {
          final parsed = DateTime.tryParse(rawDate);
          if (parsed != null) serviceDate = parsed;
        }
        
        // Seri numarasını string olarak formatla
        String serialNumber = '';
        final rawSerial = data['SERİ NO'] ?? data['SERI NO'] ?? data['seri_no'];
        if (rawSerial != null) {
          serialNumber = rawSerial.toString();
        }
        
        // Service history formatında veri oluştur
        final serviceHistoryData = {
          'device_id': serialNumber.isNotEmpty ? serialNumber : formId,
          'device_name': data['CİHAZ ADI'] ?? data['CIHAZ ADI'] ?? data['cihaz_adi'] ?? '',
          'brand': data['MARKA'] ?? data['marka'] ?? '',
          'model': data['MODEL'] ?? data['model'] ?? '',
          'customer_name': data['FİRMA'] ?? data['firma'] ?? '',
          'location': data['LOKASYON'] ?? data['lokasyon'] ?? '',
          'service_type': 'Eski Formlar',
          'description': data['YAPILAN İŞLEM'] ?? data['YAPILAN ISLEM'] ?? data['yapilan_islem'] ?? '',
          'actions_taken': data['YAPILAN İŞLEM'] ?? data['YAPILAN ISLEM'] ?? data['yapilan_islem'] ?? '',
          'technician_id': 'migration_system',
          'technician_name': 'Migration System',
          'service_start': Timestamp.fromDate(serviceDate),
          'service_end': Timestamp.fromDate(serviceDate),
          'created_at': Timestamp.fromDate(DateTime.now()),
          'images': [],
          'used_parts': [],
          'is_synced': true,
          'migration_source': 'formlar',
          'original_id': formId,
          'migrated_at': Timestamp.fromDate(DateTime.now()),
        };
        
        // Batch'e ekle
        final newDocRef = firestore.collection('service_history').doc();
        batch.set(newDocRef, serviceHistoryData);
        migratedCount++;
      }
      
      // Batch'i commit et
      if (migratedCount > 0) {
        await batch.commit();
      }
      
      setState(() {
        _result = '''Migration tamamlandı!
• $migratedCount kayıt taşındı
• $skippedCount kayıt zaten mevcut
• Toplam: ${formsSnapshot.docs.length} kayıt işlendi''';
      });
    } catch (e) {
      setState(() {
        _result = 'Migration hatası: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkCollections() async {
    setState(() {
      _isLoading = true;
      _result = 'Koleksiyonlar kontrol ediliyor...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Formlar koleksiyonunu kontrol et
      final formsSnapshot = await firestore.collection('formlar').get();
      final formsCount = formsSnapshot.docs.length;
      
      // Service_history koleksiyonunu kontrol et
      final serviceHistorySnapshot = await firestore.collection('service_history').get();
      final serviceHistoryCount = serviceHistorySnapshot.docs.length;
      
      setState(() {
        _result = '''Koleksiyon Durumu:
• Forms: $formsCount kayıt
• Service History: $serviceHistoryCount kayıt''';
      });
    } catch (e) {
      setState(() {
        _result = 'Koleksiyon kontrol hatası: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migration Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Veri Migration İşlemleri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkCollections,
              child: const Text('Koleksiyonları Kontrol Et'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _runMigration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Migration Başlat'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}