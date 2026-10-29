import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      // The app's name, not translated.
      title: 'Ev',
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // The phone's language when it is Turkish or English, otherwise
      // Turkish. Choosing a language per person comes with ticket #4.
      localeResolutionCallback: (locale, supported) => supported.firstWhere(
        (candidate) => candidate.languageCode == locale?.languageCode,
        orElse: () => const Locale('tr'),
      ),
    );
  }
}
