import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// CBT thought record ending in a self-compassionate balanced response.
class ThoughtRecordForm extends StatefulWidget {
  const ThoughtRecordForm({super.key, required this.onSaved, this.submitLabel = 'Save'});
  final VoidCallback onSaved;
  final String submitLabel;

  @override
  State<ThoughtRecordForm> createState() => _ThoughtRecordFormState();
}

class _ThoughtRecordFormState extends State<ThoughtRecordForm> {
  final _situation = TextEditingController();
  final _thought = TextEditingController();
  final _for = TextEditingController();
  final _against = TextEditingController();
  final _balanced = TextEditingController();
  final _action = TextEditingController();
  int _beliefBefore = 70;
  int _beliefAfter = 50;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_situation, _thought, _balanced]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_situation, _thought, _for, _against, _balanced, _action]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid =>
      _situation.text.trim().isNotEmpty && _thought.text.trim().isNotEmpty && _balanced.text.trim().isNotEmpty;

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<AppState>().addThought(ThoughtRecord(
          id: newId(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          situation: _situation.text.trim(),
          automaticThought: _thought.text.trim(),
          beliefBefore: _beliefBefore,
          evidenceFor: _for.text.trim(),
          evidenceAgainst: _against.text.trim(),
          balancedResponse: _balanced.text.trim(),
          beliefAfter: _beliefAfter,
          action: _action.text.trim(),
        ));
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('1. The situation', style: t.titleMedium),
        const SizedBox(height: 8),
        Field(controller: _situation, label: 'Situation', hint: 'e.g. I want to share an idea in tomorrow\'s meeting'),
        Text('2. The thought', style: t.titleMedium),
        const SizedBox(height: 8),
        Field(controller: _thought, label: 'What does the anxious voice say?', hint: 'e.g. Everyone will think I\'m stupid'),
        PercentSlider(
          label: 'How much do you believe it?',
          value: _beliefBefore,
          onChanged: (v) => setState(() => _beliefBefore = v),
        ),
        const SizedBox(height: 16),
        Text('3. Test it', style: t.titleMedium),
        const SizedBox(height: 8),
        Field(controller: _for, label: 'Evidence that supports it'),
        Field(
          controller: _against,
          label: 'Evidence against it, or other possible outcomes',
          hint: 'Has it happened before? What else could people think?',
        ),
        Text('4. Talk to yourself like a friend', style: t.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Not "I\'m brilliant" - something kind and realistic you would say to a friend in this spot.',
          style: t.bodySmall,
        ),
        const SizedBox(height: 8),
        Field(
          controller: _balanced,
          label: 'Balanced response',
          hint: 'e.g. My idea may be imperfect, but I\'m allowed to contribute. Most people will be thinking about the topic, not judging me.',
          maxLines: 5,
        ),
        PercentSlider(
          label: 'Now, how much do you believe the original thought?',
          value: _beliefAfter,
          onChanged: (v) => setState(() => _beliefAfter = v),
        ),
        const SizedBox(height: 16),
        Field(controller: _action, label: 'One thing I will do anyway (optional)'),
        FilledButton(onPressed: _valid && !_saving ? _save : null, child: Text(widget.submitLabel)),
      ],
    );
  }
}

class ThoughtRecordScreen extends StatelessWidget {
  const ThoughtRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test a thought')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [ThoughtRecordForm(onSaved: () => Navigator.pop(context))],
      ),
    );
  }
}
