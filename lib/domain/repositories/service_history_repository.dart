import 'package:cence_app/core/error/failures.dart' as app;
import 'package:cence_app/core/result/result.dart';
import 'package:cence_app/core/result/unit.dart';
import 'package:cence_app/models/service_history.dart';

/// Domain arayüzü (Result tabanlı)
abstract class ServiceHistoryRepositoryV2 {
  Future<Result<List<ServiceHistory>, app.Failure>> getAll();
  Future<Result<List<ServiceHistory>, app.Failure>> getRecent({int count = 3});
  Future<Result<Unit, app.Failure>> add(ServiceHistory history);
  Future<Result<Unit, app.Failure>> update(String id, ServiceHistory history);
  Future<Result<Unit, app.Failure>> delete(String id);
}