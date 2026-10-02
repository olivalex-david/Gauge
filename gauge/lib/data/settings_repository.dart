import 'package:flutter/material.dart';

/// Where user preferences are stored. Same idea as [WorkoutRepository]: the
/// controller only knows this interface, so the storage can change (device
/// storage now, a user account on a server later) without touching the UI.
abstract interface class SettingsRepository {
  Future<ThemeMode> loadThemeMode();

  Future<void> saveThemeMode(ThemeMode mode);
}
