// Provider that centralizes all dashboard, history, and productivity statistics.
import 'package:flutter/foundation.dart';

import '../database/session_dao.dart';
import '../database/task_dao.dart';

class StatsProvider extends ChangeNotifier {
  StatsProvider({
    TaskDao? taskDao,
    SessionDao? sessionDao,
  })  : _taskDao = taskDao ?? TaskDao(),
        _sessionDao = sessionDao ?? SessionDao();

  final TaskDao _taskDao;
  final SessionDao _sessionDao;

  bool _isLoading = false;
  String? _errorMessage;
  int? _activeUserId;
  int _completedTasksToday = 0;
  int _todayPomodoroCount = 0;
  int _todayFocusMinutes = 0;
  int _weeklyPomodoroCount = 0;
  int _weeklyFocusMinutes = 0;
  int _totalPomodoroCount = 0;
  int _currentStreak = 0;
  String? _topFocusTaskTitle;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get completedTasksToday => _completedTasksToday;
  int get todayPomodoroCount => _todayPomodoroCount;
  int get todayFocusMinutes => _todayFocusMinutes;
  int get weeklyPomodoroCount => _weeklyPomodoroCount;
  int get weeklyFocusMinutes => _weeklyFocusMinutes;
  int get totalPomodoroCount => _totalPomodoroCount;
  int get currentStreak => _currentStreak;
  String? get topFocusTaskTitle => _topFocusTaskTitle;

  Future<void> updateActiveUser(int? userId) async {
    if (_activeUserId == userId && userId != null) {
      return;
    }
    _activeUserId = userId;
    if (userId == null) {
      _reset();
      notifyListeners();
      return;
    }
    await loadStats();
  }

  Future<void> loadStats() async {
    final userId = _activeUserId;
    if (userId == null) {
      return;
    }
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final results = await Future.wait<Object?>([
        _taskDao.getCompletedTodayCountByUserId(userId),
        _sessionDao.getTodayPomodoroCountByUserId(userId),
        _sessionDao.getTodayFocusMinutesByUserId(userId),
        _sessionDao.getWeeklyPomodoroCountByUserId(userId),
        _sessionDao.getWeeklyFocusMinutesByUserId(userId),
        _sessionDao.getTotalPomodoroCountByUserId(userId),
        _sessionDao.getCurrentStreakByUserId(userId),
        _taskDao.getTopFocusTaskTitleByUserId(userId),
      ]);

      _completedTasksToday = results[0] as int;
      _todayPomodoroCount = results[1] as int;
      _todayFocusMinutes = results[2] as int;
      _weeklyPomodoroCount = results[3] as int;
      _weeklyFocusMinutes = results[4] as int;
      _totalPomodoroCount = results[5] as int;
      _currentStreak = results[6] as int;
      _topFocusTaskTitle = results[7] as String?;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _reset() {
    _completedTasksToday = 0;
    _todayPomodoroCount = 0;
    _todayFocusMinutes = 0;
    _weeklyPomodoroCount = 0;
    _weeklyFocusMinutes = 0;
    _totalPomodoroCount = 0;
    _currentStreak = 0;
    _topFocusTaskTitle = null;
  }
}
