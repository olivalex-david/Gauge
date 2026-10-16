import 'package:flutter/material.dart';

import '../navigation/app_drawer.dart';

/// Generic "coming soon" screen. Reused for any sidebar entry that isn't built
/// yet — it's a `StatelessWidget` configured entirely by its constructor
/// arguments, the simplest kind of reusable widget.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.route,
    required this.icon,
  });

  final String title;
  final String route;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // Giving a Scaffold a `drawer` makes the AppBar show the ☰ button
      // automatically.
      appBar: AppBar(title: Text(title)),
      drawer: AppDrawer(currentRoute: route),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('$title — coming soon', style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
