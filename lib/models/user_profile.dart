// Local user profile stored in SQLite.
class UserProfile {
  const UserProfile({
    this.id,
    required this.name,
    this.email,
    this.avatarEmoji = '🙂',
    this.dailyPomodoroGoal = 4,
    this.preferredWorkDuration = 25,
    required this.createdAt,
    this.isActive = true,
  });

  final int? id;
  final String name;
  final String? email;
  final String avatarEmoji;
  final int dailyPomodoroGoal;
  final int preferredWorkDuration;
  final DateTime createdAt;
  final bool isActive;

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarEmoji,
    int? dailyPomodoroGoal,
    int? preferredWorkDuration,
    DateTime? createdAt,
    bool? isActive,
    bool clearEmail = false,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: clearEmail ? null : email ?? this.email,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      dailyPomodoroGoal: dailyPomodoroGoal ?? this.dailyPomodoroGoal,
      preferredWorkDuration:
          preferredWorkDuration ?? this.preferredWorkDuration,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarEmoji': avatarEmoji,
      'dailyPomodoroGoal': dailyPomodoroGoal,
      'preferredWorkDuration': preferredWorkDuration,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String?,
      avatarEmoji: map['avatarEmoji'] as String? ?? '🙂',
      dailyPomodoroGoal: map['dailyPomodoroGoal'] as int? ?? 4,
      preferredWorkDuration: map['preferredWorkDuration'] as int? ?? 25,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: (map['isActive'] as int? ?? 1) == 1,
    );
  }
}
