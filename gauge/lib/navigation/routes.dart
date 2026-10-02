import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/workouts_screen.dart';

/// Named routes for the top-level screens reachable from the sidebar.
///
/// Keeping the names as constants avoids typos like '/workout' vs '/workouts'
/// that would otherwise only fail at runtime.
abstract final class Routes {
  static const home = '/';
  static const workouts = '/workouts';
  static const goals = '/goals';

  /// Passed to `MaterialApp.routes`. Each entry is a builder function, so the
  /// screen is only constructed when someone navigates to it.
  static final Map<String, WidgetBuilder> table = {
    home: (_) => const HomeScreen(),
    workouts: (_) => const WorkoutsScreen(),
    goals: (_) => const PlaceholderScreen(
      title: 'Goals',
      route: goals,
      icon: Icons.flag_outlined,
    ),
  };
}
