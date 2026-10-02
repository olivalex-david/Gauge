import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/workout_controller.dart';
import '../models/workout.dart';
import '../navigation/app_drawer.dart';
import '../navigation/routes.dart';
import 'workout_form_screen.dart';

/// Lists workouts and lets the user add, edit and delete them.
class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch subscribes this widget: build() re-runs every time the
    // controller calls notifyListeners(). Use watch inside build() to *read
    // state*; use context.read inside callbacks (onPressed etc.) to *call
    // methods* — read doesn't subscribe, and watch isn't allowed outside build.
    final controller = context.watch<WorkoutController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      drawer: const AppDrawer(currentRoute: Routes.workouts),
      body: _buildBody(context, controller),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addWorkout(context),
        icon: const Icon(Icons.add),
        label: const Text('Log workout'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WorkoutController controller) {
    // Only show the full-screen spinner on the first load. On later reloads
    // we keep showing the existing list so the screen doesn't flicker.
    if (controller.isLoading && controller.workouts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(controller.error!),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => context.read<WorkoutController>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (controller.workouts.isEmpty) {
      return const Center(child: Text('No workouts yet. Tap + to log one.'));
    }

    final workouts = controller.workouts;
    return RefreshIndicator(
      onRefresh: () => context.read<WorkoutController>().load(),
      // ListView.builder only builds the rows currently on screen, so it stays
      // fast even with thousands of workouts. Prefer it over
      // ListView(children: [...]) for any list that can grow.
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88), // Room for the FAB.
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return Dismissible(
            // Keys tell Flutter which widget is which when the list changes.
            // Without a stable key based on the data (the id), deleting row 2
            // could make Flutter reuse row 2's widget state for row 3. Never
            // use the index as the key in a list where items can be removed.
            key: ValueKey(workout.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Icon(Icons.delete_outline),
            ),
            onDismissed: (_) => _deleteWorkout(context, workout),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
              title: Text(workout.name),
              subtitle: Text(
                '${DateFormat.yMMMEd().format(workout.date)}'
                ' · ${workout.durationMinutes} min',
              ),
              onTap: () => _editWorkout(context, workout),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addWorkout(BuildContext context) async {
    // Grab the controller *before* the await. After an await the widget may
    // have been removed from the tree (e.g. the user navigated away), and
    // using its `context` then is unsafe — the analyzer warns about this
    // ("use_build_context_synchronously").
    final controller = context.read<WorkoutController>();

    // Navigator.push returns a Future that completes when the pushed screen
    // pops, carrying whatever value it popped with. The form returns the new
    // Workout, or null if the user backed out.
    final result = await Navigator.push<Workout>(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutFormScreen()),
    );
    if (result != null) await controller.add(result);
  }

  Future<void> _editWorkout(BuildContext context, Workout workout) async {
    final controller = context.read<WorkoutController>();
    final result = await Navigator.push<Workout>(
      context,
      MaterialPageRoute(builder: (_) => WorkoutFormScreen(initial: workout)),
    );
    if (result != null) await controller.edit(result);
  }

  void _deleteWorkout(BuildContext context, Workout workout) {
    final controller = context.read<WorkoutController>();
    controller.remove(workout);

    // ScaffoldMessenger lives above the Navigator, so the snackbar survives
    // even if the user switches screens while it's showing.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${workout.name}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => controller.restore(workout),
          ),
        ),
      );
  }
}
