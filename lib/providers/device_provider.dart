import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceProvider extends ChangeNotifier {
  final List<Device> _devices = [
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

  List<Device> get devices => List.unmodifiable(_devices);

  void addDevice(Device device) {
    _devices.add(device);
    notifyListeners();
  }

  void updateDevice(Device updated) {
    final idx = _devices.indexWhere((d) => d.id == updated.id);
    if (idx != -1) {
      _devices[idx] = updated;
      notifyListeners();
    }
  }

  Device? findBySerial(String serial) {
    try {
      return _devices.firstWhere(
        (d) => d.serialNumber.toLowerCase() == serial.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<Device> search(String query) {
    return _devices.where((d) =>
      d.modelName.toLowerCase().contains(query.toLowerCase()) ||
      d.serialNumber.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
} 