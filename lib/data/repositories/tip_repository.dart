import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/content_pillar.dart';
import '../models/tip.dart';
import '../sources/asset_tip_source.dart';

/// In-memory access to all tips. Content is fully bundled (offline-first).
class TipRepository {
  final List<Tip> _tips;
  const TipRepository(this._tips);

  List<Tip> all() => List.unmodifiable(_tips);

  int get count => _tips.length;

  List<Tip> byPillar(ContentPillar pillar) =>
      _tips.where((t) => t.pillar == pillar).toList(growable: false);

  List<Tip> byCategory(String categoryId) =>
      _tips.where((t) => t.category == categoryId).toList(growable: false);

  Tip? byId(String id) {
    for (final t in _tips) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// Async-loads the repository once and caches it for the app's lifetime.
final tipRepositoryProvider = FutureProvider<TipRepository>((ref) async {
  final tips = await const AssetTipSource().load();
  return TipRepository(tips);
});
