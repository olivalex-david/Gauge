import '../../models/workout.dart';
import '../workout_repository.dart';

/// [WorkoutRepository] that keeps everything in a list. Data is lost when the
/// app closes.
///
/// Used by tests (no database plugin needed), and it proves the point of the
/// interface: swap it into `main.dart` and the whole app still works.
class InMemoryWorkoutRepository implements WorkoutRepository {
  InMemoryWorkoutRepository([List<Workout> initial = const []]) {
    for (final w in initial) {
      _items.add(w.copyWith(id: _nextId++));
    }
  }

  final List<Workout> _items = [];
  int _nextId = 1;

  @override
  Future<List<Workout>> getAll() async {
    // Return a sorted *copy* so callers can't modify our internal list.
    return [..._items]..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Workout?> getById(int id) async {
    for (final w in _items) {
      if (w.id == id) return w;
    }
    return null;
  }

  @override
  Future<Workout> create(Workout workout) async {
    final saved = workout.copyWith(id: _nextId++);
    _items.add(saved);
    return saved;
  }

  @override
  Future<void> update(Workout workout) async {
    final index = _items.indexWhere((w) => w.id == workout.id);
    if (index != -1) _items[index] = workout;
  }

  @override
  Future<void> delete(int id) async {
    _items.removeWhere((w) => w.id == id);
  }
}
