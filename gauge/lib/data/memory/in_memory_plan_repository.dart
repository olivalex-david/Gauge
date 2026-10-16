import '../../models/plan.dart';
import '../plan_repository.dart';

/// [PlanRepository] that keeps everything in a list. Used by tests, like
/// `InMemoryWorkoutRepository`.
class InMemoryPlanRepository implements PlanRepository {
  InMemoryPlanRepository([List<Plan> initial = const []]) {
    for (final p in initial) {
      _items.add(p.copyWith(id: _nextId++));
    }
  }

  final List<Plan> _items = [];
  int _nextId = 1;

  @override
  Future<List<Plan>> getAll() async {
    return [..._items]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<Plan?> getById(int id) async {
    for (final p in _items) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<Plan> create(Plan plan) async {
    final saved = plan.copyWith(id: _nextId++);
    _items.add(saved);
    return saved;
  }

  @override
  Future<void> update(Plan plan) async {
    final index = _items.indexWhere((p) => p.id == plan.id);
    if (index != -1) _items[index] = plan;
  }

  @override
  Future<void> delete(int id) async {
    _items.removeWhere((p) => p.id == id);
  }
}
