import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/workout_controller.dart';
import '../navigation/app_drawer.dart';
import '../navigation/routes.dart';

/// Dashboard. It reads the *same* WorkoutController as the Workouts screen, so
/// adding a workout there updates the numbers here automatically.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.select rebuilds this widget only when the selected value
    // changes, rather than on every notifyListeners() like context.watch.
    // Here it's a small optimisation; on bigger screens it really helps.
    final workouts = context.select((WorkoutController c) => c.workouts);
    final latest = workouts.isEmpty ? null : workouts.first;
    final totalMinutes = workouts.fold<int>(
      0,
      (sum, w) => sum + w.durationMinutes,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: const AppDrawer(currentRoute: Routes.home),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              // Expanded makes each card take an equal share of the Row's
              // width. Without it, Row gives children only their natural size.
              Expanded(
                child: _StatCard(
                  label: 'Workouts',
                  value: '${workouts.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Total minutes',
                  value: '$totalMinutes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Last workout'),
              subtitle: Text(
                latest == null
                    ? 'None yet — log your first one!'
                    : '${latest.name} · ${DateFormat.MMMd().format(latest.date)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Routes.workouts),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small private widget (leading underscore = private to this file). Splitting
/// UI into little widgets like this keeps `build` methods readable.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: theme.textTheme.headlineMedium),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
