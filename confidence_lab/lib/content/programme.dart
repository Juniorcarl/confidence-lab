/// The 30-day programme: phases and the micro-lesson for each day.
///
/// Lessons are short (under a minute to read) and each one ends with
/// something to do, not just something to know.
class Phase {
  const Phase(this.number, this.title, this.firstDay, this.lastDay, this.focus, this.maxLevel);
  final int number;
  final String title;
  final int firstDay;
  final int lastDay;
  final String focus;

  /// Hardest challenge level offered in this phase (1-5).
  final int maxLevel;

  bool contains(int day) => day >= firstDay && day <= lastDay;
}

const phases = <Phase>[
  Phase(1, 'Awareness and self-trust', 1, 7,
      'Notice predictions and safety behaviours. Try small, low-stakes experiments.', 2),
  Phase(2, 'Voice and assertiveness', 8, 14,
      'Speak so you can be heard, finish sentences, state preferences.', 3),
  Phase(3, 'Social confidence', 15, 21,
      'Strangers, groups and authority figures. Handle disagreement and mistakes.', 4),
  Phase(4, 'Real-world application', 22, 30,
      'Bigger experiments in the situations that matter most to you.', 5),
];

const programmeLength = 30;

Phase phaseForDay(int day) =>
    phases.firstWhere((p) => p.contains(day.clamp(1, programmeLength)));

class Lesson {
  const Lesson(this.id, this.title, this.body, this.tryThis, {this.source});
  final String id;
  final String title;
  final String body;
  final String tryThis;
  final String? source;
}

const lessons = <String, Lesson>{
  'skill': Lesson(
    'skill',
    'Confidence follows action',
    'Research on self-esteem suggests feeling good about yourself is mostly a result of doing '
        'things, not the cause of doing them. You do not need to feel confident before you act. '
        'Each small action is evidence your brain can learn from.',
    'Today, notice one moment where you held back. No need to fix it yet, just notice it.',
    source: 'Baumeister et al. (2003), Psychological Science in the Public Interest',
  ),
  'predictions': Lesson(
    'predictions',
    'Fear makes predictions',
    'Anxiety is a forecast: "If I speak, they will think I am stupid." Forecasts can be tested. '
        'In this app every challenge starts with a written prediction and how likely you think '
        'it is. Afterwards you compare it with what actually happened.',
    'Write down one prediction your fear makes about tomorrow.',
    source: 'Craske et al. (2014), Behaviour Research and Therapy',
  ),
  'safety': Lesson(
    'safety',
    'Safety behaviours keep fear alive',
    'Speaking quietly, rehearsing every word, apologising first, avoiding eye contact, '
        'keeping it short - these feel protective. But they stop you learning that you would '
        'have been fine without them, and they can make you look more anxious, not less.',
    'Pick one safety behaviour you use. In your next challenge, drop just that one.',
    source: 'Clark & Wells (1995) cognitive model of social anxiety',
  ),
  'attention': Lesson(
    'attention',
    'Point your attention outward',
    'When anxious, attention turns inward: "How do I sound? Am I red?" That inner picture '
        'is usually worse than what others see. Turning attention to the other person - their '
        'words, their face, the topic - reduces anxiety and gives you real information.',
    'In your next conversation, try to remember two things the other person said.',
    source: 'Clark & Wells (1995)',
  ),
  'transparency': Lesson(
    'transparency',
    'Your nerves are less visible than you think',
    'Nervous speakers consistently believe their anxiety is obvious. Audiences rate them as '
        'much calmer than they feel. This is called the illusion of transparency.',
    'Before your challenge, remind yourself: "They see much less than I feel."',
    source: 'Savitsky & Gilovich (2003), Journal of Experimental Social Psychology',
  ),
  'liking': Lesson(
    'liking',
    'People like you more than you know',
    'After conversations, people reliably underestimate how much the other person liked them '
        'and enjoyed talking. Shyer people underestimate the most. Observers watching the same '
        'conversations could see the liking that participants missed.',
    'After your next conversation, write down any sign that the other person was interested.',
    source: 'Boothby et al. (2018), Psychological Science',
  ),
  'replay': Lesson(
    'replay',
    'Stop the post-mortem',
    'Replaying a conversation afterwards, looking for mistakes, builds a memory that is more '
        'negative than what happened. When you review a challenge here, you also record what '
        'went okay and what you noticed about the other person.',
    'If you catch yourself replaying, ask: "What would a neutral observer have seen?"',
    source: 'Clark & Wells (1995)',
  ),
  'compassion': Lesson(
    'compassion',
    'Be on your own side',
    'Self-compassion - treating yourself like you would a friend who struggled - is linked to '
        'steadier self-worth than self-esteem, because it does not depend on things going well. '
        'It is not letting yourself off the hook. It is what makes it safe to try again.',
    'Write your balanced thought today as if talking to a friend.',
    source: 'Neff (2011); Neff & Vonk (2009)',
  ),
  'volume': Lesson(
    'volume',
    'Finish the sentence',
    'Trailing off and speaking quietly are common safety behaviours: if no one hears you, '
        'no one can judge you. Speaking to the back of the room, and landing the last word of '
        'the sentence, usually feels much louder to you than it sounds to others.',
    'Say one sentence today at a volume that feels "slightly too loud". Ask if it was.',
  ),
  'preference': Lesson(
    'preference',
    'Preferences are not demands',
    '"I would prefer the earlier time" is not rude. Stating a preference gives others '
        'information. Assertiveness sits between staying silent and being aggressive: '
        'clear, brief, respectful.',
    'State one genuine preference today without adding a justification.',
  ),
  'disagree': Lesson(
    'disagree',
    'Disagreeing well',
    'A simple structure: acknowledge, then add. "I see why you\'d go with A. I\'d lean towards '
        'B because..." Disagreement about ideas is normal in healthy teams and relationships.',
    'Notice one small thing you disagree with today. Say it with the acknowledge-then-add shape.',
  ),
  'no': Lesson(
    'no',
    'No without the essay',
    'Long explanations invite negotiation and signal that you think you are doing something '
        'wrong. A short reason, or none, is enough. "I can\'t take that on this week."',
    'Practise saying no to something small with one sentence only.',
  ),
  'mistakes': Lesson(
    'mistakes',
    'Recovering from a stumble',
    'Everyone stumbles over words. Listeners barely register it unless the speaker makes a big '
        'deal of it. "Let me say that again" and carrying on is a confident move.',
    'If you stumble today, try "Let me rephrase that" and keep going.',
  ),
  'authority': Lesson(
    'authority',
    'Status is not a verdict on you',
    'Senior or impressive people are usually busy thinking about their own work, not grading '
        'you. A clear, brief question or idea is generally welcome. The fear is about status; '
        'the conversation is about the topic.',
    'Prepare one specific question for someone senior.',
  ),
  'groups': Lesson(
    'groups',
    'Getting in early',
    'In groups, the longer you wait, the bigger the first contribution feels. Saying something '
        'small early - agreeing with a point, asking a quick question - lowers the bar for '
        'everything after.',
    'In your next group conversation, say something in the first few minutes.',
  ),
  'variety': Lesson(
    'variety',
    'Practise in many places',
    'What you learn in one situation does not automatically transfer to others. Repeating '
        'experiments with different people, places and times makes the learning stick.',
    'Choose a challenge today in a place you have not practised before.',
    source: 'Craske et al. (2014)',
  ),
  'setbacks': Lesson(
    'setbacks',
    'Setbacks are data',
    'Sometimes the feared outcome partly happens. That is useful too: how bad was it really, and '
        'how did you cope? Most people find they handle it better than predicted.',
    'If a challenge went badly, rate how bad it was now compared with how bad you expected.',
  ),
  'help': Lesson(
    'help',
    'When to get extra support',
    'This app is training, not therapy. If fear of judgment stops you working, studying or '
        'seeing people, a psychologist can help - CBT for social anxiety is one of the best '
        'supported treatments in psychology.',
    'If that sounds like you, look at the support page in your Profile.',
  ),
};

/// Lesson id for each day of the programme (index 0 = day 1).
const dailyLessonIds = <String>[
  // Phase 1
  'skill', 'predictions', 'safety', 'attention', 'transparency', 'liking', 'replay',
  // Phase 2
  'compassion', 'volume', 'preference', 'disagree', 'no', 'mistakes', 'help',
  // Phase 3
  'authority', 'groups', 'liking', 'setbacks', 'attention', 'disagree', 'variety',
  // Phase 4
  'predictions', 'safety', 'variety', 'compassion', 'transparency', 'setbacks', 'groups',
  'authority', 'skill',
];

Lesson lessonForDay(int day) => lessons[dailyLessonIds[(day.clamp(1, programmeLength)) - 1]]!;
