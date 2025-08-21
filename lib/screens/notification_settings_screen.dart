import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _faultNotification = true;
  bool _maintenanceNotification = false;
  bool _stockNotification = true;

  @override
  void initState() {
    super.initState();
    // Mevcut ayarları yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      setState(() {
        _faultNotification = appState.appSettings.faultNotification;
        _maintenanceNotification = appState.appSettings.maintenanceNotification;
        _stockNotification = appState.appSettings.stockNotification;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF23408E);
    final Color background = const Color(0xFFF7F9FC);
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF232946);
    final double cardRadius = 18;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bildirim Ayarları',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationSwitch(
                  title: 'Yeni Arıza Kaydı Bildirimi',
                  subtitle: 'Yeni bir arıza kaydı oluşturulduğunda bildirim al',
                  value: _faultNotification,
                  onChanged: (val) {
                    setState(() {
                      _faultNotification = val;
                    });
                  },
                  primaryBlue: primaryBlue,
                ),
                const Divider(height: 28),
                _NotificationSwitch(
                  title: 'Yaklaşan Bakım Bildirimi',
                  subtitle: 'Bakım zamanı yaklaşan cihazlar için bildirim al',
                  value: _maintenanceNotification,
                  onChanged: (val) {
                    setState(() {
                      _maintenanceNotification = val;
                    });
                  },
                  primaryBlue: primaryBlue,
                ),
                const Divider(height: 28),
                _NotificationSwitch(
                  title: 'Parça Stoğu Azalması Bildirimi',
                  subtitle: 'Stokta azalan parça olduğunda bildirim al',
                  value: _stockNotification,
                  onChanged: (val) {
                    setState(() {
                      _stockNotification = val;
                    });
                  },
                  primaryBlue: primaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // Ayarları kaydet
                final appState = Provider.of<AppStateProvider>(context, listen: false);
                appState.setFaultNotification(_faultNotification);
                appState.setMaintenanceNotification(_maintenanceNotification);
                appState.setStockNotification(_stockNotification);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bildirim ayarları başarıyla kaydedildi!'),
                    backgroundColor: Color(0xFF424242),
                  ),
                );
                
                Navigator.pop(context);
              },
              child: Text(
                'Kaydet',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color primaryBlue;
  const _NotificationSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = const Color(0xFF232946);
    final Color subtitleColor = const Color(0xFF4A4A4A);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: primaryBlue),
      ],
    );
  }
}
