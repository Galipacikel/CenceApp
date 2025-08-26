import 'package:flutter/material.dart';

import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/common/cards/quick_access_card.dart';
import '../widgets/common/cards/service_card.dart';
import '../widgets/common/cards/empty_service_card.dart';

import 'device_query_screen.dart';
import 'new_service_form_screen.dart';
import 'service_history_screen.dart';
import 'stock_tracking_screen.dart';
import 'settings_screen.dart';
import 'all_service_history_screen.dart';
import '../models/service_history.dart';

import 'package:provider/provider.dart';
import '../providers/service_history_provider.dart';
import '../providers/stock_provider.dart';
import '../providers/device_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Firestore'dan ilk verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final deviceProvider = Provider.of<DeviceProvider>(
        context,
        listen: false,
      );
      final serviceHistoryProvider = Provider.of<ServiceHistoryProvider>(
        context,
        listen: false,
      );
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      await Future.wait([
        deviceProvider.fetchAll(),
        serviceHistoryProvider.fetchAll(),
        stockProvider.fetchAll(),
      ]);
    });
  }

  Future<void> _addServiceHistoryFromForm(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewServiceFormScreen()));
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
              // Logo container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: isWide ? 28 : 24,
                ),
              ),
              const SizedBox(width: 16),

              // Cence yazısı
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        children: [
                          TextSpan(
                            text: 'Ce',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'n',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'ce',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Medikal Cihazlar',
                      style: TextStyle(
                        fontSize: isWide ? 14 : 12,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _currentIndex == 0
          ? _buildMainContent(context, isWide)
          : const SettingsScreen(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isWide) {
    final width = MediaQuery.of(context).size.width;

    final cardIconSize = isWide ? 36.0 : 26.0;
    final gridCrossAxisCount = width > 1100
        ? 5
        : width > 800
        ? 4
        : isWide
        ? 3
        : 2;
    final gridSpacing = isWide ? 24.0 : 12.0;
    final iconColor = const Color(0xFF23408E);
    final serviceHistoryList = Provider.of<ServiceHistoryProvider>(context).all;
    return Container(
      color: const Color(0xFFF5F6FA),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 40 : 14,
          vertical: isWide ? 24 : 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selamlama ve özet
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF23408E).withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF23408E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.waving_hand_rounded,
                          color: const Color(0xFF23408E),
                          size: isWide ? 28 : 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hoş Geldiniz!',
                              style: TextStyle(
                                fontSize: isWide ? 22 : 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C1C1C),
                              ),
                            ),
                            Text(
                              'Medikal cihaz yönetim sisteminize hoş geldiniz',
                              style: TextStyle(
                                fontSize: isWide ? 15 : 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Hızlı Erişim Kartları (animasyonlu)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: GridView.count(
                key: ValueKey(gridCrossAxisCount),
                crossAxisCount: gridCrossAxisCount,
                shrinkWrap: true,
                mainAxisSpacing: gridSpacing,
                crossAxisSpacing: gridSpacing,
                childAspectRatio: isWide ? 1.18 : 1.15, // Daha kısa kartlar
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ModernQuickAccessCard(
                    icon: Icons.search,
                    label: 'Cihaz Sorgula',
                    iconSize: cardIconSize,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CihazSorgulaScreen(),
                        ),
                      );
                    },
                    iconColor: iconColor,
                  ),
                  ModernQuickAccessCard(
                    icon: Icons.note_add_outlined,
                    label: 'Yeni Servis Formu',
                    iconSize: cardIconSize,
                    onTap: () => _addServiceHistoryFromForm(context),
                    iconColor: iconColor,
                  ),
                  ModernQuickAccessCard(
                    icon: Icons.history,
                    label: 'Servis Geçmişi',
                    iconSize: cardIconSize,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ServisGecmisiScreen(),
                        ),
                      );
                    },
                    iconColor: iconColor,
                  ),
                  ModernQuickAccessCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Stok Takibi',
                    iconSize: cardIconSize,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => StokTakibiScreen()),
                      );
                    },
                    iconColor: iconColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // Son Servis İşlemleri başlık + buton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Son Servis İşlemleri',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF23408E),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AllServiceHistoryScreen(),
                      ),
                    );
                  },
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (serviceHistoryList.isEmpty)
              const EmptyServiceCard()
            else
              Column(
                children: serviceHistoryList
                    .take(3)
                    .map((item) => ModernServiceCard(item: item))
                    .toList(),
              ),

            const SizedBox(height: 24),
            // Footer
            Center(
              child: Text(
                'Cence Medikal © 2025',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
