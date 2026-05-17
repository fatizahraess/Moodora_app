// Local service that generates Focus Mood insights and mood scores.
import '../models/mood_entry.dart';

class MoodInsightService {
  List<String> generateMoodInsights({
    required List<MoodEntry> moodEntries,
    required int todayFocusMinutes,
    required int todayPomodoroCount,
  }) {
    if (moodEntries.isEmpty) {
      return ['Track your mood after a session to discover productivity patterns.'];
    }

    final todayEntries = moodEntries.where((entry) {
      final now = DateTime.now();
      return entry.date.year == now.year &&
          entry.date.month == now.month &&
          entry.date.day == now.day;
    }).toList();
    final dominantMood = getDominantMood(moodEntries);
    final averageEnergy = getAverageEnergy(todayEntries.isEmpty ? moodEntries : todayEntries);
    final averageStress = getAverageStress(todayEntries.isEmpty ? moodEntries : todayEntries);
    final improvedCount = moodEntries.where(hasMoodImproved).length;
    final insights = <String>[
      'Your most common mood is $dominantMood.',
      'Your average energy level today is ${averageEnergy.toStringAsFixed(1)}/5.',
    ];

    if (averageStress >= 4) {
      insights.add('Stress is high today. Consider taking a longer break.');
    }
    if (averageEnergy <= 2.5) {
      insights.add('Low energy detected. Start with an easy task.');
    }
    if (improvedCount > 0) {
      insights.add('You usually feel better after focus sessions.');
    }
    if (todayPomodoroCount > 0) {
      insights.add('You completed $todayPomodoroCount sessions with $todayFocusMinutes focus minutes today.');
    }
    if (dominantMood == 'calm') {
      insights.add('You completed more sessions when your mood was calm.');
    }
    if (dominantMood == 'motivated') {
      insights.add('Motivation is high. Tackle a high-priority task next.');
    }

    return insights;
  }

  String getDominantMood(List<MoodEntry> entries) {
    final counts = <String, int>{};
    for (final entry in entries) {
      for (final mood in [entry.moodBefore, entry.moodAfter]) {
        if (mood.isNotEmpty) {
          counts[mood] = (counts[mood] ?? 0) + 1;
        }
      }
    }
    if (counts.isEmpty) {
      return 'neutral';
    }
    return counts.entries.reduce((best, item) => item.value > best.value ? item : best).key;
  }

  double getAverageEnergy(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }
    return entries.fold<int>(0, (sum, entry) => sum + entry.energyLevel) / entries.length;
  }

  double getAverageStress(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }
    return entries.fold<int>(0, (sum, entry) => sum + entry.stressLevel) / entries.length;
  }

  bool hasMoodImproved(MoodEntry entry) {
    if (entry.moodBefore.isEmpty || entry.moodAfter.isEmpty) {
      return false;
    }
    return _moodRank(entry.moodAfter) > _moodRank(entry.moodBefore);
  }

  int calculateMoodScore({required List<MoodEntry> entries}) {
    if (entries.isEmpty) {
      return 0;
    }
    final energyPoints = (getAverageEnergy(entries) / 5 * 30).clamp(0, 30);
    final stressPoints = ((5 - getAverageStress(entries)) / 4 * 25).clamp(0, 25);
    final improvedRatio = entries.where(hasMoodImproved).length / entries.length;
    final improvementPoints = (improvedRatio * 25).clamp(0, 25);
    final dominantMood = getDominantMood(entries);
    final positiveMoodPoints =
        ['motivated', 'calm', 'happy'].contains(dominantMood) ? 20 : 8;

    return (energyPoints + stressPoints + improvementPoints + positiveMoodPoints)
        .round()
        .clamp(0, 100)
        .toInt();
  }

  int _moodRank(String mood) {
    return switch (mood) {
      'frustrated' => 0,
      'stressed' => 1,
      'tired' => 2,
      'neutral' => 3,
      'calm' => 4,
      'happy' => 5,
      'motivated' => 6,
      _ => 3,
    };
  }
}
