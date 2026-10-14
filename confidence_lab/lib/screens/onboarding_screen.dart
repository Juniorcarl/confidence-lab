import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/assessment.dart';
import '../content/check_in.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'check_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  final _assessment = <String, int>{};
  final _triggers = <String>{};
  final _goal = TextEditingController();
  final _checkIn = List<int?>.filled(checkInItems.length, null);
  bool _saving = false;

  static const _steps = 4;

  @override
  void dispose() {
    _goal.dispose();
    super.dispose();
  }

  bool get _canContinue => switch (_step) {
        1 => _assessment.length == assessmentCategories.length,
        2 => _triggers.isNotEmpty,
        3 => !_checkIn.contains(null),
        _ => true,
      };

  Future<void> _next() async {
    if (_step < _steps - 1) {
      setState(() => _step++);
      return;
    }
    setState(() => _saving = true);
    await context.read<AppState>().completeOnboarding(
          assessment: Map.of(_assessment),
          triggers: _triggers.toList(),
          goal: _goal.text.trim(),
          baselineCheckIn: _checkIn.map((e) => e!).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(onPressed: () => setState(() => _step--), icon: const Icon(Icons.arrow_back)),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_step + 1) / _steps,
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(key: ValueKey(_step), child: _buildStep(context)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canContinue && !_saving ? _next : null,
                  child: Text(_step == 0 ? 'Get started' : (_step == _steps - 1 ? 'Start day 1' : 'Continue')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    final t = Theme.of(context).textTheme;
    switch (_step) {
      case 0:
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Icon(Icons.graphic_eq, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Confidence is a skill you can practise.', style: t.headlineMedium),
            const SizedBox(height: 16),
            Text(
              'Each day takes about 10-15 minutes: a short lesson, a thought exercise, and one small '
              'real-world experiment. You do not need to feel confident first.',
              style: t.bodyLarge,
            ),
            const SizedBox(height: 24),
            SectionCard(
              child: Text(
                'Confidence Lab is a training tool, not therapy or a diagnosis. If fear of judgment is '
                'seriously affecting your life, a psychologist can help, and you can use this alongside.',
                style: t.bodyMedium,
              ),
            ),
          ],
        );
      case 1:
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('How hard are these for you right now?', style: t.headlineSmall),
            const SizedBox(height: 8),
            Text('There are no right answers. This sets where you start.', style: t.bodyMedium),
            const SizedBox(height: 20),
            for (final c in assessmentCategories) ...[
              Text(c.question, style: t.titleSmall),
              const SizedBox(height: 8),
              ScaleChoice(
                labels: difficultyLabels,
                value: _assessment[c.id],
                onChanged: (v) => setState(() => _assessment[c.id] = v),
              ),
              const SizedBox(height: 20),
            ],
          ],
        );
      case 2:
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Where does self-doubt show up?', style: t.headlineSmall),
            const SizedBox(height: 8),
            Text('Pick any that apply.', style: t.bodyMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in triggerOptions)
                  FilterChip(
                    label: Text(o),
                    selected: _triggers.contains(o),
                    onSelected: (s) => setState(() => s ? _triggers.add(o) : _triggers.remove(o)),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Text('In a month, what would you like to be able to do?', style: t.titleMedium),
            const SizedBox(height: 12),
            Field(
              controller: _goal,
              label: 'My goal',
              hint: 'e.g. Share one idea in every team meeting',
            ),
          ],
        );
      default:
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Your starting point', style: t.headlineSmall),
            const SizedBox(height: 8),
            Text('How true is each of these for you this week? You will see how this changes.',
                style: t.bodyMedium),
            const SizedBox(height: 20),
            CheckInQuestions(
              answers: _checkIn,
              onChanged: (i, v) => setState(() => _checkIn[i] = v),
            ),
          ],
        );
    }
  }
}
