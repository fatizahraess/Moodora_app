// Data model for a local mood entry linked to a profile, session, and optional task.
class MoodEntry {
  const MoodEntry({
    this.id,
    required this.userId,
    this.sessionId,
    this.taskId,
    this.moodBefore = '',
    this.moodAfter = '',
    required this.energyLevel,
    required this.stressLevel,
    required this.date,
    this.note,
  });

  final int? id;
  final int userId;
  final int? sessionId;
  final int? taskId;
  final String moodBefore;
  final String moodAfter;
  final int energyLevel;
  final int stressLevel;
  final DateTime date;
  final String? note;

  MoodEntry copyWith({
    int? id,
    int? userId,
    int? sessionId,
    int? taskId,
    String? moodBefore,
    String? moodAfter,
    int? energyLevel,
    int? stressLevel,
    DateTime? date,
    String? note,
    bool clearSessionId = false,
    bool clearTaskId = false,
    bool clearNote = false,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: clearSessionId ? null : sessionId ?? this.sessionId,
      taskId: clearTaskId ? null : taskId ?? this.taskId,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      energyLevel: (energyLevel ?? this.energyLevel).clamp(1, 5),
      stressLevel: (stressLevel ?? this.stressLevel).clamp(1, 5),
      date: date ?? this.date,
      note: clearNote ? null : note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'taskId': taskId,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'energyLevel': energyLevel.clamp(1, 5),
      'stressLevel': stressLevel.clamp(1, 5),
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 1,
      sessionId: map['sessionId'] as int?,
      taskId: map['taskId'] as int?,
      moodBefore: map['moodBefore'] as String? ?? '',
      moodAfter: map['moodAfter'] as String? ?? '',
      energyLevel: (map['energyLevel'] as int? ?? 3).clamp(1, 5),
      stressLevel: (map['stressLevel'] as int? ?? 3).clamp(1, 5),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }
}
