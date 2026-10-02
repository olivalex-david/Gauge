import 'package:flutter/material.dart';

/// The raw brand palette. Screens shouldn't use these directly — they should
/// read roles from the theme (`Theme.of(context).colorScheme.primary`), so dark
/// mode and future palette changes work automatically. See `app_theme.dart`
/// for which palette colour plays which role.
abstract final class AppColors {
  // Tricky: CSS writes alpha LAST (#RRGGBBAA, e.g. #010224ff), but Flutter's
  // Color(int) wants alpha FIRST (0xAARRGGBB). So CSS #010224ff becomes
  // 0xFF010224 — move the trailing "ff" to the front.
  static const prussianBlue = Color(0xFF010224);
  static const deepSpaceBlue = Color(0xFF002D46);
  static const darkTeal = Color(0xFF004451);
  static const stormyTeal = Color(0xFF126F7F);
  static const pacificCyan = Color(0xFF148197);

  // Every palette colour is dark, but light mode needs pale backgrounds for
  // cards and highlights. Mixing a palette colour with white keeps those pale
  // shades in the same family. They're `final`, not `const`, because
  // Color.lerp runs when the app starts and can't be evaluated at compile time.
  static final pacificCyanTint = tint(pacificCyan, 0.85);
  static final stormyTealTint = tint(stormyTeal, 0.7);

  /// Mixes [color] with white. `amount` 0 = unchanged, 1 = pure white.
  static Color tint(Color color, double amount) =>
      Color.lerp(color, Colors.white, amount)!;

  /// The palette as a gradient, darkest at the top-left. This is the Flutter
  /// version of the CSS `linear-gradient(135deg, ...)`: instead of an angle,
  /// you give a start and end point on the box.
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [prussianBlue, deepSpaceBlue, darkTeal, stormyTeal, pacificCyan],
  );
}
