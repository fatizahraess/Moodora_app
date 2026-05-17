// DAO responsible for Pomodoro session persistence and time-based statistics.
import 'package:sqflite/sqflite.dart';

import '../models/pomodoro_session.dart';
import '../utils/date_formatter.dart';
import 'database_helper.dart';

class SessionDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _database => _databaseHelper.database;

  Future<int> insertSession(PomodoroSession session) async {
    final db = await _database;
    return db.insert('pomodoro_sessions', session.toMap());
  }

  Future<List<PomodoroSession>> getAllSessionsByUserId(int userId) {
    return getRecentSessionsByUserId(userId, limit: 1000);
  }

  Future<List<PomodoroSession>> getRecentSessions({int limit = 30}) {
    return getRecentSessionsByUserId(1, limit: limit);
  }

  Future<List<PomodoroSession>> getRecentSessionsByUserId(
    int userId, {
    int limit = 30,
  }) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT s.*, t.title AS taskTitle
      FROM pomodoro_sessions s
      LEFT JOIN tasks t ON t.id = s.taskId
      WHERE s.userId = ?
      ORDER BY s.date DESC
      LIMIT ?
    ''', [userId, limit]);
    return rows.map(PomodoroSession.fromMap).toList();
  }

  Future<Map<String, List<PomodoroSession>>> getSessionsGroupedByDate() {
    return getSessionsGroupedByDateByUserId(1);
  }

  Future<Map<String, List<PomodoroSession>>> getSessionsGroupedByDateByUserId(
    int userId,
  ) async {
    final sessions = await getRecentSessionsByUserId(userId, limit: 200);
    final grouped = <String, List<PomodoroSession>>{};
    for (final session in sessions) {
      final key = DateFormatter.databaseDay(session.date);
      grouped.putIfAbsent(key, () => []).add(session);
    }
    return grouped;
  }

  Future<List<PomodoroSession>> getSessionsByDate(DateTime date) {
    return getSessionsByDateAndUserId(date, 1);
  }

  Future<List<PomodoroSession>> getSessionsByDateAndUserId(
    DateTime date,
    int userId,
  ) async {
    final db = await _database;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final rows = await db.rawQuery('''
      SELECT s.*, t.title AS taskTitle
      FROM pomodoro_sessions s
      LEFT JOIN tasks t ON t.id = s.taskId
      WHERE s.userId = ? AND s.date >= ? AND s.date < ?
      ORDER BY s.date DESC
    ''', [userId, start.toIso8601String(), end.toIso8601String()]);
    return rows.map(PomodoroSession.fromMap).toList();
  }

  Future<List<PomodoroSession>> getTodaySessions() => getTodaySessionsByUserId(1);

  Future<List<PomodoroSession>> getTodaySessionsByUserId(int userId) {
    return getSessionsByDateAndUserId(DateTime.now(), userId);
  }

  Future<List<PomodoroSession>> getYesterdaySessions() {
    return getYesterdaySessionsByUserId(1);
  }

  Future<List<PomodoroSession>> getYesterdaySessionsByUserId(int userId) {
    return getSessionsByDateAndUserId(
      DateTime.now().subtract(const Duration(days: 1)),
      userId,
    );
  }

  Future<List<PomodoroSession>> getSessionsByTaskId(int taskId) {
    return getSessionsByTaskIdAndUserId(taskId, 1);
  }

  Future<List<PomodoroSession>> getSessionsByTaskIdAndUserId(
    int taskId,
    int userId,
  ) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT s.*, t.title AS taskTitle
      FROM pomodoro_sessions s
      LEFT JOIN tasks t ON t.id = s.taskId
      WHERE s.taskId = ? AND s.userId = ?
      ORDER BY s.date DESC
    ''', [taskId, userId]);
    return rows.map(PomodoroSession.fromMap).toList();
  }

  Future<int> getTodayPomodoroCount() => getTodayPomodoroCountByUserId(1);

  Future<int> getTodayPomodoroCountByUserId(int userId) {
    return _countWorkSessionsBetween(
      userId,
      _startOfDay(DateTime.now()),
      DateTime.now(),
    );
  }

  Future<int> getTodayFocusMinutes() => getTodayFocusMinutesByUserId(1);

  Future<int> getTodayFocusMinutesByUserId(int userId) {
    return _sumWorkMinutesBetween(
      userId,
      _startOfDay(DateTime.now()),
      DateTime.now(),
    );
  }

  Future<int> getWeeklyFocusMinutes() => getWeeklyFocusMinutesByUserId(1);

  Future<int> getWeeklyFocusMinutesByUserId(int userId) {
    return _sumWorkMinutesBetween(
      userId,
      _startOfWeek(DateTime.now()),
      DateTime.now(),
    );
  }

  Future<int> getWeeklyPomodoroCount() => getWeeklyPomodoroCountByUserId(1);

  Future<int> getWeeklyPomodoroCountByUserId(int userId) {
    return _countWorkSessionsBetween(
      userId,
      _startOfWeek(DateTime.now()),
      DateTime.now(),
    );
  }

  Future<int> getTotalPomodoroCount() => getTotalPomodoroCountByUserId(1);

  Future<int> getTotalPomodoroCountByUserId(int userId) async {
    final db = await _database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) AS total FROM pomodoro_sessions WHERE userId = ? AND type = 'work'",
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<int, int>> getFocusMinutesGroupedByTask() {
    return getFocusMinutesGroupedByTaskByUserId(1);
  }

  Future<Map<int, int>> getFocusMinutesGroupedByTaskByUserId(int userId) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT taskId, SUM(duration) AS total
      FROM pomodoro_sessions
      WHERE userId = ? AND type = 'work' AND taskId IS NOT NULL
      GROUP BY taskId
    ''', [userId]);
    return {
      for (final row in rows) row['taskId'] as int: row['total'] as int? ?? 0,
    };
  }

  Future<Map<int, int>> getPomodoroCountGroupedByTask() {
    return getPomodoroCountGroupedByTaskByUserId(1);
  }

  Future<Map<int, int>> getPomodoroCountGroupedByTaskByUserId(int userId) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT taskId, COUNT(*) AS total
      FROM pomodoro_sessions
      WHERE userId = ? AND type = 'work' AND taskId IS NOT NULL
      GROUP BY taskId
    ''', [userId]);
    return {
      for (final row in rows) row['taskId'] as int: row['total'] as int? ?? 0,
    };
  }

  Future<Map<String, int>> getFocusMinutesGroupedByDateForCurrentWeek() {
    return getFocusMinutesGroupedByDateForCurrentWeekByUserId(1);
  }

  Future<Map<String, int>> getFocusMinutesGroupedByDateForCurrentWeekByUserId(
    int userId,
  ) async {
    final start = _startOfWeek(DateTime.now());
    final days = <String, int>{
      for (var index = 0; index < 7; index++)
        DateFormatter.databaseDay(start.add(Duration(days: index))): 0,
    };
    final db = await _database;
    final end = start.add(const Duration(days: 7));
    final rows = await db.rawQuery(
      '''
      SELECT SUBSTR(date, 1, 10) AS day, SUM(duration) AS total
      FROM pomodoro_sessions
      WHERE userId = ? AND type = 'work' AND date >= ? AND date < ?
      GROUP BY day
      ''',
      [userId, start.toIso8601String(), end.toIso8601String()],
    );
    for (final row in rows) {
      final day = row['day'] as String;
      days[day] = row['total'] as int? ?? 0;
    }
    return days;
  }

  Future<int> getFocusMinutesByDate(DateTime date) {
    return getFocusMinutesByDateAndUserId(date, 1);
  }

  Future<int> getFocusMinutesByDateAndUserId(DateTime date, int userId) async {
    final start = _startOfDay(date);
    final end = start.add(const Duration(days: 1));
    return _sumWorkMinutesBetween(userId, start, end);
  }

  Future<int> getTotalFocusMinutes() => getTotalFocusMinutesByUserId(1);

  Future<int> getTotalFocusMinutesByUserId(int userId) async {
    final db = await _database;
    final result = await db.rawQuery(
      "SELECT SUM(duration) AS total FROM pomodoro_sessions WHERE userId = ? AND type = 'work'",
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCurrentStreak() => getCurrentStreakByUserId(1);

  Future<int> getCurrentStreakByUserId(int userId) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT SUBSTR(date, 1, 10) AS day
      FROM pomodoro_sessions
      WHERE userId = ? AND type = 'work'
      GROUP BY day
      ORDER BY day DESC
    ''', [userId]);
    if (rows.isEmpty) {
      return 0;
    }

    var streak = 0;
    var cursor = _startOfDay(DateTime.now());
    final productiveDays = rows.map((row) => row['day'] as String).toSet();

    while (productiveDays.contains(DateFormatter.databaseDay(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<int> _countWorkSessionsBetween(
    int userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total FROM pomodoro_sessions
      WHERE userId = ? AND type = 'work' AND date >= ? AND date <= ?
      ''',
      [userId, start.toIso8601String(), end.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> _sumWorkMinutesBetween(
    int userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(duration) AS total FROM pomodoro_sessions
      WHERE userId = ? AND type = 'work' AND date >= ? AND date <= ?
      ''',
      [userId, start.toIso8601String(), end.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _startOfWeek(DateTime date) {
    final startOfDay = _startOfDay(date);
    return startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
  }
}
