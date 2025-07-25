import 'package:flutter/material.dart';
import '../models/service_history.dart';
import 'package:provider/provider.dart';
import '../providers/service_history_provider.dart';
import '../providers/app_state_provider.dart';

class ServisGecmisiScreen extends StatefulWidget {
  // final ServiceHistoryRepository repository;
  // ServisGecmisiScreen({Key? key, ServiceHistoryRepository? repository})
  //     : repository = repository ?? MockServiceHistoryRepository(),
  //       super(key: key);
  ServisGecmisiScreen({Key? key}) : super(key: key);

  @override
  State<ServisGecmisiScreen> createState() => _ServisGecmisiScreenState();
}

class _ServisGecmisiScreenState extends State<ServisGecmisiScreen> {
  String? selectedStatus;
  String? selectedSort;
  String? selectedDevice;
  String searchText = '';
  final TextEditingController _searchController = TextEditingController();

  // late Future<List<ServiceHistory>> _futureHistory;
  // List<ServiceHistory> _allHistory = [];

  @override
  void initState() {
    super.initState();
    // _futureHistory = widget.repository.getAll();
  }

  List<String> get deviceList {
    final allHistory = Provider.of<ServiceHistoryProvider>(context, listen: false).all;
    return allHistory.map((k) => k.deviceId).toSet().toList();
  }

  List<String> get filteredDevices {
    if (searchText.isEmpty) return deviceList;
    return deviceList.where((c) => c.toLowerCase().contains(searchText.toLowerCase())).toList();
  }

  List<ServiceHistory> get filteredHistory {
    List<ServiceHistory> list = List.from(Provider.of<ServiceHistoryProvider>(context).all);
    if (selectedStatus != null) {
      list = list.where((k) => k.status == selectedStatus).toList();
    }
    if (selectedDevice != null) {
      list = list.where((k) => k.deviceId == selectedDevice).toList();
    }
    if (selectedSort == 'Tarih (Yeni > Eski)') {
      list.sort((a, b) => b.date.compareTo(a.date));
    } else if (selectedSort == 'Tarih (Eski > Yeni)') {
      list.sort((a, b) => a.date.compareTo(b.date));
    }
    return list;
  }

  void _showFilterDialog() async {
    final result = await showModalBottomSheet<Map<String, String?>> (
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Duruma Göre Filtrele', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Tümü'),
                    selected: selectedStatus == null,
                    onSelected: (_) => Navigator.pop(ctx, {'status': null, 'device': selectedDevice}),
                  ),
                  FilterChip(
                    label: const Text('Başarılı'),
                    selected: selectedStatus == 'Başarılı',
                    onSelected: (_) => Navigator.pop(ctx, {'status': 'Başarılı', 'device': selectedDevice}),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Cihaza Göre Filtrele', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Tümü'),
                    selected: selectedDevice == null,
                    onSelected: (_) => Navigator.pop(ctx, {'status': selectedStatus, 'device': null}),
                  ),
                  ...deviceList.map((c) => FilterChip(
                    label: Text(c),
                    selected: selectedDevice == c,
                    onSelected: (_) => Navigator.pop(ctx, {'status': selectedStatus, 'device': c}),
                  )),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        selectedStatus = result['status'];
        selectedDevice = result['device'];
      });
    }
  }

  void _showSortDialog() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sırala', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Tarih (Yeni > Eski)'),
                leading: Radio<String>(
                  value: 'Tarih (Yeni > Eski)',
                  groupValue: selectedSort,
                  onChanged: (v) => Navigator.pop(ctx, v),
                ),
              ),
              ListTile(
                title: const Text('Tarih (Eski > Yeni)'),
                leading: Radio<String>(
                  value: 'Tarih (Eski > Yeni)',
                  groupValue: selectedSort,
                  onChanged: (v) => Navigator.pop(ctx, v),
                ),
              ),
              ListTile(
                title: const Text('Varsayılan'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: selectedSort,
                  onChanged: (v) => Navigator.pop(ctx, v),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        selectedSort = result;
      });
    }
  }

  void guncelleKayit(ServiceHistory eski, Map<String, dynamic> yeni) {
    setState(() {
      final idx = Provider.of<ServiceHistoryProvider>(context, listen: false).all.indexOf(eski);
      if (idx != -1) {
        Provider.of<ServiceHistoryProvider>(context, listen: false).update(idx, {
          'tarih': _parseDate(yeni['tarih']),
          'cihaz': yeni['cihaz'] ?? 'CIHAZ-001',
          'musteri': yeni['musteri'] ?? '',
          'baslik': yeni['baslik'] ?? '',
          'aciklama': yeni['aciklama'] != null ? ' - ${yeni['aciklama']}' : '',
          'kisi': yeni['kisi'] ?? '',
          'durum': yeni['durum'] ?? '',
        });
      }
    });
  }
  void silKayit(ServiceHistory kayit) {
    setState(() {
      Provider.of<ServiceHistoryProvider>(context, listen: false).delete(kayit.id);
    });
  }

  DateTime _parseDate(String? date) {
    if (date == null) return DateTime.now();
    final months = {
      'Ocak': 1, 'Şubat': 2, 'Mart': 3, 'Nisan': 4, 'Mayıs': 5, 'Haziran': 6,
      'Temmuz': 7, 'Ağustos': 8, 'Eylül': 9, 'Ekim': 10, 'Kasım': 11, 'Aralık': 12,
    };
    final parts = date.split(' ');
    if (parts.length != 3) return DateTime.now();
    final day = int.tryParse(parts[0]);
    final month = months[parts[1]];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return DateTime.now();
    return DateTime(year, month, day);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23408E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Servis Geçmişi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            onPressed: _showSortDialog,
            tooltip: 'Sırala',
          ),
        ],
      ),
      body: Consumer<ServiceHistoryProvider>(
        builder: (context, provider, _) {
          final allHistory = provider.all;
          if (allHistory.isEmpty) {
            return const Center(child: Text('Kayıt bulunamadı.'));
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? MediaQuery.of(context).size.width * 0.2 : 16,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cihaz Seçimi
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cihaz Seçimi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Cihaz ara veya listeden seç...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: const Color(0xFFF5F6FA),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: selectedDevice != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          selectedDevice = null;
                                          _searchController.clear();
                                          searchText = '';
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (val) {
                              setState(() {
                                searchText = val;
                              });
                            },
                            onTap: () {
                              setState(() {
                                searchText = _searchController.text;
                              });
                            },
                            readOnly: selectedDevice != null,
                          ),
                          if (searchText.isNotEmpty && selectedDevice == null)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 54,
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(10),
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  children: filteredDevices.isEmpty
                                      ? [
                                          const ListTile(
                                            title: Text('Sonuç bulunamadı'),
                                          ),
                                        ]
                                      : filteredDevices.map((device) => ListTile(
                                            title: Text(device),
                                            onTap: () {
                                              setState(() {
                                                selectedDevice = device;
                                                _searchController.text = device;
                                                searchText = '';
                                              });
                                            },
                                          )).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Servis Kayıtları başlık ve filtre/sırala
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      const Text('Servis Kayıtları', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.filter_alt_outlined, size: 22),
                        onPressed: _showFilterDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.sort, size: 22),
                        onPressed: _showSortDialog,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Servis kayıtları listesi veya boş ekran
                filteredHistory.isEmpty
                    ? Container(
                        margin: const EdgeInsets.only(top: 40),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.inbox_rounded, size: 60, color: Color(0xFFB0B6C3)),
                            SizedBox(height: 16),
                            Text('Kayıt bulunamadı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF23408E))),
                            SizedBox(height: 8),
                            Text('Seçili filtre veya arama ile eşleşen servis kaydı yok.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.black54)),
                          ],
                        ),
                      )
                    : _ServisKayitListesi(kayitlar: filteredHistory, deviceList: deviceList),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ServisKayitListesi extends StatelessWidget {
  final List<ServiceHistory> kayitlar;
  final List<String> deviceList;
  const _ServisKayitListesi({required this.kayitlar, required this.deviceList, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: kayitlar.map((k) => _ServisKayitCard(kayit: k, deviceList: deviceList)).toList(),
    );
  }
}

class _ServisKayitCard extends StatelessWidget {
  final ServiceHistory kayit;
  final List<String> deviceList;
  const _ServisKayitCard({required this.kayit, required this.deviceList, Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 
                   'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final parentState = context.findAncestorStateOfType<_ServisGecmisiScreenState>();
    final isWide = MediaQuery.of(context).size.width > 600;
    return Container(
      margin: EdgeInsets.only(bottom: isWide ? 24 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWide ? 22 : 16),
        border: Border.all(color: const Color(0xFF23408E).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF23408E).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 18, vertical: isWide ? 22 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF23408E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_month, size: isWide ? 24 : 18, color: const Color(0xFF23408E)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(kayit.date),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWide ? 16 : 14, color: Colors.black87),
                  ),
                  Text(
                    _formatTime(kayit.date),
                    style: TextStyle(fontSize: isWide ? 13 : 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF23408E)),
                tooltip: 'Düzenle',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: parentState == null ? null : () async {
                  final guncelKayit = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (ctx) => YeniKayitDialog(
                      cihazlar: deviceList,
                      mevcutKayit: kayit.toJson(),
                    ),
                  );
                  if (guncelKayit != null) {
                    parentState?.guncelleKayit(kayit, guncelKayit);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
                tooltip: 'Sil',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: parentState == null ? null : () async {
                  final onay = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Kaydı Sil'),
                      content: const Text('Bu kaydı silmek istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('İptal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sil'),
                        ),
                      ],
                    ),
                  );
                  if (onay == true) {
                    parentState?.silKayit(kayit);
                  }
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: getStatusBgColor(kayit.status),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: getStatusTextColor(kayit.status).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      kayit.status == 'Başarılı' ? Icons.check_circle : Icons.warning,
                      size: 10,
                      color: getStatusTextColor(kayit.status),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      getStatusLabel(kayit.status),
                      style: TextStyle(
                        color: getStatusTextColor(kayit.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF23408E).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF23408E).withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF23408E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.devices_other, size: isWide ? 20 : 16, color: const Color(0xFF23408E)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kayit.deviceId,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWide ? 16 : 14, color: Colors.black87),
                          ),
                          if (kayit.musteri.isNotEmpty)
                            Text(
                              kayit.musteri,
                              style: TextStyle(fontSize: isWide ? 13 : 11, color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (kayit.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    kayit.description,
                    style: TextStyle(fontSize: isWide ? 14 : 12, color: Colors.black87, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF23408E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
                        builder: (_) => ServisKaydiDetayScreen(kayit: kayit),
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
    );
  }
}

class ServisKaydiDetayScreen extends StatelessWidget {
  final ServiceHistory kayit;
  const ServisKaydiDetayScreen({required this.kayit, Key? key}) : super(key: key);

  String _formatDetailDate(DateTime date) {
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 
                   'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF23408E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Servis Detayı',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
              // Paylaşım fonksiyonu buraya eklenebilir
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
              );
            },
            tooltip: 'Paylaş',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF23408E).withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF23408E).withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusBgColor(kayit.status),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: getStatusTextColor(kayit.status).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              kayit.status == 'Başarılı' ? Icons.check_circle : Icons.warning,
                              size: 12,
                              color: getStatusTextColor(kayit.status),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              getStatusLabel(kayit.status),
                              style: TextStyle(
                                color: getStatusTextColor(kayit.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF23408E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month, size: 18, color: const Color(0xFF23408E)),
                            const SizedBox(width: 6),
                            Text(
                              _formatDetailDate(kayit.date),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF23408E)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    kayit.deviceId,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                  ),
                  if (kayit.musteri.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      kayit.musteri,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                  if (kayit.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      kayit.description,
                      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23408E).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF23408E).withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF23408E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.devices_other, size: 20, color: Color(0xFF23408E)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cihaz',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    kayit.deviceId,
                                    style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF23408E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.person, size: 20, color: Color(0xFF23408E)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Teknisyen',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    kayit.technician,
                                    style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Kullanılan Parçalar
                  if (kayit.kullanilanParcalar.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF23408E).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF23408E).withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF23408E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.build, size: 20, color: Color(0xFF23408E)),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Kullanılan Parçalar',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...kayit.kullanilanParcalar.map((part) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF23408E).withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF23408E).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.memory, size: 16, color: Color(0xFF23408E)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        part.parcaAdi,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                                      ),
                                      Text(
                                        'Kod: ${part.parcaKodu}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF23408E).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${part.stokAdedi} adet',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF23408E)),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Yeni Kayıt Dialogu
class YeniKayitDialog extends StatefulWidget {
  final List<String> cihazlar;
  final Map<String, dynamic>? mevcutKayit;
  const YeniKayitDialog({required this.cihazlar, this.mevcutKayit, Key? key}) : super(key: key);

  @override
  State<YeniKayitDialog> createState() => _YeniKayitDialogState();
}

class _YeniKayitDialogState extends State<YeniKayitDialog> {
  final _formKey = GlobalKey<FormState>();
  String? cihaz;
  String? baslik;
  String? aciklama;
  String? kisi;
  String? durum;
  String? musteri;
  DateTime? tarih;

  @override
  void initState() {
    super.initState();
    if (widget.mevcutKayit != null) {
      cihaz = widget.mevcutKayit!['cihaz'];
      baslik = widget.mevcutKayit!['baslik'];
      aciklama = widget.mevcutKayit!['aciklama'];
      kisi = widget.mevcutKayit!['kisi'];
      durum = widget.mevcutKayit!['durum'];
      musteri = widget.mevcutKayit!['musteri'];
      tarih = _parseDate(widget.mevcutKayit!['tarih']);
    } else {
      // Yeni kayıt için teknisyen adını otomatik doldur
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          kisi = _getTechnicianName();
        });
      });
    }
  }
  DateTime _parseDate(String? date) {
    if (date == null) return DateTime.now();
    final months = {
      'Ocak': 1, 'Şubat': 2, 'Mart': 3, 'Nisan': 4, 'Mayıs': 5, 'Haziran': 6,
      'Temmuz': 7, 'Ağustos': 8, 'Eylül': 9, 'Ekim': 10, 'Kasım': 11, 'Aralık': 12,
    };
    final parts = date.split(' ');
    if (parts.length != 3) return DateTime.now();
    final day = int.tryParse(parts[0]);
    final month = months[parts[1]];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return DateTime.now();
    return DateTime(year, month, day);
  }

  String _ayAdi(int ay) {
    const aylar = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return aylar[ay];
  }

  // Kullanıcı profilinden teknisyen adını al
  String _getTechnicianName() {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final userProfile = appStateProvider.userProfile;
    return userProfile.fullName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.mevcutKayit == null ? 'Yeni Servis Kaydı' : 'Kaydı Düzenle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Cihaz'),
                value: cihaz,
                items: widget.cihazlar.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => cihaz = v),
                validator: (v) => v == null ? 'Cihaz seçin' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Başlık'),
                initialValue: baslik,
                onChanged: (v) => baslik = v,
                validator: (v) => v == null || v.isEmpty ? 'Başlık girin' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Açıklama'),
                initialValue: aciklama,
                onChanged: (v) => aciklama = v,
                validator: (v) => v == null || v.isEmpty ? 'Açıklama girin' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Teknisyen',
                  suffixIcon: const Icon(Icons.person, color: Color(0xFF23408E)),
                ),
                initialValue: kisi,
                readOnly: true,
                onChanged: (v) => kisi = v,
                validator: (v) => v == null || v.isEmpty ? 'Teknisyen girin' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Müşteri/Kurum'),
                initialValue: musteri,
                onChanged: (v) => musteri = v,
                validator: (v) => v == null || v.isEmpty ? 'Müşteri/Kurum girin' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Durum'),
                value: durum,
                items: const [
                  DropdownMenuItem(value: 'Başarılı', child: Text('Başarılı')),
                ],
                onChanged: (v) => setState(() => durum = v),
                validator: (v) => v == null ? 'Durum seçin' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(tarih == null ? 'Tarih seçilmedi' : '${tarih!.day} ${_ayAdi(tarih!.month)} ${tarih!.year}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tarih ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        locale: const Locale('tr', 'TR'),
                      );
                      if (picked != null) setState(() => tarih = picked);
                    },
                    child: const Text('Tarih Seç'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && tarih != null) {
              Navigator.pop(context, {
                'tarih': '${tarih!.day} ${_ayAdi(tarih!.month)} ${tarih!.year}',
                'baslik': baslik,
                'aciklama': aciklama,
                'kisi': kisi,
                'durum': durum,
                'cihaz': cihaz,
                'musteri': musteri,
              });
            }
          },
          child: Text(widget.mevcutKayit == null ? 'Kaydet' : 'Güncelle'),
        ),
      ],
    );
  }
}

// Duruma göre renk döndüren yardımcı fonksiyon
Color getStatusColor(String status) {
  switch (status) {
    case 'Başarılı':
      return const Color(0xFF43A047);
    case 'Beklemede':
      return const Color(0xFFFFB300);
    case 'Arızalı':
      return const Color(0xFFE53935);
    default:
      return Colors.grey;
  }
}

Color getStatusBgColor(String status) {
  switch (status) {
    case 'Başarılı':
      return const Color(0xFF43A047); // Yeşil
    case 'Beklemede':
      return const Color(0xFFFFC107); // Modern sarı
    case 'Arızalı':
      return const Color(0xFFE53935); // Kırmızı
    default:
      return const Color(0xFF43A047);
  }
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

Color getStatusTextColor(String status) {
  return Colors.white;
} 