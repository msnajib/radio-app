import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  // Title "Radio" — Geist Bold 24px
  static TextStyle get appTitle => GoogleFonts.geist(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  // Frequency display — Geist Mono ExtraBold 64px
  static TextStyle get frequencyLarge => GoogleFonts.geistMono(
    fontSize: 64,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1,
  );

  // Station name — Geist Regular 12px, uppercase
  static TextStyle get stationName => GoogleFonts.geist(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // FM/AM toggle label — Geist Bold 12px
  static TextStyle get bandLabel => GoogleFonts.geist(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  // Play button label — Geist Bold 14px
  static TextStyle get buttonLabel => GoogleFonts.geist(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.buttonPrimaryText,
  );

  // Dial tick label — Geist Mono Medium 10px
  static TextStyle get dialLabel => GoogleFonts.geistMono(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.dialLabel,
    letterSpacing: 0.2,
  );

  // Body
  static TextStyle get body => GoogleFonts.geist(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.geist(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
