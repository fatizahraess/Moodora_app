// Premium empty state with lavender icon, soft glass surface, and optional action.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'common_glass_card.dart';
import 'common_gradient_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.textWhite;
    return CommonGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.2),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Icon(icon, size: 38, color: AppColors.softLavender),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.lightTextMuted
                      : AppColors.textMuted,
                ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            CommonGradientButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
