import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app_router.dart';
import 'providers/settings_controller.dart';
import 'data/question_repository.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('en')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('fr'),
      child: const ProviderScope(child: NaturalisationApp()),
    ),
  );
}

class NaturalisationApp extends ConsumerWidget {
  const NaturalisationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    // Keep EasyLocalization in sync with Riverpod locale
    final loc = settings.locale == QuizLocale.en
        ? const Locale('en')
        : const Locale('fr');
    if (context.locale != loc) context.setLocale(loc);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Naturalisation',
      theme: buildTheme(settings.darkMode == true ? true : false),
      routerConfig: router,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
}
