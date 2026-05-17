// DAO responsible for task persistence and task-related statistics.
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import '../utils/date_formatter.dart';
import 'database_helper.dart';

class TaskDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _database => _databaseHelper.database;

  Future<List<Task>> getAllTasks() => getAllTasksByUserId(1);

  Future<List<Task>> getAllTasksByUserId(int userId) async {
    final db = await _database;
    final rows = await db.rawQuery(_taskSelect('WHERE t.userId = ?'), [userId]);
    return rows.map(Task.fromMap).toList();
  }

  Future<List<Task>> getActiveTasks({int? limit}) =>
      getActiveTasksByUserId(1, limit: limit);

  Future<List<Task>> getActiveTasksByUserId(int userId, {int? limit}) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      ${_taskSelect("WHERE t.userId = ? AND t.isCompleted = 0")}
      ORDER BY
        CASE t.priority WHEN 'high' THEN 0 WHEN 'medium' THEN 1 ELSE 2 END,
        COALESCE(t.dueDate, '9999-12-31') ASC,
        t.createdAt DESC
      ${limit == null ? '' : 'LIMIT $limit'}
    ''', [userId]);
    return rows.map(Task.fromMap).toList();
  }

  Future<List<Task>> getCompletedTasksByUserId(int userId) async {
    final db = await _database;
    final rows = await db.rawQuery(
      '${_taskSelect("WHERE t.userId = ? AND t.isCompleted = 1")} ORDER BY t.completedAt DESC',
      [userId],
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<List<Task>> getLastActiveTasksByUserId(
    int userId, {
    int limit = 3,
  }) {
    return getActiveTasksByUserId(userId, limit: limit);
  }

  Future<Task?> getTaskById(int id) async {
    final db = await _database;
    final rows = await db.rawQuery(
      '${_taskSelect("WHERE t.id = ?")} LIMIT 1',
      [id],
    );
    if (rows.isEmpty) {
      return null;
    }
    return Task.fromMap(rows.first);
  }

  Future<List<Task>> getHighPriorityActiveTasks() async {
    final tasks = await getActiveTasks();
    return tasks.where((task) => task.priority == 'high').toList();
  }

  Future<List<Task>> getHighPriorityActiveTasksByUserId(int userId) async {
    final tasks = await getActiveTasksByUserId(userId);
    return tasks.where((task) => task.priority == 'high').toList();
  }

  Future<List<Task>> getActiveTasksWithoutSessions(
    List<int> taskIdsWithSessions,
  ) async {
    final tasks = await getActiveTasks();
    final ids = taskIdsWithSessions.toSet();
    return tasks.where((task) => task.id != null && !ids.contains(task.id)).toList();
  }

  Future<List<Task>> getActiveTasksWithoutSessionsByUserId(
    int userId,
    List<int> taskIdsWithSessions,
  ) async {
    final tasks = await getActiveTasksByUserId(userId);
    final ids = taskIdsWithSessions.toSet();
    return tasks.where((task) => task.id != null && !ids.contains(task.id)).toList();
  }

  Future<int> insertTask(Task task) async {
    final db = await _database;
    return db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await _database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [task.id, task.userId],
    );
  }

  Future<int> deleteTask(int taskId) async {
    final db = await _database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  Future<int> countCompletedTasksToday() => getCompletedTodayCountByUserId(1);

  Future<int> getCompletedTodayCountByUserId(int userId) async {
    final db = await _database;
    final start = DateFormatter.databaseDay(DateTime.now());
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total FROM tasks
      WHERE userId = ? AND isCompleted = 1 AND completedAt >= ?
      ''',
      [userId, start],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getOverdueTaskCountByUserId(int userId) async {
    final today = DateFormatter.databaseDay(DateTime.now());
    final db = await _database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total FROM tasks
      WHERE userId = ? AND isCompleted = 0 AND dueDate < ?
      ''',
      [userId, today],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<String?> getTopFocusTaskTitle() => getTopFocusTaskTitleByUserId(1);

  Future<String?> getTopFocusTaskTitleByUserId(int userId) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT t.title, SUM(s.duration) AS total
      FROM pomodoro_sessions s
      INNER JOIN tasks t ON t.id = s.taskId
      WHERE s.userId = ? AND s.type = 'work'
      GROUP BY t.id
      ORDER BY total DESC
      LIMIT 1
    ''', [userId]);
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['title'] as String?;
  }

  String _taskSelect(String whereClause) {
    return '''
      SELECT t.*,
        COALESCE((
          SELECT COUNT(*)
          FROM pomodoro_sessions s
          WHERE s.taskId = t.id AND s.userId = t.userId AND s.type = 'work'
        ), 0) AS completedPomodoros
      FROM tasks t
      $whereClause
    ''';
  }
}
