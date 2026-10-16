import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/plan_controller.dart';
import '../models/plan.dart';
import '../navigation/app_drawer.dart';
import '../navigation/routes.dart';
import 'plan_form_screen.dart';

/// Lists plans and lets the user add, rename and delete them. Same structure
/// as `WorkoutsScreen`.
class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlanController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Plans')),
      drawer: const AppDrawer(currentRoute: Routes.plans),
      body: _buildBody(context, controller),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPlan(context),
        icon: const Icon(Icons.add),
        label: const Text('New plan'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlanController controller) {
    if (controller.isLoading && controller.plans.isEmpty) {
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
              onPressed: () => context.read<PlanController>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (controller.plans.isEmpty) {
      return const Center(child: Text('No plans yet. Tap + to add one.'));
    }

    final plans = controller.plans;
    return RefreshIndicator(
      onRefresh: () => context.read<PlanController>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88), // Room for the FAB.
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Dismissible(
            key: ValueKey(plan.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Icon(Icons.delete_outline),
            ),
            onDismissed: (_) => _deletePlan(context, plan),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.list_alt)),
              title: Text(plan.name),
              onTap: () => _editPlan(context, plan),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addPlan(BuildContext context) async {
    final controller = context.read<PlanController>();
    final result = await Navigator.push<Plan>(
      context,
      MaterialPageRoute(builder: (_) => const PlanFormScreen()),
    );
    if (result != null) await controller.add(result);
  }

  Future<void> _editPlan(BuildContext context, Plan plan) async {
    final controller = context.read<PlanController>();
    final result = await Navigator.push<Plan>(
      context,
      MaterialPageRoute(builder: (_) => PlanFormScreen(initial: plan)),
    );
    if (result != null) await controller.edit(result);
  }

  void _deletePlan(BuildContext context, Plan plan) {
    final controller = context.read<PlanController>();
    controller.remove(plan);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${plan.name}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => controller.restore(plan),
          ),
        ),
      );
  }
}
