// Data model for local application settings stored per profile in SQLite.
class AppSettings {
  const AppSettings({
    this.id,
    required this.userId,
    this.dailyPomodoroGoal = 4,
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.notificationsEnabled = true,
    this.themeMode = 'system',
  });

  final int? id;
  final int userId;
  final int dailyPomodoroGoal;
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final bool notificationsEnabled;
  final String themeMode;

  static const defaults = AppSettings(userId: 1);

  AppSettings copyWith({
    int? id,
    int? userId,
    int? dailyPomodoroGoal,
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    bool? notificationsEnabled,
    String? themeMode,
  }) {
    return AppSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dailyPomodoroGoal: dailyPomodoroGoal ?? this.dailyPomodoroGoal,
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'dailyPomodoroGoal': dailyPomodoroGoal,
      'workDuration': workDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'themeMode': themeMode,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 1,
      dailyPomodoroGoal: map['dailyPomodoroGoal'] as int? ?? 4,
      workDuration: map['workDuration'] as int? ?? 25,
      shortBreakDuration: map['shortBreakDuration'] as int? ?? 5,
      longBreakDuration: map['longBreakDuration'] as int? ?? 15,
      notificationsEnabled: (map['notificationsEnabled'] as int? ?? 1) == 1,
      themeMode: map['themeMode'] as String? ?? 'system',
    );
  }
}
