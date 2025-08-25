import 'package:flutter/material.dart';

class AppSettings {
  ThemeMode themeMode;
  bool faultNotification;
  bool maintenanceNotification;
  bool stockNotification;

  AppSettings({
    this.themeMode = ThemeMode.light,
    this.faultNotification = true,
    this.maintenanceNotification = true,
    this.stockNotification = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? faultNotification,
    bool? maintenanceNotification,
    bool? stockNotification,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      faultNotification: faultNotification ?? this.faultNotification,
      maintenanceNotification:
          maintenanceNotification ?? this.maintenanceNotification,
      stockNotification: stockNotification ?? this.stockNotification,
    );
  }
}
