// Provider that loads Focus Map analytics from DAOs and exposes UI-ready state.
import 'package:flutter/foundation.dart';

import '../database/session_dao.dart';
import '../database/task_dao.dart';
import '../models/focus_map_item.dart';
import '../models/task.dart';
import '../services/focus_map_service.dart';

class FocusMapProvider extends ChangeNotifier {
  FocusMapProvider({
    TaskDao? taskDao,
    SessionDao? sessionDao,
    FocusMapService? focusMapService,
  })  : _taskDao = taskDao ?? TaskDao(),
        _sessionDao = sessionDao ?? SessionDao(),
        _focusMapService = focusMapService ?? FocusMapService();

  final TaskDao _taskDao;
  final SessionDao _sessionDao;
  final FocusMapService _focusMapService;

  List<FocusMapItem> _focusByTask = [];
  List<FocusMapItem> _focusByPriority = [];
  Map<String, int> _weeklyFocusMinutes = {};
  List<Task> _neglectedTasks = [];
  List<String> _insights = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _activeUserId;

  List<FocusMapItem> get focusByTask => List.unmodifiable(_focusByTask);
  List<FocusMapItem> get focusByPriority => List.unmodifiable(_focusByPriority);
  Map<String, int> get weeklyFocusMinutes => Map.unmodifiable(_weeklyFocusMinutes);
  List<Task> get neglectedTasks => List.unmodifiable(_neglectedTasks);
  List<String> get insights => List.unmodifiable(_insights);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get weeklyTotalFocusMinutes {
    return _weeklyFocusMinutes.values.fold<int>(0, (sum, minutes) => sum + minutes);
  }

  Future<void> updateActiveUser(int? userId) async {
    if (_activeUserId == userId && userId != null) {
      return;
    }
    _activeUserId = userId;
    if (userId == null) {
      _focusByTask = [];
      _focusByPriority = [];
      _weeklyFocusMinutes = {};
      _neglectedTasks = [];
      _insights = [];
      notifyListeners();
      return;
    }
    await loadFocusMap();
  }

  Future<void> loadFocusMap() async {
    final userId = _activeUserId;
    if (userId == null) {
      return;
    }
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final tasks = await _taskDao.getAllTasksByUserId(userId);
      final activeTasks = tasks.where((task) => !task.isCompleted).toList();
      final focusMinutesByTask =
          await _sessionDao.getFocusMinutesGroupedByTaskByUserId(userId);
      final sessionsByTask =
          await _sessionDao.getPomodoroCountGroupedByTaskByUserId(userId);

      _focusByTask = _focusMapService.buildFocusByTask(
        tasks: tasks,
        focusMinutesByTask: focusMinutesByTask,
        sessionsByTask: sessionsByTask,
      );
      _focusByPriority = _focusMapService.buildFocusByPriority(
        tasks: tasks,
        focusMinutesByTask: focusMinutesByTask,
      );
      _weeklyFocusMinutes =
          await _sessionDao.getFocusMinutesGroupedByDateForCurrentWeekByUserId(
        userId,
      );
      _neglectedTasks = _focusMapService.findNeglectedTasks(
        activeTasks: activeTasks,
        sessionsByTask: sessionsByTask,
      );
      _insights = _focusMapService.generateFocusMapInsights(
        tasks: tasks,
        focusByTask: _focusByTask,
        focusByPriority: _focusByPriority,
        weeklyFocusMinutes: _weeklyFocusMinutes,
        neglectedTasks: _neglectedTasks,
      );
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
}
