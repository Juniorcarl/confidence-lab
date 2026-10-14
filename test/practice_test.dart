import 'package:confidence_lab/data/practice_service.dart';
import 'package:confidence_lab/logic/practice_feedback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageSignals', () {
    test('clear statements are recognised', () {
      expect(MessageSignals('I think we should wait because testing matters.').isClear, isTrue);
      expect(MessageSignals('No, I can\'t this Saturday.').isClear, isTrue);
    });

    test('apologetic or tiny replies are not clear', () {
      expect(MessageSignals('Sorry, I think maybe we could wait').isClear, isFalse);
      expect(MessageSignals('ok').isClear, isFalse);
    });

    test('counts apologies and hedges', () {
      final s = MessageSignals('Sorry, I just maybe think it is kind of confusing, sorry');
      expect(s.apologies, 2);
      expect(s.hedges, 3);
    });
  });

  group('strengthen', () {
    test('removes apology, put-down and hedges', () {
      expect(
        strengthen('Sorry, this might be a stupid question, but maybe we could just send SMS reminders?'),
        'We could send SMS reminders?',
      );
    });

    test('removes tag hedges at the end', () {
      expect(strengthen('I\'m sorry but I kind of think it\'s confusing, does that make sense?'),
          'I think it\'s confusing');
    });

    test('leaves a direct sentence alone', () {
      expect(strengthen('I think we should wait.'), 'I think we should wait.');
    });
  });

  group('analyse', () {
    test('praises clear replies without apologies', () {
      final f = analyse(['I think we should wait because the form has bugs.', 'I\'d suggest a small test first.'],
          scenarioId: 'disagree');
      expect(f.strengths.join(' '), contains('clear point'));
      expect(f.strengths.join(' '), contains('No unnecessary apologies'));
      expect(f.stronger, isNull);
    });

    test('flags apologies and offers a stronger version', () {
      final f = analyse(['Sorry, maybe we could just wait?', 'Sorry, I guess it is fine'], scenarioId: 'disagree');
      expect(f.tryNext.length, lessThanOrEqualTo(2));
      expect(f.tryNext.join(' '), contains('apologised 2 times'));
      expect(f.stronger, isNotNull);
    });

    test('long refusals get brevity advice in say_no', () {
      final long = List.filled(40, 'word').join(' ');
      final f = analyse([long], scenarioId: 'say_no');
      expect(f.tryNext.join(' '), contains('one sentence'));
    });

    test('format includes sections', () {
      final text = analyse(['ok'], scenarioId: 'meet_new').format();
      expect(text, contains('What worked'));
      expect(text, contains('Try next time'));
    });
  });

  group('LocalPracticeService', () {
    final service = LocalPracticeService();

    test('replies differently to clear and vague messages', () async {
      final s = scenarioById('disagree');
      final clear = await service.send(
          s.id, [PracticeMessage('assistant', s.opening), const PracticeMessage('user', 'I disagree because we have open bugs.')],
          mode: 'reply');
      final vague = await service.send(
          s.id, [PracticeMessage('assistant', s.opening), const PracticeMessage('user', 'um maybe')], mode: 'reply');
      expect(clear.text, s.turns[0].ifClear);
      expect(vague.text, s.turns[0].ifVague);
    });

    test('ends after the scripted turns', () async {
      final s = scenarioById('say_no');
      final msgs = <PracticeMessage>[PracticeMessage('assistant', s.opening)];
      for (var i = 0; i <= s.turns.length; i++) {
        msgs.add(const PracticeMessage('user', 'No, I can\'t.'));
      }
      final r = await service.send(s.id, msgs, mode: 'reply');
      expect(r.ended, isTrue);
      expect(r.text, s.closing);
    });

    test('detects crisis language', () async {
      final r = await service.send('meet_new', [const PracticeMessage('user', 'I want to die')], mode: 'reply');
      expect(r.crisis, isTrue);
    });
  });
}
