import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vakti/data/models/category.dart';
import 'package:vakti/data/sources/local_store.dart';
import 'package:vakti/features/onboarding/onboarding_screen.dart';
import 'package:vakti/features/settings/interests_provider.dart';
import 'package:vakti/l10n/app_localizations.dart';

void main() {
  setUp(() => LocalStore.instance.initInMemory());

  testWidgets('tapping a category chip selects that interest', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final first = kCategories.first;
    const lang = 'tr';
    final chip = find.widgetWithText(
      FilterChip,
      '${first.emoji} ${first.title.of(lang)}',
    );
    await tester.scrollUntilVisible(chip, 200);
    await tester.tap(chip);
    await tester.pump();

    expect(container.read(interestsProvider).contains(first.id), isTrue);
  });
}
