import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../app_router.dart';
import '../providers/settings_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(settingsControllerProvider).locale;

    final actions = [
      _HomeAction(
        label: 'home_start_quick'.tr(),
        icon: Icons.flash_on,
        onTap: () => context.goNamed(
          AppRoute.quiz.name,
          queryParameters: {'mode': 'quick'},
        ),
      ),
      _HomeAction(
        label: 'home_start_exam'.tr(),
        icon: Icons.school,
        onTap: () => context.goNamed(
          AppRoute.quiz.name,
          queryParameters: {'mode': 'exam'},
        ),
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
      appBar: AppBar(title: Text('app_title'.tr())),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
