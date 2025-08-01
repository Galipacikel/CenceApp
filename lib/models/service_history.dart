
import 'package:cence_app/models/stock_part.dart';

class ServiceHistory {
  final String id;
  final DateTime date;
  final String deviceId; // Artık Device nesnesine referans
  final String musteri;
  final String description;
  final String technician;
  final String status;
  final List<StockPart> kullanilanParcalar; // Kullanılan parçaların listesi

  ServiceHistory({
    required this.id,
    required this.date,
    required this.deviceId,
    required this.musteri,
    required this.description,
    required this.technician,
    required this.status,
    this.kullanilanParcalar = const [],
  });

  // Json işlemleri şimdilik basitleştirildi, ileride detaylandırılacak
  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    return ServiceHistory(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      deviceId: json['deviceId'] ?? '',
      musteri: json['musteri'] ?? '',
      description: json['description'] ?? '',
      technician: json['technician'] ?? '',
      status: json['status'] ?? '',
      kullanilanParcalar: (json['kullanilanParcalar'] as List? ?? [])
          .map((item) => StockPart.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'deviceId': deviceId,
      'musteri': musteri,
      'description': description,
      'technician': technician,
      'status': status,
      'kullanilanParcalar': kullanilanParcalar.map((p) => p.toJson()).toList(),
    };
  }
}

abstract class ServiceHistoryRepository {
  Future<List<ServiceHistory>> getAll();
  Future<List<ServiceHistory>> getRecent({int count = 3});
  Future<void> add(ServiceHistory history);
}

class MockServiceHistoryRepository implements ServiceHistoryRepository {
  final List<ServiceHistory> _mockList = [
    ServiceHistory(
      id: '1',
      date: DateTime(2024, 3, 15),
      deviceId: 'CİHAZ-001', // Örnek cihaz ID'si
      musteri: 'A Hastanesi',
      description: 'Yıllık kalibrasyon ve parça kontrolü yapıldı.',
      technician: 'Ahmet Yılmaz',
      status: 'Başarılı',
      kullanilanParcalar: [
        // Örnek kullanılan parça
        StockPart(id: '3', parcaAdi: 'Kablo', parcaKodu: '67890', stokAdedi: 1, criticalLevel: 5)
      ]
    ),
    ServiceHistory(
      id: '2',
      date: DateTime(2024, 2, 28),
      deviceId: 'CİHAZ-002',
      musteri: 'B Kliniği',
      description: 'Güç kaynağı değiştirildi.',
      technician: 'Mehmet Demir',
      status: 'Başarılı',
    ),
    ServiceHistory(
      id: '3',
      date: DateTime(2024, 1, 10),
      deviceId: 'CİHAZ-001',
      musteri: 'A Hastanesi',
      description: 'Cihaz yazılımı v2.1.0 sürümüne güncellendi.',
      technician: 'Elif Kaya',
      status: 'Beklemede',
    ),
    ServiceHistory(
      id: '4',
      date: DateTime(2023, 12, 5),
      deviceId: 'CİHAZ-003',
      musteri: 'C Sağlık Merkezi',
      description: 'Filtreler değiştirildi, genel temizlik yapıldı.',
      technician: 'Ahmet Yılmaz',
      status: 'Arızalı',
    ),
  ];

  @override
  Future<List<ServiceHistory>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<ServiceHistory>.from(_mockList);
  }

  @override
  Future<List<ServiceHistory>> getRecent({int count = 3}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockList.take(count).toList();
  }

  @override
  Future<void> add(ServiceHistory history) async {
    _mockList.insert(0, history);
  }
} 