import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../data/question_repository.dart';
import '../services/preferences_service.dart';
import '../services/analytics_service.dart';
import 'settings_controller.dart';

class QuizState {
  final List<Question> questions;
  final int index;
  final List<int?> answers; // user-selected index per question
  final bool finished;

  const QuizState({
    required this.questions,
    this.index = 0,
    required this.answers,
    this.finished = false,
  });

  int get total => questions.length;
  int get score => List.generate(
    total,
    (i) => answers[i] == questions[i].answerIndex ? 1 : 0,
  ).fold(0, (a, b) => a + b);
}

final analyticsProvider = Provider((_) => AnalyticsService());
final questionRepositoryProvider = Provider((_) => const QuestionRepository());

final quizControllerProvider =
    StateNotifierProvider<QuizController, QuizState?>(
      (ref) => QuizController(ref),
    );

class QuizController extends StateNotifier<QuizState?> {
  final Ref _ref;
  QuizController(this._ref) : super(null);

  Future<void> start({required bool examMode}) async {
    final repo = _ref.read(questionRepositoryProvider);
    final locale = _ref.read(settingsControllerProvider).locale;
    final list = await repo.load(locale);
    final rng = Random();
    final pool = List<Question>.from(list)..shuffle(rng);
    final selected = examMode ? pool.take(30).toList() : pool.take(10).toList();
    state = QuizState(
      questions: selected,
      answers: List<int?>.filled(selected.length, null),
    );
    _ref.read(analyticsProvider).logEvent('quiz_start', {
      'mode': examMode ? 'exam' : 'quick',
      'count': selected.length,
    });
  }

  void answerCurrent(int choiceIndex) {
    final s = state;
    if (s == null) return;
    final answers = List<int?>.from(s.answers)..[s.index] = choiceIndex;
    state = QuizState(
      questions: s.questions,
      index: s.index,
      answers: answers,
      finished: s.finished,
    );
  }

  Future<void> next() async {
    final s = state;
    if (s == null) return;
    if (s.index < s.total - 1) {
      state = QuizState(
        questions: s.questions,
        index: s.index + 1,
        answers: s.answers,
        finished: false,
      );
    } else {
      // Finish
      final prefs = _ref.read(preferencesServiceProvider);
      final mistakes = <String>{};
      for (var i = 0; i < s.total; i++) {
        if (s.answers[i] != s.questions[i].answerIndex)
          mistakes.add(s.questions[i].id);
      }
      await prefs.saveMistakes(mistakes);
      final score = s.score;
      final prevBest = await prefs.getBestScore30();
      if (s.total == 30 && score > prevBest) await prefs.setBestScore30(score);
      _ref.read(analyticsProvider).logEvent('quiz_finish', {
        'score': score,
        'total': s.total,
      });
      state = QuizState(
        questions: s.questions,
        index: s.index,
        answers: s.answers,
        finished: true,
      );
    }
  }
}
