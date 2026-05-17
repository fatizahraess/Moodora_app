// Card for a neglected task that has priority or due-date pressure but no focus sessions.
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/app_constants.dart';
import '../utils/date_formatter.dart';
import 'common_gradient_button.dart';
import 'priority_badge.dart';

class NeglectedTaskCard extends StatelessWidget {
  const NeglectedTaskCard({
    super.key,
    required this.task,
    this.onStartFocus,
  });

  final Task task;
  final VoidCallback? onStartFocus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                PriorityBadge(priority: task.priority),
              ],
            ),
            const SizedBox(height: 8),
            const Text('No Pomodoro sessions yet'),
            if (task.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16,
                    color: task.isOverdue
                        ? AppConstants.dangerColor
                        : AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text('Due ${DateFormatter.readableDate(task.dueDate!)}'),
                ],
              ),
            ],
            if (onStartFocus != null) ...[
              const SizedBox(height: 12),
              CommonGradientButton(
                onPressed: onStartFocus,
                icon: Icons.play_arrow,
                label: 'Start Focus',
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
