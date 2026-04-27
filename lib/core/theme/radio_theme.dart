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

  // ── Play/Pause button sphere ──────────────────────────────────────────────
  final Color btnPriRingLight;
  final Color btnPriRingDark;
  final Color btnPriBodyLight;
  final Color btnPriBodyMid;
  final Color btnPriBodyDark;
  final Color btnPriText;

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
    required this.btnPriRingLight,
    required this.btnPriRingDark,
    required this.btnPriBodyLight,
    required this.btnPriBodyMid,
    required this.btnPriBodyDark,
    required this.btnPriText,
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
    btnPriRingLight: Color(0xFF888888),
    btnPriRingDark: Color(0xFF242424),
    btnPriBodyLight: Color(0xFF4A4A4A),
    btnPriBodyMid: Color(0xFF1C1C1C),
    btnPriBodyDark: Color(0xFF080808),
    btnPriText: Color(0xFFFFFFFF),
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
    btnPriRingLight: Color(0xFF888888),
    btnPriRingDark: Color(0xFF242424),
    btnPriBodyLight: Color(0xFF4A4A4A),
    btnPriBodyMid: Color(0xFF1C1C1C),
    btnPriBodyDark: Color(0xFF080808),
    btnPriText: Color(0xFFFFFFFF),
    dialBackground: Color(0xFF0D0D0D),
    dialTick: Color(0xFF555555),
    dialTickMajor: Color(0xFFAAAAAA),
    dialGhostTick: Color(0x33AAAAAA),
    dialDeadZone: Color(0xFF1E1E1E),
  );

  // ── Retro/Warm ────────────────────────────────────────────────────────────
  // Scale: 50=#F5EDD0 · 100=#E8D4A8 · 200=#D4B878 · 300=#C4A060(bg)
  //        400=#A88040 · 500=#8A6428 · 600=#6C4A14 · 700=#503408
  //        800=#381E00 · 900=#221000
  static const AppColorTheme retro = AppColorTheme(
    background: Color(0xFFC4A060),         // 300
    textPrimary: Color(0xFF221000),         // 900
    textSecondary: Color(0xFF6C4A14),       // 600
    toggleBorder: Color(0xFF6C4A14),        // 600
    toggleSelectedBg: Color(0xFF6C4A14),    // 600
    toggleSelectedText: Color(0xFFF5EDD0),  // 50
    surfaceSecondary: Color(0xFFA88040),    // 400
    btnPriRingLight: Color(0xFFE8D4A8),     // 100
    btnPriRingDark: Color(0xFF503408),      // 700
    btnPriBodyLight: Color(0xFF8A6428),     // 500
    btnPriBodyMid: Color(0xFF6C4A14),       // 600
    btnPriBodyDark: Color(0xFF503408),      // 700
    btnPriText: Color(0xFFF5EDD0),          // 50
    dialBackground: Color(0xFFF5EDD0),      // 50
    dialTick: Color(0xFF8A6428),            // 500
    dialTickMajor: Color(0xFF503408),       // 700
    dialGhostTick: Color(0x33503408),       // 700 @ 20%
    dialDeadZone: Color(0xFFA88040),        // 400
  );

  // ── Midnight ──────────────────────────────────────────────────────────────
  // Scale: 50=#FFF3D0 · 100=#F8D890 · 200=#F0A030(text) · 300=#C07818
  //        400=#9A6010 · 500=#6A3C08 · 600=#3C1E00 · 700=#1A0800
  //        bg=#000000
  static const AppColorTheme midnight = AppColorTheme(
    background: Color(0xFF000000),         // OLED black
    textPrimary: Color(0xFFF0A030),         // 200 — amber glow
    textSecondary: Color(0xFFC07818),       // 300
    toggleBorder: Color(0xFFC07818),        // 300
    toggleSelectedBg: Color(0xFFF0A030),    // 200
    toggleSelectedText: Color(0xFF000000),  // bg
    surfaceSecondary: Color(0xFF1A0800),    // 700
    btnPriRingLight: Color(0xFFF8D890),     // 100
    btnPriRingDark: Color(0xFF3C1E00),      // 600
    btnPriBodyLight: Color(0xFFC07818),     // 300
    btnPriBodyMid: Color(0xFF9A6010),       // 400
    btnPriBodyDark: Color(0xFF6A3C08),      // 500
    btnPriText: Color(0xFFFFF3D0),          // 50
    dialBackground: Color(0xFF0D0800),      // near-black amber
    dialTick: Color(0xFF9A6010),            // 400
    dialTickMajor: Color(0xFFF0A030),       // 200 — glowing major ticks
    dialGhostTick: Color(0x33F0A030),       // 200 @ 20%
    dialDeadZone: Color(0xFF1A0800),        // 700
  );

  // ── Ocean ─────────────────────────────────────────────────────────────────
  // Scale: 50=#E0F8FF · 100=#88D8EE · 200=#3AAFE0 · 300=#1A80A8
  //        400=#0E5070 · 500=#083040 · 600=#041C28 · 700=#021018
  //        bg=#04161E
  static const AppColorTheme ocean = AppColorTheme(
    background: Color(0xFF04161E),         // deep navy
    textPrimary: Color(0xFF88D8EE),         // 100
    textSecondary: Color(0xFF3AAFE0),       // 200
    toggleBorder: Color(0xFF1A80A8),        // 300
    toggleSelectedBg: Color(0xFF1A80A8),    // 300
    toggleSelectedText: Color(0xFFE0F8FF),  // 50
    surfaceSecondary: Color(0xFF0A2030),    // between 500-600
    btnPriRingLight: Color(0xFF3AAFE0),     // 200
    btnPriRingDark: Color(0xFF083040),      // 500
    btnPriBodyLight: Color(0xFF1A80A8),     // 300
    btnPriBodyMid: Color(0xFF0E5070),       // 400
    btnPriBodyDark: Color(0xFF083040),      // 500
    btnPriText: Color(0xFFE0F8FF),          // 50
    dialBackground: Color(0xFF081828),      // dark navy dial
    dialTick: Color(0xFF1A80A8),            // 300
    dialTickMajor: Color(0xFF3AAFE0),       // 200
    dialGhostTick: Color(0x333AAFE0),       // 200 @ 20%
    dialDeadZone: Color(0xFF0A2030),        // surface
  );

  // ── Forest ────────────────────────────────────────────────────────────────
  // Scale: 50=#F0EED0 · 100=#D4D090 · 200=#A8A840 · 300=#787820
  //        400=#505010 · 500=#303010 · 600=#1E2008(bg) · 700=#121400
  static const AppColorTheme forest = AppColorTheme(
    background: Color(0xFF1E2008),         // dark olive
    textPrimary: Color(0xFFD4D090),         // 100
    textSecondary: Color(0xFFA8A840),       // 200
    toggleBorder: Color(0xFF787820),        // 300
    toggleSelectedBg: Color(0xFF787820),    // 300
    toggleSelectedText: Color(0xFFF0EED0),  // 50
    surfaceSecondary: Color(0xFF303010),    // 500
    btnPriRingLight: Color(0xFFA8A840),     // 200
    btnPriRingDark: Color(0xFF303010),      // 500
    btnPriBodyLight: Color(0xFF787820),     // 300
    btnPriBodyMid: Color(0xFF505010),       // 400
    btnPriBodyDark: Color(0xFF303010),      // 500
    btnPriText: Color(0xFFF0EED0),          // 50
    dialBackground: Color(0xFFF0EED0),      // 50 — cream dial face
    dialTick: Color(0xFF787820),            // 300
    dialTickMajor: Color(0xFFA8A840),       // 200
    dialGhostTick: Color(0x33A8A840),       // 200 @ 20%
    dialDeadZone: Color(0xFF303010),        // 500
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
    Color? btnPriRingLight,
    Color? btnPriRingDark,
    Color? btnPriBodyLight,
    Color? btnPriBodyMid,
    Color? btnPriBodyDark,
    Color? btnPriText,
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
      btnPriRingLight: btnPriRingLight ?? this.btnPriRingLight,
      btnPriRingDark: btnPriRingDark ?? this.btnPriRingDark,
      btnPriBodyLight: btnPriBodyLight ?? this.btnPriBodyLight,
      btnPriBodyMid: btnPriBodyMid ?? this.btnPriBodyMid,
      btnPriBodyDark: btnPriBodyDark ?? this.btnPriBodyDark,
      btnPriText: btnPriText ?? this.btnPriText,
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
      btnPriRingLight: Color.lerp(btnPriRingLight, other.btnPriRingLight, t)!,
      btnPriRingDark: Color.lerp(btnPriRingDark, other.btnPriRingDark, t)!,
      btnPriBodyLight: Color.lerp(btnPriBodyLight, other.btnPriBodyLight, t)!,
      btnPriBodyMid: Color.lerp(btnPriBodyMid, other.btnPriBodyMid, t)!,
      btnPriBodyDark: Color.lerp(btnPriBodyDark, other.btnPriBodyDark, t)!,
      btnPriText: Color.lerp(btnPriText, other.btnPriText, t)!,
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
