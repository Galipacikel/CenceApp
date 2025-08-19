import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan renk sabitlerini tanımlar
class AppColors {
  // Ana renkler
  static const Color primaryBlue = Color(0xFF23408E);
  static const Color primaryColor = Color(0xFF23408E);
  static const Color criticalRed = Color(0xFFE53935);
  
  // Metin renkleri
  static const Color textColor = Color(0xFF232946);
  static const Color subtitleColor = Color(0xFF4A4A4A);
  
  // Arka plan renkleri
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color disabledColor = Color(0xFFF5F5F5);
  
  // Border renkleri
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color errorColor = Color(0xFFE53935);
  
  // Kritik durumlar için renkler
  static const Color criticalBackground = Color(0xFFFFCDD2);
  static const Color criticalText = Color(0xFFD32F2F);
  
  // Yardımcı renkler
  static const Color iconColor = Color(0xFFB0B3C0);
  
  // Özel kullanımlar
  static Color primaryBlueWithOpacity(double opacity) => primaryBlue.withOpacity(opacity);
  static Color criticalRedWithOpacity(double opacity) => criticalRed.withOpacity(opacity);
  static Color criticalTextWithOpacity(double opacity) => criticalText.withOpacity(opacity);
}