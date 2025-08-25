import 'package:cence_app/domain/repositories/device_repository.dart';
import 'package:cence_app/models/device.dart';

/// Pure domain use-cases (no Riverpod, no presentation imports)
/// These classes encapsulate business actions and depend only on the domain repository interface.
class AddDeviceUseCase {
  AddDeviceUseCase(this._repo);
  final DeviceRepositoryV2 _repo;

  Future<void> call(Device device) async {
    final r = await _repo.add(device);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (e) => throw Exception(e.message),
    );
  }
}

class UpdateDeviceUseCase {
  UpdateDeviceUseCase(this._repo);
  final DeviceRepositoryV2 _repo;

  Future<void> call(Device device) async {
    final r = await _repo.update(device);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (e) => throw Exception(e.message),
    );
  }
}

class DeleteDeviceUseCase {
  DeleteDeviceUseCase(this._repo);
  final DeviceRepositoryV2 _repo;

  Future<void> call(String id) async {
    final r = await _repo.delete(id);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (e) => throw Exception(e.message),
    );
  }
}

class FindDeviceByIdUseCase {
  FindDeviceByIdUseCase(this._repo);
  final DeviceRepositoryV2 _repo;

  Future<Device> call(String id) async {
    final r = await _repo.findById(id);
    return r.fold(
      onSuccess: (d) => d,
      onFailure: (e) => throw Exception(e.message),
    );
  }
}
