import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge/data/memory/in_memory_settings_repository.dart';
import 'package:gauge/data/memory/in_memory_workout_repository.dart';
import 'package:gauge/main.dart';
import 'package:gauge/models/workout.dart';

void main() {
  // The in-memory repository means tests need no SQLite plugin — the payoff
  // of depending on the WorkoutRepository interface.
  testWidgets('logging a workout shows it in the list', (tester) async {
    await tester.pumpWidget(
      GaugeApp(
        repository: InMemoryWorkoutRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    // pumpAndSettle keeps rendering frames until animations and pending
    // futures (like the initial load()) have finished.
    await tester.pumpAndSettle();

    // Open the sidebar and go to Workouts.
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(
      // "Workouts" also appears on a Home stat card, so look only inside the
      // drawer.
      find.descendant(
        of: find.byType(NavigationDrawer),
        matching: find.text('Workouts'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No workouts yet. Tap + to log one.'), findsOneWidget);

    // Fill in and save the form.
    await tester.tap(find.text('Log workout'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Leg day',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Duration (minutes)'),
      '45',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Leg day'), findsOneWidget);
  });

  testWidgets('form rejects an empty name', (tester) async {
    await tester.pumpWidget(
      GaugeApp(
        repository: InMemoryWorkoutRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(
      // "Workouts" also appears on a Home stat card, so look only inside the
      // drawer.
      find.descendant(
        of: find.byType(NavigationDrawer),
        matching: find.text('Workouts'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Give the workout a name'), findsOneWidget);
  });

  testWidgets('home dashboard reflects existing workouts', (tester) async {
    final repo = InMemoryWorkoutRepository([
      Workout(
        name: 'Pull day',
        date: DateTime(2026, 9, 30),
        durationMinutes: 50,
      ),
      Workout(name: 'Run', date: DateTime(2026, 10, 1), durationMinutes: 30),
    ]);
    await tester.pumpWidget(
      GaugeApp(
        repository: repo,
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget); // workout count
    expect(find.text('80'), findsOneWidget); // total minutes
    expect(find.textContaining('Run'), findsOneWidget); // latest by date
  });

  testWidgets('choosing Dark in settings switches and saves the theme', (
    tester,
  ) async {
    final settings = InMemorySettingsRepository();
    await tester.pumpWidget(
      GaugeApp(
        repository: InMemoryWorkoutRepository(),
        settingsRepository: settings,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(settings.themeMode, ThemeMode.dark); // It was saved, too.
  });
}
