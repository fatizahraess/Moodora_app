// Provider that manages Focus Mood entries, summaries, insights, and errors.
import 'package:flutter/foundation.dart';

import '../database/mood_dao.dart';
import '../models/mood_entry.dart';
import '../services/mood_insight_service.dart';

class MoodProvider extends ChangeNotifier {
  MoodProvider({
    MoodDao? moodDao,
    MoodInsightService? moodInsightService,
  })  : _moodDao = moodDao ?? MoodDao(),
        _moodInsightService = moodInsightService ?? MoodInsightService();

  final MoodDao _moodDao;
  final MoodInsightService _moodInsightService;

  List<MoodEntry> _moodEntries = [];
  List<MoodEntry> _todayMoodEntries = [];
  List<String> _insights = [];
  String? _dominantMood;
  double _averageEnergy = 0;
  double _averageStress = 0;
  int _moodScore = 0;
  bool _isLoading = false;
  String? _errorMessage;
  int _lastTodayFocusMinutes = 0;
  int _lastTodayPomodoroCount = 0;
  int? _activeUserId;

  List<MoodEntry> get moodEntries => List.unmodifiable(_moodEntries);
  List<MoodEntry> get todayMoodEntries => List.unmodifiable(_todayMoodEntries);
  List<String> get insights => List.unmodifiable(_insights);
  String? get dominantMood => _dominantMood;
  double get averageEnergy => _averageEnergy;
  double get averageStress => _averageStress;
  int get moodScore => _moodScore;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> updateActiveUser(int? userId) async {
    if (_activeUserId == userId && userId != null) {
      return;
    }
    _activeUserId = userId;
    if (userId == null) {
      _moodEntries = [];
      _todayMoodEntries = [];
      _insights = [];
      _dominantMood = null;
      _averageEnergy = 0;
      _averageStress = 0;
      _moodScore = 0;
      notifyListeners();
      return;
    }
    await loadMoodData(
      todayFocusMinutes: _lastTodayFocusMinutes,
      todayPomodoroCount: _lastTodayPomodoroCount,
    );
  }

  Future<void> loadMoodData({
    required int todayFocusMinutes,
    required int todayPomodoroCount,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _lastTodayFocusMinutes = todayFocusMinutes;
      _lastTodayPomodoroCount = todayPomodoroCount;
      notifyListeners();

      final userId = _activeUserId;
      if (userId == null) {
        return;
      }
      _moodEntries = await _moodDao.getAllMoodEntriesByUserId(userId);
      _todayMoodEntries = await _moodDao.getTodayMoodEntriesByUserId(userId);
      final summaryEntries = _todayMoodEntries.isEmpty ? _moodEntries : _todayMoodEntries;
      _dominantMood = summaryEntries.isEmpty
          ? null
          : _moodInsightService.getDominantMood(summaryEntries);
      _averageEnergy = _moodInsightService.getAverageEnergy(summaryEntries);
      _averageStress = _moodInsightService.getAverageStress(summaryEntries);
      _moodScore = _moodInsightService.calculateMoodScore(entries: summaryEntries);
      _insights = _moodInsightService.generateMoodInsights(
        moodEntries: _moodEntries,
        todayFocusMinutes: todayFocusMinutes,
        todayPomodoroCount: todayPomodoroCount,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMoodEntry(MoodEntry moodEntry) async {
    final userId = _requireUserId();
    await _runMutation(
      () => _moodDao.insertMoodEntry(moodEntry.copyWith(userId: userId)),
    );
  }

  Future<void> updateMoodEntry(MoodEntry moodEntry) async {
    await _runMutation(() => _moodDao.updateMoodEntry(moodEntry));
  }

  Future<void> deleteMoodEntry(int id) async {
    await _runMutation(() => _moodDao.deleteMoodEntry(id));
  }

  Future<MoodEntry?> getMoodBySessionId(int sessionId) {
    final userId = _activeUserId;
    if (userId == null) {
      return Future.value(null);
    }
    return _moodDao.getMoodEntryBySessionIdAndUserId(sessionId, userId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _runMutation(Future<Object?> Function() action) async {
    try {
      _errorMessage = null;
      await action();
      await loadMoodData(
        todayFocusMinutes: _lastTodayFocusMinutes,
        todayPomodoroCount: _lastTodayPomodoroCount,
      );
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  int _requireUserId() {
    final userId = _activeUserId;
    if (userId == null) {
      throw StateError('No active local profile.');
    }
    return userId;
  }
}
