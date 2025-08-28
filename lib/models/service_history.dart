import 'package:cence_app/models/stock_part.dart';

class ServiceHistory {
  final String id;
  final DateTime date;
  final String serialNumber;
  final String musteri;
  final String description;
  final String technician;
  final String status;
  final String location;
  final List<StockPart> kullanilanParcalar;
  final List<String>? photos;

  ServiceHistory({
    required this.id,
    required this.date,
    required this.serialNumber,
    required this.musteri,
    required this.description,
    required this.technician,
    required this.status,
    this.location = '',
    this.kullanilanParcalar = const [],
    this.photos,
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    return ServiceHistory(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      serialNumber: json['serialNumber'] ?? json['deviceId'] ?? '',
      musteri: json['musteri'] ?? '',
      description: json['description'] ?? '',
      technician: json['technician'] ?? '',
      status: json['status'] ?? '',
      location: json['location'] ?? '',
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
      'serialNumber': serialNumber,
      'musteri': musteri,
      'description': description,
      'technician': technician,
      'status': status,
      'location': location,
      'kullanilanParcalar': kullanilanParcalar.map((p) => p.toJson()).toList(),
      'photos': photos ?? [],
    };
  }
}

abstract class ServiceHistoryRepository {
  Future<List<ServiceHistory>> getAll();
  Future<List<ServiceHistory>> getRecent({int count = 3});
  Future<void> add(ServiceHistory history);
  Future<void> update(String id, ServiceHistory history);
  Future<void> delete(String id);
}
