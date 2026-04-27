import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// Decorative knob — purely visual, 48x48 px, no gesture detection.
// Gesture handling lives in CircleDial (the full arc is the drag target).
class Knob extends StatelessWidget {
  static const double kSize = 48;

  const Knob({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kSize,
      height: kSize,
      child: CustomPaint(painter: _KnobPainter()),
    );
  }
}

class _KnobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2; // 24.0
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Metallic gradient fill — 215° (upper-right → lower-left)
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment(0.57, -0.82), // ~35° origin
          end: Alignment(-0.57, 0.82), // ~215° destination
          colors: [Color(0xFFEEEEEE), Color(0xFF454545)],
          stops: [0.117, 0.866],
        ).createShader(rect),
    );

    // 2. Grip lines — 88 short radial segments spread 360°
    final gripPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    const double gripOuter = 22.0; // just inside border
    const double gripInner = 16.0; // 6 px grip length

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

    // 3. Border ring
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
