import 'package:cence_app/domain/repositories/service_history_repository.dart' as v2;
import 'package:cence_app/models/service_history.dart';

class ServiceHistoryRepositoryAdapter implements ServiceHistoryRepository {
  final v2.ServiceHistoryRepositoryV2 _inner;
  ServiceHistoryRepositoryAdapter(this._inner);

  @override
  Future<void> add(ServiceHistory history) async {
    final r = await _inner.add(history);
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
  Future<List<ServiceHistory>> getAll() async {
    final r = await _inner.getAll();
    return r.fold(
      onSuccess: (value) => value,
      onFailure: (err) => throw Exception(err.message),
    );
  }

  @override
  Future<List<ServiceHistory>> getRecent({int count = 3}) async {
    final r = await _inner.getRecent(count: count);
    return r.fold(
      onSuccess: (value) => value,
      onFailure: (err) => throw Exception(err.message),
    );
  }

  @override
  Future<void> update(String id, ServiceHistory history) async {
    final r = await _inner.update(id, history);
    r.fold(
      onSuccess: (_) => null,
      onFailure: (err) => throw Exception(err.message),
    );
  }
}