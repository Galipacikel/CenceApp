import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/features/devices/providers.dart' as devices;
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
    if (current == null || !current.isAdmin) return false;
    
    try {
      final repo = ref.read(devices.deviceRepositoryProvider);
      final result = await repo.add(device);
      
      if (result.isSuccess) {
        final updatedDevices = [...current.devices, device];
        state = AsyncData(current.copyWith(devices: updatedDevices));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateDevice(Device device) async {
    final current = state.valueOrNull;
    if (current == null || !current.isAdmin) return false;
    
    try {
      final repo = ref.read(devices.deviceRepositoryProvider);
      final result = await repo.update(device);
      
      if (result.isSuccess) {
        final updatedDevices = current.devices.map((d) => d.id == device.id ? device : d).toList();
        state = AsyncData(current.copyWith(devices: updatedDevices));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDevice(String id) async {
    final current = state.valueOrNull;
    if (current == null || !current.isAdmin) return false;
    
    try {
      final repo = ref.read(devices.deviceRepositoryProvider);
      final result = await repo.delete(id);
      
      if (result.isSuccess) {
        final updatedDevices = current.devices.where((d) => d.id != id).toList();
        state = AsyncData(current.copyWith(devices: updatedDevices));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addPart(StockPart part) async {
    final current = state.valueOrNull;
    if (current == null || !current.isAdmin) return false;
    
    try {
      final repo = ref.read(stock.stockRepositoryProvider);
      final result = await repo.add(part);
      
      if (result.isSuccess) {
        final updatedParts = [...current.parts, part];
        state = AsyncData(current.copyWith(parts: updatedParts));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePart(StockPart part) async {
    final current = state.valueOrNull;
    if (current == null || !current.isAdmin) return false;
    
    try {
      final repo = ref.read(stock.stockRepositoryProvider);
      final result = await repo.update(part);
      
      if (result.isSuccess) {
        final updatedParts = current.parts.map((p) => p.id == part.id ? part : p).toList();
        final criticalParts = updatedParts.where((p) => p.stokAdedi <= p.criticalLevel).toList();
        final shouldShowOnlyCritical = current.showOnlyCritical && criticalParts.isNotEmpty;
        
        state = AsyncData(current.copyWith(
          parts: updatedParts,
          showOnlyCritical: shouldShowOnlyCritical,
        ));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePart(String partId) async {
    final current = state.valueOrNull;
    if (current == null || !current.isAdmin) return false;
    
    try {
      final repo = ref.read(stock.stockRepositoryProvider);
      final result = await repo.delete(partId);
      
      if (result.isSuccess) {
        final updatedParts = current.parts.where((p) => p.id != partId).toList();
        final criticalParts = updatedParts.where((p) => p.stokAdedi <= p.criticalLevel).toList();
        final shouldShowOnlyCritical = current.showOnlyCritical && criticalParts.isNotEmpty;
        
        state = AsyncData(current.copyWith(
          parts: updatedParts,
          showOnlyCritical: shouldShowOnlyCritical,
        ));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

final inventoryProvider = AsyncNotifierProvider<InventoryNotifier, InventoryState>(
  () => InventoryNotifier(),
);
