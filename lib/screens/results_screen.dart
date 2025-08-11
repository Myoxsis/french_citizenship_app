import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_controller.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(quizControllerProvider);
    final score = s?.score ?? 0;
    final total = s?.total ?? 0;
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
            const SizedBox(height: 8),
            Text('$score / $total ${'results_correct'.tr()}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/review'),
              child: Text('results_review'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
