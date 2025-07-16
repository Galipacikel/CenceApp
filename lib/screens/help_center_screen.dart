import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'Cence uygulamasına nasıl giriş yapabilirim?',
        'answer': 'Kullanıcı adınız ve şifrenizle giriş yapabilirsiniz. Şifrenizi unuttuysanız yöneticinizle iletişime geçin.'
      },
      {
        'question': 'Offline mod nedir?',
        'answer': 'İnternet bağlantınız olmadığında da uygulamayı kullanabilir, verileriniz tekrar bağlantı sağlandığında otomatik olarak senkronize edilir.'
      },
      {
        'question': 'Bildirimleri nasıl açıp kapatabilirim?',
        'answer': 'Ayarlar > Bildirimler menüsünden istediğiniz bildirim türünü açıp kapatabilirsiniz.'
      },
      {
        'question': 'Profil bilgilerimi nasıl güncellerim?',
        'answer': 'Ayarlar > Profili Görüntüle/Düzenle menüsünden profil bilgilerinizi güncelleyebilirsiniz.'
      },
      {
        'question': 'Destek talebi nasıl oluşturabilirim?',
        'answer': 'Ayarlar > Destek Talebi / İletişim menüsünden yeni bir destek talebi oluşturabilirsiniz.'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Yardım Merkezi / SSS')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return ExpansionTile(
            title: Text(faq['question']!),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(faq['answer']!),
              ),
            ],
          );
        },
      ),
    );
  }
} 