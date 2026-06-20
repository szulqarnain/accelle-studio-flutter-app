import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    AppState.instance.initialize();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            SizedBox(
              width: 130,
              height: 130,
              child: CustomPaint(painter: _SandLogoPainter()),
            )
                .animate()
                .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 28),

            // App name
            const Text(
              'Access Sand Table',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF5F1EA),
                letterSpacing: 0.5,
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 8),

            // Tagline
            const Text(
              'control  ·  create  ·  inspire',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B6660),
                letterSpacing: 1.8,
                fontWeight: FontWeight.w500,
              ),
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 64),

            // Loading dots
            _LoadingDots()
                .animate(delay: 800.ms)
                .fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            final t = (_ctrl.value - i * 0.15).clamp(0.0, 1.0);
            final opacity = sin(t * pi).clamp(0.2, 1.0);
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4A256).withValues(alpha: opacity),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Sand table mandala — concentric rings + radial spokes.
class _SandLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2 - 2;

    final stroke = Paint()
      ..color = const Color(0xFFD4A256)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final dimStroke = Paint()
      ..color = const Color(0xFFD4A256).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = const Color(0xFFD4A256)
      ..style = PaintingStyle.fill;

    // Outer ring
    canvas.drawCircle(center, maxR, stroke);
    // Middle rings
    canvas.drawCircle(center, maxR * 0.68, stroke);
    canvas.drawCircle(center, maxR * 0.38, dimStroke);

    // 8 radial spokes from inner ring to outer ring
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi - pi / 2;
      final inner = Offset(
        center.dx + cos(angle) * maxR * 0.38,
        center.dy + sin(angle) * maxR * 0.38,
      );
      final outer = Offset(
        center.dx + cos(angle) * maxR * 0.68,
        center.dy + sin(angle) * maxR * 0.68,
      );
      canvas.drawLine(inner, outer, stroke);
    }

    // 16 tiny tick marks on outer ring
    for (int i = 0; i < 16; i++) {
      if (i % 2 == 0) continue; // skip where spokes are
      final angle = (i / 16) * 2 * pi - pi / 2;
      final inner = Offset(
        center.dx + cos(angle) * (maxR - 6),
        center.dy + sin(angle) * (maxR - 6),
      );
      final outer = Offset(
        center.dx + cos(angle) * maxR,
        center.dy + sin(angle) * maxR,
      );
      canvas.drawLine(inner, outer, dimStroke);
    }

    // Centre dot
    canvas.drawCircle(center, 4.5, fill);
    canvas.drawCircle(center, 8, dimStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
