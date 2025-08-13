import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _kLocaleKey = 'locale_code'; // 'fr' or 'en'
  static const _kDarkModeKey = 'dark_mode';
  static const _kMistakesKey = 'mistake_ids'; // comma-separated question IDs
  static const _kBestScoreKey = 'best_score_15';
  static const _kHeartsKey = 'hearts_count';
  static const _kNextHeartKey = 'next_heart_ms';
  static const _kQuizCountKey = 'quiz_count';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> setLocale(String code) async {
    final p = await _prefs;
    await p.setString(_kLocaleKey, code);
  }

  Future<String?> getLocale() async {
    final p = await _prefs;
    return p.getString(_kLocaleKey);
  }

  Future<void> setDarkMode(bool value) async {
    final p = await _prefs;
    await p.setBool(_kDarkModeKey, value);
  }

  Future<bool> getDarkMode() async {
    final p = await _prefs;
    return p.getBool(_kDarkModeKey) ?? false;
  }

  Future<void> saveMistakes(Set<String> ids) async {
    final p = await _prefs;
    await p.setString(_kMistakesKey, ids.join(','));
  }

  Future<Set<String>> getMistakes() async {
    final p = await _prefs;
    final raw = p.getString(_kMistakesKey);
    return raw == null || raw.isEmpty ? {} : raw.split(',').toSet();
  }

  Future<void> setBestScore15(int score) async {
    final p = await _prefs;
    await p.setInt(_kBestScoreKey, score);
  }

  Future<int> getBestScore15() async {
    final p = await _prefs;
    return p.getInt(_kBestScoreKey) ?? 0;
  }

  Future<void> incrementQuizCount() async {
    final p = await _prefs;
    final current = p.getInt(_kQuizCountKey) ?? 0;
    await p.setInt(_kQuizCountKey, current + 1);
  }

  Future<int> getQuizCount() async {
    final p = await _prefs;
    return p.getInt(_kQuizCountKey) ?? 0;
  }

  Future<void> resetAll() async {
    final p = await _prefs;
    await p.clear();
  }

  Future<int> getHeartsCount() async {
    final p = await _prefs;
    return p.getInt(_kHeartsKey) ?? 5;
  }

  Future<int?> getNextHeartTimestamp() async {
    final p = await _prefs;
    return p.getInt(_kNextHeartKey);
  }

  Future<void> setHeartsState(int hearts, DateTime? next) async {
    final p = await _prefs;
    await p.setInt(_kHeartsKey, hearts);
    if (next == null) {
      await p.remove(_kNextHeartKey);
    } else {
      await p.setInt(_kNextHeartKey, next.millisecondsSinceEpoch);
    }
  }
}
