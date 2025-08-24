import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/domain/repositories/device_repository.dart';
import 'package:cence_app/repositories/firestore_device_repository_v2.dart';
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
