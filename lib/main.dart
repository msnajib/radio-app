import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/analytics_service.dart';
import 'core/services/sfx_service.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/hive_datasource.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.configureSystemUI();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final hive = HiveDatasource();
  await hive.init();

  final sfx = SfxService();
  await sfx.init();

  final analytics = AnalyticsService();

  runApp(RadioApp(hiveDatasource: hive, sfxService: sfx, analytics: analytics));
}
