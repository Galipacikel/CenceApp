import 'package:flutter/material.dart';
import '../widgets/home/quick_access_card.dart';
import '../widgets/home/service_history_card.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/bottom_nav_bar.dart';
import 'device_query_screen.dart';
import 'new_service_form_screen.dart';
import 'service_history_screen.dart';
import 'stock_tracking_screen.dart';
import 'settings_screen.dart';
import 'all_service_history_screen.dart';
import 'service_history_detail_screen.dart';
import '../models/service_history.dart';
import '../models/stock_part.dart';
import 'package:provider/provider.dart';
import '../providers/service_history_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/device_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addServiceHistoryFromForm(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewServiceFormScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      final int formTipi = result['formTipi'] ?? 0;
      String status = 'Başarılı';
      if (formTipi == 2) status = 'Arızalı';
      final newHistory = ServiceHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: result['date'] ?? DateTime.now(),
        deviceId: result['deviceId'] ?? '',
        musteri: result['customer'] ?? '',
        description: result['description'] ?? '',
        technician: result['technician'] ?? '',
        status: status,
        kullanilanParcalar: (result['usedParts'] as List?)?.map((p) => StockPart(
          id: p['partCode'] ?? '',
          parcaAdi: p['partName'] ?? '',
          parcaKodu: p['partCode'] ?? '',
          stokAdedi: p['quantity'] ?? 1,
          criticalLevel: 5,
        )).toList() ?? [],
      );
      Provider.of<ServiceHistoryProvider>(context, listen: false).addServiceHistory(newHistory);
    }
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
            color: const Color(0xFFF5F6FA),
            border: const Border(
              bottom: BorderSide(color: Color(0xFF23408E), width: 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF23408E).withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
              // Modern medical cross + Cence logo
              Container(
                width: isWide ? 44 : 36,
                height: isWide ? 44 : 36,
                margin: const EdgeInsets.only(right: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Blue circle background
                    Container(
                      width: isWide ? 44 : 36,
                      height: isWide ? 44 : 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF23408E).withOpacity(0.09),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Medical cross
                    Positioned(
                      left: (isWide ? 22 : 18) - 7,
                      top: (isWide ? 22 : 18) - 13,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF23408E), width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(Icons.add, size: 12, color: const Color(0xFF23408E)),
                        ),
                      ),
                    ),
                    // Stylized C
                    Positioned(
                      left: 0,
                      child: Text(
                        'C',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: isWide ? 32 : 26,
                          color: const Color(0xFF23408E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Cence Medikal yazısı
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.montserrat(fontSize: isWide ? 26 : 20, fontWeight: FontWeight.bold),
                      children: const [
                        TextSpan(text: 'Ce', style: TextStyle(color: Color(0xFF23408E))),
                        TextSpan(text: 'n', style: TextStyle(color: Color(0xFFE53935))),
                        TextSpan(text: 'ce', style: TextStyle(color: Color(0xFF23408E))),
                      ],
                    ),
                  ),
                  Text('Medikal', style: GoogleFonts.montserrat(fontSize: isWide ? 15 : 12, color: Color(0xFF23408E), fontWeight: FontWeight.w500)),
                ],
              ),
              const Spacer(),
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
    final cardHeight = isWide ? 140.0 : 100.0;
    final cardIconSize = isWide ? 36.0 : 26.0;
    final gridCrossAxisCount = width > 1100 ? 5 : width > 800 ? 4 : isWide ? 3 : 2;
    final gridSpacing = isWide ? 24.0 : 12.0;
    final iconColor = const Color(0xFF23408E);
    final serviceHistoryList = Provider.of<ServiceHistoryProvider>(context).all;
    return Container(
      color: const Color(0xFFF5F6FA),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 14, vertical: isWide ? 24 : 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selamlama ve özet
            _WelcomeSummary(),
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
                  _ModernQuickAccessCard(
                    icon: Icons.search,
                    label: 'Cihaz Sorgula',
                    iconSize: cardIconSize,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CihazSorgulaScreen()),
                      );
                    },
                    iconColor: iconColor,
                  ),
                  _ModernQuickAccessCard(
                    icon: Icons.note_add_outlined,
                    label: 'Yeni Servis Formu',
                    iconSize: cardIconSize,
                    onTap: () => _addServiceHistoryFromForm(context),
                    iconColor: iconColor,
                  ),
                  _ModernQuickAccessCard(
                    icon: Icons.history,
                    label: 'Servis Geçmişi',
                    iconSize: cardIconSize,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ServisGecmisiScreen()),
                      );
                    },
                    iconColor: iconColor,
                  ),
                  _ModernQuickAccessCard(
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
                const Text('Son Servis İşlemleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1C1C1C))),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF23408E),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AllServiceHistoryScreen()),
                    );
                  },
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (serviceHistoryList.isEmpty)
              const _ModernServiceHistoryCard()
            else
              Column(
                children: serviceHistoryList
                    .take(3)
                    .map((item) => _ModernServiceCard(item: item))
                    .toList(),
              ),

            const SizedBox(height: 24),
            // Footer
            Center(
              child: Text('Cence Medikal © 2025', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Kullanıcı adı ve özet artık provider'dan alınacak
    final String user = 'Ahmet';
    final int device = Provider.of<DeviceProvider>(context).devices.length;
    final int service = Provider.of<ServiceHistoryProvider>(context).all.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFF23408E),
          radius: 22,
          child: Text(user[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hoş geldin, $user!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1C1C1C))),
              const SizedBox(height: 2),
              Text('Sistemde $device cihaz, $service servis kaydı var.', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}



class _ModernQuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final VoidCallback onTap;
  final Color iconColor;
  const _ModernQuickAccessCard({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.onTap,
    required this.iconColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16), // Küçük radius
        onTap: onTap,
        splashColor: iconColor.withOpacity(0.12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // Küçük radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10), // Daha az padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10), // Daha az padding
                child: Icon(icon, size: iconSize, color: iconColor), // Küçük ikon
              ),
              const SizedBox(height: 10), // Daha az spacing
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1C1C1C),
                  fontWeight: FontWeight.w600,
                  fontSize: 15, // Küçük font
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernServiceHistoryCard extends StatelessWidget {
  const _ModernServiceHistoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // küçültüldü
        border: Border.all(color: Colors.grey.shade100, width: 1.2), // inceltildi
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56, // küçültüldü
            color: Color(0xFFB0B3C0),
          ),
          SizedBox(height: 16), // azaltıldı
          Text(
            'Henüz servis kaydı yok',
            style: TextStyle(
              fontSize: 16, // küçültüldü
              fontWeight: FontWeight.w500,
              color: Color(0xFF6F7489),
            ),
          )
        ],
      ),
    );
  }
}

class _ModernServiceCard extends StatelessWidget {
  final ServiceHistory item;
  const _ModernServiceCard({required this.item, Key? key}) : super(key: key);

  Map<String, dynamic> getStatusData(String status) {
    switch (status) {
      case 'Başarılı':
        return {
          'label': 'Başarılı',
          'color': Colors.blue.shade800,
          'bgColor': Colors.blue.shade100,
          'icon': Icons.check_circle_rounded,
        };
      case 'Beklemede':
        return {
          'label': 'Beklemede',
          'color': Colors.amber.shade800,
          'bgColor': Colors.amber.shade200,
          'icon': Icons.hourglass_bottom_rounded,
        };
      case 'Arızalı':
        return {
          'label': 'Arızalı',
          'color': Colors.red.shade800,
          'bgColor': Colors.red.shade100,
          'icon': Icons.error_rounded,
        };
      default:
        return {
          'label': item.status,
          'color': Colors.grey.shade800,
          'bgColor': Colors.grey.shade200,
          'icon': Icons.info_outline_rounded,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusData = getStatusData(item.status);

    return InkWell(
      borderRadius: BorderRadius.circular(16.0),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ServiceHistoryDetailScreen(serviceHistory: item),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: Colors.grey.shade100, width: 1.2),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            leading: Icon(
              statusData['icon'],
              color: statusData['color'],
              size: 32,
            ),
            title: Text(
              '${item.deviceId} - ${item.description}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF1C1C1C),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Teknisyen: ${item.technician}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusData['bgColor'],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusData['label'],
                style: TextStyle(
                  color: statusData['color'],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 