import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uygulama Bilgisi')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cence Teknik Servis Uygulaması', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: const [
                Text('Sürüm: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('1.2.3'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Text('Geliştirici: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Cence Yazılım'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Text('İletişim: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('destek@cence.com'),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Bu uygulama, teknik servis süreçlerini kolaylaştırmak ve hızlandırmak amacıyla geliştirilmiştir. Tüm hakları saklıdır.',
              style: TextStyle(fontSize: 15),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Güncelleme kontrolü (şimdilik simülasyon)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Uygulamanız güncel!')),
                  );
                },
                icon: const Icon(Icons.system_update_alt),
                label: const Text('Güncellemeleri Kontrol Et'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 