import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/service_history.dart';
import '../providers/service_history_provider.dart';
import 'service_history_detail_screen.dart';

class AllServiceHistoryScreen extends StatefulWidget {
  const AllServiceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AllServiceHistoryScreen> createState() => _AllServiceHistoryScreenState();
}

class _AllServiceHistoryScreenState extends State<AllServiceHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Tümü';
  final List<String> _statusOptions = ['Tümü', 'Başarılı', 'Arızalı', 'Beklemede'];
  
  // Sıralama seçenekleri
  String _selectedSortBy = 'En Yeni';
  final List<String> _sortOptions = ['En Yeni', 'En Eski'];
  


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
        return Colors.blue.shade100;
      case 'Beklemede':
        return Colors.amber.shade200;
      case 'Arızalı':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color getStatusTextColor(String status) {
    switch (status) {
      case 'Başarılı':
        return Colors.blue.shade800;
      case 'Beklemede':
        return Colors.amber.shade800;
      case 'Arızalı':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
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
        return item.deviceId.toLowerCase().contains(query) ||
               item.musteri.toLowerCase().contains(query) ||
               item.technician.toLowerCase().contains(query) ||
               (item.description ?? '').toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
    
    // Sıralama uygula
    return _sortItems(filteredItems);
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

  List<ServiceHistory> _sortItems(List<ServiceHistory> items) {
    switch (_selectedSortBy) {
      case 'En Yeni':
        return items..sort((a, b) => b.date.compareTo(a.date));
      case 'En Eski':
        return items..sort((a, b) => a.date.compareTo(b.date));
      default:
        return items..sort((a, b) => b.date.compareTo(a.date));
    }
  }



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF23408E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Tüm Servis İşlemleri',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ServiceHistoryProvider>(
        builder: (context, serviceHistoryProvider, child) {
          final allItems = serviceHistoryProvider.all;
          final filteredItems = _filterAndSearchItems(allItems);
          
          return Column(
            children: [
              // Arama ve Filtreleme Bölümü
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    // Arama Çubuğu
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cihaz, müşteri, teknisyen veya açıklama ara...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF23408E)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Color(0xFF23408E)),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                                         const SizedBox(height: 12),
                     // Durum ve Sıralama Filtreleri
                     Row(
                       children: [
                         // Durum Filtresi
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text('Durum: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                               const SizedBox(height: 4),
                               DropdownButtonFormField<String>(
                                 value: _selectedStatus,
                                 decoration: InputDecoration(
                                   filled: true,
                                   fillColor: Colors.grey.shade50,
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(8),
                                     borderSide: BorderSide.none,
                                   ),
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 ),
                                 items: _statusOptions.map((status) => DropdownMenuItem(
                                   value: status,
                                   child: Text(status),
                                 )).toList(),
                                 onChanged: _onStatusFilterChanged,
                               ),
                             ],
                           ),
                         ),
                         const SizedBox(width: 12),
                         // Sıralama Filtresi
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text('Sıralama: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                               const SizedBox(height: 4),
                               DropdownButtonFormField<String>(
                                 value: _selectedSortBy,
                                 decoration: InputDecoration(
                                   filled: true,
                                   fillColor: Colors.grey.shade50,
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(8),
                                     borderSide: BorderSide.none,
                                   ),
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 ),
                                 items: _sortOptions.map((sort) => DropdownMenuItem(
                                   value: sort,
                                   child: Text(sort),
                                 )).toList(),
                                 onChanged: _onSortByChanged,
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                    const SizedBox(height: 8),
                    // Sonuç Sayısı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filteredItems.length} kayıt bulundu',
                          style: const TextStyle(
                            color: Color(0xFF23408E),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                                                 if (_searchQuery.isNotEmpty || _selectedStatus != 'Tümü' || _selectedSortBy != 'En Yeni')
                           TextButton.icon(
                             onPressed: () {
                               _searchController.clear();
                               setState(() {
                                 _searchQuery = '';
                                 _selectedStatus = 'Tümü';
                                 _selectedSortBy = 'En Yeni';
                               });
                             },
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Filtreleri Temizle'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF23408E),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Liste
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Arama kriterlerinize uygun kayıt bulunamadı',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredItems.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 18),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];

                          final statusBgColor = getStatusBgColor(item.status);
                          final statusTextColor = getStatusTextColor(item.status);
                          final statusIcon = getStatusIcon(item.status);
                          final statusLabel = getStatusLabel(item.status);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                              leading: Icon(statusIcon, color: getStatusTextColor(item.status), size: 32),
                              title: Text('${item.deviceId} - ${item.description}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1C))),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tarih: ${dateFormat.format(item.date)}', style: const TextStyle(fontSize: 13, color: Color(0xFF23408E))),
                                  Text('Müşteri/Kurum: ${item.musteri}', style: const TextStyle(fontSize: 13, color: Color(0xFF23408E), fontWeight: FontWeight.w600)),
                                  Text('Teknisyen: ${item.technician}', style: const TextStyle(fontSize: 13, color: Color(0xFF23408E))),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(statusLabel, style: TextStyle(color: statusTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => ServiceHistoryDetailScreen(serviceHistory: item),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
} 