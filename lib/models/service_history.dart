import 'package:cence_app/models/stock_part.dart';

class ServiceHistory {
  final String id;
  final DateTime date;
  final DateTime? serviceStart;
  final DateTime? serviceEnd;
  final String serialNumber;
  final String musteri;
  final String description;
  final String technician;
  final String status;
  final String location;
  final List<StockPart> kullanilanParcalar;
  final List<String>? photos;
  final String deviceName;
  final String brand;
  final String model;

  ServiceHistory({
    required this.id,
    required this.date,
    this.serviceStart,
    this.serviceEnd,
    required this.serialNumber,
    required this.musteri,
    required this.description,
    required this.technician,
    required this.status,
    this.location = '',
    this.kullanilanParcalar = const [],
    this.photos,
    this.deviceName = '',
    this.brand = '',
    this.model = '',
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    return ServiceHistory(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      serviceStart: json['serviceStart'] != null ? DateTime.tryParse(json['serviceStart']) : null,
      serviceEnd: json['serviceEnd'] != null ? DateTime.tryParse(json['serviceEnd']) : null,
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
      deviceName: json['deviceName'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'serviceStart': serviceStart?.toIso8601String(),
      'serviceEnd': serviceEnd?.toIso8601String(),
      'serialNumber': serialNumber,
      'musteri': musteri,
      'description': description,
      'technician': technician,
      'status': status,
      'location': location,
      'kullanilanParcalar': kullanilanParcalar.map((p) => p.toJson()).toList(),
      'photos': photos ?? [],
      'deviceName': deviceName,
      'brand': brand,
      'model': model,
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
