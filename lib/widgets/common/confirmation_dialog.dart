import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color iconColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Sil',
    this.cancelText = 'İptal',
    this.icon = Icons.warning_amber_rounded,
    this.iconColor = AppColors.criticalRed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.montserrat()),
        ],
      ),
      content: Text(message, style: GoogleFonts.montserrat()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText, style: GoogleFonts.montserrat()),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.criticalRed,
          ),
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.delete),
          label: Text(confirmText, style: GoogleFonts.montserrat()),
        ),
      ],
    );
  }
}
