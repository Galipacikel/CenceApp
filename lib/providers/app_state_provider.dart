import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AppStateProvider extends ChangeNotifier {
  UserProfile? _userProfile; // null olabilir şimdi
  AppSettings _appSettings = AppSettings();
  AppUser? _currentUser; // real auth user
  final AuthService _authService = AuthService();

  UserProfile? get userProfile => _userProfile;
  AppSettings get appSettings => _appSettings;
  AppUser? get currentUser => _currentUser;

  // Auth durumunu başlat
  Future<void> initAuth() async {
    _currentUser = await _authService.getCurrentUserProfile();
    
    // AppUser varsa UserProfile'a dönüştür
    if (_currentUser != null) {
      _userProfile = UserProfile(
        id: _currentUser!.uid,
        name: _currentUser!.fullName?.split(' ').first ?? '',
        surname: _currentUser!.fullName?.split(' ').skip(1).join(' ') ?? '',
        title: _currentUser!.isAdmin ? 'Admin' : 'Teknisyen',
        email: _currentUser!.email,
        phone: null,
        department: 'Teknik Servis',
        profileImagePath: null,
      );
    }
    notifyListeners();
  }

  void updateCurrentUser(AppUser? user) {
    _currentUser = user;
    
    if (user != null) {
      _userProfile = UserProfile(
        id: user.uid,
        name: user.fullName?.split(' ').first ?? '',
        surname: user.fullName?.split(' ').skip(1).join(' ') ?? '',
        title: user.isAdmin ? 'Admin' : 'Teknisyen',
        email: user.email,
        phone: null,
        department: 'Teknik Servis',
        profileImagePath: null,
      );
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

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
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(profileImagePath: path);
      notifyListeners();
    }
  }

  void setName(String name) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(name: name);
      notifyListeners();
    }
  }

  void setSurname(String surname) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(surname: surname);
      notifyListeners();
    }
  }

  void setTitle(String title) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(title: title);
      notifyListeners();
    }
  }
}