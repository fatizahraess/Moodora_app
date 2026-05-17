// Provider that owns task state, filters, sorting, errors, and task persistence.
import 'package:flutter/foundation.dart';

import '../database/task_dao.dart';
import '../models/task.dart';

enum TaskStatusFilter { all, active, completed }

enum TaskSortOption { priority, created, dueDate, title }

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskDao? taskDao}) : _taskDao = taskDao ?? TaskDao();

  final TaskDao _taskDao;
  final List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _priorityFilter;
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;
  TaskSortOption _sortOption = TaskSortOption.priority;
  int? _activeUserId;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get priorityFilter => _priorityFilter;
  TaskStatusFilter get statusFilter => _statusFilter;
  TaskSortOption get sortOption => _sortOption;

  List<Task> get activeTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();

  List<Task> get filteredTasks {
    final filtered = _tasks.where((task) {
      final matchesPriority =
          _priorityFilter == null || task.priority == _priorityFilter;
      final matchesStatus = switch (_statusFilter) {
        TaskStatusFilter.all => true,
        TaskStatusFilter.active => !task.isCompleted,
        TaskStatusFilter.completed => task.isCompleted,
      };
      return matchesPriority && matchesStatus;
    }).toList();

    filtered.sort(_compareTasks);
    return filtered;
  }

  Future<void> updateActiveUser(int? userId) async {
    if (_activeUserId == userId && userId != null) {
      return;
    }
    _activeUserId = userId;
    if (userId == null) {
      _tasks.clear();
      notifyListeners();
      return;
    }
    await loadTasks();
  }

  Future<void> loadTasks() async {
    final userId = _activeUserId;
    if (userId == null) {
      return;
    }
    await _runGuarded(() async {
      _setLoading(true);
      final loadedTasks = await _taskDao.getAllTasksByUserId(userId);
      _tasks
        ..clear()
        ..addAll(loadedTasks);
    });
    _setLoading(false);
  }

  Future<void> addTask({
    required String title,
    String description = '',
    String priority = 'medium',
    DateTime? dueDate,
    int estimatedPomodoros = 1,
  }) async {
    final userId = _requireUserId();
    await _runGuarded(() async {
      final now = DateTime.now();
      await _taskDao.insertTask(
        Task(
          userId: userId,
          title: title.trim(),
          description: description.trim(),
          priority: priority,
          createdAt: now,
          updatedAt: now,
          dueDate: dueDate,
          estimatedPomodoros: estimatedPomodoros,
        ),
      );
      await loadTasks();
    });
  }

  Future<void> updateTask(Task task) async {
    await _runGuarded(() async {
      await _taskDao.updateTask(
        task.copyWith(
          userId: _activeUserId ?? task.userId,
          updatedAt: DateTime.now(),
        ),
      );
      await loadTasks();
    });
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final isNowCompleted = !task.isCompleted;
    await updateTask(
      task.copyWith(
        isCompleted: isNowCompleted,
        completedAt: isNowCompleted ? DateTime.now() : null,
        clearCompletedAt: !isNowCompleted,
      ),
    );
  }

  Future<void> deleteTask(int taskId) async {
    await _runGuarded(() async {
      await _taskDao.deleteTask(taskId);
      await loadTasks();
    });
  }

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setStatusFilter(TaskStatusFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setSortOption(TaskSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  int _requireUserId() {
    final userId = _activeUserId;
    if (userId == null) {
      throw StateError('No active local profile.');
    }
    return userId;
  }

  int _compareTasks(Task a, Task b) {
    switch (_sortOption) {
      case TaskSortOption.priority:
        return _priorityWeight(a.priority).compareTo(_priorityWeight(b.priority));
      case TaskSortOption.created:
        return b.createdAt.compareTo(a.createdAt);
      case TaskSortOption.dueDate:
        final aDue = a.dueDate ?? DateTime(9999);
        final bDue = b.dueDate ?? DateTime(9999);
        return aDue.compareTo(bDue);
      case TaskSortOption.title:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
  }

  int _priorityWeight(String priority) {
    return switch (priority) {
      'high' => 0,
      'medium' => 1,
      _ => 2,
    };
  }

  Future<void> _runGuarded(Future<void> Function() action) async {
    try {
      _errorMessage = null;
      await action();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
