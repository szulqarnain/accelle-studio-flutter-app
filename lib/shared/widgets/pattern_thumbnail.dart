import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/models.dart';

Color patternCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'geometric':
      return const Color(0xFF5B9BD5);
    case 'organic':
      return const Color(0xFF52A875);
    case 'mandala':
      return const Color(0xFF9B6BC5);
    case 'abstract':
      return const Color(0xFFD4804A);
    default:
      return const Color(0xFF5B9BD5);
  }
}

Color _patternCategoryBg(String category) {
  switch (category.toLowerCase()) {
    case 'geometric':
      return const Color(0xFF0A1628);
    case 'organic':
      return const Color(0xFF0A1E12);
    case 'mandala':
      return const Color(0xFF160A2A);
    case 'abstract':
      return const Color(0xFF231608);
    default:
      return const Color(0xFF0A1628);
  }
}

IconData patternCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'geometric':
      return LucideIcons.hexagon;
    case 'organic':
      return LucideIcons.waves;
    case 'mandala':
      return LucideIcons.sun;
    case 'abstract':
      return LucideIcons.star;
    default:
      return LucideIcons.hexagon;
  }
}

class PatternThumbnail extends StatelessWidget {
  final PatternItem pattern;
  final double size;

  const PatternThumbnail({super.key, required this.pattern, this.size = 60});

  @override
  Widget build(BuildContext context) {
    final bg = _patternCategoryBg(pattern.category);
    final stroke = patternCategoryColor(pattern.category);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _PatternPainter(path: pattern.path, strokeColor: stroke, bgColor: bg),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final String path;
  final Color strokeColor;
  final Color bgColor;

  _PatternPainter({required this.path, required this.strokeColor, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = bgColor);

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    switch (path) {
      case 'geometric/spiral_bloom.thr':
        _drawSpiral(canvas, paint, cx, cy, r);
        break;
      case 'geometric/hex_lattice.thr':
        _drawHexGrid(canvas, paint, cx, cy, r);
        break;
      case 'organic/dune_waves.thr':
        _drawDuneWaves(canvas, paint, size);
        break;
      case 'organic/coastline.thr':
        _drawCoastline(canvas, paint, size);
        break;
      case 'mandala/lotus_field.thr':
        _drawLotus(canvas, paint, cx, cy, r);
        break;
      case 'mandala/eight_fold.thr':
        _drawEightFold(canvas, paint, cx, cy, r);
        break;
      case 'abstract/fractured.thr':
        _drawFractured(canvas, paint, size);
        break;
      case 'abstract/whisper.thr':
        _drawWhisper(canvas, paint, size);
        break;
      default:
        _drawSpiral(canvas, paint, cx, cy, r);
    }
  }

  void _drawSpiral(Canvas canvas, Paint paint, double cx, double cy, double maxR) {
    const turns = 4;
    const points = 200;
    final path = Path();
    for (int i = 0; i < points; i++) {
      final t = i / points;
      final angle = t * turns * 2 * pi;
      final radius = maxR * (1 - t);
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, paint);
  }

  void _drawHexGrid(Canvas canvas, Paint paint, double cx, double cy, double r) {
    final hexR = r * 0.32;
    final offsets = [
      Offset(cx, cy),
      Offset(cx + hexR * 1.8, cy),
      Offset(cx - hexR * 1.8, cy),
      Offset(cx + hexR * 0.9, cy - hexR * 1.56),
      Offset(cx - hexR * 0.9, cy - hexR * 1.56),
      Offset(cx + hexR * 0.9, cy + hexR * 1.56),
      Offset(cx - hexR * 0.9, cy + hexR * 1.56),
    ];
    for (final o in offsets) {
      final p = Path();
      for (int i = 0; i < 6; i++) {
        final a = pi / 6 + i * pi / 3;
        final x = o.dx + hexR * cos(a);
        final y = o.dy + hexR * sin(a);
        if (i == 0) { p.moveTo(x, y); } else { p.lineTo(x, y); }
      }
      p.close();
      canvas.drawPath(p, paint);
    }
  }

  void _drawDuneWaves(Canvas canvas, Paint paint, Size size) {
    for (int wave = 0; wave < 5; wave++) {
      final y0 = size.height * (0.2 + wave * 0.15);
      final p = Path();
      p.moveTo(0, y0);
      final amp = size.height * 0.04;
      final freq = (wave + 2) * 0.4;
      for (double x = 0; x <= size.width; x += 1) {
        final y = y0 + amp * sin(freq * x / size.width * 2 * pi + wave * 0.7);
        p.lineTo(x, y);
      }
      canvas.drawPath(p, paint);
    }
  }

  void _drawCoastline(Canvas canvas, Paint paint, Size size) {
    final rng = Random(13);
    for (int line = 0; line < 2; line++) {
      final p = Path();
      final y0 = size.height * (0.35 + line * 0.3);
      p.moveTo(0, y0);
      double x = 0;
      while (x < size.width) {
        final step = 6.0 + rng.nextDouble() * 8;
        x += step;
        final y = y0 + (rng.nextDouble() - 0.5) * size.height * 0.2;
        p.lineTo(x.clamp(0, size.width), y.clamp(0, size.height));
      }
      canvas.drawPath(p, paint);
    }
  }

  void _drawLotus(Canvas canvas, Paint paint, double cx, double cy, double r) {
    final petalR = r * 0.45;
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final ox = cx + r * 0.55 * cos(angle);
      final oy = cy + r * 0.55 * sin(angle);
      canvas.drawCircle(Offset(ox, oy), petalR, paint);
    }
    canvas.drawCircle(Offset(cx, cy), r * 0.25, paint);
  }

  void _drawEightFold(Canvas canvas, Paint paint, double cx, double cy, double r) {
    for (int i = 0; i < 8; i++) {
      final startAngle = i * pi / 4;
      final sweepAngle = pi / 3;
      final rect = Rect.fromCenter(center: Offset(cx, cy), width: r * 1.6, height: r * 1.6);
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      // inner arc
      final innerRect = Rect.fromCenter(center: Offset(cx, cy), width: r * 0.9, height: r * 0.9);
      canvas.drawArc(innerRect, startAngle + pi / 8, sweepAngle * 0.7, false, paint);
    }
  }

  void _drawFractured(Canvas canvas, Paint paint, Size size) {
    final rng = Random(42);
    for (int i = 0; i < 12; i++) {
      final x1 = rng.nextDouble() * size.width;
      final y1 = rng.nextDouble() * size.height;
      final x2 = rng.nextDouble() * size.width;
      final y2 = rng.nextDouble() * size.height;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  void _drawWhisper(Canvas canvas, Paint paint, Size size) {
    final rng = Random(7);
    // dots
    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
    }
    // bezier curves
    for (int i = 0; i < 3; i++) {
      final p = Path();
      final y0 = size.height * (0.25 + i * 0.25);
      p.moveTo(0, y0);
      p.cubicTo(
        size.width * 0.3, y0 + (rng.nextDouble() - 0.5) * size.height * 0.3,
        size.width * 0.7, y0 + (rng.nextDouble() - 0.5) * size.height * 0.3,
        size.width, y0,
      );
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
