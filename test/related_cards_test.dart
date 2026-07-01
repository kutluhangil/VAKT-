import 'package:flutter_test/flutter_test.dart';
import 'package:vakti/data/models/content_pillar.dart';
import 'package:vakti/data/models/localized_text.dart';
import 'package:vakti/data/models/tip.dart';
import 'package:vakti/data/repositories/tip_repository.dart';

Tip _t(String id, String cat) => Tip(
      id: id,
      pillar: ContentPillar.wellness,
      category: cat,
      emoji: '🌙',
      title: LocalizedText(tr: 'b $id', en: 't $id'),
      primary: const LocalizedText(tr: 'a', en: 'a'),
      secondary: const LocalizedText(tr: 'b', en: 'b'),
      primaryLabel: const LocalizedText(tr: 'NE', en: 'WHEN'),
      secondaryLabel: const LocalizedText(tr: 'ND', en: 'WHY'),
    );

List<Tip> related(TipRepository repo, Tip tip) => repo
    .byCategory(tip.category)
    .where((t) => t.id != tip.id)
    .take(4)
    .toList(growable: false);

void main() {
  test('related: same category, excludes self, capped at 4', () {
    final tips = [
      _t('1', 'sleep'),
      _t('2', 'sleep'),
      _t('3', 'sleep'),
      _t('4', 'sleep'),
      _t('5', 'sleep'),
      _t('6', 'sleep'),
      _t('7', 'energy'),
    ];
    final repo = TipRepository(tips);
    final r = related(repo, tips.first);
    expect(r.length, 4);
    expect(r.every((t) => t.category == 'sleep'), isTrue);
    expect(r.any((t) => t.id == '1'), isFalse);
  });

  test('related: empty when category has only the current tip', () {
    final tips = [_t('1', 'sleep'), _t('2', 'energy')];
    final repo = TipRepository(tips);
    expect(related(repo, tips.first), isEmpty);
  });
}
