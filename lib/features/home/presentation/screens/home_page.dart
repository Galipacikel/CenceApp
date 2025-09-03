import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:cence_app/features/home/presentation/providers/home_providers.dart';
import 'package:cence_app/widgets/common/bottom_nav_bar.dart';
import 'package:cence_app/widgets/common/cards/quick_access_card.dart';
// import 'package:cence_app/widgets/common/cards/service_card.dart';
// import 'package:cence_app/widgets/common/cards/empty_service_card.dart';

import 'package:cence_app/features/devices/presentation/screens/device_query_screen.dart';
import 'package:cence_app/features/service_history/presentation/screens/new_service_form_screen.dart';
import 'package:cence_app/features/service_history/presentation/screens/service_history_screen.dart';
import 'package:cence_app/features/stock_tracking/presentation/screens/stock_tracking_screen.dart';
import 'package:cence_app/features/settings/presentation/screens/settings_screen.dart';
// import 'package:cence_app/features/service_history/presentation/screens/all_service_history_screen.dart';
// removed unused: service_history model not needed here

// import 'package:provider/provider.dart';
// import 'package:cence_app/providers/service_history_provider.dart';

// import 'package:cence_app/providers/device_provider.dart';

class HomePage extends rp.ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  rp.ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends rp.ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Remove legacy provider prefetch; Riverpod providers load lazily on watch
  }

  Future<void> _addServiceHistoryFromForm(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewServiceFormScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    // Responsive logo sizing (2x of the original 28/24)
    final double baseLogoSize = isWide ? 28.0 : 24.0;
    final double logoSize = baseLogoSize * 2; // 2x enlargement
    // AppBar height scales with logo size (start from original 90/70 and add the delta)
    final double appBarHeight =
        (isWide ? 90.0 : 70.0) + (logoSize - baseLogoSize);
    final currentIndex = ref.watch(homeCurrentIndexProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF23408E),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF23408E).withValues(alpha: 0.2),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/app_icon/cence_logo.jpeg',
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.cover,
                  ),
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
                        color: Colors.white.withValues(alpha: 0.9),
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
      body: currentIndex == 0
          ? _buildMainContent(context, isWide)
          : const SettingsScreen(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(homeCurrentIndexProvider.notifier).state = index,
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
                    color: const Color(0xFF23408E).withValues(alpha: 0.08),
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
                          color: const Color(0xFF23408E).withValues(alpha: 0.1),
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

            // Son Servis İşlemleri bölümü kaldırıldı (istek üzerine)
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
