import 'package:cence_app/domain/repositories/forms_repository.dart' as v2;
import 'package:cence_app/models/device.dart';
import 'package:cence_app/repositories/forms_repository.dart' show FormsRepositoryBase;

class FormsRepositoryAdapter implements FormsRepositoryBase {
  final v2.FormsRepositoryV2 _inner;
  FormsRepositoryAdapter(this._inner);

  @override
  Future<List<Device>> searchDevices(String text) async {
    final r = await _inner.searchDevices(text);
    return r.fold(
      onSuccess: (value) => value,
      onFailure: (err) => throw Exception(err.message),
    );
  }
}