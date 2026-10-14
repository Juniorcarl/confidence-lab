import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/programme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'challenge_plan_form.dart';
import 'thought_record_form.dart';

/// Daily session: lesson -> thought record (skippable) -> plan challenge -> done.
class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int _step = 0;
  static const _titles = ['Today\'s idea', 'Test a thought', 'Plan a challenge', 'Done'];

  void _next() => setState(() => _step++);

  Future<void> _finish() async {
    await context.read<AppState>().completeSession();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_step]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / _titles.length),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_step), child: _body(context)),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context).textTheme;
    switch (_step) {
      case 0:
        final lesson = lessonForDay(state.day);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Pill('Day ${state.day} · ${state.phase.title}'),
            const SizedBox(height: 16),
            Text(lesson.title, style: t.headlineSmall),
            const SizedBox(height: 12),
            Text(lesson.body, style: t.bodyLarge),
            const SizedBox(height: 20),
            SectionCard(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Try this', style: t.labelLarge),
                  const SizedBox(height: 6),
                  Text(lesson.tryThis, style: t.bodyLarge),
                ],
              ),
            ),
            if (lesson.source != null) ...[
              const SizedBox(height: 12),
              Text('Based on: ${lesson.source}', style: t.bodySmall),
            ],
            const SizedBox(height: 24),
            FilledButton(onPressed: _next, child: const Text('Continue')),
          ],
        );
      case 1:
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Think of a situation coming up, or one from today, where self-doubt showed up.',
                style: t.bodyLarge),
            const SizedBox(height: 20),
            ThoughtRecordForm(onSaved: _next, submitLabel: 'Save and continue'),
            const SizedBox(height: 8),
            TextButton(onPressed: _next, child: const Text('Skip for a shorter session')),
          ],
        );
      case 2:
        final open = state.openChallenge;
        if (open != null) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('You already have a challenge waiting', style: t.titleLarge),
              const SizedBox(height: 12),
              SectionCard(child: Text(open.title, style: t.titleMedium)),
              const SizedBox(height: 12),
              const Text('Keep it for today. Review it from the Home screen once you have tried it.'),
              const SizedBox(height: 24),
              FilledButton(onPressed: _next, child: const Text('Keep this challenge')),
              TextButton(
                onPressed: () async {
                  await state.updateChallenge(open.skip());
                },
                child: const Text('Set it aside and choose a new one'),
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [ChallengePlanForm(onSaved: _next)],
        );
      default:
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 32),
            Icon(Icons.check_circle_outline, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('Session complete', style: t.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Now the real practice happens out there. Nerves are expected - the aim is to do it anyway '
              'and see what actually happens.',
              style: t.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(onPressed: _finish, child: const Text('Back to home')),
          ],
        );
    }
  }
}
