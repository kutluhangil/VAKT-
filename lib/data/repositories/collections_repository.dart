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
