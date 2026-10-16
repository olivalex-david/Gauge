import 'package:sqflite/sqflite.dart';

import '../../models/workout.dart';
import '../workout_repository.dart';

/// [WorkoutRepository] backed by a local SQLite database.
class SqliteWorkoutRepository implements WorkoutRepository {
  // The database is passed in ("dependency injection") rather than opened
  // here, so several repositories can share one connection.
  SqliteWorkoutRepository(this._db);

  final Database _db;
  static const _table = 'workouts';

  @override
  Future<List<Workout>> getAll() async {
    final rows = await _db.query(_table, orderBy: 'date DESC');
    return rows.map(Workout.fromMap).toList();
  }

  @override
  Future<Workout?> getById(int id) async {
    // Always use `where` + `whereArgs` (the `?` placeholder) instead of
    // building the SQL string yourself like 'id = $id'. sqflite escapes the
    // arguments for you, which prevents SQL injection and quoting bugs.
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Workout.fromMap(rows.first);
  }

  @override
  Future<Workout> create(Workout workout) async {
    // Remove 'id' so SQLite's AUTOINCREMENT picks one. insert() returns the
    // new row id, which we copy back onto the model.
    final values = workout.toMap()..remove('id');
    final id = await _db.insert(_table, values);
    return workout.copyWith(id: id);
  }

  @override
  Future<void> update(Workout workout) async {
    await _db.update(
      _table,
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
