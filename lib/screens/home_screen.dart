import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/programme.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'challenge_review_screen.dart';
import 'check_in_screen.dart';
import 'session_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context).textTheme;
    final open = state.openChallenge;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Pill(state.programmeComplete ? 'Programme complete' : 'Day ${state.day} of $programmeLength'),
              const SizedBox(width: 8),
              Flexible(child: Pill('Phase ${state.phase.number}: ${state.phase.title}')),
            ],
          ),
          const SizedBox(height: 16),
          Text(_greeting(), style: t.headlineSmall),
          const SizedBox(height: 20),
          _NextAction(state: state, open: open),
          const SizedBox(height: 16),
          if (open != null && !_isStale(open) && state.sessionDoneToday) ...[
            _ChallengeCard(challenge: open),
            const SizedBox(height: 16),
          ],
          if (state.showSupportSuggestion) ...[
            const SupportCard(),
            const SizedBox(height: 16),
          ],
          if (state.checkInDue)
            SectionCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckInScreen())),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.fact_check_outlined),
                title: Text('Weekly check-in'),
                subtitle: Text('2 minutes. See how things are shifting.'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          if (state.profile?.goal.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your goal', style: t.labelLarge),
                  const SizedBox(height: 6),
                  Text(state.profile!.goal, style: t.titleMedium),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _Stats(state: state),
        ],
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

/// A planned challenge from a previous day is waiting for its review.
bool _isStale(Challenge c) {
  final created = DateTime.fromMillisecondsSinceEpoch(c.createdAt);
  final now = DateTime.now();
  return !(created.year == now.year && created.month == now.month && created.day == now.day);
}

class _NextAction extends StatelessWidget {
  const _NextAction({required this.state, required this.open});
  final AppState state;
  final Challenge? open;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    late final String title;
    late final String body;
    late final String button;
    late final VoidCallback? onPressed;

    final c = open;
    if (c != null && _isStale(c)) {
      title = 'How did your challenge go?';
      body = c.title;
      button = 'Review it';
      onPressed = () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChallengeReviewScreen(challenge: c)));
    } else if (!state.sessionDoneToday) {
      final lesson = lessonForDay(state.day);
      title = state.programmeComplete ? 'Keep practising' : "Today's session";
      body = '${lesson.title} · about 10 minutes';
      button = 'Start';
      onPressed = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionScreen()));
    } else if (c != null) {
      title = 'Session done';
      body = 'Your challenge is below. Review it once you have tried it - today or tomorrow.';
      button = 'Review now';
      onPressed = () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChallengeReviewScreen(challenge: c)));
    } else {
      title = 'Done for today';
      body = 'Nice work. Rest is part of training too. The Practise tab is there if you want more.';
      button = '';
      onPressed = null;
    }

    return SectionCard(
      color: scheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.titleLarge?.copyWith(color: scheme.onPrimaryContainer)),
          const SizedBox(height: 8),
          Text(body, style: t.bodyLarge?.copyWith(color: scheme.onPrimaryContainer)),
          if (onPressed != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onPressed, child: Text(button)),
          ],
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});
  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Pill(challenge.domain.label), const SizedBox(width: 8), Pill('Level ${challenge.level}')]),
          const SizedBox(height: 12),
          Text(challenge.title, style: t.titleMedium),
          const SizedBox(height: 12),
          Text('Your prediction (${challenge.predictedProbability}% likely):', style: t.labelLarge),
          Text(challenge.prediction, style: t.bodyMedium),
          if (challenge.safetyBehavioursToDrop.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Dropping: ${challenge.safetyBehavioursToDrop.join(', ')}', style: t.bodySmall),
          ],
          const SizedBox(height: 12),
          Text('Tip: point your attention at the other person, not at how you come across.', style: t.bodySmall),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final done = state.reviewedChallenges.where((c) => c.status == ChallengeStatus.done).length;
    return Row(
      children: [
        Expanded(child: _Stat(value: '${state.profile?.sessionsCompleted ?? 0}', label: 'sessions')),
        const SizedBox(width: 12),
        Expanded(child: _Stat(value: '$done', label: 'challenges tried')),
        const SizedBox(width: 12),
        Expanded(child: _Stat(value: '${state.thoughts.length}', label: 'thoughts tested')),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(value, style: t.headlineSmall),
          Text(label, style: t.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
