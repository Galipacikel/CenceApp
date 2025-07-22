import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // DateFormat için intl paketini ekliyoruz
import '../models/stock_part.dart';
import '../models/device.dart'; // Yeni Cihaz modelini import ediyoruz
import '../models/service_history.dart';

class StokTakibiScreen extends StatefulWidget {
  const StokTakibiScreen({Key? key}) : super(key: key);

  @override
  State<StokTakibiScreen> createState() => _StokTakibiScreenState();
}

class _StokTakibiScreenState extends State<StokTakibiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Device> _deviceList = [];
  List<StockPart> _parcaListesi = [];
  
  final DeviceRepository _deviceRepository = MockDeviceRepository();
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
    final devices = await _deviceRepository.getAll();
    final parts = await _stockRepository.getAll();
    if (mounted) {
      setState(() {
        _deviceList = devices;
        _parcaListesi = parts;
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
                        );
                              setState(() {
                          _parcaListesi.insert(0, yeniParca);
                              });
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
          child: StatefulBuilder(builder: (context, setModalState) {
              return Form(
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
                            id: 'DEVICE-${DateTime.now().millisecondsSinceEpoch}',
                            modelName: modelNameCtrl.text,
                            serialNumber: serialNumberCtrl.text,
                          );
                              setState(() {
                             _deviceList.insert(0, newDevice);
                              });
                              Navigator.pop(context);
                            }
                          },
                      child: const Text('Ekle'),
                        ),
                    const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Envanter Yönetimi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF23408E),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF23408E),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Yedek Parçalar'),
            Tab(text: 'Cihazlar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
              children: [
          YedekParcaListesi(
            key: ValueKey(_parcaListesi.length),
            parcaListesi: _parcaListesi,
            onTap: (part) => showStockPartDetailModal(context, part, _serviceHistoryRepository),
                  ),
          DeviceList(
            key: ValueKey(_deviceList.length),
            deviceList: _deviceList,
                              ),
                          ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Yeni Ekle',
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF23408E),
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddPartSheet();
          } else {
            _showAddDeviceSheet();
          }
        },
      ),
    );
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    onTap: () => widget.onTap(part),
                    title: Text(part.parcaAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Kod: ${part.parcaKodu}'),
                    trailing: Text('Stok: ${part.stokAdedi}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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