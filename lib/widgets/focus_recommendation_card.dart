// Visual card that displays the current Focus Coach task recommendation.
import 'package:flutter/material.dart';

import '../models/focus_recommendation.dart';
import '../utils/app_constants.dart';
import 'common_gradient_button.dart';
import 'empty_state.dart';
import 'priority_badge.dart';

class FocusRecommendationCard extends StatelessWidget {
  const FocusRecommendationCard({
    super.key,
    required this.recommendation,
    this.onStart,
  });

  final FocusRecommendation? recommendation;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    if (recommendation == null) {
      return const EmptyState(
        icon: Icons.lightbulb_outline,
        title: 'No recommendation yet',
        description: 'Add an active task to let Focus Coach choose what to do next.',
      );
    }

    final item = recommendation!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Recommended Focus',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  Text(
                    '${item.score}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item.task.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text('Reason: ${item.reason}.'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PriorityBadge(priority: item.task.priority),
                  _ChipText(label: 'Suggested: ${item.suggestedPomodoros} Pomodoros'),
                  _ChipText(
                    label:
                        '${item.task.completedPomodoros}/${item.task.estimatedPomodoros} done',
                  ),
                ],
              ),
              if (onStart != null) ...[
                const SizedBox(height: 16),
                CommonGradientButton(
                  onPressed: onStart,
                  icon: Icons.play_arrow,
                  label: 'Start recommended focus',
                  width: double.infinity,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipText extends StatelessWidget {
  const _ChipText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.secondaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppConstants.secondaryColor,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
