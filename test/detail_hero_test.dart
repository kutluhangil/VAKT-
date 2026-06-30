import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vakti/data/models/tip.dart';
import 'package:vakti/data/repositories/tip_repository.dart';
import 'package:vakti/data/sources/local_store.dart';
import 'package:vakti/features/detail/detail_screen.dart';
import 'package:vakti/l10n/app_localizations.dart';

void main() {
  group('heroParallax', () {
    test('at rest is identity', () {
      final r = heroParallax(0, 48);
      expect(r.dy, 0.0);
      expect(r.scale, 1.0);
    });

    test('scrolling up lags the image, clamped to maxShift', () {
      expect(heroParallax(100, 48).dy, closeTo(30, 1e-9)); // 100 * 0.3
      expect(heroParallax(1000, 48).dy, 48.0); // clamped
      expect(heroParallax(100, 48).scale, 1.0);
    });

    test('pull-down overscroll zooms in, clamped at 1.12', () {
      final small = heroParallax(-20, 48);
      expect(small.dy, 0.0);
      expect(small.scale, closeTo(1.03, 1e-9)); // 1 + 20*0.0015
      expect(heroParallax(-1000, 48).scale, 1.12); // clamped
    });
  });

  group('detail render', () {
    late TipRepository repo;

    setUpAll(() {
      final raw = File('assets/data/tips.json').readAsStringSync();
      final list = json.decode(raw) as List<dynamic>;
      repo = TipRepository(
        list.map((e) => Tip.fromJson(e as Map<String, dynamic>)).toList(),
      );
    });

    setUp(() => LocalStore.instance.initInMemory());
    tearDown(() => LocalStore.instance.resetInMemory());

    testWidgets('hero + title render and a scroll settles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [tipRepositoryProvider.overrideWith((ref) => repo)],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('tr')],
            home: DetailScreen(tipId: 'w_ginger_tea'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ginger Tea'), findsOneWidget); // title below the hero
      expect(find.byType(DetailScreen), findsOneWidget);

      // Drag the content up; the parallax builder must not throw.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
