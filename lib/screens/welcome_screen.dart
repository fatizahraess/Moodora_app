// Premium welcome screen that introduces Moodora before opening the main app.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_gradients.dart';
import '../utils/app_spacing.dart';
import '../widgets/common_gradient_button.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _openApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const HomeScreen(),
        ),
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.pageBackground),
        child: Stack(
          children: [
            const Positioned.fill(child: _WelcomeBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 720;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      compact ? AppSpacing.md : AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        const _WelcomeTopBar(),
                        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
                        Expanded(
                          child: Center(
                            child: _PhoneShowcase(compact: compact),
                          ),
                        ),
                        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
                        const _WelcomeCopy(),
                        const SizedBox(height: AppSpacing.lg),
                        CommonGradientButton(
                          label: 'Start',
                          icon: Icons.play_arrow_rounded,
                          height: 58,
                          onPressed: () => _openApp(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeTopBar extends StatelessWidget {
  const _WelcomeTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBubble(icon: Icons.menu_rounded),
        const Spacer(),
        Text(
          'Moodora',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
        ),
        const Spacer(),
        _IconBubble(icon: Icons.auto_graph_rounded),
      ],
    );
  }
}

class _PhoneShowcase extends StatelessWidget {
  const _PhoneShowcase({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 360.0 : 440.0;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -12,
            bottom: 22,
            child: Transform.rotate(
              angle: -0.14,
              child: _SidePreviewCard(
                height: height * 0.64,
                width: 126,
                type: _SidePreviewType.dashboard,
              ),
            ),
          ),
          Positioned(
            right: -10,
            bottom: 18,
            child: Transform.rotate(
              angle: 0.14,
              child: _SidePreviewCard(
                height: height * 0.64,
                width: 126,
                type: _SidePreviewType.mood,
              ),
            ),
          ),
          _MainPhoneMockup(height: height, compact: compact),
        ],
      ),
    );
  }
}

class _MainPhoneMockup extends StatelessWidget {
  const _MainPhoneMockup({
    required this.height,
    required this.compact,
  });

  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = height * 0.54;
    final timerSize = compact ? 174.0 : 210.0;
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0B25),
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.45),
            blurRadius: 42,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF7C4DFF),
                Color(0xFF6C3FF2),
                Color(0xFF29155F),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: CustomPaint(painter: _LandscapePainter())),
              Positioned(
                top: 10,
                child: Container(
                  height: 24,
                  width: 82,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned(
                top: 48,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: AppGradients.cta,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withValues(alpha: 0.32),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Text(
                    'FOCUS',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: compact ? 90 : 106,
                child: SizedBox(
                  height: timerSize,
                  width: timerSize,
                  child: CustomPaint(
                    painter: _WelcomeTimerPainter(progress: 0.72),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '25:00',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Stay focused',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: compact ? 72 : 92,
                child: Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    gradient: AppGradients.cta,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withValues(alpha: 0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.textWhite,
                    size: 34,
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

enum _SidePreviewType { dashboard, mood }

class _SidePreviewCard extends StatelessWidget {
  const _SidePreviewCard({
    required this.height,
    required this.width,
    required this.type,
  });

  final double height;
  final double width;
  final _SidePreviewType type;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.92,
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppGradients.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: type == _SidePreviewType.dashboard
            ? const _DashboardPreview()
            : const _MoodPreview(),
      ),
    );
  }
}

class _DashboardPreview extends StatelessWidget {
  const _DashboardPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Moodora',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _MiniStat(icon: Icons.timer_rounded, value: '12')),
            const SizedBox(width: 5),
            Expanded(child: _MiniStat(icon: Icons.local_fire_department_rounded, value: '8')),
            const SizedBox(width: 5),
            Expanded(child: _MiniStat(icon: Icons.trending_up_rounded, value: '92%')),
          ],
        ),
        const Spacer(),
        Center(
          child: SizedBox(
            height: 104,
            width: 104,
            child: CustomPaint(
              painter: _WelcomeTimerPainter(progress: 0.78, strokeWidth: 10),
              child: const Center(
                child: Text(
                  '25:00',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        Center(
          child: Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              gradient: AppGradients.cta,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}

class _MoodPreview extends StatelessWidget {
  const _MoodPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'How are you feeling?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            gradient: AppGradients.cta,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withValues(alpha: 0.30),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Icon(Icons.sentiment_satisfied_alt_rounded, color: AppColors.deepBackground, size: 44),
        ),
        const SizedBox(height: 12),
        const Text(
          'Good',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 58,
          width: double.infinity,
          child: CustomPaint(painter: _MoodWavePainter()),
        ),
        const Spacer(),
        Container(
          height: 34,
          decoration: BoxDecoration(
            gradient: AppGradients.cta,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(
            child: Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.softLavender, size: 14),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCopy extends StatelessWidget {
  const _WelcomeCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Focus smarter.\nFlow deeper.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w900,
                height: 1.04,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Plan tasks, run Pomodoro sessions, track mood, and understand your productivity rhythm.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 21),
    );
  }
}

class _WelcomeBackground extends StatelessWidget {
  const _WelcomeBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -90,
          right: -80,
          child: _GlowOrb(
            size: 220,
            color: AppColors.softLavender.withValues(alpha: 0.30),
          ),
        ),
        Positioned(
          top: 210,
          left: -100,
          child: _GlowOrb(
            size: 240,
            color: AppColors.primaryPurple.withValues(alpha: 0.24),
          ),
        ),
        Positioned(
          bottom: 150,
          right: -70,
          child: _GlowOrb(
            size: 180,
            color: AppColors.coral.withValues(alpha: 0.18),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _WelcomeTimerPainter extends CustomPainter {
  _WelcomeTimerPainter({
    required this.progress,
    this.strokeWidth = 14,
  });

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;
    final circleRect = Rect.fromCircle(center: center, radius: radius);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = Colors.white.withValues(alpha: 0.13);

    canvas.drawCircle(center, radius, basePaint);

    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..shader = AppGradients.timerAccent.createShader(circleRect);

    canvas.drawArc(
      circleRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      gradientPaint,
    );

    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 40; i++) {
      final angle = -math.pi / 2 + (math.pi * 2 * i / 40);
      final outer = Offset(
        center.dx + math.cos(angle) * (radius - strokeWidth - 2),
        center.dy + math.sin(angle) * (radius - strokeWidth - 2),
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - strokeWidth - (i % 5 == 0 ? 11 : 7)),
        center.dy + math.sin(angle) * (radius - strokeWidth - (i % 5 == 0 ? 11 : 7)),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WelcomeTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth;
  }
}

class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.softCoral.withValues(alpha: 0.90),
          AppColors.coral.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.78, size.height * 0.76),
          radius: 54,
        ),
      );
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.76), 54, sunPaint);

    final backPath = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.28, size.height * 0.64, size.width * 0.52, size.height * 0.74)
      ..quadraticBezierTo(size.width * 0.74, size.height * 0.84, size.width, size.height * 0.66)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      backPath,
      Paint()..color = AppColors.softLavender.withValues(alpha: 0.30),
    );

    final frontPath = Path()
      ..moveTo(0, size.height * 0.86)
      ..quadraticBezierTo(size.width * 0.34, size.height * 0.74, size.width * 0.60, size.height * 0.84)
      ..quadraticBezierTo(size.width * 0.82, size.height * 0.93, size.width, size.height * 0.80)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      frontPath,
      Paint()..color = AppColors.deepBackground.withValues(alpha: 0.62),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MoodWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..shader = AppGradients.cta.createShader(Offset.zero & size);

    final path = Path()..moveTo(0, size.height * 0.55);
    for (var x = 0.0; x <= size.width; x += 4) {
      final y = size.height * 0.55 + math.sin(x / size.width * math.pi * 4) * 12;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, linePaint);

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.42),
      4,
      Paint()..color = AppColors.pinkHighlight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
