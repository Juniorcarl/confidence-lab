import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/challenges.dart';
import '../logic/adaptive.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// Set up today's real-world challenge as a behavioural experiment:
/// choose it, write the fear's prediction, rate it, pick safety
/// behaviours to drop.
class ChallengePlanForm extends StatefulWidget {
  const ChallengePlanForm({super.key, required this.onSaved});
  final VoidCallback onSaved;

  @override
  State<ChallengePlanForm> createState() => _ChallengePlanFormState();
}

class _ChallengePlanFormState extends State<ChallengePlanForm> {
  late final List<ChallengeOption> _options;
  int _selected = 0;
  final _prediction = TextEditingController();
  int _probability = 70;
  final _drop = <String>{};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _options = context.read<AppState>().todaysOptions;
    _prediction.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _prediction.dispose();
    super.dispose();
  }

  ChallengeTemplate get _template => _options[_selected].template;

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<AppState>().planChallenge(Challenge(
          id: newId(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          domain: _template.domain,
          level: _template.level,
          title: _template.title,
          prediction: _prediction.text.trim(),
          predictedProbability: _probability,
          safetyBehavioursToDrop: _drop.toList(),
        ));
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Choose one', style: t.titleMedium),
        const SizedBox(height: 12),
        for (var i = 0; i < _options.length; i++) ...[
          SectionCard(
            color: i == _selected ? scheme.secondaryContainer : null,
            onTap: () => setState(() => _selected = i),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(i == _selected ? Icons.radio_button_checked : Icons.radio_button_off, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_options[i].label} · ${_options[i].template.domain.label}', style: t.labelMedium),
                      const SizedBox(height: 4),
                      Text(_options[i].template.title, style: t.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 14),
        Text('What does your fear predict will happen?', style: t.titleMedium),
        const SizedBox(height: 4),
        Text('Be specific, so you can check it afterwards.', style: t.bodySmall),
        const SizedBox(height: 8),
        Field(controller: _prediction, label: 'Prediction', hint: _template.examplePrediction),
        PercentSlider(
          label: 'How likely is that to happen?',
          value: _probability,
          onChanged: (v) => setState(() => _probability = v),
          lowLabel: 'Won\'t happen',
          highLabel: 'Certain',
        ),
        const SizedBox(height: 20),
        Text('Safety behaviours to drop', style: t.titleMedium),
        const SizedBox(height: 4),
        Text(
          'These feel protective but stop you learning you would be fine without them. Pick one or two.',
          style: t.bodySmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in safetyBehaviours)
              FilterChip(
                label: Text(s),
                selected: _drop.contains(s),
                onSelected: (sel) => setState(() => sel ? _drop.add(s) : _drop.remove(s)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _prediction.text.trim().isNotEmpty && !_saving ? _save : null,
          child: const Text('Commit to this challenge'),
        ),
      ],
    );
  }
}
