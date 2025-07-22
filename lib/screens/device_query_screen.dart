import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'barcode_scanner_screen.dart';

class CihazSorgulaScreen extends StatefulWidget {
  const CihazSorgulaScreen({Key? key}) : super(key: key);

  @override
  State<CihazSorgulaScreen> createState() => _CihazSorgulaScreenState();
}

class _CihazSorgulaScreenState extends State<CihazSorgulaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Cihaz Sorgula',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Arama kutusu
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Barkod veya Seri Numarası',
                prefixIcon: const Icon(Icons.qr_code_2_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Kamerayla Tara butonu
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    if (context.mounted) {
                      final result = await Navigator.of(context).push<String>(
                        MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                      );
                      if (result != null && result.isNotEmpty) {
                        _searchController.text = result;
                      }
                    }
                  } else if (status.isDenied || status.isPermanentlyDenied) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Kamera İzni Gerekli'),
                          content: const Text('Kamerayı kullanabilmek için izin vermelisiniz.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Tamam'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Kamerayla Tara'),
              ),
            ),
            const SizedBox(height: 22),
            // Arama Sonucu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.devices_other_rounded, color: Color(0xFF23408E), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Cihaz Adı: ABC Medikal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      SizedBox(height: 2),
                      Text('Model: XYZ123', style: TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            // Cihaz Detayları
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cihaz Detayları',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'Seri Numarası', value: 'SN123456'),
                  _DetailRow(label: 'Müşteri Bilgileri', value: 'Sağlık Kliniği'),
                  _DetailRow(label: 'Kurulum Tarihi', value: '15.01.2023'),
                  Row(
                    children: const [
                      Expanded(child: Text('Garanti Durumu', style: TextStyle(color: Colors.black54, fontSize: 15))),
                      _WarrantyBadge(text: 'Devam Ediyor'),
                    ],
                  ),
                  _DetailRow(label: 'Son Bakım Tarihi', value: '15.01.2024'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 15))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}

class _WarrantyBadge extends StatelessWidget {
  final String text;
  const _WarrantyBadge({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF43A047).withOpacity(0.13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF43A047),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
} 