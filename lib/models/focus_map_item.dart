// Data model for visual Focus Map distribution items by task, priority, or category.
class FocusMapItem {
  const FocusMapItem({
    this.taskId,
    required this.title,
    required this.category,
    required this.focusMinutes,
    required this.sessionCount,
    required this.percentage,
    required this.priority,
  });

  final int? taskId;
  final String title;
  final String category;
  final int focusMinutes;
  final int sessionCount;
  final double percentage;
  final String priority;

  FocusMapItem copyWith({
    int? taskId,
    String? title,
    String? category,
    int? focusMinutes,
    int? sessionCount,
    double? percentage,
    String? priority,
  }) {
    return FocusMapItem(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      category: category ?? this.category,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      sessionCount: sessionCount ?? this.sessionCount,
      percentage: percentage ?? this.percentage,
      priority: priority ?? this.priority,
    );
  }
}
