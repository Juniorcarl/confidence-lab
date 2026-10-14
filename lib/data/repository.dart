import '../models/models.dart';

/// Storage boundary. LocalRepository (on-device) is used by the app;
/// InMemoryRepository is used in tests.
abstract class Repository {
  Future<UserProfile?> loadProfile();
  Future<void> saveProfile(UserProfile profile);

  Future<List<ThoughtRecord>> loadThoughts();
  Future<void> saveThought(ThoughtRecord record);

  Future<List<Challenge>> loadChallenges();
  Future<void> saveChallenge(Challenge challenge);

  Future<List<CheckIn>> loadCheckIns();
  Future<void> saveCheckIn(CheckIn checkIn);

  /// Permanently removes all of this user's data.
  Future<void> deleteAll();
}

class InMemoryRepository implements Repository {
  UserProfile? _profile;
  final _thoughts = <String, ThoughtRecord>{};
  final _challenges = <String, Challenge>{};
  final _checkIns = <String, CheckIn>{};

  @override
  Future<UserProfile?> loadProfile() async => _profile;
  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<List<ThoughtRecord>> loadThoughts() async => _thoughts.values.toList();
  @override
  Future<void> saveThought(ThoughtRecord record) async {
    _thoughts[record.id] = record;
  }

  @override
  Future<List<Challenge>> loadChallenges() async => _challenges.values.toList();
  @override
  Future<void> saveChallenge(Challenge challenge) async {
    _challenges[challenge.id] = challenge;
  }

  @override
  Future<List<CheckIn>> loadCheckIns() async => _checkIns.values.toList();
  @override
  Future<void> saveCheckIn(CheckIn checkIn) async {
    _checkIns[checkIn.id] = checkIn;
  }

  @override
  Future<void> deleteAll() async {
    _profile = null;
    _thoughts.clear();
    _challenges.clear();
    _checkIns.clear();
  }
}
