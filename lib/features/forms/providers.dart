import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/domain/repositories/forms_repository.dart';
import 'package:cence_app/repositories/forms_repository_v2.dart';
import 'package:cence_app/models/device.dart';

/// Repository provider
final formsRepositoryProvider = Provider<FormsRepositoryV2>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FormsRepositoryV2Impl(firestore: firestore);
});

/// Query tabanlı cihaz arama
final formsDeviceSearchProvider = FutureProvider.family<List<Device>, String>((
  ref,
  query,
) async {
  final repo = ref.watch(formsRepositoryProvider);
  final result = await repo.searchDevices(query);
  return result.fold(
    onSuccess: (list) => list,
    onFailure: (e) => throw Exception(e.message),
  );
});
