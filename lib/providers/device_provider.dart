import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/device.dart';
import '../repositories/firestore_device_repository.dart';

class DeviceProvider extends ChangeNotifier {
  final List<Device> _devices = [];
  final FirestoreDeviceRepository _repository = FirestoreDeviceRepository();

  List<Device> get devices => List.unmodifiable(_devices);

  Future<void> fetchAll() async {
    final list = await _repository.getAll();
    _devices
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

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
      return _devices.firstWhere(
        (device) => device.serialNumber == serialNumber,
      );
    } catch (e) {
      return null;
    }
  }

  List<Device> search(String query) {
    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    return _devices
        .where(
          (device) =>
              device.modelName.toLowerCase().contains(lowercaseQuery) ||
              device.serialNumber.toLowerCase().contains(lowercaseQuery) ||
              device.customer.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
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
