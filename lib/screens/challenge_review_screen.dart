import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/adaptive.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// Compare the prediction with what actually happened, then update the
/// belief for next time. The updated belief is the key progress signal.
class ChallengeReviewScreen extends StatefulWidget {
  const ChallengeReviewScreen({super.key, required this.challenge});
  final Challenge challenge;

  @override
  State<ChallengeReviewScreen> createState() => _ChallengeReviewScreenState();
}

class _ChallengeReviewScreenState extends State<ChallengeReviewScreen> {
  final _happened = TextEditingController();
  final _signs = TextEditingController();
  final _learned = TextEditingController();
  FearedOutcome? _outcome;
  int _anxiety = 50;
  late int _updated = widget.challenge.predictedProbability;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _happened.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _happened.dispose();
    _signs.dispose();
    _learned.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final state = context.read<AppState>();
    final c = widget.challenge;
    final before = earnedLevel(c.domain, state.challenges);
    await state.updateChallenge(c.review(
      whatHappened: _happened.text.trim(),
      fearedOutcome: _outcome!,
      anxietyPeak: _anxiety,
      signsOfInterest: _signs.text.trim(),
      updatedProbability: _updated,
      learned: _learned.text.trim(),
    ));
    final after = earnedLevel(c.domain, state.challenges);
    if (!mounted) return;

    final drop = c.predictedProbability - _updated;
    final message = StringBuffer()
      ..write('You predicted ${c.predictedProbability}%. Now you expect $_updated%')
      ..write(drop > 0 ? ' - your fear\'s forecast moved by $drop points.' : '.');
    if (after > before) {
      message.write('\n\nNext ${c.domain.label.toLowerCase()} challenges will step up a little.');
    } else if (_outcome == FearedOutcome.yes) {
      message.write('\n\nIt did not go as hoped, and you still did it. That is the practice. '
          'We will repeat this level before moving on.');
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Challenge logged'),
        content: Text(message.toString()),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _skip() async {
    await context.read<AppState>().updateChallenge(widget.challenge.skip());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('No problem. Avoiding sometimes is normal - the next one may be a bit gentler.'),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final t = Theme.of(context).textTheme;
    final valid = _outcome != null && _happened.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Review your challenge')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: t.titleMedium),
                const SizedBox(height: 10),
                Text('Your fear predicted (${c.predictedProbability}% likely):', style: t.labelLarge),
                Text(c.prediction),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Field(controller: _happened, label: 'What actually happened?', maxLines: 5),
          Text('Did the feared outcome happen?', style: t.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<FearedOutcome>(
            segments: [for (final f in FearedOutcome.values) ButtonSegment(value: f, label: Text(f.label))],
            selected: _outcome == null ? <FearedOutcome>{} : {_outcome!},
            emptySelectionAllowed: true,
            onSelectionChanged: (s) => setState(() => _outcome = s.isEmpty ? null : s.first),
          ),
          const SizedBox(height: 20),
          PercentSlider(
            label: 'How anxious did you feel at the peak?',
            value: _anxiety,
            onChanged: (v) => setState(() => _anxiety = v),
            lowLabel: 'Calm',
            highLabel: 'Extremely',
          ),
          const SizedBox(height: 20),
          Field(
            controller: _signs,
            label: 'Any signs the other person was interested or friendly?',
            hint: 'A smile, a follow-up question, nodding... People usually like us more than we notice.',
          ),
          PercentSlider(
            label: 'Next time, how likely is the feared outcome?',
            value: _updated,
            onChanged: (v) => setState(() => _updated = v),
            lowLabel: 'Won\'t happen',
            highLabel: 'Certain',
          ),
          const SizedBox(height: 20),
          Field(controller: _learned, label: 'What did you learn? (optional)'),
          FilledButton(onPressed: valid && !_saving ? _save : null, child: const Text('Save review')),
          const SizedBox(height: 8),
          TextButton(onPressed: _saving ? null : _skip, child: const Text('I didn\'t do it this time')),
        ],
      ),
    );
  }
}
