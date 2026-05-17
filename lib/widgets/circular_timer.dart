// Tomato-shaped timer inspired by the Pomodoro reference design.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CircularTimer extends StatefulWidget {
  const CircularTimer({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.progress,
    required this.label,
    this.isRunning = false,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final double progress;
  final String label;
  final bool isRunning;

  @override
  State<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends State<CircularTimer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.isRunning) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CircularTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRunning && _controller.isAnimating) {
      _controller.stop();
      _controller.animateTo(0, duration: const Duration(milliseconds: 220));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.remainingSeconds ~/ 60;
    final seconds = widget.remainingSeconds % 60;
    final displayTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: widget.progress.clamp(0, 1).toDouble(),
      ),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final pulse = widget.isRunning
                ? 1 + math.sin(_controller.value * math.pi) * 0.025
                : 1.0;
            final rotation = widget.isRunning
                ? math.sin(_controller.value * math.pi * 2) * 0.025
                : 0.0;

            return Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: pulse,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: _TomatoTimerPainter(progress: animatedProgress),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayTime,
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.16,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.label.toUpperCase(),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.86),
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TomatoTimerPainter extends CustomPainter {
  const _TomatoTimerPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final shortest = size.shortestSide;
    final tomatoRadius = shortest * 0.34;
    final tomatoCenter = Offset(center.dx, center.dy + shortest * 0.04);

    final ringRadius = shortest * 0.43;
    final ringRect = Rect.fromCircle(center: center, radius: ringRadius);
    final ringStroke = shortest * 0.035;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + shortest * 0.34),
        width: shortest * 0.48,
        height: shortest * 0.08,
      ),
      shadowPaint,
    );

    final baseRing = Paint()
      ..color = const Color(0xFFE9E4E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, ringRadius, baseRing);

    final progressPaint = Paint()
      ..color = AppColors.tomato
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      ringRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );

    if (progress > 0) {
      final angle = -math.pi / 2 + math.pi * 2 * progress;
      final dot = Offset(
        center.dx + math.cos(angle) * ringRadius,
        center.dy + math.sin(angle) * ringRadius,
      );
      canvas.drawCircle(dot, ringStroke * 0.82, Paint()..color = Colors.white);
      canvas.drawCircle(dot, ringStroke * 0.46, progressPaint);
    }

    final tomatoRect = Rect.fromCircle(
      center: tomatoCenter,
      radius: tomatoRadius,
    );
    final tomatoPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.tomatoSoft, AppColors.tomato, AppColors.tomatoDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(tomatoRect);
    canvas.drawCircle(tomatoCenter, tomatoRadius, tomatoPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          tomatoCenter.dx - tomatoRadius * 0.28,
          tomatoCenter.dy - tomatoRadius * 0.26,
        ),
        width: tomatoRadius * 0.42,
        height: tomatoRadius * 0.24,
      ),
      highlightPaint,
    );

    final leafPaint = Paint()
      ..color = AppColors.leaf
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i - 2) * 0.38;
      final path = Path()
        ..moveTo(tomatoCenter.dx, tomatoCenter.dy - tomatoRadius * 0.72)
        ..quadraticBezierTo(
          tomatoCenter.dx + math.cos(angle) * tomatoRadius * 0.18,
          tomatoCenter.dy - tomatoRadius * 1.15,
          tomatoCenter.dx + math.cos(angle) * tomatoRadius * 0.52,
          tomatoCenter.dy - tomatoRadius * 0.78,
        )
        ..quadraticBezierTo(
          tomatoCenter.dx + math.cos(angle) * tomatoRadius * 0.16,
          tomatoCenter.dy - tomatoRadius * 0.92,
          tomatoCenter.dx,
          tomatoCenter.dy - tomatoRadius * 0.72,
        );
      canvas.drawPath(path, leafPaint);
    }

    final eyePaint = Paint()..color = AppColors.ink;
    canvas.drawCircle(
      Offset(tomatoCenter.dx - tomatoRadius * 0.30, tomatoCenter.dy - 4),
      tomatoRadius * 0.055,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(tomatoCenter.dx + tomatoRadius * 0.30, tomatoCenter.dy - 4),
      tomatoRadius * 0.055,
      eyePaint,
    );

    final blushPaint = Paint()..color = Colors.white.withValues(alpha: 0.20);
    canvas.drawCircle(
      Offset(tomatoCenter.dx - tomatoRadius * 0.43, tomatoCenter.dy + 12),
      tomatoRadius * 0.07,
      blushPaint,
    );
    canvas.drawCircle(
      Offset(tomatoCenter.dx + tomatoRadius * 0.43, tomatoCenter.dy + 12),
      tomatoRadius * 0.07,
      blushPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TomatoTimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
