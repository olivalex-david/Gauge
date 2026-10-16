# Models

A model is a plain Dart class describing one kind of thing the app stores, like
a `Workout`. Models know nothing about SQLite, the network, or widgets. They
hold data and convert themselves to and from a `Map`. Everything else
(repositories, controllers, screens) is built around them.

Every model here follows the same rules:

- **Immutable.** All fields are `final`. To change one, make a copy with
  `copyWith`. This guarantees nothing changes behind a controller's back.
- **`id` is nullable.** It's `null` until the model is saved; the storage layer
  assigns it.
- **`toMap()` / `fromMap()`** convert to and from the primitive types SQLite
  and JSON understand (`int`, `String`, `double`, `null`). For example, a
  `DateTime` is stored as milliseconds since epoch (`int`).

Use [`workout.dart`](workout.dart) as the reference example.

---

## Changing an existing model

Example: adding a `category` field to `Workout`.

### 1. The model class ([`workout.dart`](workout.dart))

Add the field in **all five** places. Forgetting one fails silently, without
any error:

| Place | Add | If you forget it |
|---|---|---|
| Field | `final String category;` | — |
| Constructor | `this.category = 'Strength',` | — |
| `copyWith` | `String? category` param + `category: category ?? this.category` | Editing a workout resets the field to its default |
| `toMap` | `'category': category,` | The value is never saved |
| `fromMap` | `category: (map['category'] as String?) ?? 'Strength',` | The value is never read back |

Give new fields a **default value** in the constructor. That way existing code
and tests that build a `Workout` without the field keep compiling.

### 2. The database schema ([`../data/sqlite/app_database.dart`](../data/sqlite/app_database.dart))

This is the step everyone forgets. Devices that already have the app have a
`gauge.db` with the **old** table shape. `onCreate` only runs on a fresh
install, so you have to change three things:

```dart
// a) Bump the version (1 → 2).
static const _version = 2;

// b) In _onCreate: add the column, for brand-new installs.
//      category TEXT NOT NULL DEFAULT 'Strength'

// c) In _onUpgrade: add it for existing installs.
if (oldVersion < 2) {
  await db.execute(
    "ALTER TABLE workouts ADD COLUMN category TEXT NOT NULL DEFAULT 'Strength'",
  );
}
```

- Skip (c) and the app crashes on save with
  `table workouts has no column named category`.
- The `DEFAULT` fills in a value for rows that already exist.
- Never edit or delete an old `if (oldVersion < N)` block once it has shipped.
  Always add a new one below it, so a user who skipped several updates runs
  every step in order.
- **Renaming or removing** a column is harder in SQLite: create a new table,
  copy the data across, drop the old one. Prefer adding new columns while
  you're learning.

### 3. The UI

- **Form** ([`../screens/workout_form_screen.dart`](../screens/workout_form_screen.dart)):
  add an input, and pass its value into `copyWith(...)` in `_save()`.
- **Display** ([`../screens/workouts_screen.dart`](../screens/workouts_screen.dart)):
  show it wherever it's useful, such as the list tile subtitle.

### What you *don't* need to touch

- **Repositories and controllers.** They pass whole `Workout` objects around
  and never look at individual fields.
- **The in-memory repository.** It stores `Workout` objects directly, with no
  maps or tables.

### Try it

`toMap`, `fromMap` and migrations only take effect on startup. Press **`R`**
(hot restart), not `r`, then run `flutter test`.

---

## Creating a new model

Example: a `Goal` (e.g. "Work out 3 times a week"). A new model touches every
layer once, and each layer has an existing file you can copy.

```
models/goal.dart                          ← 1. the data
data/goal_repository.dart                 ← 2. the interface (API agnostic)
data/sqlite/sqlite_goal_repository.dart   ← 3. SQLite implementation
data/sqlite/app_database.dart             ← 3. new table + migration
data/memory/in_memory_goal_repository.dart← 4. in-memory implementation (tests)
controllers/goal_controller.dart          ← 5. state
main.dart                                 ← 6. wire it up
screens/goals_screen.dart + routes        ← 7. UI
```

### 1. Model: `models/goal.dart`

Copy `workout.dart` and rename. Keep the same structure: `final` fields,
nullable `id`, `copyWith`, `toMap`, `fromMap`.

```dart
class Goal {
  const Goal({this.id, required this.title, required this.targetPerWeek});

  final int? id;
  final String title;
  final int targetPerWeek;

  // copyWith, toMap, fromMap: same pattern as Workout.
}
```

Storing a `bool`? SQLite has no boolean type, so store `1`/`0` as an
`INTEGER` and convert in `toMap`/`fromMap`.

### 2. Repository interface: `data/goal_repository.dart`

Copy [`workout_repository.dart`](../data/workout_repository.dart). Keep every
method returning a `Future`, so an API version can be added later without
changing callers.

### 3. SQLite implementation + table

- Copy [`sqlite_workout_repository.dart`](../data/sqlite/sqlite_workout_repository.dart),
  change `_table` to `'goals'` and the types to `Goal`.
- In [`app_database.dart`](../data/sqlite/app_database.dart), bump `_version`
  and add the table in **both** places:

  ```dart
  // _onCreate (fresh installs): add after the workouts table
  await db.execute('CREATE TABLE goals (...)');

  // _onUpgrade (existing installs)
  if (oldVersion < 2) {
    await db.execute('CREATE TABLE goals (...)');
  }
  ```

  Tip: put the `CREATE TABLE` SQL in a `static const` string so both places use
  the exact same definition.

- **Linking models?** If a goal belongs to a workout (or sets belong to a
  workout), add a `workout_id INTEGER NOT NULL REFERENCES workouts(id)` column.
  The Dart model just gets an `int workoutId` field.

### 4. In-memory implementation

Copy [`in_memory_workout_repository.dart`](../data/memory/in_memory_workout_repository.dart).
Tests use it, so they never need a real database.

### 5. Controller: `controllers/goal_controller.dart`

Copy [`workout_controller.dart`](../controllers/workout_controller.dart): a
`ChangeNotifier` that keeps an unmodifiable list, a loading flag and an error,
and calls the repository. Remember `notifyListeners()` after every state change.

### 6. Wire it up in [`main.dart`](../main.dart)

1. Create the repository in `main()`, next to the workout one:
   `final GoalRepository goalRepository = SqliteGoalRepository(db);`
2. Add a `goalRepository` parameter to `GaugeApp` and pass it in.
3. Add a provider to the `MultiProvider` list:

   ```dart
   ChangeNotifierProvider(create: (_) => GoalController(goalRepository)..load()),
   ```

4. Update the `GaugeApp(...)` calls in `test/widget_test.dart` to pass
   `InMemoryGoalRepository()`.

### 7. UI

- Create `screens/goals_screen.dart`, using
  [`workouts_screen.dart`](../screens/workouts_screen.dart) as a template.
- In [`routes.dart`](../navigation/routes.dart), point the `goals` route at the
  new screen instead of `PlaceholderScreen`.
- To add a brand-new sidebar entry, add a route constant there and a
  `_Destination` line in [`app_drawer.dart`](../navigation/app_drawer.dart).

---

## Checklist

**Changing a model**

- [ ] Field, constructor (with default), `copyWith`, `toMap`, `fromMap`
- [ ] Bump `_version`, update `_onCreate`, add an `_onUpgrade` step
- [ ] Form + display updated
- [ ] Hot restart (`R`), `flutter test`

**New model**

- [ ] Model class
- [ ] Repository interface
- [ ] SQLite implementation + table in `_onCreate` **and** `_onUpgrade` + version bump
- [ ] In-memory implementation
- [ ] Controller
- [ ] Repository created in `main()`, `GaugeApp` parameter, provider added
- [ ] Tests updated to pass the in-memory repository
- [ ] Screen, route, sidebar entry
- [ ] Hot restart (`R`), `flutter analyze`, `flutter test`
