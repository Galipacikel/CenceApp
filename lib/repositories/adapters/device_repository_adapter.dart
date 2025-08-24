import 'package:cence_app/core/error/failures.dart' as app;
import 'package:cence_app/domain/repositories/device_repository.dart' as v2;
import 'package:cence_app/models/device.dart';

class DeviceRepositoryAdapter implements DeviceRepository {
  final v2.DeviceRepositoryV2 _inner;
  DeviceRepositoryAdapter(this._inner);

  @override
  Future<List<Device>> getAll() async {
    final r = await _inner.getAll();
    return r.fold(
      onSuccess: (value) => value,
      onFailure: (err) => throw Exception(err.message),
    );
  }

  @override
  Future<void> add(Device device) async {
    final r = await _inner.add(device);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (err) => throw Exception(err.message),
    );
  }

  @override
  Future<void> update(Device device) async {
    final r = await _inner.update(device);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (err) => throw Exception(err.message),
    );
  }

  @override
  Future<void> delete(String id) async {
    final r = await _inner.delete(id);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (err) => throw Exception(err.message),
    );
  }

  @override
  Future<Device?> findById(String id) async {
    final r = await _inner.findById(id);
    return r.fold(
      onSuccess: (value) => value,
      onFailure: (err) {
        if (err is app.NotFoundFailure) return null;
        throw Exception(err.message);
      },
    );
  }
}