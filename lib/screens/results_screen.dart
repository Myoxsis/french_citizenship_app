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
    final color = percent >= 0.8
        ? Colors.green
        : percent >= 0.5
            ? Colors.orange
            : Colors.red;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('results_title'.tr()),
      ),
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
