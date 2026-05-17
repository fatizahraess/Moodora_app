// Singleton SQLite helper that creates, upgrades, and exposes the local database.
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static const String databaseName = 'focusflow.db';
  static const int databaseVersion = 4;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final fullPath = join(databasePath, databaseName);
    _database = await openDatabase(
      fullPath,
      version: databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await _migrateToUserProfiles(db);
      return;
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE user_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        avatarEmoji TEXT NOT NULL,
        dailyPomodoroGoal INTEGER NOT NULL,
        preferredWorkDuration INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        priority TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        completedAt TEXT,
        dueDate TEXT,
        estimatedPomodoros INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(userId) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pomodoro_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        taskId INTEGER,
        duration INTEGER NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES user_profiles(id) ON DELETE CASCADE,
        FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL UNIQUE,
        dailyPomodoroGoal INTEGER NOT NULL,
        workDuration INTEGER NOT NULL,
        shortBreakDuration INTEGER NOT NULL,
        longBreakDuration INTEGER NOT NULL,
        notificationsEnabled INTEGER NOT NULL,
        themeMode TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE mood_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        sessionId INTEGER,
        taskId INTEGER,
        moodBefore TEXT,
        moodAfter TEXT,
        energyLevel INTEGER NOT NULL,
        stressLevel INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY(userId) REFERENCES user_profiles(id) ON DELETE CASCADE,
        FOREIGN KEY(sessionId) REFERENCES pomodoro_sessions(id) ON DELETE SET NULL,
        FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _migrateToUserProfiles(Database db) async {
    await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS user_profiles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT,
          avatarEmoji TEXT NOT NULL,
          dailyPomodoroGoal INTEGER NOT NULL,
          preferredWorkDuration INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          isActive INTEGER NOT NULL
        )
      ''');

      final profiles = await txn.query('user_profiles', limit: 1);
      var defaultUserId = 1;
      if (profiles.isEmpty) {
        defaultUserId = await txn.insert('user_profiles', {
          'name': 'Local User',
          'email': null,
          'avatarEmoji': '🙂',
          'dailyPomodoroGoal': 4,
          'preferredWorkDuration': 25,
          'createdAt': now,
          'isActive': 1,
        });
      } else {
        defaultUserId = profiles.first['id'] as int? ?? 1;
      }

      await _migrateTasks(txn, defaultUserId);
      await _migrateSessions(txn, defaultUserId);
      await _migrateSettings(txn, defaultUserId);
      await _migrateMoodEntries(txn, defaultUserId);
    });
  }

  Future<void> _migrateTasks(Transaction txn, int userId) async {
    await txn.execute('ALTER TABLE tasks RENAME TO tasks_old');
    await txn.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        priority TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        completedAt TEXT,
        dueDate TEXT,
        estimatedPomodoros INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(userId) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');
    await txn.rawInsert('''
      INSERT INTO tasks (
        id, userId, title, description, isCompleted, priority, createdAt,
        updatedAt, completedAt, dueDate, estimatedPomodoros
      )
      SELECT id, ?, title, description, isCompleted, priority, createdAt,
        updatedAt, completedAt, dueDate, estimatedPomodoros
      FROM tasks_old
    ''', [userId]);
    await txn.execute('DROP TABLE tasks_old');
  }

  Future<void> _migrateSessions(Transaction txn, int userId) async {
    await txn.execute(
      'ALTER TABLE pomodoro_sessions RENAME TO pomodoro_sessions_old',
    );
    await txn.execute('''
      CREATE TABLE pomodoro_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        taskId INTEGER,
        duration INTEGER NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES user_profiles(id) ON DELETE CASCADE,
        FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE SET NULL
      )
    ''');
    await txn.rawInsert('''
      INSERT INTO pomodoro_sessions (id, userId, taskId, duration, date, type)
      SELECT id, ?, taskId, duration, date, type
      FROM pomodoro_sessions_old
    ''', [userId]);
    await txn.execute('DROP TABLE pomodoro_sessions_old');
  }

  Future<void> _migrateSettings(Transaction txn, int userId) async {
    await txn.execute('ALTER TABLE settings RENAME TO settings_old');
    await txn.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL UNIQUE,
        dailyPomodoroGoal INTEGER NOT NULL,
        workDuration INTEGER NOT NULL,
        shortBreakDuration INTEGER NOT NULL,
        longBreakDuration INTEGER NOT NULL,
        notificationsEnabled INTEGER NOT NULL,
        themeMode TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');
    final rows = await txn.query('settings_old', limit: 1);
    if (rows.isEmpty) {
      await txn.insert('settings', _defaultSettings(userId));
    } else {
      final row = rows.first;
      await txn.insert('settings', {
        'userId': userId,
        'dailyPomodoroGoal': row['dailyPomodoroGoal'] as int? ?? 4,
        'workDuration': row['workDuration'] as int? ?? 25,
        'shortBreakDuration': row['shortBreakDuration'] as int? ?? 5,
        'longBreakDuration': row['longBreakDuration'] as int? ?? 15,
        'notificationsEnabled': row['notificationsEnabled'] as int? ?? 1,
        'themeMode': row['themeMode'] as String? ?? 'system',
      });
    }
    await txn.execute('DROP TABLE settings_old');
  }

  Future<void> _migrateMoodEntries(Transaction txn, int userId) async {
    final tableExists = await txn.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='mood_entries'",
    );
    if (tableExists.isEmpty) {
      await txn.execute('''
        CREATE TABLE mood_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          sessionId INTEGER,
          taskId INTEGER,
          moodBefore TEXT,
          moodAfter TEXT,
          energyLevel INTEGER NOT NULL,
          stressLevel INTEGER NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          FOREIGN KEY(userId) REFERENCES user_profiles(id) ON DELETE CASCADE,
          FOREIGN KEY(sessionId) REFERENCES pomodoro_sessions(id) ON DELETE SET NULL,
          FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE SET NULL
        )
      ''');
      return;
    }

    await txn.execute('ALTER TABLE mood_entries RENAME TO mood_entries_old');
    await txn.execute('''
      CREATE TABLE mood_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        sessionId INTEGER,
        taskId INTEGER,
        moodBefore TEXT,
        moodAfter TEXT,
        energyLevel INTEGER NOT NULL,
        stressLevel INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY(userId) REFERENCES user_profiles(id) ON DELETE CASCADE,
        FOREIGN KEY(sessionId) REFERENCES pomodoro_sessions(id) ON DELETE SET NULL,
        FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE SET NULL
      )
    ''');
    await txn.rawInsert('''
      INSERT INTO mood_entries (
        id, userId, sessionId, taskId, moodBefore, moodAfter, energyLevel,
        stressLevel, date, note
      )
      SELECT id, ?, sessionId, taskId, moodBefore, moodAfter, energyLevel,
        stressLevel, date, note
      FROM mood_entries_old
    ''', [userId]);
    await txn.execute('DROP TABLE mood_entries_old');
  }

  Map<String, Object?> _defaultSettings(int userId) {
    return {
      'userId': userId,
      'dailyPomodoroGoal': 4,
      'workDuration': 25,
      'shortBreakDuration': 5,
      'longBreakDuration': 15,
      'notificationsEnabled': 1,
      'themeMode': 'system',
    };
  }
}
