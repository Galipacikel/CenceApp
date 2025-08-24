import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/device.dart';
import 'providers.dart';

/// Arama fonksiyonu use-case'i (callable function)
final formsSearchUseCaseProvider = Provider<Future<List<Device>> Function(String)>((ref) {
  final repo = ref.watch(formsRepositoryProvider);
  return (query) async {
    final r = await repo.searchDevices(query);
    return r.fold(
      onSuccess: (list) => list,
      onFailure: (e) => throw Exception(e.message),
    );
  };
});