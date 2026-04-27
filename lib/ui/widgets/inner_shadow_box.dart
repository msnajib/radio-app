import 'package:flutter/material.dart';
import '../../core/theme/app_shadows.dart';

// Renders a clipped container with inset shadows painted as a foreground overlay.
// Equivalent to CSS `inset` box-shadow.
//
// Technique: for each shadow, an even-odd path (outer rect minus offset inner shape)
// is drawn inside a clip, then blurred — this makes the shadow appear only at the
// edges, fading inward, exactly like a CSS inset shadow.
class InnerShadowBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final List<InsetShadow> shadows;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;

  const InnerShadowBox({
    super.key,
    required this.child,
    required this.color,
    required this.shadows,
    this.borderRadius = 100,
    this.width,
    this.height,
    this.padding,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CustomPaint(
        foregroundPainter: _InsetShadowPainter(
          shadows: shadows,
          borderRadius: borderRadius,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: gradient != null
              ? BoxDecoration(gradient: gradient)
              : BoxDecoration(color: color),
          child: child,
        ),
      ),
    );
  }
}

class _InsetShadowPainter extends CustomPainter {
  final List<InsetShadow> shadows;
  final double borderRadius;

  const _InsetShadowPainter({
    required this.shadows,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = Radius.circular(borderRadius);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    for (final shadow in shadows) {
      canvas.saveLayer(rect, Paint());

      // Outer rect (fills entire clip) minus offset inner rrect = ring shadow at edges
      final expandedRect = rect.inflate(shadow.blur * 3);
      final shiftedRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          shadow.offset.dx,
          shadow.offset.dy,
          size.width,
          size.height,
        ),
        radius,
      );

      final path = Path()
        ..addRect(expandedRect)
        ..addRRect(shiftedRRect)
        ..fillType = PathFillType.evenOdd;

      final sigma = _blurToSigma(shadow.blur);
      final paint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

      canvas.clipRRect(rrect);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  static double _blurToSigma(double blur) => blur * 0.3;

  @override
  bool shouldRepaint(_InsetShadowPainter old) =>
      old.shadows != shadows || old.borderRadius != borderRadius;
}
