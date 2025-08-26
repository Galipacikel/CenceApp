import 'package:flutter/material.dart';

class EmptyServiceCard extends StatelessWidget {
  const EmptyServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8ECF4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF23408E).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Basit saat ikonu
          const Icon(
            Icons.history,
            size: 48,
            color: Color(0xFF6F7489),
          ),
          const SizedBox(height: 16),
          
          // Ana başlık
          const Text(
            'Henüz Servis Kaydı Yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Açıklama metni
          const Text(
            'İlk servis kaydınızı oluşturmak için\nYeni Servis Formu\'nu kullanın',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6F7489),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Dekoratif elementler
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDecorElement(Icons.check_circle_outline, 'Kurulum'),
              const SizedBox(width: 20),
              _buildDecorElement(Icons.build_outlined, 'Bakım'),
              const SizedBox(width: 20),
              _buildDecorElement(Icons.warning_amber_outlined, 'Arıza'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecorElement(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF23408E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF23408E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6F7489),
          ),
        ),
      ],
    );
  }
}