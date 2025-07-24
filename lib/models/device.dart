class Device {
  final String id;
  final String modelName;
  final String serialNumber;
  final String customer;
  final String installDate;
  final String warrantyStatus;
  final String lastMaintenance;
  final DateTime? warrantyEndDate; // Yeni alan

  Device({
    required this.id,
    required this.modelName,
    required this.serialNumber,
    required this.customer,
    required this.installDate,
    required this.warrantyStatus,
    required this.lastMaintenance,
    this.warrantyEndDate,
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

class MockDeviceRepository implements DeviceRepository {
  final List<Device> _mockDevices = [
    Device(
      id: 'CİHAZ-001',
      modelName: 'Solunum Cihazı X-2000',
      serialNumber: 'SN-A12345',
      customer: 'Acıbadem Hastanesi',
      installDate: '15.01.2023',
      warrantyStatus: 'Devam Ediyor',
      lastMaintenance: '15.01.2024',
      warrantyEndDate: DateTime(2025, 1, 15), // 24 ay garanti
    ),
    Device(
      id: 'CİHAZ-002',
      modelName: 'Kalp Şok Cihazı Pro-500',
      serialNumber: 'SN-B67890',
      customer: 'Medipol Kliniği',
      installDate: '10.03.2022',
      warrantyStatus: 'Bitti',
      lastMaintenance: '10.03.2023',
      warrantyEndDate: DateTime(2024, 3, 10), // Garanti bitti
    ),
    Device(
      id: 'CİHAZ-003',
      modelName: 'EKG Monitörü Card-10',
      serialNumber: 'SN-C13579',
      customer: 'Şifa Sağlık Merkezi',
      installDate: '20.06.2021',
      warrantyStatus: 'Devam Ediyor',
      lastMaintenance: '20.06.2023',
      warrantyEndDate: DateTime(2025, 6, 20), // 48 ay garanti
    ),
    // Aynı model farklı müşteriler
    Device(
      id: 'CİHAZ-004',
      modelName: 'EKG Monitörü Card-10',
      serialNumber: 'SN-C24680',
      customer: 'Memorial Hastanesi',
      installDate: '05.09.2022',
      warrantyStatus: 'Devam Ediyor',
      lastMaintenance: '05.09.2023',
      warrantyEndDate: DateTime(2024, 9, 5), // 24 ay garanti
    ),
    Device(
      id: 'CİHAZ-005',
      modelName: 'EKG Monitörü Card-10',
      serialNumber: 'SN-C35791',
      customer: 'Liv Hastanesi',
      installDate: '12.11.2021',
      warrantyStatus: 'Bitti',
      lastMaintenance: '12.11.2022',
      warrantyEndDate: DateTime(2023, 11, 12), // Garanti bitti
    ),
    Device(
      id: 'CİHAZ-006',
      modelName: 'Solunum Cihazı X-2000',
      serialNumber: 'SN-A24680',
      customer: 'Anadolu Sağlık Merkezi',
      installDate: '08.04.2023',
      warrantyStatus: 'Devam Ediyor',
      lastMaintenance: '08.04.2024',
      warrantyEndDate: DateTime(2025, 4, 8), // 24 ay garanti
    ),
    Device(
      id: 'CİHAZ-007',
      modelName: 'Kalp Şok Cihazı Pro-500',
      serialNumber: 'SN-B13579',
      customer: 'Koç Üniversitesi Hastanesi',
      installDate: '25.07.2022',
      warrantyStatus: 'Devam Ediyor',
      lastMaintenance: '25.07.2023',
      warrantyEndDate: DateTime(2024, 7, 25), // 24 ay garanti
    ),
    Device(
      id: 'CİHAZ-008',
      modelName: 'Kalp Şok Cihazı Pro-500',
      serialNumber: 'SN-B24680',
      customer: 'Hacettepe Üniversitesi Hastanesi',
      installDate: '03.12.2021',
      warrantyStatus: 'Bitti',
      lastMaintenance: '03.12.2022',
      warrantyEndDate: DateTime(2023, 12, 3), // Garanti bitti
    ),
  ];

  @override
  Future<List<Device>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockDevices;
  }

  @override
  Future<void> add(Device device) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _mockDevices.insert(0, device);
  }

  @override
  Future<void> update(Device device) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _mockDevices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      _mockDevices[index] = device;
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _mockDevices.removeWhere((d) => d.id == id);
  }

  @override
  Future<Device?> findById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _mockDevices.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
} 