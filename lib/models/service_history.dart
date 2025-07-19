class ServiceHistory {
  final String id;
  final DateTime date;
  final String type;
  final String description;
  final String technician;
  final String status;

  ServiceHistory({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
    required this.technician,
    required this.status,
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    return ServiceHistory(
      id: json['id'] ?? '',
      date: json['date'] is DateTime
          ? json['date']
          : DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      technician: json['technician'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
      'technician': technician,
      'status': status,
    };
  }
}

abstract class ServiceHistoryRepository {
  Future<List<ServiceHistory>> getAll();
  Future<List<ServiceHistory>> getRecent({int count = 3});
  // İleride eklenebilecek: getById, add, update, delete vs.
}

class MockServiceHistoryRepository implements ServiceHistoryRepository {
  final List<ServiceHistory> _mockList = [
    ServiceHistory(
      id: '1',
      date: DateTime(2024, 3, 15),
      type: 'Periyodik Bakım',
      description: 'Yıllık kalibrasyon ve parça kontrolü yapıldı.',
      technician: 'Ahmet Yılmaz',
      status: 'Tamamlandı',
    ),
    ServiceHistory(
      id: '2',
      date: DateTime(2024, 2, 28),
      type: 'Arıza Onarımı',
      description: 'Güç kaynağı değiştirildi.',
      technician: 'Mehmet Demir',
      status: 'Başarılı',
    ),
    ServiceHistory(
      id: '3',
      date: DateTime(2024, 1, 10),
      type: 'Yazılım Güncelleme',
      description: 'Cihaz yazılımı v2.1.0 sürümüne güncellendi.',
      technician: 'Elif Kaya',
      status: 'Beklemede',
    ),
    ServiceHistory(
      id: '4',
      date: DateTime(2023, 12, 5),
      type: 'Periyodik Bakım',
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

  Future<void> add(ServiceHistory history) async {
    _mockList.insert(0, history);
  }
} 