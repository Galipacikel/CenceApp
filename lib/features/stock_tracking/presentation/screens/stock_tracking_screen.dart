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
import 'package:cence_app/widgets/stock_tracking/device_tile.dart';
import 'package:cence_app/widgets/stock_tracking/stock_part_tile.dart';
import 'package:cence_app/widgets/stock_tracking/device_form_sheet.dart';
import 'package:cence_app/widgets/stock_tracking/part_form_sheet.dart';

class StokTakibiScreen extends ConsumerWidget {
  const StokTakibiScreen({super.key});

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
        appBar: _buildAppBar(context, ref, selectedIndex),
        body: Column(
          children: [
            _buildTabBar(context, ref),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDevicesTab(context, ref, isWide),
                  _buildPartsTab(context, ref, isWide, showOnlyCritical),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, int selectedIndex) {
    return PreferredSize(
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
                  tooltip: selectedIndex == 0 ? 'Yeni Cihaz Ekle' : 'Yeni Parça Ekle',
                  onPressed: () => _handleAddButtonPress(context, ref, selectedIndex, isAdmin),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, WidgetRef ref) {
    return Container(
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
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withAlpha(179),
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
    );
  }

  Widget _buildDevicesTab(BuildContext context, WidgetRef ref, bool isWide) {
    return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isWide ? 600 : double.infinity,
              ),
        child: Consumer(
          builder: (context, ref, _) {
            final devicesAsync = ref.watch(filteredDevicesProvider);
            return devicesAsync.when(
              data: (devices) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSearchField(
                      hintText: 'Model ile ara...',
                      onChanged: (value) => ref.read(inventoryProvider.notifier).setDeviceSearch(value),
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
                            return DeviceTile(
                              device: device,
                              onEdit: () => _showDeviceFormSheet(context, ref, device),
                              onDelete: () => _showDeleteDeviceDialog(context, ref, device),
                            );
                          },
                        ),
                      ),
                    ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Hata oluştu')),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildPartsTab(BuildContext context, WidgetRef ref, bool isWide, bool showOnlyCritical) {
    return Center(
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                      child: _buildSearchField(
                        hintText: 'Parça adı veya kodu ile ara...',
                        onChanged: (value) => ref.read(inventoryProvider.notifier).setPartSearch(value),
                      ),
                    ),
                    _buildCriticalWarningBanner(context, ref, showOnlyCritical, criticalParts),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
                            (p) => StockPartTile(
                              part: p,
                              onEdit: () => _showPartFormSheet(context, ref, p),
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
    );
  }

  Widget _buildSearchField({
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
                          decoration: InputDecoration(
        hintText: hintText,
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
      onChanged: onChanged,
    );
  }

  Widget _buildCriticalWarningBanner(BuildContext context, WidgetRef ref, bool showOnlyCritical, List<StockPart> criticalParts) {
    final hasCriticalParts = criticalParts.isNotEmpty;
    
    return GestureDetector(
                                onTap: () {
        if (hasCriticalParts) {
          ref.read(inventoryProvider.notifier).toggleShowOnlyCritical();
        }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
          color: hasCriticalParts 
              ? AppColors.criticalRed.withAlpha(33)
              : Colors.grey.withAlpha(33),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
            color: hasCriticalParts 
                ? AppColors.criticalRed.withAlpha(77)
                : Colors.grey.withAlpha(77),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
              color: hasCriticalParts 
                  ? AppColors.criticalRed.withAlpha(26)
                  : Colors.grey.withAlpha(26),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
              hasCriticalParts ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: hasCriticalParts ? AppColors.criticalRed : Colors.grey[600],
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
                        hasCriticalParts ? 'Kritik Seviye Uyarısı' : 'Stok Durumu',
                                                  style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                          color: hasCriticalParts ? AppColors.criticalRed : Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                          color: hasCriticalParts 
                              ? AppColors.criticalRed.withAlpha(46)
                              : Colors.grey.withAlpha(46),
                          borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '${criticalParts.length}',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: hasCriticalParts ? AppColors.criticalRed : Colors.grey[600],
                            fontSize: 12,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                    hasCriticalParts
                        ? (showOnlyCritical
                                                  ? 'Kritik seviyedekiler gösteriliyor'
                            : 'Stokta kritik seviyeye düşen parçalarınız var!')
                        : 'Tüm parçalar normal seviyede',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 13,
                      color: hasCriticalParts ? AppColors.criticalRed : Colors.grey[600],
                                              ),
                                            ),
                  if (hasCriticalParts)
                                            Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                                              child: Text(
                        showOnlyCritical ? 'Tüm parçaları göster' : 'Kritik seviyeleri gör',
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

  void _handleAddButtonPress(BuildContext context, WidgetRef ref, int selectedIndex, bool isAdmin) {
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
      _showDeviceFormSheet(context, ref, null);
    } else {
      _showPartFormSheet(context, ref, null);
    }
  }

  void _showDeviceFormSheet(BuildContext context, WidgetRef ref, Device? device) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
      builder: (ctx) => DeviceFormSheet(device: device),
    );
  }

  void _showPartFormSheet(BuildContext context, WidgetRef ref, StockPart? part) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => PartFormSheet(part: part),
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
          const SnackBar(
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
          const SnackBar(
            content: Text('Parça başarıyla silindi'),
            backgroundColor: AppColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
  }
}

