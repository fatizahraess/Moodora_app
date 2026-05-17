// Data models returned by Focus Coach for recommendation, score, and insights.
import 'task.dart';

class FocusRecommendation {
  const FocusRecommendation({
    required this.task,
    required this.score,
    required this.reason,
    required this.suggestedPomodoros,
  });

  final Task task;
  final int score;
  final String reason;
  final int suggestedPomodoros;
}

class FocusCoachState {
  const FocusCoachState({
    this.recommendation,
    required this.focusScore,
    required this.focusScoreLabel,
    required this.insights,
    required this.overdueTaskCount,
    required this.isOverloaded,
  });

  final FocusRecommendation? recommendation;
  final int focusScore;
  final String focusScoreLabel;
  final List<String> insights;
  final int overdueTaskCount;
  final bool isOverloaded;

  factory FocusCoachState.empty() {
    return const FocusCoachState(
      recommendation: null,
      focusScore: 0,
      focusScoreLabel: 'Start your first focus session',
      insights: ['Create or select an active task to receive a recommendation.'],
      overdueTaskCount: 0,
      isOverloaded: false,
    );
  }
}
