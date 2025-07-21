import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/stock_part.dart';
import '../models/cihaz.dart';

class YeniServisFormuScreen extends StatefulWidget {
  final StockPartRepository? stockRepository;
  final CihazRepository? cihazRepository;
  const YeniServisFormuScreen({Key? key, this.stockRepository, this.cihazRepository}) : super(key: key);

  @override
  State<YeniServisFormuScreen> createState() => _YeniServisFormuScreenState();
}

class SelectedPart {
  final StockPart part;
  int adet;
  SelectedPart({required this.part, this.adet = 1});
}

class _YeniServisFormuScreenState extends State<YeniServisFormuScreen> {
  int _formTipi = 0; // 0: Kurulum, 1: Bakım, 2: Arıza
  final TextEditingController _cihazController = TextEditingController();
  final TextEditingController _teknisyenController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
  final TextEditingController _musteriController = TextEditingController();
  DateTime? _tarih;
  late TextEditingController _tarihController;
  File? _pickedImage;
  
  // Parça seçimi için yeni alanlar
  StockPart? _selectedPart;
  bool _noPartInstalled = false;
  final TextEditingController _partSearchController = TextEditingController();
  List<StockPart> _allParts = [];
  List<StockPart> _filteredParts = [];
  bool _showPartSuggestions = false;
  final StockPartRepository _stockRepository = MockStockRepository();
  
  // Cihaz seçimi için
  Cihaz? _selectedCihaz;
  final TextEditingController _cihazSearchController = TextEditingController();
  List<Cihaz> _allCihazlar = [];
  List<Cihaz> _filteredCihazlar = [];
  bool _showCihazSuggestions = false;
  final CihazRepository _cihazRepository = MockCihazRepository();
  
  // Kategori seçimi için
  String? _selectedCategory;
  final List<String> _categories = ['Tüm Parçalar', 'Elektronik', 'Mekanik', 'Sarf Malzeme', 'Diğer'];
  final Map<String, IconData> _categoryIcons = {
    'Tüm Parçalar': Icons.all_inclusive,
    'Elektronik': Icons.memory,
    'Mekanik': Icons.settings,
    'Sarf Malzeme': Icons.cable,
    'Diğer': Icons.category,
  };
  final Map<String, Color> _categoryColors = {
    'Tüm Parçalar': const Color(0xFF23408E),
    'Elektronik': const Color(0xFF23408E),
    'Mekanik': const Color(0xFF00BFAE),
    'Sarf Malzeme': const Color(0xFFFF7043),
    'Diğer': const Color(0xFFB0B6C3),
  };

  List<SelectedPart> _selectedParts = [];

  @override
  void initState() {
    super.initState();
    _tarihController = TextEditingController();
    _loadParts();
    _loadCihazlar();
  }

  @override
  void dispose() {
    _cihazController.dispose();
    _teknisyenController.dispose();
    _aciklamaController.dispose();
    _tarihController.dispose();
    _partSearchController.dispose();
    _musteriController.dispose();
    super.dispose();
  }

  Future<void> _loadParts() async {
    final parts = await _stockRepository.getAll();
    setState(() {
      _allParts = parts;
      _filteredParts = parts;
    });
  }

  Future<void> _loadCihazlar() async {
    final cihazlar = await _cihazRepository.getAll();
    setState(() {
      _allCihazlar = cihazlar;
      _filteredCihazlar = cihazlar;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedPart = null;
      _partSearchController.clear();
      _showPartSuggestions = false;
      
      _filteredParts = _allParts;
      _filteredParts.sort((a, b) {
        return a.parcaAdi.compareTo(b.parcaAdi);
      });
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

  void _filterCihazlar(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCihazlar = _allCihazlar;
      } else {
        _filteredCihazlar = _allCihazlar.where((cihaz) =>
          cihaz.modelAdi.toLowerCase().contains(query.toLowerCase()) ||
          cihaz.seriNumarasi.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      _showCihazSuggestions = true;
    });
  }

  void _selectPart(StockPart part) {
    setState(() {
      _selectedPart = part;
      _partSearchController.text = '${part.parcaAdi} (${part.parcaKodu})';
      _showPartSuggestions = false;
      _noPartInstalled = false;
    });
  }

  void _selectCihaz(Cihaz cihaz) {
    setState(() {
      _selectedCihaz = cihaz;
      _cihazSearchController.text = '${cihaz.modelAdi} (${cihaz.seriNumarasi})';
      _showCihazSuggestions = false;
    });
  }

  void _updateTarihController() {
    _tarihController.text = _tarih == null ? '' : '${_tarih!.day.toString().padLeft(2, '0')}.${_tarih!.month.toString().padLeft(2, '0')}.${_tarih!.year}';
  }

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

  void _onKaydet() async {
    if (_selectedCihaz == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir cihaz seçin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    if (_musteriController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen müşteri/kurum adını girin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    if (_tarih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir tarih seçin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    if (_teknisyenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen teknisyen adını girin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    if (_aciklamaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir açıklama girin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    // Parça seçimi kontrolü
    if (_selectedParts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir parça ve adet seçin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }
    // Stoktan düşme işlemi
    for (final sp in _selectedParts) {
      await _stockRepository.decreaseQuantity(sp.part.parcaKodu, sp.adet);
    }
    Navigator.pop(context, {
      'formTipi': _formTipi,
      'cihazId': _selectedCihaz!.id,
      'musteri': _musteriController.text,
      'teknisyen': _teknisyenController.text,
      'aciklama': _aciklamaController.text,
      'tarih': _tarih,
      'kullanilanParcalar': _selectedParts.map((sp) => {'parcaKodu': sp.part.parcaKodu, 'parcaAdi': sp.part.parcaAdi, 'adet': sp.adet}).toList(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıt başarıyla eklendi!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
    );
  }

  Color _getStockStatusColor(StockPart part) {
    if (part.stokAdedi <= 5) {
      return const Color(0xFFFFC107); // Sarı - Düşük
    } else {
      return const Color(0xFF43A047); // Yeşil - Normal
    }
  }

  String _getStockStatusText(StockPart part) {
    if (part.stokAdedi <= 5) {
      return 'Düşük';
    } else {
      return 'Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateTarihController();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Yeni Servis Formu',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
            // Cihaz Bilgileri
            const Text('Cihaz Bilgileri', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            const Text('Cihaz', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            // Responsive cihaz seçimi
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            TextField(
                      controller: _cihazSearchController,
                      readOnly: false,
              decoration: InputDecoration(
                        hintText: 'Model, seri no veya müşteri ile ara...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                        suffixIcon: _selectedCihaz != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedCihaz = null;
                                    _cihazSearchController.clear();
                                    _showCihazSuggestions = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: _filterCihazlar,
                      onTap: () {
                        setState(() {
                          _showCihazSuggestions = true;
                        });
                      },
                    ),
                    if (_showCihazSuggestions && _filteredCihazlar.isNotEmpty)
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
                          itemCount: _filteredCihazlar.length,
                          itemBuilder: (context, index) {
                            final cihaz = _filteredCihazlar[index];
                            return ListTile(
                              title: Text('${cihaz.modelAdi} (${cihaz.seriNumarasi})'),
                              onTap: () => _selectCihaz(cihaz),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            const Text('Müşteri/Kurum Bilgisi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _musteriController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Müşteri veya kurum adını girin',
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
            // Fotoğraf ekleme alanı
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
            // Form Detayları
            const Text('Form Detayları', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            // Kurulum Tarihi başlığı
            const Text('Kurulum Tarihi', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              readOnly: true,
              controller: _tarihController,
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
                    if (picked != null) setState(() => _tarih = picked);
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
            // Teknisyen başlığı
            const Text('Teknisyen', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _teknisyenController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Teknisyen adını girin',
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
            // Kullanılan Parça başlığı
            const Text('Kullanılan Parçalar', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            // Parça arama kutusu
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
            // Modern kart tabanlı çoklu parça seçimi
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
                              child: Center(child: Text('Aradığınız parça bulunamadı', style: TextStyle(color: Colors.grey))),
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
                                            ? null
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
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text('Stok: ${part.stokAdedi}', style: const TextStyle(fontSize: 12, color: Color(0xFF23408E))),
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
                                                  : null,
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
            // Açıklama başlığı
            const Text('Açıklama', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _aciklamaController,
              keyboardType: TextInputType.text,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Yapılan işlemleri ve notlarınızı buraya yazın...',
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
            // Kaydet Butonu
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 12,
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