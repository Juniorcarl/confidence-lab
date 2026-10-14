import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/check_in.dart';
import '../logic/adaptive.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/line_chart.dart';

/// Progress is about behaviour and changing predictions - no streaks.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final reviewed = state.reviewedChallenges.where((c) => c.status == ChallengeStatus.done).toList()
      ..sort((a, b) => (a.reviewedAt ?? 0).compareTo(b.reviewedAt ?? 0));
    final avgChange = averageExpectancyChange(reviewed);
    final indices = state.checkIns.map((c) => confidenceIndex(c.answers)).whereType<int>().toList();
    final priority = domainPriority(state.profile?.assessment ?? const {});

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Progress', style: t.headlineSmall),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your fear's forecasts", style: t.titleMedium),
                const SizedBox(height: 4),
                Text(
                  avgChange == null
                      ? 'Review a challenge to see how your predictions change.'
                      : 'On average your expectation of the feared outcome dropped by '
                          '${avgChange.toStringAsFixed(0)} points after trying.',
                  style: t.bodySmall,
                ),
                if (reviewed.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SimpleLineChart(series: [
                    ChartSeries('Predicted before', reviewed.map((c) => c.predictedProbability.toDouble()).toList(),
                        scheme.tertiary),
                    ChartSeries('Expected next time',
                        reviewed.map((c) => (c.updatedProbability ?? c.predictedProbability).toDouble()).toList(),
                        scheme.primary),
                  ]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Confidence index', style: t.titleMedium),
                const SizedBox(height: 4),
                Text(
                  indices.length < 2
                      ? 'From your weekly check-ins. The trend appears after your second one.'
                      : 'From your weekly check-ins (0-100). Started at ${indices.first}, now ${indices.last}.',
                  style: t.bodySmall,
                ),
                if (indices.length >= 2) ...[
                  const SizedBox(height: 16),
                  SimpleLineChart(
                    height: 140,
                    series: [ChartSeries('Index', indices.map((e) => e.toDouble()).toList(), scheme.primary)],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Challenge levels', style: t.titleMedium),
                const SizedBox(height: 12),
                for (final d in priority) ...[
                  Row(
                    children: [
                      Expanded(child: Text(d.label)),
                      Text('Level ${earnedLevel(d, state.challenges)} / 5', style: t.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: earnedLevel(d, state.challenges) / 5,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Challenge history', style: t.titleMedium),
          const SizedBox(height: 12),
          if (state.reviewedChallenges.isEmpty) const Text('Nothing here yet.'),
          for (final c in state.reviewedChallenges) ...[
            _HistoryTile(challenge: c),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.challenge});
  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = challenge;
    final skipped = c.status == ChallengeStatus.skipped;
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Pill(c.domain.label),
            const SizedBox(width: 8),
            Pill(skipped ? 'Set aside' : 'Feared outcome: ${c.fearedOutcome?.label ?? '-'}'),
          ]),
          const SizedBox(height: 8),
          Text(c.title, style: t.titleSmall),
          if (!skipped) ...[
            const SizedBox(height: 6),
            Text('Forecast ${c.predictedProbability}% → ${c.updatedProbability ?? '-'}%', style: t.bodySmall),
            if (c.learned.isNotEmpty) ...[const SizedBox(height: 6), Text(c.learned)],
          ],
        ],
      ),
    );
  }
}
