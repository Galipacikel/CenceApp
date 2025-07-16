import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';

class AppStateProvider extends ChangeNotifier {
  UserProfile _userProfile = UserProfile(
    name: 'Mehmet',
    surname: 'Yılmaz',
    title: 'Teknik Servis Sorumlusu',
    profileImagePath: null,
  );
  AppSettings _appSettings = AppSettings();

  UserProfile get userProfile => _userProfile;
  AppSettings get appSettings => _appSettings;

  void updateUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void updateAppSettings(AppSettings settings) {
    _appSettings = settings;
    notifyListeners();
  }

  // Tek tek alan güncelleyiciler (örnek)
  void setThemeMode(ThemeMode mode) {
    _appSettings = _appSettings.copyWith(themeMode: mode);
    notifyListeners();
  }

  void setFaultNotification(bool value) {
    _appSettings = _appSettings.copyWith(faultNotification: value);
    notifyListeners();
  }

  void setMaintenanceNotification(bool value) {
    _appSettings = _appSettings.copyWith(maintenanceNotification: value);
    notifyListeners();
  }

  void setStockNotification(bool value) {
    _appSettings = _appSettings.copyWith(stockNotification: value);
    notifyListeners();
  }

  void setProfileImagePath(String? path) {
    _userProfile = _userProfile.copyWith(profileImagePath: path);
    notifyListeners();
  }

  void setName(String name) {
    _userProfile = _userProfile.copyWith(name: name);
    notifyListeners();
  }

  void setSurname(String surname) {
    _userProfile = _userProfile.copyWith(surname: surname);
    notifyListeners();
  }

  void setTitle(String title) {
    _userProfile = _userProfile.copyWith(title: title);
    notifyListeners();
  }
} 