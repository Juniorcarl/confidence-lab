import '../models/models.dart';

class AssessmentCategory {
  const AssessmentCategory(this.id, this.question, this.domain);
  final String id;
  final String question;
  final Domain domain;
}

/// Onboarding self-rating: "How hard is this for you?" 0-4.
const assessmentCategories = <AssessmentCategory>[
  AssessmentCategory('selfTrust', 'Trusting that my opinions are worth sharing', Domain.speakingUp),
  AssessmentCategory('fearOfJudgment', 'Not worrying about being judged or making mistakes', Domain.speakingUp),
  AssessmentCategory('voice', 'Speaking loudly and clearly enough to be heard', Domain.voice),
  AssessmentCategory('initiating', 'Starting conversations with new people', Domain.initiating),
  AssessmentCategory('assertiveness', 'Saying what I prefer, disagreeing or saying no', Domain.assertiveness),
  AssessmentCategory('authority', 'Talking to managers, seniors or people I find intimidating', Domain.authority),
  AssessmentCategory('groups', 'Contributing in group conversations or meetings', Domain.groups),
];

const difficultyLabels = ['Easy', 'A little hard', 'Hard', 'Very hard', 'Extremely hard'];

const triggerOptions = <String>[
  'Meetings at work or class',
  'Talking to a manager or lecturer',
  'Meeting new people',
  'Phone or video calls',
  'Disagreeing with someone',
  'Asking for help',
  'Being the centre of attention',
  'Talking to someone I find attractive or impressive',
  'Shops, restaurants and services',
  'Family gatherings',
];
