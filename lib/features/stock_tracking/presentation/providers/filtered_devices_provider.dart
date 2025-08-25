import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/features/devices/providers.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';

final filteredDevicesProvider = FutureProvider<List<Device>>((ref) async {
  final allDevices = await ref.watch(devicesListProvider.future);
  final query = ref.watch(inventoryProvider).value?.deviceSearch ?? '';

  // Unique by modelName + serialNumber
  final uniqueKeys = <String>{};
  final uniqueDevices = <Device>[];
  for (final d in allDevices) {
    final key = '${d.modelName}_${d.serialNumber}';
    if (!uniqueKeys.contains(key)) {
      uniqueKeys.add(key);
      uniqueDevices.add(d);
    }
  }

  uniqueDevices.sort((a, b) => a.modelName.compareTo(b.modelName));

  if (query.isEmpty) return uniqueDevices;
  final q = query.toLowerCase();
  return uniqueDevices
      .where((d) => d.modelName.toLowerCase().contains(q))
      .toList();
});
