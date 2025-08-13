import 'dart:math';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';

enum QuizLocale { fr, en }

class QuestionRepository {
  const QuestionRepository();

  Future<List<Question>> load(QuizLocale locale) async {
    final path = switch (locale) {
      QuizLocale.fr => 'assets/questions/fr.json',
      QuizLocale.en => 'assets/questions/en.json',
    };
    try {
      final jsonStr = await rootBundle.loadString(path);
      final questions = Question.listFromJsonString(jsonStr);
      questions.shuffle(Random());
      return questions;
    } catch (e) {
      debugPrint('Failed to load questions from $path: $e');
      return [];
    }
  }
}
