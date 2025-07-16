import 'package:flutter/material.dart';
import '../widgets/home/quick_access_card.dart';
import '../widgets/home/service_history_card.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/bottom_nav_bar.dart';
import 'cihaz_sorgula_screen.dart';
import 'yeni_servis_formu_screen.dart';
import 'servis_gecmisi_screen.dart';
import 'stok_takibi_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: CustomAppBar(),
      ),
      body: _currentIndex == 0 ? _buildMainContent(context) : const SettingsScreen(),
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

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Denetim Paneli Butonu
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23408E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {},
                icon: const Icon(Icons.dashboard_customize, size: 20, color: Colors.white),
                label: const Text(
                  'Denetim Paneli',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hızlı Erişim Kartları
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              QuickAccessCard(
                icon: Icons.search,
                label: 'Cihaz Sorgula',
                iconSize: 26,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CihazSorgulaScreen()),
                  );
                },
              ),
              QuickAccessCard(
                icon: Icons.note_add_outlined,
                label: 'Yeni Servis Formu',
                iconSize: 26,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const YeniServisFormuScreen()),
                  );
                },
              ),
              QuickAccessCard(
                icon: Icons.history,
                label: 'Servis Geçmişi',
                iconSize: 26,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ServisGecmisiScreen()),
                  );
                },
              ),
              QuickAccessCard(
                icon: Icons.inventory_2_outlined,
                label: 'Stok Takibi',
                iconSize: 26,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StokTakibiScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Son Servis İşlemleri
          ServiceHistoryCard(),
        ],
      ),
    );
  }
} 