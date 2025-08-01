import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/stock_part.dart';
import '../models/device.dart';
import '../models/service_history.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../providers/service_history_provider.dart';
import '../providers/device_provider.dart';
import '../providers/app_state_provider.dart';

class NewServiceFormScreen extends StatefulWidget {
  final StockPartRepository? stockRepository;
  final DeviceRepository? deviceRepository;
  const NewServiceFormScreen({Key? key, this.stockRepository, this.deviceRepository}) : super(key: key);

  @override
  State<NewServiceFormScreen> createState() => _NewServiceFormScreenState();
}

class SelectedPart {
  final StockPart part;
  int adet;
  SelectedPart({required this.part, this.adet = 1});
}

class _NewServiceFormScreenState extends State<NewServiceFormScreen> {
  int _formTipi = 0; // 0: Kurulum, 1: Bakım, 2: Arıza
  final TextEditingController _deviceController = TextEditingController();
  final TextEditingController _technicianController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  DateTime? _date;
  late TextEditingController _dateController;
  File? _pickedImage;
  
  // Garanti özellikleri
  final TextEditingController _warrantyDurationController = TextEditingController();
  
  // Parça seçimi için yeni alanlar
  final TextEditingController _partSearchController = TextEditingController();
  List<StockPart> _allParts = [];
  List<StockPart> _filteredParts = [];
  
  // Diğer parça seçeneği için
  bool _showOtherPartInput = false;
  final TextEditingController _otherPartNameController = TextEditingController();
  final TextEditingController _otherPartQuantityController = TextEditingController();
  
  // Cihaz seçimi için
  Device? _selectedDevice;
  final TextEditingController _deviceSearchController = TextEditingController();
  List<Device> _allDevices = [];
  List<Device> _filteredDevices = [];
  bool _showDeviceSuggestions = false;
  final DeviceRepository _deviceRepository = MockDeviceRepository();

  List<SelectedPart> _selectedParts = [];
  bool _isSaving = false; // Çift kaydetmeyi önlemek için flag

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _warrantyDurationController.text = '24';
    _loadParts();
    _loadDevices();
    
    // Teknisyen adını otomatik doldur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _technicianController.text = _getTechnicianName();
    });
  }

  @override
  void dispose() {
    _deviceController.dispose();
    _technicianController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _partSearchController.dispose();
    _customerController.dispose();
    _warrantyDurationController.dispose();
    _otherPartNameController.dispose();
    _otherPartQuantityController.dispose();
    super.dispose();
  }

  Future<void> _loadParts() async {
    // StockProvider'dan parçaları al
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    setState(() {
      _allParts = stockProvider.parts;
      _filteredParts = stockProvider.parts;
    });
  }

  Future<void> _loadDevices() async {
    final devices = await _deviceRepository.getAll();
    setState(() {
      _allDevices = devices;
      _filteredDevices = devices;
    });
  }



  void _filterParts(String query) {
    setState(() {
      List<StockPart> baseParts = _allParts;
      
      if (query.isEmpty) {
        _filteredParts = baseParts;
      } else {
        _filteredParts = baseParts.where((part) =>
          part.parcaAdi.toLowerCase().contains(query.toLowerCase()) ||
          part.parcaKodu.toLowerCase().contains(query.toLowerCase())
        ).toList();
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
        _filteredDevices = _allDevices.where((device) =>
          device.modelName.toLowerCase().contains(query.toLowerCase()) ||
          device.serialNumber.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      _showDeviceSuggestions = true;
    });
  }



  void _selectDevice(Device device) {
    setState(() {
      _selectedDevice = device;
      _deviceSearchController.text = device.modelName;
      _showDeviceSuggestions = false;
      
      // Kurulum tarihi seçili değilse bugünün tarihini ata
      if (_date == null) {
        _date = DateTime.now();
        _updateDateController();
      }
    });
  }

  // Kullanıcı profilinden teknisyen adını al
  String _getTechnicianName() {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final userProfile = appStateProvider.userProfile;
    return userProfile.fullName;
  }

  void _updateDateController() {
    _dateController.text = _date == null ? '' : '${_date!.day.toString().padLeft(2, '0')}.${_date!.month.toString().padLeft(2, '0')}.${_date!.year}';
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
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF23408E)),
              title: const Text('Kamera ile Çek'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF23408E)),
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
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    }
  }

  void _addOrUpdateSelectedPart(StockPart part, int adet) {
    // Stok kontrolü yap
    if (adet > part.stokAdedi) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stokta sadece ${part.stokAdedi} adet ${part.parcaAdi} bulunuyor.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      final idx = _selectedParts.indexWhere((sp) => sp.part.parcaKodu == part.parcaKodu);
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
        const SnackBar(content: Text('Lütfen parça adını girin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
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
        const SnackBar(content: Text('Geçerli bir miktar girin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Miktar 0\'dan büyük olmalıdır.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
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
      SnackBar(content: Text('${customPart.parcaAdi} eklendi.'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
    );
  }

  void _onKaydet() async {
    // Çift kaydetmeyi önle
    if (_isSaving) return;
    _isSaving = true;
    
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir cihaz seçin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      _isSaving = false;
      return;
    }
    if (_customerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen müşteri/kurum adı girin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      _isSaving = false;
      return;
    }
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir tarih seçin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
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

    // Cihaz bilgilerini güncelle (DeviceProvider ile)
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final updatedDevice = Device(
      id: _selectedDevice!.id,
      modelName: _selectedDevice!.modelName,
      serialNumber: _selectedDevice!.serialNumber,
      customer: _customerController.text,
      installDate: _dateController.text,
      warrantyStatus: warrantyEndDate != null && DateTime.now().isBefore(warrantyEndDate) ? 'Devam Ediyor' : 'Bitti',
      lastMaintenance: _dateController.text,
      warrantyEndDate: warrantyEndDate,
    );
    deviceProvider.updateDevice(updatedDevice);

    // Stoktan düşme işlemi (Provider ile) - sadece stok parçaları için
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    for (final sp in _selectedParts) {
      // Sadece stok parçaları için stok düşürme işlemi yap
      if (sp.part.parcaKodu != 'ÖZEL') {
        stockProvider.decreaseStock(sp.part.id, sp.adet);
      }
    }
    
    // Servis geçmişine ekleme (Provider ile)
    final serviceHistoryProvider = Provider.of<ServiceHistoryProvider>(context, listen: false);
    serviceHistoryProvider.addServiceHistory(
      ServiceHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _date!,
        deviceId: _selectedDevice!.modelName, // ID yerine cihaz adını kaydet
        musteri: _customerController.text,
        description: _descriptionController.text,
        technician: _technicianController.text,
        status: _formTipi == 2 ? 'Arızalı' : 'Başarılı',
        kullanilanParcalar: _selectedParts.map((sp) => StockPart(
          id: sp.part.id,
          parcaAdi: sp.part.parcaAdi,
          parcaKodu: sp.part.parcaKodu,
          stokAdedi: sp.adet,
          criticalLevel: sp.part.criticalLevel,
        )).toList(),
      ),
    );
    
    Navigator.pop(context, {
      'formTipi': _formTipi,
      'date': _date!,
      'deviceId': _selectedDevice!.id,
      'customer': _customerController.text,
      'technician': _technicianController.text,
      'description': _descriptionController.text,
      'warrantyDuration': warrantyDuration,
      'warrantyStartDate': _date,
      'warrantyEndDate': warrantyEndDate,
      'usedParts': _selectedParts.map((sp) => {
        'partCode': sp.part.parcaKodu,
        'partName': sp.part.parcaAdi,
        'quantity': sp.adet,
      }).toList(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıt başarıyla eklendi!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
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
    _updateDateController();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23408E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
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
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Form doldurma konusunda yardım için destek ekibimizle iletişime geçin.'),
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
            const Text('Form Tipi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                _FormTypeChip(
                  label: 'Kurulum',
                  selected: _formTipi == 0,
                  color: const Color(0xFF23408E),
                  onTap: () => setState(() => _formTipi = 0),
                ),
                const SizedBox(width: 8),
                _FormTypeChip(
                  label: 'Bakım',
                  selected: _formTipi == 1,
                  color: const Color(0xFFFFC107),
                  onTap: () => setState(() => _formTipi = 1),
                ),
                const SizedBox(width: 8),
                _FormTypeChip(
                  label: 'Arıza',
                  selected: _formTipi == 2,
                  color: const Color(0xFFE53935),
                  onTap: () => setState(() => _formTipi = 2),
                ),
              ],
            ),
            const SizedBox(height: 22),
            // Device Information
            const Text('Cihaz Bilgileri', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            const Text('Cihaz', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            // Responsive device selection
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            TextField(
                      controller: _deviceSearchController,
                      readOnly: false,
              decoration: InputDecoration(
                        hintText: 'Model, seri numarası veya müşteri...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                        suffixIcon: _selectedDevice != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedDevice = null;
                                    _deviceSearchController.clear();
                                    _showDeviceSuggestions = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: _filterDevices,
                      onTap: () {
                        setState(() {
                          _showDeviceSuggestions = true;
                        });
                      },
                    ),
                    if (_showDeviceSuggestions && _filteredDevices.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight > 300 ? 300 : constraints.maxHeight * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredDevices.length,
                          itemBuilder: (context, index) {
                            final device = _filteredDevices[index];
                            return ListTile(
                              title: Text('${device.modelName} (${device.serialNumber})'),
                              onTap: () => _selectDevice(device),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            const Text('Müşteri/Kurum Bilgileri', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _customerController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Müşteri veya kurum adı girin',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
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
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  label: const Text('Fotoğraf Çek', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
                if (_pickedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _pickedImage!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            // Form Details
            const Text('Form Detayları', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            // Installation Date header
            const Text('Kurulum Tarihi', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              readOnly: true,
              controller: _dateController,
              decoration: InputDecoration(
                hintText: 'gg.aa.yyyy',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () async {
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
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Garanti Bilgileri (Sadece Kurulum formunda göster)
            if (_formTipi == 0) ...[
              const Text('Garanti Süresi (Ay)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(height: 4),
              TextField(
                controller: _warrantyDurationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '24',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
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
              if (_date != null && _warrantyDurationController.text.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F6ED),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF43A047).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF43A047), size: 16),
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
            const Text('Teknisyen', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _technicianController,
              readOnly: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Teknisyen adı otomatik doldurulur',
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.person, color: Color(0xFF23408E)),
              ),
            ),
            const SizedBox(height: 12),
            // Used Parts header
            const Text('Kullanılan Parçalar (Opsiyonel)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            // Part search box
            TextField(
              controller: _partSearchController,
              decoration: InputDecoration(
                hintText: 'Parça adı veya kodu ile ara...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF23408E)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
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
                    icon: Icon(_showOtherPartInput ? Icons.remove : Icons.add, color: Color(0xFF23408E)),
                    label: Text(_showOtherPartInput ? 'İptal' : 'Diğer Parça Ekle', style: TextStyle(color: Color(0xFF23408E))),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF23408E)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    const Text('Özel Parça Ekle', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF23408E))),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otherPartNameController,
                      decoration: InputDecoration(
                        hintText: 'Parça adını girin...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Ekle', style: TextStyle(color: Colors.white)),
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
                              child: Center(child: Text('Aramanıza uygun parça bulunamadı', style: TextStyle(color: Colors.grey))),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _filteredParts.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                              itemBuilder: (context, index) {
                                final part = _filteredParts[index];
                                final selected = _selectedParts.firstWhere(
                                  (sp) => sp.part.parcaKodu == part.parcaKodu,
                                  orElse: () => SelectedPart(part: part, adet: 0),
                                );
                                final isSelected = selected.adet > 0;
                                final isOutOfStock = part.stokAdedi == 0;
                                final isCriticalLevel = part.stokAdedi <= part.criticalLevel && part.stokAdedi > 0;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                          color: const Color(0xFF43A047).withOpacity(0.08),
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
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('${part.parcaAdi} stokta bulunmuyor.'),
                                                    backgroundColor: Colors.red,
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            : () {
                                                if (isSelected) {
                                                  _removeSelectedPart(part);
                                                } else {
                                                  _addOrUpdateSelectedPart(part, 1);
                                                }
                                              },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected ? const Color(0xFF43A047) : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            color: isSelected ? const Color(0xFF43A047) : Colors.white,
                                          ),
                                          child: isSelected
                                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(part.parcaAdi, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isOutOfStock ? Colors.grey : Colors.black)),
                                                if (isOutOfStock)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Text('Stokta Yok', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                                                    ),
                                                  )
                                                else if (part.stokAdedi <= part.criticalLevel)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Text('Kritik Seviye', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text('Kod: ${part.parcaKodu}', style: const TextStyle(fontSize: 12, color: Color(0xFF23408E))),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: part.stokAdedi == 0 
                                                        ? Colors.red.shade100 
                                                        : part.stokAdedi <= part.criticalLevel 
                                                            ? Colors.orange.shade100 
                                                            : Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    'Stok: ${part.stokAdedi}', 
                                                    style: TextStyle(
                                                      fontSize: 12, 
                                                      color: part.stokAdedi == 0 
                                                          ? Colors.red 
                                                          : part.stokAdedi <= part.criticalLevel 
                                                              ? Colors.orange 
                                                              : const Color(0xFF23408E),
                                                      fontWeight: part.stokAdedi == 0 || part.stokAdedi <= part.criticalLevel 
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
                                              icon: const Icon(Icons.remove_circle_outline, size: 24, color: Color(0xFF23408E)),
                                              splashRadius: 20,
                                              onPressed: selected.adet > 1
                                                  ? () => _addOrUpdateSelectedPart(part, selected.adet - 1)
                                                  : null,
                                            ),
                                            Text('${selected.adet}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, size: 24, color: Color(0xFF23408E)),
                                              splashRadius: 20,
                                              onPressed: part.stokAdedi > selected.adet
                                                  ? () => _addOrUpdateSelectedPart(part, selected.adet + 1)
                                                  : () {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Stokta sadece ${part.stokAdedi} adet ${part.parcaAdi} bulunuyor.'),
                                                          backgroundColor: Colors.red,
                                                          duration: const Duration(seconds: 2),
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
                          children: _selectedParts.map((sp) => Chip(
                            label: Text('${sp.part.parcaAdi} x${sp.adet}'),
                            backgroundColor: const Color(0xFFE3F6ED),
                            labelStyle: const TextStyle(color: Color(0xFF23408E), fontWeight: FontWeight.w600),
                            deleteIcon: const Icon(Icons.close, size: 18, color: Color(0xFF23408E)),
                            onDeleted: () => _removeSelectedPart(sp.part),
                          )).toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            // Description header
            const Text('Açıklama', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
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



class _FormTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  const _FormTypeChip({required this.label, required this.selected, required this.onTap, required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
} 