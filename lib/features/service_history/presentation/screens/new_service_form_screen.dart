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
import 'package:cence_app/widgets/service/form_widgets/form_type_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:cence_app/features/devices/providers.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';
import 'package:cence_app/features/devices/use_cases.dart';
import 'package:cence_app/features/service_history/presentation/widgets/photo_picker.dart';
import 'package:cence_app/features/service_history/providers.dart';

class NewServiceFormScreen extends rp.ConsumerStatefulWidget {
  const NewServiceFormScreen({super.key});

  @override
  rp.ConsumerState<NewServiceFormScreen> createState() =>
      _NewServiceFormScreenState();
}

class SelectedPart {
  final StockPart part;
  int adet;
  SelectedPart({required this.part, this.adet = 1});
}

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
  final TextEditingController _partSearchController = TextEditingController();
  List<StockPart> _allParts = [];
  List<StockPart> _filteredParts = [];
  bool _showOtherPartInput = false;
  final TextEditingController _otherPartNameController = TextEditingController();
  final TextEditingController _otherPartQuantityController = TextEditingController();
  Device? _selectedDevice;
  final TextEditingController _deviceSearchController = TextEditingController();
  List<Device> _allDevices = [];
  List<Device> _filteredDevices = [];
  bool _showDeviceSuggestions = false;
  final List<SelectedPart> _selectedParts = [];
  bool _isSaving = false;
  // Her sekme için cihaz alanları state'i
  late Map<int, DeviceFormData> _tabDeviceData;
  // Her sekme için diğer form state'leri
  late Map<int, String> _tabDescription;
  late Map<int, DateTime?> _tabDate;
  late Map<int, String> _tabWarranty;
  late Map<int, List<SelectedPart>> _tabSelectedParts;
  late Map<int, Uint8List?> _tabPhotoBytes;
  late Map<int, XFile?> _tabPhotoFile;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _warrantyDurationController.text = '24';
    
    // Tab bazlı state'i başlat
    _tabDeviceData = {
      0: DeviceFormData.empty(),
      1: DeviceFormData.empty(),
      2: DeviceFormData.empty(),
    };
    _tabDescription = {0: '', 1: '', 2: ''};
    _tabDate = {0: null, 1: null, 2: null};
    _tabWarranty = {0: '24', 1: '24', 2: '24'};
    _tabSelectedParts = {0: <SelectedPart>[], 1: <SelectedPart>[], 2: <SelectedPart>[]};
    _tabPhotoBytes = {0: null, 1: null, 2: null};
    _tabPhotoFile = {0: null, 1: null, 2: null};
    
    // Otomatik olarak bugünün tarihini ata
    _date = DateTime.now();
    _updateDateController();
    _tabDate[_formTipi] = _date; // aktif sekmeye başlangıç tarihi yaz
    
    final inventoryAsync = ref.read(inventoryProvider);
    inventoryAsync.when(
      data: (inventory) {
        setState(() {
          _allParts = inventory.parts;
          _filteredParts = inventory.parts;
        });
      },
      loading: () {},
      error: (e, st) {},
    );
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
    _tabSelectedParts[_formTipi] = _selectedParts
        .map((sp) => SelectedPart(part: sp.part, adet: sp.adet))
        .toList();
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

      // seçilen parçaları yükle
      _selectedParts
        ..clear()
        ..addAll((_tabSelectedParts[_formTipi] ?? const <SelectedPart>[])
            .map((sp) => SelectedPart(part: sp.part, adet: sp.adet)));

      // fotoğraf
      _pickedImageBytes = _tabPhotoBytes[_formTipi];
      _pickedImage = _tabPhotoFile[_formTipi];
    });
  }

  // Sekme değiştirme: mevcut sekmeyi kaydet, yeni sekmeyi yükle
  void _switchFormType(int newType) {
    _saveCurrentTabAll();
    setState(() {
      _formTipi = newType;
    });
    _loadCurrentTabAll();
  }

  @override
  void dispose() {
    _technicianController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _partSearchController.dispose();
    _warrantyDurationController.dispose();
    _otherPartNameController.dispose();
    _otherPartQuantityController.dispose();

    // Yeni controller'ları dispose et
    _serialNumberController.dispose();
    _deviceNameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _companyController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  void _filterParts(String query) {
    setState(() {
      List<StockPart> baseParts = _allParts;

      if (query.isEmpty) {
        _filteredParts = baseParts;
      } else {
        _filteredParts = baseParts
            .where(
              (part) =>
                  part.parcaAdi.toLowerCase().contains(query.toLowerCase()) ||
                  part.parcaKodu.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
      _filteredParts.sort((a, b) {
        return a.parcaAdi.compareTo(b.parcaAdi);
      });
    });
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



  void _addOrUpdateSelectedPart(StockPart part, int adet) {
    if (adet > part.stokAdedi) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stokta sadece ${part.stokAdedi} adet ${part.parcaAdi} bulunuyor.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      final idx = _selectedParts.indexWhere(
        (sp) => sp.part.parcaKodu == part.parcaKodu,
      );
      if (idx >= 0) {
        _selectedParts[idx].adet = adet;
      } else {
        _selectedParts.add(SelectedPart(part: part, adet: adet));
      }
      // sekme bazlı parçalar state'ini güncelle
      _tabSelectedParts[_formTipi] = _selectedParts
          .map((sp) => SelectedPart(part: sp.part, adet: sp.adet))
          .toList();
    });
  }

  void _removeSelectedPart(StockPart part) {
    setState(() {
      _selectedParts.removeWhere((sp) => sp.part.parcaKodu == part.parcaKodu);
      // sekme bazlı parçalar state'ini güncelle
      _tabSelectedParts[_formTipi] = _selectedParts
          .map((sp) => SelectedPart(part: sp.part, adet: sp.adet))
          .toList();
    });
  }

  void _addOtherPart() {
    if (_otherPartNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen parça adını girin.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    int quantity = 1;
    try {
      if (_otherPartQuantityController.text.isNotEmpty) {
        quantity = int.parse(_otherPartQuantityController.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli bir miktar girin.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Miktar 0\'dan büyük olmalıdır.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final customPart = StockPart(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      parcaAdi: _otherPartNameController.text.trim(),
      parcaKodu: 'ÖZEL',
      stokAdedi: quantity,
      criticalLevel: 0,
    );

    setState(() {
      _selectedParts.add(SelectedPart(part: customPart, adet: quantity));
      _otherPartNameController.clear();
      _otherPartQuantityController.clear();
      _showOtherPartInput = false;
      // sekme bazlı parçalar state'ini güncelle
      _tabSelectedParts[_formTipi] = _selectedParts
          .map((sp) => SelectedPart(part: sp.part, adet: sp.adet))
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${customPart.parcaAdi} eklendi.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onKaydet() async {
    // Çift kaydetmeyi önle
    if (_isSaving) return;
    setState(() => _isSaving = true);

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
      setState(() => _isSaving = false);
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
      setState(() => _isSaving = false);
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
      setState(() => _isSaving = false);
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
      setState(() => _isSaving = false);
      return;
    }
    // Teknisyen adı otomatik doldurulduğu için kontrol etmeye gerek yok
    if (_technicianController.text.isEmpty) {
      _technicianController.text = _getTechnicianName();
    }

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

    final List<String> photoUrls = [];
    final recordFolderId = const Uuid().v4();
    
    if (_pickedImage != null) {
      try {
        final storage = StorageService();
        final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final url = await storage.uploadFile(
          file: _pickedImage!,
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

    final technicianName = _technicianController.text.isNotEmpty
        ? _technicianController.text
        : _getTechnicianName();
    final history = ServiceHistory(
      id: recordFolderId,
      date: _date!,
      serialNumber: historySerialNumber,
      musteri: customerName,
      description: _descriptionController.text,
      technician: technicianName,
      status: _formTipi == 2 ? 'Arızalı' : 'Başarılı',
      location: _locationController.text,
      kullanilanParcalar: _selectedParts
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
      setState(() => _isSaving = false);
      return;
    }
    if (!mounted) return;

    setState(() => _isSaving = false);
    
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
      'usedParts': _selectedParts
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
    if (_selectedParts.isEmpty) return;

    final updateTasks = _selectedParts
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
    ref.listen(inventoryProvider, (prev, next) {
      next.when(
        data: (inventory) {
          if (!mounted) return;
          setState(() {
            _allParts = inventory.parts;
            _filteredParts = inventory.parts;
          });
        },
        loading: () {},
        error: (e, st) {},
      );
    });

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
          }
        },
        loading: () {},
        error: (_, __) {},
      );
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
            Row(
              children: [
                FormTypeChip(
                  label: 'Kurulum',
                  selected: _formTipi == 0,
                  color: const Color(0xFF23408E),
                  onTap: () => _switchFormType(0),
                ),
                const SizedBox(width: 8),
                FormTypeChip(
                  label: 'Bakım',
                  selected: _formTipi == 1,
                  color: const Color(0xFFFFC107),
                  onTap: () => _switchFormType(1),
                ),
                const SizedBox(width: 8),
                FormTypeChip(
                  label: 'Arıza',
                  selected: _formTipi == 2,
                  color: const Color(0xFFE53935),
                  onTap: () => _switchFormType(2),
                ),
              ],
            ),
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
              },
              onShowSuggestions: () {
                setState(() {
                  _showDeviceSuggestions = true;
                });
              },
              isInstallation: _formTipi == 0,
            ),
            const SizedBox(height: 22),
            CustomerInfoSection(
              companyController: _companyController,
              locationController: _locationController,
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

            TextField(
              controller: _partSearchController,
              decoration: InputDecoration(
                hintText: 'Parça adı veya kodu ile ara...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF23408E)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _partSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF23408E)),
                        onPressed: () {
                          setState(() {
                            _partSearchController.clear();
                            _filterParts('');
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (val) => _filterParts(val),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showOtherPartInput = !_showOtherPartInput;
                        if (!_showOtherPartInput) {
                          _otherPartNameController.clear();
                          _otherPartQuantityController.clear();
                        }
                      });
                    },
                    icon: Icon(
                      _showOtherPartInput ? Icons.remove : Icons.add,
                      color: Color(0xFF23408E),
                    ),
                    label: Text(
                      _showOtherPartInput ? 'İptal' : 'Diğer Parça Ekle',
                      style: TextStyle(color: Color(0xFF23408E)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF23408E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showOtherPartInput) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Özel Parça Ekle',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF23408E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otherPartNameController,
                      decoration: InputDecoration(
                        hintText: 'Parça adını girin...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _otherPartQuantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Miktar (varsayılan: 1)',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addOtherPart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF23408E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Ekle',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),

            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: _filteredParts.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'Aramanıza uygun parça bulunamadı',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _filteredParts.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: Colors.grey.shade100,
                              ),
                              itemBuilder: (context, index) {
                                final part = _filteredParts[index];
                                final selected = _selectedParts.firstWhere(
                                  (sp) => sp.part.parcaKodu == part.parcaKodu,
                                  orElse: () =>
                                      SelectedPart(part: part, adet: 0),
                                );
                                final isSelected = selected.adet > 0;
                                final isOutOfStock = part.stokAdedi == 0;
                                // final isCriticalLevel = part.stokAdedi <= part.criticalLevel && part.stokAdedi > 0;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isOutOfStock
                                        ? Colors.grey.shade100
                                        : isSelected
                                        ? const Color(0xFFE3F6ED)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF43A047)
                                          : isOutOfStock
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: const Color(
                                            0xFF43A047,
                                          ).withAlpha(20),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: isOutOfStock
                                            ? () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '${part.parcaAdi} stokta bulunmuyor.',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              }
                                            : () {
                                                if (isSelected) {
                                                  _removeSelectedPart(part);
                                                } else {
                                                  _addOrUpdateSelectedPart(
                                                    part,
                                                    1,
                                                  );
                                                }
                                              },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF43A047)
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            color: isSelected
                                                ? const Color(0xFF43A047)
                                                : Colors.white,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 18,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  part.parcaAdi,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                    color: isOutOfStock
                                                        ? Colors.grey
                                                        : Colors.black,
                                                  ),
                                                ),
                                                if (isOutOfStock)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 8.0,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        'Stokta Yok',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                else if (part.stokAdedi <=
                                                    part.criticalLevel)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 8.0,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .orange
                                                            .shade100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        'Kritik Seviye',
                                                        style: TextStyle(
                                                          color: Colors.orange,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Kod: ${part.parcaKodu}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF23408E),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: part.stokAdedi == 0
                                                        ? Colors.red.shade100
                                                        : part.stokAdedi <=
                                                              part.criticalLevel
                                                        ? Colors.orange.shade100
                                                        : Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Stok: ${part.stokAdedi}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: part.stokAdedi == 0
                                                          ? Colors.red
                                                          : part.stokAdedi <=
                                                                part.criticalLevel
                                                          ? Colors.orange
                                                          : const Color(
                                                              0xFF23408E,
                                                            ),
                                                      fontWeight:
                                                          part.stokAdedi == 0 ||
                                                              part.stokAdedi <=
                                                                  part.criticalLevel
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isOutOfStock && isSelected)
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                size: 24,
                                                color: Color(0xFF23408E),
                                              ),
                                              splashRadius: 20,
                                              onPressed: selected.adet > 1
                                                  ? () =>
                                                        _addOrUpdateSelectedPart(
                                                          part,
                                                          selected.adet - 1,
                                                        )
                                                  : null,
                                            ),
                                            Text(
                                              '${selected.adet}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                size: 24,
                                                color: Color(0xFF23408E),
                                              ),
                                              splashRadius: 20,
                                              onPressed:
                                                  part.stokAdedi > selected.adet
                                                  ? () =>
                                                        _addOrUpdateSelectedPart(
                                                          part,
                                                          selected.adet + 1,
                                                        )
                                                  : () {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Stokta sadece ${part.stokAdedi} adet ${part.parcaAdi} bulunuyor.',
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                          duration:
                                                              const Duration(
                                                                seconds: 2,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    if (_selectedParts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 2),
                        child: Wrap(
                          spacing: 8,
                          children: _selectedParts
                              .map(
                                (sp) => Chip(
                                  label: Text(
                                    '${sp.part.parcaAdi} x${sp.adet}',
                                  ),
                                  backgroundColor: const Color(0xFFE3F6ED),
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF23408E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Color(0xFF23408E),
                                  ),
                                  onDeleted: () => _removeSelectedPart(sp.part),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            const Text(
              'Açıklama',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _descriptionController,
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

            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23408E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _onKaydet,
                child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Kaydediliyor...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Kaydet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
