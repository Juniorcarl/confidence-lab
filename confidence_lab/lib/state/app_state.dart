import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../content/check_in.dart';
import '../content/programme.dart';
import '../data/practice_service.dart';
import '../data/repository.dart';
import '../logic/adaptive.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState({required this.repo, required this.practice});

  final Repository repo;
  final PracticeService practice;

  bool loaded = false;
  UserProfile? profile;
  List<ThoughtRecord> thoughts = [];
  List<Challenge> challenges = [];
  List<CheckIn> checkIns = [];

  Future<void> load() async {
    profile = await repo.loadProfile();
    thoughts = (await repo.loadThoughts())..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    challenges = (await repo.loadChallenges())..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    checkIns = (await repo.loadCheckIns())..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    loaded = true;
    notifyListeners();
  }

  // ---------- Derived state ----------

  bool get onboarded => profile != null;
  int get day => programmeDay(profile?.sessionsCompleted ?? 0);
  Phase get phase => phaseForDay(day);
  bool get programmeComplete => (profile?.sessionsCompleted ?? 0) >= programmeLength;

  bool get sessionDoneToday => profile?.lastSessionDate == dateKey(DateTime.now());

  /// The planned challenge still waiting for review, if any.
  Challenge? get openChallenge {
    for (final c in challenges) {
      if (c.status == ChallengeStatus.planned) return c;
    }
    return null;
  }

  List<Challenge> get reviewedChallenges => challenges.where((c) => c.isReviewed).toList();

  CheckIn? get latestCheckIn => checkIns.isEmpty ? null : checkIns.last;

  /// Weekly check-in is due once a week after onboarding.
  bool get checkInDue {
    final last = latestCheckIn;
    if (last == null) return true;
    final since = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(last.createdAt));
    return since.inDays >= 7;
  }

  bool get showSupportSuggestion {
    final last = latestCheckIn;
    return last != null && suggestsSupport(last.answers);
  }

  List<ChallengeOption> get todaysOptions => challengeOptions(
        assessment: profile?.assessment ?? const {},
        history: challenges,
        day: day,
      );

  // ---------- Actions ----------

  Future<void> completeOnboarding({
    required Map<String, int> assessment,
    required List<String> triggers,
    required String goal,
    required List<int> baselineCheckIn,
  }) async {
    final p = UserProfile(
      createdAt: DateTime.now().millisecondsSinceEpoch,
      assessment: assessment,
      triggers: triggers,
      goal: goal,
    );
    await repo.saveProfile(p);
    profile = p;
    await addCheckIn(baselineCheckIn, notify: false);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile p) async {
    await repo.saveProfile(p);
    profile = p;
    notifyListeners();
  }

  Future<void> addThought(ThoughtRecord r) async {
    await repo.saveThought(r);
    thoughts.insert(0, r);
    notifyListeners();
  }

  Future<void> planChallenge(Challenge c) async {
    await repo.saveChallenge(c);
    challenges.insert(0, c);
    notifyListeners();
  }

  Future<void> updateChallenge(Challenge c) async {
    await repo.saveChallenge(c);
    final i = challenges.indexWhere((x) => x.id == c.id);
    if (i >= 0) challenges[i] = c;
    notifyListeners();
  }

  Future<void> addCheckIn(List<int> answers, {bool notify = true}) async {
    final c = CheckIn(id: newId(), createdAt: DateTime.now().millisecondsSinceEpoch, answers: answers);
    await repo.saveCheckIn(c);
    checkIns.add(c);
    if (notify) notifyListeners();
  }

  /// Counts once per calendar day, however many sessions are done.
  Future<void> completeSession() async {
    final p = profile;
    if (p == null) return;
    final today = dateKey(DateTime.now());
    if (p.lastSessionDate == today) return;
    await updateProfile(p.copyWith(sessionsCompleted: p.sessionsCompleted + 1, lastSessionDate: today));
  }

  Future<void> deleteAllData() async {
    await repo.deleteAll();
    profile = null;
    thoughts = [];
    challenges = [];
    checkIns = [];
    notifyListeners();
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert({
        'exportedAt': DateTime.now().toIso8601String(),
        'profile': profile?.toMap(),
        'thoughtRecords': thoughts.map((t) => t.toMap()).toList(),
        'challenges': challenges.map((c) => c.toMap()).toList(),
        'checkIns': checkIns.map((c) => c.toMap()).toList(),
      });
}
