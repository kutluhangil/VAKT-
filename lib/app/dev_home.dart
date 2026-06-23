import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/tip.dart';
import '../data/repositories/tip_repository.dart';
import '../l10n/app_localizations.dart';
import 'controllers/locale_controller.dart';
import 'controllers/theme_controller.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';

/// TEMPORARY Phase-1 verification screen.
/// Proves: bundled fonts + light/dark theme (Agent 1), live TR/EN switch from
/// ARB (Agent 2), and the tip repository loading from assets (Agent 3).
/// Replaced by the real feed/browse shell in Phase 2.
class DevHome extends ConsumerWidget {
  const DevHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repoAsync = ref.watch(tipRepositoryProvider);
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l.appTagline, style: AppTypography.titleL),
            const SizedBox(height: 24),
            _SettingRow(
              label: l.settingsLanguage,
              child: _LanguagePicker(l: l),
            ),
            const SizedBox(height: 16),
            _SettingRow(
              label: l.settingsTheme,
              child: _ThemePicker(l: l),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            repoAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (repo) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.tipsLoaded(repo.count),
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.saffronDeep,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final tip in repo.all().take(3)) _TipPreview(tip, lang),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyL),
        child,
      ],
    );
  }
}

class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(localeProvider);
    final controller = ref.read(localeProvider.notifier);
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: 'tr', label: Text(l.languageTr)),
        ButtonSegment(value: 'en', label: Text(l.languageEn)),
        ButtonSegment(value: 'system', label: Text(l.languageSystem)),
      ],
      selected: {selected?.languageCode ?? 'system'},
      onSelectionChanged: (s) {
        final v = s.first;
        controller.setLocale(v == 'system' ? null : Locale(v));
      },
    );
  }
}

class _ThemePicker extends ConsumerWidget {
  const _ThemePicker({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final controller = ref.read(themeModeProvider.notifier);
    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: ThemeMode.light, label: Text(l.settingsThemeLight)),
        ButtonSegment(value: ThemeMode.dark, label: Text(l.settingsThemeDark)),
        ButtonSegment(
            value: ThemeMode.system, label: Text(l.settingsThemeSystem)),
      ],
      selected: {mode},
      onSelectionChanged: (s) => controller.setThemeMode(s.first),
    );
  }
}

class _TipPreview extends StatelessWidget {
  const _TipPreview(this.tip, this.lang);
  final Tip tip;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${tip.emoji}  ${tip.title.of(lang)}',
                style: AppTypography.titleL),
            const SizedBox(height: 12),
            Text(tip.primaryLabel.of(lang).toUpperCase(),
                style: AppTypography.labelCaps
                    .copyWith(color: AppColors.saffronDeep)),
            Text(tip.primary.of(lang), style: AppTypography.bodyL),
            const SizedBox(height: 8),
            Text(tip.secondaryLabel.of(lang).toUpperCase(),
                style: AppTypography.labelCaps
                    .copyWith(color: AppColors.saffronDeep)),
            Text(tip.secondary.of(lang), style: AppTypography.bodyM),
          ],
        ),
      ),
    );
  }
}
