import '../models/models.dart';

class ChallengeTemplate {
  const ChallengeTemplate(this.domain, this.level, this.title, this.examplePrediction);
  final Domain domain;
  final int level; // 1 (easiest) - 5
  final String title;
  final String examplePrediction;
}

/// Real-world challenges, graded 1-5 within each domain.
const challengeLibrary = <ChallengeTemplate>[
  // Speaking up / self-trust
  ChallengeTemplate(Domain.speakingUp, 1, 'Ask a shop assistant where to find something',
      'They will look annoyed or think it is a stupid question.'),
  ChallengeTemplate(Domain.speakingUp, 1, 'Reply to a group chat with your honest opinion',
      'No one will respond, or someone will disagree.'),
  ChallengeTemplate(Domain.speakingUp, 2, 'Give a friend or colleague your opinion on something they ask about',
      'They will think my opinion is silly.'),
  ChallengeTemplate(Domain.speakingUp, 2, 'Ask a question you have been unsure about instead of looking it up',
      'They will think I should already know.'),
  ChallengeTemplate(Domain.speakingUp, 3, 'Share an idea at work or in class, even if it is not fully formed',
      'People will think it is a bad idea and I will be embarrassed.'),
  ChallengeTemplate(Domain.speakingUp, 3, 'Admit "I don\'t know" instead of bluffing or staying quiet',
      'They will lose respect for me.'),
  ChallengeTemplate(Domain.speakingUp, 4, 'Ask a question in a meeting or lecture with several people',
      'Everyone will notice I am nervous and think the question is obvious.'),
  ChallengeTemplate(Domain.speakingUp, 5, 'Present a short update or idea to a group',
      'I will freeze or lose my words and people will judge me.'),

  // Starting conversations
  ChallengeTemplate(Domain.initiating, 1, 'Greet someone you usually walk past without speaking',
      'They will ignore me or it will be awkward.'),
  ChallengeTemplate(Domain.initiating, 1, 'Ask a cashier or driver how their day is going',
      'They will give a one-word answer and I will feel silly.'),
  ChallengeTemplate(Domain.initiating, 2, 'Make a small comment to someone in a queue',
      'They will think I am strange for talking to them.'),
  ChallengeTemplate(Domain.initiating, 2, 'Message an old friend you have lost touch with',
      'They will not reply or will not want to talk.'),
  ChallengeTemplate(Domain.initiating, 3, 'Start a conversation with a colleague or classmate you rarely talk to',
      'I will run out of things to say and there will be an awkward silence.'),
  ChallengeTemplate(Domain.initiating, 4, 'Introduce yourself to someone new at an event, church or gathering',
      'They will be uninterested and try to get away.'),
  ChallengeTemplate(Domain.initiating, 5, 'Invite someone for coffee or lunch',
      'They will say no and I will feel rejected.'),

  // Assertiveness
  ChallengeTemplate(Domain.assertiveness, 1, 'Choose the restaurant, film or plan when asked',
      'Others will be unhappy with my choice.'),
  ChallengeTemplate(Domain.assertiveness, 1, 'State a preference without adding a reason',
      'They will think I am rude or difficult.'),
  ChallengeTemplate(Domain.assertiveness, 2, 'Ask for something small you need (a refill, a correction, a seat change)',
      'They will be irritated with me.'),
  ChallengeTemplate(Domain.assertiveness, 2, 'Say no to a small request with one sentence only',
      'They will be upset or think less of me.'),
  ChallengeTemplate(Domain.assertiveness, 3, 'Disagree politely with a friend about a minor topic',
      'It will turn into an argument or damage the friendship.'),
  ChallengeTemplate(Domain.assertiveness, 4, 'Return an item or point out a mistake on a bill',
      'They will argue or make me feel embarrassed.'),
  ChallengeTemplate(Domain.assertiveness, 5, 'Raise something that has been bothering you with someone close',
      'They will get defensive and the relationship will suffer.'),

  // Authority
  ChallengeTemplate(Domain.authority, 1, 'Send a clear question by email or chat to a manager or lecturer',
      'They will think the question shows I am not capable.'),
  ChallengeTemplate(Domain.authority, 2, 'Greet a senior person by name and ask how they are',
      'They will be dismissive or not remember me.'),
  ChallengeTemplate(Domain.authority, 3, 'Ask a senior person a question face to face',
      'They will be impatient and I will sound unprepared.'),
  ChallengeTemplate(Domain.authority, 3, 'Ask for feedback on a piece of your work',
      'They will tell me it is bad and I will not cope.'),
  ChallengeTemplate(Domain.authority, 4, 'Share an idea or suggestion directly with your manager',
      'They will dismiss it and think less of me.'),
  ChallengeTemplate(Domain.authority, 5, 'Respectfully disagree with someone senior',
      'They will be offended and it will affect how they treat me.'),

  // Groups
  ChallengeTemplate(Domain.groups, 1, 'Agree out loud with someone\'s point in a group ("Good point")',
      'People will think it is a pointless comment.'),
  ChallengeTemplate(Domain.groups, 2, 'Ask one follow-up question in a group conversation',
      'Everyone will look at me and I will go blank.'),
  ChallengeTemplate(Domain.groups, 3, 'Say something in the first five minutes of a meeting or group chat',
      'I will interrupt and people will be annoyed.'),
  ChallengeTemplate(Domain.groups, 3, 'Join a group conversation that has already started',
      'They will stop talking and it will be awkward.'),
  ChallengeTemplate(Domain.groups, 4, 'Tell a short story or experience to a group',
      'People will get bored and I will lose my train of thought.'),
  ChallengeTemplate(Domain.groups, 5, 'Offer a different view from the group\'s',
      'Everyone will disagree with me and think I am wrong.'),

  // Voice
  ChallengeTemplate(Domain.voice, 1, 'Read a paragraph aloud at home at "slightly too loud" volume',
      'It will sound ridiculous.'),
  ChallengeTemplate(Domain.voice, 1, 'Order food or a drink so you do not have to repeat yourself',
      'They will still ask me to repeat it.'),
  ChallengeTemplate(Domain.voice, 2, 'Answer the phone or a call with a clear, full greeting',
      'My voice will shake and they will notice.'),
  ChallengeTemplate(Domain.voice, 3, 'In a conversation, finish every sentence fully without trailing off',
      'People will think I am too loud or too forward.'),
  ChallengeTemplate(Domain.voice, 4, 'Speak so the person furthest away in a room can hear you',
      'People will stare at me.'),
  ChallengeTemplate(Domain.voice, 5, 'Introduce yourself or speak to a group at full volume',
      'My voice will crack and everyone will notice.'),
];

/// Common safety behaviours. Users tick the ones they will drop.
const safetyBehaviours = <String>[
  'Speaking quietly',
  'Trailing off at the end of sentences',
  'Rehearsing exactly what to say',
  'Apologising before speaking',
  'Over-explaining or justifying',
  'Avoiding eye contact',
  'Keeping it as short as possible',
  'Checking my phone to look busy',
  'Waiting for someone else to go first',
  'Monitoring how I come across',
];

List<ChallengeTemplate> templatesFor(Domain domain, int level) =>
    challengeLibrary.where((t) => t.domain == domain && t.level == level).toList();

/// Nearest available template to [level] in [domain], searching downward first.
ChallengeTemplate nearestTemplate(Domain domain, int level, int seed) {
  for (var l = level; l >= 1; l--) {
    final list = templatesFor(domain, l);
    if (list.isNotEmpty) return list[seed.abs() % list.length];
  }
  for (var l = level + 1; l <= 5; l++) {
    final list = templatesFor(domain, l);
    if (list.isNotEmpty) return list[seed.abs() % list.length];
  }
  return challengeLibrary.first;
}
