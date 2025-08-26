import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_history.dart';
import 'service_history_detail_screen.dart';
// Add Riverpod service history providers
import 'package:cence_app/features/service_history/providers.dart';
import 'package:cence_app/features/service_history/use_cases.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import '../widgets/common/cards/service_history_selectable_card.dart';

class AllServiceHistoryScreen extends ConsumerStatefulWidget {
  const AllServiceHistoryScreen({super.key});

  @override
  ConsumerState<AllServiceHistoryScreen> createState() =>
      _AllServiceHistoryScreenState();
}

class _AllServiceHistoryScreenState
    extends ConsumerState<AllServiceHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Tümü';
  final List<String> _statusOptions = [
    'Tümü',
    'Başarılı',
    'Arızalı',
    'Beklemede',
  ];

  // Sıralama seçenekleri
  String _selectedSortBy = 'En Yeni';
  final List<String> _sortOptions = ['En Yeni', 'En Eski'];

  // Toplu işlemler için
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};

  String getStatusLabel(String status) {
    switch (status) {
      case 'Başarılı':
        return 'Başarılı';
      case 'Beklemede':
        return 'Beklemede';
      case 'Arızalı':
        return 'Arızalı';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Başarılı':
        return const Color(0xFF43A047);
      case 'Beklemede':
        return const Color.fromARGB(255, 223, 238, 20);
      case 'Arızalı':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF23408E);
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case 'Başarılı':
        return const Color(0xFF43A047);
      case 'Beklemede':
        return const Color(0xFFFFC107);
      case 'Arızalı':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF43A047);
    }
  }

  Color getStatusTextColor(String status) {
    return Colors.white;
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Başarılı':
        return Icons.check_circle_rounded;
      case 'Beklemede':
        return Icons.hourglass_bottom_rounded;
      case 'Arızalı':
        return Icons.error_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  List<ServiceHistory> _filterAndSearchItems(List<ServiceHistory> items) {
    var filteredItems = items.where((item) {
      // Durum filtresi
      if (_selectedStatus != 'Tümü' && item.status != _selectedStatus) {
        return false;
      }

      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final deviceId = item.deviceId.toLowerCase();
        final description = item.description.toLowerCase();
        final technician = item.technician.toLowerCase();
        final musteri = item.musteri.toLowerCase();

        if (!deviceId.contains(query) &&
            !description.contains(query) &&
            !technician.contains(query) &&
            !musteri.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sıralama
    switch (_selectedSortBy) {
      case 'En Yeni':
        filteredItems.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'En Eski':
        filteredItems.sort((a, b) => a.date.compareTo(b.date));
        break;
    }

    return filteredItems;
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
              final delete = ref.read(deleteServiceHistoryUseCaseProvider);
              int failed = 0;
              for (final id in _selectedItems) {
                try {
                  await delete(id);
                } catch (e) {
                  failed += 1;
                }
              }

              // Listeyi yenile
              ref.invalidate(serviceHistoryListProvider);
              await ref.read(serviceHistoryListProvider.future);

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
                final success = selectedCount - failed;
                final msg = failed == 0
                    ? '$success kayıt silindi'
                    : '$success kayıt silindi, $failed başarısız';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(msg),
                      ],
                    ),
                    backgroundColor: failed == 0 ? Colors.green : Colors.orange,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isWide ? 90 : 70),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF23408E),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF23408E).withAlpha(51),
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
                      : 'Tüm Servis İşlemleri',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isWide ? 22 : 20,
                  ),
                ),
              ),
              if (!_isSelectionMode)
                IconButton(
                  icon: const Icon(
                    Icons.select_all,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _toggleSelectionMode,
                  tooltip: 'Toplu Seçim',
                ),
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
      body: Builder(
        builder: (context) {
          final asyncItems = ref.watch(serviceHistoryListProvider);
          return asyncItems.when(
            data: (allItems) {
              final filteredItems = _filterAndSearchItems(allItems);
              return Column(
                children: [
                  // Arama çubuğu
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
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
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFF23408E),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
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
                              onTap: () => _selectAllItems(filteredItems),
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
                  // Liste
                  Expanded(
                    child: filteredItems.isEmpty
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
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isSelected = _selectedItems.contains(
                                  item.id,
                                );

                                return ServiceHistorySelectableCard(
                                  item: item,
                                  isSelected: isSelected,
                                  isSelectionMode: _isSelectionMode,
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      _toggleItemSelection(item.id);
                                    } else {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              ServiceHistoryDetailScreen(
                                                serviceHistory: item,
                                              ),
                                          transitionsBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                        ),
                                      );
                                    }
                                  },
                                  onLongPress: () {
                                    if (!_isSelectionMode) {
                                      _toggleSelectionMode();
                                      _toggleItemSelection(item.id);
                                    }
                                  },
                                  onSelectionChanged: (value) {
                                    _toggleItemSelection(item.id);
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Veriler yüklenirken bir hata oluştu'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(serviceHistoryListProvider);
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Moved to widgets/common/cards/service_history_selectable_card.dart
