import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/features/devices/presentation/providers.dart';

/// Cihaz ekleme use-case'i
final addDeviceUseCaseProvider = Provider<Future<void> Function(Device)>((ref) {
  final repo = ref.watch(deviceRepositoryProvider);
  return (device) async {
    final r = await repo.add(device);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (e) => throw Exception(e.message),
    );
  };
});

/// Cihaz güncelleme use-case'i
final updateDeviceUseCaseProvider = Provider<Future<void> Function(Device)>((
  ref,
) {
  final repo = ref.watch(deviceRepositoryProvider);
  return (device) async {
    final r = await repo.update(device);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (e) => throw Exception(e.message),
    );
  };
});

/// Cihaz silme use-case'i
final deleteDeviceUseCaseProvider = Provider<Future<void> Function(String)>((
  ref,
) {
  final repo = ref.watch(deviceRepositoryProvider);
  return (id) async {
    final r = await repo.delete(id);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (e) => throw Exception(e.message),
    );
  };
});

/// ID ile cihaz bulma use-case'i
final findDeviceByIdUseCaseProvider = Provider<Future<Device> Function(String)>(
  (ref) {
    final repo = ref.watch(deviceRepositoryProvider);
    return (id) async {
      final r = await repo.findById(id);
      return r.fold(
        onSuccess: (d) => d,
        onFailure: (e) => throw Exception(e.message),
      );
    };
  },
);
