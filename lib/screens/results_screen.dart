import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app_router.dart';
import '../providers/quiz_controller.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(quizControllerProvider);
    final score = s?.score ?? 0;
    final total = s?.total ?? 0;
    final percent = total == 0 ? 0.0 : score / total;
    final color = percent >= 0.8
        ? Colors.green
        : percent >= 0.5
            ? Colors.orange
            : Colors.red;
    return Scaffold(
      appBar: AppBar(title: Text('results_title'.tr())),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'results_score'.tr(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 12,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      percent >= 0.8
                          ? Icons.emoji_events
                          : Icons.sentiment_satisfied_alt,
                      size: 48,
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$score / $total',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('results_correct'.tr()),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pushNamed(AppRoute.review.name),
              child: Text('results_review'.tr()),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => total == 30
                  ? context.goNamed(
                      AppRoute.quiz.name,
                      queryParameters: {'mode': 'exam'},
                    )
                  : context.goNamed(AppRoute.quiz.name),
              child: Text('results_retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
