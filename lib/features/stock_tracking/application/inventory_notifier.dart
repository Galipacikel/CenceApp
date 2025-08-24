import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/features/devices/providers.dart' as devices;
import 'package:cence_app/features/devices/use_cases.dart' as device_usecases;
import 'package:cence_app/features/stock/providers.dart' as stock;
import 'package:cence_app/core/providers/firebase_providers.dart';

class InventoryState {
  final List<Device> devices;
  final List<StockPart> parts;
  final String deviceSearch;
  final String partSearch;
  final bool showOnlyCritical;
  final bool showBanner;
  final int selectedTabIndex;
  final bool isAdmin;

  const InventoryState({
    required this.devices,
    required this.parts,
    this.deviceSearch = '',
    this.partSearch = '',
    this.showOnlyCritical = false,
    this.showBanner = true,
    this.selectedTabIndex = 0,
    this.isAdmin = false,
  });

  InventoryState copyWith({
    List<Device>? devices,
    List<StockPart>? parts,
    String? deviceSearch,
    String? partSearch,
    bool? showOnlyCritical,
    bool? showBanner,
    int? selectedTabIndex,
    bool? isAdmin,
  }) {
    return InventoryState(
      devices: devices ?? this.devices,
      parts: parts ?? this.parts,
      deviceSearch: deviceSearch ?? this.deviceSearch,
      partSearch: partSearch ?? this.partSearch,
      showOnlyCritical: showOnlyCritical ?? this.showOnlyCritical,
      showBanner: showBanner ?? this.showBanner,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class InventoryNotifier extends AsyncNotifier<InventoryState> {
  @override
  Future<InventoryState> build() async {
    final isAdmin = ref.watch(isAdminProvider);
    final devicesList = await ref.read(devices.devicesListProvider.future);
    final partsList = await ref.read(stock.stockPartsProvider.future);
    return InventoryState(
      devices: devicesList,
      parts: partsList,
      isAdmin: isAdmin,
    );
  }

  void setDeviceSearch(String value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(deviceSearch: value));
  }

  void setPartSearch(String value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(partSearch: value));
  }

  void toggleShowOnlyCritical() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(showOnlyCritical: !current.showOnlyCritical),
    );
  }

  void dismissBanner() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(showBanner: false));
  }

  void setTab(int index) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedTabIndex: index));
  }

  Future<bool> addDevice(Device device) async {
    final current = state.valueOrNull;
    if (current == null) return false;
    if (!current.isAdmin) return false;
    try {
      await ref.read(device_usecases.addDeviceUseCaseProvider)(device);
      // Refresh devices list
      final refreshed = await ref.read(devices.devicesListProvider.future);
      state = AsyncData(current.copyWith(devices: refreshed));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateDevice(Device device) async {
    final current = state.valueOrNull;
    if (current == null) return false;
    if (!current.isAdmin) return false;
    try {
      await ref.read(device_usecases.updateDeviceUseCaseProvider)(device);
      final refreshed = await ref.read(devices.devicesListProvider.future);
      state = AsyncData(current.copyWith(devices: refreshed));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDevice(String id) async {
    final current = state.valueOrNull;
    if (current == null) return false;
    if (!current.isAdmin) return false;
    try {
      await ref.read(device_usecases.deleteDeviceUseCaseProvider)(id);
      final refreshed = await ref.read(devices.devicesListProvider.future);
      state = AsyncData(current.copyWith(devices: refreshed));
      return true;
    } catch (_) {
      return false;
    }
  }
}

final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, InventoryState>(
      () => InventoryNotifier(),
    );
