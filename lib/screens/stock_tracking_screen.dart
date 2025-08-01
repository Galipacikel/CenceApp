import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stock_part.dart';
import '../models/device.dart';
import '../models/service_history.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../providers/device_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class StokTakibiScreen extends StatefulWidget {
  const StokTakibiScreen({Key? key}) : super(key: key);

  @override
  State<StokTakibiScreen> createState() => _StokTakibiScreenState();
}

class _StokTakibiScreenState extends State<StokTakibiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showOnlyCritical = false;
  bool showBanner = true;
  List<StockPart> _parcaListesi = [];
  String deviceSearch = '';
  String partSearch = '';
  
  final StockPartRepository _stockRepository = MockStockRepository();
  final ServiceHistoryRepository _serviceHistoryRepository = MockServiceHistoryRepository();




  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() { 
      setState(() {});
    });
    _loadData();
    }

  Future<void> _loadData() async {
    final parts = await _stockRepository.getAll();
    if (mounted) {
      setState(() {
        _parcaListesi = parts;
        showBanner = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddPartSheet() {
    final _formKey = GlobalKey<FormState>();
    final parcaAdiCtrl = TextEditingController();
    final parcaKoduCtrl = TextEditingController();
    final stokAdediCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yeni Yedek Parça Ekle', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: parcaAdiCtrl,
                    decoration: const InputDecoration(labelText: 'Parça Adı'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: parcaKoduCtrl,
                    decoration: const InputDecoration(labelText: 'Parça Kodu'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: stokAdediCtrl,
                    decoration: const InputDecoration(labelText: 'Stok Adedi'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Bu alan boş bırakılamaz';
                      if (int.tryParse(v) == null) return 'Lütfen geçerli bir sayı girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final yeniParca = StockPart(
                          id: 'PART-${DateTime.now().millisecondsSinceEpoch}',
                          parcaAdi: parcaAdiCtrl.text,
                          parcaKodu: parcaKoduCtrl.text,
                          stokAdedi: int.parse(stokAdediCtrl.text),
                          criticalLevel: 5,
                        );
                        Provider.of<StockProvider>(context, listen: false).addPart(yeniParca);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Ekle'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddDeviceSheet() {
    final _formKey = GlobalKey<FormState>();
    final modelNameCtrl = TextEditingController();
    final serialNumberCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yeni Cihaz Ekle', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: modelNameCtrl,
                    decoration: const InputDecoration(labelText: 'Model Adı'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: serialNumberCtrl,
                    decoration: const InputDecoration(labelText: 'Seri Numarası'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final newDevice = Device(
                          id: 'CİHAZ-${DateTime.now().millisecondsSinceEpoch}',
                          modelName: modelNameCtrl.text,
                          serialNumber: serialNumberCtrl.text,
                          customer: 'Demo Müşteri',
                          installDate: DateFormat('dd.MM.yyyy').format(DateTime.now()),
                          warrantyStatus: 'Devam Ediyor',
                          lastMaintenance: DateFormat('dd.MM.yyyy').format(DateTime.now()),
                        );
                        Provider.of<DeviceProvider>(context, listen: false).addDevice(newDevice);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Ekle'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditDeviceSheet(Device device) {
    final _formKey = GlobalKey<FormState>();
    final modelNameCtrl = TextEditingController(text: device.modelName);
    final serialNumberCtrl = TextEditingController(text: device.serialNumber);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cihazı Düzenle', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: modelNameCtrl,
                    decoration: const InputDecoration(labelText: 'Model Adı'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: serialNumberCtrl,
                    decoration: const InputDecoration(labelText: 'Seri Numarası'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final updatedDevice = device.copyWith(
                          modelName: modelNameCtrl.text,
                          serialNumber: serialNumberCtrl.text,
                        );
                        Provider.of<DeviceProvider>(context, listen: false).updateDevice(updatedDevice);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Kaydet'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditPartSheet(StockPart part) {
    final _formKey = GlobalKey<FormState>();
    final parcaAdiCtrl = TextEditingController(text: part.parcaAdi);
    final parcaKoduCtrl = TextEditingController(text: part.parcaKodu);
    final stokAdediCtrl = TextEditingController(text: part.stokAdedi.toString());
    final criticalLevelCtrl = TextEditingController(text: part.criticalLevel.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Parçayı Düzenle', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: parcaAdiCtrl,
                    decoration: const InputDecoration(labelText: 'Parça Adı'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: parcaKoduCtrl,
                    decoration: const InputDecoration(labelText: 'Parça Kodu'),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: stokAdediCtrl,
                    decoration: const InputDecoration(labelText: 'Stok Adedi'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Bu alan boş bırakılamaz';
                      if (int.tryParse(v) == null) return 'Lütfen geçerli bir sayı girin';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: criticalLevelCtrl,
                    decoration: const InputDecoration(labelText: 'Kritik Seviye'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Bu alan boş bırakılamaz';
                      if (int.tryParse(v) == null) return 'Lütfen geçerli bir sayı girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final updatedPart = StockPart(
                          id: part.id,
                          parcaAdi: parcaAdiCtrl.text,
                          parcaKodu: parcaKoduCtrl.text,
                          stokAdedi: int.parse(stokAdediCtrl.text),
                          criticalLevel: int.parse(criticalLevelCtrl.text),
                        );
                        Provider.of<StockProvider>(context, listen: false).updatePart(updatedPart);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Kaydet'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF23408E);
    final Color background = const Color(0xFFF7F9FC);
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF232946);
    final Color subtitleColor = const Color(0xFF4A4A4A);
    final Color criticalRed = const Color(0xFFE53935);
    final Color warningAmber = const Color(0xFFFFC107);
    final double cardRadius = 18;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: primaryBlue,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Stok Takibi',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(Icons.add_circle_rounded, color: Colors.white, size: 32),
                tooltip: _tabController.index == 0 ? 'Yeni Cihaz Ekle' : 'Yeni Parça Ekle',
                onPressed: () {
                  if (_tabController.index == 0) {
                    _showAddDeviceSheet();
                  } else {
                    _showAddPartSheet();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: textColor.withOpacity(0.7),
              labelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              unselectedLabelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'Cihazlar'),
                Tab(text: 'Yedek Parça'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Cihazlar Sekmesi
                Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
                    child: Consumer<DeviceProvider>(
                      builder: (context, deviceProvider, _) {
                        final allDevices = deviceProvider.devices;
                        final uniqueKeys = <String>{};
                        final uniqueDevices = <Device>[];
                        for (final device in allDevices) {
                          final key = '${device.modelName}_${device.serialNumber}';
                          if (!uniqueKeys.contains(key)) {
                            uniqueKeys.add(key);
                            uniqueDevices.add(device);
                          }
                        }
                        // Alfabetik sıralama
                        uniqueDevices.sort((a, b) => a.modelName.compareTo(b.modelName));
                        final filtered = deviceSearch.isEmpty
                          ? uniqueDevices
                          : uniqueDevices.where((d) =>
                              d.modelName.toLowerCase().contains(deviceSearch.toLowerCase())
                            ).toList();
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Model ile ara...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    deviceSearch = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              if (filtered.isEmpty)
                                const Text('Envanterde cihaz bulunamadı.', style: TextStyle(color: Colors.black54))
                              else
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final device = filtered[index];
                                      return Slidable(
                                        key: ValueKey(device.id),
                                        endActionPane: ActionPane(
                                          motion: const DrawerMotion(),
                                          extentRatio: 0.5,
                                          children: [
                                            SlidableAction(
                                              onPressed: (context) {
                                                _showEditDeviceSheet(device);
                                              },
                                              backgroundColor: const Color(0xFF23408E),
                                              foregroundColor: Colors.white,
                                              icon: Icons.edit,
                                              label: 'Düzenle',
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            SlidableAction(
                                              onPressed: (context) {
                                                _confirmAndDeleteDevice(device);
                                              },
                                              backgroundColor: const Color(0xFFE53935),
                                              foregroundColor: Colors.white,
                                              icon: Icons.delete_forever_rounded,
                                              label: 'Sil',
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ],
                                        ),
                                        child: Card(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          elevation: 3,
                                          child: ListTile(
                                            leading: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: primaryBlue.withOpacity(0.10),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.devices_other_rounded,
                                                color: const Color(0xFF23408E),
                                                size: 26,
                                              ),
                                            ),
                                            title: Text(device.modelName, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                                            subtitle: Text('ID: ${device.id} | Seri No: ${device.serialNumber}', style: GoogleFonts.montserrat(fontSize: 13, color: subtitleColor)),
                                            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFB0B3C0), size: 18),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Yedek Parça Sekmesi
                Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
                    child: Consumer<StockProvider>(
                      builder: (context, stockProvider, _) {
                        final criticalParts = stockProvider.getCriticalParts();
                        final sortedParts = [
                          ...stockProvider.parts.where((p) => p.stokAdedi == 0),
                          ...stockProvider.parts.where((p) => p.stokAdedi > 0)
                        ];
                        
                        // Arama filtresi
                        final filteredParts = partSearch.isEmpty
                          ? sortedParts
                          : sortedParts.where((p) =>
                              p.parcaAdi.toLowerCase().contains(partSearch.toLowerCase()) ||
                              p.parcaKodu.toLowerCase().contains(partSearch.toLowerCase())
                            ).toList();
                        
                        final partsToShow = showOnlyCritical ? criticalParts : filteredParts;
                        
                        return Column(
                          children: [
                            // Arama kutusu
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Parça adı veya kodu ile ara...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    partSearch = value;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                children: [
                            if (criticalParts.isNotEmpty && showBanner)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showOnlyCritical = !showOnlyCritical;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: criticalRed.withOpacity(0.13),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: criticalRed.withOpacity(0.3), width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: criticalRed.withOpacity(0.10),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: criticalRed, size: 22),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('Kritik Seviye Uyarısı', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15, color: criticalRed)),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: warningAmber.withOpacity(0.18),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text('${criticalParts.length}', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: warningAmber)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              showOnlyCritical
                                                ? 'Kritik seviyedekiler gösteriliyor'
                                                : 'Stokta kritik seviyeye düşen parçalarınız var!',
                                              style: GoogleFonts.montserrat(fontSize: 13, color: criticalRed),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6.0),
                                              child: Text(
                                                showOnlyCritical ? 'Tüm parçaları göster' : 'Kritik seviyeleri gör',
                                                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: criticalRed),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showBanner = false;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Icon(Icons.close, color: criticalRed, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Text('Tüm Parçalar', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                            const SizedBox(height: 10),
                            ...partsToShow.map((p) => Slidable(
                              key: ValueKey(p.id),
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.5,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      _showEditPartSheet(p);
                                    },
                                    backgroundColor: const Color(0xFF23408E),
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit_note_rounded,
                                    label: 'Düzenle',
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  SlidableAction(
                                    onPressed: (context) async {
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: Row(
                                            children: [
                                              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935)),
                                              SizedBox(width: 8),
                                              Text('Parçayı Sil'),
                                            ],
                                          ),
                                          content: Text('"${p.parcaAdi}" parçasını silmek istediğinize emin misiniz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('İptal'),
                                            ),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
                                              onPressed: () => Navigator.pop(ctx, true),
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Sil'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (result == true) {
                                        stockProvider.removePart(p.id);
                                      }
                                    },
                                    backgroundColor: const Color(0xFFE53935),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete_forever_rounded,
                                    label: 'Sil',
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                              ),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 3,
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: p.stokAdedi <= p.criticalLevel ? const Color(0xFFFFCDD2) : primaryBlue.withOpacity(0.10), // soft kırmızımsı
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      p.stokAdedi <= p.criticalLevel ? Icons.warning_amber_rounded : Icons.memory_rounded,
                                      color: p.stokAdedi <= p.criticalLevel ? const Color(0xFFD32F2F) : const Color(0xFF23408E),
                                      size: 22,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.parcaAdi,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      if (p.stokAdedi == 0)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD32F2F).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFD32F2F), width: 1),
                                          ),
                                          child: Text(
                                            'Stok tükendi',
                                            style: GoogleFonts.montserrat(
                                              color: const Color(0xFFD32F2F),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        )
                                      else if (p.stokAdedi <= p.criticalLevel)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD32F2F).withOpacity(0.10),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Stok kritik',
                                            style: GoogleFonts.montserrat(
                                              color: const Color(0xFFD32F2F),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    'Kod: ${p.parcaKodu}  |  Stok: ${p.stokAdedi}',
                                    style: GoogleFonts.montserrat(
                                      color: subtitleColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.info_outline_rounded, color: Color(0xFFB0B3C0), size: 18),
                                ),
                              ),
                            )),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDeleteDevice(Device device) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935)),
            SizedBox(width: 8),
            Text('Cihazı Sil'),
          ],
        ),
        content: Text('"${device.modelName}" cihazını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete),
            label: const Text('Sil'),
          ),
        ],
      ),
    );
    if (result == true) {
      Provider.of<DeviceProvider>(context, listen: false).removeDevice(device.id);
    }
  }
}

// Parça detay modalı (güncellenmiş)
void showStockPartDetailModal(BuildContext context, StockPart part, ServiceHistoryRepository serviceHistoryRepository) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (ctx) => _StockPartDetailModal(part: part, serviceHistoryRepository: serviceHistoryRepository),
  );
}

class _StockPartDetailModal extends StatefulWidget {
  final StockPart part;
  final ServiceHistoryRepository serviceHistoryRepository;
  const _StockPartDetailModal({required this.part, required this.serviceHistoryRepository, Key? key}) : super(key: key);

  @override
  State<_StockPartDetailModal> createState() => _StockPartDetailModalState();
}

class _StockPartDetailModalState extends State<_StockPartDetailModal> {
  late Future<List<ServiceHistory>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = widget.serviceHistoryRepository.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
                    children: [
            Text('Parça Detayı', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Adı: ${widget.part.parcaAdi}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Kod: ${widget.part.parcaKodu}'),
            Text('Stok: ${widget.part.stokAdedi}'),
            const SizedBox(height: 18),
            Text('Kullanıldığı Servisler:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
            FutureBuilder<List<ServiceHistory>>(
              future: _futureHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Bu parça hiçbir serviste kullanılmamış.');
                }
                final relevant = snapshot.data!
                  .where((h) => h.kullanilanParcalar.any((p) => p.parcaKodu == widget.part.parcaKodu))
                  .toList();
                if (relevant.isEmpty) {
                  return const Text('Bu parça hiçbir serviste kullanılmamış.');
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: relevant.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, i) {
                    final h = relevant[i];
                    final used = h.kullanilanParcalar.firstWhere((p) => p.parcaKodu == widget.part.parcaKodu);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${h.deviceId} - ${h.description}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                          Text('Tarih: ${h.date.day.toString().padLeft(2, '0')}.${h.date.month.toString().padLeft(2, '0')}.${h.date.year}'),
                          Text('Teknisyen: ${h.technician}'),
                        ],
                      ),
                      trailing: Chip(
                        label: Text('x${used.stokAdedi}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    );
                  },
                );
              },
                        ),
                    ],
                  ),
      ),
    );
  }
}

class YedekParcaListesi extends StatefulWidget {
  final List<StockPart> parcaListesi;
  final Function(StockPart) onTap;
  const YedekParcaListesi({Key? key, required this.parcaListesi, required this.onTap}) : super(key: key);

  @override
  _YedekParcaListesiState createState() => _YedekParcaListesiState();
}

class _YedekParcaListesiState extends State<YedekParcaListesi> {
  final TextEditingController _searchController = TextEditingController();
  String search = '';
  late List<StockPart> _allParts;

  @override
  void initState() {
    super.initState();
    _allParts = widget.parcaListesi;
  }

  List<StockPart> get filteredParts {
    List<StockPart> parts = List.from(_allParts);
    if (search.isNotEmpty) {
      parts = parts.where((p) =>
        p.parcaAdi.toLowerCase().contains(search.toLowerCase()) ||
        p.parcaKodu.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    return parts;
  }

  @override
  Widget build(BuildContext context) {
    if (_allParts.isEmpty) {
      return const Center(child: Text('Stokta parça bulunamadı.'));
    }
                      return Padding(
      padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Parça adı veya kodu ile ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() => search = value),
                    ),
          const SizedBox(height: 16),
                        Expanded(
            child: ListView.builder(
              itemCount: filteredParts.length,
              itemBuilder: (context, index) {
                final part = filteredParts[index];
                return _PartCard(
                  part: part,
                  primaryBlue: const Color(0xFF23408E),
                  textColor: const Color(0xFF232946),
                  subtitleColor: const Color(0xFF4A4A4A),
                  cardRadius: 12,
                  onCriticalLevelEdit: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceList extends StatefulWidget {
  final List<Device> deviceList;
  const DeviceList({Key? key, required this.deviceList}) : super(key: key);

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  final TextEditingController _searchController = TextEditingController();
  String search = '';
  late List<Device> _allDevices;

  @override
  void initState() {
    super.initState();
    _allDevices = widget.deviceList;
  }

  List<Device> get filteredDevices {
    List<Device> devices = List.from(_allDevices);
    if (search.isNotEmpty) {
      devices = devices.where((d) =>
        d.modelName.toLowerCase().contains(search.toLowerCase()) ||
        d.serialNumber.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    return devices;
  }

  @override
  Widget build(BuildContext context) {
    if (_allDevices.isEmpty) {
      return const Center(child: Text('Sistemde kayıtlı cihaz bulunamadı.'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Model, seri no veya müşteri ile ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() => search = value),
                  ),
          const SizedBox(height: 16),
                  Expanded(
            child: ListView.builder(
              itemCount: filteredDevices.length,
              itemBuilder: (context, index) {
                final device = filteredDevices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.devices_other, color: Color(0xFF23408E)),
                    title: Text(device.modelName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Seri No: ${device.serialNumber}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 

class _CriticalPartCard extends StatelessWidget {
  final Map<String, dynamic> part;
  final Color criticalRed;
  final Color warningAmber;
  const _CriticalPartCard({required this.part, required this.criticalRed, required this.warningAmber, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: criticalRed.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: criticalRed.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: criticalRed, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(part['name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15, color: criticalRed)),
                Text('Kod: ${part['code']}', style: GoogleFonts.montserrat(fontSize: 13, color: warningAmber)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: criticalRed.withOpacity(0.13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Stok: ${part['stock']}', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: criticalRed)),
          ),
        ],
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  final StockPart part;
  final Color primaryBlue;
  final Color textColor;
  final Color subtitleColor;
  final double cardRadius;
  final VoidCallback onCriticalLevelEdit;
  const _PartCard({required this.part, required this.primaryBlue, required this.textColor, required this.subtitleColor, required this.cardRadius, required this.onCriticalLevelEdit, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final bool isOutOfStock = part.stokAdedi == 0;
    final bool isCritical = !isOutOfStock && part.stokAdedi <= part.criticalLevel;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: isOutOfStock
              ? const Color(0xFFD32F2F)
              : isCritical ? Colors.red.withOpacity(0.35) : primaryBlue.withOpacity(0.10),
          width: isOutOfStock ? 1.5 : isCritical ? 2 : 1,
        ),
        boxShadow: [
          if (isOutOfStock)
            BoxShadow(
              color: Colors.red.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 2),
            )
          else if (isCritical)
            BoxShadow(
              color: Colors.red.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: primaryBlue.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isOutOfStock
                ? Colors.red.shade300
                : isCritical ? Colors.red.withOpacity(0.18) : primaryBlue.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isOutOfStock
                ? Icons.block
                : isCritical ? Icons.warning_amber_rounded : Icons.memory,
            color: isOutOfStock ? Colors.red : isCritical ? Colors.red : primaryBlue,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                part.parcaAdi,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: isOutOfStock ? Colors.red.shade900 : textColor,
                  fontSize: 16,
                ),
              ),
            ),
            if (isOutOfStock)
              Text(
                'Stok tükendi',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFFD32F2F),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              )
            else if (isCritical)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Stok kritik',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFFD32F2F),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          'Kod: ${part.parcaKodu}  |  Stok: ${part.stokAdedi}',
          style: GoogleFonts.montserrat(
            color: isOutOfStock ? Colors.red.shade900 : subtitleColor,
            fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        trailing: isOutOfStock ? null : Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isCritical ? Colors.red.withOpacity(0.18) : primaryBlue.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: isCritical ? Colors.red : primaryBlue, size: 16),
              const SizedBox(width: 2),
              Text('Kritik:', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: isCritical ? Colors.red : primaryBlue, fontSize: 11)),
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                color: isCritical ? Colors.red : primaryBlue,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  if (part.criticalLevel > 1) {
                    stockProvider.updateCriticalLevel(part.id, part.criticalLevel - 1);
                  }
                },
              ),
              Text('${part.criticalLevel}', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: isCritical ? Colors.red : primaryBlue, fontSize: 12)),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                color: isCritical ? Colors.red : primaryBlue,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  stockProvider.updateCriticalLevel(part.id, part.criticalLevel + 1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 

class _CriticalBanner extends StatelessWidget {
  final int criticalCount;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final bool showDetailButton;
  const _CriticalBanner({required this.criticalCount, required this.onTap, required this.onClose, this.showDetailButton = true, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color criticalRed = const Color(0xFFE53935);
    final Color warningAmber = const Color(0xFFFFC107);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: criticalRed.withOpacity(0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: criticalRed.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: criticalRed.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, color: criticalRed, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Kritik Seviye Uyarısı', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15, color: criticalRed)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: warningAmber.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('$criticalCount', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: warningAmber)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Stokta kritik seviyeye düşen parçalarınız var!', style: GoogleFonts.montserrat(fontSize: 13, color: criticalRed)),
                if (showDetailButton)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: criticalRed,
                        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        minimumSize: const Size(0, 28),
                      ),
                      onPressed: onTap,
                      child: const Text('Detayları Gör'),
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              onClose();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.close, color: criticalRed, size: 20),
            ),
          ),
        ],
      ),
    );
  }
} 

class _CriticalLevelDialog extends StatefulWidget {
  final int initialLevel;
  const _CriticalLevelDialog({required this.initialLevel, Key? key}) : super(key: key);

  @override
  State<_CriticalLevelDialog> createState() => _CriticalLevelDialogState();
}

class _CriticalLevelDialogState extends State<_CriticalLevelDialog> {
  late int _level;

  @override
  void initState() {
    super.initState();
    _level = widget.initialLevel;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kritik Seviye Ayarla'),
      content: Row(
        children: [
          Expanded(
            child: Slider(
              value: _level.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              label: '$_level',
              onChanged: (val) => setState(() => _level = val.round()),
            ),
          ),
          Text('$_level'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_level),
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
} 