# Vakti — Flutter Uygulama Blueprint'i

> **Tagline (TR):** Doğru bilgi, doğru vakitte.
> **Tagline (EN):** The right thing, at the right time.
>
> **Tür:** Ücretsiz, reklamsız, offline mobil uygulama (iOS + Android)
> **Stack:** Flutter / Dart
> **Diller:** Türkçe + İngilizce
> **Bu doküman:** Claude Code ile faz faz çalıştırılmak üzere yazılmıştır. Her faz bir "agent"e karşılık gelir; her agent'in sahip olduğu dosyalar ve kabul kriterleri tanımlıdır.

---

## 1. Vizyon ve Konsept

Vakti, kullanıcının **kısa, premium, kart formatında yararlı bilgiler** okuduğu sakin bir uygulamadır. Her bilgi "ne zaman" ve "neden" sorusuna cevap verir. Bilgiler iki içerik sütununa ayrılır:

| Sütun | Türkçe | İçerik şekli | Örnek |
|---|---|---|---|
| `wellness` | Sağlıklı Yaşam | Başlık → *Ne Zaman* → *Neden* | "Zencefil Çayı → Ağır yemekten sonra → Sindirimi rahatlatır." |
| `communication` | İletişim | Cümle → *Ne Zaman Söylenir* → *Neden İşe Yarar* | "\"Sana yardım edeceğim ama senin yerine yapmayacağım.\" → Çocuk zorlandığında → Sorumluluğu ona bırakır." |

Kullanıcı bu bilgileri akışta okur, beğendiğini kaydeder, görsel olarak paylaşır ve isterse **ana ekran widget'ı** ile her gün telefonunda görür.

### Temel ilkeler
- **Backend yok, login yok, hesap yok.** Tüm içerik uygulamayla birlikte gelir (offline-first).
- **Veri toplanmaz.** Hiçbir analytics/tracking yok → mağaza onayı ve gizlilik kolaylaşır.
- **Reklamsız.** AdMob veya benzeri SDK eklenmez.
- **İki dil, tek veri.** İçerik veri modelinde hem `tr` hem `en` taşır; dil değişince anında güncellenir.

---

## 2. Karar Özeti (kilitlenen varsayılanlar)

Bu kararlar blueprint'i çalıştırılabilir kılmak için varsayılan olarak alınmıştır. İstediğin an değiştirebilirsin; her biri tek bir agent'i etkiler.

| Karar | Seçim | Not |
|---|---|---|
| Ana akış stili | **Tam ekran dikey kaydırma (Reels tarzı)** + kategori gözatma | Kaynak içerik birebir bu formatta |
| MVP ek özellikler | **Favoriler · Kartı görsel paylaş · Günlük bildirim** | Streak → ileri faz |
| Widget davranışı | **Her gün otomatik + dokununca yeni bilgi** | `workmanager` ile günlük yenileme |
| Kategori sistemi | **Var** | Her kategori renk + ikon taşır |
| Reklam | **Yok** | — |
| İsim | **Vakti** | — |
| İçerik sütunları | **Sağlıklı Yaşam + İletişim** | İletişim: çocuk + bebek/ilk yıllar odaklı |

---

## 3. Tasarım Sistemi

> Amaç: jenerik "AI varsayılanı" görünümden (mor gradyan, her yerde aynı sans-serif, gereksiz gölge) kaçınmak. Vakti'nin kimliği **editoryal, sakin ve "altın saat" sıcaklığında** olmalı.

### 3.1 Konsept
"Vakit" = doğru zaman = **altın saat (golden hour)**. Marka, günün dingin geçiş anlarının sıcaklığını taşır: koyu mürekkep zemin, sıcak kâğıt tonları, tek bir safran/amber vurgu.

### 3.2 Renk Token'ları

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  // Marka
  static const ink        = Color(0xFF14181F); // koyu mürekkep (dark zemin)
  static const paper      = Color(0xFFF7F3EC); // sıcak kâğıt (light zemin)
  static const saffron    = Color(0xFFE0A24B); // vurgu — altın saat
  static const saffronDeep = Color(0xFFC07F2E);

  // Light tema
  static const lightBg      = paper;
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText    = Color(0xFF1B1F27);
  static const lightMuted   = Color(0xFF6B7280);
  static const lightBorder = Color(0xFFE6DFD3); // ince ayraçlar

  // Dark tema
  static const darkBg      = ink;
  static const darkSurface = Color(0xFF1C222B);
  static const darkText    = Color(0xFFF2EFE9);
  static const darkMuted   = Color(0xFF9BA3AF);
  static const darkBorder  = Color(0xFF2A323D);

  // Kategori tint'leri (ince, arka plan vurgusu için)
  static const tintDigestion = Color(0xFF7FB069); // sindirim
  static const tintImmunity  = Color(0xFFE07A5F); // bağışıklık
  static const tintSleep     = Color(0xFF6C7BBF); // uyku
  static const tintEnergy    = Color(0xFFE0A24B); // enerji
  static const tintSkin      = Color(0xFFD98CA3); // cilt
  static const tintHydration = Color(0xFF5BA6C9); // su
  static const tintBoundaries= Color(0xFF8E7CC3); // sınır koyma
  static const tintEmotions  = Color(0xFFD98CA3); // duygular
  static const tintCoop      = Color(0xFF7FB069); // iş birliği
  static const tintConfidence= Color(0xFFE0A24B); // özgüven
  static const tintEarlyYears= Color(0xFF5BA6C9); // bebek & ilk yıllar
}
```

### 3.3 Tipografi
Premium-editoryal his için **başlıklarda serif, gövdede sans** ikilisi:

- **Display / Başlık:** `Fraunces` (veya `Newsreader`) — serif, sıcak, karakterli. Kart başlıkları burada.
- **Gövde / UI:** `Inter` — temiz, yüksek okunabilirlik.
- Fontlar **bundle edilir** (`assets/fonts/`), `google_fonts` runtime indirme yok → offline ve hızlı.

```dart
// Ölçek
titleXL  : Fraunces 34 / w600
titleL   : Fraunces 26 / w600
labelCaps: Inter 12 / w600 / letterSpacing 1.2 / uppercase  (örn. "NE ZAMAN")
bodyL    : Inter 18 / w400 / height 1.4
bodyM    : Inter 15 / w400
caption  : Inter 13 / w500
```

### 3.4 İmza görsel motif
**"Zaman yayı":** her kartın üstünde, kategoriye göre konumlanan ince bir yarım ay/yay + nokta (günün anını sembolize eder). Sabah/öğle/akşam içerikleri yayda farklı konumda durur. Bu, hem "vakit" temasını görsel kılar hem markaya özgüdür. Widget'ta da aynı yay küçük halde kullanılır.

### 3.5 Boşluk & şekil
- Köşe yarıçapı: kartlar `20`, butonlar `14`.
- Gölge yok; ayrım için ince border + tint zemin.
- Bol negatif alan; tek kartta dikkat tek bilgide.
- 8pt grid (`4, 8, 12, 16, 24, 32, 48`).

---

## 4. İçerik Mimarisi

### 4.1 Veri modeli (iki sütunu tek modelle taşır)

```dart
// lib/data/models/tip.dart
enum ContentPillar { wellness, communication }

class LocalizedText {
  final String tr;
  final String en;
  const LocalizedText({required this.tr, required this.en});
  String of(String locale) => locale == 'tr' ? tr : en;
  factory LocalizedText.fromJson(Map<String, dynamic> j) =>
      LocalizedText(tr: j['tr'] as String, en: j['en'] as String);
}

class Tip {
  final String id;
  final ContentPillar pillar;
  final String category;        // kategori id (bkz. 4.2)
  final String emoji;           // hızlı görsel ipucu
  final LocalizedText title;    // wellness: besin adı / communication: cümle
  final LocalizedText primary;  // "ne zaman" satırı
  final LocalizedText secondary;// "neden" satırı
  final LocalizedText primaryLabel;   // örn. "Ne Zaman" / "Ne Zaman Söylenir"
  final LocalizedText secondaryLabel; // örn. "Neden" / "Neden İşe Yarar"

  const Tip({
    required this.id, required this.pillar, required this.category,
    required this.emoji, required this.title, required this.primary,
    required this.secondary, required this.primaryLabel, required this.secondaryLabel,
  });

  factory Tip.fromJson(Map<String, dynamic> j) => Tip(
    id: j['id'],
    pillar: ContentPillar.values.byName(j['pillar']),
    category: j['category'],
    emoji: j['emoji'],
    title: LocalizedText.fromJson(j['title']),
    primary: LocalizedText.fromJson(j['primary']),
    secondary: LocalizedText.fromJson(j['secondary']),
    primaryLabel: LocalizedText.fromJson(j['primaryLabel']),
    secondaryLabel: LocalizedText.fromJson(j['secondaryLabel']),
  );
}
```

### 4.2 Kategoriler

```dart
// lib/data/models/category.dart  (id, pillar, başlık TR/EN, renk, ikon)
wellness:
  digestion  → Sindirim / Digestion      🫚
  immunity   → Bağışıklık / Immunity      🍋
  sleep      → Uyku / Sleep               🌙
  energy     → Enerji / Energy            ⚡
  skin       → Cilt / Skin                ✨
  hydration  → Hidrasyon / Hydration      💧
communication:
  boundaries → Sınır Koyma / Boundaries   🧭
  emotions   → Duygular / Emotions        💬
  cooperation→ İş Birliği / Cooperation   🤝
  confidence → Özgüven / Confidence       🌱
  earlyYears → Bebek & İlk Yıllar / Early Years 🍼
```

### 4.3 Başlangıç içeriği (`assets/data/tips.json`)

> Aşağıdaki tohum içerik özgün olarak üretilmiştir. **Sağlık içeriği iddialı tıbbi cümlelerden kaçınır; iletişim içeriği genel ebeveynlik diline dayanır.** Build sırasında her kategoride en az 8–10 karta tamamlanmalı (toplam hedef ~60–80 kart, dengeli dağılım).

```json
[
  {
    "id": "w_ginger_tea", "pillar": "wellness", "category": "digestion", "emoji": "🫚",
    "title": {"tr": "Zencefil Çayı", "en": "Ginger Tea"},
    "primary": {"tr": "Ağır bir yemekten sonra", "en": "After a heavy meal"},
    "secondary": {"tr": "Şişkinlik hissini azaltır, sindirimi rahatlatır.", "en": "Helps ease bloating and supports digestion."},
    "primaryLabel": {"tr": "Ne Zaman", "en": "When"}, "secondaryLabel": {"tr": "Neden", "en": "Why"}
  },
  {
    "id": "w_kefir", "pillar": "wellness", "category": "digestion", "emoji": "🥛",
    "title": {"tr": "Kefir", "en": "Kefir"},
    "primary": {"tr": "İkindi vakti, ara öğün olarak", "en": "Mid-afternoon, as a snack"},
    "secondary": {"tr": "Tok tutar ve bağırsak florasını destekler.", "en": "Keeps you full and supports gut flora."},
    "primaryLabel": {"tr": "Ne Zaman", "en": "When"}, "secondaryLabel": {"tr": "Neden", "en": "Why"}
  },
  {
    "id": "w_water_morning", "pillar": "wellness", "category": "hydration", "emoji": "💧",
    "title": {"tr": "Bir Bardak Su", "en": "A Glass of Water"},
    "primary": {"tr": "Uyanır uyanmaz, kahvaltıdan önce", "en": "Right after waking, before breakfast"},
    "secondary": {"tr": "Gece boyu kaybedilen sıvıyı yerine koyar, güne canlı başlatır.", "en": "Replaces fluid lost overnight and helps you start the day fresh."},
    "primaryLabel": {"tr": "Ne Zaman", "en": "When"}, "secondaryLabel": {"tr": "Neden", "en": "Why"}
  },
  {
    "id": "w_walk_after_meal", "pillar": "wellness", "category": "digestion", "emoji": "🚶",
    "title": {"tr": "Kısa Yürüyüş", "en": "A Short Walk"},
    "primary": {"tr": "Yemekten 15 dakika sonra", "en": "About 15 minutes after eating"},
    "secondary": {"tr": "Kan şekerinin daha dengeli seyretmesine yardımcı olur.", "en": "Helps keep blood sugar steadier after meals."},
    "primaryLabel": {"tr": "Ne Zaman", "en": "When"}, "secondaryLabel": {"tr": "Neden", "en": "Why"}
  },
  {
    "id": "w_chamomile", "pillar": "wellness", "category": "sleep", "emoji": "🌼",
    "title": {"tr": "Papatya Çayı", "en": "Chamomile Tea"},
    "primary": {"tr": "Yatmadan ~1 saat önce", "en": "About an hour before bed"},
    "secondary": {"tr": "Sakinleşmeye ve güne yumuşak bir kapanış yapmaya yardımcı olur.", "en": "Helps you wind down for a calmer end to the day."},
    "primaryLabel": {"tr": "Ne Zaman", "en": "When"}, "secondaryLabel": {"tr": "Neden", "en": "Why"}
  },
  {
    "id": "w_sunlight", "pillar": "wellness", "category": "energy", "emoji": "☀️",
    "title": {"tr": "Sabah Işığı", "en": "Morning Light"},
    "primary": {"tr": "Uyandıktan sonraki ilk saat içinde", "en": "Within the first hour of waking"},
    "secondary": {"tr": "Vücut saatini düzenler, gün içi uyanıklığı destekler.", "en": "Helps set your body clock and supports daytime alertness."},
    "primaryLabel": {"tr": "Ne Zaman", "en": "When"}, "secondaryLabel": {"tr": "Neden", "en": "Why"}
  },
  {
    "id": "w_lemon_water", "pillar": "wellness", "category": "immunity", "emoji": "🍋",
    "title": {"tr": "Ilık Limonlu Su", "en": "Warm Lemon Water"},
    "primary": {"tr": "Sabah, aç karnına", "en": "In the morning, on an empty stomach"},
    "secondary": {"tr": "Güne hafif bir başlangıç ve sıvı alımı için keyifli bir yol.", "en": "A pleasant way to hydrate and ease into the day."},
    "primaryLabel": {"tr": "Ne Zaman", "en": "When"}, "secondaryLabel": {"tr": "Neden", "en": "Why"}
  },
  {
    "id": "w_screen_off", "pillar": "wellness", "category": "sleep", "emoji": "📵",
    "title": {"tr": "Ekranları Bırak", "en": "Put Screens Away"},
    "primary": {"tr": "Yatmadan 30–60 dakika önce", "en": "30–60 minutes before bed"},
    "secondary": {"tr": "Zihnin yavaşlamasına ve uykuya geçişin kolaylaşmasına yardımcı olur.", "en": "Lets the mind slow down so falling asleep gets easier."},
    "primaryLabel": {"tr": "Ne Zaman", "en": "When"}, "secondaryLabel": {"tr": "Neden", "en": "Why"}
  },

  {
    "id": "c_help_not_for_you", "pillar": "communication", "category": "boundaries", "emoji": "🧭",
    "title": {"tr": "\"Sana yardım ederim ama senin yerine yapmam.\"", "en": "\"I'll help you, but I won't do it for you.\""},
    "primary": {"tr": "Çocuk bir işte zorlanıp pes etmek üzereyken", "en": "When your child struggles and is about to give up"},
    "secondary": {"tr": "Destek verirken sorumluluğu çocukta bırakır.", "en": "Offers support while leaving responsibility with the child."},
    "primaryLabel": {"tr": "Ne Zaman Söylenir", "en": "When to Say It"}, "secondaryLabel": {"tr": "Neden İşe Yarar", "en": "Why It Works"}
  },
  {
    "id": "c_stop_to_keep_safe", "pillar": "communication", "category": "boundaries", "emoji": "🛑",
    "title": {"tr": "\"Şu an durduruyorum çünkü güvende kalman gerekiyor.\"", "en": "\"I'm stopping this now because you need to stay safe.\""},
    "primary": {"tr": "Tehlikeli bir davranışı kesmen gerektiğinde", "en": "When you need to stop a risky behavior"},
    "secondary": {"tr": "Sınırın amacının kontrol değil, korumak olduğunu gösterir.", "en": "Shows the boundary is about protection, not control."},
    "primaryLabel": {"tr": "Ne Zaman Söylenir", "en": "When to Say It"}, "secondaryLabel": {"tr": "Neden İşe Yarar", "en": "Why It Works"}
  },
  {
    "id": "c_feelings_ok", "pillar": "communication", "category": "emotions", "emoji": "💬",
    "title": {"tr": "\"İstediğin gibi olmadığı için üzülmen çok normal.\"", "en": "\"It's okay to be upset that it didn't go your way.\""},
    "primary": {"tr": "Çocuk hayal kırıklığı yaşadığında", "en": "When your child is disappointed"},
    "secondary": {"tr": "Duyguyu kabul eder ama sınırdan vazgeçmez.", "en": "Accepts the feeling without abandoning the boundary."},
    "primaryLabel": {"tr": "Ne Zaman Söylenir", "en": "When to Say It"}, "secondaryLabel": {"tr": "Neden İşe Yarar", "en": "Why It Works"}
  },
  {
    "id": "c_my_job", "pillar": "communication", "category": "boundaries", "emoji": "🌟",
    "title": {"tr": "\"Benim işim seni korumak, her dediğine evet demek değil.\"", "en": "\"My job is to keep you safe, not to say yes to everything.\""},
    "primary": {"tr": "Ardı ardına gelen 'olmaz' tepkilerinde", "en": "When facing repeated pushback on a 'no'"},
    "secondary": {"tr": "Ebeveynliğin amacının memnun etmek değil rehberlik etmek olduğunu hatırlatır.", "en": "Reminds that parenting is about guidance, not pleasing."},
    "primaryLabel": {"tr": "Ne Zaman Söylenir", "en": "When to Say It"}, "secondaryLabel": {"tr": "Neden İşe Yarar", "en": "Why It Works"}
  },
  {
    "id": "c_listening_no_change", "pillar": "communication", "category": "boundaries", "emoji": "🤝",
    "title": {"tr": "\"Seni dinliyorum ama kararım değişmeyecek.\"", "en": "\"I hear you, but my decision won't change.\""},
    "primary": {"tr": "Çocuk pazarlık etmeye çalışırken", "en": "When your child tries to negotiate a firm limit"},
    "secondary": {"tr": "Sınırın tartışmaya açık olmadığını sakin bir dille ifade eder.", "en": "Calmly signals the limit isn't up for debate."},
    "primaryLabel": {"tr": "Ne Zaman Söylenir", "en": "When to Say It"}, "secondaryLabel": {"tr": "Neden İşe Yarar", "en": "Why It Works"}
  },
  {
    "id": "c_try_together", "pillar": "communication", "category": "cooperation", "emoji": "🧩",
    "title": {"tr": "\"Hadi bunu birlikte çözelim.\"", "en": "\"Let's figure this out together.\""},
    "primary": {"tr": "Çocuk bir görevden kaçındığında", "en": "When your child avoids a task"},
    "secondary": {"tr": "İş birliğini emir vermeden davet eder.", "en": "Invites cooperation without issuing commands."},
    "primaryLabel": {"tr": "Ne Zaman Söylenir", "en": "When to Say It"}, "secondaryLabel": {"tr": "Neden İşe Yarar", "en": "Why It Works"}
  },
  {
    "id": "c_you_can_handle", "pillar": "communication", "category": "confidence", "emoji": "🌱",
    "title": {"tr": "\"Bu zor ama senin bunu yapabileceğini biliyorum.\"", "en": "\"This is hard, but I know you can handle it.\""},
    "primary": {"tr": "Çocuk 'yapamam' dediğinde", "en": "When your child says 'I can't'"},
    "secondary": {"tr": "Zorluğu küçümsemeden çocuğun yeterlilik duygusunu besler.", "en": "Builds competence without dismissing the difficulty."},
    "primaryLabel": {"tr": "Ne Zaman Söylenir", "en": "When to Say It"}, "secondaryLabel": {"tr": "Neden İşe Yarar", "en": "Why It Works"}
  },
  {
    "id": "c_name_the_feeling", "pillar": "communication", "category": "earlyYears", "emoji": "🍼",
    "title": {"tr": "\"Kızgınsın, görüyorum.\"", "en": "\"You're angry — I can see it.\""},
    "primary": {"tr": "Küçük çocuk öfke nöbetindeyken", "en": "When a young child is mid-meltdown"},
    "secondary": {"tr": "Duyguyu isimlendirmek çocuğun sakinleşmesine yardımcı olur.", "en": "Naming the feeling helps the child settle."},
    "primaryLabel": {"tr": "Ne Zaman Söylenir", "en": "When to Say It"}, "secondaryLabel": {"tr": "Neden İşe Yarar", "en": "Why It Works"}
  }
]
```

> **İletişim içeriği üretim kuralları (build agent'e):** klinik/kesin iddialardan kaçın; "her zaman/garanti" gibi kelimeler kullanma; ton destekleyici ve genel olsun. Bu içerik profesyonel pedagojik/psikolojik tavsiye değildir (bkz. §13).

---

## 5. Lokalizasyon (TR + EN)

İki katmanlı:
1. **UI metinleri** → `flutter_localizations` + `intl` + ARB dosyaları (`lib/l10n/app_tr.arb`, `app_en.arb`).
2. **İçerik metinleri** → `LocalizedText` modeli (veri içinde).

```dart
// LocaleController (Riverpod) — sistem dili + kullanıcı override
final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) =>
    LocaleController());
// Ayarlar'da TR / EN / Sistem seçimi; Hive'da saklanır.
```

Örnek ARB anahtarları: `appTitle`, `tabFeed`, `tabBrowse`, `tabFavorites`, `tabSettings`, `saveTip`, `shareTip`, `dailyReminderTitle`, `disclaimerBody`, `onboarding1Title` …

---

## 6. Uygulama Mimarisi

### 6.1 Klasör yapısı (feature-first)

```
lib/
  main.dart
  app/
    app.dart                 # MaterialApp.router, theme, locale bağlama
    router.dart              # go_router rotaları
    theme/
      app_theme.dart         # light/dark ThemeData
      app_colors.dart
      app_typography.dart
  core/
    constants.dart
    extensions.dart
    result.dart
  l10n/
    app_tr.arb
    app_en.arb
  data/
    models/ (tip.dart, category.dart, content_pillar.dart)
    sources/ (asset_tip_source.dart, local_store.dart)   # Hive
    repositories/ (tip_repository.dart, favorites_repository.dart)
  features/
    onboarding/
    feed/       # tam ekran dikey kaydırma
    browse/     # kategori gözatma + filtre
    detail/     # tek kart geniş hali
    favorites/
    settings/
  widgets/      # paylaşılan UI: TipCard, TimeArc, PillBadge, EmptyState
  services/
    daily_tip_service.dart   # günün bilgisi (deterministik seed)
    notification_service.dart
    widget_service.dart      # home_widget köprüsü
    share_service.dart       # kartı görsele çevir + paylaş
assets/
  data/tips.json
  fonts/ (Fraunces, Inter)
  icons/
```

### 6.2 State yönetimi
`flutter_riverpod`. Ana provider'lar: `tipRepositoryProvider`, `feedTipsProvider`, `favoritesProvider`, `localeProvider`, `themeModeProvider`, `dailyTipProvider`, `selectedCategoryProvider`.

### 6.3 Navigasyon
`go_router` ile alt sekme (bottom nav) kabuğu: **Akış · Gözat · Favoriler · Ayarlar**. Detay sayfası push.

### 6.4 "Günün bilgisi" deterministik seed
Aynı gün herkeste/widget'ta aynı kart çıksın diye tarih tabanlı seçim:
```dart
int seed = int.parse(DateFormat('yyyyMMdd').format(DateTime.now()));
final tip = allTips[seed % allTips.length];
```

---

## 7. Ekranlar ve Akışlar

1. **Onboarding (3 ekran)** — (a) hoş geldin + "zaman yayı" animasyonu, (b) iki sütun tanıtımı, (c) dil seçimi (TR/EN/Sistem) + **kısa bilgilendirme notu onayı**. Sadece ilk açılışta (Hive `onboardingDone`).
2. **Akış (Feed)** — `PageView` dikey, tam ekran kartlar. Sağ tarafta dikey aksiyonlar: ❤️ kaydet, ⤴️ paylaş. Üstte sütun filtresi (Tümü / Sağlıklı Yaşam / İletişim).
3. **Gözat (Browse)** — kategori grid'i (renk + ikon + emoji). Kategoriye tıkla → o kategorinin kart listesi.
4. **Detay** — tek kartın geniş, paylaşılabilir hali (paylaşım görseli buradan üretilir).
5. **Favoriler** — kaydedilen kartlar; boşsa zarif empty-state.
6. **Ayarlar** — Dil · Tema (Açık/Koyu/Sistem) · Günlük bildirim (aç/kapa + saat) · Widget bilgisi · **Bilgilendirme/Yasal** · Hakkında · Uygulamayı değerlendir.

---

## 8. Ana Ekran Widget'ı (kritik, native gerektirir)

`home_widget` paketi Flutter ↔ native köprüsü kurar; **her platformda native widget kodu yazılır.**

### 8.1 Akış
1. Flutter tarafı günün bilgisini hesaplar → `HomeWidget.saveWidgetData('title', ...)` vb. ile yazar.
2. `HomeWidget.updateWidget(...)` çağrılır.
3. Native widget bu veriyi okuyup render eder.
4. Günlük yenileme: `workmanager` ile günde 1 periyodik görev veriyi tazeler; ayrıca widget'a dokununca uygulama açılır ve yeni kart yazılır.

### 8.2 iOS (WidgetKit / SwiftUI)
- Xcode'da **Widget Extension** target (`VaktiWidget`).
- App Group (`group.com.vakti.app`) ile veri paylaşımı (`UserDefaults(suiteName:)`).
- Boyutlar: `systemSmall` (başlık + emoji + zaman yayı), `systemMedium` (başlık + ne zaman + neden).
- `TimelineProvider` ile günlük güncelleme.

### 8.3 Android (App Widget)
- `AppWidgetProvider` (`VaktiWidgetProvider`) + `res/layout/vakti_widget.xml`.
- `res/xml/vakti_widget_info.xml` (resizable, min boyutlar).
- `home_widget`'ın `backgroundCallback`'i ile veri güncelleme; tıklamada `HomeWidget` PendingIntent.

### 8.4 Tasarım
Widget de markaya sadık: koyu mürekkep zemin, safran "zaman yayı", serif başlık. Light/dark uyumlu.

> **Uyarı (build agent):** widget MVP'nin parçası ama iki platformda native kod gerektirdiği için ayrı faz/agent. Önce Android (daha hızlı iterasyon), sonra iOS.

---

## 9. Bildirimler ve Paylaşım

### 9.1 Günlük bildirim
`flutter_local_notifications` + `timezone`. Kullanıcı saat seçer (varsayılan 09:00). Bildirim metni: "Bugünün bilgisi hazır 🌅 / Today's tip is ready". Dokununca → ilgili karta gider. İzin akışı iOS/Android 13+ için ele alınır. Varsayılan **kapalı**, kullanıcı açar (gizlilik dostu).

### 9.2 Kartı görsel olarak paylaş
`screenshot` (veya `RenderRepaintBoundary`) ile kartı PNG'ye çevir → `share_plus` ile paylaş. Paylaşım görselinde küçük "Vakti" filigranı + uygulama adı (organik büyüme). Görsel 1080×1350 (4:5) üretilir.

---

## 10. 9-Agent Sistemi (dosya sahipliği + kabul kriterleri)

> Her agent kendi dosyalarına sahiptir; başka agent'in dosyasını değiştirmez. Sıra önemlidir (1→9). Her agent bitince `flutter analyze` temiz olmalı.

### Agent 1 — Temel & Tema
**Sahip:** `app/app.dart`, `app/theme/*`, `main.dart`, `pubspec.yaml`, `assets/fonts/`
**Görev:** Proje iskeleti, light/dark ThemeData, renk/tipografi token'ları, font bundle, `flutter_lints`.
**Kabul:** Boş uygulama TR/EN locale ve light/dark temayla açılıyor; `analyze` temiz.

### Agent 2 — Lokalizasyon
**Sahip:** `l10n/*`, `app/router.dart` (locale bağlama), `LocaleController`
**Görev:** ARB dosyaları, `intl` generate, dil değiştirici, Hive'da locale saklama.
**Kabul:** Ayarlar'dan TR↔EN anında değişiyor; tüm UI string'leri ARB'den geliyor.

### Agent 3 — Veri & Modeller
**Sahip:** `data/models/*`, `data/sources/*`, `data/repositories/tip_repository.dart`, `assets/data/tips.json`
**Görev:** Modeller, `tips.json` (her kategoride ≥8 kart, çift dilli), asset loader, kategori tanımları, repository, Hive init.
**Kabul:** `tipRepository.all()` ≥60 kart döndürüyor; tüm kartlarda `tr` ve `en` dolu; JSON şema testi geçiyor.

### Agent 4 — Akış (Feed)
**Sahip:** `features/feed/*`, `widgets/tip_card.dart`, `widgets/time_arc.dart`
**Görev:** Dikey `PageView` tam ekran akış, TipCard bileşeni, zaman yayı motifi, sütun filtresi.
**Kabul:** Kartlar dikey kaydırılıyor; iki sütun da görünüyor; locale/tema değişimi anında yansıyor.

### Agent 5 — Gözat & Kategoriler
**Sahip:** `features/browse/*`, `widgets/category_tile.dart`
**Görev:** Kategori grid'i, kategoriye göre filtreli liste.
**Kabul:** Her kategori doğru renk/ikonla görünüyor; seçince yalnız o kategori kartları listeleniyor.

### Agent 6 — Detay, Favoriler & Paylaşım
**Sahip:** `features/detail/*`, `features/favorites/*`, `data/repositories/favorites_repository.dart`, `services/share_service.dart`
**Görev:** Detay sayfası, favori kaydet/sil (Hive, kalıcı), kartı görsele çevirip paylaş.
**Kabul:** Favori app yeniden açılınca kalıyor; paylaşım 4:5 PNG üretip paylaşım sayfasını açıyor.

### Agent 7 — Widget (native)
**Sahip:** `services/widget_service.dart`, iOS `VaktiWidget/*`, Android `VaktiWidgetProvider` + layout XML, `workmanager` kurulumu
**Görev:** `home_widget` entegrasyonu, iOS + Android widget, günlük + dokunmayla yenileme.
**Kabul:** Her iki platformda ana ekrana eklenen widget günün bilgisini gösteriyor; ertesi gün/dokununca değişiyor.

### Agent 8 — Bildirim & Günün Bilgisi
**Sahip:** `services/notification_service.dart`, `services/daily_tip_service.dart`
**Görev:** İzin akışı, planlı günlük bildirim, saat seçimi, deterministik günün bilgisi.
**Kabul:** Seçilen saatte bildirim geliyor; dokununca doğru karta gidiyor; widget ve bildirim aynı günün kartında hemfikir.

### Agent 9 — Onboarding, Ayarlar & Uyumluluk
**Sahip:** `features/onboarding/*`, `features/settings/*`, store metadata, gizlilik/yasal metinler
**Görev:** 3 ekranlı onboarding, ayarlar, **bilgilendirme/yasal notu**, mağaza varlıkları (ikon, açıklama TR/EN), gizlilik politikası.
**Kabul:** İlk açılışta onboarding bir kez çıkıyor; ayarlar tüm tercihleri kalıcı saklıyor; disclaimer erişilebilir.

---

## 11. Faz Planı ve Commit Örnekleri

| Faz | Agent(ler) | Çıktı |
|---|---|---|
| 1 | 1, 2, 3 | İskelet + tema + lokalizasyon + veri katmanı |
| 2 | 4, 5 | Akış + kategori gözatma |
| 3 | 6 | Detay + favoriler + paylaşım |
| 4 | 7 | Widget (Android → iOS) |
| 5 | 8 | Bildirim + günün bilgisi |
| 6 | 9 | Onboarding + ayarlar + uyumluluk + yayın hazırlığı |

**Örnek commit mesajları (conventional, sade, AI imzası yok):**
```
feat(theme): add light/dark theme tokens and Fraunces/Inter typography
feat(data): load bilingual tips from assets and expose tip repository
feat(feed): vertical full-screen tip feed with pillar filter
feat(favorites): persist saved tips with Hive
feat(widget): wire home_widget for android app widget
feat(notify): schedule daily tip reminder with timezone support
chore(store): add bilingual store listing and privacy policy
```

---

## 12. Mağaza Uyumluluğu

### App Store (iOS)
- **Privacy Nutrition Label:** "Data Not Collected" (hiçbir veri toplanmıyor).
- Health içeriği için **bilgilendirme notu** zorunlu (genel bilgi, tıbbi tavsiye değil).
- Widget, WidgetKit yönergelerine uygun; özel/private API yok.
- App Group + extension imzaları doğru.

### Google Play (Android)
- **Data Safety formu:** veri toplanmıyor/paylaşılmıyor.
- Güncel `targetSdk`; bildirim için `POST_NOTIFICATIONS` (Android 13+) izni runtime.
- Sağlık kategorisi için yanıltıcı iddia yok.
- `workmanager` arka plan kısıtlarına uyumlu.

### Ortak
- Gizlilik politikası URL'i (veri toplanmasa da mağaza ister) — basit "hiçbir veri toplamıyoruz" metni, TR + EN.
- Uygulama ikonu + ekran görüntüleri TR ve EN.

---

## 13. Yasal / Bilgilendirme Notu (zorunlu)

Onboarding'de onaylanır, Ayarlar'da her zaman erişilir:

> **TR:** "Vakti'deki içerikler yalnızca genel bilgilendirme amaçlıdır ve profesyonel tıbbi, psikolojik veya pedagojik tavsiye yerine geçmez. Sağlık veya çocuğunuzla ilgili önemli kararlarda lütfen uzmana danışın."
>
> **EN:** "Content in Vakti is for general information only and is not a substitute for professional medical, psychological, or parenting advice. For important health or child-related decisions, please consult a qualified professional."

İçerik üretiminde: kesin/iddialı tıbbi cümle yok; "tedavi eder, iyileştirir, garanti" gibi ifadeler yasak; destekleyici ve genel dil.

---

## 14. Gizlilik

- Hiçbir kişisel veri toplanmaz, sunucuya gönderilmez.
- Tüm tercihler (favoriler, dil, tema, bildirim saati) yalnızca cihazda (Hive) saklanır.
- Üçüncü taraf analytics/reklam SDK'sı yok.

---

## 15. Test & Kalite

- **Birim:** `tip_repository`, `daily_tip_service` (seed determinizmi), `favorites_repository`.
- **Şema testi:** her tip kaydında `tr`/`en` alanlarının dolu olduğunu doğrula.
- **Widget testi:** TipCard ve kategori grid render.
- **Lint:** `flutter_lints` (veya `very_good_analysis`), CI'da `flutter analyze` + `flutter test`.
- **Manuel:** widget'ın iki platformda ana ekrana eklenmesi; TR↔EN canlı geçiş; light/dark.

---

## 16. README Şablonu

```markdown
# Vakti
Doğru bilgi, doğru vakitte. / The right thing, at the right time.

Ücretsiz, reklamsız, offline bilgi-kartı uygulaması (iOS + Android). İki içerik sütunu:
Sağlıklı Yaşam ve İletişim. Türkçe ve İngilizce. Ana ekran widget'ı.

## Stack
Flutter · Riverpod · go_router · Hive · home_widget · flutter_local_notifications

## Kurulum
flutter pub get
flutter gen-l10n
flutter run

## Yapı
Feature-first mimari (bkz. VAKTI_BLUEPRINT.md). Backend yok, veri toplanmaz.

## Lisans
...
```

---

## 17. Açık Sorular / Sonraki Adımlar

Bunlara karar verirsen ilgili agent'i güncellerim:
1. **İçerik hacmi:** lansmanda her kategoride kaç kart? (öneri: ≥8, toplam ~60–80)
2. **İletişim sütunu kapsamı:** sadece çocuk/ebeveyn mi, yoksa partner/iş gibi yetişkin iletişimi de eklensin mi?
3. **Streak (günlük seri):** v1.1'e mi bırakalım, MVP'ye mi alalım?
4. **Bundle id / paket adı:** örn. `com.rebuildrebreak.vakti` uygun mu?
5. **Font tercihi:** Fraunces mı, Newsreader mı? (ikisi de bedava/açık lisans)

---

*Bu blueprint Claude Code ile sırayla (Agent 1 → 9) çalıştırılmak üzere hazırlanmıştır. Her agent kendi dosya kümesine sahiptir ve kabul kriterleri geçmeden bir sonrakine geçilmez.*
