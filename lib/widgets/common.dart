import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.color, this.onTap, this.padding});
  final Widget child;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding ?? const EdgeInsets.all(20), child: child),
      ),
    );
  }
}

/// 0-100 slider with a live value and end labels.
class PercentSlider extends StatelessWidget {
  const PercentSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.lowLabel = '0%',
    this.highLabel = '100%',
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final String lowLabel;
  final String highLabel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: t.titleSmall)),
            Text('$value%', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          max: 100,
          divisions: 20,
          label: '$value%',
          onChanged: (v) => onChanged(v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(lowLabel, style: t.bodySmall), Text(highLabel, style: t.bodySmall)],
        ),
      ],
    );
  }
}

/// Five-point choice (0-4) shown as wrapping chips.
class ScaleChoice extends StatelessWidget {
  const ScaleChoice({super.key, required this.labels, required this.value, required this.onChanged});
  final List<String> labels;
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          ChoiceChip(label: Text(labels[i]), selected: value == i, onSelected: (_) => onChanged(i)),
      ],
    );
  }
}

class Field extends StatelessWidget {
  const Field({super.key, required this.controller, required this.label, this.hint, this.maxLines = 3});
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label, hintText: hint, alignLabelWithHint: true),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(99)),
      child: Text(text,
          style: TextStyle(color: scheme.onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      color: scheme.errorContainer.withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Extra support could help', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'You said worry about judgment is getting in the way a lot. This app is training, '
            'not treatment. A psychologist or counsellor can offer CBT for social anxiety, which '
            'has strong evidence. You can keep using the app alongside that.',
          ),
          const SizedBox(height: 8),
          const Text('See Profile > Support for where to start.'),
        ],
      ),
    );
  }
}
