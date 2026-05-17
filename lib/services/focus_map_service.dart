// Local analytics service that builds Focus Map distributions, neglected tasks, and insights.
import '../models/focus_map_item.dart';
import '../models/task.dart';
import '../utils/date_formatter.dart';

class FocusMapService {
  List<FocusMapItem> buildFocusByTask({
    required List<Task> tasks,
    required Map<int, int> focusMinutesByTask,
    required Map<int, int> sessionsByTask,
  }) {
    final totalMinutes = focusMinutesByTask.values.fold<int>(
      0,
      (sum, minutes) => sum + minutes,
    );

    final items = tasks
        .where((task) => task.id != null && focusMinutesByTask.containsKey(task.id))
        .map((task) {
      final minutes = focusMinutesByTask[task.id] ?? 0;
      return FocusMapItem(
        taskId: task.id,
        title: task.title,
        category: 'task',
        focusMinutes: minutes,
        sessionCount: sessionsByTask[task.id] ?? 0,
        percentage: totalMinutes == 0 ? 0 : (minutes / totalMinutes) * 100,
        priority: task.priority,
      );
    }).toList()
      ..sort((a, b) => b.focusMinutes.compareTo(a.focusMinutes));

    return items;
  }

  List<FocusMapItem> buildFocusByPriority({
    required List<Task> tasks,
    required Map<int, int> focusMinutesByTask,
  }) {
    final minutesByPriority = <String, int>{'high': 0, 'medium': 0, 'low': 0};
    final sessionsByPriority = <String, int>{'high': 0, 'medium': 0, 'low': 0};

    for (final task in tasks) {
      if (task.id == null) {
        continue;
      }
      final minutes = focusMinutesByTask[task.id] ?? 0;
      minutesByPriority[task.priority] = (minutesByPriority[task.priority] ?? 0) + minutes;
      if (minutes > 0) {
        sessionsByPriority[task.priority] = (sessionsByPriority[task.priority] ?? 0) + 1;
      }
    }

    final totalMinutes = minutesByPriority.values.fold<int>(
      0,
      (sum, minutes) => sum + minutes,
    );

    return ['high', 'medium', 'low'].map((priority) {
      final minutes = minutesByPriority[priority] ?? 0;
      return FocusMapItem(
        title: '${priority[0].toUpperCase()}${priority.substring(1)} priority',
        category: 'priority',
        focusMinutes: minutes,
        sessionCount: sessionsByPriority[priority] ?? 0,
        percentage: totalMinutes == 0 ? 0 : (minutes / totalMinutes) * 100,
        priority: priority,
      );
    }).toList()
      ..sort((a, b) => b.focusMinutes.compareTo(a.focusMinutes));
  }

  List<Task> findNeglectedTasks({
    required List<Task> activeTasks,
    required Map<int, int> sessionsByTask,
  }) {
    return activeTasks.where((task) {
      final hasNoSessions = (sessionsByTask[task.id] ?? 0) == 0;
      if (!hasNoSessions) {
        return false;
      }
      final isImportant = task.priority == 'high' || task.priority == 'medium';
      final isDueSoon = _isDueTodayOrTomorrow(task);
      return isImportant || isDueSoon;
    }).toList();
  }

  List<String> generateFocusMapInsights({
    required List<Task> tasks,
    required List<FocusMapItem> focusByTask,
    required List<FocusMapItem> focusByPriority,
    required Map<String, int> weeklyFocusMinutes,
    required List<Task> neglectedTasks,
  }) {
    final insights = <String>[];

    if (focusByTask.isNotEmpty) {
      final topTask = focusByTask.first;
      insights.add(
        'Your top focus task is ${topTask.title} with ${topTask.focusMinutes} minutes.',
      );
    }

    final highPriorityItems =
        focusByPriority.where((item) => item.priority == 'high').toList();
    final highPriority =
        highPriorityItems.isEmpty ? null : highPriorityItems.first;
    if (highPriority != null) {
      insights.add(
        '${highPriority.percentage.round()}% of your focus time went to high-priority tasks.',
      );
      if (highPriority.percentage < 35 && tasks.any((task) => task.priority == 'high')) {
        insights.add('You focused less on high-priority tasks than expected.');
      }
    }

    final highNeglectedCount =
        neglectedTasks.where((task) => task.priority == 'high').length;
    if (highNeglectedCount > 0) {
      insights.add('You have $highNeglectedCount high-priority neglected tasks.');
    }

    final strongestDay = _strongestFocusDay(weeklyFocusMinutes);
    if (strongestDay != null) {
      insights.add('Your strongest focus day this week was $strongestDay.');
    }

    if (focusByTask.where((item) => item.focusMinutes > 0).length > 5) {
      insights.add('You have focus time spread across too many tasks.');
    }

    if (insights.isEmpty) {
      insights.add('Complete a work session to unlock Focus Map insights.');
    }

    return insights;
  }

  bool _isDueTodayOrTomorrow(Task task) {
    if (task.dueDate == null) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    final difference = dueDay.difference(today).inDays;
    return difference >= 0 && difference <= 1;
  }

  String? _strongestFocusDay(Map<String, int> weeklyFocusMinutes) {
    if (weeklyFocusMinutes.isEmpty || weeklyFocusMinutes.values.every((minutes) => minutes == 0)) {
      return null;
    }

    final entry = weeklyFocusMinutes.entries.reduce(
      (best, current) => current.value > best.value ? current : best,
    );
    return DateFormatter.readableDate(DateTime.parse(entry.key)).split(',').first;
  }
}
