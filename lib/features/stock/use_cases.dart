import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

/// Stok miktarı azaltma use-case'i
final decreaseStockUseCaseProvider = Provider<Future<void> Function(String partCode, int amount)>((ref) {
  final repo = ref.watch(stockRepositoryProvider);
  return (partCode, amount) async {
    final r = await repo.decreaseQuantity(partCode, amount);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (e) => throw Exception(e.message),
    );
  };
});