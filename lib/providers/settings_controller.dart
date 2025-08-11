import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';
import '../data/question_repository.dart';

class SettingsState {
  final QuizLocale locale;
  final bool darkMode;
  const SettingsState({required this.locale, required this.darkMode});

  SettingsState copyWith({QuizLocale? locale, bool? darkMode}) => SettingsState(
    locale: locale ?? this.locale,
    darkMode: darkMode ?? this.darkMode,
  );
}

final preferencesServiceProvider = Provider((_) => PreferencesService());

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
      (ref) => SettingsController(ref),
    );

class SettingsController extends StateNotifier<SettingsState> {
  final Ref _ref;
  SettingsController(this._ref)
    : super(const SettingsState(locale: QuizLocale.fr, darkMode: false)) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = _ref.read(preferencesServiceProvider);
    final code = await prefs.getLocale();
    final dark = await prefs.getDarkMode();
    state = SettingsState(
      locale: code == 'en' ? QuizLocale.en : QuizLocale.fr,
      darkMode: dark,
    );
  }

  Future<void> setLocale(QuizLocale locale) async {
    state = state.copyWith(locale: locale);
    await _ref
        .read(preferencesServiceProvider)
        .setLocale(locale == QuizLocale.en ? 'en' : 'fr');
  }

  Future<void> toggleDark(bool value) async {
    state = state.copyWith(darkMode: value);
    await _ref.read(preferencesServiceProvider).setDarkMode(value);
  }
}
