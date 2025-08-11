import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app_router.dart';
import '../providers/quiz_controller.dart';
import '../widgets/question_card.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final bool examMode;
  const QuizScreen({super.key, required this.examMode});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(quizControllerProvider.notifier)
          .start(examMode: widget.examMode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizControllerProvider);
    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final s = state;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'quiz_question'.tr(
            namedArgs: {'index': '${s.index + 1}', 'total': '${s.total}'},
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween<double>(
                begin: s.index / s.total,
                end: (s.index + 1) / s.total,
              ),
              builder: (context, value, _) =>
                  LinearProgressIndicator(value: value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: QuestionCard(
                  key: ValueKey(s.index),
                  question: s.questions[s.index],
                  selectedIndex: s.answers[s.index],
                  onSelected: (i) => ref
                      .read(quizControllerProvider.notifier)
                      .answerCurrent(i),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: s.index == s.total - 1
                        ? () => _finishOrNext(context, s.finished)
                        : () =>
                              ref.read(quizControllerProvider.notifier).next(),
                    child: Text(
                      s.index == s.total - 1
                          ? 'quiz_finish'.tr()
                          : 'quiz_next'.tr(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _finishOrNext(BuildContext context, bool finished) {
    ref.read(quizControllerProvider.notifier).next();
    context.goNamed(AppRoute.results.name);
  }
}
