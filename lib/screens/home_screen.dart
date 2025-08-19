import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Future<void> _confirmWatchAd() async {
    final consent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('home_ad_title'.tr()),
        content: Text('home_ad_content'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('dialog_cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('home_ad_watch'.tr()),
          ),
        ],
      ),
    );

    if (consent == true) {
      _showRewardedAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(settingsControllerProvider).locale;
    final hearts = ref.watch(heartsControllerProvider);

    final actions = [
      _HomeAction(
        label: 'home_start_quick'.tr(),
        asset: 'assets/icons/flash.svg',
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
        asset: 'assets/icons/exam.svg',
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
        asset: 'assets/icons/review.svg',
        onTap: () => context.goNamed(AppRoute.review.name),
      ),
      _HomeAction(
        label: 'home_settings'.tr(),
        asset: 'assets/icons/settings.svg',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Image.asset('assets/app_logo.png', height: 100),
                        const SizedBox(height: 12),
                        Text(
                          'home_hero_title'.tr(),
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
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
                      Tooltip(
                        message: 'home_ad_tooltip'.tr(),
                        child: IconButton(
                          iconSize: 32,
                          padding: EdgeInsets.zero,
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                color:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: _confirmWatchAd,
                        ),
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
  final String asset;
  final VoidCallback onTap;

  const _HomeAction({
    required this.label,
    required this.asset,
    required this.onTap,
  });
}

class _ActionCard extends StatefulWidget {
  final _HomeAction action;

  const _ActionCard({required this.action});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.3 : 0.1),
              blurRadius: _hovering ? 8 : 4,
              offset: Offset(0, _hovering ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.action.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(widget.action.asset, height: 40),
                  const SizedBox(height: 12),
                  Text(
                    widget.action.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
