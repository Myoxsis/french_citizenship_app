import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_controller.dart';
import '../data/question_repository.dart';
import '../providers/heart_controller.dart';
import '../widgets/app_back_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(
          'settings_title'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(
              'settings_language'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: DropdownButton<QuizLocale>(
              value: settings.locale,
              onChanged: (val) => val == null
                  ? null
                  : ref
                      .read(settingsControllerProvider.notifier)
                      .setLocale(val),
              items: const [
                DropdownMenuItem(value: QuizLocale.fr, child: Text('FR')),
                DropdownMenuItem(value: QuizLocale.en, child: Text('EN')),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(
              'settings_darkmode'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            value: settings.darkMode,
            onChanged: (v) =>
                ref.read(settingsControllerProvider.notifier).toggleDark(v),
          ),
          const Divider(),
          FilledButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    'dialog_confirm'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'dialog_cancel'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'dialog_confirm'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(preferencesServiceProvider).resetAll();
                await ref.read(heartsControllerProvider.notifier).reset();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(content: Text('settings_reset_done'.tr())),
                );
              }
            },
            child: Text(
              'settings_reset'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
