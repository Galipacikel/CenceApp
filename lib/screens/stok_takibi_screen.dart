import 'package:flutter/material.dart';
import '../models/stock_part.dart';

class StokTakibiScreen extends StatefulWidget {
  final StockPartRepository repository;
  StokTakibiScreen({Key? key, StockPartRepository? repository})
      : repository = repository ?? MockStockPartRepository(),
        super(key: key);

  @override
  State<StokTakibiScreen> createState() => _StokTakibiScreenState();
}

class _StokTakibiScreenState extends State<StokTakibiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String search = '';
  late Future<List<StockPart>> _futureParts;
  List<StockPart> _allParts = [];

  // Filtre ve sıralama için ek alanlar
  String _filterType = 'all'; // 'all' veya 'critical'
  String _sortType = 'none'; // 'none', 'quantity_asc', 'quantity_desc', 'date_asc', 'date_desc'

  // Gelişmiş filtreler
  List<String> _selectedCategories = [];
  int? _minQuantity;
  int? _maxQuantity;
  bool _onlyCritical = false;
  String _descSearch = '';

  // Toplu seçim için
  bool _selectionMode = false;
  final Set<StockPart> _selectedParts = {};

  final List<String> _categories = [
    'Elektronik', 'Mekanik', 'Sarf Malzeme', 'Diğer'
  ];

  // Kategori ikon ve renk eşlemesi
  final Map<String, IconData> _categoryIcons = {
    'Elektronik': Icons.memory,
    'Mekanik': Icons.settings,
    'Sarf Malzeme': Icons.cable,
    'Diğer': Icons.category,
  };
  final Map<String, Color> _categoryColors = {
    'Elektronik': Color(0xFF23408E),
    'Mekanik': Color(0xFF00BFAE),
    'Sarf Malzeme': Color(0xFFFF7043),
    'Diğer': Color(0xFFB0B6C3),
  };

  bool get _hasCriticalStock => filteredParts.any((p) => p.criticalLevel > 0 && p.quantity <= p.criticalLevel);
  int get _criticalCount => filteredParts.where((p) => p.criticalLevel > 0 && p.quantity <= p.criticalLevel).length;
  List<StockPart> get _criticalParts => filteredParts.where((p) => p.criticalLevel > 0 && p.quantity <= p.criticalLevel).toList();
  bool _showCriticalSummary = true;
  bool _forceDefaultSort = false;

  @override
  void initState() {
    super.initState();
    _futureParts = widget.repository.getAll();
  }

  List<StockPart> get filteredParts {
    List<StockPart> parts = _allParts;
    // Kategori filtresi
    if (_selectedCategories.isNotEmpty) {
      parts = parts.where((p) => _selectedCategories.contains(p.category ?? 'Diğer')).toList();
    }
    // Miktar aralığı filtresi
    if (_minQuantity != null) {
      parts = parts.where((p) => p.quantity >= _minQuantity!).toList();
    }
    if (_maxQuantity != null) {
      parts = parts.where((p) => p.quantity <= _maxQuantity!).toList();
    }
    // Açıklama/metin arama
    if (_descSearch.isNotEmpty) {
      parts = parts.where((p) => (p.description ?? '').toLowerCase().contains(_descSearch.toLowerCase())).toList();
    }
    // Kritik stok filtresi
    if (_onlyCritical) {
      parts = parts.where((p) => p.criticalLevel > 0 && p.quantity <= p.criticalLevel).toList();
    }
    // Eski arama (isim/kod)
    if (search.isNotEmpty) {
      parts = parts.where((p) =>
      p.name.toLowerCase().contains(search.toLowerCase()) ||
      p.code.toLowerCase().contains(search.toLowerCase())
    ).toList();
    }
    // Sıralama
    if (_forceDefaultSort) {
      parts.sort((a, b) => _parseDate(b.lastUpdate).compareTo(_parseDate(a.lastUpdate)));
    } else {
      switch (_sortType) {
        case 'quantity_asc':
          parts.sort((a, b) => a.quantity.compareTo(b.quantity));
          break;
        case 'quantity_desc':
          parts.sort((a, b) => b.quantity.compareTo(a.quantity));
          break;
        case 'date_asc':
          parts.sort((a, b) => _parseDate(a.lastUpdate).compareTo(_parseDate(b.lastUpdate)));
          break;
        case 'date_desc':
          parts.sort((a, b) => _parseDate(b.lastUpdate).compareTo(_parseDate(a.lastUpdate)));
          break;
        default:
          break;
      }
    }
    return parts;
  }

  DateTime _parseDate(String dateStr) {
    // Beklenen format: 'dd.MM.yyyy'
    try {
      final parts = dateStr.split('.');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return DateTime(1970);
  }

  void _showFilterSheet() {
    final allCats = _categories;
    final minQtyCtrl = TextEditingController(text: _minQuantity?.toString() ?? '');
    final maxQtyCtrl = TextEditingController(text: _maxQuantity?.toString() ?? '');
    final descCtrl = TextEditingController(text: _descSearch);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filtrele', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
                    Wrap(
                      spacing: 8,
                      children: allCats.map((cat) => FilterChip(
                        label: Text(cat),
                        selected: _selectedCategories.contains(cat),
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              _selectedCategories.add(cat);
                            } else {
                              _selectedCategories.remove(cat);
                            }
                          });
                        },
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: minQtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Min. Miktar',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => setModalState(() {
                              _minQuantity = int.tryParse(val);
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: maxQtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Maks. Miktar',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => setModalState(() {
                              _maxQuantity = int.tryParse(val);
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama/metin içinde ara',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setModalState(() {
                        _descSearch = val;
                      }),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _onlyCritical,
                      onChanged: (val) => setModalState(() => _onlyCritical = val ?? false),
                      title: const Text('Sadece kritik seviyedekileri göster'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategories.clear();
                                _minQuantity = null;
                                _maxQuantity = null;
                                _descSearch = '';
                                _onlyCritical = false;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Temizle'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23408E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Uygula', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sırala', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _SortRadio(
                groupValue: _sortType,
                value: 'quantity_asc',
                label: 'Miktar (Artan)',
                onChanged: (val) {
                  setState(() => _sortType = val);
                  Navigator.pop(context);
                },
              ),
              _SortRadio(
                groupValue: _sortType,
                value: 'quantity_desc',
                label: 'Miktar (Azalan)',
                onChanged: (val) {
                  setState(() => _sortType = val);
                  Navigator.pop(context);
                },
              ),
              _SortRadio(
                groupValue: _sortType,
                value: 'date_asc',
                label: 'Son Güncelleme (En Eski)',
                onChanged: (val) {
                  setState(() => _sortType = val);
                  Navigator.pop(context);
                },
              ),
              _SortRadio(
                groupValue: _sortType,
                value: 'date_desc',
                label: 'Son Güncelleme (En Yeni)',
                onChanged: (val) {
                  setState(() => _sortType = val);
                  Navigator.pop(context);
                },
              ),
              _SortRadio(
                groupValue: _sortType,
                value: 'none',
                label: 'Varsayılan',
                onChanged: (val) {
                  setState(() => _sortType = val);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddPartSheet() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController codeCtrl = TextEditingController();
    final TextEditingController qtyCtrl = TextEditingController();
    final TextEditingController critCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedCategory;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Yeni Parça Ekle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(errorText!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                        ),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Parça Adı',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Parça adı zorunlu' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: codeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Kod',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Kod zorunlu' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: qtyCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Miktar',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Miktar zorunlu';
                                final n = int.tryParse(v);
                                if (n == null || n < 0) return 'Geçerli bir miktar girin';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: critCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Kritik Seviye',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Kritik seviye zorunlu';
                                final n = int.tryParse(v);
                                if (n == null || n < 0) return 'Geçerli bir seviye girin';
                                if (qtyCtrl.text.isNotEmpty && int.tryParse(qtyCtrl.text) != null && n > int.parse(qtyCtrl.text)) {
                                  return 'Kritik seviye miktardan büyük olamaz';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setModalState(() => selectedDate = picked);
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Son Güncelleme Tarihi',
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Açıklama (isteğe bağlı)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: _categories.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        )).toList(),
                        onChanged: (val) => setModalState(() => selectedCategory = val),
                        decoration: const InputDecoration(
                          labelText: 'Kategori (isteğe bağlı)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Ekle', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF23408E),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Kodun benzersizliğini kontrol et
                              final exists = _allParts.any((p) => p.code.trim() == codeCtrl.text.trim());
                              if (exists) {
                                setModalState(() => errorText = 'Bu kodda bir parça zaten mevcut!');
                                return;
                              }
                              setState(() {
                                _allParts.insert(0, StockPart(
                                  name: nameCtrl.text.trim(),
                                  code: codeCtrl.text.trim(),
                                  quantity: int.parse(qtyCtrl.text),
                                  lastUpdate: '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                                  criticalLevel: int.parse(critCtrl.text),
                                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                                  category: selectedCategory,
                                ));
                              });
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Map<String, List<StockPart>> get groupedParts {
    final Map<String, List<StockPart>> map = {};
    for (final part in filteredParts) {
      final cat = part.category ?? 'Diğer';
      map.putIfAbsent(cat, () => []).add(part);
    }
    return map;
  }

  List<String> get sortedCategories {
    final cats = groupedParts.keys.toList();
    cats.sort((a, b) => a.compareTo(b));
    return cats;
  }

  void _startSelection(StockPart part) {
    setState(() {
      _selectionMode = true;
      _selectedParts.add(part);
    });
  }

  void _toggleSelection(StockPart part) {
    setState(() {
      if (_selectedParts.contains(part)) {
        _selectedParts.remove(part);
        if (_selectedParts.isEmpty) _selectionMode = false;
      } else {
        _selectedParts.add(part);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectionMode = false;
      _selectedParts.clear();
    });
  }

  void _deleteSelectedParts() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Toplu Silme Onayı', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '${_selectedParts.length} parça silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
          style: const TextStyle(fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete, color: Colors.white, size: 20),
            label: const Text('Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _allParts.removeWhere((p) => _selectedParts.contains(p));
        _selectionMode = false;
        _selectedParts.clear();
      });
    }
  }

  void _toggleCriticalFilter() {
    setState(() {
      if (!_onlyCritical) {
        _onlyCritical = true;
        _forceDefaultSort = false;
      } else {
        _onlyCritical = false;
        _forceDefaultSort = true;
      }
    });
    // Varsayılan sıralama modunu bir sonraki tıklamada kapatmak için timer ile resetle
    if (_forceDefaultSort) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _forceDefaultSort = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF23408E); // Lacivert
    final Color accentColor = const Color(0xFF00BFAE); // Turkuaz
    final Color criticalColor = const Color(0xFFFF7043); // Turuncu
    final Color backgroundColor = const Color(0xFFF6F8FA); // Açık gri
    final Color cardColor = Colors.white;
    final Color borderColor = Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _selectionMode
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: _cancelSelection,
                  ),
                  const SizedBox(width: 8),
                  Text('${_selectedParts.length} seçili', style: const TextStyle(color: Colors.black)),
                ],
              )
            : const Text('Stok Takibi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Seçili Parçaları Sil',
              onPressed: _selectedParts.isEmpty ? null : _deleteSelectedParts,
            )
          else
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<StockPart>>(
        future: _futureParts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Stokta parça bulunamadı.'));
          }
          _allParts = snapshot.data!;
          final grouped = groupedParts;
          final categories = sortedCategories;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern arama çubuğu
                Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Parça adı veya kodu ile ara',
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                          ),
                      filled: true,
                      fillColor: cardColor,
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => search = val),
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Parçalar (${filteredParts.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    Row(
                      children: [
                        _ModernButton(
                          icon: Icons.filter_alt_outlined,
                          label: 'Filtrele',
                          onTap: _showFilterSheet,
                        ),
                        const SizedBox(width: 8),
                        _ModernButton(
                          icon: Icons.sort,
                          label: 'Sırala',
                          onTap: _showSortSheet,
                    ),
                  ],
                ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_showCriticalSummary)
                  _CriticalStockSummary(
                    hasCritical: _hasCriticalStock,
                    count: _criticalCount,
                    parts: _criticalParts,
                    onTap: _toggleCriticalFilter,
                    onlyCriticalActive: _onlyCritical,
                    onClose: () => setState(() => _showCriticalSummary = false),
                  ),
                if (_showCriticalSummary) const SizedBox(height: 12),
                Expanded(
                  child: grouped.isEmpty
                      ? const Center(child: Text('Aramanıza uygun parça bulunamadı.'))
                      : CustomScrollView(
                          slivers: [
                            for (final cat in categories)
                              _CategorySliverSection(
                                category: cat,
                                parts: grouped[cat]!,
                                icon: _categoryIcons[cat] ?? Icons.category,
                                color: _categoryColors[cat] ?? const Color(0xFFB0B6C3),
                                accentColor: const Color(0xFF00BFAE),
                                primaryColor: const Color(0xFF23408E),
                                criticalColor: const Color(0xFFFF7043),
                                selectionMode: _selectionMode,
                                selectedParts: _selectedParts,
                                onLongPressPart: _startSelection,
                                onTapPart: _toggleSelection,
                              ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPartSheet,
        backgroundColor: const Color(0xFF23408E),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Parça Ekle',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ModernButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ModernButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class _SortRadio extends StatelessWidget {
  final String groupValue;
  final String value;
  final String label;
  final ValueChanged<String> onChanged;
  const _SortRadio({required this.groupValue, required this.value, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: (val) => onChanged(val!),
      title: Text(label),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _CategorySliverSection extends StatelessWidget {
  final String category;
  final List<StockPart> parts;
  final IconData icon;
  final Color color;
  final Color accentColor;
  final Color primaryColor;
  final Color criticalColor;
  final bool selectionMode;
  final Set<StockPart> selectedParts;
  final void Function(StockPart part)? onLongPressPart;
  final void Function(StockPart part)? onTapPart;
  const _CategorySliverSection({
    required this.category,
    required this.parts,
    required this.icon,
    required this.color,
    required this.accentColor,
    required this.primaryColor,
    required this.criticalColor,
    this.selectionMode = false,
    this.selectedParts = const {},
    this.onLongPressPart,
    this.onTapPart,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _CategoryHeaderDelegate(
            category: category,
            icon: icon,
            color: color,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: StockPartCard(
                part: parts[i],
                accentColor: accentColor,
                primaryColor: primaryColor,
                criticalColor: criticalColor,
                selectionMode: selectionMode,
                selected: selectedParts.contains(parts[i]),
                onLongPress: onLongPressPart,
                onTap: onTapPart,
              ),
            ),
            childCount: parts.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String category;
  final IconData icon;
  final Color color;
  _CategoryHeaderDelegate({required this.category, required this.icon, required this.color});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white.withOpacity(0.97),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            category,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return oldDelegate.category != category || oldDelegate.icon != icon || oldDelegate.color != color;
  }
}

class StockPartCard extends StatelessWidget {
  final StockPart part;
  final Color accentColor;
  final Color primaryColor;
  final Color criticalColor;
  final bool selectionMode;
  final bool selected;
  final void Function(StockPart part)? onLongPress;
  final void Function(StockPart part)? onTap;
  const StockPartCard({
    required this.part,
    required this.accentColor,
    required this.primaryColor,
    required this.criticalColor,
    this.selectionMode = false,
    this.selected = false,
    this.onLongPress,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCritical = part.criticalLevel > 0 && part.quantity <= part.criticalLevel;
    return GestureDetector(
      onLongPress: () => onLongPress?.call(part),
      onTap: selectionMode ? () => onTap?.call(part) : () => _showDetailModal(context),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE3F0FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? const Color(0xFF23408E) : (isCritical ? criticalColor : Colors.grey.shade200),
                width: selected ? 2.5 : (isCritical ? 2 : 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 2),
                    child: Icon(
                      selected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: selected ? const Color(0xFF23408E) : Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kod: ${part.code}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      if (part.description != null && part.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Colors.blueGrey),
                              SizedBox(width: 4),
                              Flexible(child: Text(part.description!, style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade700))),
                            ],
                          ),
                        ),
                const SizedBox(height: 8),
                Row(
                  children: [
                          Icon(Icons.inventory_2, size: 18, color: accentColor),
                          const SizedBox(width: 4),
                          Text('Miktar: ', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
                          Text('${part.quantity}', style: TextStyle(fontWeight: FontWeight.bold, color: isCritical ? criticalColor : primaryColor)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Son Güncelleme: ${part.lastUpdate}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 4),
                      if (part.category != null)
                        Row(
                          children: [
                            const Icon(Icons.label, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(part.category!, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                    ],
                  ),
                ),
                if (isCritical)
                  Column(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: criticalColor, size: 28),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: criticalColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Kritik Seviye!',
                          style: TextStyle(
                            color: Color(0xFFFF7043),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => _StockPartDetailModal(part: part),
    );
  }
}

class _StockPartDetailModal extends StatefulWidget {
  final StockPart part;
  const _StockPartDetailModal({required this.part, Key? key}) : super(key: key);

  @override
  State<_StockPartDetailModal> createState() => _StockPartDetailModalState();
}

class _StockPartDetailModalState extends State<_StockPartDetailModal> {
  bool _editMode = false;
  late TextEditingController nameCtrl;
  late TextEditingController codeCtrl;
  late TextEditingController qtyCtrl;
  late TextEditingController critCtrl;
  late TextEditingController descCtrl;
  String? selectedCategory;
  DateTime? selectedDate;
  String? errorText;
  final _formKey = GlobalKey<FormState>();
  late String _originalCode;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.part.name);
    codeCtrl = TextEditingController(text: widget.part.code);
    qtyCtrl = TextEditingController(text: widget.part.quantity.toString());
    critCtrl = TextEditingController(text: widget.part.criticalLevel.toString());
    descCtrl = TextEditingController(text: widget.part.description ?? '');
    selectedCategory = widget.part.category;
    selectedDate = _parseDate(widget.part.lastUpdate);
    _originalCode = widget.part.code;
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('.');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return DateTime.now();
  }

  void _saveEdit() {
    final name = nameCtrl.text.trim();
    final code = codeCtrl.text.trim();
    final qty = int.tryParse(qtyCtrl.text);
    final crit = int.tryParse(critCtrl.text);
    if (name.isEmpty || code.isEmpty || qty == null || crit == null) {
      setState(() => errorText = 'Tüm zorunlu alanları doldurun.');
      return;
    }
    final stokTakibiState = context.findAncestorStateOfType<_StokTakibiScreenState>();
    if (stokTakibiState != null) {
      final exists = stokTakibiState._allParts.any((p) => p.code == code && p.code != _originalCode);
      if (exists) {
        setState(() => errorText = 'Bu kodda başka bir parça mevcut!');
        return;
      }
      setState(() => errorText = null);
      stokTakibiState.setState(() {
        final idx = stokTakibiState._allParts.indexWhere((p) => p.code == _originalCode);
        if (idx != -1) {
          stokTakibiState._allParts[idx] = StockPart(
            name: name,
            code: code,
            quantity: qty,
            lastUpdate: selectedDate == null ? widget.part.lastUpdate : '${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}',
            criticalLevel: crit,
            description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
            category: selectedCategory,
            movements: widget.part.movements,
          );
        }
      });
      Navigator.pop(context);
    }
  }

  void _deletePart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Silme Onayı', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Bu parçayı silmek üzeresiniz. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete, color: Colors.white, size: 20),
            label: const Text('Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final stokTakibiState = context.findAncestorStateOfType<_StokTakibiScreenState>();
      if (stokTakibiState != null) {
        stokTakibiState.setState(() {
          stokTakibiState._allParts.removeWhere((p) => p.code == _originalCode);
        });
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Elektronik', 'Mekanik', 'Sarf Malzeme', 'Diğer'];
                      return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
                        child: Column(
          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                Text(_editMode ? 'Parçayı Düzenle' : 'Parça Detayı', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(errorText!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
              ),
            if (_editMode)
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Parça Adı', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Parça adı zorunlu' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(labelText: 'Kod', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Kod zorunlu' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: qtyCtrl,
                            decoration: const InputDecoration(labelText: 'Miktar', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Miktar zorunlu';
                              final n = int.tryParse(v);
                              if (n == null || n < 0) return 'Geçerli bir miktar girin';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: critCtrl,
                            decoration: const InputDecoration(labelText: 'Kritik Seviye', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Kritik seviye zorunlu';
                              final n = int.tryParse(v);
                              if (n == null || n < 0) return 'Geçerli bir seviye girin';
                              if (qtyCtrl.text.isNotEmpty && int.tryParse(qtyCtrl.text) != null && n > int.parse(qtyCtrl.text)) {
                                return 'Kritik seviye miktardan büyük olamaz';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Son Güncelleme Tarihi',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: selectedDate == null ? '' : '${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedCategory = val),
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text('Kaydet', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23408E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveEdit();
                          }
                        },
                  ),
                ),
              ],
                ),
              )
            else ...[
              _DetailRow(label: 'Parça Adı', value: widget.part.name),
              _DetailRow(label: 'Kod', value: widget.part.code),
              _DetailRow(label: 'Miktar', value: widget.part.quantity.toString()),
              _DetailRow(label: 'Kritik Seviye', value: widget.part.criticalLevel.toString()),
              _DetailRow(label: 'Son Güncelleme', value: widget.part.lastUpdate),
              if (widget.part.description != null && widget.part.description!.isNotEmpty)
                _DetailRow(label: 'Açıklama', value: widget.part.description!),
              if (widget.part.category != null)
                _DetailRow(label: 'Kategori', value: widget.part.category!),
              if (!_editMode && widget.part.movements != null && widget.part.movements!.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('Stok Hareketleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Row(
                          children: const [
                            Expanded(flex: 2, child: Text('Tarih', style: TextStyle(fontWeight: FontWeight.w600))),
                            Expanded(flex: 2, child: Text('İşlem', style: TextStyle(fontWeight: FontWeight.w600))),
                            Expanded(flex: 1, child: Text('Miktar', style: TextStyle(fontWeight: FontWeight.w600))),
                            Expanded(flex: 3, child: Text('Açıklama', style: TextStyle(fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ...widget.part.movements!.map((m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(m.date)),
                            Expanded(flex: 2, child: Text(m.type)),
                            Expanded(flex: 1, child: Text(m.amount.toString())),
                            Expanded(flex: 3, child: Text(m.description ?? '-')),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Sil', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _deletePart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Düzenle', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF23408E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => setState(() => _editMode = true),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _CriticalStockSummary extends StatelessWidget {
  final bool hasCritical;
  final int count;
  final List<StockPart> parts;
  final VoidCallback onTap;
  final bool onlyCriticalActive;
  final VoidCallback onClose;
  const _CriticalStockSummary({
    required this.hasCritical,
    required this.count,
    required this.parts,
    required this.onTap,
    required this.onlyCriticalActive,
    required this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = hasCritical
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFF6F8FA);
    final Color borderColor = hasCritical
        ? const Color(0xFFFF7043)
        : Colors.grey.shade300;
    final Color textColor = hasCritical
        ? const Color(0xFFFF7043)
        : Colors.black54;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: hasCritical ? onTap : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    hasCritical ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: textColor,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: hasCritical
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$count kritik stok',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (parts.isNotEmpty)
                                Text(
                                  'En kritik: ${parts.first.name} (${parts.first.quantity} adet)',
                                  style: TextStyle(color: textColor, fontSize: 14),
                                ),
                              if (!onlyCriticalActive)
                                const Text(
                                  'Kritik stokları görmek için kutuya tıklayın',
                                  style: TextStyle(fontSize: 13, color: Colors.black54),
                                ),
                              if (onlyCriticalActive)
                                const Text(
                                  'Tüm stokları görmek için tekrar tıklayın',
                                  style: TextStyle(fontSize: 13, color: Colors.black54),
                                ),
                            ],
                          )
                        : const Text(
                            'Kritik seviyede stok yok',
                            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                  ),
                ],
              ),
            ),
          ),
          // X (kapat) butonu
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 22, color: Colors.black38),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 