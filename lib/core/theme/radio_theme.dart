import 'package:flutter/material.dart';

@immutable
class AppColorTheme extends ThemeExtension<AppColorTheme> {
  // ── Base ──────────────────────────────────────────────────────────────────
  final Color background;
  final Color textPrimary;
  final Color textSecondary;

  // ── FM/AM Toggle ──────────────────────────────────────────────────────────
  final Color toggleBorder;
  final Color toggleSelectedBg;
  final Color toggleSelectedText;

  // ── Surfaces (bottom sheets, chips) ──────────────────────────────────────
  final Color surfaceSecondary;

  // ── Dial ──────────────────────────────────────────────────────────────────
  final Color dialBackground;
  final Color dialTick;
  final Color dialTickMajor;
  final Color dialGhostTick;
  final Color dialDeadZone;

  const AppColorTheme({
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.toggleBorder,
    required this.toggleSelectedBg,
    required this.toggleSelectedText,
    required this.surfaceSecondary,
    required this.dialBackground,
    required this.dialTick,
    required this.dialTickMajor,
    required this.dialGhostTick,
    required this.dialDeadZone,
  });

  // ── Light ─────────────────────────────────────────────────────────────────
  static const AppColorTheme light = AppColorTheme(
    background: Color(0xFFEFF1F2),
    textPrimary: Color(0xFF333333),
    textSecondary: Color(0xFF4E4E4E),
    toggleBorder: Color(0xFF1C1C1C),
    toggleSelectedBg: Color(0xFF333333),
    toggleSelectedText: Color(0xFFEFF1F2),
    surfaceSecondary: Color(0xFFE2E2E2),
    dialBackground: Color(0xFFFFFFFF),
    dialTick: Color(0xFF4E4E4E),
    dialTickMajor: Color(0xFF1C1C1C),
    dialGhostTick: Color(0x331C1C1C),
    dialDeadZone: Color(0xFFD6DEE1),
  );

  // ── Dark ──────────────────────────────────────────────────────────────────
  static const AppColorTheme dark = AppColorTheme(
    background: Color(0xFF0D0D0D),
    textPrimary: Color(0xFFE8E8E8),
    textSecondary: Color(0xFF888888),
    toggleBorder: Color(0xFF444444),
    toggleSelectedBg: Color(0xFFE8E8E8),
    toggleSelectedText: Color(0xFF0D0D0D),
    surfaceSecondary: Color(0xFF2A2A2A),
    dialBackground: Color(0xFF0D0D0D),
    dialTick: Color(0xFF555555),
    dialTickMajor: Color(0xFFAAAAAA),
    dialGhostTick: Color(0x33AAAAAA),
    dialDeadZone: Color(0xFF1E1E1E),
  );

  // ── Access ────────────────────────────────────────────────────────────────
  static AppColorTheme of(BuildContext context) =>
      Theme.of(context).extension<AppColorTheme>()!;

  // ── ThemeExtension ────────────────────────────────────────────────────────
  @override
  AppColorTheme copyWith({
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    Color? toggleBorder,
    Color? toggleSelectedBg,
    Color? toggleSelectedText,
    Color? surfaceSecondary,
    Color? dialBackground,
    Color? dialTick,
    Color? dialTickMajor,
    Color? dialGhostTick,
    Color? dialDeadZone,
  }) {
    return AppColorTheme(
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      toggleBorder: toggleBorder ?? this.toggleBorder,
      toggleSelectedBg: toggleSelectedBg ?? this.toggleSelectedBg,
      toggleSelectedText: toggleSelectedText ?? this.toggleSelectedText,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      dialBackground: dialBackground ?? this.dialBackground,
      dialTick: dialTick ?? this.dialTick,
      dialTickMajor: dialTickMajor ?? this.dialTickMajor,
      dialGhostTick: dialGhostTick ?? this.dialGhostTick,
      dialDeadZone: dialDeadZone ?? this.dialDeadZone,
    );
  }

  @override
  AppColorTheme lerp(AppColorTheme? other, double t) {
    if (other == null) return this;
    return AppColorTheme(
      background: Color.lerp(background, other.background, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      toggleBorder: Color.lerp(toggleBorder, other.toggleBorder, t)!,
      toggleSelectedBg: Color.lerp(toggleSelectedBg, other.toggleSelectedBg, t)!,
      toggleSelectedText: Color.lerp(toggleSelectedText, other.toggleSelectedText, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      dialBackground: Color.lerp(dialBackground, other.dialBackground, t)!,
      dialTick: Color.lerp(dialTick, other.dialTick, t)!,
      dialTickMajor: Color.lerp(dialTickMajor, other.dialTickMajor, t)!,
      dialGhostTick: Color.lerp(dialGhostTick, other.dialGhostTick, t)!,
      dialDeadZone: Color.lerp(dialDeadZone, other.dialDeadZone, t)!,
    );
  }
}

extension RadioThemeContext on BuildContext {
  AppColorTheme get radioTheme => AppColorTheme.of(this);
}
