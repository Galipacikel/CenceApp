import 'package:flutter/material.dart';

class CustomerInfoSection extends StatelessWidget {
  final TextEditingController companyController;
  final TextEditingController locationController;

  const CustomerInfoSection({
    super.key,
    required this.companyController,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Müşteri/Kurum Bilgileri',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),

        // Firma
        const Text(
          'Firma',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: companyController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Firma adını girin',
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

        // Lokasyon
        const Text(
          'Lokasyon',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: locationController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Lokasyon bilgisini girin',
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
