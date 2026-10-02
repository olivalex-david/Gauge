import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the app's light and dark themes from the brand palette.
///
/// Material 3 widgets don't use colours directly; they use *roles* from a
/// ColorScheme (primary, primaryContainer, surface…). For example, a
/// FloatingActionButton is painted with `primaryContainer`, and the selected
/// sidebar item uses `secondaryContainer`. Assigning palette colours to roles
/// here styles every widget at once.
abstract final class AppTheme {
  static ThemeData get light {
    // fromSeed generates *all* ~30 roles (outlines, surfaces, error colours…)
    // from one colour. We then override the main roles with exact palette
    // values with copyWith. Without the overrides, fromSeed would shift our
    // colours slightly to fit its own tonal scale.
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.stormyTeal,
          brightness: Brightness.light,
        ).copyWith(
          // The whole palette is dark, so in light mode it's used for "strong"
          // elements (buttons, icons, app bar) with white text on top, and the
          // pale tints from AppColors fill the containers.
          primary: AppColors.stormyTeal,
          onPrimary: Colors.white,
          primaryContainer: AppColors.pacificCyanTint,
          onPrimaryContainer: AppColors.prussianBlue,
          secondary: AppColors.pacificCyan,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.stormyTealTint,
          onSecondaryContainer: AppColors.prussianBlue,
          tertiary: AppColors.darkTeal,
          onTertiary: Colors.white,
        );
    return _build(
      scheme,
      cardColor: AppColors.pacificCyanTint,
      appBarColor: AppColors.deepSpaceBlue,
      onAppBarColor: Colors.white,
    );
  }

  static ThemeData get dark {
    // In dark mode the palette fits naturally: the darkest colour becomes the
    // page background and each lighter step is used for things that sit on
    // top of it (app bar and cards, then highlights, then accents).
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.prussianBlue,
          brightness: Brightness.dark,
        ).copyWith(
          surface: AppColors.prussianBlue,
          // Pacific Cyan is the lightest palette colour, so it's the accent
          // that stands out most against the near-black background.
          primary: AppColors.pacificCyan,
          onPrimary: Colors.white,
          primaryContainer: AppColors.darkTeal,
          onPrimaryContainer: Colors.white,
          secondary: AppColors.stormyTeal,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.stormyTeal,
          onSecondaryContainer: Colors.white,
          tertiary: AppColors.pacificCyanTint,
          onTertiary: AppColors.prussianBlue,
        );
    return _build(
      scheme,
      cardColor: AppColors.deepSpaceBlue,
      appBarColor: AppColors.deepSpaceBlue,
      onAppBarColor: Colors.white,
    );
  }

  /// Settings shared by both themes. Component themes like `appBarTheme`
  /// change one widget type everywhere, so you don't style each AppBar by hand.
  static ThemeData _build(
    ColorScheme scheme, {
    required Color cardColor,
    required Color appBarColor,
    required Color onAppBarColor,
  }) {
    return ThemeData(
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: onAppBarColor,
      ),
      cardTheme: CardThemeData(color: cardColor, elevation: 0),
    );
  }
}
