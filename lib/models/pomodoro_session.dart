// Data model for a completed Pomodoro timer session owned by a local profile.
class PomodoroSession {
  const PomodoroSession({
    this.id,
    required this.userId,
    this.taskId,
    this.taskTitle,
    required this.duration,
    required this.date,
    required this.type,
  });

  final int? id;
  final int userId;
  final int? taskId;
  final String? taskTitle;
  final int duration;
  final DateTime date;
  final String type;

  bool get isWorkSession => type == 'work';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'taskId': taskId,
      'duration': duration,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory PomodoroSession.fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 1,
      taskId: map['taskId'] as int?,
      taskTitle: map['taskTitle'] as String?,
      duration: map['duration'] as int,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
    );
  }
}
