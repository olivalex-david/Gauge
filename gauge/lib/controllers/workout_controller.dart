import 'package:flutter/foundation.dart';

import '../data/workout_repository.dart';
import '../models/workout.dart';

/// Holds the workout state for the whole app and exposes actions the UI can
/// call.
///
/// `ChangeNotifier` is Flutter's built-in "observable": widgets subscribe to
/// it (via Provider's `context.watch`) and rebuild whenever we call
/// [notifyListeners]. The UI never touches the repository directly.
class WorkoutController extends ChangeNotifier {
  WorkoutController(this._repository);

  // Typed as the *interface*, not SqliteWorkoutRepository. This line is why
  // the controller doesn't care where data lives.
  final WorkoutRepository _repository;

  List<Workout> _workouts = const [];
  bool _isLoading = false;
  String? _error;

  // Private fields + public getters = read-only from the outside. The UI can
  // read state but must go through the methods below to change it, so every
  // change is guaranteed to call notifyListeners().
  //
  // The list is stored as unmodifiable (see load), so
  // `controller.workouts.add(...)` throws instead of silently mutating state
  // without notifying anyone. We wrap it once in load() rather than in this
  // getter: wrapping here would return a *new* list object on every read, and
  // `context.select` (which compares old vs new with ==) would think the data
  // changed every time and rebuild needlessly.
  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Show a spinner right away.

    try {
      _workouts = List.unmodifiable(await _repository.getAll());
    } catch (e) {
      _error = 'Could not load workouts: $e';
    } finally {
      // `finally` runs on success *and* failure, so the spinner can never get
      // stuck on screen.
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(Workout workout) async {
    await _repository.create(workout);
    // Simplest correct approach: re-read from the source of truth after each
    // write. With an API you might instead update `_workouts` locally first
    // ("optimistic update") to make the UI feel instant.
    await load();
  }

  Future<void> edit(Workout workout) async {
    await _repository.update(workout);
    await load();
  }

  Future<void> remove(Workout workout) async {
    final id = workout.id;
    if (id == null) return; // Never saved, nothing to delete.

    // Optimistic update: drop it from local state *synchronously*, before any
    // await. This is required by the swipe-to-delete `Dismissible` widget: once
    // swiped, the item must be gone from the list on the very next frame, or
    // Flutter throws "A dismissed Dismissible widget is still part of the
    // tree". Waiting for the database first would be too late.
    _workouts = List.unmodifiable(_workouts.where((w) => w.id != id));
    notifyListeners();

    try {
      await _repository.delete(id);
    } finally {
      // Re-sync with storage; if the delete failed, the item reappears.
      await load();
    }
  }

  /// Re-inserts a deleted workout (used by the "Undo" snackbar). It gets a new
  /// id, which is fine because nothing else references it yet.
  Future<void> restore(Workout workout) async {
    await _repository.create(workout);
    await load();
  }
}
