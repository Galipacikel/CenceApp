import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF1E88E5),
        secondary: const Color(0xFF1565C0),
      ),
      textTheme: base.textTheme,
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF90CAF9),
        secondary: const Color(0xFF64B5F6),
      ),
      textTheme: base.textTheme,
    );
  }
}