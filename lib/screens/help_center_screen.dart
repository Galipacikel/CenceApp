import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF23408E);
    final Color background = const Color(0xFFF7F9FC);
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF232946);
    final Color subtitleColor = const Color(0xFF4A4A4A);
    final double cardRadius = 18;
    final isWide = MediaQuery.of(context).size.width > 600;
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
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Yardım Merkezi',
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
          constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            itemCount: faqs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(cardRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(cardRadius),
                  onTap: () {},
                  splashColor: primaryBlue.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline, color: primaryBlue, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                faq['question']!,
                                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: textColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          faq['answer']!,
                          style: GoogleFonts.montserrat(fontSize: 15, color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 