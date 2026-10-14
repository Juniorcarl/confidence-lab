import '../content/assessment.dart';
import '../content/challenges.dart';
import '../content/programme.dart';
import '../models/models.dart';

/// Pure functions that drive personalisation. No Flutter imports, so they
/// are covered by plain unit tests in test/adaptive_test.dart.

/// Domains ordered from most to least difficult for this user.
List<Domain> domainPriority(Map<String, int> assessment) {
  final scores = {for (final d in Domain.values) d: 0};
  for (final c in assessmentCategories) {
    scores[c.domain] = scores[c.domain]! + (assessment[c.id] ?? 0);
  }
  final ordered = Domain.values.toList()
    ..sort((a, b) {
      final diff = scores[b]!.compareTo(scores[a]!);
      return diff != 0 ? diff : a.index.compareTo(b.index);
    });
  return ordered;
}

/// The level the user has earned in [domain] from their challenge history.
///
/// Rules (graduated exposure, no punishment):
/// - Start at level 1.
/// - Two completed challenges in a row where the feared outcome did not
///   fully happen -> move up one level.
/// - A completed challenge where the feared outcome DID happen -> stay and
///   repeat (it still counts as practice; the streak resets).
/// - Two skips in a row -> move down one level (minimum 1).
int earnedLevel(Domain domain, List<Challenge> history) {
  final items = history
      .where((c) => c.domain == domain && c.isReviewed)
      .toList()
    // Only one challenge is open at a time, so creation order is review order.
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  var level = 1;
  var successes = 0;
  var skips = 0;
  for (final c in items) {
    if (c.status == ChallengeStatus.skipped) {
      skips++;
      successes = 0;
      if (skips >= 2) {
        level = (level - 1).clamp(1, 5);
        skips = 0;
      }
      continue;
    }
    skips = 0;
    if (c.fearedOutcome == FearedOutcome.yes) {
      successes = 0;
      continue;
    }
    // Only challenges at (or above) the current level count towards moving up.
    if (c.level >= level) successes++;
    if (successes >= 2) {
      level = (level + 1).clamp(1, 5);
      successes = 0;
    }
  }
  return level;
}

/// Level to offer today: earned level, capped by the current phase.
int offeredLevel(Domain domain, List<Challenge> history, int day) =>
    earnedLevel(domain, history).clamp(1, phaseForDay(day).maxLevel);

class ChallengeOption {
  const ChallengeOption(this.template, this.label);
  final ChallengeTemplate template;

  /// "Your focus", "Also useful" or "Gentler option".
  final String label;
}

/// Three options for today: the main focus area, a secondary area, and an
/// easier version. Giving a choice (including an easier one) reduces
/// avoidance more than a single all-or-nothing task.
List<ChallengeOption> challengeOptions({
  required Map<String, int> assessment,
  required List<Challenge> history,
  required int day,
}) {
  final priority = domainPriority(assessment);
  // Alternate the top two domains day by day; every 5th day rotate in a
  // third domain so practice varies across contexts.
  final primary = day % 5 == 0 ? priority[2] : (day.isOdd ? priority[0] : priority[1]);
  final secondary = primary == priority[0] ? priority[1] : priority[0];

  final pLevel = offeredLevel(primary, history, day);
  final sLevel = offeredLevel(secondary, history, day);

  final main = nearestTemplate(primary, pLevel, day);
  final second = nearestTemplate(secondary, sLevel, day + 1);
  final easier = nearestTemplate(primary, (pLevel - 1).clamp(1, 5), day + 2);

  final options = <ChallengeOption>[
    ChallengeOption(main, 'Your focus'),
    ChallengeOption(second, 'Also useful'),
  ];
  if (easier.title != main.title) {
    options.add(ChallengeOption(easier, 'Gentler option'));
  }
  return options;
}

/// Programme day: based on completed sessions, not the calendar, so missing
/// a day never "breaks" anything.
int programmeDay(int sessionsCompleted) => (sessionsCompleted + 1).clamp(1, programmeLength);

/// Average drop in expected likelihood of the feared outcome, across
/// reviewed challenges. Positive = expecting catastrophe less.
double? averageExpectancyChange(List<Challenge> history) {
  final changes = history.map((c) => c.expectancyChange).whereType<int>().toList();
  if (changes.isEmpty) return null;
  return changes.reduce((a, b) => a + b) / changes.length;
}

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
