// Data model for a task with priority, due date, Pomodoro estimation, and owner profile.
class Task {
  const Task({
    this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = 'medium',
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.dueDate,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
  });

  final int? id;
  final int userId;
  final String title;
  final String description;
  final bool isCompleted;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final int estimatedPomodoros;
  final int completedPomodoros;

  bool get isOverdue {
    if (dueDate == null || isCompleted) {
      return false;
    }
    final today = DateTime.now();
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final currentDay = DateTime(today.year, today.month, today.day);
    return dueDay.isBefore(currentDay);
  }

  double get pomodoroProgress {
    if (estimatedPomodoros <= 0) {
      return 0;
    }
    return (completedPomodoros / estimatedPomodoros).clamp(0, 1).toDouble();
  }

  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    bool? isCompleted,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? dueDate,
    int? estimatedPomodoros,
    int? completedPomodoros,
    bool clearCompletedAt = false,
    bool clearDueDate = false,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'estimatedPomodoros': estimatedPomodoros,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 1,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      priority: map['priority'] as String? ?? 'medium',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.parse(map['completedAt'] as String),
      dueDate: map['dueDate'] == null
          ? null
          : DateTime.parse(map['dueDate'] as String),
      estimatedPomodoros: map['estimatedPomodoros'] as int? ?? 1,
      completedPomodoros: map['completedPomodoros'] as int? ?? 0,
    );
  }
}
