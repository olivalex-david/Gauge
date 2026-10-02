import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/settings_controller.dart';
import 'controllers/workout_controller.dart';
import 'data/prefs/prefs_settings_repository.dart';
import 'data/settings_repository.dart';
import 'data/sqlite/app_database.dart';
import 'data/sqlite/sqlite_workout_repository.dart';
import 'data/workout_repository.dart';
import 'navigation/routes.dart';
import 'theme/app_theme.dart';

// `main` can be async so we can open the database before showing the app.
Future<void> main() async {
  // Plugins like sqflite talk to native iOS code through "platform channels",
  // which only exist once Flutter's engine binding is set up. runApp() would
  // do that for us, but we need the database *before* runApp, so we
  // initialize the binding manually first. Skip this and you get a
  // "Binding has not yet been initialized" error.
  WidgetsFlutterBinding.ensureInitialized();

  final db = await AppDatabase.open();

  // ⬇ The single place that decides where data lives. To use a REST API
  //   later: `final repository = ApiWorkoutRepository(httpClient);`
  //   To try the app without a database: `InMemoryWorkoutRepository()`.
  final WorkoutRepository repository = SqliteWorkoutRepository(db);

  // Read the saved theme *before* the first frame, so the app opens in the
  // right theme instead of flashing the default one first.
  final SettingsRepository settingsRepository = PrefsSettingsRepository();
  final themeMode = await settingsRepository.loadThemeMode();

  runApp(
    GaugeApp(
      repository: repository,
      settingsRepository: settingsRepository,
      initialThemeMode: themeMode,
    ),
  );
}

/// The root widget. Taking the repositories as parameters (instead of
/// creating them inside) is what lets tests pass in in-memory versions.
class GaugeApp extends StatelessWidget {
  const GaugeApp({
    super.key,
    required this.repository,
    required this.settingsRepository,
    this.initialThemeMode = ThemeMode.system,
  });

  final WorkoutRepository repository;
  final SettingsRepository settingsRepository;
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    // Placing the providers *above* MaterialApp makes the controllers
    // reachable from every screen, including ones pushed with Navigator later.
    // If one were inside a single screen, other routes couldn't find it and
    // you'd get a ProviderNotFoundException.
    //
    // MultiProvider is just a tidier way to nest several providers.
    return MultiProvider(
      providers: [
        // `create` runs once, lazily. The `..` cascade calls load() on the
        // new controller and still returns the controller itself. Provider
        // also calls dispose() on it automatically when it's removed.
        ChangeNotifierProvider(
          create: (_) => WorkoutController(repository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsController(
            settingsRepository,
            initialThemeMode: initialThemeMode,
          ),
        ),
      ],
      // Tricky: we can't call context.watch<SettingsController>() in this
      // build method. This `context` belongs to GaugeApp, which sits *above*
      // the MultiProvider, and lookups only search upward. Consumer is a
      // widget placed *below* the provider; its builder gets a context that
      // can find it, and it rebuilds MaterialApp when the theme changes.
      child: Consumer<SettingsController>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Gauge',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // system = follow the iPhone's setting; light/dark = force one.
          themeMode: settings.themeMode,
          initialRoute: Routes.home,
          routes: Routes.table,
        ),
      ),
    );
  }
}
