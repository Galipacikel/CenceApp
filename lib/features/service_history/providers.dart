import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/domain/repositories/service_history_repository.dart';
import 'package:cence_app/repositories/firestore_service_history_repository_v2.dart';
import 'package:cence_app/repositories/firestore_formlar_repository.dart';
import 'package:cence_app/models/service_history.dart';

/// Repository provider
final serviceHistoryRepositoryProvider = Provider<ServiceHistoryRepositoryV2>((
  ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreServiceHistoryRepositoryV2(firestore: firestore);
});

/// Formlar Repository provider
final formlarRepositoryProvider = Provider<FirestoreFormlarRepository>((
  ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreFormlarRepository(firestore: firestore);
});

/// Tüm servis kayıtları
final serviceHistoryListProvider = FutureProvider<List<ServiceHistory>>((
  ref,
) async {
  final repo = ref.watch(serviceHistoryRepositoryProvider);
  final result = await repo.getAll();
  return result.fold(
    onSuccess: (list) => list,
    onFailure: (e) => throw Exception(e.message),
  );
});

/// Formlar listesi
final formlarListProvider = FutureProvider<List<ServiceHistory>>((ref) async {
  final repo = ref.watch(formlarRepositoryProvider);
  final result = await repo.getAll();
  return result.fold(
    onSuccess: (list) => list,
    onFailure: (e) => throw Exception(e.toString()),
  );
});

/// Son N kayıt
final recentServiceHistoryProvider =
    FutureProvider.family<List<ServiceHistory>, int>((ref, count) async {
      final repo = ref.watch(serviceHistoryRepositoryProvider);
      final result = await repo.getRecent(count: count);
      return result.fold(
        onSuccess: (list) => list,
        onFailure: (e) => throw Exception(e.message),
      );
    });
