import 'package:cence_app/core/error/failures.dart' as app;
import 'package:cence_app/core/result/result.dart';
import 'package:cence_app/core/result/unit.dart';
import 'package:cence_app/models/stock_part.dart';

/// Domain arayüzü (Result tabanlı)
abstract class StockPartRepositoryV2 {
  Future<Result<List<StockPart>, app.Failure>> getAll();
  Future<Result<Unit, app.Failure>> decreaseQuantity(
    String partCode,
    int amount,
  );
  Future<Result<Unit, app.Failure>> add(StockPart part);
  Future<Result<Unit, app.Failure>> update(StockPart part);
  Future<Result<Unit, app.Failure>> delete(String partId);
}
