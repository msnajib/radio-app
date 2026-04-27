import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'radio_theme.dart';
import '../../bloc/theme/theme_cubit.dart';

export 'app_colors.dart';
export 'app_shadows.dart';
export 'app_typography.dart';
export 'radio_theme.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(AppColorTheme.light, Brightness.light);
  static ThemeData get dark => _build(AppColorTheme.dark, Brightness.dark);
  static ThemeData get retro => _build(AppColorTheme.retro, Brightness.light);
  static ThemeData get midnight => _build(AppColorTheme.midnight, Brightness.dark);
  static ThemeData get ocean => _build(AppColorTheme.ocean, Brightness.dark);
  static ThemeData get forest => _build(AppColorTheme.forest, Brightness.dark);

  static ThemeData forVariant(AppThemeVariant v) => switch (v) {
        AppThemeVariant.light => light,
        AppThemeVariant.dark => dark,
        AppThemeVariant.retro => retro,
        AppThemeVariant.midnight => midnight,
        AppThemeVariant.ocean => ocean,
        AppThemeVariant.forest => forest,
      };

  static ThemeData _build(AppColorTheme r, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: r.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        surface: r.background,
        primary: AppColors.buttonPrimaryBg,
        onPrimary: AppColors.buttonPrimaryText,
        onSurface: r.textPrimary,
        secondary: r.textSecondary,
        onSecondary: r.background,
        error: AppColors.dialNeedle,
        onError: AppColors.buttonPrimaryText,
        primaryContainer: r.surfaceSecondary,
        onPrimaryContainer: r.textPrimary,
        secondaryContainer: r.surfaceSecondary,
        onSecondaryContainer: r.textSecondary,
        surfaceContainerHighest: r.surfaceSecondary,
        onSurfaceVariant: r.textSecondary,
      ),
      textTheme: GoogleFonts.geistTextTheme().apply(
        bodyColor: r.textPrimary,
        displayColor: r.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: r.background,
        elevation: 0,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: r.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: r.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      extensions: [r],
    );
  }

  static void configureSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
}
