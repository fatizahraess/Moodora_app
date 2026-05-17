// Premium card that displays one Focus Mood history entry and optional task context.
import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import 'common_glass_card.dart';
import 'mood_selector.dart';

class MoodHistoryCard extends StatelessWidget {
  const MoodHistoryCard({
    super.key,
    required this.moodEntry,
    this.taskTitle,
  });

  final MoodEntry moodEntry;
  final String? taskTitle;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.textWhite;
    final secondaryTextColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightTextMuted
        : AppColors.textSecondary;
    return CommonGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormatter.fullDate(moodEntry.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Text(
                DateFormatter.time(moodEntry.date),
                style: TextStyle(color: secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (moodEntry.moodBefore.isNotEmpty)
                _MoodPill(label: 'Before', mood: moodEntry.moodBefore),
              if (moodEntry.moodAfter.isNotEmpty)
                _MoodPill(label: 'After', mood: moodEntry.moodAfter),
              _MetricPill(label: 'Energy', value: '${moodEntry.energyLevel}/5'),
              _MetricPill(label: 'Stress', value: '${moodEntry.stressLevel}/5'),
            ],
          ),
          if (taskTitle != null) ...[
            const SizedBox(height: 10),
            Text('Task: $taskTitle', style: TextStyle(color: textColor)),
          ],
          if (moodEntry.note != null && moodEntry.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(moodEntry.note!, style: TextStyle(color: textColor)),
          ],
        ],
      ),
    );
  }
}

class _MoodPill extends StatelessWidget {
  const _MoodPill({required this.label, required this.mood});

  final String label;
  final String mood;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.24)),
      ),
      child: Text(
        '$label: ${MoodSelector.emojiForMood(mood)} ${MoodSelector.labelForMood(mood)}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isLight ? AppColors.tomatoDark : AppColors.textWhite,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label $value'),
    );
  }
}
