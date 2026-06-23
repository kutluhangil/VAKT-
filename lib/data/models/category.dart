import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'content_pillar.dart';
import 'localized_text.dart';

/// A content category: id, pillar, bilingual title, tint color, emoji (§4.2).
class Category {
  final String id;
  final ContentPillar pillar;
  final LocalizedText title;
  final Color color;
  final String emoji;

  const Category({
    required this.id,
    required this.pillar,
    required this.title,
    required this.color,
    required this.emoji,
  });
}

/// The fixed category registry. Order here is the browse-grid order.
const List<Category> kCategories = [
  // Wellness
  Category(
    id: 'digestion',
    pillar: ContentPillar.wellness,
    title: LocalizedText(tr: 'Sindirim', en: 'Digestion'),
    color: AppColors.tintDigestion,
    emoji: '🫚',
  ),
  Category(
    id: 'immunity',
    pillar: ContentPillar.wellness,
    title: LocalizedText(tr: 'Bağışıklık', en: 'Immunity'),
    color: AppColors.tintImmunity,
    emoji: '🍋',
  ),
  Category(
    id: 'sleep',
    pillar: ContentPillar.wellness,
    title: LocalizedText(tr: 'Uyku', en: 'Sleep'),
    color: AppColors.tintSleep,
    emoji: '🌙',
  ),
  Category(
    id: 'energy',
    pillar: ContentPillar.wellness,
    title: LocalizedText(tr: 'Enerji', en: 'Energy'),
    color: AppColors.tintEnergy,
    emoji: '⚡',
  ),
  Category(
    id: 'skin',
    pillar: ContentPillar.wellness,
    title: LocalizedText(tr: 'Cilt', en: 'Skin'),
    color: AppColors.tintSkin,
    emoji: '✨',
  ),
  Category(
    id: 'hydration',
    pillar: ContentPillar.wellness,
    title: LocalizedText(tr: 'Hidrasyon', en: 'Hydration'),
    color: AppColors.tintHydration,
    emoji: '💧',
  ),
  // Communication
  Category(
    id: 'boundaries',
    pillar: ContentPillar.communication,
    title: LocalizedText(tr: 'Sınır Koyma', en: 'Boundaries'),
    color: AppColors.tintBoundaries,
    emoji: '🧭',
  ),
  Category(
    id: 'emotions',
    pillar: ContentPillar.communication,
    title: LocalizedText(tr: 'Duygular', en: 'Emotions'),
    color: AppColors.tintEmotions,
    emoji: '💬',
  ),
  Category(
    id: 'cooperation',
    pillar: ContentPillar.communication,
    title: LocalizedText(tr: 'İş Birliği', en: 'Cooperation'),
    color: AppColors.tintCoop,
    emoji: '🤝',
  ),
  Category(
    id: 'confidence',
    pillar: ContentPillar.communication,
    title: LocalizedText(tr: 'Özgüven', en: 'Confidence'),
    color: AppColors.tintConfidence,
    emoji: '🌱',
  ),
  Category(
    id: 'earlyYears',
    pillar: ContentPillar.communication,
    title: LocalizedText(tr: 'Bebek & İlk Yıllar', en: 'Early Years'),
    color: AppColors.tintEarlyYears,
    emoji: '🍼',
  ),
];

final Map<String, Category> kCategoryById = {
  for (final c in kCategories) c.id: c,
};

Category? categoryById(String id) => kCategoryById[id];

List<Category> categoriesForPillar(ContentPillar pillar) =>
    kCategories.where((c) => c.pillar == pillar).toList();
