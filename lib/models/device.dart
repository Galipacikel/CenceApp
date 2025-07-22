class Device {
  final String id;
  final String modelName;
  final String serialNumber;

  Device({
    required this.id,
    required this.modelName,
    required this.serialNumber,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      modelName: json['modelName'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelName': modelName,
      'serialNumber': serialNumber,
    };
  }
}

abstract class DeviceRepository {
  Future<List<Device>> getAll();
  Future<void> add(Device device);
}

class MockDeviceRepository implements DeviceRepository {
  final List<Device> _mockDevices = [
    Device(id: 'DEVICE-001', modelName: 'Respiratory Device X-2000', serialNumber: 'SN-A12345'),
    Device(id: 'DEVICE-002', modelName: 'Defibrillator Pro-500', serialNumber: 'SN-B67890'),
    Device(id: 'DEVICE-003', modelName: 'ECG Monitor Card-10', serialNumber: 'SN-C13579'),
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