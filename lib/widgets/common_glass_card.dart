// Reusable premium dark glass card with soft gradient, border, and subtle shadow.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_gradients.dart';
import '../utils/app_spacing.dart';

class CommonGlassCard extends StatefulWidget {
  const CommonGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.radius = AppSpacing.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  State<CommonGlassCard> createState() => _CommonGlassCardState();
}

class _CommonGlassCardState extends State<CommonGlassCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_pressed ? 0.985 : 1.0),
        padding: widget.padding,
        decoration: BoxDecoration(
          gradient: isLight ? AppGradients.lightCard : AppGradients.card,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: isLight ? AppColors.lightLine : AppColors.subtleLine,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: isLight ? 0.10 : 0.18),
              blurRadius: isLight ? 22 : 28,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.22),
              blurRadius: isLight ? 12 : 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
