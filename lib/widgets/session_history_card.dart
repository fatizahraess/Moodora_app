// Card used by the history screen to display a completed session.
import 'package:flutter/material.dart';

import '../models/pomodoro_session.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/date_formatter.dart';
import 'common_glass_card.dart';

class SessionHistoryCard extends StatelessWidget {
  const SessionHistoryCard({
    super.key,
    required this.session,
    this.moodLabel,
  });

  final PomodoroSession session;
  final String? moodLabel;

  @override
  Widget build(BuildContext context) {
    final color = session.isWorkSession
        ? AppConstants.primaryColor
        : AppConstants.secondaryColor;
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.textWhite;

    return CommonGlassCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                session.isWorkSession ? Icons.work_outline : Icons.coffee,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelForType(session.type),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.taskTitle == null
                        ? 'No linked task'
                        : 'Task: ${session.taskTitle}',
                  ),
                  if (moodLabel != null) ...[
                    const SizedBox(height: 4),
                    Text('Mood: $moodLabel'),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${session.duration} min',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(DateFormatter.time(session.date)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _labelForType(String type) {
    return switch (type) {
      'work' => 'Work session',
      'shortBreak' => 'Short break',
      'longBreak' => 'Long break',
      _ => type,
    };
  }
}
