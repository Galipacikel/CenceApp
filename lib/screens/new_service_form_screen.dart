import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/features/service_history/use_cases.dart';
import '../services/storage_service.dart';
import '../models/stock_part.dart';
import '../models/service_history.dart';

import '../widgets/service/form_sections/device_selection_section.dart';
import '../widgets/service/form_sections/customer_info_section.dart';
import '../widgets/service/form_widgets/form_type_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:cence_app/features/stock/providers.dart';

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

class _NewServiceFormScreenState
    extends rp.ConsumerState<NewServiceFormScreen> {
  int _formTipi = 0; // 0: Kurulum, 1: Bakım, 2: Arıza
  final TextEditingController _technicianController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  
  // Yeni cihaz bilgileri controller'ları
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  
  // Yeni müşteri bilgileri controller'ları
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  DateTime? _date;
  late TextEditingController _dateController;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  // Garanti özellikleri
  final TextEditingController _warrantyDurationController =
      TextEditingController();

  // Parça seçimi için yeni alanlar
  final TextEditingController _partSearchController = TextEditingController();
  List<StockPart> _allParts = [];
  List<StockPart> _filteredParts = [];

  // Diğer parça seçeneği için
  bool _showOtherPartInput = false;
  final TextEditingController _otherPartNameController =
      TextEditingController();
  final TextEditingController _otherPartQuantityController =
      TextEditingController();



  final List<SelectedPart> _selectedParts = [];
  bool _isSaving = false; // Çift kaydetmeyi önlemek için flag

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _warrantyDurationController.text = '24';
    // Async değerleri mevcutsa seed et
    final partsAsync = ref.read(stockPartsProvider);
    partsAsync.when(
      data: (parts) {
        setState(() {
          _allParts = parts;
          _filteredParts = parts;
        });
      },
      loading: () {},
      error: (e, st) {},
    );


    // Teknisyen adını otomatik doldur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _technicianController.text = _getTechnicianName();
    });


  }

  @override
  void dispose() {
    _technicianController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _partSearchController.dispose();
    _customerController.dispose();
    _warrantyDurationController.dispose();
    _otherPartNameController.dispose();
    _otherPartQuantityController.dispose();
    
    // Cihaz bilgileri controller'ları dispose et
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

  // Garanti başlangıç tarihi artık kullanılmıyor, otomatik hesaplanıyor

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF23408E),
              ),
              title: const Text('Kamera ile Çek'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFF23408E),
              ),
              title: const Text('Galeriden Seç'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedImage = picked;
          _pickedImageBytes = bytes;
        });
      }
    }
  }

  void _addOrUpdateSelectedPart(StockPart part, int adet) {
    // Stok kontrolü yap
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
    });
  }

  void _removeSelectedPart(StockPart part) {
    setState(() {
      _selectedParts.removeWhere((sp) => sp.part.parcaKodu == part.parcaKodu);
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

    // Özel parça için geçici bir StockPart oluştur
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${customPart.parcaAdi} eklendi.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onKaydet() async {
    // Çift kaydetmeyi önle
    if (_isSaving) return;
    _isSaving = true;

    final bool isInstallation = _formTipi == 0; // 0: Kurulum

    // Firma alanından müşteri alanını senkronize et
    if (_customerController.text.isEmpty && _companyController.text.isNotEmpty) {
      _customerController.text = _companyController.text.trim();
    }



    // Kurulum için en az seri no veya cihaz adı zorunlu
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
      _isSaving = false;
      return;
    }

    if (_customerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen müşteri/kurum adı girin.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      _isSaving = false;
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
      _isSaving = false;
      return;
    }
    // Teknisyen adı otomatik doldurulduğu için kontrol etmeye gerek yok
    if (_technicianController.text.isEmpty) {
      // Teknisyen adını tekrar doldur
      _technicianController.text = _getTechnicianName();
    }
    // Açıklama alanı opsiyonel olduğu için kontrol kaldırıldı
    // Kullanılan parçalar artık opsiyonel olduğu için kontrol kaldırıldı

    // Garanti süresini parse et
    int warrantyDuration = 24;
    try {
      warrantyDuration = int.parse(_warrantyDurationController.text);
    } catch (e) {
      // Hata durumunda varsayılan değer kullan
    }

    // Garanti bitiş tarihini hesapla (Kurulum tarihi + Garanti süresi)
    DateTime? warrantyEndDate;
    if (_date != null) {
      warrantyEndDate = DateTime(
        _date!.year,
        _date!.month + warrantyDuration,
        _date!.day,
      );
    }



    // Fotoğrafı Storage'a yükle ve URL'leri hazırla
    final List<String> photoUrls = [];
    // Firestore bağımlılığı olmadan benzersiz bir klasör kimliği üret
    final recordFolderId = const Uuid().v4();
    if (_pickedImage != null) {
      final storage = StorageService();
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await storage.uploadFile(
        file: _pickedImage!, // XFile veriyoruz
        storagePath: 'service_images/$recordFolderId/$fileName',
      );
      photoUrls.add(url);
    }

    // ServiceHistory için cihaz id'si: girilen seri no / cihaz adı
    final String historyDeviceId = _serialNumberController.text.trim().isNotEmpty
        ? _serialNumberController.text.trim()
        : _deviceNameController.text.trim();

    // Firestore'a servis kaydı oluştur (stok düşüşü repo/use-case içinde)
    // Kayıtta kullanıcıya görünen teknisyen ismini kullan
    final technicianName = _technicianController.text.isNotEmpty
        ? _technicianController.text
        : _getTechnicianName();
    final history = ServiceHistory(
      id: recordFolderId,
      date: _date!,
      deviceId: historyDeviceId,
      musteri: _customerController.text,
      description: _descriptionController.text,
      technician: technicianName,
      status: _formTipi == 2 ? 'Arızalı' : 'Başarılı',
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

    // UI listesine de ekleyelim
    try {
      final addHistory = ref.read(addServiceHistoryUseCaseProvider);
      await addHistory(history);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt sırasında hata: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      _isSaving = false;
      return;
    }
    if (!mounted) return;

    // Riverpod servis geçmişi provider'ları repository güncellemesini yansıtacaktır.

    Navigator.of(context).pop({
      'formTipi': _formTipi,
      'date': _date!,
      'deviceId': historyDeviceId,
      'customer': _customerController.text,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kayıt başarıyla eklendi!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Flag'i sıfırla
    _isSaving = false;
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

  @override
  Widget build(BuildContext context) {
    // Provider değişimlerini dinle (Riverpod gereği build içinde)
    ref.listen(stockPartsProvider, (prev, next) {
      next.when(
        data: (parts) {
          if (!mounted) return;
          setState(() {
            _allParts = parts;
            _filteredParts = parts;
          });
        },
        loading: () {},
        error: (e, st) {},
      );
    });



    // AppUser yüklendiğinde kullanıcı adı ile teknisyen alanını güncelle
    ref.listen(appUserProvider, (previous, next) {
      next.when(
        data: (appUser) {
          final uname = (appUser?.username ?? appUser?.usernameLowercase ?? '').trim();
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
                  onTap: () => setState(() => _formTipi = 0),
                ),
                const SizedBox(width: 8),
                FormTypeChip(
                  label: 'Bakım',
                  selected: _formTipi == 1,
                  color: const Color(0xFFFFC107),
                  onTap: () => setState(() => _formTipi = 1),
                ),
                const SizedBox(width: 8),
                FormTypeChip(
                  label: 'Arıza',
                  selected: _formTipi == 2,
                  color: const Color(0xFFE53935),
                  onTap: () => setState(() => _formTipi = 2),
                ),
              ],
            ),
            const SizedBox(height: 22),
            DeviceSelectionSection(
              serialNumberController: _serialNumberController,
              deviceNameController: _deviceNameController,
              brandController: _brandController,
              modelController: _modelController,
              formTipi: _formTipi,
            ),
            const SizedBox(height: 22),
            CustomerInfoSection(
              companyController: _companyController,
              locationController: _locationController,
            ),
            const SizedBox(height: 18),

            // Photo upload area
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23408E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _pickImage,
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Fotoğraf Çek',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                if (_pickedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (_pickedImageBytes != null)
                        ? Image.memory(
                            _pickedImageBytes!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                const SizedBox(width: 70, height: 70),
                          )
                        : const SizedBox(width: 70, height: 70),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            // Form Details
            const Text(
              'Form Detayları',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            // Installation Date header
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
                if (picked != null) setState(() => _date = picked);
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

            // Garanti Bilgileri (Sadece Kurulum formunda göster)
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
                },
              ),
              const SizedBox(height: 8),

              // Garanti Bitiş Tarihi (Otomatik Hesaplanan)
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

            // Technician header
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
            // Used Parts header
            const Text(
              'Kullanılan Parçalar (Opsiyonel)',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            // Part search box
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
            // Diğer parça seçeneği
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
            // Modern multi-part selection based on cards
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
            // Description header
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
            // Save Button
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
                onPressed: _onKaydet,
                child: const Text(
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
