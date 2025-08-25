import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cence_app/models/app_user.dart';
import 'package:cence_app/services/firestore_paths.dart';
import 'package:cence_app/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase bağımlılık sağlayıcıları (DI)
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// FirebaseAuth provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Auth state changes stream
final authUserChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// AppUser provider (Firestore'dan kullanıcı profilini getirir)
final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final user = await ref.watch(authUserChangesProvider.future);
  if (user == null) return null;
  final firestore = ref.watch(firebaseFirestoreProvider);
  final doc = await firestore
      .collection(FirestorePaths.users)
      .doc(user.uid)
      .get();
  if (!doc.exists) return null;
  final data = doc.data() ?? {};
  return AppUser.fromFirestore(data, doc.id);
});

// Admin kontrolü için provider
final isAdminProvider = Provider<bool>((ref) {
  final asyncUser = ref.watch(appUserProvider);
  return asyncUser.maybeWhen(
    data: (u) => u?.isAdmin ?? false,
    orElse: () => false,
  );
});

// Uygulama Ayarları (Tema ve Bildirimler) için StateNotifier
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(AppSettings()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    final fault = prefs.getBool('fault_notification') ?? true;
    final maintenance = prefs.getBool('maintenance_notification') ?? true;
    final stock = prefs.getBool('stock_notification') ?? false;
    state = AppSettings(
      themeMode: ThemeMode.values[themeModeIndex],
      faultNotification: fault,
      maintenanceNotification: maintenance,
      stockNotification: stock,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> setFaultNotification(bool value) async {
    state = state.copyWith(faultNotification: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fault_notification', value);
  }

  Future<void> setMaintenanceNotification(bool value) async {
    state = state.copyWith(maintenanceNotification: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('maintenance_notification', value);
  }

  Future<void> setStockNotification(bool value) async {
    state = state.copyWith(stockNotification: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stock_notification', value);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
      return AppSettingsNotifier();
    });
