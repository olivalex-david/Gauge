import 'package:flutter/material.dart';

import '../models/plan.dart';

/// Create/edit form. Pass [initial] to edit an existing plan. Like
/// `WorkoutFormScreen`, it pops the finished [Plan] back instead of saving it.
class PlanFormScreen extends StatefulWidget {
  const PlanFormScreen({super.key, this.initial});

  final Plan? initial;

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // copyWith keeps the id when editing, so the right row is updated.
    final base = widget.initial ?? const Plan(name: '');
    Navigator.pop(context, base.copyWith(name: _name.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit plan' : 'New plan'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              autofocus: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. 5x5 Strength',
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Give the plan a name'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
