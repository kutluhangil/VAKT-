import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'controllers/locale_controller.dart';
import 'controllers/theme_controller.dart';
import 'dev_home.dart';
import 'theme/app_theme.dart';

/// Root app: binds theme (light/dark/system) and locale (tr/en/system),
/// both driven by Riverpod + persisted in Hive.
class VaktiApp extends ConsumerWidget {
  const VaktiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Phase 1 dev harness. Replaced by the go_router bottom-nav shell in Phase 2.
      home: const DevHome(),
    );
  }
}
