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
  final List<String>? photos; // Fotoğrafların yolları

  ServiceHistory({
    required this.id,
    required this.date,
    required this.deviceId,
    required this.musteri,
    required this.description,
    required this.technician,
    required this.status,
    this.kullanilanParcalar = const [],
    this.photos,
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
      photos: (json['photos'] as List? ?? []).cast<String>(),
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
      'photos': photos ?? [],
    };
  }
}

abstract class ServiceHistoryRepository {
  Future<List<ServiceHistory>> getAll();
  Future<List<ServiceHistory>> getRecent({int count = 3});
  Future<void> add(ServiceHistory history);
}
