import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/dial/dial_bloc.dart';
import 'bloc/favorites/favorites_bloc.dart';
import 'bloc/favorites/favorites_event.dart';
import 'bloc/radio/radio_bloc.dart';
import 'bloc/radio/radio_event.dart';
import 'bloc/sleep_timer/sleep_timer_bloc.dart';
import 'bloc/theme/theme_cubit.dart';
import 'core/services/sfx_service.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/hive_datasource.dart';
import 'data/repositories/favorite_repository.dart';
import 'data/repositories/radio_browser_repository.dart';
import 'ui/screens/home_screen.dart';

class RadioApp extends StatelessWidget {
  final HiveDatasource hiveDatasource;
  final SfxService sfxService;

  const RadioApp({
    super.key,
    required this.hiveDatasource,
    required this.sfxService,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteRepo = FavoriteRepository(datasource: hiveDatasource);
    final radioRepo = RadioBrowserRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: radioRepo),
        RepositoryProvider.value(value: favoriteRepo),
        RepositoryProvider.value(value: sfxService),
      ],
      child: MultiBlocProvider(
        providers: [
          // BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => ThemeCubit()..setDark()),
          BlocProvider(create: (_) => DialBloc(datasource: hiveDatasource)),
          BlocProvider(
            create: (_) =>
                RadioBloc(repository: radioRepo)..add(const RadioInitialized()),
          ),
          BlocProvider(
            create: (_) =>
                FavoritesBloc(repository: favoriteRepo)
                  ..add(const FavoritesLoaded()),
          ),
          BlocProvider(create: (_) => SleepTimerBloc()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'Radio',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}
