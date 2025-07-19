import 'package:flutter/material.dart';
import '../models/service_history.dart';

class ServisGecmisiScreen extends StatefulWidget {
  final ServiceHistoryRepository repository;
  ServisGecmisiScreen({Key? key, ServiceHistoryRepository? repository})
      : repository = repository ?? MockServiceHistoryRepository(),
        super(key: key);

  @override
  State<ServisGecmisiScreen> createState() => _ServisGecmisiScreenState();
}

class _ServisGecmisiScreenState extends State<ServisGecmisiScreen> {
  String? selectedStatus;
  String? selectedSort;
  String? selectedDevice;
  String searchText = '';
  final TextEditingController _searchController = TextEditingController();

  late Future<List<ServiceHistory>> _futureHistory;
  List<ServiceHistory> _allHistory = [];

  @override
  void initState() {
    super.initState();
    _futureHistory = widget.repository.getAll();
  }

  List<String> get cihazListesi => _allHistory.map((k) => k.type).toSet().toList();

  List<String> get filteredCihazlar {
    if (searchText.isEmpty) return cihazListesi;
    return cihazListesi.where((c) => c.toLowerCase().contains(searchText.toLowerCase())).toList();
  }

  List<ServiceHistory> get filteredHistory {
    List<ServiceHistory> list = List.from(_allHistory);
    if (selectedStatus != null) {
      list = list.where((k) => k.status == selectedStatus).toList();
    }
    if (selectedDevice != null) {
      list = list.where((k) => k.type == selectedDevice).toList();
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
                  FilterChip(
                    label: const Text('Tamamlandı'),
                    selected: selectedStatus == 'Tamamlandı',
                    onSelected: (_) => Navigator.pop(ctx, {'status': 'Tamamlandı', 'device': selectedDevice}),
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
                  ..._allHistory.map((k) => FilterChip(
                    label: Text(k.type),
                    selected: selectedDevice == k.type,
                    onSelected: (_) => Navigator.pop(ctx, {'status': selectedStatus, 'device': k.type}),
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
      final idx = _allHistory.indexOf(eski);
      if (idx != -1) {
        _allHistory[idx] = ServiceHistory(
          id: eski.id,
          date: _parseDate(yeni['tarih']),
          type: yeni['cihaz'] ?? '',
          description: ((yeni['baslik'] ?? '') + (yeni['aciklama'] != null ? ' - ${yeni['aciklama']}' : '')),
          technician: yeni['kisi'] ?? '',
          status: yeni['durum'] ?? '',
        );
      }
    });
  }
  void silKayit(ServiceHistory kayit) {
    setState(() {
      _allHistory.remove(kayit);
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Servis Geçmişi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ServiceHistory>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Kayıt bulunamadı.'));
          }
          // Only set _allHistory if it's empty, to avoid overwriting user changes
          if (_allHistory.isEmpty) {
            _allHistory = snapshot.data!;
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
                                  children: filteredCihazlar.isEmpty
                                      ? [
                                          const ListTile(
                                            title: Text('Sonuç bulunamadı'),
                                          ),
                                        ]
                                      : filteredCihazlar.map((cihaz) => ListTile(
                                            title: Text(cihaz),
                                            onTap: () {
                                              setState(() {
                                                selectedDevice = cihaz;
                                                _searchController.text = cihaz;
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
                    : _ServisKayitListesi(kayitlar: filteredHistory),
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
  const _ServisKayitListesi({required this.kayitlar, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: kayitlar.map((k) => _ServisKayitCard(kayit: k)).toList(),
    );
  }
}

class _ServisKayitCard extends StatelessWidget {
  final ServiceHistory kayit;
  const _ServisKayitCard({required this.kayit, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final parentState = context.findAncestorStateOfType<_ServisGecmisiScreenState>();
    final isWide = MediaQuery.of(context).size.width > 600;
    return Container(
      margin: EdgeInsets.only(bottom: isWide ? 24 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWide ? 22 : 14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 16, vertical: isWide ? 22 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, size: isWide ? 26 : 20, color: const Color(0xFF23408E)),
              const SizedBox(width: 6),
              Text(
                kayit.date.toString().split(' ')[0], // Tarihi formatla
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: isWide ? 16 : 14, color: Colors.black87),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Color(0xFF23408E)),
                tooltip: 'Düzenle',
                onPressed: parentState == null ? null : () async {
                  final guncelKayit = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (ctx) => YeniKayitDialog(
                      cihazlar: parentState.cihazListesi,
                      mevcutKayit: kayit.toJson(),
                    ),
                  );
                  if (guncelKayit != null) {
                    parentState.guncelleKayit(kayit, guncelKayit);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Color(0xFFE53935)),
                tooltip: 'Sil',
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
                    parentState.silKayit(kayit);
                  }
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: getStatusBgColor(kayit.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  getStatusLabel(kayit.status),
                  style: TextStyle(
                    color: getStatusTextColor(kayit.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.label_important_rounded, size: isWide ? 22 : 16, color: getStatusBgColor(kayit.status)),
              const SizedBox(width: 4),
              Text(
                kayit.type,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWide ? 17 : 15, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            kayit.description,
            style: TextStyle(fontSize: isWide ? 15 : 13, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person, size: isWide ? 22 : 18, color: const Color(0xFF23408E)),
              const SizedBox(width: 6),
              Text(
                kayit.technician,
                style: TextStyle(fontSize: isWide ? 15 : 13, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ServisKaydiDetayScreen(kayit: kayit),
                    ),
                  );
                },
                child: const Text('Detaylar', style: TextStyle(fontSize: 13, color: Color(0xFF23408E), fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Servis Detayı', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: getStatusBgColor(kayit.status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          getStatusLabel(kayit.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        kayit.date.toString().split(' ')[0], // Tarihi formatla
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    kayit.type,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kayit.description,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.devices, size: 20, color: Color(0xFF23408E)),
                      const SizedBox(width: 8),
                      Text(
                        kayit.type,
                        style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Color(0xFF23408E)),
                      const SizedBox(width: 8),
                      Text(
                        kayit.technician,
                        style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Medya alanı (örnek görsel)
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E7F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 60, color: Color(0xFFB0B6C3)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Medya (örnek)', style: TextStyle(fontSize: 13, color: Color(0xFFB0B6C3))),
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
      tarih = _parseDate(widget.mevcutKayit!['tarih']);
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
                decoration: const InputDecoration(labelText: 'Teknisyen'),
                initialValue: kisi,
                onChanged: (v) => kisi = v,
                validator: (v) => v == null || v.isEmpty ? 'Teknisyen girin' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Durum'),
                value: durum,
                items: const [
                  DropdownMenuItem(value: 'Başarılı', child: Text('Başarılı')),
                  DropdownMenuItem(value: 'Tamamlandı', child: Text('Tamamlandı')),
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
    case 'Tamamlandı':
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