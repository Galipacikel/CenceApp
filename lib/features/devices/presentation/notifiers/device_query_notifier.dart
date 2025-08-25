import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/features/forms/use_cases.dart';

class DeviceQueryState {
  final String query;
  final bool isLoading;
  final List<Device> searchResults;
  final List<Device> recent;

  const DeviceQueryState({
    required this.query,
    required this.isLoading,
    required this.searchResults,
    required this.recent,
  });

  factory DeviceQueryState.initial() => const DeviceQueryState(
        query: '',
        isLoading: false,
        searchResults: <Device>[],
        recent: <Device>[],
      );

  DeviceQueryState copyWith({
    String? query,
    bool? isLoading,
    List<Device>? searchResults,
    List<Device>? recent,
  }) {
    return DeviceQueryState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      searchResults: searchResults ?? this.searchResults,
      recent: recent ?? this.recent,
    );
  }
}

class DeviceQueryNotifier extends StateNotifier<DeviceQueryState> {
  DeviceQueryNotifier(this._ref) : super(DeviceQueryState.initial());

  final Ref _ref;
  Timer? _debounce;
  static const String _recentSearchesKey = 'recent_device_searches';

  Future<void> init() async {
    try {
      final box = await Hive.openBox('device_searches');
      final savedData = box.get(_recentSearchesKey, defaultValue: <Map>[]);
      if (savedData.isNotEmpty) {
        final recents = (savedData as List)
            .map<Device>((data) => Device.fromJson(Map<String, dynamic>.from(data as Map)))
            .toList();
        state = state.copyWith(recent: recents);
      }
    } catch (_) {
      // ignore errors, keep empty recents
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void onQueryChanged(String q) {
    state = state.copyWith(query: q);
    _debounce?.cancel();

    if (q.trim().length < 2) {
      state = state.copyWith(isLoading: false, searchResults: <Device>[]);
      return;
    }

    state = state.copyWith(isLoading: true);
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (q.trim().length < 2) {
        state = state.copyWith(isLoading: false, searchResults: <Device>[]);
        return;
      }
      try {
        final search = _ref.read(formsSearchUseCaseProvider);
        final results = await search(q.trim());
        state = state.copyWith(searchResults: results, isLoading: false);
      } catch (_) {
        state = state.copyWith(isLoading: false);
      }
    });
  }

  Future<void> addToRecents(Device device) async {
    try {
      final existing = state.recent.where((d) => d.serialNumber == device.serialNumber).isNotEmpty;
      List<Device> updated = List<Device>.from(state.recent);
      if (!existing) {
        updated.insert(0, device);
        if (updated.length > 5) {
          updated.removeLast();
        }
        state = state.copyWith(recent: updated);
        await _saveRecents(updated);
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> clearRecents() async {
    state = state.copyWith(recent: <Device>[]);
    try {
      final box = await Hive.openBox('device_searches');
      await box.delete(_recentSearchesKey);
    } catch (_) {
      // ignore
    }
  }

  Future<List<Device>> searchOnce(String q) async {
    final search = _ref.read(formsSearchUseCaseProvider);
    try {
      final results = await search(q.trim());
      return results;
    } catch (_) {
      return <Device>[];
    }
  }

  Future<void> _saveRecents(List<Device> recents) async {
    try {
      final box = await Hive.openBox('device_searches');
      final dataToSave = recents.map((d) => d.toJson()).toList();
      await box.put(_recentSearchesKey, dataToSave);
    } catch (_) {
      // ignore
    }
  }
}

final deviceQueryNotifierProvider =
    StateNotifierProvider<DeviceQueryNotifier, DeviceQueryState>((ref) {
  final notifier = DeviceQueryNotifier(ref);
  // Fire and forget
  notifier.init();
  return notifier;
});