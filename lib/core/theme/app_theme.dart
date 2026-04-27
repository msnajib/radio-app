import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

export 'app_colors.dart';
export 'app_shadows.dart';
export 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        surface: AppColors.background,
        primary: AppColors.buttonPrimaryBg,
        onPrimary: AppColors.buttonPrimaryText,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.geistTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static void configureSystemUI() {
    // edgeToEdge: Scaffold background (#EFF1F2) renders behind the status bar,
    // so the status bar area naturally matches the screen background.
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
