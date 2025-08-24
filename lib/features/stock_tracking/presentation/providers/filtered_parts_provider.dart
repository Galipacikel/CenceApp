import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/features/stock/providers.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';

final criticalPartsProvider = FutureProvider<List<StockPart>>((ref) async {
  final parts = await ref.watch(stockPartsProvider.future);
  return parts.where((p) => p.stokAdedi <= p.criticalLevel).toList();
});

final filteredPartsProvider = FutureProvider<List<StockPart>>((ref) async {
  final parts = await ref.watch(stockPartsProvider.future);
  final query = ref.watch(inventoryProvider).value?.partSearch ?? '';
  final showOnlyCritical = ref.watch(inventoryProvider).value?.showOnlyCritical ?? false;

  final sortedParts = [
    ...parts.where((p) => p.stokAdedi == 0),
    ...parts.where((p) => p.stokAdedi > 0),
  ];

  final filtered = query.isEmpty
      ? sortedParts
      : sortedParts
          .where((p) => p.parcaAdi.toLowerCase().contains(query.toLowerCase()) ||
              p.parcaKodu.toLowerCase().contains(query.toLowerCase()))
          .toList();

  if (!showOnlyCritical) return filtered;

  final critical = await ref.watch(criticalPartsProvider.future);
  return critical;
});