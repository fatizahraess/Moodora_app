// Premium weekly focus heatmap built from local focus minutes without external packages.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import 'common_glass_card.dart';

class WeeklyFocusHeatmap extends StatelessWidget {
  const WeeklyFocusHeatmap({
    super.key,
    required this.weeklyFocusMinutes,
  });

  final Map<String, int> weeklyFocusMinutes;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.textWhite;
    final days = _weekDays();
    final maxMinutes = weeklyFocusMinutes.values.fold<int>(
      0,
      (max, minutes) => minutes > max ? minutes : max,
    );

    return CommonGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Focus Heatmap',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: days.map((day) {
              final key = DateFormatter.databaseDay(day);
              final minutes = weeklyFocusMinutes[key] ?? 0;
              final intensity =
                  maxMinutes == 0 ? 0.10 : (minutes / maxMinutes).clamp(0.14, 1);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        height: 62,
                        decoration: BoxDecoration(
                          color: AppColors.coral.withValues(
                            alpha: intensity.toDouble(),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: minutes > 0
                              ? [
                                  BoxShadow(
                                    color: AppColors.coral.withValues(alpha: 0.22),
                                    blurRadius: 16,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormatter.readableDate(day).split(',').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        '$minutes',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<DateTime> _weekDays() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }
}
