// Premium card that displays focus distribution items with glowing progress bars.
import 'package:flutter/material.dart';

import '../models/focus_map_item.dart';
import '../utils/app_colors.dart';
import 'common_glass_card.dart';

class FocusDistributionCard extends StatelessWidget {
  const FocusDistributionCard({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<FocusMapItem> items;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.textWhite;
    return CommonGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('No focus data yet.')
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _DistributionRow(item: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({required this.item});

  final FocusMapItem item;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.textWhite;
    final progress = (item.percentage / 100).clamp(0, 1).toDouble();
    final color = switch (item.priority) {
      'high' => AppColors.coral,
      'medium' => AppColors.warning,
      'low' => AppColors.success,
      _ => AppColors.softLavender,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Text('${item.focusMinutes} min · ${item.percentage.round()}%'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? AppColors.primaryPurple.withValues(alpha: 0.12)
                : AppColors.textWhite.withValues(alpha: 0.10),
            color: color,
          ),
        ),
      ],
    );
  }
}
