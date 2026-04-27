import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// Decorative knob — purely visual, 48x48 px, fixed colors (physical element).
class Knob extends StatelessWidget {
  static const double kSize = 48;

  const Knob({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: kSize,
      height: kSize,
      child: CustomPaint(painter: _KnobPainter()),
    );
  }
}

class _KnobPainter extends CustomPainter {
  const _KnobPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment(0.57, -0.82),
          end: Alignment(-0.57, 0.82),
          colors: [AppColors.knobGradientLight, AppColors.knobGradientDark],
          stops: [0.117, 0.866],
        ).createShader(rect),
    );

    final gripPaint = Paint()
      ..color = AppColors.knobGradientLight
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    const double gripOuter = 22.0;
    const double gripInner = 16.0;

    for (int i = 0; i < 88; i++) {
      final angle = (i / 88) * 2 * math.pi;
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      canvas.drawLine(
        Offset(center.dx + gripOuter * cosA, center.dy + gripOuter * sinA),
        Offset(center.dx + gripInner * cosA, center.dy + gripInner * sinA),
        gripPaint,
      );
    }

    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = AppColors.knobBorder
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_KnobPainter old) => false;
}
