import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vakti/app/app.dart';
import 'package:vakti/data/models/tip.dart';
import 'package:vakti/data/repositories/tip_repository.dart';
import 'package:vakti/data/sources/local_store.dart';

/// Phase-1 smoke test: the app boots, shows bundled content, and switches
/// language live (Agents 1, 2, 3 together). The tip repository is overridden
/// with a disk-loaded copy so the test avoids real asset I/O under the fake
/// async clock.
void main() {
  late Directory tempDir;
  late TipRepository repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vakti_test');
    await LocalStore.instance.initWithPath(tempDir.path);

    final raw = File('assets/data/tips.json').readAsStringSync();
    final list = json.decode(raw) as List<dynamic>;
    final tips =
        list.map((e) => Tip.fromJson(e as Map<String, dynamic>)).toList();
    repo = TipRepository(tips);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  testWidgets('boots, loads tips, and switches TR/EN', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tipRepositoryProvider.overrideWith((ref) => repo)],
        child: const VaktiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Default locale (en in test) tagline + content count visible.
    expect(find.text('The right thing, at the right time.'), findsOneWidget);
    expect(find.textContaining('tips loaded'), findsOneWidget);

    // Switch to Turkish via the language picker.
    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();

    expect(find.text('Doğru bilgi, doğru vakitte.'), findsOneWidget);
    expect(find.textContaining('bilgi yüklendi'), findsOneWidget);
  });
}
