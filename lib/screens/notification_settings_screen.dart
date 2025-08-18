import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/app_state_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF23408E);
    final Color background = const Color(0xFFF7F9FC);
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF232946);
    // final Color subtitleColor = const Color(0xFF4A4A4A);
    final double cardRadius = 18;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bildirim Ayarları',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: primaryBlue),
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
                  value: true,
                  onChanged: (val) {},
                  primaryBlue: primaryBlue,
                ),
                const Divider(height: 28),
                _NotificationSwitch(
                  title: 'Yaklaşan Bakım Bildirimi',
                  subtitle: 'Bakım zamanı yaklaşan cihazlar için bildirim al',
                  value: false,
                  onChanged: (val) {},
                  primaryBlue: primaryBlue,
                ),
                const Divider(height: 28),
                _NotificationSwitch(
                  title: 'Parça Stoğu Azalması Bildirimi',
                  subtitle: 'Stokta azalan parça olduğunda bildirim al',
                  value: true,
                  onChanged: (val) {},
                  primaryBlue: primaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
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
              // Kaydet işlemi
            },
            child: Text(
              'Kaydet',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
