import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/hive_datasource.dart';

enum AppThemeVariant { light, dark, retro, midnight, ocean, forest }

class ThemeCubit extends Cubit<AppThemeVariant> {
  final HiveDatasource _datasource;

  ThemeCubit({required HiveDatasource datasource})
      : _datasource = datasource,
        super(_load(datasource));

  static AppThemeVariant _load(HiveDatasource ds) {
    final index = ds.getThemeVariantIndex();
    return AppThemeVariant.values[index.clamp(0, AppThemeVariant.values.length - 1)];
  }

  void _set(AppThemeVariant v) {
    emit(v);
    _datasource.saveThemeVariantIndex(v.index);
  }

  void setLight() => _set(AppThemeVariant.light);
  void setDark() => _set(AppThemeVariant.dark);
  void setRetro() => _set(AppThemeVariant.retro);
  void setMidnight() => _set(AppThemeVariant.midnight);
  void setOcean() => _set(AppThemeVariant.ocean);
  void setForest() => _set(AppThemeVariant.forest);

  void cycle() {
    final next = AppThemeVariant.values[
        (state.index + 1) % AppThemeVariant.values.length];
    _set(next);
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
