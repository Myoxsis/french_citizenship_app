import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';
import '../data/question_repository.dart';
import '../models/question.dart';
import '../providers/settings_controller.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: FutureBuilder<(Set<String>, List<Question>)>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final (mistakes, questions) = snapshot.data!;
          final filtered = questions
              .where((q) => mistakes.contains(q.id))
              .toList();
          if (filtered.isEmpty)
            return const Center(child: Text('Aucune erreur enregistrée.'));
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final q = filtered[i];
              return ListTile(
                title: Text(q.prompt),
                subtitle: Text(q.explanation ?? ''),
              );
            },
          );
        },
      ),
    );
  }

  Future<(Set<String>, List<Question>)> _load(WidgetRef ref) async {
    final prefs = ref.read(preferencesServiceProvider);
    final repo = ref.read(questionRepositoryProvider);
    final locale = ref.read(settingsControllerProvider).locale;
    final mistakes = await prefs.getMistakes();
    final qs = await repo.load(locale);
    return (mistakes, qs);
  }
}
