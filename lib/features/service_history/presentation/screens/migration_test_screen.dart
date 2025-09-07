import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/repositories/firestore_service_history_repository_v2.dart';

class MigrationTestScreen extends ConsumerStatefulWidget {
  const MigrationTestScreen({super.key});

  @override
  ConsumerState<MigrationTestScreen> createState() => _MigrationTestScreenState();
}

class _MigrationTestScreenState extends ConsumerState<MigrationTestScreen> {
  bool _isLoading = false;
  String _result = '';

  Future<void> _runMigration() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final repository = FirestoreServiceHistoryRepositoryV2();
      final result = await repository.migrateFormsToServiceHistory();
      
      result.fold(
        onSuccess: (_) {
          setState(() {
            _result = 'Migration başarıyla tamamlandı!';
          });
        },
        onFailure: (failure) {
          setState(() {
            _result = 'Migration hatası: ${failure.message}';
          });
        },
      );
    } catch (e) {
      setState(() {
        _result = 'Beklenmeyen hata: $e';
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
        backgroundColor: const Color(0xFF23408E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Formlar Koleksiyonu Migration Testi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu işlem formlar koleksiyonundaki verileri service_history koleksiyonuna kopyalar. '
              'Marka ve model bilgileri doğru şekilde aktarılacaktır.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _runMigration,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23408E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Migration Çalışıyor...'),
                      ],
                    )
                  : const Text(
                      'Migration Başlat',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result.contains('başarıyla') 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  border: Border.all(
                    color: _result.contains('başarıyla') 
                        ? Colors.green 
                        : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result,
                  style: TextStyle(
                    color: _result.contains('başarıyla') 
                        ? Colors.green.shade800 
                        : Colors.red.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}