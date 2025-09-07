import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MigrationTestScreen extends StatefulWidget {
  const MigrationTestScreen({Key? key}) : super(key: key);

  @override
  State<MigrationTestScreen> createState() => _MigrationTestScreenState();
}

class _MigrationTestScreenState extends State<MigrationTestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String _statusMessage = '';
  int _migratedCount = 0;
  int _totalCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veri Migration Testi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Migration Durumu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Toplam Kayıt: $_totalCount'),
                    Text('Migrate Edilen: $_migratedCount'),
                    const SizedBox(height: 8),
                    if (_statusMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeData,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Veri Analizi Yap'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _startMigration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Migration Başlat'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyMigration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Migration Doğrula'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _cleanupOldData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eski Verileri Temizle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Veri analizi başlatılıyor...';
    });

    try {
      // Formlar koleksiyonundaki toplam kayıt sayısını al
      final formsSnapshot = await _firestore.collection('formlar').get();
      final serviceHistorySnapshot = await _firestore.collection('service_history').get();
      
      setState(() {
        _totalCount = formsSnapshot.docs.length;
        _statusMessage = 'Analiz tamamlandı:\n'
            'Formlar koleksiyonu: ${formsSnapshot.docs.length} kayıt\n'
            'Service History koleksiyonu: ${serviceHistorySnapshot.docs.length} kayıt';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Analiz hatası: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startMigration() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Migration başlatılıyor...';
      _migratedCount = 0;
    });

    try {
      final formsSnapshot = await _firestore.collection('formlar').get();
      
      for (int i = 0; i < formsSnapshot.docs.length; i++) {
        final doc = formsSnapshot.docs[i];
        final data = doc.data();
        
        // Formlar verisini service_history formatına dönüştür
        final migratedData = _convertToServiceHistoryFormat(data, doc.id);
        
        // Service history koleksiyonuna ekle
        await _firestore.collection('service_history').add(migratedData);
        
        setState(() {
          _migratedCount = i + 1;
          _statusMessage = 'Migration devam ediyor... ${_migratedCount}/${formsSnapshot.docs.length}';
        });
      }
      
      setState(() {
        _statusMessage = 'Migration tamamlandı! $_migratedCount kayıt başarıyla migrate edildi.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Migration hatası: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _convertToServiceHistoryFormat(Map<String, dynamic> formData, String originalId) {
    // Tarih formatını dönüştür
    DateTime? serviceDate;
    if (formData['TARİH'] != null) {
      if (formData['TARİH'] is Timestamp) {
        serviceDate = (formData['TARİH'] as Timestamp).toDate();
      } else if (formData['TARİH'] is String) {
        serviceDate = DateTime.tryParse(formData['TARİH']);
      }
    }

    return {
      'device_id': formData['SERİ NO']?.toString() ?? 'UNKNOWN',
      'device_name': formData['CİHAZ ADI'] ?? 'Bilinmeyen Cihaz',
      'brand': formData['MARKA'] ?? 'Bilinmeyen Marka',
      'model': formData['MODEL'] ?? 'Bilinmeyen Model',
      'customer_name': formData['FİRMA'] ?? 'Bilinmeyen Firma',
      'location': formData['LOKASYON'] ?? 'Bilinmeyen Lokasyon',
      'service_type': 'Eski Kayıt', // Eski verileri işaretle
      'description': formData['YAPILAN İŞLEM'] ?? 'Açıklama yok',
      'actions_taken': formData['YAPILAN İŞLEM'] ?? '',
      'technician_id': 'migration_system',
      'technician_name': 'Migration System',
      'service_start': serviceDate?.toIso8601String(),
      'service_end': serviceDate?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'images': '[]',
      'used_parts': '[]',
      'is_synced': true,
      'migration_source': 'formlar',
      'original_id': originalId,
      'migrated_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _verifyMigration() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Migration doğrulanıyor...';
    });

    try {
      final formsSnapshot = await _firestore.collection('formlar').get();
      final serviceHistorySnapshot = await _firestore
          .collection('service_history')
          .where('migration_source', isEqualTo: 'formlar')
          .get();
      
      setState(() {
        _statusMessage = 'Doğrulama tamamlandı:\n'
            'Formlar koleksiyonu: ${formsSnapshot.docs.length} kayıt\n'
            'Migrate edilen kayıtlar: ${serviceHistorySnapshot.docs.length} kayıt\n'
            'Durum: ${formsSnapshot.docs.length == serviceHistorySnapshot.docs.length ? "✅ Başarılı" : "❌ Eksik kayıt var"}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Doğrulama hatası: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanupOldData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Eski veriler temizleniyor...';
    });

    try {
      // Önce migration doğrulaması yap
      final formsSnapshot = await _firestore.collection('formlar').get();
      final migratedSnapshot = await _firestore
          .collection('service_history')
          .where('migration_source', isEqualTo: 'formlar')
          .get();
      
      if (formsSnapshot.docs.length != migratedSnapshot.docs.length) {
        setState(() {
          _statusMessage = 'Hata: Migration tamamlanmamış. Önce migration işlemini tamamlayın.';
        });
        return;
      }

      // Formlar koleksiyonundaki tüm belgeleri sil
      final batch = _firestore.batch();
      for (final doc in formsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      setState(() {
        _statusMessage = 'Temizlik tamamlandı! ${formsSnapshot.docs.length} eski kayıt silindi.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Temizlik hatası: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}