import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens the SQLite database file and creates/migrates the schema.
///
/// One `Database` instance is shared by all SQLite repositories (workouts, plans,
/// goals later), so each new feature just adds a table here.
class AppDatabase {
  static const _fileName = 'gauge.db';

  /// Bump this whenever the schema changes, and add the matching step to
  /// [_onUpgrade]. SQLite remembers the version stored on the user's device:
  /// `onCreate` only runs on a fresh install, so existing users only get new
  /// tables/columns through `onUpgrade`. Forgetting this is a classic bug —
  /// the app works on your freshly installed simulator but crashes for users.
  static const _version = 2;

  // Shared by _onCreate and _onUpgrade so both create the exact same table.
  static const _createPlansTable = '''
    CREATE TABLE plans (
      id   INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT    NOT NULL
    )
  ''';

  static Future<Database> open() async {
    // getDatabasesPath() returns the platform-specific folder where apps are
    // allowed to store databases (on iOS, inside the app's sandbox).
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, _fileName),
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        name             TEXT    NOT NULL,
        date             INTEGER NOT NULL,
        duration_minutes INTEGER NOT NULL,
        notes            TEXT    NOT NULL DEFAULT ''
      )
    ''');
    await db.execute(_createPlansTable);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(_createPlansTable);
    }

    // Using `if (oldVersion < N)` blocks (not `else if`) lets a user who skipped
    // several app updates run every missing migration in order.
  }
}
