import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/workout.dart';

/// Create/edit form. Pass [initial] to edit an existing workout.
///
/// The form doesn't save anything itself: it pops the finished [Workout] back
/// to whoever opened it. That keeps it reusable and free of controller logic.
///
/// It's a StatefulWidget because it owns things that must live as long as the
/// screen and be cleaned up afterwards (text controllers) and values that
/// change while the user types (the chosen date).
class WorkoutFormScreen extends StatefulWidget {
  const WorkoutFormScreen({super.key, this.initial});

  final Workout? initial;

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  // A GlobalKey gives us a handle to the Form's state so we can call
  // validate() on all fields at once from the Save button.
  final _formKey = GlobalKey<FormState>();

  // `late` = "assigned before first use, just not at declaration". We need
  // `widget.initial`, which isn't accessible in field initializers, so these
  // are set up in initState instead.
  late final TextEditingController _name;
  late final TextEditingController _duration;
  late final TextEditingController _notes;
  late DateTime _date;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    // initState runs once when the State is created — the right place to set
    // up controllers. Don't do this in build(), which runs many times.
    super.initState();
    final w = widget.initial;
    _name = TextEditingController(text: w?.name ?? '');
    _duration = TextEditingController(
      text: w?.durationMinutes.toString() ?? '',
    );
    _notes = TextEditingController(text: w?.notes ?? '');
    _date = w?.date ?? DateUtils.dateOnly(DateTime.now());
  }

  @override
  void dispose() {
    // Controllers hold listeners and native resources. Forgetting to dispose
    // them is a memory leak — every opened form would leave some behind.
    _name.dispose();
    _duration.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    // In a State, `mounted` is false once the widget has been disposed. Always
    // check it after an await before touching setState or context.
    if (picked == null || !mounted) return;

    // setState tells Flutter "this State changed, re-run build()". Changing
    // _date without it would update the variable but not the screen.
    setState(() => _date = picked);
  }

  void _save() {
    // validate() runs every field's validator and shows the error messages.
    if (!_formKey.currentState!.validate()) return;

    final base =
        widget.initial ?? Workout(name: '', date: _date, durationMinutes: 0);
    // copyWith keeps the id when editing, so the repository updates the
    // right row instead of creating a new one.
    final result = base.copyWith(
      name: _name.text.trim(),
      date: _date,
      durationMinutes: int.parse(_duration.text),
      notes: _notes.text.trim(),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit workout' : 'Log workout'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Push day',
              ),
              textCapitalization: TextCapitalization.sentences,
              // A validator returns an error message, or null when valid.
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Give the workout a name'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _duration,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final minutes = int.tryParse(value ?? '');
                if (minutes == null || minutes <= 0) {
                  return 'Enter a positive number of minutes';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat.yMMMMEEEEd().format(_date)),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 4,
              minLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
