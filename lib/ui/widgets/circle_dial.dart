import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/frequencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/frequency_mapper.dart';

// Rotating tick arc with built-in rotary gesture detection.
//
// MAPPING  : Window of ticks centered on currentTick fills the visible semicircle.
//            tickAngle(d) = π + (d + halfWindow) / (2·halfWindow) · π
//            d<0 → left (lower freq), d=0 → needle (12-o'clock), d>0 → right (higher freq).
// TICKS    : OUTWARD — base at ring (r), tip outside (r + tickLen). Same strokeWidth for all.
//            Labels just outside the tip.
// DEAD ZONE: grey ring arc + ghost ticks (#1C1C1C @20%) outside the frequency range.
// SPACING  : kFMWindowTicks / kAMWindowTicks controls how many ticks span the π arc.
//
// GEOMETRY :
//   kRadius = 328  (fixed, half of Figma 656 px dial)
//   kHeight = kRadius + 50  (extra headroom for outward labels)
//   cy = size.height = widget bottom = circle center
class CircleDial extends StatefulWidget {
  final double position; // 0.0–1.0
  final Band band;
  final ValueChanged<double> onRotate; // positive = CW = higher freq
  final ValueChanged<double>? onRelease;
  final VoidCallback? onTick;
  final VoidCallback? onDragStart;
  final int?
  playingTickIndex; // hide label for this tick when station is playing

  static const double kRadius = 328.0;
  static const double kMajorTick = 20.0;
  static const double kMinorTick = 12.0;
  static const double kLabelGap = 16.0;
  static const double kHeight = kRadius - 8;

  // ── Spacing knobs ─────────────────────────────────────────────────────────
  // Fewer ticks in the window = more visual space between each tick.
  // FM: kFMWindowTicks=60 → ~17 px/tick  (6 MHz visible)
  // AM: kAMWindowTicks=30 → ~34 px/tick  (300 kHz visible)
  static const int kFMWindowTicks = 120;
  static const int kAMWindowTicks = 160;

  const CircleDial({
    super.key,
    required this.position,
    required this.band,
    required this.onRotate,
    this.onRelease,
    this.onTick,
    this.onDragStart,
    this.playingTickIndex,
  });

  @override
  State<CircleDial> createState() => _CircleDialState();
}

class _CircleDialState extends State<CircleDial> {
  Offset? _lastPos;
  int _lastTick = -1;

  // Local position tracked in real-time during gesture (not waiting for BLoC rebuild).
  double _localPos = 0.0;

  int _totalTicks() =>
      widget.band == Band.fm ? FMConstants.totalTicks : AMConstants.totalTicks;

  @override
  void didUpdateWidget(CircleDial old) {
    super.didUpdateWidget(old);
    // Only fire haptic/tick for programmatic changes (snap, jump) — not during
    // active gesture, which handles its own ticks in _onPanUpdate.
    if (_lastPos != null) return;
    final tick = (widget.position * (_totalTicks() - 1)).round();
    if (_lastTick != -1 && tick != _lastTick) {
      HapticFeedback.selectionClick();
      widget.onTick?.call();
    }
    _lastTick = tick;
  }

  double _angularDelta(Offset from, Offset to, Offset center) {
    final a = from - center;
    final b = to - center;
    if (a.distance < 10 || b.distance < 10) return 0;
    final cross = a.dx * b.dy - a.dy * b.dx;
    final dot = a.dx * b.dx + a.dy * b.dy;
    return math.atan2(cross, dot);
  }

  void _onPanStart(DragStartDetails d, Offset center) {
    _lastPos = d.localPosition;
    _localPos = widget.position;
    _lastTick = (_localPos * (_totalTicks() - 1)).round();
    widget.onDragStart?.call();
  }

  void _onPanUpdate(DragUpdateDetails d, Offset center) {
    if (_lastPos == null) return;
    final cur = d.localPosition;
    final dAngle = _angularDelta(_lastPos!, cur, center);
    _lastPos = cur;
    // Full 2π rotation → 0.40 of dial range. Negated so drag-right scrolls ticks right.
    const sensitivity = 0.40 / (2 * math.pi);
    final delta = dAngle * sensitivity;
    if (delta.abs() <= 0.0001) return;

    widget.onRotate(-delta);

    // Track position locally — detect every tick crossing in real-time,
    // independent of BLoC rebuild cadence.
    _localPos = (_localPos - delta) % 1.0;
    if (_localPos < 0) _localPos += 1.0;
    final newTick = (_localPos * (_totalTicks() - 1)).round();
    if (newTick != _lastTick) {
      final steps = (newTick - _lastTick).abs();
      for (int i = 0; i < steps; i++) {
        widget.onTick?.call();
      }
      HapticFeedback.selectionClick();
      _lastTick = newTick;
    }
  }

  void _onPanEnd(DragEndDetails d) {
    _lastPos = null;
    if (widget.onRelease == null) return;
    final speed = d.velocity.pixelsPerSecond.distance;
    final fraction = (speed / 3000.0).clamp(0.0, 1.0);
    // Negated to match drag direction convention above.
    final dir = d.velocity.pixelsPerSecond.dx >= 0 ? -1.0 : 1.0;
    widget.onRelease!(fraction * 0.15 * dir);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final circleCenter = Offset(w / 2, CircleDial.kHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => _onPanStart(d, circleCenter),
          onPanUpdate: (d) => _onPanUpdate(d, circleCenter),
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            size: Size(w, CircleDial.kHeight),
            painter: _DialPainter(
              position: widget.position,
              band: widget.band,
              playingTickIndex: widget.playingTickIndex,
            ),
          ),
        );
      },
    );
  }
}

// ── Painter ──────────────────────────────────────────────────────────────────

class _DialPainter extends CustomPainter {
  final double position;
  final Band band;
  final int? playingTickIndex;

  const _DialPainter({
    required this.position,
    required this.band,
    this.playingTickIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height; // circle center at widget bottom
    const r = CircleDial.kRadius;

    final totalTicks = band == Band.fm
        ? FMConstants.totalTicks
        : AMConstants.totalTicks;
    final windowTicks = band == Band.fm
        ? CircleDial.kFMWindowTicks
        : CircleDial.kAMWindowTicks;
    final halfWindow = windowTicks ~/ 2;
    final currentTick = (position * (totalTicks - 1)).round().clamp(
      0,
      totalTicks - 1,
    );

    // Canvas angle for tick at offset d from currentTick:
    //   d = −halfWindow → π  (left / 9-o'clock)
    //   d =  0          → 3π/2  (top / 12-o'clock / needle)
    //   d = +halfWindow → 2π≡0  (right / 3-o'clock)
    double tickAngle(int d) =>
        math.pi + (d + halfWindow) / (2.0 * halfWindow) * math.pi;

    bool isMajor(int virtualIndex) => band == Band.fm
        ? FrequencyMapper.isFMMajorTick(virtualIndex)
        : FrequencyMapper.isAMMajorTick(virtualIndex);

    // ── White background — filled semicircle ─────────────────────────────────
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: size.height),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    // ── Dead zone arcs (grey ring) ────────────────────────────────────────────
    final deadPaint = Paint()
      ..color = AppColors.dialDeadZone
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final distFromStart = currentTick;
    final distFromEnd = totalTicks - 1 - currentTick;

    if (distFromStart < halfWindow) {
      final sweep = (halfWindow - distFromStart) / (2.0 * halfWindow) * math.pi;
      if (sweep > 0.002) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          math.pi,
          sweep,
          false,
          deadPaint,
        );
      }
    }

    if (distFromEnd < halfWindow) {
      final sweep = (halfWindow - distFromEnd) / (2.0 * halfWindow) * math.pi;
      if (sweep > 0.002) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          tickAngle(distFromEnd),
          sweep,
          false,
          deadPaint,
        );
      }
    }

    // ── Tick paint (same strokeWidth for major and minor) ────────────────────
    final tickPaint = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final ghostPaint = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = const Color(0x331C1C1C); // #1C1C1C @ 20% opacity

    // ── Ghost ticks in dead zone ──────────────────────────────────────────────
    void drawTick(Canvas c, int d, Paint paint) {
      final angle = tickAngle(d);
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      if (sinA >= -0.01) return; // lower semicircle, skip
      final major = isMajor(currentTick + d);
      final tickLen = major ? CircleDial.kMajorTick : CircleDial.kMinorTick;
      c.drawLine(
        Offset(cx + r * cosA, cy + r * sinA),
        Offset(cx + (r + tickLen) * cosA, cy + (r + tickLen) * sinA),
        paint,
      );
    }

    // Left ghost ticks (virtual indices < 0)
    if (distFromStart < halfWindow) {
      for (int d = -halfWindow; d < -distFromStart; d++) {
        drawTick(canvas, d, ghostPaint);
      }
    }

    // Right ghost ticks (virtual indices >= totalTicks)
    if (distFromEnd < halfWindow) {
      for (int d = distFromEnd + 1; d <= halfWindow; d++) {
        drawTick(canvas, d, ghostPaint);
      }
    }

    // ── Active tick marks ─────────────────────────────────────────────────────
    final iStart = math.max(0, currentTick - halfWindow);
    final iEnd = math.min(totalTicks - 1, currentTick + halfWindow);

    for (int i = iStart; i <= iEnd; i++) {
      final d = i - currentTick;
      final angle = tickAngle(d);
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      if (sinA >= -0.01) continue;

      final major = isMajor(i);
      final tickLen = major ? CircleDial.kMajorTick : CircleDial.kMinorTick;
      tickPaint.color = major ? AppColors.dialTickMajor : AppColors.dialTick;

      // OUTWARD: base at ring surface (r), tip outside ring (r + tickLen).
      canvas.drawLine(
        Offset(cx + r * cosA, cy + r * sinA),
        Offset(cx + (r + tickLen) * cosA, cy + (r + tickLen) * sinA),
        tickPaint,
      );

      // Label outside tick tip (major ticks only; hidden when station is playing at this tick).
      if (major && i != playingTickIndex) {
        final labelStr = band == Band.fm
            ? FrequencyMapper.fmTickToFreq(i).toStringAsFixed(1)
            : FrequencyMapper.amTickToFreq(i).toString();

        final labelR = r + CircleDial.kMajorTick + CircleDial.kLabelGap;
        final lx = cx + labelR * cosA;
        final ly = cy + labelR * sinA;

        if (ly < size.height) {
          canvas.save();
          canvas.translate(lx, ly);
          canvas.rotate(angle + math.pi / 2);
          final tp = TextPainter(
            text: TextSpan(
              text: labelStr.toUpperCase(),
              style: AppTypography.dialLabel,
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
          canvas.restore();
        }
      }
    }

    // ── Knob — full dial as physical knob, indicator on outer body ───────────
    const kKnobR = CircleDial.kHeight; // ~320px, fills widget
    const kGripInner = kKnobR - 36.0;
    const kGripOuter = kKnobR - 2.0;
    // Indicator lives at ~80% of knob radius, inside the body area
    const kIndicatorOuter = kKnobR - 52.0;
    const kIndicatorInner = kKnobR - 100.0;

    final knobRect = Rect.fromCircle(center: Offset(cx, cy), radius: kKnobR);

    // 1. Outer drop shadow
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx + 4, cy + 6), radius: kKnobR + 4),
      math.pi,
      math.pi,
      true,
      Paint()
        ..color = const Color(0x44000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // 2. Body — chrome radial gradient (off-center → convex 3D illusion)
    canvas.drawArc(
      knobRect,
      math.pi,
      math.pi,
      true,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.18, -0.42),
          radius: 1.05,
          colors: [
            Color(0xFFF6F6F6), // bright specular center
            Color(0xFFD2D2D2), // silver mid
            Color(0xFF909090), // darker silver
            Color(0xFF565656), // deep shadow at edge
          ],
          stops: [0.0, 0.32, 0.70, 1.0],
        ).createShader(knobRect),
    );

    // 3. Center accent ring — decorative hub at ~⅓ of knob radius
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: kKnobR - 160),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFCFC9C9)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: kKnobR - 160.8),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFE8E8E8)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );

    // 4. Grip band background — dark chrome ring
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(cx, cy),
        radius: (kGripInner + kGripOuter) / 2,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFC8C8C8)
        ..strokeWidth = kGripOuter - kGripInner
        ..style = PaintingStyle.stroke,
    );

    // 3b. Separator ring — tight arc just inside grip band inner edge
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: kGripInner - 1),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF888888)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: kGripInner + 1),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFE2E2E2)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );

    // 4. Knurling — 88 segments spread 360°, alternating shadow+highlight
    for (int i = 0; i < 88; i++) {
      final a = (i / 88) * 2 * math.pi;
      final ca = math.cos(a);
      final sa = math.sin(a);
      canvas.drawLine(
        Offset(cx + kGripInner * ca, cy + kGripInner * sa),
        Offset(cx + kGripOuter * ca, cy + kGripOuter * sa),
        Paint()
          ..color = const Color(0xFF888888)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.butt
          ..style = PaintingStyle.stroke,
      );
      // highlight stripe next to each shadow stripe
      final ah = a + (math.pi / 88) * 0.5;
      canvas.drawLine(
        Offset(cx + kGripInner * math.cos(ah), cy + kGripInner * math.sin(ah)),
        Offset(cx + kGripOuter * math.cos(ah), cy + kGripOuter * math.sin(ah)),
        Paint()
          ..color = const Color(0xFFE8E8E8)
          ..strokeWidth = 0.7
          ..strokeCap = StrokeCap.butt
          ..style = PaintingStyle.stroke,
      );
    }

    // 5. Specular sweep — soft white arc, top-left area
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(cx - kKnobR * 0.12, cy - kKnobR * 0.25),
        radius: kKnobR * 0.50,
      ),
      math.pi * 1.1,
      math.pi * 0.42,
      false,
      Paint()
        ..color = const Color(0x44FFFFFF)
        ..strokeWidth = 40
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // 6. Outer border
    canvas.drawArc(
      knobRect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF787878)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // 7. Indicator — fixed at top (needle position = 12 o'clock)
    canvas.drawLine(
      Offset(cx, cy - kIndicatorInner),
      Offset(cx, cy - kIndicatorOuter),
      Paint()
        ..color = AppColors.dialTick
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.position != position ||
      old.band != band ||
      old.playingTickIndex != playingTickIndex;
}
