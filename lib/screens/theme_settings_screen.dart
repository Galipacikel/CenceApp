import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    ThemeMode themeMode = appState.appSettings.themeMode;
    return Scaffold(
      appBar: AppBar(title: const Text('Tema Ayarları')),
      body: ListView(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Aydınlık Tema'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (val) {
              if (val != null) appState.setThemeMode(val);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Karanlık Tema'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (val) {
              if (val != null) appState.setThemeMode(val);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Sistem Varsayılanı'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (val) {
              if (val != null) appState.setThemeMode(val);
            },
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tema ayarı kaydedildi!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
} 