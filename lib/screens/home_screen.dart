import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../app_router.dart';
import '../providers/settings_controller.dart';
import '../providers/heart_controller.dart';
import '../services/ad_manager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _showRewardedAd() {
    RewardedAd.load(
      adUnitId: AdManager.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
          );
          ad.show(
            onUserEarnedReward: (ad, reward) {
              ref.read(heartsControllerProvider.notifier).addHeart();
            },
          );
        },
        onAdFailedToLoad: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load ad: ${error.message}')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(settingsControllerProvider).locale;
    final hearts = ref.watch(heartsControllerProvider);

    final actions = [
      _HomeAction(
        label: 'home_start_quick'.tr(),
        icon: Icons.flash_on,
        onTap: () {
          final ok = ref.read(heartsControllerProvider.notifier).spend(1);
          if (ok) {
            context.goNamed(
              AppRoute.quiz.name,
              queryParameters: {'mode': 'quick'},
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('home_no_hearts'.tr())),
            );
          }
        },
      ),
      _HomeAction(
        label: 'home_start_exam'.tr(),
        icon: Icons.school,
        onTap: () {
          final ok = ref.read(heartsControllerProvider.notifier).spend(2);
          if (ok) {
            context.goNamed(
              AppRoute.quiz.name,
              queryParameters: {'mode': 'exam'},
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('home_no_hearts'.tr())),
            );
          }
        },
      ),
      _HomeAction(
        label: 'home_review_mistakes'.tr(),
        icon: Icons.refresh,
        onTap: () => context.goNamed(AppRoute.review.name),
      ),
      _HomeAction(
        label: 'home_settings'.tr(),
        icon: Icons.settings,
        onTap: () => context.goNamed(AppRoute.settings.name),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'app_title'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(
                        HeartsController.maxHearts,
                        (i) => Icon(
                          i < hearts.hearts
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      IconButton(
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        icon: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Icon(
                                Icons.add,
                                size: 12,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                        onPressed: _showRewardedAd,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                      children:
                          actions.map((a) => _ActionCard(action: a)).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Locale: ${locale.name.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
          if (_bannerAd != null)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}

class _HomeAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _HomeAction action;

  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, size: 40),
              const SizedBox(height: 12),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
