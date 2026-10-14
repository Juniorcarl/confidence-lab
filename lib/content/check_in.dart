/// Weekly check-in. These are original items written for this app, not a
/// validated clinical scale. Before using results as research outcomes,
/// license and add a validated measure (e.g. Brief Fear of Negative
/// Evaluation, Mini-SPIN) and keep this as the in-app progress signal.
class CheckInItem {
  const CheckInItem(this.text, {this.reverse = false, this.scored = true});
  final String text;

  /// true when agreeing means MORE confidence.
  final bool reverse;
  final bool scored;
}

const checkInScaleLabels = ['Not at all', 'A little', 'Somewhat', 'Very much', 'Extremely'];

const checkInItems = <CheckInItem>[
  CheckInItem('I worry about what people think of me when I speak.'),
  CheckInItem('I avoid speaking up because I might be judged.'),
  CheckInItem('When I share an opinion, I trust it is worth hearing.', reverse: true),
  CheckInItem('I start conversations when I want to.', reverse: true),
  CheckInItem('I say what I prefer, even if others might disagree.', reverse: true),
  CheckInItem('People can hear me clearly when I speak.', reverse: true),
  // Not part of the score: used to suggest professional support.
  CheckInItem('Worry about being judged gets in the way of my work, studies or relationships.',
      scored: false),
];

/// Index of the interference item.
const interferenceItemIndex = 6;

/// 0-100, higher = more confident. Returns null for incomplete answers.
int? confidenceIndex(List<int> answers) {
  if (answers.length < checkInItems.length) return null;
  var total = 0;
  var max = 0;
  for (var i = 0; i < checkInItems.length; i++) {
    final item = checkInItems[i];
    if (!item.scored) continue;
    final a = answers[i].clamp(0, 4);
    total += item.reverse ? a : 4 - a;
    max += 4;
  }
  return max == 0 ? null : (total * 100 / max).round();
}

/// "Very much" or "Extremely" on the interference item.
bool suggestsSupport(List<int> answers) =>
    answers.length > interferenceItemIndex && answers[interferenceItemIndex] >= 3;
