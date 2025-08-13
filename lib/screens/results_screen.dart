import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app_router.dart';
import '../providers/quiz_controller.dart';
import '../providers/heart_controller.dart';
import '../providers/settings_controller.dart';
import '../services/ad_manager.dart';
import '../theme_extensions.dart';
import '../widgets/app_back_button.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    _maybeShowAd();
  }

  Future<void> _maybeShowAd() async {
    final prefs = ref.read(preferencesServiceProvider);
    final count = await prefs.getQuizCount();
    if (count >= 4 && count % 4 == 0) {
      InterstitialAd.load(
        adUnitId: AdManager.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
              onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
            );
            ad.show();
          },
          onAdFailedToLoad: (error) {},
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(quizControllerProvider);
    final score = s?.score ?? 0;
    final total = s?.total ?? 0;
    final percent = total == 0 ? 0.0 : score / total;
    final status = Theme.of(context).extension<StatusColors>()!;
    final color = percent >= 0.8
        ? status.success
        : percent >= 0.5
            ? status.warning
            : status.error;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(
          'results_title'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/app_logo.png',
                  width: 40,
                  height: 40,
                  semanticLabel: 'App logo',
                ),
                const SizedBox(width: 8),
                Text(
                  'results_score'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percent),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return ShaderMask(
                      shaderCallback: (rect) {
                        return SweepGradient(
                          startAngle: 0,
                          endAngle: 2 * math.pi,
                          colors: [
                            color.withOpacity(0.3),
                            color,
                          ],
                        ).createShader(rect);
                      },
                      child: SizedBox(
                        height: 150,
                        width: 150,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 12,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceVariant,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    );
                  },
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/app_logo.png',
                  width: 24,
                  height: 24,
                  semanticLabel: 'App logo',
                ),
                const SizedBox(width: 8),
                Text(
                  'results_correct'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pushNamed(AppRoute.review.name),
              child: Text('results_review'.tr()),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                final cost = total == 15 ? 2 : 1;
                final ok = ref.read(heartsControllerProvider.notifier).spend(cost);
                if (ok) {
                  if (total == 15) {
                    context.goNamed(
                      AppRoute.quiz.name,
                      queryParameters: {'mode': 'exam'},
                    );
                  } else {
                    context.goNamed(AppRoute.quiz.name);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('home_no_hearts'.tr())),
                  );
                }
              },
              child: Text('results_retry'.tr()),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.goNamed(AppRoute.home.name),
              child: Text('results_home'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
