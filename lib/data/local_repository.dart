import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'repository.dart';

/// Stores everything on the device as JSON in SharedPreferences.
/// No accounts, no servers, no network. Data is removed if the app is
/// uninstalled; Profile > Export lets the user keep a copy.
class LocalRepository implements Repository {
  LocalRepository(this._prefs);

  static Future<LocalRepository> open() async => LocalRepository(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static const _profileKey = 'cl.profile';
  static const _thoughtsKey = 'cl.thoughts';
  static const _challengesKey = 'cl.challenges';
  static const _checkInsKey = 'cl.checkins';

  List<Map<String, dynamic>> _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Upserts [item] by its 'id' field.
  Future<void> _upsert(String key, Map<String, dynamic> item) async {
    final list = _readList(key);
    final i = list.indexWhere((m) => m['id'] == item['id']);
    if (i >= 0) {
      list[i] = item;
    } else {
      list.add(item);
    }
    await _prefs.setString(key, jsonEncode(list));
  }

  @override
  Future<UserProfile?> loadProfile() async {
    final raw = _prefs.getString(_profileKey);
    if (raw == null) return null;
    try {
      return UserProfile.fromMap(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toMap()));
  }

  @override
  Future<List<ThoughtRecord>> loadThoughts() async => _readList(_thoughtsKey).map(ThoughtRecord.fromMap).toList();

  @override
  Future<void> saveThought(ThoughtRecord record) => _upsert(_thoughtsKey, record.toMap());

  @override
  Future<List<Challenge>> loadChallenges() async => _readList(_challengesKey).map(Challenge.fromMap).toList();

  @override
  Future<void> saveChallenge(Challenge challenge) => _upsert(_challengesKey, challenge.toMap());

  @override
  Future<List<CheckIn>> loadCheckIns() async => _readList(_checkInsKey).map(CheckIn.fromMap).toList();

  @override
  Future<void> saveCheckIn(CheckIn checkIn) => _upsert(_checkInsKey, checkIn.toMap());

  @override
  Future<void> deleteAll() async {
    for (final k in [_profileKey, _thoughtsKey, _challengesKey, _checkInsKey]) {
      await _prefs.remove(k);
    }
  }
}
