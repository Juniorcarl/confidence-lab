import '../logic/practice_feedback.dart';

/// Rehearsal scenarios. Everything runs on the device: the other person
/// follows a short script that reacts to whether the user's reply was
/// clear or vague, and feedback comes from practice_feedback.dart.
class Scenario {
  const Scenario(this.id, this.title, this.setup, this.opening, this.turns, this.closing);
  final String id;
  final String title;
  final String setup;
  final String opening;

  /// One entry per turn: what the other person says next.
  final List<ScriptTurn> turns;

  /// Said after the last scripted turn.
  final String closing;
}

class ScriptTurn {
  const ScriptTurn({required this.ifClear, required this.ifVague});

  /// Reply when the user's last message was clear and direct.
  final String ifClear;

  /// Reply when it was vague, apologetic or very short.
  final String ifVague;
}

const scenarios = <Scenario>[
  Scenario(
    'meet_new',
    'Introducing yourself',
    'You are at a work social. Someone you have not met is standing nearby.',
    'Hi! I don\'t think we\'ve met - are you with the events team?',
    [
      ScriptTurn(
        ifClear: 'Oh nice, good to meet you. How long have you been there?',
        ifVague: 'Ah, okay. So... what do you do there?',
      ),
      ScriptTurn(
        ifClear: 'That sounds interesting. What do you enjoy most about it?',
        ifVague: 'Right. Is it busy at the moment?',
      ),
      ScriptTurn(
        ifClear: 'Ha, I can relate. I\'m in finance, mostly spreadsheets, but the people are great.',
        ifVague: 'Mm. I\'m in finance myself. Lots of spreadsheets.',
      ),
    ],
    'Anyway, it was really nice talking to you. I\'ll see you around!',
  ),
  Scenario(
    'senior_idea',
    'Sharing an idea with a senior colleague',
    'Your manager asks the team for ideas on reducing missed appointments. You have one.',
    'Okay, anyone have thoughts on the missed appointments problem?',
    [
      ScriptTurn(
        ifClear: 'Interesting. How would that work in practice?',
        ifVague: 'Sorry, I didn\'t quite catch the idea. What exactly are you suggesting?',
      ),
      ScriptTurn(
        ifClear: 'And what would it cost us, roughly? Time or money.',
        ifVague: 'Hmm. I\'d need something more concrete before we try it.',
      ),
      ScriptTurn(
        ifClear: 'Okay. Can you write up a short proposal for Friday?',
        ifVague: 'Let\'s park it for now. If you can firm it up, bring it back next week.',
      ),
    ],
    'Thanks for speaking up. Let\'s move on to the next item.',
  ),
  Scenario(
    'disagree',
    'Disagreeing respectfully',
    'A colleague proposes a plan you think has a flaw.',
    'So I think we should just launch on Friday and fix issues as they come. Everyone agree?',
    [
      ScriptTurn(
        ifClear: 'Hmm, okay. Why do you think waiting is better?',
        ifVague: 'I think it\'s fine though. We can always fix things later.',
      ),
      ScriptTurn(
        ifClear: 'That\'s a fair point. But won\'t delaying cost us momentum?',
        ifVague: 'Honestly I\'d rather not slow down for small stuff.',
      ),
      ScriptTurn(
        ifClear: 'Okay, I hear you. What if we did a small test with a few users first?',
        ifVague: 'Let\'s just go with Friday then.',
      ),
    ],
    'Alright, let\'s take that to the team and decide together.',
  ),
  Scenario(
    'say_no',
    'Saying no without over-explaining',
    'A friend asks you to help them move this weekend, but you already have plans you want to keep.',
    'Hey, any chance you can help me move on Saturday? Should only take the whole day.',
    [
      ScriptTurn(
        ifClear: 'Ah, are you sure? It would really help.',
        ifVague: 'So is that a yes? I really need the help.',
      ),
      ScriptTurn(
        ifClear: 'Okay, fair enough. I\'ll ask someone else.',
        ifVague: 'Come on, it\'s only one day. Please?',
      ),
      ScriptTurn(
        ifClear: 'No worries at all. Thanks for being straight with me.',
        ifVague: 'Hmm, okay. Let me know if you change your mind.',
      ),
    ],
    'Talk soon!',
  ),
  Scenario(
    'challenged',
    'When someone challenges your opinion',
    'You said in a meeting that the new booking form is confusing. A colleague pushes back.',
    'Honestly I don\'t see what\'s confusing about it. It\'s pretty standard.',
    [
      ScriptTurn(
        ifClear: 'Okay, which part specifically?',
        ifVague: 'I mean, nobody else has complained.',
      ),
      ScriptTurn(
        ifClear: 'Hm. I hadn\'t thought about it from a patient\'s side.',
        ifVague: 'I still think it\'s fine.',
      ),
      ScriptTurn(
        ifClear: 'Fair enough. Could you mark up what you\'d change?',
        ifVague: 'Let\'s leave it as it is for now.',
      ),
    ],
    'Okay, thanks. Let\'s keep going.',
  ),
];

Scenario scenarioById(String id) => scenarios.firstWhere((s) => s.id == id, orElse: () => scenarios.first);

class PracticeMessage {
  const PracticeMessage(this.role, this.content);
  final String role; // 'user' or 'assistant'
  final String content;
}

class PracticeReply {
  const PracticeReply(this.text, {this.crisis = false, this.ended = false});
  final String text;

  /// Possible crisis language was detected; the role-play stops.
  final bool crisis;

  /// The script has finished; the next step is feedback.
  final bool ended;
}

const crisisText =
    'It sounds like things might be really hard right now. This practice tool can\'t help with that, '
    'but people can. If you are in danger or thinking about harming yourself, please contact your local '
    'emergency number or a crisis line now, or reach out to someone you trust.';

abstract class PracticeService {
  /// mode: 'reply' continues the role-play, 'feedback' ends it with coaching.
  Future<PracticeReply> send(String scenarioId, List<PracticeMessage> messages, {required String mode});
}

/// Free, offline practice partner.
class LocalPracticeService implements PracticeService {
  @override
  Future<PracticeReply> send(String scenarioId, List<PracticeMessage> messages, {required String mode}) async {
    final scenario = scenarioById(scenarioId);
    final userLines = messages.where((m) => m.role == 'user').map((m) => m.content).toList();

    if (looksLikeCrisis(userLines.join('\n'))) {
      return const PracticeReply(crisisText, crisis: true);
    }

    if (mode == 'feedback') {
      return PracticeReply(analyse(userLines, scenarioId: scenarioId).format());
    }

    // A short pause so the reply feels conversational.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final turn = userLines.length - 1;
    if (turn >= scenario.turns.length) {
      return PracticeReply(scenario.closing, ended: true);
    }
    final clear = MessageSignals(userLines.last).isClear;
    final step = scenario.turns[turn];
    return PracticeReply(clear ? step.ifClear : step.ifVague);
  }
}
