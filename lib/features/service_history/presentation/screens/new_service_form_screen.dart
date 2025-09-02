import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/features/service_history/use_cases.dart';
import 'package:cence_app/services/storage_service.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/models/service_history.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/widgets/service/form_sections/device_selection_section.dart';
import 'package:cence_app/widgets/service/form_sections/customer_info_section.dart';
import 'package:cence_app/widgets/service/form_widgets/form_type_selection.dart';
import 'package:cence_app/widgets/service/form_widgets/submit_button.dart';
import 'package:cence_app/features/service_history/application/new_service_form_notifier.dart';
import 'package:cence_app/features/service_history/presentation/providers/new_service_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:cence_app/features/devices/providers.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';
import 'package:cence_app/features/devices/use_cases.dart';
import 'package:cence_app/features/service_history/presentation/widgets/photo_picker.dart';
import 'package:cence_app/features/service_history/providers.dart';
import 'package:cence_app/widgets/service/form_sections/used_parts_section.dart';

class NewServiceFormScreen extends rp.ConsumerStatefulWidget {
  const NewServiceFormScreen({super.key});

  @override
  rp.ConsumerState<NewServiceFormScreen> createState() =>
      _NewServiceFormScreenState();
}

// Removed local SelectedPart; using provider SelectedPart from new_service_form_state.dart

// Tab bazlı cihaz alanı state'i için küçük bir veri sınıfı
class DeviceFormData {
  Device? selectedDevice;
  String serialNumber;
  String deviceName;
  String brand;
  String model;
  String company;
  String location;

  DeviceFormData({
    this.selectedDevice,
    this.serialNumber = '',
    this.deviceName = '',
    this.brand = '',
    this.model = '',
    this.company = '',
    this.location = '',
  });

  factory DeviceFormData.empty() => DeviceFormData();
}

class _NewServiceFormScreenState
    extends rp.ConsumerState<NewServiceFormScreen> {
  int _formTipi = 0;
  final TextEditingController _technicianController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _date;
  late TextEditingController _dateController;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  final TextEditingController _warrantyDurationController = TextEditingController();
  // final TextEditingController _partSearchController = TextEditingController();
  // List<StockPart> _allParts = [];
  // List<StockPart> _filteredParts = [];
  // bool _showOtherPartInput = false;
  // final TextEditingController _otherPartNameController = TextEditingController();
  // final TextEditingController _otherPartQuantityController = TextEditingController();
  Device? _selectedDevice;
  final TextEditingController _deviceSearchController = TextEditingController();
  List<Device> _allDevices = [];
  List<Device> _filteredDevices = [];
  bool _showDeviceSuggestions = false;
  // Her sekme için cihaz alanları state'i
  late Map<int, DeviceFormData> _tabDeviceData;
  // Her sekme için diğer form state'leri
  late Map<int, String> _tabDescription;
  late Map<int, DateTime?> _tabDate;
  late Map<int, String> _tabWarranty;
  late Map<int, Uint8List?> _tabPhotoBytes;
  late Map<int, XFile?> _tabPhotoFile;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _warrantyDurationController.text = '24';
    // Provider state'ine başlangıç garanti süresini de yaz
    try {
      ref
          .read(newServiceFormProvider.notifier)
          .updateWarranty(_warrantyDurationController.text);
    } catch (_) {}
    
    // Tab bazlı state'i başlat
    _tabDeviceData = {
      0: DeviceFormData.empty(),
      1: DeviceFormData.empty(),
      2: DeviceFormData.empty(),
    };
    _tabDescription = {0: '', 1: '', 2: ''};
    _tabDate = {0: null, 1: null, 2: null};
    _tabWarranty = {0: '24', 1: '24', 2: '24'};
    _tabPhotoBytes = {0: null, 1: null, 2: null};
    _tabPhotoFile = {0: null, 1: null, 2: null};
    
    // Otomatik olarak bugünün tarihini ata
    _date = DateTime.now();
    _updateDateController();
    _tabDate[_formTipi] = _date; // aktif sekmeye başlangıç tarihi yaz
    // Provider state'ini de güncelle
    try {
      if (_date != null) {
        ref.read(newServiceFormProvider.notifier).updateDate(_date!);
      }
    } catch (_) {}
    

    final devicesAsync = ref.read(devicesListProvider);
    devicesAsync.when(
      data: (devices) {
        setState(() {
          _allDevices = devices;
          _filteredDevices = devices;
        });
      },
      loading: () {},
      error: (e, st) {},
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _technicianController.text = _getTechnicianName();
      // Notifier state'ine teknisyen adını yaz
      try {
        final tech = _technicianController.text.trim();
        if (tech.isNotEmpty) {
          ref.read(newServiceFormProvider.notifier).setTechnicianName(tech);
        }
      } catch (_) {}
      // İlk sekmenin state'ini controller'lara yükle
      _loadCurrentTabAll();
    });
  }

  // Aktif sekmedeki controller içeriklerini sekmeye özgü state'e kaydet (tüm alanlar)
  void _saveCurrentTabAll() {
    final t = _tabDeviceData[_formTipi]!;
    t.selectedDevice = _selectedDevice;
    t.serialNumber = _serialNumberController.text;
    t.deviceName = _deviceNameController.text;
    t.brand = _brandController.text;
    t.model = _modelController.text;
    t.company = _companyController.text;
    t.location = _locationController.text;

    _tabDescription[_formTipi] = _descriptionController.text;
    _tabDate[_formTipi] = _date;
    _tabWarranty[_formTipi] = _warrantyDurationController.text;
    _tabPhotoBytes[_formTipi] = _pickedImageBytes;
    _tabPhotoFile[_formTipi] = _pickedImage;
  }

  // Aktif sekme için kayıtlı state'i controller'lara yükle (tüm alanlar)
  void _loadCurrentTabAll() {
    final t = _tabDeviceData[_formTipi]!;
    setState(() {
      _selectedDevice = t.selectedDevice;
      _serialNumberController.text = t.serialNumber;
      _deviceNameController.text = t.deviceName;
      _brandController.text = t.brand;
      _modelController.text = t.model;
      _companyController.text = t.company;
      _locationController.text = t.location;
      _showDeviceSuggestions = false;

      _descriptionController.text = _tabDescription[_formTipi] ?? '';
      _date = _tabDate[_formTipi];
      _updateDateController();
      _warrantyDurationController.text = _tabWarranty[_formTipi] ?? '24';

      // fotoğraf
      _pickedImageBytes = _tabPhotoBytes[_formTipi];
      _pickedImage = _tabPhotoFile[_formTipi];
    });

    // Provider ile senkronize et
    try {
      // Fotoğraf
      ref.read(newServiceFormProvider.notifier).updatePhoto(
            bytes: _pickedImageBytes,
            file: _pickedImage,
          );
    } catch (_) {}
    try {
      // Tarih
      if (_date != null) {
        ref.read(newServiceFormProvider.notifier).updateDate(_date!);
      }
    } catch (_) {}
    try {
      // Garanti süresi
      final w = _warrantyDurationController.text.trim();
      if (w.isNotEmpty) {
        ref.read(newServiceFormProvider.notifier).updateWarranty(w);
      }
    } catch (_) {}
  }

  // Sekme değiştirme: mevcut sekmeyi kaydet, yeni sekmeyi yükle
  void _switchFormType(int newType) {
    _saveCurrentTabAll();
    setState(() {
      _formTipi = newType;
    });
    try {
      ref.read(newServiceFormProvider.notifier).setFormType(newType);
    } catch (_) {}
    _loadCurrentTabAll();
  }

  @override
  void dispose() {
    _technicianController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    // _partSearchController.dispose(); // moved into UsedPartsSection
    _warrantyDurationController.dispose();
    // _otherPartNameController.dispose(); // moved into UsedPartsSection
    // _otherPartQuantityController.dispose(); // moved into UsedPartsSection

    // Yeni controller'ları dispose et
    _serialNumberController.dispose();
    _deviceNameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _companyController.dispose();
    _locationController.dispose();

    super.dispose();
  }


  void _filterDevices(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDevices = _allDevices;
      } else {
        _filteredDevices = _allDevices
            .where(
              (device) =>
                  device.modelName.toLowerCase().contains(query.toLowerCase()) ||
                  device.serialNumber.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
      _showDeviceSuggestions = true;
    });
  }

  void _selectDevice(Device device) {
    setState(() {
      _selectedDevice = device;
      _deviceSearchController.text = device.modelName;
      _showDeviceSuggestions = false;
      _serialNumberController.text = device.serialNumber;
      _deviceNameController.text = device.modelName;
      _brandController.text = device.modelName;
      _modelController.text = device.modelName;
      _companyController.text = device.customer;

      // Aktif sekmenin state'ini güncelle
      final t = _tabDeviceData[_formTipi]!;
      t.selectedDevice = device;
      t.serialNumber = device.serialNumber;
      t.deviceName = device.modelName;
      t.brand = device.modelName;
      t.model = device.modelName;
      t.company = device.customer;
      // location alanını cihazdan türetecek veri yoksa mevcutu koru
    });
    // Provider state'ini de güncelle
    try {
      ref.read(newServiceFormProvider.notifier).setSelectedDevice(device);
    } catch (_) {}
  }

  // Kullanıcı profilinden teknisyen adını al
  String _getTechnicianName() {
    // Öncelik: Firestore AppUser profilinden username
    final asyncUser = ref.read(appUserProvider);
    final fromProfile = asyncUser.maybeWhen<String?>(
      data: (u) {
        final uname = (u?.username ?? u?.usernameLowercase)?.trim();
        if (uname != null && uname.isNotEmpty) return uname;
        final fullName = (u?.fullName ?? '').trim();
        if (fullName.isNotEmpty) return fullName;
        return null;
      },
      orElse: () => null,
    );
    if (fromProfile != null && fromProfile.isNotEmpty) {
      return fromProfile;
    }

    // Geriye dönük: FirebaseAuth displayName, sonra email'in @ öncesi
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user != null) {
      if ((user.displayName ?? '').trim().isNotEmpty) {
        return user.displayName!.trim();
      }
      final email = user.email ?? '';
      if (email.contains('@')) {
        return email.split('@').first;
      }
    }
    return 'Teknisyen';
  }

  void _updateDateController() {
    _dateController.text = _date == null
        ? ''
        : '${_date!.day.toString().padLeft(2, '0')}.${_date!.month.toString().padLeft(2, '0')}.${_date!.year}';
  }



  // Legacy _addOtherPart removed; functionality is handled by UsedPartsSection.

  Future<void> _onKaydet() async {
    final bool isInstallation = _formTipi == 0; // 0: Kurulum

    final customerName = _companyController.text.trim();

    if (!isInstallation && _selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir cihaz seçin.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (isInstallation &&
        _serialNumberController.text.trim().isEmpty &&
        _deviceNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kurulum için en az Seri No veya Cihaz Adı girin.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen firma adı girin.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir tarih seçin.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    // Teknisyen adı ref.listen ile otomatik dolduruluyor

    int warrantyDuration = 24;
    try {
      warrantyDuration = int.parse(_warrantyDurationController.text);
    } catch (e) {
      // Default value
    }

    DateTime? warrantyEndDate;
    if (_date != null) {
      warrantyEndDate = DateTime(
        _date!.year,
        _date!.month + warrantyDuration,
        _date!.day,
      );
    }

    String deviceSerialNumber = '';
    
    if (isInstallation) {
      deviceSerialNumber = _serialNumberController.text.trim().isNotEmpty
          ? _serialNumberController.text.trim()
          : _deviceNameController.text.trim();
          
      final newDevice = Device(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        modelName: _deviceNameController.text.trim().isNotEmpty 
            ? _deviceNameController.text.trim() 
            : deviceSerialNumber,
        serialNumber: deviceSerialNumber,
        customer: _companyController.text,
        installDate: _dateController.text,
        warrantyStatus:
            warrantyEndDate != null && DateTime.now().isBefore(warrantyEndDate)
            ? 'Devam Ediyor'
            : 'Bitti',
        lastMaintenance: _dateController.text,
        warrantyEndDate: warrantyEndDate,
        stockQuantity: 1,
      );
      final addDevice = ref.read(addDeviceUseCaseProvider);
      await addDevice(newDevice);
    } else if (_selectedDevice != null) {
      deviceSerialNumber = _selectedDevice!.serialNumber;
      final updatedDevice = Device(
        id: _selectedDevice!.id,
        modelName: _selectedDevice!.modelName,
        serialNumber: _selectedDevice!.serialNumber,
        customer: _companyController.text,
        installDate: _dateController.text,
        warrantyStatus:
            warrantyEndDate != null && DateTime.now().isBefore(warrantyEndDate)
            ? 'Devam Ediyor'
            : 'Bitti',
        lastMaintenance: _dateController.text,
        warrantyEndDate: warrantyEndDate,
      );
      final updateDevice = ref.read(updateDeviceUseCaseProvider);
      await updateDevice(updatedDevice);
    }

    // Provider state'inden fotoğrafı al
    final providerState = ref.read(newServiceFormProvider);
    final xfile = providerState.activeTabData.photoFile;

    final List<String> photoUrls = [];
    final recordFolderId = const Uuid().v4();
    
    if (xfile != null) {
      try {
        final storage = StorageService();
        final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final url = await storage.uploadFile(
          file: xfile,
          storagePath: 'service_images/$recordFolderId/$fileName',
        );
        photoUrls.add(url);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fotoğraf yüklenemedi, form fotoğrafsız kaydedilecek: $e'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    final String historySerialNumber = deviceSerialNumber;

    // Teknisyen adını provider state'inden al
    final technicianName = providerState.technicianName.isNotEmpty
        ? providerState.technicianName
        : _technicianController.text;

    final history = ServiceHistory(
      id: recordFolderId,
      date: _date!,
      serialNumber: historySerialNumber,
      musteri: customerName,
      description: _descriptionController.text,
      technician: technicianName,
      status: _formTipi == 2 ? 'Arızalı' : 'Başarılı',
      location: _locationController.text,
      kullanilanParcalar: providerState.activeTabData.selectedParts
          .map(
            (sp) => StockPart(
              id: sp.part.id,
              parcaAdi: sp.part.parcaAdi,
              parcaKodu: sp.part.parcaKodu,
              stokAdedi: sp.adet,
              criticalLevel: sp.part.criticalLevel,
            ),
          )
          .toList(),
      photos: photoUrls.isNotEmpty ? photoUrls : null,
    );

    try {
      await Future.wait([
        ref.read(addServiceHistoryUseCaseProvider)(history),
        _updateStockQuantities(),
      ]);
      
      ref.invalidate(serviceHistoryListProvider);
      ref.invalidate(recentServiceHistoryProvider(3));
      ref.invalidate(devicesListProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt sırasında hata: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (!mounted) return;
    
    Navigator.of(context).pop({
      'formTipi': _formTipi,
      'date': _date!,
      'deviceId': historySerialNumber,
      'customer': customerName,
      'technician': technicianName,
      'description': _descriptionController.text,
      'warrantyDuration': warrantyDuration,
      'warrantyStartDate': _date,
      'warrantyEndDate': warrantyEndDate,
      'usedParts': providerState.activeTabData.selectedParts
          .map(
            (sp) => {
              'partCode': sp.part.parcaKodu,
              'partName': sp.part.parcaAdi,
              'quantity': sp.adet,
            },
          )
          .toList(),
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarıyla eklendi!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _calculateWarrantyEndDate() {
    if (_date == null || _warrantyDurationController.text.isEmpty) {
      return 'Hesaplanamıyor';
    }

    try {
      final warrantyDuration = int.parse(_warrantyDurationController.text);
      final warrantyEndDate = DateTime(
        _date!.year,
        _date!.month + warrantyDuration,
        _date!.day,
      );
      return '${warrantyEndDate.day.toString().padLeft(2, '0')}.${warrantyEndDate.month.toString().padLeft(2, '0')}.${warrantyEndDate.year}';
    } catch (e) {
      return 'Hesaplanamıyor';
    }
  }

  Future<void> _updateStockQuantities() async {
    final providerParts = ref.read(newServiceFormProvider).activeTabData.selectedParts;
    if (providerParts.isEmpty) return;

    final updateTasks = providerParts
        .where((selectedPart) => selectedPart.part.id.isNotEmpty)
        .map((selectedPart) async {
      final part = selectedPart.part;
      final usedQuantity = selectedPart.adet;
      final currentStock = part.stokAdedi;
      final newStock = currentStock - usedQuantity;
      final finalStock = newStock < 0 ? 0 : newStock;
      
      final updatedPart = StockPart(
        id: part.id,
        parcaAdi: part.parcaAdi,
        parcaKodu: part.parcaKodu,
        stokAdedi: finalStock,
        criticalLevel: part.criticalLevel,
      );
      
      return ref.read(inventoryProvider.notifier).updatePart(updatedPart);
    }).toList();

    await Future.wait(updateTasks);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(devicesListProvider, (prev, next) {
      next.when(
        data: (devices) {
          if (!mounted) return;
          setState(() {
            _allDevices = devices;
            _filteredDevices = devices;
          });
        },
        loading: () {},
        error: (e, st) {},
      );
    });

    ref.listen(appUserProvider, (previous, next) {
      next.when(
        data: (appUser) {
          final uname = (appUser?.username ?? appUser?.usernameLowercase ?? '')
              .trim();
          if (uname.isNotEmpty) {
            if (_technicianController.text != uname) {
              _technicianController.text = uname;
            }
            // Notifier state'ine teknisyen adını yansıt
            try {
              ref.read(newServiceFormProvider.notifier).setTechnicianName(uname);
            } catch (_) {}
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    });

    // Provider tabanlı form tipi değişimini dinle ve ekran state'i ile senkronize et
    ref.listen(newServiceFormProvider, (prev, next) {
      if (prev?.formTipi != next.formTipi) {
        _switchFormType(next.formTipi);
      }
    });

    _updateDateController();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23408E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Yeni Servis Formu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Form doldurma konusunda yardım için destek ekibimizle iletişime geçin.',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Form Tipi',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 10),
            const FormTypeSelection(),
            const SizedBox(height: 22),
            DeviceSelectionSection(
              deviceSearchController: _deviceSearchController,
              serialNumberController: _serialNumberController,
              deviceNameController: _deviceNameController,
              brandController: _brandController,
              modelController: _modelController,
              selectedDevice: _selectedDevice,
              filteredDevices: _filteredDevices,
              showDeviceSuggestions: _showDeviceSuggestions,
              onFilterDevices: _filterDevices,
              onSelectDevice: _selectDevice,
              onClearDevice: () {
                setState(() {
                  _selectedDevice = null;
                  _deviceSearchController.clear();
                  _showDeviceSuggestions = false;
                  
                  // Tüm cihaz bilgilerini temizle
                  _serialNumberController.clear();
                  _deviceNameController.clear();
                  _brandController.clear();
                  _modelController.clear();
                  _companyController.clear();
                  _locationController.clear();

                  // Aktif sekmenin state'ini de temizle
                  final t = _tabDeviceData[_formTipi]!;
                  t.selectedDevice = null;
                  t.serialNumber = '';
                  t.deviceName = '';
                  t.brand = '';
                  t.model = '';
                  t.company = '';
                  t.location = '';
                });
                // Provider state'ini temizle
                try {
                  ref.read(newServiceFormProvider.notifier).setSelectedDevice(null);
                } catch (_) {}
              },
              onShowSuggestions: () {
                setState(() {
                  _showDeviceSuggestions = true;
                });
              },
              isInstallation: _formTipi == 0,
              onSerialChanged: (v) {
                try {
                  ref.read(newServiceFormProvider.notifier).updateDeviceFields(serialNumber: v);
                } catch (_) {}
              },
              onDeviceNameChanged: (v) {
                try {
                  ref.read(newServiceFormProvider.notifier).updateDeviceFields(deviceName: v);
                } catch (_) {}
              },
              onBrandChanged: (v) {
                try {
                  ref.read(newServiceFormProvider.notifier).updateDeviceFields(brand: v);
                } catch (_) {}
              },
              onModelChanged: (v) {
                try {
                  ref.read(newServiceFormProvider.notifier).updateDeviceFields(model: v);
                } catch (_) {}
              },
            ),
            const SizedBox(height: 22),
            CustomerInfoSection(
              companyController: _companyController,
              locationController: _locationController,
              onCompanyChanged: (v) {
                try {
                  ref.read(newServiceFormProvider.notifier).updateDeviceFields(company: v);
                } catch (_) {}
              },
              onLocationChanged: (v) {
                try {
                  ref.read(newServiceFormProvider.notifier).updateDeviceFields(location: v);
                } catch (_) {}
              },
            ),
            const SizedBox(height: 18),


            Row(
              children: [
                Expanded(
                  child: PhotoPicker(
                    initialBytes: _pickedImageBytes,
                    onChanged: (selection) {
                      setState(() {
                        _pickedImage = selection?.file;
                        _pickedImageBytes = selection?.bytes;
                      });
                      // Provider state'ine de yaz
                      try {
                        ref.read(newServiceFormProvider.notifier).updatePhoto(
                          bytes: selection?.bytes,
                          file: selection?.file,
                        );
                      } catch (_) {}
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            const Text(
              'Form Detayları',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),

            const Text(
              'Kurulum Tarihi',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            TextField(
              readOnly: true,
              controller: _dateController,
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 5),
                  locale: const Locale('tr', 'TR'),
                );
                if (picked != null) {
                  setState(() {
                    _date = picked;
                    _updateDateController();
                    _tabDate[_formTipi] = _date; // sekme bazlı tarih güncelle
                  });
                  // Provider state'i güncelle
                  try {
                    ref.read(newServiceFormProvider.notifier).updateDate(picked);
                  } catch (_) {}
                }
              },
              decoration: InputDecoration(
                hintText: 'gg.aa.yyyy',
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),


            if (_formTipi == 0) ...[
              const Text(
                'Garanti Süresi (Ay)',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _warrantyDurationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '24',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // Garanti süresi değiştiğinde otomatik hesaplama yap
                  setState(() {});
                  _tabWarranty[_formTipi] = value; // sekme bazlı garanti süresi güncelle
                  // Provider state'i güncelle
                  try {
                    ref.read(newServiceFormProvider.notifier).updateWarranty(value);
                  } catch (_) {}
                },
              ),
              const SizedBox(height: 8),


              if (_date != null &&
                  _warrantyDurationController.text.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F6ED),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF43A047).withAlpha(77),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF43A047),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Garanti Bitiş Tarihi: ${_calculateWarrantyEndDate()}',
                          style: const TextStyle(
                            color: Color(0xFF43A047),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 12),
            ],


            const Text(
              'Teknisyen',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _technicianController,
              readOnly: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Teknisyen adı otomatik doldurulur',
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.person, color: Color(0xFF23408E)),
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'Kullanılan Parçalar (Opsiyonel)',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),

            const UsedPartsSection(),
            const SizedBox(height: 12),

            const Text(
              'Açıklama',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _descriptionController,
              onChanged: (value) {
                try {
                  ref.read(newServiceFormProvider.notifier).updateDescription(value);
                } catch (_) {}
              },
              keyboardType: TextInputType.text,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Yapılan işlemi ve notlarınızı buraya yazın...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),

            SubmitButton(onSubmit: _onKaydet),
          ],
        ),
      ),
    );
  }
}
