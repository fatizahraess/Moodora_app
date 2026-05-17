// Premium summary card for Focus Mood score, dominant mood, average energy, and stress.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_gradients.dart';
import 'common_glass_card.dart';
import 'mood_selector.dart';

class MoodSummaryCard extends StatelessWidget {
  const MoodSummaryCard({
    super.key,
    required this.dominantMood,
    required this.moodScore,
    required this.averageEnergy,
    required this.averageStress,
    this.compact = false,
  });

  final String? dominantMood;
  final int moodScore;
  final double averageEnergy;
  final double averageStress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.textWhite;
    final secondaryTextColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightTextMuted
        : AppColors.textSecondary;
    final mood = dominantMood ?? 'neutral';
    return CommonGlassCard(
      padding: EdgeInsets.all(compact ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 58 : 82,
                height: compact ? 58 : 82,
                decoration: BoxDecoration(
                  gradient: AppGradients.timerAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coral.withValues(alpha: 0.32),
                      blurRadius: 26,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  MoodSelector.emojiForMood(mood),
                  style: TextStyle(fontSize: compact ? 26 : 38),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus Mood',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${MoodSelector.labelForMood(mood)} · $moodScore/100',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: 'Energy',
                  value: '${averageEnergy.toStringAsFixed(1)}/5',
                  icon: Icons.bolt,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricPill(
                  label: 'Stress',
                  value: '${averageStress.toStringAsFixed(1)}/5',
                  icon: Icons.spa_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.primaryPurple.withValues(alpha: 0.08)
            : AppColors.textWhite.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.subtleLine),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.pinkHighlight),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.lightText
                            : AppColors.textWhite,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
