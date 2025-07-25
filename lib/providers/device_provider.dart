import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
      warrantyEndDate: DateTime(2025, 1, 15),
    ),
    Device(
      id: 'CİHAZ-002',
      modelName: 'Kalp Şok Cihazı Pro-500',
      serialNumber: 'SN-B67890',
      customer: 'Medipol Kliniği',
      installDate: '10.03.2022',
      warrantyStatus: 'Bitti',
      lastMaintenance: '10.03.2023',
      warrantyEndDate: DateTime(2024, 3, 10),
    ),
    Device(
      id: 'CİHAZ-003',
      modelName: 'EKG Monitörü Card-10',
      serialNumber: 'SN-C13579',
      customer: 'Şifa Sağlık Merkezi',
      installDate: '20.06.2021',
      warrantyStatus: 'Devam Ediyor',
      lastMaintenance: '20.06.2023',
      warrantyEndDate: DateTime(2025, 6, 20),
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
      warrantyEndDate: DateTime(2024, 9, 5),
    ),
    Device(
      id: 'CİHAZ-005',
      modelName: 'EKG Monitörü Card-10',
      serialNumber: 'SN-C35791',
      customer: 'Liv Hastanesi',
      installDate: '12.11.2021',
      warrantyStatus: 'Bitti',
      lastMaintenance: '12.11.2022',
      warrantyEndDate: DateTime(2023, 11, 12),
    ),
    Device(
      id: 'CİHAZ-006',
      modelName: 'Solunum Cihazı X-2000',
      serialNumber: 'SN-A24680',
      customer: 'Anadolu Sağlık Merkezi',
      installDate: '08.04.2023',
      warrantyStatus: 'Devam Ediyor',
      lastMaintenance: '08.04.2024',
      warrantyEndDate: DateTime(2025, 4, 8),
    ),
    Device(
      id: 'CİHAZ-007',
      modelName: 'Kalp Şok Cihazı Pro-500',
      serialNumber: 'SN-B13579',
      customer: 'Koç Üniversitesi Hastanesi',
      installDate: '25.07.2022',
      warrantyStatus: 'Devam Ediyor',
      lastMaintenance: '25.07.2023',
      warrantyEndDate: DateTime(2024, 7, 25),
    ),
    Device(
      id: 'CİHAZ-008',
      modelName: 'Kalp Şok Cihazı Pro-500',
      serialNumber: 'SN-B24680',
      customer: 'Hacettepe Üniversitesi Hastanesi',
      installDate: '03.12.2021',
      warrantyStatus: 'Bitti',
      lastMaintenance: '03.12.2022',
      warrantyEndDate: DateTime(2023, 12, 3),
    ),
  ];

  List<Device> get devices => List.unmodifiable(_devices);

  void addDevice(Device device) {
    _devices.insert(0, device);
    notifyListeners();
  }

  void updateDevice(Device device) {
    final index = _devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      _devices[index] = device;
      notifyListeners();
    }
  }

  void removeDevice(String deviceId) {
    _devices.removeWhere((d) => d.id == deviceId);
    notifyListeners();
  }

  Device? findBySerial(String serialNumber) {
    try {
      return _devices.firstWhere((device) => device.serialNumber == serialNumber);
    } catch (e) {
      return null;
    }
  }

  List<Device> search(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return _devices.where((device) =>
      device.modelName.toLowerCase().contains(lowercaseQuery) ||
      device.serialNumber.toLowerCase().contains(lowercaseQuery) ||
      device.customer.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Model bazında gruplandırma
  Map<String, List<Device>> getDevicesByModel() {
    final grouped = <String, List<Device>>{};
    for (final device in _devices) {
      if (grouped.containsKey(device.modelName)) {
        grouped[device.modelName]!.add(device);
      } else {
        grouped[device.modelName] = [device];
      }
    }
    return grouped;
  }

  // Müşteri bazında gruplandırma
  Map<String, List<Device>> getDevicesByCustomer() {
    final grouped = <String, List<Device>>{};
    for (final device in _devices) {
      if (grouped.containsKey(device.customer)) {
        grouped[device.customer]!.add(device);
      } else {
        grouped[device.customer] = [device];
      }
    }
    return grouped;
  }

  // Belirli bir modelin tüm cihazlarını getir
  List<Device> getDevicesByModelName(String modelName) {
    return _devices.where((device) => device.modelName == modelName).toList();
  }

  // Belirli bir müşterinin tüm cihazlarını getir
  List<Device> getDevicesByCustomerName(String customerName) {
    return _devices.where((device) => device.customer == customerName).toList();
  }

  // Benzersiz cihaz sayısı (modelName+serialNumber ile)
  int get uniqueDeviceCount {
    final unique = <String>{};
    for (final d in _devices) {
      unique.add('${d.modelName}_${d.serialNumber}');
    }
    return unique.length;
  }
} 