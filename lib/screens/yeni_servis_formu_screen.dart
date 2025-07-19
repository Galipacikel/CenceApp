import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/stock_part.dart';

class YeniServisFormuScreen extends StatefulWidget {
  final StockPartRepository? stockRepository;
  const YeniServisFormuScreen({Key? key, this.stockRepository}) : super(key: key);

  @override
  State<YeniServisFormuScreen> createState() => _YeniServisFormuScreenState();
}

class _YeniServisFormuScreenState extends State<YeniServisFormuScreen> {
  int _formTipi = 0; // 0: Kurulum, 1: Bakım, 2: Arıza
  final TextEditingController _cihazController = TextEditingController();
  final TextEditingController _teknisyenController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
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
  final StockPartRepository _stockRepository = MockStockPartRepository();
  
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

  @override
  void initState() {
    super.initState();
    _tarihController = TextEditingController();
    _loadParts();
  }

  @override
  void dispose() {
    _cihazController.dispose();
    _teknisyenController.dispose();
    _aciklamaController.dispose();
    _tarihController.dispose();
    _partSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadParts() async {
    final parts = await _stockRepository.getAll();
    setState(() {
      _allParts = parts;
      _filteredParts = parts;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedPart = null;
      _partSearchController.clear();
      _showPartSuggestions = false;
      
      // Kategoriye göre parçaları filtrele
      if (category == 'Tüm Parçalar') {
        _filteredParts = _allParts;
      } else {
        _filteredParts = _allParts.where((part) => 
          (part.category ?? 'Diğer') == category
        ).toList();
      }
      
      // En çok kullanılan parçaları üste taşı (stok miktarı düşük olanlar)
      _filteredParts.sort((a, b) {
        final aIsCritical = a.criticalLevel > 0 && a.quantity <= a.criticalLevel;
        final bIsCritical = b.criticalLevel > 0 && b.quantity <= b.criticalLevel;
        
        if (aIsCritical && !bIsCritical) return -1;
        if (!aIsCritical && bIsCritical) return 1;
        return a.name.compareTo(b.name);
      });
    });
  }

  void _filterParts(String query) {
    setState(() {
      List<StockPart> baseParts;
      
      if (_selectedCategory == null || _selectedCategory == 'Tüm Parçalar') {
        baseParts = _allParts;
      } else {
        baseParts = _allParts.where((part) => 
          (part.category ?? 'Diğer') == _selectedCategory
        ).toList();
      }
      
      if (query.isEmpty) {
        _filteredParts = baseParts;
      } else {
        _filteredParts = baseParts.where((part) =>
          part.name.toLowerCase().contains(query.toLowerCase()) ||
          part.code.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      
      // En çok kullanılan parçaları üste taşı (stok miktarı düşük olanlar)
      _filteredParts.sort((a, b) {
        final aIsCritical = a.criticalLevel > 0 && a.quantity <= a.criticalLevel;
        final bIsCritical = b.criticalLevel > 0 && b.quantity <= b.criticalLevel;
        
        if (aIsCritical && !bIsCritical) return -1;
        if (!aIsCritical && bIsCritical) return 1;
        return a.name.compareTo(b.name);
      });
    });
  }

  void _selectPart(StockPart part) {
    setState(() {
      _selectedPart = part;
      _partSearchController.text = '${part.name} (${part.code})';
      _showPartSuggestions = false;
      _noPartInstalled = false;
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

  void _onKaydet() async {
    if (_cihazController.text.isEmpty || _teknisyenController.text.isEmpty || _aciklamaController.text.isEmpty || _tarih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }

    // Parça seçimi kontrolü
    if (!_noPartInstalled && _selectedPart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kullanılan parçayı seçin veya "Parça Takılmadı" işaretleyin.'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
      return;
    }

    // Eğer parça seçilmişse stoktan eksilt
    if (_selectedPart != null && !_noPartInstalled) {
      await _stockRepository.decreaseQuantity(_selectedPart!.code, 1);
    }

    // Mock veri olarak üst seviyeye dön
    Navigator.pop(context, {
      'formTipi': _formTipi,
      'cihaz': _cihazController.text,
      'teknisyen': _teknisyenController.text,
      'aciklama': _aciklamaController.text,
      'tarih': _tarih,
      'kullanilanParca': _selectedPart?.name,
      'parcaKodu': _selectedPart?.code,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıt başarıyla eklendi!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
    );
  }

  Color _getStockStatusColor(StockPart part) {
    if (part.criticalLevel > 0 && part.quantity <= part.criticalLevel) {
      return const Color(0xFFFF7043); // Kırmızı - Kritik
    } else if (part.quantity <= 5) {
      return const Color(0xFFFFC107); // Sarı - Düşük
    } else {
      return const Color(0xFF43A047); // Yeşil - Normal
    }
  }

  String _getStockStatusText(StockPart part) {
    if (part.criticalLevel > 0 && part.quantity <= part.criticalLevel) {
      return 'Kritik';
    } else if (part.quantity <= 5) {
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
            TextField(
              controller: _cihazController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Cihaz seri numarası veya adı',
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
            const Text('Kullanılan Parça', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 4),
            // Parça Takılmadı checkbox
            Row(
              children: [
                Checkbox(
                  value: _noPartInstalled,
                  onChanged: (value) {
                    setState(() {
                      _noPartInstalled = value ?? false;
                      if (_noPartInstalled) {
                        _selectedPart = null;
                        _partSearchController.clear();
                        _showPartSuggestions = false;
                        _selectedCategory = null;
                      }
                    });
                  },
                  activeColor: const Color(0xFF23408E),
                ),
                const Text('Parça Takılmadı', style: TextStyle(fontSize: 14)),
              ],
            ),
            // Parça seçimi alanı
            if (!_noPartInstalled) ...[
              // Kategori seçimi
              const SizedBox(height: 8),
              const Text('Kategori Seçin:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) => _CategoryChip(
                  label: category,
                  selected: _selectedCategory == category,
                  icon: _categoryIcons[category] ?? Icons.category,
                  color: _categoryColors[category] ?? const Color(0xFFB0B6C3),
                  onTap: () => _selectCategory(category),
                )).toList(),
              ),
              const SizedBox(height: 12),
              // Parça listesi
              if (_selectedCategory != null) ...[
                // Parça arama kutusu
                TextField(
                  controller: _partSearchController,
                  enabled: !_noPartInstalled,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: '${_selectedCategory} kategorisinde parça ara...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _filterParts,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: _filteredParts.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Bu kategoride parça bulunamadı',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredParts.length,
                          itemBuilder: (context, index) {
                            final part = _filteredParts[index];
                            final statusColor = _getStockStatusColor(part);
                            final statusText = _getStockStatusText(part);
                            final isSelected = _selectedPart?.code == part.code;
                            
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: const Color(0xFF23408E), width: 2) : null,
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(
                                  part.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Kod: ${part.code}'),
                                    Row(
                                      children: [
                                        Text('Stok: ${part.quantity}'),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: isSelected 
                                    ? const Icon(Icons.check_circle, color: Color(0xFF23408E))
                                    : null,
                                onTap: () => _selectPart(part),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ],
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