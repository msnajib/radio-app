import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/sfx_service.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/hive_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.configureSystemUI();

  final hive = HiveDatasource();
  await hive.init();

  final sfx = SfxService();
  await sfx.init();

  runApp(RadioApp(hiveDatasource: hive, sfxService: sfx));
}
