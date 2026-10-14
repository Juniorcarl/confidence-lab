import 'package:confidence_lab/content/challenges.dart';
import 'package:confidence_lab/content/check_in.dart';
import 'package:confidence_lab/content/programme.dart';
import 'package:confidence_lab/logic/adaptive.dart';
import 'package:confidence_lab/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

var _t = 0;

Challenge _done(Domain d, int level, FearedOutcome outcome, {int predicted = 70, int updated = 40}) {
  _t += 1000;
  return Challenge(
    id: 'c$_t',
    createdAt: _t,
    domain: d,
    level: level,
    title: 't',
    prediction: 'p',
    predictedProbability: predicted,
    safetyBehavioursToDrop: const [],
  ).review(
    whatHappened: 'x',
    fearedOutcome: outcome,
    anxietyPeak: 50,
    signsOfInterest: '',
    updatedProbability: updated,
    learned: '',
  );
}

Challenge _skipped(Domain d, int level) {
  _t += 1000;
  return Challenge(
    id: 's$_t',
    createdAt: _t,
    domain: d,
    level: level,
    title: 't',
    prediction: 'p',
    predictedProbability: 50,
    safetyBehavioursToDrop: const [],
  ).skip();
}

void main() {
  group('domainPriority', () {
    test('orders domains by difficulty ratings', () {
      final p = domainPriority({'voice': 4, 'groups': 3, 'selfTrust': 0, 'fearOfJudgment': 0});
      expect(p.first, Domain.voice);
      expect(p[1], Domain.groups);
    });

    test('combines the two speaking-up categories', () {
      final p = domainPriority({'selfTrust': 3, 'fearOfJudgment': 3, 'voice': 4});
      expect(p.first, Domain.speakingUp);
    });
  });

  group('earnedLevel', () {
    test('starts at 1', () {
      expect(earnedLevel(Domain.groups, []), 1);
    });

    test('two successes move up one level', () {
      final h = [
        _done(Domain.groups, 1, FearedOutcome.no),
        _done(Domain.groups, 1, FearedOutcome.partly),
      ];
      expect(earnedLevel(Domain.groups, h), 2);
    });

    test('feared outcome happening resets the streak but does not drop the level', () {
      final h = [
        _done(Domain.groups, 1, FearedOutcome.no),
        _done(Domain.groups, 1, FearedOutcome.yes),
        _done(Domain.groups, 1, FearedOutcome.no),
      ];
      expect(earnedLevel(Domain.groups, h), 1);
    });

    test('two skips in a row step down, never below 1', () {
      final h = [
        _done(Domain.voice, 1, FearedOutcome.no),
        _done(Domain.voice, 1, FearedOutcome.no), // -> 2
        _skipped(Domain.voice, 2),
        _skipped(Domain.voice, 2), // -> 1
        _skipped(Domain.voice, 1),
        _skipped(Domain.voice, 1), // stays 1
      ];
      expect(earnedLevel(Domain.voice, h), 1);
    });

    test('easier challenges below the current level do not count towards moving up', () {
      final h = [
        _done(Domain.authority, 1, FearedOutcome.no),
        _done(Domain.authority, 1, FearedOutcome.no), // -> 2
        _done(Domain.authority, 1, FearedOutcome.no),
        _done(Domain.authority, 1, FearedOutcome.no),
      ];
      expect(earnedLevel(Domain.authority, h), 2);
    });

    test('other domains are ignored', () {
      final h = [_done(Domain.voice, 1, FearedOutcome.no), _done(Domain.voice, 1, FearedOutcome.no)];
      expect(earnedLevel(Domain.groups, h), 1);
    });

    test('never exceeds 5', () {
      final h = <Challenge>[];
      for (var l = 1; l <= 6; l++) {
        h
          ..add(_done(Domain.initiating, l.clamp(1, 5), FearedOutcome.no))
          ..add(_done(Domain.initiating, l.clamp(1, 5), FearedOutcome.no));
      }
      expect(earnedLevel(Domain.initiating, h), 5);
    });
  });

  group('offeredLevel', () {
    test('is capped by the phase', () {
      final h = <Challenge>[];
      for (var l = 1; l <= 4; l++) {
        h
          ..add(_done(Domain.groups, l, FearedOutcome.no))
          ..add(_done(Domain.groups, l, FearedOutcome.no));
      }
      expect(earnedLevel(Domain.groups, h), 5);
      expect(offeredLevel(Domain.groups, h, 3), phaseForDay(3).maxLevel);
      expect(offeredLevel(Domain.groups, h, 25), 5);
    });
  });

  group('challengeOptions', () {
    test('returns distinct options from the user\'s top domains', () {
      final opts = challengeOptions(
        assessment: {'groups': 4, 'authority': 3},
        history: const [],
        day: 1,
      );
      expect(opts.length, greaterThanOrEqualTo(2));
      expect(opts.first.template.domain, Domain.groups);
      expect(opts[1].template.domain, Domain.authority);
      expect(opts.map((o) => o.template.title).toSet().length, opts.length);
    });

    test('every domain has a template at every level it can reach', () {
      for (final d in Domain.values) {
        for (var l = 1; l <= 5; l++) {
          expect(nearestTemplate(d, l, 0).domain, d);
        }
      }
    });
  });

  group('programme', () {
    test('has a lesson for each of the 30 days', () {
      expect(dailyLessonIds.length, programmeLength);
      for (var d = 1; d <= programmeLength; d++) {
        expect(lessonForDay(d).title, isNotEmpty);
      }
    });

    test('day is based on sessions completed and capped at 30', () {
      expect(programmeDay(0), 1);
      expect(programmeDay(6), 7);
      expect(programmeDay(45), 30);
    });
  });

  group('expectancy and check-in scoring', () {
    test('average expectancy change', () {
      final h = [
        _done(Domain.voice, 1, FearedOutcome.no, predicted: 80, updated: 40),
        _done(Domain.voice, 1, FearedOutcome.no, predicted: 60, updated: 50),
      ];
      expect(averageExpectancyChange(h), 25);
      expect(averageExpectancyChange([]), isNull);
    });

    test('confidence index reverse-codes and ignores the interference item', () {
      // Worst possible answers on scored items, max interference.
      expect(confidenceIndex([4, 4, 0, 0, 0, 0, 4]), 0);
      // Best possible answers.
      expect(confidenceIndex([0, 0, 4, 4, 4, 4, 0]), 100);
      expect(confidenceIndex([0, 0]), isNull);
    });

    test('support suggestion triggers on high interference', () {
      expect(suggestsSupport([0, 0, 0, 0, 0, 0, 3]), isTrue);
      expect(suggestsSupport([4, 4, 4, 4, 4, 4, 2]), isFalse);
    });
  });

  group('models', () {
    test('challenge round-trips through a map', () {
      final c = _done(Domain.assertiveness, 3, FearedOutcome.partly);
      final back = Challenge.fromMap(c.toMap());
      expect(back.domain, Domain.assertiveness);
      expect(back.fearedOutcome, FearedOutcome.partly);
      expect(back.status, ChallengeStatus.done);
      expect(back.expectancyChange, 30);
    });
  });
}
