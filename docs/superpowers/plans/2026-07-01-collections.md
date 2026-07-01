# User Collections Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** User-created named collections of tips, offline, alongside Favorites.

**Architecture:** `TipCollection` model + a Hive `collections` box + `CollectionsController` (Riverpod Notifier). Favorites tab gains a Favorites|Collections segment; a collection-detail screen and an add-to-collection sheet round it out.

**Tech Stack:** Flutter 3.44 / Dart 3.12, Riverpod 3 (`Notifier`), go_router, Hive, gen-l10n.

## Global Constraints

- Offline-first; no backend. No new dependencies.
- **Do NOT run `flutter analyze`** (İ path crash). Use `dart analyze lib test`.
- Widget/data tests use `LocalStore.instance.initInMemory()`; controllers set `state`
  BEFORE awaiting persistence (optimistic).
- l10n strings in BOTH `app_en.arb` and `app_tr.arb`; `flutter gen-l10n` after edits.
- Collection ids from `DateTime.now().microsecondsSinceEpoch.toString()`.
- Newest collection first.

---

### Task 1: Data layer — model, store, controller

**Files:**
- Create: `lib/data/models/tip_collection.dart`
- Modify: `lib/data/sources/local_store.dart`
- Create: `lib/data/repositories/collections_repository.dart`
- Test: `test/collections_test.dart`

**Interfaces produced:**
- `TipCollection{String id; String name; DateTime createdAt; List<String> tipIds}`
  with `Map<String,dynamic> toMap()` and `factory TipCollection.fromMap(Map)`.
- `LocalStore`: `Map<String, Map> collectionEntries()`, `Future<void> putCollection(String id, Map data)`, `Future<void> deleteCollectionData(String id)`.
- `collectionsProvider` (`NotifierProvider<CollectionsController, List<TipCollection>>`)
  with `create/rename/delete/addTip/removeTip` and `Set<String> idsFor(String tipId)`.

- [ ] **Step 1: Write failing tests**

Create `test/collections_test.dart`:

```dart
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
    final back = TipCollection.fromMap(c.toMap());
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
```

- [ ] **Step 2: Run to verify failure**

Run: `flutter test test/collections_test.dart`
Expected: FAIL — model/controller not defined.

- [ ] **Step 3: Create the model**

`lib/data/models/tip_collection.dart`:

```dart
/// A user-created named list of tip ids. Offline, Hive-backed.
class TipCollection {
  const TipCollection({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.tipIds,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> tipIds;

  Map<String, dynamic> toMap() => {
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'tipIds': tipIds,
      };

  factory TipCollection.fromMap(String id, Map data) => TipCollection(
        id: id,
        name: (data['name'] ?? '') as String,
        createdAt:
            DateTime.tryParse((data['createdAt'] ?? '') as String) ??
                DateTime.fromMillisecondsSinceEpoch(0),
        tipIds: ((data['tipIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  TipCollection copyWith({String? name, List<String>? tipIds}) => TipCollection(
        id: id,
        name: name ?? this.name,
        createdAt: createdAt,
        tipIds: tipIds ?? this.tipIds,
      );
}
```

NOTE: `toMap()` omits `id` (the map is stored under the id key); `fromMap` takes the
id separately. Update the test's round-trip to call `TipCollection.fromMap(c.id, c.toMap())`.

- [ ] **Step 4: Fix the round-trip test call**

In `test/collections_test.dart`, change `TipCollection.fromMap(c.toMap())` to
`TipCollection.fromMap(c.id, c.toMap())`.

- [ ] **Step 5: Add the collections box to LocalStore**

In `lib/data/sources/local_store.dart`:

Add the box name near `_favoritesBox`:

```dart
  static const _collectionsBox = 'collections';
```

Add an in-memory map near `_memFavorites`:

```dart
  final Map<String, Object?> _memCollections = {};
```

Add a late box field near `_favorites`:

```dart
  late Box _collections;
```

In `_openBoxes`, open it:

```dart
    _collections = await Hive.openBox(_collectionsBox);
```

In `initInMemory` and `resetInMemory`, clear it (next to `_memFavorites.clear()`):

```dart
    _memCollections.clear();
```

Add the accessor methods (next to the favorites methods):

```dart
  Map<String, Map> collectionEntries() {
    if (_memory) {
      return _memCollections.map(
        (k, v) => MapEntry(k, (v as Map)),
      );
    }
    return {
      for (final k in _collections.keys)
        k.toString(): (_collections.get(k) as Map),
    };
  }

  Future<void> putCollection(String id, Map data) async {
    if (_memory) {
      _memCollections[id] = data;
      return;
    }
    await _collections.put(id, data);
  }

  Future<void> deleteCollectionData(String id) async {
    if (_memory) {
      _memCollections.remove(id);
      return;
    }
    await _collections.delete(id);
  }
```

- [ ] **Step 6: Create the controller**

`lib/data/repositories/collections_repository.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tip_collection.dart';
import '../sources/local_store.dart';

/// User collections, persisted on-device in Hive. Newest first. State updates
/// optimistically, then writes to disk.
class CollectionsController extends Notifier<List<TipCollection>> {
  LocalStore get _store => LocalStore.instance;

  @override
  List<TipCollection> build() {
    final list = _store
        .collectionEntries()
        .entries
        .map((e) => TipCollection.fromMap(e.key, e.value))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  TipCollection? _byId(String id) {
    for (final c in state) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<String> create(String name) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final c = TipCollection(
      id: id,
      name: name.trim().isEmpty ? '—' : name.trim(),
      createdAt: DateTime.now(),
      tipIds: const [],
    );
    state = [c, ...state];
    await _store.putCollection(id, c.toMap());
    return id;
  }

  Future<void> rename(String id, String name) async {
    final c = _byId(id);
    if (c == null) return;
    final updated = c.copyWith(name: name.trim().isEmpty ? c.name : name.trim());
    state = [for (final x in state) x.id == id ? updated : x];
    await _store.putCollection(id, updated.toMap());
  }

  Future<void> delete(String id) async {
    state = state.where((c) => c.id != id).toList();
    await _store.deleteCollectionData(id);
  }

  Future<void> addTip(String id, String tipId) async {
    final c = _byId(id);
    if (c == null || c.tipIds.contains(tipId)) return;
    final updated = c.copyWith(tipIds: [...c.tipIds, tipId]);
    state = [for (final x in state) x.id == id ? updated : x];
    await _store.putCollection(id, updated.toMap());
  }

  Future<void> removeTip(String id, String tipId) async {
    final c = _byId(id);
    if (c == null) return;
    final updated =
        c.copyWith(tipIds: c.tipIds.where((t) => t != tipId).toList());
    state = [for (final x in state) x.id == id ? updated : x];
    await _store.putCollection(id, updated.toMap());
  }

  Set<String> idsFor(String tipId) =>
      {for (final c in state) if (c.tipIds.contains(tipId)) c.id};
}

final collectionsProvider =
    NotifierProvider<CollectionsController, List<TipCollection>>(
  CollectionsController.new,
);
```

- [ ] **Step 7: Run tests + analyze**

Run: `flutter test test/collections_test.dart && dart analyze lib test`
Expected: PASS; analyze clean.

- [ ] **Step 8: Commit**

```bash
git add lib/data/models/tip_collection.dart lib/data/repositories/collections_repository.dart lib/data/sources/local_store.dart test/collections_test.dart
git commit -m "feat(collections): data layer — model, Hive box, controller"
```

---

### Task 2: Favorites segment + collections list + collection detail + route

**Files:**
- Modify: `lib/features/favorites/favorites_screen.dart`
- Create: `lib/features/collections/collection_detail_screen.dart`
- Modify: `lib/app/router.dart`, `lib/l10n/app_en.arb`, `lib/l10n/app_tr.arb`
- Test: `test/collections_test.dart` (extend with a widget test)

**Interfaces consumed:** `collectionsProvider`, `tipRepositoryProvider`,
`VaktiSegmented`, `FavoriteCard`, `EmptyState`, `rootNavigatorKey`.

- [ ] **Step 1: Add l10n strings (EN then TR)**

In `lib/l10n/app_en.arb`, after `"favoritesEmptyBody"` line add:

```json
  "favoritesSegment": "Favorites",
  "collectionsSegment": "Collections",
  "newCollection": "New collection",
  "collectionNameHint": "Collection name",
  "renameCollection": "Rename",
  "deleteCollection": "Delete",
  "addToCollection": "Add to collection",
  "collectionsEmptyTitle": "No collections yet",
  "collectionsEmptyBody": "Create a list to group tips your way.",
  "collectionEmptyTitle": "This collection is empty",
  "collectionEmptyBody": "Add tips from any card.",
  "createAction": "Create",
  "cancelAction": "Cancel",
  "saveAction": "Save",
  "collectionCount": "{count} tips",
  "@collectionCount": { "placeholders": { "count": { "type": "int" } } },
```

In `lib/l10n/app_tr.arb`, after its `"favoritesEmptyBody"` line add:

```json
  "favoritesSegment": "Favoriler",
  "collectionsSegment": "Koleksiyonlar",
  "newCollection": "Yeni koleksiyon",
  "collectionNameHint": "Koleksiyon adı",
  "renameCollection": "Yeniden adlandır",
  "deleteCollection": "Sil",
  "addToCollection": "Koleksiyona ekle",
  "collectionsEmptyTitle": "Henüz koleksiyon yok",
  "collectionsEmptyBody": "Bilgileri kendi tarzında gruplamak için bir liste oluştur.",
  "collectionEmptyTitle": "Bu koleksiyon boş",
  "collectionEmptyBody": "Herhangi bir karttan bilgi ekle.",
  "createAction": "Oluştur",
  "cancelAction": "Vazgeç",
  "saveAction": "Kaydet",
  "collectionCount": "{count} bilgi",
  "@collectionCount": { "placeholders": { "count": { "type": "int" } } },
```

Run: `flutter gen-l10n` (expected: no errors).

- [ ] **Step 2: Create the collection detail screen**

`lib/features/collections/collection_detail_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/tip_collection.dart';
import '../../data/repositories/collections_repository.dart';
import '../../data/repositories/tip_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/favorite_card.dart';

/// The tips inside a single collection.
class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final collections = ref.watch(collectionsProvider);
    final repoAsync = ref.watch(tipRepositoryProvider);
    TipCollection? collection;
    for (final c in collections) {
      if (c.id == collectionId) {
        collection = c;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(collection?.name ?? '—')),
      body: repoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (repo) {
          final ids = collection?.tipIds ?? const [];
          final tips = [
            for (final id in ids)
              if (repo.byId(id) != null) repo.byId(id)!,
          ];
          if (tips.isEmpty) {
            return EmptyState(
              emoji: '📑',
              title: l.collectionEmptyTitle,
              body: l.collectionEmptyBody,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: tips.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, i) => FavoriteCard(
              tip: tips[i],
              onTap: () => context.push('/tip/${tips[i].id}'),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Register the `/collection/:id` route**

In `lib/app/router.dart`, add the import:

```dart
import '../features/collections/collection_detail_screen.dart';
```

Add after the `/streak` route (root navigator):

```dart
    GoRoute(
      path: '/collection/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) =>
          CollectionDetailScreen(collectionId: state.pathParameters['id']!),
    ),
```

- [ ] **Step 4: Rebuild the Favorites screen with a segment**

Replace the whole body of `lib/features/favorites/favorites_screen.dart` with a
`ConsumerStatefulWidget` that toggles Favorites | Collections. (Full file below.)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/tip_collection.dart';
import '../../data/repositories/collections_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/tip_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/favorite_card.dart';
import '../../widgets/vakti_screen_title.dart';
import '../../widgets/vakti_segmented.dart';

/// Favorites tab: saved tips and user collections, toggled by a segment.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _showCollections = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VaktiScreenTitle(l.favoritesTitle),
            const SizedBox(height: 16),
            VaktiSegmented<bool>(
              selected: _showCollections,
              onChanged: (v) => setState(() => _showCollections = v),
              segments: [
                VaktiSegment(false, l.favoritesSegment),
                VaktiSegment(true, l.collectionsSegment),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _showCollections
                  ? const _CollectionsView()
                  : const _FavoritesView(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesView extends ConsumerWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repoAsync = ref.watch(tipRepositoryProvider);
    final favIds = ref.watch(favoritesProvider);
    return repoAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (repo) {
        final tips = repo.all().where((t) => favIds.contains(t.id)).toList();
        if (tips.isEmpty) {
          return EmptyState(
            emoji: '🤍',
            title: l.favoritesEmptyTitle,
            body: l.favoritesEmptyBody,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
          itemCount: tips.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, i) => FavoriteCard(
            tip: tips[i],
            onTap: () => context.push('/tip/${tips[i].id}'),
          ),
        );
      },
    );
  }
}

class _CollectionsView extends ConsumerWidget {
  const _CollectionsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final collections = ref.watch(collectionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _createDialog(context, ref),
          icon: const Icon(Icons.add, size: 18),
          label: Text(l.newCollection),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: collections.isEmpty
              ? EmptyState(
                  emoji: '📑',
                  title: l.collectionsEmptyTitle,
                  body: l.collectionsEmptyBody,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                  itemCount: collections.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _CollectionRow(collection: collections[i]),
                ),
        ),
      ],
    );
  }
}

class _CollectionRow extends ConsumerWidget {
  const _CollectionRow({required this.collection});
  final TipCollection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/collection/${collection.id}'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(collection.name, style: AppTypography.titleL.copyWith(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(
                    l.collectionCount(collection.tipIds.length),
                    style: AppTypography.caption.copyWith(color: AppColors.saffronDeep),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              onSelected: (v) {
                if (v == 'rename') _renameDialog(context, ref, collection);
                if (v == 'delete') {
                  ref.read(collectionsProvider.notifier).delete(collection.id);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'rename', child: Text(l.renameCollection)),
                PopupMenuItem(value: 'delete', child: Text(l.deleteCollection)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.newCollection),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: l.collectionNameHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancelAction),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l.createAction),
        ),
      ],
    ),
  );
  if (name != null && name.trim().isNotEmpty) {
    await ref.read(collectionsProvider.notifier).create(name);
  }
}

Future<void> _renameDialog(
  BuildContext context,
  WidgetRef ref,
  TipCollection collection,
) async {
  final l = AppLocalizations.of(context);
  final controller = TextEditingController(text: collection.name);
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.renameCollection),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: l.collectionNameHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancelAction),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l.saveAction),
        ),
      ],
    ),
  );
  if (name != null && name.trim().isNotEmpty) {
    await ref.read(collectionsProvider.notifier).rename(collection.id, name);
  }
}
```

- [ ] **Step 5: Add a widget test**

Append to `test/collections_test.dart` — add these imports at the top:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vakti/data/models/tip.dart';
import 'package:vakti/data/repositories/tip_repository.dart';
import 'package:vakti/features/collections/collection_detail_screen.dart';
import 'package:vakti/l10n/app_localizations.dart';
```

And add this group inside `main()`:

```dart
  group('collection detail widget', () {
    late TipRepository repo;

    setUpAll(() {
      final raw = File('assets/data/tips.json').readAsStringSync();
      final list = json.decode(raw) as List<dynamic>;
      repo = TipRepository(
        list.map((e) => Tip.fromJson(e as Map<String, dynamic>)).toList(),
      );
    });

    testWidgets('renders the tips in a collection', (tester) async {
      LocalStore.instance.initInMemory();
      final container = ProviderContainer(
        overrides: [tipRepositoryProvider.overrideWith((ref) => repo)],
      );
      final id = await container.read(collectionsProvider.notifier).create('C');
      await container.read(collectionsProvider.notifier).addTip(id, 'w_ginger_tea');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('tr')],
            home: CollectionDetailScreen(collectionId: id),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ginger Tea'), findsOneWidget);

      container.dispose();
      LocalStore.instance.resetInMemory();
    });
  });
```

- [ ] **Step 6: Run tests + analyze**

Run: `flutter test && dart analyze lib test`
Expected: all PASS; analyze clean.

- [ ] **Step 7: Commit**

```bash
git add lib/features/favorites/favorites_screen.dart lib/features/collections/collection_detail_screen.dart lib/app/router.dart lib/l10n/app_en.arb lib/l10n/app_tr.arb lib/l10n/app_localizations*.dart test/collections_test.dart
git commit -m "feat(collections): Favorites/Collections segment, collection detail, route"
```

---

### Task 3: Add-to-collection sheet from the detail screen

**Files:**
- Create: `lib/features/collections/collection_picker_sheet.dart`
- Modify: `lib/features/detail/detail_screen.dart`

**Interfaces consumed:** `collectionsProvider`, `AppLocalizations`.

- [ ] **Step 1: Create the picker sheet**

`lib/features/collections/collection_picker_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/collections_repository.dart';
import '../../l10n/app_localizations.dart';

/// Bottom sheet to add/remove a tip to/from collections, and create new ones.
Future<void> showCollectionPicker(BuildContext context, String tipId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _CollectionPickerSheet(tipId: tipId),
  );
}

class _CollectionPickerSheet extends ConsumerStatefulWidget {
  const _CollectionPickerSheet({required this.tipId});
  final String tipId;

  @override
  ConsumerState<_CollectionPickerSheet> createState() => _SheetState();
}

class _SheetState extends ConsumerState<_CollectionPickerSheet> {
  final _newName = TextEditingController();

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final collections = ref.watch(collectionsProvider);
    final ctrl = ref.read(collectionsProvider.notifier);
    final inIds = ctrl.idsFor(widget.tipId);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.addToCollection,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final c in collections)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(c.name),
                    value: inIds.contains(c.id),
                    onChanged: (checked) {
                      if (checked ?? false) {
                        ctrl.addTip(c.id, widget.tipId);
                      } else {
                        ctrl.removeTip(c.id, widget.tipId);
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newName,
                  decoration: InputDecoration(hintText: l.newCollection),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  final name = _newName.text.trim();
                  if (name.isEmpty) return;
                  final id = await ctrl.create(name);
                  await ctrl.addTip(id, widget.tipId);
                  _newName.clear();
                },
                child: Text(l.createAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add the bookmark action to the detail app bar**

In `lib/features/detail/detail_screen.dart`, add the import:

```dart
import '../collections/collection_picker_sheet.dart';
```

In `_DetailBodyState.build`, the `SliverAppBar` has an `actions:` list containing
`TipActions(...)`. Add a bookmark button before it:

```dart
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined, size: 22),
              onPressed: () => showCollectionPicker(context, tip.id),
            ),
            TipActions(tip: tip, axis: Axis.horizontal),
            const SizedBox(width: 8),
          ],
```

- [ ] **Step 3: Run tests + analyze**

Run: `flutter test && dart analyze lib test`
Expected: all PASS; analyze clean.

- [ ] **Step 4: Commit**

```bash
git add lib/features/collections/collection_picker_sheet.dart lib/features/detail/detail_screen.dart
git commit -m "feat(collections): add-to-collection sheet from the detail screen"
```

---

## Notes for the implementer

- After all tasks: `flutter test` (existing + new green) and `dart analyze lib test`.
- No new dependencies. Favorites (the built-in bucket) is unchanged; collections are
  separate.
