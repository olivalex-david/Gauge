import 'package:sqflite/sqflite.dart';

import '../../models/plan.dart';
import '../plan_repository.dart';

/// [PlanRepository] backed by a local SQLite database. Same pattern as
/// `SqliteWorkoutRepository`.
class SqlitePlanRepository implements PlanRepository {
  SqlitePlanRepository(this._db);

  final Database _db;
  static const _table = 'plans';

  @override
  Future<List<Plan>> getAll() async {
    // COLLATE NOCASE sorts "abs" next to "Arms" instead of after every
    // capitalised name.
    final rows = await _db.query(_table, orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(Plan.fromMap).toList();
  }

  @override
  Future<Plan?> getById(int id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Plan.fromMap(rows.first);
  }

  @override
  Future<Plan> create(Plan plan) async {
    final values = plan.toMap()..remove('id');
    final id = await _db.insert(_table, values);
    return plan.copyWith(id: id);
  }

  @override
  Future<void> update(Plan plan) async {
    await _db.update(
      _table,
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
