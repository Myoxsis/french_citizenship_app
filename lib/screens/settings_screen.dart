import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_controller.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text('settings_title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('settings_language'.tr()),
            trailing: DropdownButton(
              value: settings.locale,
              onChanged: (val) => ref
                  .read(settingsControllerProvider.notifier)
                  .setLocale(val as QuizLocale),
              items: const [
                DropdownMenuItem(value: QuizLocale.fr, child: Text('FR')),
                DropdownMenuItem(value: QuizLocale.en, child: Text('EN')),
              ],
            ),
          ),
          SwitchListTile(
            title: Text('settings_darkmode'.tr()),
            value: settings.darkMode,
            onChanged: (v) =>
                ref.read(settingsControllerProvider.notifier).toggleDark(v),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('dialog_confirm'.tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('dialog_cancel'.tr()),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('dialog_confirm'.tr()),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await PreferencesService().resetAll();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Reset done.')));
              }
            },
            child: Text('settings_reset'.tr()),
          ),
        ],
      ),
    );
  }
}
