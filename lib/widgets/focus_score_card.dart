// Premium card that displays the daily Focus Score with a glowing circular progress.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'common_glass_card.dart';

class FocusScoreCard extends StatelessWidget {
  const FocusScoreCard({
    super.key,
    required this.score,
    required this.label,
  });

  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.textWhite;
    final progress = (score / 100).clamp(0, 1).toDouble();

    return CommonGlassCard(
      child: Row(
        children: [
          SizedBox(
            height: 78,
            width: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                    backgroundColor: Theme.of(context).brightness == Brightness.light
                        ? AppColors.primaryPurple.withValues(alpha: 0.12)
                        : AppColors.textWhite.withValues(alpha: 0.10),
                  color: AppColors.coral,
                ),
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score / 100',
                  style: const TextStyle(color: AppColors.pinkHighlight),
                ),
                const SizedBox(height: 4),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
