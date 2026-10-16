import 'package:flutter/foundation.dart';

import '../data/plan_repository.dart';
import '../models/plan.dart';

/// Holds the plan state for the whole app. Same pattern as
/// `WorkoutController` — see the comments there for the reasoning behind the
/// unmodifiable list, the loading flag and the optimistic delete.
class PlanController extends ChangeNotifier {
  PlanController(this._repository);

  final PlanRepository _repository;

  List<Plan> _plans = const [];
  bool _isLoading = false;
  String? _error;

  List<Plan> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = List.unmodifiable(await _repository.getAll());
    } catch (e) {
      _error = 'Could not load plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(Plan plan) async {
    await _repository.create(plan);
    await load();
  }

  Future<void> edit(Plan plan) async {
    await _repository.update(plan);
    await load();
  }

  Future<void> remove(Plan plan) async {
    final id = plan.id;
    if (id == null) return;

    // Drop it synchronously so the swiped Dismissible leaves the tree on the
    // next frame.
    _plans = List.unmodifiable(_plans.where((p) => p.id != id));
    notifyListeners();

    try {
      await _repository.delete(id);
    } finally {
      await load();
    }
  }

  /// Re-inserts a deleted plan (used by the "Undo" snackbar).
  Future<void> restore(Plan plan) async {
    await _repository.create(plan);
    await load();
  }
}
