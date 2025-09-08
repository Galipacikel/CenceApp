import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/models/stock_part.dart';

part 'new_service_form_state.freezed.dart';

@freezed
class NewServiceFormState with _$NewServiceFormState {
  const factory NewServiceFormState({
    @Default(0) int formTipi,
    required FormTabData kurulumData,
    required FormTabData arizaData,
    @Default('') String technicianName,
    @Default(false) bool isSaving,
    @Default(false) bool lastSubmitSuccess,
  }) = _NewServiceFormState;
}

extension NewServiceFormStateX on NewServiceFormState {
  FormTabData get activeTabData => formTipi == 0 ? kurulumData : arizaData;
}

@freezed
class FormTabData with _$FormTabData {
  const factory FormTabData({
    // Cihaz ve Müşteri Bilgileri
    Device? selectedDevice,
    String? serialNumber,
    String? deviceName,
    String? brand,
    String? model,
    String? company,
    String? location,
    // Form Detayları
    DateTime? date,
    @Default('24') String warranty,
    String? description,

    // Fotoğraf (tek fotoğraf)
    Uint8List? photoBytes,
    XFile? photoFile,
    String? photoUrl, // Tek fotoğraf URL'si

    // Parçalar
    @Default(<SelectedPart>[]) List<SelectedPart> selectedParts,
  }) = _FormTabData;
}

@freezed
class SelectedPart with _$SelectedPart {
  const factory SelectedPart({
    required StockPart part,
    required int adet,
  }) = _SelectedPart;
}