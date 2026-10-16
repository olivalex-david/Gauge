import 'package:flutter/material.dart';

import '../data/settings_repository.dart';

/// Holds the user's preferences. MaterialApp listens to it, so changing
/// [themeMode] re-themes the whole app instantly.
class SettingsController extends ChangeNotifier {
  // The starting value is passed in (it was loaded in main() before the app
  // started) instead of loaded here. Loading it here would mean the first
  // frame uses the default theme and then flips, a visible flash on launch.
  SettingsController(
    this._repository, {
    ThemeMode initialThemeMode = ThemeMode.system,
  }) : _themeMode = initialThemeMode;

  final SettingsRepository _repository;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return; // Nothing changed; skip the rebuild.

    // Update the UI first, then save. Saving takes a moment, and the switch
    // should feel instant. If the save fails, the app still looks right until
    // the next launch, which is acceptable for a preference like this.
    _themeMode = mode;
    notifyListeners();
    await _repository.saveThemeMode(mode);
  }
}
