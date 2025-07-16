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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Profil Kartı
          _ProfileCard(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                // Hesap/Profil Ayarları
                _SectionHeader(title: 'Hesap/Profil Ayarları'),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Şifre Değiştirme',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.notifications_none,
                  title: 'Bildirimler',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.brightness_6_outlined,
                  title: 'Tema',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Destek
                _SectionHeader(title: 'Destek'),
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Yardım Merkezi / SSS',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.support_agent_outlined,
                  title: 'Destek Talebi / İletişim',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SupportRequestScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Hakkında
                _SectionHeader(title: 'Hakkında'),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'Uygulama Bilgisi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppInfoScreen()),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Gizlilik ve Koşullar',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Çıkış Yap
                _SettingsTile(
                  icon: Icons.logout,
                  title: 'Çıkış Yap',
                  iconColor: Colors.red,
                  titleColor: Colors.red,
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Çıkış Yap'),
                        content: const Text('Oturumunuzu kapatmak istediğinize emin misiniz?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Vazgeç'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Çıkış Yap'),
                          ),
                        ],
                      ),
                    );
                    if (shouldLogout == true) {
                      // Provider'daki state'i sıfırla
                      Provider.of<AppStateProvider>(context, listen: false).updateUserProfile(
                        Provider.of<AppStateProvider>(context, listen: false).userProfile.copyWith(
                          name: 'Ali',
                          surname: 'Yılmaz',
                          title: 'Teknik Servis Sorumlusu',
                          profileImagePath: null,
                        ),
                      );
                      Provider.of<AppStateProvider>(context, listen: false).updateAppSettings(AppSettings());
                      // LoginScreen'e yönlendir
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Alt Bilgi
          _BottomInfoBar(),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppStateProvider>(context).userProfile;
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: user.profileImagePath != null
                  ? FileImage(File(user.profileImagePath!))
                  : const AssetImage('assets/avatar_placeholder.png') as ImageProvider,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name + ' ' + user.surname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(user.title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text('Aktif', style: TextStyle(fontSize: 12, color: Colors.green)),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                );
              },
              child: const Text('Profili Görüntüle'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.blueGrey),
      title: Text(title, style: TextStyle(color: titleColor ?? Colors.black)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _BottomInfoBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Versiyon 1.2.3', style: TextStyle(fontSize: 12, color: Colors.grey)),
          Row(
            children: [
              Icon(Icons.cloud_done, size: 16, color: Colors.green),
              SizedBox(width: 4),
              Text('Offline Mod Aktif', style: TextStyle(fontSize: 12, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
} 