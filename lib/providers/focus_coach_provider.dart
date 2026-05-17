// Provider that exposes Focus Coach recommendation, focus score, insights, and loading state.
import 'package:flutter/foundation.dart';

import '../database/mood_dao.dart';
import '../models/app_settings.dart';
import '../models/focus_recommendation.dart';
import '../services/focus_coach_service.dart';

class FocusCoachProvider extends ChangeNotifier {
  FocusCoachProvider({
    FocusCoachService? focusCoachService,
    MoodDao? moodDao,
  })  : _focusCoachService = focusCoachService ?? FocusCoachService(),
        _moodDao = moodDao ?? MoodDao();

  final FocusCoachService _focusCoachService;
  final MoodDao _moodDao;
  AppSettings _settings = AppSettings.defaults;
  FocusCoachState _coachState = FocusCoachState.empty();
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  int? _activeUserId;

  FocusCoachState get coachState => _coachState;
  FocusRecommendation? get recommendation => _coachState.recommendation;
  int get focusScore => _coachState.focusScore;
  String get focusScoreLabel => _coachState.focusScoreLabel;
  List<String> get insights => List.unmodifiable(_coachState.insights);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateActiveUser(int? userId) {
    if (_activeUserId == userId) {
      return;
    }
    _activeUserId = userId;
    _hasLoaded = false;
    if (userId == null) {
      _coachState = FocusCoachState.empty();
      notifyListeners();
      return;
    }
    Future.microtask(loadCoach);
  }

  void updateSettings(AppSettings settings) {
    final shouldReload = !_hasLoaded ||
        settings.dailyPomodoroGoal != _settings.dailyPomodoroGoal ||
        settings.workDuration != _settings.workDuration ||
        settings.shortBreakDuration != _settings.shortBreakDuration ||
        settings.longBreakDuration != _settings.longBreakDuration;
    _settings = settings;
    if (shouldReload) {
      Future.microtask(loadCoach);
    }
  }

  Future<void> loadCoach() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      final userId = _activeUserId;
      if (userId == null) {
        return;
      }
      final coachState = await _focusCoachService.buildCoachState(
        _settings,
        userId: userId,
      );
      final moodInsights = await _buildMoodCoachInsights();
      _coachState = FocusCoachState(
        recommendation: coachState.recommendation,
        focusScore: coachState.focusScore,
        focusScoreLabel: coachState.focusScoreLabel,
        insights: [...moodInsights, ...coachState.insights],
        overdueTaskCount: coachState.overdueTaskCount,
        isOverloaded: coachState.isOverloaded,
      );
      _hasLoaded = true;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<List<String>> _buildMoodCoachInsights() async {
    final userId = _activeUserId;
    if (userId == null) {
      return [];
    }
    final todayMoodEntries = await _moodDao.getTodayMoodEntriesByUserId(userId);
    if (todayMoodEntries.isEmpty) {
      return [];
    }

    final averageEnergy = todayMoodEntries
            .fold<int>(0, (sum, entry) => sum + entry.energyLevel) /
        todayMoodEntries.length;
    final averageStress = todayMoodEntries
            .fold<int>(0, (sum, entry) => sum + entry.stressLevel) /
        todayMoodEntries.length;
    final latestMood = todayMoodEntries.first.moodAfter.isNotEmpty
        ? todayMoodEntries.first.moodAfter
        : todayMoodEntries.first.moodBefore;
    final insights = <String>[];

    if (averageStress >= 4) {
      insights.add('Stress is high. Choose a short break before deep work.');
    }
    if (averageEnergy <= 2.5) {
      insights.add('Energy is low. Start with an easier task.');
    }
    if (latestMood == 'motivated') {
      insights.add('Mood is motivated. This is a good moment for a high-priority task.');
    }
    if (latestMood == 'tired' && todayMoodEntries.length >= 3) {
      insights.add('You often feel tired after sessions. Plan a longer break.');
    }

    return insights;
  }
}
