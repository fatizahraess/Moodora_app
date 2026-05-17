// Provider for local user profiles and the active profile.
import 'package:flutter/foundation.dart';

import '../database/settings_dao.dart';
import '../database/user_profile_dao.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider({
    UserProfileDao? userProfileDao,
    SettingsDao? settingsDao,
  })  : _userProfileDao = userProfileDao ?? UserProfileDao(),
        _settingsDao = settingsDao ?? SettingsDao();

  final UserProfileDao _userProfileDao;
  final SettingsDao _settingsDao;

  UserProfile? _activeProfile;
  List<UserProfile> _profiles = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get activeProfile => _activeProfile;
  List<UserProfile> get profiles => List.unmodifiable(_profiles);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _profiles.isNotEmpty;
  int? get activeUserId => _activeProfile?.id;

  Future<void> loadProfiles() async {
    await _runGuarded(() async {
      _isLoading = true;
      notifyListeners();
      _profiles = await _userProfileDao.getAllProfiles();
      _activeProfile = await _userProfileDao.getActiveProfile();
      if (_activeProfile == null && _profiles.isNotEmpty) {
        await _userProfileDao.setActiveProfile(_profiles.first.id!);
        _profiles = await _userProfileDao.getAllProfiles();
        _activeProfile = await _userProfileDao.getActiveProfile();
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> loadActiveProfile() async {
    await _runGuarded(() async {
      _activeProfile = await _userProfileDao.getActiveProfile();
      notifyListeners();
    });
  }

  Future<void> createProfile(UserProfile profile) async {
    await _runGuarded(() async {
      final id = await _userProfileDao.insertUserProfile(
        profile.copyWith(isActive: true),
      );
      await _settingsDao.ensureDefaultSettingsForUser(id);
      await _settingsDao.updateSettingsByUserId(
        (await _settingsDao.getSettingsByUserId(id)).copyWith(
          dailyPomodoroGoal: profile.dailyPomodoroGoal,
          workDuration: profile.preferredWorkDuration,
        ),
      );
      await loadProfiles();
    });
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _runGuarded(() async {
      await _userProfileDao.updateUserProfile(profile);
      if (profile.id != null) {
        final settings = await _settingsDao.getSettingsByUserId(profile.id!);
        await _settingsDao.updateSettingsByUserId(
          settings.copyWith(
            dailyPomodoroGoal: profile.dailyPomodoroGoal,
            workDuration: profile.preferredWorkDuration,
          ),
        );
      }
      await loadProfiles();
    });
  }

  Future<void> deleteProfile(int id) async {
    await _runGuarded(() async {
      await _userProfileDao.deleteUserProfile(id);
      final remaining = await _userProfileDao.getAllProfiles();
      if (remaining.isNotEmpty && remaining.every((profile) => !profile.isActive)) {
        await _userProfileDao.setActiveProfile(remaining.first.id!);
      }
      await loadProfiles();
    });
  }

  Future<void> switchProfile(int id) async {
    await _runGuarded(() async {
      await _userProfileDao.setActiveProfile(id);
      await _settingsDao.ensureDefaultSettingsForUser(id);
      await loadProfiles();
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
