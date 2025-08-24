import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/domain/repositories/device_repository.dart';
import 'package:cence_app/features/devices/data/repositories/device_repository_impl.dart';
import 'package:cence_app/features/devices/domain/use_cases.dart';
import 'package:cence_app/models/device.dart';

/// Repository provider
final deviceRepositoryProvider = Provider<DeviceRepositoryV2>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreDeviceRepositoryV2(firestore: firestore);
});

/// Cihaz listesi (okuma)
final devicesListProvider = FutureProvider<List<Device>>((ref) async {
  final repo = ref.watch(deviceRepositoryProvider);
  final result = await repo.getAll();
  return result.fold(
    onSuccess: (list) => list,
    onFailure: (e) => throw Exception(e.message),
  );
});

/// Arama için yardımcı provider (query -> filtreli liste)
final devicesSearchProvider = Provider.family<List<Device>, String>((
  ref,
  query,
) {
  final asyncDevices = ref.watch(devicesListProvider);
  return asyncDevices.maybeWhen(
    data: (devices) {
      if (query.isEmpty) return devices;
      final q = query.toLowerCase();
      return devices
          .where(
            (d) =>
                d.modelName.toLowerCase().contains(q) ||
                d.serialNumber.toLowerCase().contains(q) ||
                d.customer.toLowerCase().contains(q),
          )
          .toList();
    },
    orElse: () => const <Device>[],
  );
});

// Use-case Providers (presentation wrappers)
final addDeviceUseCaseProvider = Provider<Future<void> Function(Device)>((ref) {
  final repo = ref.watch(deviceRepositoryProvider);
  return (device) async {
    // Using pure domain use-case
    final usecase = AddDeviceUseCase(repo);
    return usecase(device);
  };
});

final updateDeviceUseCaseProvider = Provider<Future<void> Function(Device)>((ref) {
  final repo = ref.watch(deviceRepositoryProvider);
  return (device) async {
    final usecase = UpdateDeviceUseCase(repo);
    return usecase(device);
  };
});

final deleteDeviceUseCaseProvider = Provider<Future<void> Function(String)>((ref) {
  final repo = ref.watch(deviceRepositoryProvider);
  return (id) async {
    final usecase = DeleteDeviceUseCase(repo);
    return usecase(id);
  };
});

final findDeviceByIdUseCaseProvider = Provider<Future<Device> Function(String)>((ref) {
  final repo = ref.watch(deviceRepositoryProvider);
  return (id) async {
    final usecase = FindDeviceByIdUseCase(repo);
    return usecase(id);
  };
});