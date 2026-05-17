// Provider that owns timer state, session persistence, and completion flow.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../database/session_dao.dart';
import '../models/app_settings.dart';
import '../models/pomodoro_session.dart';
import '../services/notification_service.dart';

enum PomodoroMode { work, shortBreak, longBreak }

extension PomodoroModeDetails on PomodoroMode {
  String get label {
    return switch (this) {
      PomodoroMode.work => 'Work',
      PomodoroMode.shortBreak => 'Short Break',
      PomodoroMode.longBreak => 'Long Break',
    };
  }

  String get sessionType {
    return switch (this) {
      PomodoroMode.work => 'work',
      PomodoroMode.shortBreak => 'shortBreak',
      PomodoroMode.longBreak => 'longBreak',
    };
  }
}

class PomodoroProvider extends ChangeNotifier {
  PomodoroProvider({
    SessionDao? sessionDao,
    NotificationService? notificationService,
  })  : _sessionDao = sessionDao ?? SessionDao(),
        _notificationService = notificationService ?? NotificationService();

  final SessionDao _sessionDao;
  final NotificationService _notificationService;
  Future<void> Function()? onSessionCompleted;

  Timer? _timer;
  AppSettings _settings = AppSettings.defaults;
  PomodoroMode _mode = PomodoroMode.work;
  int _remainingSeconds = AppSettings.defaults.workDuration * 60;
  int _totalSeconds = AppSettings.defaults.workDuration * 60;
  int? _activeUserId;
  int _sessionCount = 0;
  int? _selectedTaskId;
  int? _lastCompletedSessionId;
  int? _lastSelectedTaskId;
  bool _isRunning = false;
  bool _isLoading = false;
  String? _errorMessage;

  PomodoroMode get mode => _mode;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  int get sessionCount => _sessionCount;
  int? get selectedTaskId => _selectedTaskId;
  int? get lastCompletedSessionId => _lastCompletedSessionId;
  int? get lastSelectedTaskId => _lastSelectedTaskId;
  bool get isRunning => _isRunning;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateActiveUser(int? userId) {
    if (_activeUserId == userId) {
      return;
    }
    _activeUserId = userId;
    _selectedTaskId = null;
    _sessionCount = 0;
    reset();
  }

  double get progress {
    if (_totalSeconds == 0) {
      return 0;
    }
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  String get nextSessionLabel {
    if (_mode != PomodoroMode.work) {
      return PomodoroMode.work.label;
    }
    return (_sessionCount + 1) % 4 == 0
        ? PomodoroMode.longBreak.label
        : PomodoroMode.shortBreak.label;
  }

  void updateSettings(AppSettings settings) {
    final durationsChanged =
        settings.workDuration != _settings.workDuration ||
            settings.shortBreakDuration != _settings.shortBreakDuration ||
            settings.longBreakDuration != _settings.longBreakDuration;
    _settings = settings;
    if (!_isRunning && durationsChanged) {
      _applyModeDuration(_mode);
    }
  }

  void selectTask(int? taskId) {
    _selectedTaskId = taskId;
    notifyListeners();
  }

  void setMode(PomodoroMode mode) {
    _timer?.cancel();
    _isRunning = false;
    _mode = mode;
    _applyModeDuration(mode);
    notifyListeners();
  }

  void startOrPause() {
    if (_isRunning) {
      pause();
    } else {
      start();
    }
  }

  void start() {
    if (_isRunning) {
      return;
    }
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        completeCurrentSession();
        return;
      }
      _remainingSeconds--;
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _applyModeDuration(_mode);
    notifyListeners();
  }

  Future<void> skip() async {
    await completeCurrentSession(saveSession: false);
  }

  Future<int?> completeCurrentSession({bool saveSession = true}) async {
    if (_isLoading) {
      return null;
    }

    _timer?.cancel();
    _isRunning = false;
    _remainingSeconds = 0;
    _isLoading = true;
    notifyListeners();

    try {
      if (saveSession) {
        _lastSelectedTaskId = _selectedTaskId;
        final userId = _activeUserId;
        if (userId == null) {
          throw StateError('No active local profile.');
        }
        _lastCompletedSessionId = await _sessionDao.insertSession(
          PomodoroSession(
            userId: userId,
            taskId: _selectedTaskId,
            duration: _durationForMode(_mode),
            date: DateTime.now(),
            type: _mode.sessionType,
          ),
        );
        if (_mode == PomodoroMode.work) {
          _sessionCount++;
        }
      } else {
        _lastCompletedSessionId = null;
        _lastSelectedTaskId = _selectedTaskId;
      }

      await _notificationService.showTimerCompleted(
        title: 'Moodora',
        body: '${_mode.label} session completed.',
        enabled: _settings.notificationsEnabled,
      );

      await onSessionCompleted?.call();

      _mode = _nextMode();
      _applyModeDuration(_mode);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _lastCompletedSessionId;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  PomodoroMode _nextMode() {
    if (_mode != PomodoroMode.work) {
      return PomodoroMode.work;
    }
    return _sessionCount % 4 == 0 ? PomodoroMode.longBreak : PomodoroMode.shortBreak;
  }

  void _applyModeDuration(PomodoroMode mode) {
    _totalSeconds = _durationForMode(mode) * 60;
    _remainingSeconds = _totalSeconds;
  }

  int _durationForMode(PomodoroMode mode) {
    return switch (mode) {
      PomodoroMode.work => _settings.workDuration,
      PomodoroMode.shortBreak => _settings.shortBreakDuration,
      PomodoroMode.longBreak => _settings.longBreakDuration,
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
