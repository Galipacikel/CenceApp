class Device {
  final String id;
  final String modelName;
  final String serialNumber;
  final String customer;
  final String installDate;
  final String warrantyStatus;
  final String lastMaintenance;
  final DateTime? warrantyEndDate;
  final int stockQuantity; // İngilizce isim

  Device({
    required this.id,
    required this.modelName,
    required this.serialNumber,
    required this.customer,
    required this.installDate,
    required this.warrantyStatus,
    required this.lastMaintenance,
    this.warrantyEndDate,
    this.stockQuantity = 1, // İngilizce isim
  });

  // Garanti durumunu otomatik hesapla
  String get calculatedWarrantyStatus {
    if (warrantyEndDate == null) return warrantyStatus;

    final now = DateTime.now();
    if (now.isBefore(warrantyEndDate!)) {
      return 'Devam Ediyor';
    } else {
      return 'Bitti';
    }
  }

  // Garanti bitiş tarihini string olarak getir
  String get warrantyEndDateString {
    if (warrantyEndDate == null) return 'Belirtilmemiş';
    return '${warrantyEndDate!.day.toString().padLeft(2, '0')}.${warrantyEndDate!.month.toString().padLeft(2, '0')}.${warrantyEndDate!.year}';
  }

  // Garanti bitiş tarihine kalan gün sayısı
  int get daysUntilWarrantyExpiry {
    if (warrantyEndDate == null) return -1;

    final now = DateTime.now();
    final difference = warrantyEndDate!.difference(now);
    return difference.inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelName': modelName,
      'serialNumber': serialNumber,
      'customer': customer,
      'installDate': installDate,
      'warrantyStatus': warrantyStatus,
      'lastMaintenance': lastMaintenance,
      'warrantyEndDate': warrantyEndDate?.toIso8601String(),
      'stockQuantity': stockQuantity,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      modelName: json['modelName'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      customer: json['customer'] ?? '',
      installDate: json['installDate'] ?? '',
      warrantyStatus: json['warrantyStatus'] ?? '',
      lastMaintenance: json['lastMaintenance'] ?? '',
      warrantyEndDate: json['warrantyEndDate'] != null
          ? DateTime.parse(json['warrantyEndDate'])
          : null,
      stockQuantity: json['stockQuantity'] ?? 1,
    );
  }

  Device copyWith({
    String? id,
    String? modelName,
    String? serialNumber,
    String? customer,
    String? installDate,
    String? warrantyStatus,
    String? lastMaintenance,
    DateTime? warrantyEndDate,
    int? stockQuantity,
  }) {
    return Device(
      id: id ?? this.id,
      modelName: modelName ?? this.modelName,
      serialNumber: serialNumber ?? this.serialNumber,
      customer: customer ?? this.customer,
      installDate: installDate ?? this.installDate,
      warrantyStatus: warrantyStatus ?? this.warrantyStatus,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      warrantyEndDate: warrantyEndDate ?? this.warrantyEndDate,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }
}

abstract class DeviceRepository {
  Future<List<Device>> getAll();
  Future<void> add(Device device);
  Future<void> update(Device device);
  Future<void> delete(String id);
  Future<Device?> findById(String id);
}
