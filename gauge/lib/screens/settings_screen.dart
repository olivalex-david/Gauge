import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../navigation/app_drawer.dart';
import '../navigation/routes.dart';

/// App preferences. For now: choosing light, dark, or the phone's setting.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // select: rebuild only when themeMode changes, not on every
    // notifyListeners() (which matters once more settings are added here).
    final themeMode = context.select((SettingsController s) => s.themeMode);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: const AppDrawer(currentRoute: Routes.settings),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          // A three-way choice rather than an on/off Switch: "System" follows
          // the iPhone's own light/dark setting, which a two-state toggle
          // can't represent.
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            // SegmentedButton supports picking several segments at once, so
            // it works with a Set even when only one may be chosen. We wrap
            // our single value in {…} and take `.first` back out.
            selected: {themeMode},
            onSelectionChanged: (selection) => context
                .read<SettingsController>()
                .setThemeMode(selection.first),
          ),
        ],
      ),
    );
  }
}
