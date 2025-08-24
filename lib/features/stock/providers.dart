import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/domain/repositories/stock_part_repository.dart';
import 'package:cence_app/repositories/firestore_stock_repository_v2.dart';
import 'package:cence_app/models/stock_part.dart';

/// Repository provider
final stockRepositoryProvider = Provider<StockPartRepositoryV2>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreStockRepositoryV2(firestore: firestore);
});

/// Parça listesi
final stockPartsProvider = FutureProvider<List<StockPart>>((ref) async {
  final repo = ref.watch(stockRepositoryProvider);
  final result = await repo.getAll();
  return result.fold(
    onSuccess: (list) => list,
    onFailure: (e) => throw Exception(e.message),
  );
});