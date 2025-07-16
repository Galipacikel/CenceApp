import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik ve Koşullar')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: const [
            Text(
              'Gizlilik Politikası',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Cence uygulaması, kullanıcı verilerinin gizliliğine ve güvenliğine büyük önem verir. Kişisel bilgileriniz, yalnızca uygulamanın işlevselliğini sağlamak ve yasal gereklilikler doğrultusunda kullanılır. Üçüncü şahıslarla paylaşılmaz.',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 24),
            Text(
              'Kullanım Koşulları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Uygulamayı kullanarak, sağlanan bilgilerin doğru ve güncel olduğunu kabul etmiş olursunuz. Uygulamanın izinsiz kullanımı, veri bütünlüğünü bozacak veya güvenliği tehlikeye atacak eylemler yasaktır. Tüm kullanıcılar, şirket politikalarına ve yasal düzenlemelere uymakla yükümlüdür.',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 24),
            Text(
              'Daha fazla bilgi için lütfen yöneticinizle veya destek ekibimizle iletişime geçin.',
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
} 