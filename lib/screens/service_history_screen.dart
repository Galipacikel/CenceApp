import 'package:flutter/material.dart';
import '../models/service_history.dart';
import 'package:provider/provider.dart';
import '../providers/service_history_provider.dart';
import 'service_history_detail_screen.dart';

class ServisGecmisiScreen extends StatefulWidget {
  
  ServisGecmisiScreen({Key? key}) : super(key: key);

  @override
  State<ServisGecmisiScreen> createState() => _ServisGecmisiScreenState();
}

class _ServisGecmisiScreenState extends State<ServisGecmisiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Tümü';
  final List<String> _statusOptions = ['Tümü', 'Başarılı', 'Arızalı', 'Beklemede'];
  
  // Sıralama seçenekleri
  String _selectedSortBy = 'En Yeni';
  final List<String> _sortOptions = ['En Yeni', 'En Eski'];

  @override
  void initState() {
    super.initState();
  }

  List<ServiceHistory> get filteredHistory {
    List<ServiceHistory> list = List.from(Provider.of<ServiceHistoryProvider>(context).all);
    
    // Durum filtresi
    if (_selectedStatus != 'Tümü') {
      list = list.where((k) => k.status == _selectedStatus).toList();
    }
    
    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((item) {
        final deviceId = item.deviceId.toLowerCase();
        final description = item.description.toLowerCase();
        final technician = item.technician.toLowerCase();
        final musteri = item.musteri.toLowerCase();
        
        return deviceId.contains(query) || 
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final filteredHistory = this.filteredHistory;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isWide ? 90 : 70),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF23408E),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF23408E).withOpacity(0.2),
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Servis Geçmişi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isWide ? 22 : 20,
                  ),
                ),
              ),
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
                  color: Colors.black.withOpacity(0.05),
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
            child: Row(
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _statusOptions.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    )).toList(),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _sortOptions.map((sort) => DropdownMenuItem(
                      value: sort,
                      child: Text(sort),
                    )).toList(),
                    onChanged: _onSortByChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Servis geçmişi listesi
          Expanded(
            child: filteredHistory.isEmpty
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
                      await Future.delayed(const Duration(seconds: 1));
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final kayit = filteredHistory[index];
                        return _ServisKaydiCard(kayit: kayit);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ServisKaydiCard extends StatelessWidget {
  final ServiceHistory kayit;
  const _ServisKaydiCard({required this.kayit, Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 
                   'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
            colors: [
              Colors.white,
              const Color(0xFF23408E).withOpacity(0.02),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getStatusBgColor(kayit.status).withOpacity(0.1),
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
                          kayit.deviceId,
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      color: const Color(0xFF23408E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.person, size: isWide ? 18 : 16, color: const Color(0xFF23408E)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    kayit.technician,
                    style: TextStyle(fontSize: isWide ? 14 : 12, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF23408E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      icon: const Icon(Icons.visibility, size: 16, color: Color(0xFF23408E)),
                      label: const Text('Detaylar', style: TextStyle(fontSize: 12, color: Color(0xFF23408E), fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ServiceHistoryDetailScreen(serviceHistory: kayit),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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