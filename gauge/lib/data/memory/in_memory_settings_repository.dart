import 'package:flutter/material.dart';

import '../settings_repository.dart';

/// [SettingsRepository] that forgets everything when the app closes. Used by
/// tests, which can also read [themeMode] to check what was "saved".
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this.themeMode = ThemeMode.system]);

  ThemeMode themeMode;

  @override
  Future<ThemeMode> loadThemeMode() async => themeMode;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async => themeMode = mode;
}
