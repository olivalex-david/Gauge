/// A single workout session.
///
/// Models are plain, immutable Dart classes: every field is `final`, and to
/// "change" a workout you create a new copy with [copyWith]. Immutability makes
/// state changes explicit, which matters once a ChangeNotifier is involved —
/// nobody can mutate an object behind the controller's back.
class Workout {
  const Workout({
    this.id,
    required this.name,
    required this.date,
    required this.durationMinutes,
    this.notes = '',
  });

  /// `null` until the workout is saved. The storage layer (SQLite's
  /// AUTOINCREMENT, or a server later on) assigns the real id, so the UI can
  /// build a `Workout` without knowing what the id will be.
  final int? id;
  final String name;
  final DateTime date;
  final int durationMinutes;
  final String notes;

  Workout copyWith({
    int? id,
    String? name,
    DateTime? date,
    int? durationMinutes,
    String? notes,
  }) {
    // `??` keeps the current value when a parameter isn't passed.
    // Tricky limitation: this pattern can't set a field *to null* (passing
    // null means "keep the old value"). That's fine here since only `id` is
    // nullable and we never need to clear it.
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
    );
  }

  /// Converts to a map of primitive values, the shape both SQLite rows and
  /// JSON objects use. An API repository could reuse this almost as-is.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      // SQLite has no DATE type. Storing milliseconds since epoch as an
      // INTEGER keeps sorting (`ORDER BY date`) correct and cheap.
      'date': date.millisecondsSinceEpoch,
      'duration_minutes': durationMinutes,
      'notes': notes,
    };
  }

  /// A `factory` constructor can run logic before returning an instance —
  /// handy for parsing. The `as` casts throw if the data has the wrong type,
  /// which surfaces schema mistakes early instead of hiding them.
  factory Workout.fromMap(Map<String, Object?> map) {
    return Workout(
      id: map['id'] as int?,
      name: map['name'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      durationMinutes: map['duration_minutes'] as int,
      notes: (map['notes'] as String?) ?? '',
    );
  }
}
