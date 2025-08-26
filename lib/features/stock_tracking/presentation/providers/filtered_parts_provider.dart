import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';

final criticalPartsProvider = FutureProvider<List<StockPart>>((ref) async {
  final inventoryState = ref.watch(inventoryProvider).value;
  final parts = inventoryState?.parts ?? [];
  return parts.where((p) => p.stokAdedi <= p.criticalLevel).toList();
});

final filteredPartsProvider = FutureProvider<List<StockPart>>((ref) async {
  final inventoryState = ref.watch(inventoryProvider).value;
  final parts = inventoryState?.parts ?? [];
  final query = inventoryState?.partSearch ?? '';
  final showOnlyCritical = inventoryState?.showOnlyCritical ?? false;

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

  if (!showOnlyCritical) return filtered;

  return filtered.where((p) => p.stokAdedi <= p.criticalLevel).toList();
});
