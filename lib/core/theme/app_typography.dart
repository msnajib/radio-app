import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Typography defines font metrics only — no colors.
// Apply colors at widget level via .copyWith(color: context.radioTheme.xxx).
abstract final class AppTypography {
  static TextStyle get appTitle => GoogleFonts.geist(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  static TextStyle get frequencyLarge => GoogleFonts.geistMono(
    fontSize: 64,
    fontWeight: FontWeight.w800,
    height: 1.0,
    letterSpacing: -1,
  );

  static TextStyle get stationName => GoogleFonts.geist(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  // bandLabel has no color — toggle applies it via copyWith
  static TextStyle get bandLabel => GoogleFonts.geist(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonLabel => GoogleFonts.geist(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  // dialLabel color is applied by _DialPainter using the active RadioTheme
  static TextStyle get dialLabel => GoogleFonts.geistMono(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static TextStyle get body => GoogleFonts.geist(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get bodySmall => GoogleFonts.geist(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
