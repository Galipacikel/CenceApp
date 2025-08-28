import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';

final criticalPartsProvider = Provider<AsyncValue<List<StockPart>>>((ref) {
  final inventoryState = ref.watch(inventoryProvider);
  
  return inventoryState.when(
    data: (state) {
      final criticalParts = state.parts.where((p) => p.stokAdedi <= p.criticalLevel).toList();
      return AsyncData(criticalParts);
    },
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
  );
});

final filteredPartsProvider = Provider<AsyncValue<List<StockPart>>>((ref) {
  final inventoryState = ref.watch(inventoryProvider);
  
  return inventoryState.when(
    data: (state) {
      final parts = state.parts;
      final query = state.partSearch;
      final showOnlyCritical = state.showOnlyCritical;

      final sortedParts = [
        ...parts.where((p) => p.stokAdedi == 0),
        ...parts.where((p) => p.stokAdedi > 0),
      ];

      final filtered = query.isEmpty
          ? sortedParts
          : sortedParts
                .where(
                  (p) =>
                      p.parcaAdi.toLowerCase().contains(query.toLowerCase()) ||
                      p.parcaKodu.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

      if (!showOnlyCritical) return AsyncData(filtered);

      final critical = parts.where((p) => p.stokAdedi <= p.criticalLevel).toList();
      return AsyncData(critical);
    },
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
  );
});
