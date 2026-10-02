import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings_repository.dart';

/// [SettingsRepository] backed by shared_preferences: a small key-value store
/// (UserDefaults on iOS). It's the usual home for simple settings like this.
/// SQLite would work too, but it's overkill for a few values that have no
/// relationships and never need querying.
class PrefsSettingsRepository implements SettingsRepository {
  final _prefs = SharedPreferencesAsync();

  static const _themeModeKey = 'theme_mode';

  @override
  Future<ThemeMode> loadThemeMode() async {
    final name = await _prefs.getString(_themeModeKey);
    // Enums are stored by name ('dark', 'light', 'system') rather than by
    // index. If someone later reorders the enum values, an index like 2 would
    // silently change meaning; a name either still matches or falls back.
    // asNameMap() builds {'system': ThemeMode.system, 'light': ..., ...}.
    return ThemeMode.values.asNameMap()[name] ?? ThemeMode.system;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
  }
}
