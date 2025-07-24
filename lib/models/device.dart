class Device {
  final String id;
  final String modelName;
  final String serialNumber;
  final String customer;
  final String installDate;
  final String warrantyStatus;
  final String lastMaintenance;

  Device({
    required this.id,
    required this.modelName,
    required this.serialNumber,
    required this.customer,
    required this.installDate,
    required this.warrantyStatus,
    required this.lastMaintenance,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      modelName: json['modelName'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      customer: json['customer'] ?? '',
      installDate: json['installDate'] ?? '',
      warrantyStatus: json['warrantyStatus'] ?? '',
      lastMaintenance: json['lastMaintenance'] ?? '',
    );
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
    };
  }
}

abstract class DeviceRepository {
  Future<List<Device>> getAll();
  Future<void> add(Device device);
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
    ),
    Device(
      id: 'CİHAZ-002',
      modelName: 'Kalp Şok Cihazı Pro-500',
      serialNumber: 'SN-B67890',
      customer: 'Medipol Kliniği',
      installDate: '10.03.2022',
      warrantyStatus: 'Bitti',
      lastMaintenance: '10.03.2023',
    ),
    Device(
      id: 'CİHAZ-003',
      modelName: 'EKG Monitörü Card-10',
      serialNumber: 'SN-C13579',
      customer: 'Şifa Sağlık Merkezi',
      installDate: '20.06.2021',
      warrantyStatus: 'Devam Ediyor',
      lastMaintenance: '20.06.2023',
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
} 