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
import 'all_service_history_screen.dart';
import 'service_history_detail_screen.dart';
import '../models/service_history.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final MockServiceHistoryRepository _repository = MockServiceHistoryRepository();
  List<ServiceHistory> _serviceHistoryList = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final all = await _repository.getAll();
    setState(() {
      _serviceHistoryList = all;
    });
  }

  Future<void> _addServiceHistoryFromForm(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const YeniServisFormuScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      final int formTipi = result['formTipi'] ?? 0;
      String type = 'Kurulum';
      String status = 'Tamamlandı';
      if (formTipi == 1) {
        type = 'Bakım';
        status = 'Tamamlandı';
      } else if (formTipi == 2) {
        type = 'Arıza';
        status = 'Arızalı';
      }
      final newHistory = ServiceHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: result['tarih'] ?? DateTime.now(),
        type: type,
        description: result['aciklama'] ?? '',
        technician: result['teknisyen'] ?? '',
        status: status,
      );
      await _repository.add(newHistory);
      await _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isWide ? 100 : 80),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 18),
              // Modern logo (CustomPaint veya SVG)
              _CenceLogo(height: isWide ? 44 : 36),
              const SizedBox(width: 12),
              // Cence yazısı (renkli TextSpan)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                      children: [
                        TextSpan(text: 'Ce', style: TextStyle(color: Color(0xFF1C1C1C))),
                        TextSpan(text: 'n', style: TextStyle(color: Color(0xFFE53935))),
                        TextSpan(text: 'ce', style: TextStyle(color: Color(0xFF1C1C1C))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('Medikal', style: TextStyle(fontSize: 14, color: Color(0xFF1C1C1C), fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                ],
              ),
              const Spacer(),
              // (Profil veya ayarlar butonu istenmiyor)
              const SizedBox(width: 18),
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
    final cardHeight = isWide ? 160.0 : 120.0;
    final cardIconSize = isWide ? 44.0 : 32.0;
    final gridCrossAxisCount = width > 1100 ? 5 : width > 800 ? 4 : isWide ? 3 : 2;
    final gridSpacing = isWide ? 28.0 : 16.0;
    final iconColor = const Color(0xFF23408E);
    return Container(
      color: const Color(0xFFF5F6FA),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 18, vertical: isWide ? 28 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selamlama ve özet
            _WelcomeSummary(),
            const SizedBox(height: 18),
            // Hızlı Erişim Kartları (animasyonlu)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: GridView.count(
                key: ValueKey(gridCrossAxisCount),
                crossAxisCount: gridCrossAxisCount,
                shrinkWrap: true,
                mainAxisSpacing: gridSpacing,
                crossAxisSpacing: gridSpacing,
                childAspectRatio: isWide ? 1.18 : 1.05,
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
                        MaterialPageRoute(builder: (_) => ServisGecmisiScreen(repository: _repository)),
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
                      MaterialPageRoute(builder: (_) => AllServiceHistoryScreen(repository: _repository)),
                    );
                  },
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _ModernServiceHistoryCard(items: _serviceHistoryList.take(3).toList()),
            // Watermark
            Align(
              alignment: Alignment.bottomRight,
              child: Opacity(
                opacity: 0.07,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, right: 8),
                  child: _CenceLogo(height: 60),
                ),
              ),
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
    // Örnek kullanıcı adı ve özet (gerçek projede provider veya API'dan alınabilir)
    final String user = 'Ahmet';
    final int cihaz = 12;
    final int servis = 34;
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
              Text('Sistemde $cihaz cihaz, $servis servis kaydı var.', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenceLogo extends StatelessWidget {
  final double height;
  const _CenceLogo({required this.height, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * 1.1,
      child: CustomPaint(
        painter: _CenceLogoPainter(),
      ),
    );
  }
}

class _CenceLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // C harfi siyah
    final cPaint = Paint()
      ..color = const Color(0xFF1C1C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.13
      ..strokeCap = StrokeCap.round;
    // n harfi kırmızı
    final nPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.13
      ..strokeCap = StrokeCap.round;
    // C harfi
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.13, size.width * 0.8, size.height * 0.74),
      0.8,
      4.6,
      false,
      cPaint,
    );
    // n harfi
    final nPath = Path();
    nPath.moveTo(size.width * 0.55, size.height * 0.55);
    nPath.lineTo(size.width * 0.55, size.height * 0.80);
    nPath.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.45,
      size.width * 0.85,
      size.height * 0.45,
    );
    nPath.lineTo(size.width * 0.85, size.height * 0.80);
    canvas.drawPath(nPath, nPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        splashColor: Colors.black12,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: iconColor),
              const SizedBox(height: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1C1C1C),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.2,
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
  final List<ServiceHistory> items;
  const _ModernServiceHistoryCard({required this.items, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.inbox_rounded, size: 60, color: Color(0xFF23408E)),
            SizedBox(height: 16),
            Text('Kayıt bulunamadı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF23408E))),
            SizedBox(height: 8),
            Text('Son servis işlemi kaydı yok.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.black54)),
          ],
        ),
      );
    }
    return Column(
      children: items.map((item) => _ModernServiceCard(item: item)).toList(),
    );
  }
}

class _ModernServiceCard extends StatelessWidget {
  final ServiceHistory item;
  const _ModernServiceCard({required this.item, Key? key}) : super(key: key);

  String get statusLabel {
    switch (item.status) {
      case 'Tamamlandı':
        return 'Tamamlandı';
      case 'Beklemede':
        return 'Beklemede';
      case 'Arızalı':
        return 'Arızalı';
      default:
        return item.status;
    }
  }

  Color get statusBgColor {
    switch (item.status) {
      case 'Tamamlandı':
        return const Color(0xFF23408E); // Lacivert
      case 'Beklemede':
        return Color(0xFFFFD600); // Canlı sarı
      case 'Arızalı':
        return const Color(0xFFE53935); // Kırmızı
      default:
        return const Color(0xFF23408E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ServiceHistoryDetailScreen(serviceHistory: item),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            leading: Icon(
              item.status == 'Tamamlandı'
                  ? Icons.check_circle_rounded
                  : item.status == 'Beklemede'
                      ? Icons.hourglass_bottom_rounded
                      : item.status == 'Arızalı'
                          ? Icons.error_rounded
                          : Icons.info_outline_rounded,
              color: const Color(0xFF23408E),
              size: 32,
            ),
            title: Text('${item.type} - ${item.description}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1C))),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tarih: ${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year}', style: const TextStyle(fontSize: 13, color: Color(0xFF23408E))),
                Text('Teknisyen: ${item.technician}', style: const TextStyle(fontSize: 13, color: Color(0xFF23408E))),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel,
                style: const TextStyle(
                  color: Colors.white,
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