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

  final List<String> _categories = [
    'Elektronik', 'Mekanik', 'Sarf Malzeme', 'Diğer'
  ];

  @override
  void initState() {
    super.initState();
    _futureParts = widget.repository.getAll();
  }

  List<StockPart> get filteredParts {
    List<StockPart> parts = _allParts;
    if (search.isNotEmpty) {
      parts = parts.where((p) =>
        p.name.toLowerCase().contains(search.toLowerCase()) ||
        p.code.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    if (_filterType == 'critical') {
      parts = parts.where((p) => p.criticalLevel > 0 && p.quantity <= p.criticalLevel).toList();
    }
    // Sıralama
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
              const Text('Filtrele', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              RadioListTile<String>(
                value: 'all',
                groupValue: _filterType,
                onChanged: (val) {
                  setState(() => _filterType = val!);
                  Navigator.pop(context);
                },
                title: const Text('Tümünü Göster'),
              ),
              RadioListTile<String>(
                value: 'critical',
                groupValue: _filterType,
                onChanged: (val) {
                  setState(() => _filterType = val!);
                  Navigator.pop(context);
                },
                title: const Text('Sadece Kritik Seviyedekileri Göster'),
              ),
            ],
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
        title: const Text('Stok Takibi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Expanded(
                  child: grouped.isEmpty
                      ? const Center(child: Text('Aramanıza uygun parça bulunamadı.'))
                      : ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (ctx, catIdx) {
                            final cat = categories[catIdx];
                            final parts = grouped[cat]!;
                            return StockCategorySection(
                              category: cat,
                              parts: parts,
                              accentColor: const Color(0xFF00BFAE),
                              primaryColor: const Color(0xFF23408E),
                              criticalColor: const Color(0xFFFF7043),
                            );
                          },
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

class StockCategorySection extends StatelessWidget {
  final String category;
  final List<StockPart> parts;
  final Color accentColor;
  final Color primaryColor;
  final Color criticalColor;
  const StockCategorySection({
    required this.category,
    required this.parts,
    required this.accentColor,
    required this.primaryColor,
    required this.criticalColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: parts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) => StockPartCard(
            part: parts[i],
            accentColor: accentColor,
            primaryColor: primaryColor,
            criticalColor: criticalColor,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class StockPartCard extends StatelessWidget {
  final StockPart part;
  final Color accentColor;
  final Color primaryColor;
  final Color criticalColor;
  const StockPartCard({
    required this.part,
    required this.accentColor,
    required this.primaryColor,
    required this.criticalColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCritical = part.criticalLevel > 0 && part.quantity <= part.criticalLevel;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical ? criticalColor : Colors.grey.shade200,
          width: isCritical ? 2 : 1,
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
    );
  }
} 