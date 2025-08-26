import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cence_app/constants/app_colors.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';
import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';
import 'package:cence_app/features/stock_tracking/presentation/providers/filtered_devices_provider.dart';
import 'package:cence_app/features/stock_tracking/presentation/providers/filtered_parts_provider.dart';
import 'package:cence_app/models/device.dart';
import 'package:cence_app/models/stock_part.dart';
import 'package:cence_app/widgets/common/confirmation_dialog.dart';

class StokTakibiScreen extends ConsumerWidget {
  const StokTakibiScreen({super.key}) : super();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final state = inventoryAsync.valueOrNull;
    final selectedIndex = state?.selectedTabIndex ?? 0;
    final showOnlyCritical = state?.showOnlyCritical ?? false;
    final isWide = MediaQuery.of(context).size.width > 600;

    return DefaultTabController(
      length: 2,
      initialIndex: selectedIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 24,
              ),
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
                child: Consumer(
                  builder: (context, ref, child) {
                    final isAdmin = ref.watch(isAdminProvider);
                    return IconButton(
                      icon: const Icon(
                        Icons.add_circle_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      tooltip: selectedIndex == 0
                          ? 'Yeni Cihaz Ekle'
                          : 'Yeni Parça Ekle',
                      onPressed: () {
                        if (!isAdmin) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ekleme yetkisi sadece admin kullanıcılar içindir.'),
                              backgroundColor: AppColors.criticalRed,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        if (selectedIndex == 0) {
                          _showAddDeviceSheet(context, ref);
                        } else {
                          _showAddPartSheet(context, ref);
                        }
                      },
                    );
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withAlpha(20),
                  width: 1,
                ),
              ),
              child: TabBar(
                onTap: (i) => ref.read(inventoryProvider.notifier).setTab(i),
                indicator: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withAlpha(64),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textColor.withAlpha(179),
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
                children: [
                  // Cihazlar Sekmesi
                  Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 600 : double.infinity,
                      ),
                      child: Consumer(
                        builder: (context, ref, _) {
                          final devicesAsync = ref.watch(filteredDevicesProvider);
                          return devicesAsync.when(
                            data: (devices) {
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
                                        ref.read(inventoryProvider.notifier).setDeviceSearch(value);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    if (devices.isEmpty)
                                      const Text(
                                        'Envanterde cihaz bulunamadı.',
                                        style: TextStyle(color: Colors.black54),
                                      )
                                    else
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: devices.length,
                                          itemBuilder: (context, index) {
                                            final device = devices[index];
                                            return _DeviceTile(
                                              device: device,
                                              onEdit: () => _showEditDeviceSheet(context, ref, device),
                                              onDelete: () => _showDeleteDeviceDialog(context, ref, device),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const Center(child: Text('Hata oluştu')),
                          );
                        },
                      ),
                    ),
                  ),
                  // Yedek Parça Sekmesi
                  Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 600 : double.infinity,
                      ),
                      child: Consumer(
                        builder: (context, ref, _) {
                          final partsAsync = ref.watch(filteredPartsProvider);
                          return partsAsync.when(
                            data: (parts) {
                              final criticalParts = parts.where((p) => p.stokAdedi <= p.criticalLevel).toList();
                              
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
                                        ref.read(inventoryProvider.notifier).setPartSearch(value);
                                      },
                                    ),
                                  ),
                                  // Kritik uyarı banner'ı
                                  if (criticalParts.isNotEmpty)
                                    _buildCriticalWarningBanner(context, ref, showOnlyCritical, criticalParts),
                                  Expanded(
                                    child: ListView(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 18,
                                      ),
                                      children: [
                                        Text(
                                          'Tüm Parçalar',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ...parts.map(
                                          (p) => _StockPartTile(
                                            part: p,
                                            onEdit: () => _showEditPartSheet(context, ref, p),
                                            onDelete: () => _showDeletePartDialog(context, ref, p),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const Center(child: Text('Hata oluştu')),
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
              ),
    );
  }

  Widget _buildCriticalWarningBanner(BuildContext context, WidgetRef ref, bool showOnlyCritical, List<StockPart> criticalParts) {
    return GestureDetector(
      onTap: () {
        ref.read(inventoryProvider.notifier).toggleShowOnlyCritical();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.criticalRed.withAlpha(33),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.criticalRed.withAlpha(77),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.criticalRed.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.criticalRed,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Kritik Seviye Uyarısı',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.criticalRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.criticalRed.withAlpha(46),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${criticalParts.length}',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: AppColors.criticalRed,
                            fontSize: 12,
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
                    padding: const EdgeInsets.only(top: 6.0),
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
          ],
        ),
      ),
    );
  }

  void _showAddDeviceSheet(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final serialNumberCtrl = TextEditingController();
    final cihazAdiCtrl = TextEditingController();
    final markaCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yeni Cihaz Ekle',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: serialNumberCtrl,
                    decoration: InputDecoration(
                      labelText: 'Seri Numarası',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cihazAdiCtrl,
                    decoration: InputDecoration(
                      labelText: 'Cihaz Adı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: markaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Marka',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: modelCtrl,
                    decoration: InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final newDevice = Device(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            serialNumber: serialNumberCtrl.text,
                            modelName: '${markaCtrl.text} ${modelCtrl.text}',
                            customer: cihazAdiCtrl.text,
                            installDate: DateTime.now().toString().split(' ')[0],
                            warrantyStatus: 'Devam Ediyor',
                            lastMaintenance: DateTime.now().toString().split(' ')[0],
                            warrantyEndDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          
                          final success = await ref.read(inventoryProvider.notifier).addDevice(newDevice);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Cihaz başarıyla eklendi'),
                                backgroundColor: AppColors.primaryBlue,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ekle',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
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

  void _showAddPartSheet(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final parcaAdiCtrl = TextEditingController();
    final parcaKoduCtrl = TextEditingController();
    final stokAdediCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yeni Yedek Parça Ekle',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: parcaAdiCtrl,
                    decoration: InputDecoration(
                      labelText: 'Parça Adı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: parcaKoduCtrl,
                    decoration: InputDecoration(
                      labelText: 'Parça Kodu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: stokAdediCtrl,
                    decoration: InputDecoration(
                      labelText: 'Stok Adedi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Bu alan boş bırakılamaz';
                      if (int.tryParse(v) == null) {
                        return 'Lütfen geçerli bir sayı girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final newPart = StockPart(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            parcaAdi: parcaAdiCtrl.text,
                            parcaKodu: parcaKoduCtrl.text,
                            stokAdedi: int.parse(stokAdediCtrl.text),
                            criticalLevel: 5,
                          );
                          
                          final success = await ref.read(inventoryProvider.notifier).addPart(newPart);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Parça başarıyla eklendi'),
                                backgroundColor: AppColors.primaryBlue,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ekle',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
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

  void _showEditDeviceSheet(BuildContext context, WidgetRef ref, Device device) {
    final formKey = GlobalKey<FormState>();
    
    // Cihaz bilgilerini parçalara ayır
    final modelNameParts = device.modelName.split(' ');
    final marka = modelNameParts.isNotEmpty ? modelNameParts.first : '';
    final model = modelNameParts.length > 1 ? modelNameParts.sublist(1).join(' ') : '';
    
    final serialNumberCtrl = TextEditingController(text: device.serialNumber);
    final cihazAdiCtrl = TextEditingController(text: device.customer);
    final markaCtrl = TextEditingController(text: marka);
    final modelCtrl = TextEditingController(text: model);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cihazı Düzenle',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: serialNumberCtrl,
                    decoration: InputDecoration(
                      labelText: 'Seri Numarası',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cihazAdiCtrl,
                    decoration: InputDecoration(
                      labelText: 'Cihaz Adı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: markaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Marka',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: modelCtrl,
                    decoration: InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final updatedDevice = device.copyWith(
                            serialNumber: serialNumberCtrl.text,
                            modelName: '${markaCtrl.text} ${modelCtrl.text}',
                            customer: cihazAdiCtrl.text,
                          );
                          
                          final success = await ref.read(inventoryProvider.notifier).updateDevice(updatedDevice);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Cihaz başarıyla güncellendi'),
                                backgroundColor: AppColors.primaryBlue,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Kaydet',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
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

  void _showEditPartSheet(BuildContext context, WidgetRef ref, StockPart part) {
    final formKey = GlobalKey<FormState>();
    final parcaAdiCtrl = TextEditingController(text: part.parcaAdi);
    final parcaKoduCtrl = TextEditingController(text: part.parcaKodu);
    final stokAdediCtrl = TextEditingController(text: part.stokAdedi.toString());
    final criticalLevelCtrl = TextEditingController(text: part.criticalLevel.toString());
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parçayı Düzenle',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: parcaAdiCtrl,
                    decoration: InputDecoration(
                      labelText: 'Parça Adı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: parcaKoduCtrl,
                    decoration: InputDecoration(
                      labelText: 'Parça Kodu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: stokAdediCtrl,
                    decoration: InputDecoration(
                      labelText: 'Stok Adedi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Bu alan boş bırakılamaz';
                      if (int.tryParse(v) == null) {
                        return 'Lütfen geçerli bir sayı girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: criticalLevelCtrl,
                    decoration: InputDecoration(
                      labelText: 'Kritik Seviye',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Bu alan boş bırakılamaz';
                      if (int.tryParse(v) == null) {
                        return 'Lütfen geçerli bir sayı girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final updatedPart = StockPart(
                            id: part.id,
                            parcaAdi: parcaAdiCtrl.text,
                            parcaKodu: parcaKoduCtrl.text,
                            stokAdedi: int.parse(stokAdediCtrl.text),
                            criticalLevel: int.parse(criticalLevelCtrl.text),
                          );
                          
                          final success = await ref.read(inventoryProvider.notifier).updatePart(updatedPart);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Parça başarıyla güncellendi'),
                                backgroundColor: AppColors.primaryBlue,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Kaydet',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
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

  Future<void> _showDeleteDeviceDialog(BuildContext context, WidgetRef ref, Device device) async {
    final isAdmin = ref.read(isAdminProvider);
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silme yetkisi sadece admin kullanıcılar içindir.'),
          backgroundColor: AppColors.criticalRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Cihazı Sil',
        message: '"${device.modelName}" cihazını silmek istediğinize emin misiniz?',
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(inventoryProvider.notifier).deleteDevice(device.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cihaz başarıyla silindi'),
            backgroundColor: AppColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showDeletePartDialog(BuildContext context, WidgetRef ref, StockPart part) async {
    final isAdmin = ref.read(isAdminProvider);
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silme yetkisi sadece admin kullanıcılar içindir.'),
          backgroundColor: AppColors.criticalRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Parçayı Sil',
        message: '"${part.parcaAdi}" parçasını silmek istediğinize emin misiniz?',
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(inventoryProvider.notifier).deletePart(part.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Parça başarıyla silindi'),
            backgroundColor: AppColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DeviceTile({
    required this.device,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.criticalRed),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: AppColors.criticalRed)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockPartTile extends StatelessWidget {
  final StockPart part;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StockPartTile({
    required this.part,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = part.stokAdedi == 0;
    final bool isCritical = !isOutOfStock && part.stokAdedi <= part.criticalLevel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOutOfStock
              ? AppColors.criticalRed
              : isCritical
              ? AppColors.criticalRed.withAlpha(89)
              : AppColors.primaryBlue.withAlpha(26),
          width: isOutOfStock ? 1.5 : isCritical ? 2 : 1,
        ),
        boxShadow: [
          if (isOutOfStock)
            BoxShadow(
              color: AppColors.criticalRed.withAlpha(46),
              blurRadius: 14,
              offset: const Offset(0, 2),
            )
          else if (isCritical)
            BoxShadow(
              color: AppColors.criticalRed.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: AppColors.primaryBlue.withAlpha(15),
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
                ? AppColors.criticalRed.withAlpha(100)
                : isCritical
                ? AppColors.criticalRed.withAlpha(46)
                : AppColors.primaryBlue.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isOutOfStock
                ? Icons.block
                : isCritical
                ? Icons.warning_amber_rounded
                : Icons.memory,
            color: isOutOfStock
                ? AppColors.criticalRed
                : isCritical
                ? AppColors.criticalRed
                : AppColors.primaryBlue,
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
                  color: isOutOfStock ? AppColors.criticalRed : AppColors.textColor,
                  fontSize: 16,
                ),
              ),
            ),
            if (isOutOfStock)
              Text(
                'Stok tükendi',
                style: GoogleFonts.montserrat(
                  color: AppColors.criticalRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              )
            else if (isCritical)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.criticalRed.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Stok kritik',
                  style: GoogleFonts.montserrat(
                    color: AppColors.criticalRed,
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
            color: isOutOfStock ? AppColors.criticalRed : AppColors.subtitleColor,
            fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.criticalRed),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: AppColors.criticalRed)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
