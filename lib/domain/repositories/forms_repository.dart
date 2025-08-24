import 'package:cence_app/core/error/failures.dart' as app;
import 'package:cence_app/core/result/result.dart';
import 'package:cence_app/models/device.dart';

/// Domain arayüzü (Result tabanlı)
abstract class FormsRepositoryV2 {
  Future<Result<List<Device>, app.Failure>> searchDevices(String text);
}