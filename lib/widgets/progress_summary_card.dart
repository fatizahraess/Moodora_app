// Premium daily goal progress card with violet-to-coral progress bar.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_gradients.dart';
import 'common_glass_card.dart';

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({
    super.key,
    required this.completed,
    required this.goal,
  });

  final int completed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.textWhite;
    final safeGoal = goal <= 0 ? 1 : goal;
    final progress = (completed / safeGoal).clamp(0, 1).toDouble();
    final percentage = (progress * 100).round();

    return CommonGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Progress",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                '$completed / $goal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.pinkHighlight,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 13,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.primaryPurple.withValues(alpha: 0.12)
                      : AppColors.textWhite.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: AppGradients.timerAccent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            '$percentage% of your daily focus goal completed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.lightTextMuted
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
