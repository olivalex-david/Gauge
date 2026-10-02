import '../models/workout.dart';

/// The contract every storage backend must fulfil.
///
/// This is what makes the app "API agnostic": the controller and the UI only
/// ever talk to this interface, never to SQLite directly. To move to a REST
/// API later, write an `ApiWorkoutRepository implements WorkoutRepository` and
/// change the one line in `main.dart` that picks the implementation.
///
/// Every method returns a `Future` even though some backends (like the
/// in-memory one) are synchronous. Network calls are always async, so
/// designing the interface async from day one avoids a painful refactor.
abstract interface class WorkoutRepository {
  /// All workouts, newest first.
  Future<List<Workout>> getAll();

  Future<Workout?> getById(int id);

  /// Saves a new workout and returns it with its assigned `id`.
  Future<Workout> create(Workout workout);

  Future<void> update(Workout workout);

  Future<void> delete(int id);
}
