import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/features/service_history/presentation/providers/new_service_form_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/models/device.dart';

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
          brand: device.modelName,
          model: device.modelName,
          company: device.customer,
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
  void updatePhoto({Uint8List? bytes, XFile? file}) {
    _updateStateWithNewTabData(
      state.activeTabData.copyWith(photoBytes: bytes, photoFile: file),
    );
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

  // Aktif sekmeye göre ilgili tab verisini state'e uygula
  void _updateStateWithNewTabData(FormTabData newTabData) {
    if (state.formTipi == 0) {
      state = state.copyWith(kurulumData: newTabData);
    } else {
      state = state.copyWith(arizaData: newTabData);
    }
  }

  String _getTechnicianName() {
    // İleride auth/Firestore'dan çekilecek
    return '';
  }
}

final newServiceFormProvider = NotifierProvider<NewServiceFormNotifier, NewServiceFormState>(
  NewServiceFormNotifier.new,
);