import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/programme.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'thought_record_form.dart';

class MindsetScreen extends StatelessWidget {
  const MindsetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Mindset', style: t.headlineSmall),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThoughtRecordScreen())),
            icon: const Icon(Icons.add),
            label: const Text('Test a thought'),
          ),
          const SizedBox(height: 24),
          Text('Your thought journal', style: t.titleMedium),
          const SizedBox(height: 12),
          if (state.thoughts.isEmpty)
            const Text('Thoughts you test will appear here, so you can spot recurring patterns.')
          else
            for (final r in state.thoughts) ...[
              _ThoughtTile(record: r),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 24),
          Text('Ideas library', style: t.titleMedium),
          const SizedBox(height: 12),
          for (final l in lessons.values)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(l.title),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.body),
                const SizedBox(height: 8),
                Text('Try this: ${l.tryThis}', style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                if (l.source != null) ...[const SizedBox(height: 6), Text(l.source!, style: t.bodySmall)],
              ],
            ),
        ],
      ),
    );
  }
}

class _ThoughtTile extends StatelessWidget {
  const _ThoughtTile({required this.record});
  final ThoughtRecord record;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final date = DateTime.fromMillisecondsSinceEpoch(record.createdAt);
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${date.day}/${date.month}/${date.year} · ${record.situation}', style: t.labelMedium),
          const SizedBox(height: 6),
          Text('"${record.automaticThought}"', style: t.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          Text(record.balancedResponse),
          const SizedBox(height: 8),
          Text('Belief: ${record.beliefBefore}% → ${record.beliefAfter}%', style: t.bodySmall),
        ],
      ),
    );
  }
}
