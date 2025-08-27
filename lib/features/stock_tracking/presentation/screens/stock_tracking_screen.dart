import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/models/service_history.dart';
import 'package:cence_app/providers/stock_provider.dart';
import 'package:cence_app/providers/device_provider.dart';
import 'package:cence_app/repositories/firestore_stock_repository.dart';
import 'package:cence_app/providers/app_state_provider.dart';
import 'package:cence_app/widgets/common/device_tile.dart';
import 'package:cence_app/widgets/common/stock_part_tile.dart';
import 'package:cence_app/widgets/common/confirmation_dialog.dart';
import 'package:cence_app/features/stock_tracking/presentation/widgets/add_stock_forms.dart';
import 'package:cence_app/constants/app_colors.dart';

class StokTakibiScreen extends StatefulWidget {
  const StokTakibiScreen({super.key});

  @override
  State<StokTakibiScreen> createState() => _StokTakibiScreenState();
}

class _StokTakibiScreenState extends State<StokTakibiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showOnlyCritical = false;
  bool showBanner = true;
  String deviceSearch = '';
  String partSearch = '';

  final StockPartRepository _stockRepository = FirestoreStockRepository();

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
    await _stockRepository.getAll();
    if (mounted) {
      setState(() {
        showBanner = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stok Takibi',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.normal,
          ),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Cihazlar'),
            Tab(text: 'Yedek Parçalar'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            // Cihazlar tabında: cihaz stoğu ekle (kritik seviye yok)
            AddDeviceSheet.show(context);
          } else {
            // Yedek Parçalar tabında: parça stoğu ekle
            AddPartSheet.show(context);
          }
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Cihazlar Tab
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isWide ? 600 : double.infinity,
              ),
              child: Consumer<DeviceProvider>(
                builder: (context, deviceProvider, _) {
                  final filteredDevices = deviceSearch.isEmpty
                      ? deviceProvider.devices
                      : deviceProvider.devices
                            .where(
                              (d) =>
                                  d.modelName.toLowerCase().contains(
                                    deviceSearch.toLowerCase(),
                                  ) ||
                                  d.serialNumber.toLowerCase().contains(
                                    deviceSearch.toLowerCase(),
                                  ) ||
                                  d.customer.toLowerCase().contains(
                                    deviceSearch.toLowerCase(),
                                  ),
                            )
                            .toList();

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
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
                          onChanged: (value) {
                            setState(() {
                              deviceSearch = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          itemCount: filteredDevices.length,
                          itemBuilder: (context, index) {
                            final device = filteredDevices[index];
                            return DeviceTile(
                              device: device,
                              onTap: () {},
                              onEdit: () {
                                // TODO: Implement device edit action (e.g., open edit bottom sheet)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Düzenleme yakında eklenecek.',
                                    ),
                                  ),
                                );
                              },
                              onDeleteConfirm: () async {
                                final isAdmin =
                                    Provider.of<AppStateProvider>(
                                      context,
                                      listen: false,
                                    ).currentUser?.isAdmin ??
                                    false;
                                if (!isAdmin) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Silme yetkisi sadece admin kullanıcılar içindir.',
                                      ),
                                    ),
                                  );
                                  return false;
                                }
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => ConfirmationDialog(
                                    title: 'Cihazı Sil',
                                    message:
                                        '"${device.modelName}" cihazını silmek istediğinize emin misiniz?',
                                  ),
                                );
                                if (!context.mounted) return false;
                                if (confirmed == true) {
                                  Provider.of<DeviceProvider>(
                                    context,
                                    listen: false,
                                  ).removeDevice(device.id);
                                  return true;
                                }
                                return false;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Yedek Parçalar Tab
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isWide ? 600 : double.infinity,
              ),
              child: Consumer<StockProvider>(
                builder: (context, stockProvider, _) {
                  final criticalParts = stockProvider.getCriticalParts();
                  final sortedParts = [
                    ...stockProvider.parts.where((p) => p.stokAdedi == 0),
                    ...stockProvider.parts.where((p) => p.stokAdedi > 0),
                  ];

                  final filteredParts = partSearch.isEmpty
                      ? sortedParts
                      : sortedParts
                            .where(
                              (p) =>
                                  p.parcaAdi.toLowerCase().contains(
                                    partSearch.toLowerCase(),
                                  ) ||
                                  p.parcaKodu.toLowerCase().contains(
                                    partSearch.toLowerCase(),
                                  ),
                            )
                            .toList();

                  final partsToShow = showOnlyCritical
                      ? criticalParts
                      : filteredParts;

                  return Column(
                    children: [
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.criticalRed.withValues(
                                      alpha: 0.13,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.criticalRed.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.criticalRed.withValues(
                                          alpha: 0.10,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppColors.criticalRed,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Kritik Seviye Uyarısı',
                                                  style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color:
                                                        AppColors.criticalRed,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber
                                                        .withValues(
                                                          alpha: 0.18,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${criticalParts.length}',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .orange
                                                              .shade700,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              showOnlyCritical
                                                  ? 'Kritik seviyedekiler gösteriliyor'
                                                  : 'Stokta kritik seviyeye düşen parçalarınız var!',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 13,
                                                color: AppColors.criticalRed,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6.0,
                                              ),
                                              child: Text(
                                                showOnlyCritical
                                                    ? 'Tüm parçaları göster'
                                                    : 'Kritik seviyeleri gör',
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.criticalRed,
                                                ),
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
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            color: AppColors.criticalRed,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Text(
                              'Tüm Parçalar',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...partsToShow.map(
                              (p) => StockPartTile(
                                part: p,
                                onTap: () {},
                                onEdit: () {
                                  // Placeholder for edit part functionality
                                },
                                onDeleteConfirm: () async {
                                  final isAdmin =
                                      Provider.of<AppStateProvider>(
                                        context,
                                        listen: false,
                                      ).currentUser?.isAdmin ??
                                      false;
                                  if (!isAdmin) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Silme yetkisi sadece admin kullanıcılar içindir.',
                                        ),
                                      ),
                                    );
                                    return false;
                                  }
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => ConfirmationDialog(
                                      title: 'Parçayı Sil',
                                      message:
                                          '"${p.parcaAdi}" parçasını silmek istediğinize emin misiniz?',
                                    ),
                                  );
                                  if (confirmed == true) {
                                    stockProvider.removePart(p.id);
                                    return true;
                                  }
                                  return false;
                                },
                              ),
                            ),
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
    );
  }
}

// Parça detay modalı
void showStockPartDetailModal(
  BuildContext context,
  StockPart part,
  ServiceHistoryRepository serviceHistoryRepository,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => _StockPartDetailModal(
      part: part,
      serviceHistoryRepository: serviceHistoryRepository,
    ),
  );
}

class _StockPartDetailModal extends StatefulWidget {
  final StockPart part;
  final ServiceHistoryRepository serviceHistoryRepository;
  const _StockPartDetailModal({
    required this.part,
    required this.serviceHistoryRepository,
  });

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
        left: 20,
        right: 20,
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
            Text(
              'Adı: ${widget.part.parcaAdi}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Kod: ${widget.part.parcaKodu}'),
            Text('Stok: ${widget.part.stokAdedi}'),
            const SizedBox(height: 18),
            Text(
              'Kullanıldığı Servisler:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
                    .where(
                      (h) => h.kullanilanParcalar.any(
                        (p) => p.parcaKodu == widget.part.parcaKodu,
                      ),
                    )
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
                    final used = h.kullanilanParcalar.firstWhere(
                      (p) => p.parcaKodu == widget.part.parcaKodu,
                    );
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${h.deviceId} - ${h.description}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tarih: ${h.date.day.toString().padLeft(2, '0')}.${h.date.month.toString().padLeft(2, '0')}.${h.date.year}',
                          ),
                          Text('Teknisyen: ${h.technician}'),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(
                          'x${used.stokAdedi}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
  const YedekParcaListesi({
    super.key,
    required this.parcaListesi,
    required this.onTap,
  });

  @override
  State<YedekParcaListesi> createState() => _YedekParcaListesiState();
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
      parts = parts
          .where(
            (p) =>
                p.parcaAdi.toLowerCase().contains(search.toLowerCase()) ||
                p.parcaKodu.toLowerCase().contains(search.toLowerCase()),
          )
          .toList();
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
                  primaryBlue: AppColors.primaryBlue,
                  textColor: AppColors.textColor,
                  subtitleColor: AppColors.subtitleColor,
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
  const DeviceList({super.key, required this.deviceList});

  @override
  State<DeviceList> createState() => _DeviceListState();
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
      devices = devices
          .where(
            (d) =>
                d.modelName.toLowerCase().contains(search.toLowerCase()) ||
                d.serialNumber.toLowerCase().contains(search.toLowerCase()),
          )
          .toList();
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.devices_other,
                      color: AppColors.primaryBlue,
                    ),
                    title: Text(
                      device.modelName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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

class _PartCard extends StatelessWidget {
  final StockPart part;
  final Color primaryBlue;
  final Color textColor;
  final Color subtitleColor;
  final double cardRadius;
  final VoidCallback onCriticalLevelEdit;
  const _PartCard({
    required this.part,
    required this.primaryBlue,
    required this.textColor,
    required this.subtitleColor,
    required this.cardRadius,
    required this.onCriticalLevelEdit,
  });

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final bool isOutOfStock = part.stokAdedi == 0;
    final bool isCritical =
        !isOutOfStock && part.stokAdedi <= part.criticalLevel;
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
              : isCritical
              ? Colors.red.withValues(alpha: 0.35)
              : primaryBlue.withValues(alpha: 0.10),
          width: isOutOfStock
              ? 1.5
              : isCritical
              ? 2
              : 1,
        ),
        boxShadow: [
          if (isOutOfStock)
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 2),
            )
          else if (isCritical)
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: primaryBlue.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isOutOfStock
                ? Colors.red.shade300
                : isCritical
                ? Colors.red.withValues(alpha: 0.18)
                : primaryBlue.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isOutOfStock
                ? Icons.block
                : isCritical
                ? Icons.warning_amber_rounded
                : Icons.memory,
            color: isOutOfStock
                ? Colors.red
                : isCritical
                ? Colors.red
                : primaryBlue,
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
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.18),
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
        trailing: isOutOfStock
            ? null
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCritical
                      ? Colors.red.withValues(alpha: 0.18)
                      : primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: isCritical ? Colors.red : primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Kritik:',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        color: isCritical ? Colors.red : primaryBlue,
                        fontSize: 11,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      color: isCritical ? Colors.red : primaryBlue,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (part.criticalLevel > 1) {
                          stockProvider.updateCriticalLevel(
                            part.id,
                            part.criticalLevel - 1,
                          );
                        }
                      },
                    ),
                    Text(
                      '${part.criticalLevel}',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: isCritical ? Colors.red : primaryBlue,
                        fontSize: 12,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      color: isCritical ? Colors.red : primaryBlue,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        stockProvider.updateCriticalLevel(
                          part.id,
                          part.criticalLevel + 1,
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CriticalLevelDialog extends StatefulWidget {
  final int initialLevel;
  const _CriticalLevelDialog({required this.initialLevel});

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
