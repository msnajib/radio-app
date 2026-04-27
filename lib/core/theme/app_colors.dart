import 'package:flutter/material.dart';

abstract final class AppColors {
  // Base
  static const Color background = Color(0xFFEFF1F2);

  // Text
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF4E4E4E);

  // Button primary — dark pill
  static const Color buttonPrimaryBg = Color(0xFF333333);
  static const Color buttonPrimaryText = Color(0xFFFFFFFF);
  static const Color buttonPrimaryInset2 = Color(0xFF1E1E1E);

  // Button secondary — neutral gray pill
  static const Color buttonSecondaryBg = Color(0xFFE2E2E2);

  // FM/AM toggle
  static const Color toggleBorder = Color(0xFF1C1C1C);
  static const Color toggleSelectedBg = Color(0xFF333333);
  static const Color toggleSelectedText = Color(0xFFEFF1F2);
  static const Color toggleUnselectedText = Color(0xFF1C1C1C);

  // Knob
  static const Color knobBorder = Color(0xFFD4D4D4);

  // Dial
  static const Color dialTick = Color(0xFF4E4E4E);
  static const Color dialTickMajor = Color(0xFF1C1C1C);
  static const Color dialLabel = Color(0xFF1C1C1C);
  static const Color dialNeedle = Color(0xFFE53935);
  static const Color dialDeadZone = Color(0xFFD6DEE1);
}
