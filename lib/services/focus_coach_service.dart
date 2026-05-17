// Local recommendation engine that scores tasks and generates Focus Coach insights.
import '../database/session_dao.dart';
import '../database/task_dao.dart';
import '../models/app_settings.dart';
import '../models/focus_recommendation.dart';
import '../models/pomodoro_session.dart';
import '../models/task.dart';

class FocusCoachService {
  FocusCoachService({
    TaskDao? taskDao,
    SessionDao? sessionDao,
  })  : _taskDao = taskDao ?? TaskDao(),
        _sessionDao = sessionDao ?? SessionDao();

  final TaskDao _taskDao;
  final SessionDao _sessionDao;

  Future<FocusCoachState> buildCoachState(
    AppSettings settings, {
    int? userId,
  }) async {
    final activeUserId = userId ?? settings.userId;
    final activeTasks = await _taskDao.getActiveTasksByUserId(activeUserId);
    final todaySessions = await _sessionDao.getTodaySessionsByUserId(activeUserId);
    final yesterdaySessions =
        await _sessionDao.getYesterdaySessionsByUserId(activeUserId);
    final todayPomodoroCount =
        await _sessionDao.getTodayPomodoroCountByUserId(activeUserId);
    final todayFocusMinutes =
        await _sessionDao.getTodayFocusMinutesByUserId(activeUserId);
    final completedTasksToday =
        await _taskDao.getCompletedTodayCountByUserId(activeUserId);
    final currentStreak = await _sessionDao.getCurrentStreakByUserId(activeUserId);
    final topFocusTaskTitle =
        await _taskDao.getTopFocusTaskTitleByUserId(activeUserId);

    final recommendation = _buildRecommendation(activeTasks);
    final overdueTaskCount = activeTasks.where((task) => task.isOverdue).length;
    final plannedPomodoros = activeTasks.fold<int>(
      0,
      (sum, task) => sum + task.estimatedPomodoros,
    );
    final isOverloaded = plannedPomodoros > settings.dailyPomodoroGoal * 2;
    final focusScore = _calculateFocusScore(
      todayPomodoroCount: todayPomodoroCount,
      dailyGoal: settings.dailyPomodoroGoal,
      todayFocusMinutes: todayFocusMinutes,
      workDuration: settings.workDuration,
      completedTasksToday: completedTasksToday,
      currentStreak: currentStreak,
    );
    final insights = _buildInsights(
      settings: settings,
      todayPomodoroCount: todayPomodoroCount,
      todayFocusMinutes: todayFocusMinutes,
      todaySessions: todaySessions,
      yesterdaySessions: yesterdaySessions,
      overdueTaskCount: overdueTaskCount,
      topFocusTaskTitle: topFocusTaskTitle,
      isOverloaded: isOverloaded,
    );

    return FocusCoachState(
      recommendation: recommendation,
      focusScore: focusScore,
      focusScoreLabel: _scoreLabel(focusScore),
      insights: insights,
      overdueTaskCount: overdueTaskCount,
      isOverloaded: isOverloaded,
    );
  }

  FocusRecommendation? _buildRecommendation(List<Task> tasks) {
    if (tasks.isEmpty) {
      return null;
    }

    final scoredTasks = tasks.map(_scoreTask).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scoredTasks.first;
  }

  FocusRecommendation _scoreTask(Task task) {
    final priorityScore = switch (task.priority) {
      'high' => 40,
      'medium' => 25,
      _ => 10,
    };
    final deadlineScore = _deadlineScore(task);
    final progressScore = _progressScore(task);
    final estimationScore = task.estimatedPomodoros <= 2 ? 10 : 0;
    final score = priorityScore + deadlineScore + progressScore + estimationScore;
    final reasons = <String>[
      '${task.priority} priority',
      _deadlineReason(task),
      _progressReason(task),
    ]..removeWhere((reason) => reason.isEmpty);
    final remainingPomodoros =
        task.estimatedPomodoros - task.completedPomodoros;

    return FocusRecommendation(
      task: task,
      score: score,
      reason: reasons.join(', '),
      suggestedPomodoros: remainingPomodoros.clamp(1, 3).toInt(),
    );
  }

  int _deadlineScore(Task task) {
    if (task.dueDate == null) {
      return 0;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    final daysUntilDue = dueDay.difference(today).inDays;

    if (daysUntilDue < 0) {
      return 50;
    }
    if (daysUntilDue == 0) {
      return 30;
    }
    if (daysUntilDue == 1) {
      return 20;
    }
    if (daysUntilDue <= 7) {
      return 10;
    }
    return 0;
  }

  String _deadlineReason(Task task) {
    if (task.dueDate == null) {
      return '';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    final daysUntilDue = dueDay.difference(today).inDays;

    if (daysUntilDue < 0) {
      return 'overdue';
    }
    if (daysUntilDue == 0) {
      return 'due today';
    }
    if (daysUntilDue == 1) {
      return 'due tomorrow';
    }
    if (daysUntilDue <= 7) {
      return 'due this week';
    }
    return '';
  }

  int _progressScore(Task task) {
    if (task.completedPomodoros == 0) {
      return 10;
    }
    if (task.pomodoroProgress >= 0.75) {
      return 15;
    }
    return 20;
  }

  String _progressReason(Task task) {
    if (task.completedPomodoros == 0) {
      return 'not started yet';
    }
    if (task.pomodoroProgress >= 0.75) {
      return '${task.completedPomodoros}/${task.estimatedPomodoros} Pomodoros completed and almost done';
    }
    return '${task.completedPomodoros}/${task.estimatedPomodoros} Pomodoros completed';
  }

  int _calculateFocusScore({
    required int todayPomodoroCount,
    required int dailyGoal,
    required int todayFocusMinutes,
    required int workDuration,
    required int completedTasksToday,
    required int currentStreak,
  }) {
    final safeGoal = dailyGoal <= 0 ? 1 : dailyGoal;
    final safeWorkDuration = workDuration <= 0 ? 25 : workDuration;
    final goalPoints = ((todayPomodoroCount / safeGoal) * 40).clamp(0, 40);
    final minuteTarget = safeGoal * safeWorkDuration;
    final minutePoints = ((todayFocusMinutes / minuteTarget) * 25).clamp(0, 25);
    final taskPoints = (completedTasksToday * 10).clamp(0, 20);
    final streakPoints = (currentStreak * 3).clamp(0, 15);

    return (goalPoints + minutePoints + taskPoints + streakPoints)
        .round()
        .clamp(0, 100)
        .toInt();
  }

  List<String> _buildInsights({
    required AppSettings settings,
    required int todayPomodoroCount,
    required int todayFocusMinutes,
    required List<PomodoroSession> todaySessions,
    required List<PomodoroSession> yesterdaySessions,
    required int overdueTaskCount,
    required String? topFocusTaskTitle,
    required bool isOverloaded,
  }) {
    final insights = <String>[
      'You completed $todayPomodoroCount focus sessions today.',
    ];

    final goalProgress = settings.dailyPomodoroGoal == 0
        ? 0
        : ((todayPomodoroCount / settings.dailyPomodoroGoal) * 100).round();
    insights.add('You reached $goalProgress% of your daily goal.');

    if (overdueTaskCount > 0) {
      insights.add('You have $overdueTaskCount overdue tasks.');
    }

    if (topFocusTaskTitle != null) {
      insights.add('Your most focused task is: $topFocusTaskTitle.');
    }

    final yesterdayMinutes = yesterdaySessions
        .where((session) => session.isWorkSession)
        .fold<int>(0, (sum, session) => sum + session.duration);
    if (todayFocusMinutes > yesterdayMinutes && todayFocusMinutes > 0) {
      insights.add('You focused more than yesterday.');
    }

    final workSessionsToday =
        todaySessions.where((session) => session.isWorkSession).length;
    if (workSessionsToday > 0 && workSessionsToday % 4 == 3) {
      insights.add('Take a long break after your next session.');
    }

    if (isOverloaded) {
      insights.add(
        'You planned too many Pomodoros today. Consider reducing your workload.',
      );
    }

    return insights;
  }

  String _scoreLabel(int score) {
    if (score >= 80) {
      return 'Great progress today';
    }
    if (score >= 55) {
      return 'Solid momentum';
    }
    if (score >= 30) {
      return 'A focused session will help';
    }
    return 'Start gently and build momentum';
  }
}
