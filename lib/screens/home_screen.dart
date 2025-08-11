import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_controller.dart';
import '../widgets/primary_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(settingsControllerProvider).locale;
    return Scaffold(
      appBar: AppBar(title: Text('app_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'home_start_quick'.tr(),
              onPressed: () => context.go('/quiz?mode=quick'),
            ),
            PrimaryButton(
              label: 'home_start_exam'.tr(),
              onPressed: () => context.go('/quiz?mode=exam'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => context.go('/review'),
              child: Text('home_review_mistakes'.tr()),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.go('/settings'),
              child: Text('home_settings'.tr()),
            ),
            const Spacer(),
            Text(
              'Locale: ${locale.name.toUpperCase()}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
