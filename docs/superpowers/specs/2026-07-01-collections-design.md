# User Collections — Design

**Date:** 2026-07-01
**Status:** Approved (autonomous — user asked to proceed without approval gates)
**Feature:** User-created named collections (lists) that tips can be added to,
alongside the existing built-in Favorites. Offline, Hive-backed.

## Goal

Let users organize tips into their own lists ("Morning routine", "Sleep", …) beyond
the single Favorites bucket. Fully offline, no backend.

## Design decisions (made autonomously)

- Collections live **next to Favorites**, on the Favorites tab, via a segmented
  control: **Favorites | Collections**. No new bottom-nav tab.
- A collection is user-named, holds an ordered list of tip ids, newest-collection
  first. Tips can be in multiple collections. Favorites stays separate (unchanged).
- Add-to-collection happens from the **detail screen** app bar (a bookmark icon) via a
  bottom sheet that lists collections (checked when the tip is in them) plus an inline
  "new collection" field.
- Rename/delete a collection from a trailing ⋯ menu on each collection row.

## Non-goals (YAGNI)

- No drag-reorder of tips within a collection (append order).
- No collection cover images or colors.
- No sharing/export of collections.

## Data layer

**Model** `lib/data/models/tip_collection.dart`:

```dart
class TipCollection {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> tipIds;
}
```

with `toMap()` / `fromMap(Map)` (dates as ISO strings; `tipIds` as `List<String>`).

**LocalStore** (`lib/data/sources/local_store.dart`): a new `collections` Hive box
keyed by collection id → a `Map` value (`{name, createdAt, tipIds}`). In-memory
backing (`_memCollections`) mirrors it for widget tests. New methods:
`collectionEntries()` → `Map<String, Map>`, `putCollection(id, map)`,
`deleteCollectionData(id)`; wired into `_openBoxes` / `initInMemory` / `resetInMemory`.

**Controller** `lib/data/repositories/collections_repository.dart`:
`CollectionsController extends Notifier<List<TipCollection>>`, newest-first. Methods
(all optimistic then persist): `create(name) → id`, `rename(id, name)`,
`delete(id)`, `addTip(id, tipId)` (no duplicates, append), `removeTip(id, tipId)`.
Helper `idsFor(tipId)` returns the set of collection ids containing a tip. Ids are
generated from `DateTime.now().microsecondsSinceEpoch`.

## UI

- **Favorites screen** → `ConsumerStatefulWidget` with a `VaktiSegmented`
  (Favorites | Collections). Favorites branch unchanged. Collections branch: a
  "+ New collection" action (dialog with a text field), then a list of collection
  rows (name + tip count, trailing ⋯ → rename/delete). Empty state when none.
- **Collection detail** `lib/features/collections/collection_detail_screen.dart`,
  route `/collection/:id` (root navigator): app bar with the collection name, a list
  of its tips (reusing `FavoriteCard`), empty state when the collection has no tips.
- **Add-to-collection sheet** `lib/features/collections/collection_picker_sheet.dart`:
  opened from a bookmark icon in the detail app bar. Lists collections with a check
  when the tip is in them (tap toggles add/remove), plus an inline field to create a
  new collection and add the tip to it.

## l10n (TR + EN)

`favoritesSegment`, `collectionsSegment`, `newCollection`, `collectionNameHint`,
`renameCollection`, `deleteCollection`, `addToCollection`, `collectionsEmptyTitle`,
`collectionsEmptyBody`, `collectionEmptyTitle`, `collectionEmptyBody`,
`createAction`, `cancelAction`, `saveAction`.

## Testing

- `TipCollection.toMap/fromMap` round-trips (pure).
- `CollectionsController` over an in-memory `LocalStore`: create → appears; addTip is
  idempotent (no dup); removeTip; rename; delete; `idsFor` reflects membership.
- Light widget tests: Favorites screen shows the Collections segment; a collection
  detail renders its tips.

## Files touched

- Create: `lib/data/models/tip_collection.dart`,
  `lib/data/repositories/collections_repository.dart`,
  `lib/features/collections/collection_detail_screen.dart`,
  `lib/features/collections/collection_picker_sheet.dart`,
  `test/collections_test.dart`.
- Modify: `lib/data/sources/local_store.dart`, `lib/features/favorites/favorites_screen.dart`,
  `lib/features/detail/detail_screen.dart`, `lib/app/router.dart`,
  `lib/l10n/app_en.arb`, `lib/l10n/app_tr.arb`.
