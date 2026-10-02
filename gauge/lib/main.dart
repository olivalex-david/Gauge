import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/workout_controller.dart';
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

  runApp(GaugeApp(repository: repository));
}

/// The root widget. Taking the repository as a parameter (instead of creating
/// it inside) is what lets tests pass in an in-memory version.
class GaugeApp extends StatelessWidget {
  const GaugeApp({super.key, required this.repository});

  final WorkoutRepository repository;

  @override
  Widget build(BuildContext context) {
    // Placing the provider *above* MaterialApp makes the controller reachable
    // from every screen, including ones pushed with Navigator later. If it
    // were inside a single screen, other routes couldn't find it and you'd
    // get a ProviderNotFoundException.
    return ChangeNotifierProvider(
      // `create` runs once, lazily. The `..` cascade calls load() on the new
      // controller and still returns the controller itself. Provider also
      // calls dispose() on it automatically when it's removed.
      create: (_) => WorkoutController(repository)..load(),
      child: MaterialApp(
        title: 'Gauge',
        // Both themes are given; iOS's light/dark setting picks one
        // automatically (themeMode defaults to ThemeMode.system).
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        initialRoute: Routes.home,
        routes: Routes.table,
      ),
    );
  }
}
