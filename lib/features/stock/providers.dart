import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/domain/repositories/stock_part_repository.dart';
import 'package:cence_app/repositories/firestore_stock_repository_v2.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';

/// Repository provider
final stockRepositoryProvider = Provider<StockPartRepositoryV2>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreStockRepositoryV2(firestore: firestore);
});

/// Parça listesi - inventoryProvider'dan alır
final stockPartsProvider = Provider<AsyncValue<List<StockPart>>>((ref) {
  final inventoryAsync = ref.watch(inventoryProvider);
  return inventoryAsync.when(
    data: (state) => AsyncData(state.parts),
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
  );
});
