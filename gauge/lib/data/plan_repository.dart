import '../models/plan.dart';

/// The contract every plan storage backend must fulfil. Same idea as
/// `WorkoutRepository`: the controller and UI only talk to this interface, so
/// an `ApiPlanRepository` can replace SQLite by changing one line in
/// `main.dart`.
abstract interface class PlanRepository {
  /// All plans, sorted by name (case-insensitive).
  Future<List<Plan>> getAll();

  Future<Plan?> getById(int id);

  /// Saves a new plan and returns it with its assigned `id`.
  Future<Plan> create(Plan plan);

  Future<void> update(Plan plan);

  Future<void> delete(int id);
}
