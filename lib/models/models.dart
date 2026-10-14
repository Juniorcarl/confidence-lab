/// Plain data models. Timestamps are stored as epoch milliseconds so the
/// models stay independent of Firestore and are easy to unit test.
library;

enum Domain {
  speakingUp('Speaking up', 'Sharing opinions and asking questions'),
  initiating('Starting conversations', 'Opening and keeping a conversation going'),
  assertiveness('Assertiveness', 'Preferences, disagreeing and saying no'),
  authority('Authority figures', 'Talking to seniors, managers and experts'),
  groups('Groups', 'Contributing when several people are talking'),
  voice('Voice', 'Speaking audibly and finishing sentences');

  const Domain(this.label, this.description);
  final String label;
  final String description;

  static Domain byName(String name) =>
      Domain.values.firstWhere((d) => d.name == name, orElse: () => Domain.speakingUp);
}

/// Did the thing the user feared actually happen?
enum FearedOutcome {
  no('No'),
  partly('Partly'),
  yes('Yes');

  const FearedOutcome(this.label);
  final String label;

  static FearedOutcome byName(String? name) =>
      FearedOutcome.values.firstWhere((f) => f.name == name, orElse: () => FearedOutcome.no);
}

enum ChallengeStatus { planned, done, skipped }

String newId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  return '${now.toRadixString(36)}${(now * 7919 % 1679616).toRadixString(36)}';
}

int _int(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
String _str(Object? v) => v is String ? v : '';
List<String> _strList(Object? v) => v is List ? v.whereType<String>().toList() : <String>[];

class UserProfile {
  UserProfile({
    required this.createdAt,
    required this.assessment,
    required this.triggers,
    required this.goal,
    this.sessionsCompleted = 0,
    this.lastSessionDate,
    this.voiceConsent = false,
  });

  final int createdAt;

  /// Category id -> how hard it is (0 = not at all, 4 = extremely).
  final Map<String, int> assessment;
  final List<String> triggers;
  final String goal;
  final int sessionsCompleted;

  /// yyyy-MM-dd of the last completed daily session.
  final String? lastSessionDate;
  final bool voiceConsent;

  UserProfile copyWith({
    Map<String, int>? assessment,
    List<String>? triggers,
    String? goal,
    int? sessionsCompleted,
    String? lastSessionDate,
    bool? voiceConsent,
  }) =>
      UserProfile(
        createdAt: createdAt,
        assessment: assessment ?? this.assessment,
        triggers: triggers ?? this.triggers,
        goal: goal ?? this.goal,
        sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
        lastSessionDate: lastSessionDate ?? this.lastSessionDate,
        voiceConsent: voiceConsent ?? this.voiceConsent,
      );

  Map<String, dynamic> toMap() => {
        'createdAt': createdAt,
        'assessment': assessment,
        'triggers': triggers,
        'goal': goal,
        'sessionsCompleted': sessionsCompleted,
        'lastSessionDate': lastSessionDate,
        'voiceConsent': voiceConsent,
      };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        createdAt: _int(m['createdAt']),
        assessment: (m['assessment'] is Map)
            ? (m['assessment'] as Map).map((k, v) => MapEntry(k.toString(), _int(v)))
            : <String, int>{},
        triggers: _strList(m['triggers']),
        goal: _str(m['goal']),
        sessionsCompleted: _int(m['sessionsCompleted']),
        lastSessionDate: m['lastSessionDate'] as String?,
        voiceConsent: m['voiceConsent'] == true,
      );
}

/// A CBT thought record, ending in a self-compassionate balanced response.
class ThoughtRecord {
  ThoughtRecord({
    required this.id,
    required this.createdAt,
    required this.situation,
    required this.automaticThought,
    required this.beliefBefore,
    required this.evidenceFor,
    required this.evidenceAgainst,
    required this.balancedResponse,
    required this.beliefAfter,
    required this.action,
  });

  final String id;
  final int createdAt;
  final String situation;
  final String automaticThought;
  final int beliefBefore; // 0-100
  final String evidenceFor;
  final String evidenceAgainst;
  final String balancedResponse;
  final int beliefAfter; // 0-100
  final String action;

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt,
        'situation': situation,
        'automaticThought': automaticThought,
        'beliefBefore': beliefBefore,
        'evidenceFor': evidenceFor,
        'evidenceAgainst': evidenceAgainst,
        'balancedResponse': balancedResponse,
        'beliefAfter': beliefAfter,
        'action': action,
      };

  factory ThoughtRecord.fromMap(Map<String, dynamic> m) => ThoughtRecord(
        id: _str(m['id']),
        createdAt: _int(m['createdAt']),
        situation: _str(m['situation']),
        automaticThought: _str(m['automaticThought']),
        beliefBefore: _int(m['beliefBefore']),
        evidenceFor: _str(m['evidenceFor']),
        evidenceAgainst: _str(m['evidenceAgainst']),
        balancedResponse: _str(m['balancedResponse']),
        beliefAfter: _int(m['beliefAfter']),
        action: _str(m['action']),
      );
}

/// A real-world challenge set up as a behavioural experiment:
/// prediction before, outcome and updated belief after.
class Challenge {
  Challenge({
    required this.id,
    required this.createdAt,
    required this.domain,
    required this.level,
    required this.title,
    required this.prediction,
    required this.predictedProbability,
    required this.safetyBehavioursToDrop,
    this.status = ChallengeStatus.planned,
    this.reviewedAt,
    this.whatHappened = '',
    this.fearedOutcome,
    this.anxietyPeak,
    this.signsOfInterest = '',
    this.updatedProbability,
    this.learned = '',
  });

  final String id;
  final int createdAt;
  final Domain domain;
  final int level; // 1-5
  final String title;
  final String prediction;
  final int predictedProbability; // 0-100, "how likely is the feared outcome?"
  final List<String> safetyBehavioursToDrop;

  final ChallengeStatus status;
  final int? reviewedAt;
  final String whatHappened;
  final FearedOutcome? fearedOutcome;
  final int? anxietyPeak; // 0-100
  final String signsOfInterest;
  final int? updatedProbability; // 0-100, belief for next time
  final String learned;

  bool get isReviewed => status != ChallengeStatus.planned;

  /// Positive = the user now expects the feared outcome less than before.
  int? get expectancyChange =>
      updatedProbability == null ? null : predictedProbability - updatedProbability!;

  Challenge review({
    required String whatHappened,
    required FearedOutcome fearedOutcome,
    required int anxietyPeak,
    required String signsOfInterest,
    required int updatedProbability,
    required String learned,
  }) =>
      Challenge(
        id: id,
        createdAt: createdAt,
        domain: domain,
        level: level,
        title: title,
        prediction: prediction,
        predictedProbability: predictedProbability,
        safetyBehavioursToDrop: safetyBehavioursToDrop,
        status: ChallengeStatus.done,
        reviewedAt: DateTime.now().millisecondsSinceEpoch,
        whatHappened: whatHappened,
        fearedOutcome: fearedOutcome,
        anxietyPeak: anxietyPeak,
        signsOfInterest: signsOfInterest,
        updatedProbability: updatedProbability,
        learned: learned,
      );

  Challenge skip() => Challenge(
        id: id,
        createdAt: createdAt,
        domain: domain,
        level: level,
        title: title,
        prediction: prediction,
        predictedProbability: predictedProbability,
        safetyBehavioursToDrop: safetyBehavioursToDrop,
        status: ChallengeStatus.skipped,
        reviewedAt: DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt,
        'domain': domain.name,
        'level': level,
        'title': title,
        'prediction': prediction,
        'predictedProbability': predictedProbability,
        'safetyBehavioursToDrop': safetyBehavioursToDrop,
        'status': status.name,
        'reviewedAt': reviewedAt,
        'whatHappened': whatHappened,
        'fearedOutcome': fearedOutcome?.name,
        'anxietyPeak': anxietyPeak,
        'signsOfInterest': signsOfInterest,
        'updatedProbability': updatedProbability,
        'learned': learned,
      };

  factory Challenge.fromMap(Map<String, dynamic> m) => Challenge(
        id: _str(m['id']),
        createdAt: _int(m['createdAt']),
        domain: Domain.byName(_str(m['domain'])),
        level: _int(m['level'], 1),
        title: _str(m['title']),
        prediction: _str(m['prediction']),
        predictedProbability: _int(m['predictedProbability']),
        safetyBehavioursToDrop: _strList(m['safetyBehavioursToDrop']),
        status: ChallengeStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => ChallengeStatus.planned,
        ),
        reviewedAt: m['reviewedAt'] is num ? (m['reviewedAt'] as num).toInt() : null,
        whatHappened: _str(m['whatHappened']),
        fearedOutcome: m['fearedOutcome'] == null ? null : FearedOutcome.byName(m['fearedOutcome'] as String?),
        anxietyPeak: m['anxietyPeak'] is num ? (m['anxietyPeak'] as num).toInt() : null,
        signsOfInterest: _str(m['signsOfInterest']),
        updatedProbability:
            m['updatedProbability'] is num ? (m['updatedProbability'] as num).toInt() : null,
        learned: _str(m['learned']),
      );
}

/// Weekly self check-in. Answers are 0-4 per item (see content/check_in.dart).
class CheckIn {
  CheckIn({required this.id, required this.createdAt, required this.answers});

  final String id;
  final int createdAt;
  final List<int> answers;

  Map<String, dynamic> toMap() => {'id': id, 'createdAt': createdAt, 'answers': answers};

  factory CheckIn.fromMap(Map<String, dynamic> m) => CheckIn(
        id: _str(m['id']),
        createdAt: _int(m['createdAt']),
        answers: (m['answers'] is List) ? (m['answers'] as List).map((e) => _int(e)).toList() : <int>[],
      );
}
