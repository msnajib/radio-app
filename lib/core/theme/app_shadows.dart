import 'package:flutter/material.dart';

// Inset shadow descriptor — equivalent to CSS `inset X Y blur color`.
// Used by InnerShadowBox to paint shadows inside a clipped area.
class InsetShadow {
  final Color color;
  final Offset offset;
  final double blur;

  const InsetShadow({
    required this.color,
    required this.offset,
    required this.blur,
  });
}

// Pre-defined button shadow presets matching Figma spec.
abstract final class AppInsetShadows {
  static const List<InsetShadow> buttonPrimary = [
    InsetShadow(color: Color(0xFF3E3E3E), offset: Offset(6, 6), blur: 12),
    InsetShadow(color: Color(0xFF1E1E1E), offset: Offset(-6, -6), blur: 12),
  ];

  static const List<InsetShadow> buttonSecondary = [
    InsetShadow(color: Color(0xFFE2E2E2), offset: Offset(6, 6), blur: 12),
    InsetShadow(color: Color(0xFFABABAB), offset: Offset(-6, -6), blur: 12),
  ];
}
