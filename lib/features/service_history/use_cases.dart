import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/service_history.dart';
import 'providers.dart';

/// Servis kaydı ekleme use-case'i
final addServiceHistoryUseCaseProvider =
    Provider<Future<void> Function(ServiceHistory)>((ref) {
      final repo = ref.watch(serviceHistoryRepositoryProvider);
      return (history) async {
        final r = await repo.add(history);
        r.fold(
          onSuccess: (_) => null,
          onFailure: (e) => throw Exception(e.message),
        );
      };
    });

/// Servis kaydı güncelleme use-case'i
final updateServiceHistoryUseCaseProvider =
    Provider<Future<void> Function(String, ServiceHistory)>((ref) {
      final repo = ref.watch(serviceHistoryRepositoryProvider);
      return (id, history) async {
        final r = await repo.update(id, history);
        r.fold(
          onSuccess: (_) => null,
          onFailure: (e) => throw Exception(e.message),
        );
      };
    });

/// Servis kaydı silme use-case'i
final deleteServiceHistoryUseCaseProvider =
    Provider<Future<void> Function(String)>((ref) {
      final repo = ref.watch(serviceHistoryRepositoryProvider);
      return (id) async {
        final r = await repo.delete(id);
        r.fold(
          onSuccess: (_) => null,
          onFailure: (e) => throw Exception(e.message),
        );
      };
    });
