import 'package:flutter/material.dart';
import 'package:cence_app/domain/repositories/device_repository.dart';
import '../models/device.dart';

class DeviceProvider extends ChangeNotifier {
  final List<Device> _devices = [];
  final DeviceRepositoryV2 _repository;
  String? _error;

  DeviceProvider({required DeviceRepositoryV2 repository})
    : _repository = repository;

  List<Device> get devices => List.unmodifiable(_devices);
  String? get error => _error;

  Future<void> fetchAll() async {
    final result = await _repository.getAll();
    result.fold(
      onSuccess: (list) {
        _devices
          ..clear()
          ..addAll(list);
        _error = null;
        notifyListeners();
      },
      onFailure: (failure) {
        _error = failure.message;
        notifyListeners();
      },
    );
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
