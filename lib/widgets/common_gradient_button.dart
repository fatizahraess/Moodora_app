// Reusable Pomodoro pill button used across the app.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CommonGradientButton extends StatefulWidget {
  const CommonGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
    this.width,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final double? width;
  final double height;

  @override
  State<CommonGradientButton> createState() => _CommonGradientButtonState();
}

class _CommonGradientButtonState extends State<CommonGradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final secondaryBackground =
        isLight ? const Color(0xFFF0ECE8) : AppColors.surfaceDark;
    final secondaryForeground =
        isLight ? AppColors.ink : AppColors.textWhite;
    final background = widget.primary ? AppColors.tomato : secondaryBackground;
    final foreground = widget.primary ? Colors.white : secondaryForeground;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: widget.width,
        height: widget.height,
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: enabled
              ? background
              : AppColors.textMuted.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(24),
          border: widget.primary
              ? null
              : Border.all(
                  color: isLight
                      ? AppColors.lightLine
                      : AppColors.subtleLine,
                ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: (widget.primary ? AppColors.tomato : Colors.black)
                        .withValues(alpha: widget.primary ? 0.18 : 0.05),
                    blurRadius: widget.primary ? 14 : 8,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: foreground, size: 19),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
