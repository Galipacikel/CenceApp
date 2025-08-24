import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.onCopy,
  });

  IconData _iconForLabel(String label) {
    switch (label) {
      case 'Seri Numarası':
        return Icons.qr_code_2_rounded;
      case 'Model Adı':
        return Icons.devices_rounded;
      case 'Müşteri/Kurum':
        return Icons.business_rounded;
      case 'Kurulum Tarihi':
        return Icons.event_rounded;
      case 'Son Bakım Tarihi':
        return Icons.build_rounded;
      case 'Garanti Bitiş Tarihi':
        return Icons.verified_user_rounded;
      case 'Garantiye Kalan Süre':
        return Icons.timer_rounded;
      case 'Garanti Durumu':
        return Icons.verified_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconForLabel(label);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF23408E).withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF23408E), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF23408E).withAlpha(26),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                onPressed: onCopy,
                icon: const Icon(
                  Icons.copy_rounded,
                  color: Color(0xFF23408E),
                  size: 18,
                ),
                tooltip: 'Kopyala',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
        ],
      ),
    );
  }
}
