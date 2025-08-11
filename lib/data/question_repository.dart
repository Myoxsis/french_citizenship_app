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
    final jsonStr = await rootBundle.loadString(path);
    return Question.listFromJsonString(jsonStr);
  }
}
