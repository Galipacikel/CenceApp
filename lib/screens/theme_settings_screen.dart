import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final Color primaryBlue = const Color(0xFF23408E);
    final Color background = const Color(0xFFF7F9FC);
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF232946);
    // final Color subtitleColor = const Color(0xFF4A4A4A);
    final double cardRadius = 18;
    final isWide = MediaQuery.of(context).size.width > 600;
    final themeMode = appState.appSettings.themeMode;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Tema ve Görünüm',
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
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
          child: ListView(
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
                    Text(
                      'Tema Seçimi',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ThemeOption(
                      label: 'Açık Tema',
                      icon: Icons.light_mode,
                      selected: themeMode == ThemeMode.light,
                      onTap: () => appState.setThemeMode(ThemeMode.light),
                      primaryBlue: primaryBlue,
                    ),
                    const SizedBox(height: 12),
                    _ThemeOption(
                      label: 'Koyu Tema',
                      icon: Icons.dark_mode,
                      selected: themeMode == ThemeMode.dark,
                      onTap: () => appState.setThemeMode(ThemeMode.dark),
                      primaryBlue: primaryBlue,
                    ),
                    const SizedBox(height: 12),
                    _ThemeOption(
                      label: 'Sistem Varsayılanı',
                      icon: Icons.phone_android,
                      selected: themeMode == ThemeMode.system,
                      onTap: () => appState.setThemeMode(ThemeMode.system),
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
                    // Tema ayarlarını kaydet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tema ayarları başarıyla kaydedildi!'),
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
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryBlue;
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? primaryBlue.withOpacity(0.08) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: primaryBlue.withOpacity(0.10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: selected ? primaryBlue : Colors.grey, size: 26),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: selected ? primaryBlue : Colors.black87,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: primaryBlue, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
