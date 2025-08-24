import 'package:cence_app/domain/repositories/stock_part_repository.dart' as v2;
import 'package:cence_app/models/stock_part.dart';

class StockPartRepositoryAdapter implements StockPartRepository {
  final v2.StockPartRepositoryV2 _inner;
  StockPartRepositoryAdapter(this._inner);

  @override
  Future<List<StockPart>> getAll() async {
    final r = await _inner.getAll();
    return r.fold(
      onSuccess: (value) => value,
      onFailure: (err) => throw Exception(err.message),
    );
  }

  @override
  Future<void> decreaseQuantity(String partCode, int amount) async {
    final r = await _inner.decreaseQuantity(partCode, amount);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (err) => throw Exception(err.message),
    );
  }
}
