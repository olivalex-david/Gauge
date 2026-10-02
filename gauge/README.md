# Gauge

A gym workout tracker built with Flutter. It's also a learning project, so tricky
parts of the code have inline comments explaining *why*.

## Run it

```
flutter pub get
flutter run        # pick the iOS simulator
flutter test       # widget tests (use the in-memory repository, no SQLite)
```

## How the code is organised

```
lib/
  main.dart                     App entry: opens the DB, picks the repository, sets up Provider
  models/workout.dart           Immutable data class + toMap/fromMap
  data/
    workout_repository.dart     Abstract interface — the "API agnostic" seam
    sqlite/                     SQLite implementation + schema/migrations
    memory/                     In-memory implementation (tests, quick experiments)
  controllers/                  ChangeNotifier state holders the UI listens to
  navigation/                   Sidebar (Drawer) + named routes
  screens/                      One file per screen
```

Data flows one way:

```
Screen ──context.read──▶ Controller ──▶ WorkoutRepository (interface)
  ▲                          │                 ├─ SqliteWorkoutRepository  (now)
  └──context.watch───────────┘                 ├─ InMemoryWorkoutRepository (tests)
     (rebuild on notifyListeners)              └─ ApiWorkoutRepository      (later)
```

To switch from SQLite to a REST API, write a class that `implements
WorkoutRepository` and change the single line in `main.dart` that creates the
repository. Screens and controllers stay as they are.

## Adding the next feature (Plans, Calendar, Goals…)

Every feature follows the same recipe:

1. **Model**: `lib/models/goal.dart` (copy the shape of `workout.dart`).
2. **Repository interface + SQLite impl**: add the table in
   `app_database.dart` and **bump `_version` and add an `onUpgrade` step**.
3. **Controller**: a `ChangeNotifier` like `WorkoutController`.
4. **Provide it**: switch `ChangeNotifierProvider` in `main.dart` to a
   `MultiProvider` with one entry per controller.
5. **Screen + route**: add it to `Routes.table` and one line in the drawer's
   `_destinations` list. Replace the Goals `PlaceholderScreen` when it's ready.

Ideas: exercises and sets inside a workout (a second table with a
`workout_id` foreign key), a calendar view (`table_calendar` package), and
weekly goals computed from workout history.
