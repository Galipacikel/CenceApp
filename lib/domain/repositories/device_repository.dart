import 'package:cence_app/core/error/failures.dart' as app;
import 'package:cence_app/core/result/result.dart';
import 'package:cence_app/core/result/unit.dart';
import 'package:cence_app/models/device.dart';

/// Domain arayüzü (Result tabanlı)
abstract class DeviceRepositoryV2 {
  Future<Result<List<Device>, app.Failure>> getAll();
  Future<Result<Unit, app.Failure>> add(Device device);
  Future<Result<Unit, app.Failure>> update(Device device);
  Future<Result<Unit, app.Failure>> delete(String id);
  Future<Result<Device, app.Failure>> findById(String id);
}
