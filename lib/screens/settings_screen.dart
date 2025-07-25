import 'package:flutter/material.dart';
import 'profile_edit_screen.dart';
import 'change_password_screen.dart';
import 'notification_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'help_center_screen.dart';
import 'support_request_screen.dart';
import 'app_info_screen.dart';
import 'privacy_policy_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'login_screen.dart';
import '../models/app_settings.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF23408E);
    final Color lightBlue = const Color(0xFF64B5F6);
    final Color background = const Color(0xFFF7F9FC);
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF232946);
    final Color subtitleColor = const Color(0xFF4A4A4A);
    final double cardRadius = 18;
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Ayarlar',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: primaryBlue),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            children: [
              // Kullanıcı Kartı
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
                child: Consumer<AppStateProvider>(
                  builder: (context, appState, _) {
                    final user = appState.userProfile;
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: primaryBlue,
                          child: Icon(Icons.person, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user.name} ${user.surname}',
                                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.title,
                                style: GoogleFonts.montserrat(fontSize: 14, color: subtitleColor),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: primaryBlue),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileEditScreen()));
                          },
                          splashRadius: 24,
                          tooltip: 'Profili Düzenle',
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Ayar Kartları
              _SettingsCard(
                icon: Icons.lock_outline,
                title: 'Şifre Değiştir',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChangePasswordScreen())),
                iconColor: primaryBlue,
                cardColor: cardColor,
                cardRadius: cardRadius,
                textColor: textColor,
              ),
              _SettingsCard(
                icon: Icons.notifications_active_outlined,
                title: 'Bildirim Ayarları',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationSettingsScreen())),
                iconColor: primaryBlue,
                cardColor: cardColor,
                cardRadius: cardRadius,
                textColor: textColor,
              ),
              _SettingsCard(
                icon: Icons.palette_outlined,
                title: 'Tema ve Görünüm',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ThemeSettingsScreen())),
                iconColor: primaryBlue,
                cardColor: cardColor,
                cardRadius: cardRadius,
                textColor: textColor,
              ),
              _SettingsCard(
                icon: Icons.help_outline,
                title: 'Yardım Merkezi',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HelpCenterScreen())),
                iconColor: primaryBlue,
                cardColor: cardColor,
                cardRadius: cardRadius,
                textColor: textColor,
              ),
              _SettingsCard(
                icon: Icons.support_agent_outlined,
                title: 'Destek Talebi',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SupportRequestScreen())),
                iconColor: primaryBlue,
                cardColor: cardColor,
                cardRadius: cardRadius,
                textColor: textColor,
              ),
              _SettingsCard(
                icon: Icons.info_outline,
                title: 'Uygulama Bilgisi',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AppInfoScreen())),
                iconColor: primaryBlue,
                cardColor: cardColor,
                cardRadius: cardRadius,
                textColor: textColor,
              ),
              _SettingsCard(
                icon: Icons.privacy_tip_outlined,
                title: 'Gizlilik ve Koşullar',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PrivacyPolicyScreen())),
                iconColor: primaryBlue,
                cardColor: cardColor,
                cardRadius: cardRadius,
                textColor: textColor,
              ),
              const SizedBox(height: 32),
              // Çıkış Butonu
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'Çıkış Yap',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'Çıkış yapmak istediğinizden emin misiniz?',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: const Color(0xFF4A4A4A),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'İptal',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: const Color(0xFF4A4A4A),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: Text(
                              'Çıkış Yap',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout),
                label: Text('Çıkış Yap', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color cardColor;
  final double cardRadius;
  final Color textColor;
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.iconColor,
    required this.cardColor,
    required this.cardRadius,
    required this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(cardRadius),
          onTap: onTap,
          splashColor: iconColor.withOpacity(0.08),
          highlightColor: iconColor.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: textColor),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFB0B6C3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 