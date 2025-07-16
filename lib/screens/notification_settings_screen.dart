import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final settings = appState.appSettings;
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirim Ayarları')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Yeni Arıza Kaydı Bildirimi'),
            subtitle: const Text('Yeni bir arıza kaydı oluşturulduğunda bildirim al'),
            value: settings.faultNotification,
            onChanged: (val) => appState.setFaultNotification(val),
          ),
          SwitchListTile(
            title: const Text('Yaklaşan Bakım Bildirimi'),
            subtitle: const Text('Bakım zamanı yaklaşan cihazlar için bildirim al'),
            value: settings.maintenanceNotification,
            onChanged: (val) => appState.setMaintenanceNotification(val),
          ),
          SwitchListTile(
            title: const Text('Parça Stoğu Azalması Bildirimi'),
            subtitle: const Text('Stokta azalan parça olduğunda bildirim al'),
            value: settings.stockNotification,
            onChanged: (val) => appState.setStockNotification(val),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bildirim ayarları kaydedildi!')),
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