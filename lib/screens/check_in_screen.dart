import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/check_in.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class CheckInQuestions extends StatelessWidget {
  const CheckInQuestions({super.key, required this.answers, required this.onChanged});
  final List<int?> answers;
  final void Function(int index, int value) onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < checkInItems.length; i++) ...[
          Text(checkInItems[i].text, style: t.titleSmall),
          const SizedBox(height: 8),
          ScaleChoice(labels: checkInScaleLabels, value: answers[i], onChanged: (v) => onChanged(i, v)),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _answers = List<int?>.filled(checkInItems.length, null);

  Future<void> _save() async {
    final state = context.read<AppState>();
    await state.addCheckIn(_answers.map((e) => e!).toList());
    if (!mounted) return;
    final score = confidenceIndex(state.latestCheckIn!.answers);
    final previous = state.checkIns.length > 1 ? confidenceIndex(state.checkIns[state.checkIns.length - 2].answers) : null;
    final diff = (score != null && previous != null) ? score - previous : null;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Check-in saved'),
        content: Text(diff == null
            ? 'Your confidence index is $score/100.'
            : 'Your confidence index is $score/100 (${diff >= 0 ? '+' : ''}$diff since last time). '
                'Week-to-week numbers wobble; the trend over a month matters more.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly check-in')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('How true is each of these for you this week?', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          CheckInQuestions(answers: _answers, onChanged: (i, v) => setState(() => _answers[i] = v)),
          FilledButton(onPressed: _answers.contains(null) ? null : _save, child: const Text('Save check-in')),
        ],
      ),
    );
  }
}
