import 'package:flutter/material.dart';
import 'app_colors.dart';

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
    InsetShadow(color: AppColors.buttonPrimaryInsetLight, offset: Offset(6, 6), blur: 12),
    InsetShadow(color: AppColors.buttonPrimaryInsetDark, offset: Offset(-6, -6), blur: 12),
  ];

  static const List<InsetShadow> buttonSecondary = [
    InsetShadow(color: AppColors.buttonSecondaryInsetLight, offset: Offset(6, 6), blur: 12),
    InsetShadow(color: AppColors.buttonSecondaryInsetDark, offset: Offset(-6, -6), blur: 12),
  ];
}
