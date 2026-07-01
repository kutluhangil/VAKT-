import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vakti/data/models/tip_collection.dart';
import 'package:vakti/data/repositories/collections_repository.dart';
import 'package:vakti/data/sources/local_store.dart';

void main() {
  test('TipCollection round-trips through a map', () {
    final c = TipCollection(
      id: '1',
      name: 'Morning',
      createdAt: DateTime(2026, 7, 1, 8),
      tipIds: const ['a', 'b'],
    );
    final back = TipCollection.fromMap(c.id, c.toMap());
    expect(back.id, '1');
    expect(back.name, 'Morning');
    expect(back.createdAt, DateTime(2026, 7, 1, 8));
    expect(back.tipIds, ['a', 'b']);
  });

  group('CollectionsController', () {
    late ProviderContainer container;

    setUp(() {
      LocalStore.instance.initInMemory();
      container = ProviderContainer();
    });
    tearDown(() {
      container.dispose();
      LocalStore.instance.resetInMemory();
    });

    test('create then addTip (idempotent) and idsFor', () async {
      final ctrl = container.read(collectionsProvider.notifier);
      final id = await ctrl.create('Sleep');
      expect(container.read(collectionsProvider).single.name, 'Sleep');

      await ctrl.addTip(id, 'w_ginger_tea');
      await ctrl.addTip(id, 'w_ginger_tea'); // dup ignored
      expect(container.read(collectionsProvider).single.tipIds, ['w_ginger_tea']);
      expect(ctrl.idsFor('w_ginger_tea'), {id});
    });

    test('removeTip, rename, delete', () async {
      final ctrl = container.read(collectionsProvider.notifier);
      final id = await ctrl.create('X');
      await ctrl.addTip(id, 't1');
      await ctrl.removeTip(id, 't1');
      expect(container.read(collectionsProvider).single.tipIds, isEmpty);

      await ctrl.rename(id, 'Y');
      expect(container.read(collectionsProvider).single.name, 'Y');

      await ctrl.delete(id);
      expect(container.read(collectionsProvider), isEmpty);
    });
  });
}
