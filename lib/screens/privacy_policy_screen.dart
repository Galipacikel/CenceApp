import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF23408E);
    final Color background = const Color(0xFFF7F9FC);
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF232946);
    final Color subtitleColor = const Color(0xFF4A4A4A);
    final double cardRadius = 18;
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Gizlilik ve Koşullar',
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
                    Row(
                      children: [
                        Icon(Icons.privacy_tip_outlined, color: primaryBlue, size: 28),
                        const SizedBox(width: 12),
                        Text('Gizlilik Politikası', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cence uygulaması, kullanıcı verilerinin gizliliğine ve güvenliğine büyük önem verir. Kişisel bilgileriniz, yalnızca uygulamanın işlevselliğini sağlamak ve yasal gereklilikler doğrultusunda kullanılır. Üçüncü şahıslarla paylaşılmaz.',
                      style: GoogleFonts.montserrat(fontSize: 15, color: subtitleColor),
                    ),
                    const SizedBox(height: 24),
                    Text('Kullanım Koşulları', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                    const SizedBox(height: 12),
                    Text(
                      'Uygulamayı kullanarak, sağlanan bilgilerin doğru ve güncel olduğunu kabul etmiş olursunuz. Uygulamanın izinsiz kullanımı, veri bütünlüğünü bozacak veya güvenliği tehlikeye atacak eylemler yasaktır. Tüm kullanıcılar, şirket politikalarına ve yasal düzenlemelere uymakla yükümlüdür.',
                      style: GoogleFonts.montserrat(fontSize: 15, color: subtitleColor),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Daha fazla bilgi için lütfen yöneticinizle veya destek ekibimizle iletişime geçin.',
                      style: GoogleFonts.montserrat(fontSize: 15, fontStyle: FontStyle.italic, color: subtitleColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 