import 'package:flutter/material.dart';

  class DeviceSelectionSection extends StatelessWidget {
  final TextEditingController serialNumberController;
  final TextEditingController deviceNameController;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final int formTipi; // 0: Kurulum, 1: Bakım, 2: Arıza

      const DeviceSelectionSection({
    super.key,
    required this.serialNumberController,
    required this.deviceNameController,
    required this.brandController,
    required this.modelController,
    required this.formTipi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cihaz Bilgileri',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 16),

        // Form tipine göre bilgilendirme mesajı
        if (formTipi == 0) ...[ // Kurulum
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0E2FF)),
            ),
            child: const Text(
              'Kurulum formu: Mevcut cihaz seçmeden aşağıdaki alanları doldurun.',
              style: TextStyle(fontSize: 12, color: Color(0xFF23408E)),
            ),
          ),
        ] else if (formTipi == 1) ...[ // Bakım
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: const Text(
              'Bakım formu: Mevcut cihaz seçmeden aşağıdaki alanları doldurun.',
              style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
            ),
          ),
        ] else if (formTipi == 2) ...[ // Arıza
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: const Text(
              'Arıza formu: Mevcut cihaz seçmeden aşağıdaki alanları doldurun.',
              style: TextStyle(fontSize: 12, color: Color(0xFFD32F2F)),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Seri No
        const Text(
          'Seri No',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: serialNumberController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Cihaz seri numarasını girin',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Cihaz Adı
        const Text(
          'Cihaz Adı',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: deviceNameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Cihaz adını girin',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Marka
        const Text(
          'Marka',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: brandController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Cihaz markasını girin',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Model
        const Text(
          'Model',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: modelController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Cihaz modelini girin',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
