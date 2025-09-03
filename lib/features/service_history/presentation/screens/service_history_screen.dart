import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/models/service_history.dart';
import 'service_history_detail_screen.dart';
// Add Riverpod service history providers
import 'package:cence_app/features/service_history/providers.dart';
import 'package:cence_app/features/service_history/use_cases.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';

class ServisGecmisiScreen extends ConsumerStatefulWidget {
  const ServisGecmisiScreen({super.key});

  @override
  ConsumerState<ServisGecmisiScreen> createState() =>
      _ServisGecmisiScreenState();
}

class _ServisGecmisiScreenState extends ConsumerState<ServisGecmisiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Tümü';
  final List<String> _statusOptions = [
    'Tümü',
    'Kurulum',
    'Arıza',
  ];

  @override
  void initState() {
    super.initState();
    // Başarılı durumundaki kayıtları Kurulum olarak güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSuccessfulRecords();
    });
  }

  void _updateSuccessfulRecords() async {
    try {
      final serviceHistoryAsync = ref.read(serviceHistoryListProvider);
      await serviceHistoryAsync.whenData((list) async {
        int updatedCount = 0;
        for (var history in list) {
          if (history.status == 'Başarılı') {
            final updatedHistory = ServiceHistory(
              id: history.id,
              date: history.date,
              serialNumber: history.serialNumber,
              musteri: history.musteri,
              description: history.description,
              technician: history.technician,
              status: 'Kurulum',
              location: history.location,
              kullanilanParcalar: history.kullanilanParcalar,
              photos: history.photos,
            );
            
            final update = ref.read(updateServiceHistoryUseCaseProvider);
            await update(history.id, updatedHistory);
            updatedCount++;
          }
        }
        // Listeyi yenile
        ref.invalidate(serviceHistoryListProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$updatedCount kayıt güncellendi'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Güncelleme sırasında hata: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  // Sıralama seçenekleri
  String _selectedSortBy = 'En Yeni';
  final List<String> _sortOptions = ['En Yeni', 'En Eski'];

  // Toplu işlemler için
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};

  // Apply filters and sorting to given list
  List<ServiceHistory> _applyFilters(List<ServiceHistory> source) {
    List<ServiceHistory> list = List.from(source);

    // Durum filtresi
    if (_selectedStatus != 'Tümü') {
      list = list.where((k) => k.status == _selectedStatus).toList();
    }

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((item) {
        final serialNumber = item.serialNumber.toLowerCase();
        final description = item.description.toLowerCase();
        final technician = item.technician.toLowerCase();
        final musteri = item.musteri.toLowerCase();

        return serialNumber.contains(query) ||
            description.contains(query) ||
            technician.contains(query) ||
            musteri.contains(query);
      }).toList();
    }

    // Sıralama
    switch (_selectedSortBy) {
      case 'En Yeni':
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'En Eski':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
    }

    return list;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _onStatusFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedStatus = value;
      });
    }
  }

  void _onSortByChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedSortBy = value;
      });
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.clear();
      }
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _selectAllItems(List<ServiceHistory> items) {
    setState(() {
      _selectedItems.addAll(items.map((item) => item.id));
    });
  }

  // removed unused _deselectAllItems

  void _deleteSelectedItems() {
    final isAdmin = ref.read(isAdminProvider);
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silme yetkisi sadece admin kullanıcılar içindir.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_forever,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Seçili Kayıtları Sil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedItems.length} kayıt silinecek.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu işlem geri alınamaz.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF23408E),
            ),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final selectedCount = _selectedItems.length;
              try {
                final delete = ref.read(deleteServiceHistoryUseCaseProvider);
                for (final id in _selectedItems) {
                  await delete(id);
                }
                // Refresh list
                ref.invalidate(serviceHistoryListProvider);

                // BuildContext guard after async work
                if (!context.mounted) return;

                // Seçim modunu kapat
                if (mounted) {
                  setState(() {
                    _selectedItems.clear();
                    _isSelectionMode = false;
                  });
                }

                if (mounted) Navigator.of(context).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('$selectedCount kayıt silindi'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Silme işlemi sırasında hata: $e'),
                      backgroundColor: Colors.red.shade600,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final isAdmin = ref.watch(isAdminProvider);
    final asyncList = ref.watch(serviceHistoryListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isWide ? 90 : 70),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF23408E),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF23408E).withAlpha(51), // 0.2 * 255 ≈ 51
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + (isWide ? 10 : 6),
            left: isWide ? 32 : 18,
            right: isWide ? 32 : 18,
            bottom: isWide ? 12 : 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isSelectionMode
                      ? '${_selectedItems.length} seçili'
                      : 'Servis Geçmişi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isWide ? 22 : 20,
                  ),
                ),
              ),
              if (!_isSelectionMode) ...[  
                if (isAdmin)
                  IconButton(
                    icon: const Icon(
                      Icons.update_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: _updateSuccessfulRecords,
                    tooltip: 'Başarılı kayıtları Kurulum olarak güncelle',
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.select_all,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _toggleSelectionMode,
                  tooltip: 'Toplu Seçim',
                ),
              ],
              if (_isSelectionMode) ...[
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: _toggleSelectionMode,
                  tooltip: 'Seçimi İptal Et',
                ),
                if (_selectedItems.isNotEmpty &&
                    (ref.watch(isAdminProvider))) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: _deleteSelectedItems,
                    tooltip: 'Seçili Kayıtları Sil',
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13), // 0.05 * 255 ≈ 13
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cihaz ara...',
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Color(0xFF23408E)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Filtreler
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _statusOptions
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: _onStatusFilterChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSortBy,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _sortOptions
                            .map(
                              (sort) => DropdownMenuItem(
                                value: sort,
                                child: Text(sort),
                              ),
                            )
                            .toList(),
                        onChanged: _onSortByChanged,
                      ),
                    ),
                  ],
                ),
                // Seçim modunda "Tümünü Seç" bildirim çubuğu
                if (_isSelectionMode) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23408E).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF23408E).withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        final list = ref
                            .read(serviceHistoryListProvider)
                            .maybeWhen(
                              data: (l) => l,
                              orElse: () => <ServiceHistory>[],
                            );
                        final filtered = _applyFilters(list);
                        _selectAllItems(filtered);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.select_all,
                            color: const Color(0xFF23408E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tümünü Seç',
                            style: TextStyle(
                              color: const Color(0xFF23408E),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Servis geçmişi listesi
          Expanded(
            child: asyncList.when(
              data: (list) {
                final filteredHistory = _applyFilters(list);
                return filteredHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Servis geçmişi bulunamadı',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Filtreleri temizleyip tekrar deneyin',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(serviceHistoryListProvider);
                          await ref.read(serviceHistoryListProvider.future);
                          if (mounted) setState(() {});
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredHistory.length,
                          itemBuilder: (context, index) {
                            final kayit = filteredHistory[index];
                            final isSelected = _selectedItems.contains(
                              kayit.id,
                            );

                            return _ServisKaydiCard(
                              kayit: kayit,
                              isSelected: isSelected,
                              isSelectionMode: _isSelectionMode,
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleItemSelection(kayit.id);
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ServiceHistoryDetailScreen(
                                            serviceHistory: kayit,
                                          ),
                                    ),
                                  );
                                }
                              },
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  _toggleSelectionMode();
                                  _toggleItemSelection(kayit.id);
                                }
                              },
                              onSelectionChanged: (value) {
                                _toggleItemSelection(kayit.id);
                              },
                            );
                          },
                        ),
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  Center(child: Text('Veriler yüklenirken hata: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServisKaydiCard extends StatelessWidget {
  final ServiceHistory kayit;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onSelectionChanged;

  const _ServisKaydiCard({
    required this.kayit,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onSelectionChanged,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case 'Kurulum':
        return Colors.green.shade800;
      case 'Arıza':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Color getStatusTextColor(String status) {
    return Colors.white;
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'Kurulum':
        return 'Kurulum';
      case 'Arıza':
        return 'Arıza';
      default:
        return status;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Kurulum':
        return Icons.check_circle_rounded;
      case 'Arıza':
        return Icons.error_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFF23408E).withAlpha(5)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => onSelectionChanged(value ?? false),
                      activeColor: const Color(0xFF23408E),
                    ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getStatusBgColor(kayit.status).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      getStatusIcon(kayit.status),
                      size: isWide ? 20 : 18,
                      color: getStatusBgColor(kayit.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kayit.serialNumber,
                          style: TextStyle(
                            fontSize: isWide ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(kayit.date),
                          style: TextStyle(
                            fontSize: isWide ? 12 : 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusBgColor(kayit.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      getStatusLabel(kayit.status),
                      style: TextStyle(
                        fontSize: isWide ? 11 : 10,
                        fontWeight: FontWeight.bold,
                        color: getStatusTextColor(kayit.status),
                      ),
                    ),
                  ),
                ],
              ),
              if (kayit.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  kayit.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isWide ? 13 : 12,
                    color: Colors.black87,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23408E).withAlpha(26),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.person,
                      size: isWide ? 18 : 16,
                      color: const Color(0xFF23408E),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    kayit.technician,
                    style: TextStyle(
                      fontSize: isWide ? 14 : 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF23408E).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.visibility,
                        size: 16,
                        color: Color(0xFF23408E),
                      ),
                      label: const Text(
                        'Detaylar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF23408E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
