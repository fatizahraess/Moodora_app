// Provider that owns app settings, theme preference, and SQLite persistence.
import 'package:flutter/material.dart';

import '../database/settings_dao.dart';
import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({SettingsDao? settingsDao})
      : _settingsDao = settingsDao ?? SettingsDao();

  final SettingsDao _settingsDao;
  AppSettings _settings = AppSettings.defaults;
  bool _isLoading = false;
  String? _errorMessage;
  int? _activeUserId;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ThemeMode get materialThemeMode {
    return switch (_settings.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> updateActiveUser(int? userId) async {
    if (_activeUserId == userId && userId != null) {
      return;
    }
    _activeUserId = userId;
    if (userId == null) {
      _settings = AppSettings.defaults;
      notifyListeners();
      return;
    }
    await loadSettings();
  }

  Future<void> loadSettings() async {
    final userId = _activeUserId;
    if (userId == null) {
      return;
    }
    await _runGuarded(() async {
      _isLoading = true;
      notifyListeners();
      _settings = await _settingsDao.getSettingsByUserId(userId);
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateSettings(AppSettings settings) async {
    final userId = _activeUserId;
    if (userId == null) {
      return;
    }
    await _runGuarded(() async {
      _settings = settings.copyWith(userId: userId);
      await _settingsDao.updateSettingsByUserId(_settings);
      notifyListeners();
    });
  }

  Future<void> resetSettings() async {
    final userId = _activeUserId;
    if (userId == null) {
      return;
    }
    await _runGuarded(() async {
      _settings = await _settingsDao.resetSettingsByUserId(userId);
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _runGuarded(Future<void> Function() action) async {
    try {
      _errorMessage = null;
      await action();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }
}
