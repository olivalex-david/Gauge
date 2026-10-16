/// A training plan. For now it only has a name; more fields (description,
/// schedule, linked workouts…) can be added following `models/README.md`.
///
/// Same structure as [Workout]: immutable, nullable `id` until saved,
/// `copyWith`, `toMap` / `fromMap`.
class Plan {
  const Plan({this.id, required this.name});

  /// `null` until the plan is saved; the storage layer assigns it.
  final int? id;
  final String name;

  Plan copyWith({int? id, String? name}) {
    return Plan(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name};
  }

  factory Plan.fromMap(Map<String, Object?> map) {
    return Plan(id: map['id'] as int?, name: map['name'] as String);
  }
}
