// DAO responsible for Focus Mood persistence and mood aggregate queries.
import 'package:sqflite/sqflite.dart';

import '../models/mood_entry.dart';
import 'database_helper.dart';

class MoodDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _database => _databaseHelper.database;

  Future<int> insertMoodEntry(MoodEntry moodEntry) async {
    final db = await _database;
    return db.insert('mood_entries', moodEntry.toMap());
  }

  Future<List<MoodEntry>> getAllMoodEntries() => getAllMoodEntriesByUserId(1);

  Future<List<MoodEntry>> getAllMoodEntriesByUserId(int userId) async {
    final db = await _database;
    final rows = await db.query(
      'mood_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return rows.map(MoodEntry.fromMap).toList();
  }

  Future<List<MoodEntry>> getTodayMoodEntries() {
    return getTodayMoodEntriesByUserId(1);
  }

  Future<List<MoodEntry>> getTodayMoodEntriesByUserId(int userId) {
    return getMoodEntriesByDateAndUserId(DateTime.now(), userId);
  }

  Future<List<MoodEntry>> getMoodEntriesByDate(DateTime date) {
    return getMoodEntriesByDateAndUserId(date, 1);
  }

  Future<List<MoodEntry>> getMoodEntriesByDateAndUserId(
    DateTime date,
    int userId,
  ) async {
    final db = await _database;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final rows = await db.query(
      'mood_entries',
      where: 'userId = ? AND date >= ? AND date < ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return rows.map(MoodEntry.fromMap).toList();
  }

  Future<List<MoodEntry>> getMoodEntriesByTaskId(int taskId) {
    return getMoodEntriesByTaskIdAndUserId(taskId, 1);
  }

  Future<List<MoodEntry>> getMoodEntriesByTaskIdAndUserId(
    int taskId,
    int userId,
  ) async {
    final db = await _database;
    final rows = await db.query(
      'mood_entries',
      where: 'taskId = ? AND userId = ?',
      whereArgs: [taskId, userId],
      orderBy: 'date DESC',
    );
    return rows.map(MoodEntry.fromMap).toList();
  }

  Future<MoodEntry?> getMoodEntryBySessionId(int sessionId) {
    return getMoodEntryBySessionIdAndUserId(sessionId, 1);
  }

  Future<MoodEntry?> getMoodEntryBySessionIdAndUserId(
    int sessionId,
    int userId,
  ) async {
    final db = await _database;
    final rows = await db.query(
      'mood_entries',
      where: 'sessionId = ? AND userId = ?',
      whereArgs: [sessionId, userId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return MoodEntry.fromMap(rows.first);
  }

  Future<int> updateMoodEntry(MoodEntry moodEntry) async {
    final db = await _database;
    return db.update(
      'mood_entries',
      moodEntry.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [moodEntry.id, moodEntry.userId],
    );
  }

  Future<int> deleteMoodEntry(int id) async {
    final db = await _database;
    return db.delete('mood_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getMoodFrequency() => getMoodFrequencyByUserId(1);

  Future<Map<String, int>> getMoodFrequencyByUserId(int userId) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT mood, COUNT(*) AS total
      FROM (
        SELECT moodBefore AS mood FROM mood_entries
        WHERE userId = ? AND moodBefore != ''
        UNION ALL
        SELECT moodAfter AS mood FROM mood_entries
        WHERE userId = ? AND moodAfter != ''
      )
      GROUP BY mood
    ''', [userId, userId]);
    return {
      for (final row in rows) row['mood'] as String: row['total'] as int? ?? 0,
    };
  }

  Future<double> getAverageEnergyLevel() => getAverageEnergyLevelByUserId(1);

  Future<double> getAverageEnergyLevelByUserId(int userId) async {
    final db = await _database;
    final rows = await db.rawQuery(
      'SELECT AVG(energyLevel) AS value FROM mood_entries WHERE userId = ?',
      [userId],
    );
    return (rows.first['value'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getAverageStressLevel() => getAverageStressLevelByUserId(1);

  Future<double> getAverageStressLevelByUserId(int userId) async {
    final db = await _database;
    final rows = await db.rawQuery(
      'SELECT AVG(stressLevel) AS value FROM mood_entries WHERE userId = ?',
      [userId],
    );
    return (rows.first['value'] as num?)?.toDouble() ?? 0;
  }

  Future<String?> getMostProductiveMood() => getMostProductiveMoodByUserId(1);

  Future<String?> getMostProductiveMoodByUserId(int userId) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT mood, COUNT(*) AS total
      FROM (
        SELECT COALESCE(NULLIF(m.moodBefore, ''), NULLIF(m.moodAfter, '')) AS mood
        FROM mood_entries m
        INNER JOIN pomodoro_sessions s ON s.id = m.sessionId
        WHERE m.userId = ? AND s.userId = ? AND s.type = 'work'
      )
      WHERE mood IS NOT NULL
      GROUP BY mood
      ORDER BY total DESC
      LIMIT 1
    ''', [userId, userId]);
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['mood'] as String?;
  }
}
