import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'routes.dart';

/// One sidebar entry. Adding a feature (Plans, Calendar…) = add a route in
/// `routes.dart` and one line in [_destinations].
class _Destination {
  const _Destination(this.label, this.route, this.icon, this.selectedIcon);
  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _Destination('Home', Routes.home, Icons.home_outlined, Icons.home),
  _Destination(
    'Workouts',
    Routes.workouts,
    Icons.fitness_center_outlined,
    Icons.fitness_center,
  ),
  _Destination('Goals', Routes.goals, Icons.flag_outlined, Icons.flag),
  _Destination(
    'Settings',
    Routes.settings,
    Icons.settings_outlined,
    Icons.settings,
  ),
];

/// The sidebar shared by all top-level screens.
///
/// Each screen passes its own route as [currentRoute] so the matching entry is
/// highlighted. (You could read it from `ModalRoute.of(context)`, but passing it
/// explicitly is easier to follow and to test.)
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final selected = _destinations.indexWhere((d) => d.route == currentRoute);

    // NavigationDrawer is the Material 3 sidebar: it handles the selected
    // "pill" highlight and keyboard/accessibility behaviour for us.
    return NavigationDrawer(
      // -1 means "nothing selected"; NavigationDrawer wants null for that.
      selectedIndex: selected == -1 ? null : selected,
      onDestinationSelected: (index) => _goTo(context, _destinations[index]),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          // A BoxDecoration paints the background of a Container. This is
          // the one place we use raw palette colours instead of theme roles:
          // the gradient is a brand element that looks the same in both modes.
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Gauge',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: Colors.white),
          ),
        ),
        for (final d in _destinations)
          NavigationDrawerDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label),
          ),
      ],
    );
  }

  void _goTo(BuildContext context, _Destination destination) {
    // The drawer is itself a route on the Navigator stack, so pop() closes it.
    // Do this first, otherwise the drawer would stay open on the old screen.
    Navigator.pop(context);

    if (destination.route == currentRoute) return;

    // pushReplacementNamed swaps the current screen instead of stacking a new
    // one on top. With plain push, every sidebar tap would add a screen and
    // the back button would replay your whole navigation history. Sidebar
    // destinations are "siblings", so replacing is what users expect.
    Navigator.pushReplacementNamed(context, destination.route);
  }
}
