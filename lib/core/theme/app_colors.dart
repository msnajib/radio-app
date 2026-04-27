import 'package:flutter/material.dart';

// Static light-theme constants — used by AppTypography and AppTheme internals.
// For runtime-switchable colors in widgets, use RadioTheme.of(context) instead.
abstract final class AppColors {
  static const Color background = Color(0xFFEFF1F2);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF4E4E4E);
  static const Color buttonPrimaryBg = Color(0xFF333333);
  static const Color buttonPrimaryText = Color(0xFFFFFFFF);
  static const Color buttonSecondaryBg = Color(0xFFE2E2E2);
  static const Color toggleBorder = Color(0xFF1C1C1C);
  static const Color toggleSelectedBg = Color(0xFF333333);
  static const Color toggleSelectedText = Color(0xFFEFF1F2);
  static const Color knobBorder = Color(0xFFD4D4D4);

  // Sphere button
  static const Color buttonPrimaryRingLight = Color(0xFF888888);
  static const Color buttonPrimaryRingDark = Color(0xFF242424);
  static const Color buttonPrimaryBodyLight = Color(0xFF4A4A4A);
  static const Color buttonPrimaryBodyMid = Color(0xFF1C1C1C);
  static const Color buttonPrimaryBodyDark = Color(0xFF080808);
  static const Color buttonSecondaryRingLight = Color(0xFFEEEEEE);
  static const Color buttonSecondaryRingDark = Color(0xFF8A8A8A);
  static const Color buttonSecondaryBodyLight = Color(0xFFF8F8F8);
  static const Color buttonSecondaryBodyMid = Color(0xFFD4D4D4);
  static const Color buttonSecondaryBodyDark = Color(0xFF8E8E8E);
  static const Color buttonPrimaryInsetLight = Color(0xFF3E3E3E);
  static const Color buttonPrimaryInsetDark = Color(0xFF1E1E1E);
  static const Color buttonSecondaryInsetLight = Color(0xFFE2E2E2);
  static const Color buttonSecondaryInsetDark = Color(0xFFABABAB);

  // Small knob
  static const Color knobGradientLight = Color(0xFFEEEEEE);
  static const Color knobGradientDark = Color(0xFF454545);

  // Dial
  static const Color dialBackground = Color(0xFFFFFFFF);
  static const Color dialTick = Color(0xFF4E4E4E);
  static const Color dialTickMajor = Color(0xFF1C1C1C);
  static const Color dialGhostTick = Color(0x331C1C1C);
  static const Color dialNeedle = Color(0xFFE53935);
  static const Color dialDeadZone = Color(0xFFD6DEE1);

  // Large knob chrome
  static const Color knobChromeShadow = Color(0x44000000);
  static const Color knobChromeTop = Color(0xFFF6F6F6);
  static const Color knobChromeMid1 = Color(0xFFD2D2D2);
  static const Color knobChromeMid2 = Color(0xFF909090);
  static const Color knobChromeEdge = Color(0xFF565656);
  static const Color knobChromeAccentShadow = Color(0xFFCFC9C9);
  static const Color knobChromeAccentHighlight = Color(0xFFE8E8E8);
  static const Color knobChromeGrip = Color(0xFFC8C8C8);
  static const Color knobChromeSepShadow = Color(0xFF888888);
  static const Color knobChromeSepHighlight = Color(0xFFE2E2E2);
  static const Color knobChromeSpecular = Color(0x44FFFFFF);
  static const Color knobChromeBorder = Color(0xFF787878);
}
