import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/features/service_history/presentation/providers/new_service_form_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/models/service_history.dart';
import 'package:cence_app/features/service_history/use_cases.dart';
import 'package:cence_app/features/service_history/providers.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';
import 'package:cence_app/features/devices/presentation/providers.dart';
import 'package:cence_app/services/storage_service.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';

class NewServiceFormNotifier extends Notifier<NewServiceFormState> {
  @override
  NewServiceFormState build() {
    // Başlangıç state'i: Kurulum sekmesi bugünün tarihiyle başlasın
    return NewServiceFormState(
      kurulumData: FormTabData(date: DateTime.now()),
      arizaData: const FormTabData(),
      technicianName: _getTechnicianName(),
    );
  }

  // Form tipi değiştir
  void setFormType(int type) {
    state = state.copyWith(formTipi: type);
  }

  // Tarih güncelle
  void updateDate(DateTime newDate) {
    _updateStateWithNewTabData(state.activeTabData.copyWith(date: newDate));
  }

  // Garanti süresi güncelle
  void updateWarranty(String months) {
    _updateStateWithNewTabData(state.activeTabData.copyWith(warranty: months));
  }

  // Açıklama güncelle
  void updateDescription(String? description) {
    _updateStateWithNewTabData(state.activeTabData.copyWith(description: description));
  }

  // Cihaz/Müşteri alanlarını güncelle
  void updateDeviceFields({
    String? serialNumber,
    String? deviceName,
    String? brand,
    String? model,
    String? company,
    String? location,
  }) {
    final t = state.activeTabData.copyWith(
      serialNumber: serialNumber ?? state.activeTabData.serialNumber,
      deviceName: deviceName ?? state.activeTabData.deviceName,
      brand: brand ?? state.activeTabData.brand,
      model: model ?? state.activeTabData.model,
      company: company ?? state.activeTabData.company,
      location: location ?? state.activeTabData.location,
    );
    _updateStateWithNewTabData(t);
  }

  // Seçili cihazı ayarla/temizle
  void setSelectedDevice(Device? device) {
    if (device == null) {
      _updateStateWithNewTabData(
        state.activeTabData.copyWith(
          selectedDevice: null,
          serialNumber: '',
          deviceName: '',
          brand: '',
          model: '',
          company: '',
          location: '',
        ),
      );
    } else {
      _updateStateWithNewTabData(
        state.activeTabData.copyWith(
          selectedDevice: device,
          serialNumber: device.serialNumber,
          deviceName: device.modelName,
          // brand ve model'i veritabanındaki değerlerle eşle: modelName'i ilk boşlukta ayır
          brand: (() {
            final full = (device.modelName).trim();
            final idx = full.indexOf(' ');
            return idx == -1 ? full : full.substring(0, idx).trim();
          })(),
          model: (() {
            final full = (device.modelName).trim();
            final idx = full.indexOf(' ');
            return idx == -1 ? '' : full.substring(idx + 1).trim();
          })(),
          // Otomatik girişte firma alanı otomatik dolmasın; mevcut değeri koru
          company: state.activeTabData.company,
          // location bilgisi cihaz modelinde olmayabilir, mevcutu koru
          location: state.activeTabData.location,
        ),
      );
    }
  }

  // Teknisyen adını güncelle
  void setTechnicianName(String name) {
    state = state.copyWith(technicianName: name);
  }

  // Fotoğraf güncelle
  Future<void> updatePhoto({Uint8List? bytes, XFile? file}) async {
    if (file == null) {
      _updateStateWithNewTabData(
        state.activeTabData.copyWith(photoBytes: bytes, photoFile: file),
      );
      return;
    }

    try {
      final storageService = StorageService();
      final storagePath = 'service_photos/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final downloadUrl = await storageService.uploadFile(
        file: file,
        storagePath: storagePath,
      );

      final currentPhotos = state.activeTabData.uploadedPhotos;
      final updatedPhotos = List<String>.from(currentPhotos)..add(downloadUrl);

      _updateStateWithNewTabData(
        state.activeTabData.copyWith(
          photoBytes: bytes,
          photoFile: file,
          uploadedPhotos: updatedPhotos,
        ),
      );
    } catch (e) {
      _updateStateWithNewTabData(
        state.activeTabData.copyWith(photoBytes: bytes, photoFile: file),
      );
    }
  }

  // Parça ekle/güncelle
  void addOrUpdatePart(StockPart part, int adet) {
    final parts = [...state.activeTabData.selectedParts];
    final idx = parts.indexWhere((sp) => sp.part.parcaKodu == part.parcaKodu);
    if (idx >= 0) {
      parts[idx] = parts[idx].copyWith(adet: adet);
    } else {
      parts.add(SelectedPart(part: part, adet: adet));
    }
    _updateStateWithNewTabData(state.activeTabData.copyWith(selectedParts: parts));
  }

  // Parça sil
  void removePart(StockPart part) {
    final parts = state.activeTabData.selectedParts
        .where((sp) => sp.part.parcaKodu != part.parcaKodu)
        .toList();
    _updateStateWithNewTabData(state.activeTabData.copyWith(selectedParts: parts));
  }

  // Form submit (eski ekran akışıyla uyum için dış aksiyonla)
  Future<bool> submitWithAction(Future<void> Function() action) async {
    state = state.copyWith(isSaving: true, lastSubmitSuccess: false);
    try {
      await action();
      state = state.copyWith(isSaving: false, lastSubmitSuccess: true);
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false, lastSubmitSuccess: false);
      rethrow;
    }
  }

  // Form submit (no external action)
  Future<bool> submitForm() async {
    state = state.copyWith(isSaving: true, lastSubmitSuccess: false);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(isSaving: false, lastSubmitSuccess: true);
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false, lastSubmitSuccess: false);
      rethrow;
    }
  }

  // ServiceHistory kaydet ve stok düş: submit akışını merkezi hale getirir
  Future<void> saveHistoryAndDeductStock(ServiceHistory history) async {
    state = state.copyWith(isSaving: true, lastSubmitSuccess: false);
    try {
      // 1) Servis kaydını ekle
      await ref.read(addServiceHistoryUseCaseProvider)(history);

      // 2) Stok düş
      final providerParts = state.activeTabData.selectedParts;
      if (providerParts.isNotEmpty) {
        final updateTasks = providerParts
            .where((selectedPart) => selectedPart.part.id.isNotEmpty)
            .map((selectedPart) async {
          final part = selectedPart.part;
          final usedQuantity = selectedPart.adet;
          final currentStock = part.stokAdedi;
          final newStock = currentStock - usedQuantity; // negatif değerlere izin ver

          final updatedPart = StockPart(
            id: part.id,
            parcaAdi: part.parcaAdi,
            parcaKodu: part.parcaKodu,
            stokAdedi: newStock,
            criticalLevel: part.criticalLevel,
          );

          // 2a) UI'da anında yansıt (optimistic update)
          ref.read(inventoryProvider.notifier).decreaseQuantityLocal(part.id, usedQuantity);
          // 2b) Veritabanını güncelle
          return ref.read(inventoryProvider.notifier).updatePart(updatedPart);
        }).toList();
        await Future.wait(updateTasks);
      }

      // 3) Liste sağlayıcılarını tazele
      ref.invalidate(serviceHistoryListProvider);
      ref.invalidate(recentServiceHistoryProvider(3));
      ref.invalidate(devicesListProvider);

      state = state.copyWith(isSaving: false, lastSubmitSuccess: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, lastSubmitSuccess: false);
      rethrow;
    }
  }

  // Aktif sekmeye göre ilgili tab verisini state'e uygula
  void _updateStateWithNewTabData(FormTabData newTabData) {
    if (state.formTipi == 0) {
      state = state.copyWith(kurulumData: newTabData);
    } else {
      state = state.copyWith(arizaData: newTabData);
    }
  }

  String _getTechnicianName() {
    // Giriş yapan kullanıcının username'ini döndür
    final asyncUser = ref.read(appUserProvider);
    return asyncUser.maybeWhen(
      data: (user) => user?.username ?? '',
      orElse: () => '',
    );
  }

  // Teknisyen adını başlangıçta yüklemek için
  void initializeTechnicianName() {
    // Bu metod screen'den çağrılacak
    final technicianName = _getTechnicianName();
    state = state.copyWith(technicianName: technicianName);
  }
}

final newServiceFormProvider = NotifierProvider<NewServiceFormNotifier, NewServiceFormState>(
  NewServiceFormNotifier.new,
);