/// On-device, rule-based coaching for practice conversations.
/// No AI, no network: it looks for patterns linked to unassertive
/// communication (apologising, hedging, putting yourself down,
/// over-explaining) and for clear, direct statements.
///
/// It is deliberately gentle: a polite or brief style is not treated as a
/// problem on its own.
library;

final _apology = RegExp(r"\b(sorry|apologi[sz]e|my bad|forgive me)\b", caseSensitive: false);

final _hedges = <RegExp>[
  RegExp(r"\bjust\b", caseSensitive: false),
  RegExp(r"\bmaybe\b", caseSensitive: false),
  RegExp(r"\bkind of\b|\bkinda\b|\bsort of\b", caseSensitive: false),
  RegExp(r"\bi guess\b", caseSensitive: false),
  RegExp(r"\bprobably\b", caseSensitive: false),
  RegExp(r"\bif that'?s (ok|okay|alright|fine)\b", caseSensitive: false),
  RegExp(r"\bdoes that make sense\b\??", caseSensitive: false),
  RegExp(r"\bi'?m not sure( if| but)?\b", caseSensitive: false),
];

final _selfPutDown = RegExp(
  r"\b(this (might|may) be (a )?(stupid|dumb|silly)( question| idea)?|stupid question|dumb question|i'?m not (an expert|smart)|i might be wrong|ignore me|i don'?t know much)\b",
  caseSensitive: false,
);

final _clearStance = RegExp(
  r"\b(i think|i believe|i'?d suggest|i suggest|i recommend|i prefer|i'?d prefer|i disagree|i see it differently|my view|i'?d like|i want|i can'?t|i won'?t|no(?=[,.!])|my idea|i propose|let'?s)\b",
  caseSensitive: false,
);

final _reason = RegExp(r"\b(because|since|so that|the reason|for example|e\.g\.)\b", caseSensitive: false);

final _crisis = RegExp(
  r"\b(kill(ing)? myself|suicid\w*|end(ing)? my life|want to die|don'?t want to (live|be alive)|self[- ]?harm|hurt(ing)? myself|cut(ting)? myself)\b",
  caseSensitive: false,
);

bool looksLikeCrisis(String text) => _crisis.hasMatch(text);

int _words(String s) => s.trim().isEmpty ? 0 : s.trim().split(RegExp(r'\s+')).length;

/// Signals found in one message.
class MessageSignals {
  MessageSignals(String text)
      : apologies = _apology.allMatches(text).length,
        hedges = _hedges.fold(0, (n, r) => n + r.allMatches(text).length),
        putDown = _selfPutDown.hasMatch(text),
        stance = _clearStance.hasMatch(text),
        reason = _reason.hasMatch(text),
        question = text.contains('?'),
        words = _words(text);

  final int apologies;
  final int hedges;
  final bool putDown;
  final bool stance;
  final bool reason;
  final bool question;
  final int words;

  /// Clear enough for the other character to engage with it.
  bool get isClear => words >= 4 && (stance || reason) && apologies == 0 && !putDown;

  int get weakness => apologies * 2 + hedges + (putDown ? 3 : 0);
}

/// Removes apologies, hedges and put-downs to suggest a more direct version.
String strengthen(String text) {
  var s = text;
  s = s.replaceAll(RegExp(r"^\s*(sorry|i'?m sorry)[,.!]?\s*(but\s*)?", caseSensitive: false), '');
  s = s.replaceAll(RegExp(r",?\s*(sorry|my bad)[,.!]?", caseSensitive: false), '');
  s = s.replaceAll(_selfPutDown, '');
  for (final h in _hedges) {
    s = s.replaceAll(h, '');
  }
  s = s.replaceAllMapped(RegExp(r'\s+([,.!?])'), (m) => m[1]!);
  s = s.replaceAllMapped(RegExp(r',\s*([.!?])'), (m) => m[1]!);
  s = s.replaceAll(RegExp(r',\s*$'), '');
  s = s.replaceAll(RegExp(r'^[\s,.]+'), '');
  s = s.replaceAll(RegExp(r'^(but|and|so)\b[\s,]*', caseSensitive: false), '');
  s = s.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  if (s.isEmpty) return text.trim();
  return s[0].toUpperCase() + s.substring(1);
}

class PracticeFeedback {
  const PracticeFeedback({required this.strengths, required this.tryNext, this.original, this.stronger});
  final List<String> strengths;
  final List<String> tryNext;
  final String? original;
  final String? stronger;

  String format() {
    final b = StringBuffer('What worked\n');
    for (final s in strengths) {
      b.writeln('- $s');
    }
    if (tryNext.isNotEmpty) {
      b.writeln('\nTry next time');
      for (final s in tryNext) {
        b.writeln('- $s');
      }
    }
    if (original != null && stronger != null) {
      b
        ..writeln('\nA more direct version')
        ..writeln('You said: "$original"')
        ..writeln('Try: "$stronger"');
    }
    b.write('\nThis feedback is automatic and looks for common patterns. You know the situation best.');
    return b.toString();
  }
}

/// Builds feedback from the user's lines in a practice conversation.
/// [scenarioId] tunes the advice (e.g. brevity matters most when saying no).
PracticeFeedback analyse(List<String> userLines, {required String scenarioId}) {
  final lines = userLines.where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) {
    return const PracticeFeedback(strengths: ['You opened the scenario. Next time, try sending a reply.'], tryNext: []);
  }
  final signals = lines.map(MessageSignals.new).toList();
  final apologies = signals.fold(0, (n, s) => n + s.apologies);
  final hedges = signals.fold(0, (n, s) => n + s.hedges);
  final putDowns = signals.where((s) => s.putDown).length;
  final clear = signals.where((s) => s.isClear).length;
  final reasons = signals.where((s) => s.reason).length;
  final questions = signals.where((s) => s.question).length;
  final avgWords = signals.fold(0, (n, s) => n + s.words) / signals.length;

  final strengths = <String>[];
  final tryNext = <String>[];

  strengths.add('You stayed in the conversation for ${lines.length} replies. That is the practice.');
  if (clear > 0) strengths.add('You made a clear point $clear time${clear == 1 ? '' : 's'}.');
  if (apologies == 0) strengths.add('No unnecessary apologies.');
  if (reasons > 0 && scenarioId != 'say_no') strengths.add('You backed up what you said with a reason.');
  if (questions > 0 && (scenarioId == 'meet_new' || scenarioId == 'senior_idea')) {
    strengths.add('You asked questions, which keeps a conversation going.');
  }

  if (putDowns > 0) {
    tryNext.add('Drop the put-downs ("this might be stupid..."). They make others take your point less '
        'seriously and you do not need them.');
  }
  if (apologies > 0) {
    tryNext.add('You apologised $apologies time${apologies == 1 ? '' : 's'}. Save "sorry" for real mistakes.');
  }
  if (hedges >= 3) {
    tryNext.add('Words like "just", "maybe" and "kind of" soften your point. Try one reply without them.');
  }
  if (scenarioId == 'say_no' && avgWords > 30) {
    tryNext.add('Your replies were long. A no can be one sentence: "I can\'t this Saturday, but good luck."');
  }
  if ((scenarioId == 'disagree' || scenarioId == 'challenged') && reasons == 0) {
    tryNext.add('Add one concrete reason or example: "I see it differently because..."');
  }
  if (scenarioId == 'meet_new' && questions == 0) {
    tryNext.add('Ask one question back. People enjoy being asked about themselves.');
  }
  if (avgWords < 4 && scenarioId != 'say_no') {
    tryNext.add('Your replies were very short. Add one detail or opinion so the other person has something to respond to.');
  }
  if (clear == 0 && tryNext.length < 2) {
    tryNext.add('State your view directly once, starting with "I think..." or "I\'d suggest...".');
  }

  String? original;
  String? stronger;
  var worst = -1;
  for (var i = 0; i < signals.length; i++) {
    if (signals[i].weakness > 0 && (worst < 0 || signals[i].weakness > signals[worst].weakness)) worst = i;
  }
  if (worst >= 0) {
    final s = strengthen(lines[worst]);
    if (s != lines[worst].trim()) {
      original = lines[worst].trim();
      stronger = s;
    }
  }

  return PracticeFeedback(strengths: strengths, tryNext: tryNext.take(2).toList(), original: original, stronger: stronger);
}
