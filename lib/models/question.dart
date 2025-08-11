import 'dart:convert';

class Question {
  final String id;
  final String prompt;
  final List<String> choices;
  final int answerIndex;
  final String? explanation;

  const Question({
    required this.id,
    required this.prompt,
    required this.choices,
    required this.answerIndex,
    this.explanation,
  });

  factory Question.fromMap(Map<String, dynamic> map) => Question(
    id: map['id'] as String,
    prompt: map['prompt'] as String,
    choices: List<String>.from(map['choices'] as List),
    answerIndex: map['answerIndex'] as int,
    explanation: map['explanation'] as String?,
  );

  static List<Question> listFromJsonString(String jsonStr) {
    final data = json.decode(jsonStr) as List<dynamic>;
    return data
        .map((e) => Question.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
