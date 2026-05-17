// Premium card for displaying one Focus Mood insight.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'common_glass_card.dart';

class MoodInsightCard extends StatelessWidget {
  const MoodInsightCard({
    super.key,
    required this.insight,
    this.icon = Icons.psychology_alt_outlined,
  });

  final String insight;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.textSecondary;
    return CommonGlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.pinkHighlight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
