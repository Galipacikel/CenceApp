import 'package:flutter/material.dart';
import 'package:cence_app/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:cence_app/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:cence_app/features/settings/presentation/screens/theme_settings_screen.dart';
import 'package:cence_app/features/support/presentation/screens/help_center_screen.dart';
import 'package:cence_app/features/support/presentation/screens/support_request_screen.dart';
import 'package:cence_app/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/core/providers/firebase_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<String?> _loadProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_path');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color primaryBlue = const Color(0xFF23408E);
    final Color background = const Color(0xFFF7F9FC);
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF232946);
    final Color subtitleColor = const Color(0xFF4A4A4A);
    final double cardRadius = 18;
    final isWide = MediaQuery.of(context).size.width > 600;

    final asyncUser = ref.watch(appUserProvider);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 500 : double.infinity,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 24,
                    ),
                    children: [
                      // Kullanıcı Kartı
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(cardRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: asyncUser.when(
                          data: (u) {
                            final fullName = (u?.fullName ?? '').trim();
                            final parts = fullName.split(RegExp(r"\s+"));
                            final name = parts.isNotEmpty ? parts.first : '';
                            final surname = parts.length > 1
                                ? parts.sublist(1).join(' ')
                                : '';
                            final title = (u?.isAdmin ?? false)
                                ? 'Admin'
                                : 'Teknisyen';
                            return Row(
                              children: [
                                FutureBuilder<String?>(
                                  future: _loadProfileImagePath(),
                                  builder: (context, snapshot) {
                                    final path = snapshot.data;
                                    final hasImage =
                                        path != null &&
                                        path.isNotEmpty &&
                                        File(path).existsSync();
                                    return CircleAvatar(
                                      radius: 32,
                                      backgroundColor: primaryBlue,
                                      backgroundImage: hasImage
                                          ? FileImage(File(path))
                                          : null,
                                      child: !hasImage
                                          ? Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 32,
                                            )
                                          : null,
                                    );
                                  },
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (name.isEmpty && surname.isEmpty)
                                            ? 'Kullanıcı'
                                            : '$name $surname'.trim(),
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        title,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: primaryBlue),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ProfileEditScreen(),
                                      ),
                                    );
                                  },
                                  splashRadius: 24,
                                  tooltip: 'Profili Düzenle',
                                ),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) => Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: primaryBlue,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kullanıcı',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Teknisyen',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: primaryBlue),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ProfileEditScreen(),
                                    ),
                                  );
                                },
                                splashRadius: 24,
                                tooltip: 'Profili Düzenle',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Ayar Kartları
                      _SettingsCard(
                        icon: Icons.notifications_active_outlined,
                        title: 'Bildirim Ayarları',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationSettingsScreen(),
                          ),
                        ),
                        iconColor: primaryBlue,
                        cardColor: cardColor,
                        cardRadius: cardRadius,
                        textColor: textColor,
                      ),
                      _SettingsCard(
                        icon: Icons.palette_outlined,
                        title: 'Tema ve Görünüm',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ThemeSettingsScreen(),
                          ),
                        ),
                        iconColor: primaryBlue,
                        cardColor: cardColor,
                        cardRadius: cardRadius,
                        textColor: textColor,
                      ),
                      _SettingsCard(
                        icon: Icons.help_outline,
                        title: 'Yardım Merkezi',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HelpCenterScreen(),
                          ),
                        ),
                        iconColor: primaryBlue,
                        cardColor: cardColor,
                        cardRadius: cardRadius,
                        textColor: textColor,
                      ),
                      _SettingsCard(
                        icon: Icons.support_agent_outlined,
                        title: 'Destek Talebi',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SupportRequestScreen(),
                          ),
                        ),
                        iconColor: primaryBlue,
                        cardColor: cardColor,
                        cardRadius: cardRadius,
                        textColor: textColor,
                      ),
                      _SettingsCard(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Gizlilik ve Koşullar',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        ),
                        iconColor: primaryBlue,
                        cardColor: cardColor,
                        cardRadius: cardRadius,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            // Çıkış Butonu - Navigation bar'ın hemen üzerinde
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                              Icon(
                                Icons.logout,
                                color: Colors.red.shade600,
                                size: 20,
                              ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await ref.read(firebaseAuthProvider).signOut();
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
                  label: Text(
                    'Çıkış Yap',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
  });

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
          splashColor: iconColor.withAlpha(20),
          highlightColor: iconColor.withAlpha(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF232946),
                    ),
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
