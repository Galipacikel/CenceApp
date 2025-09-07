import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';

final filteredDevicesProvider = Provider<AsyncValue<List<Device>>>((ref) {
  final inventoryState = ref.watch(inventoryProvider);
  
  return inventoryState.when(
    data: (state) {
      final devices = state.devices;
      final query = state.deviceSearch;

      // Basit sıralama
      final sorted = [...devices]..sort((a, b) => a.modelName.compareTo(b.modelName));

      if (query.isEmpty) return AsyncData(sorted);
      final q = query.toLowerCase();
      final filtered = sorted
          .where((d) => d.modelName.toLowerCase().contains(q) || d.serialNumber.toLowerCase().contains(q))
          .toList();
      return AsyncData(filtered);
    },
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
  );
});
