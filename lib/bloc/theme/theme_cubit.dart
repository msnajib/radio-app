import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppThemeVariant { light, dark, retro, midnight, ocean, forest }

class ThemeCubit extends Cubit<AppThemeVariant> {
  ThemeCubit() : super(AppThemeVariant.light);

  void setLight() => emit(AppThemeVariant.light);
  void setDark() => emit(AppThemeVariant.dark);
  void setRetro() => emit(AppThemeVariant.retro);
  void setMidnight() => emit(AppThemeVariant.midnight);
  void setOcean() => emit(AppThemeVariant.ocean);
  void setForest() => emit(AppThemeVariant.forest);

  void cycle() {
    final next = AppThemeVariant.values[
        (state.index + 1) % AppThemeVariant.values.length];
    emit(next);
  }

  Brightness get brightness {
    switch (state) {
      case AppThemeVariant.light:
      case AppThemeVariant.retro:
        return Brightness.light;
      default:
        return Brightness.dark;
    }
  }
}
