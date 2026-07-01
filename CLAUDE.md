# CLAUDE.md — Vakti

Working notes for Claude Code. Read this first when picking the project back up.

## What Vakti is

Free, ad-free, **offline-first** Flutter app (iOS + Android), bilingual **TR + EN**.
Premium "tip cards" that answer *when* and *why*. Two content pillars:

- **wellness** (Sağlıklı Yaşam) — digestion, immunity, sleep, energy, skin, hydration
- **communication** (İletişim) — boundaries, emotions, cooperation, confidence, earlyYears (child/parent)

No backend, no login, no analytics, no ads. All content ships in
`assets/data/tips.json`. Full spec: `VAKTI_BLUEPRINT.md`.

- Android applicationId: **com.studiorosemary.vakti** (Play package; `com.vakti.app`
  was taken by another dev) · Android namespace: `com.vakti.vakti` · iOS bundle id:
  **com.vakti.app** · App Group: `group.com.vakti.app` · Dart pkg: `vakti`
- Stack: Flutter 3.44.1 / Dart 3.12.1 · Riverpod 3 · go_router · Hive · home_widget ·
  workmanager · flutter_local_notifications · share_plus · screenshot
- Fonts bundled (Fraunces display + Inter body), no runtime google_fonts.
- Design: editorial "golden hour" — ink dark bg, warm paper light bg, single saffron
  accent, signature "time arc" (zaman yayı) motif. Cards r20, buttons r14, no shadows.

## Status: MVP COMPLETE

All 9 blueprint agents / 6 phases built. **`dart analyze` clean, 16/16 tests pass.**
Verified live on iPhone 17 simulator (iOS 26.5).

| Phase | Agents | What | State |
|---|---|---|---|
| 1 | 1-3 | scaffold, theme tokens, l10n (ARB+gen-l10n), data layer, 88-card tips.json | ✅ |
| 2 | 4-5 | go_router bottom-nav shell, feed (PageView + pillar filter), browse grid | ✅ |
| 3 | 6 | detail screen, Hive favorites + heart, 4:5 PNG share | ✅ |
| 4 | 7 | home_widget; Android widget FULLY wired; iOS source + doc | ✅* |
| 5 | 8 | daily reminder (opt-in), deterministic daily tip, tap routing | ✅ |
| 6 | 9 | 3-screen onboarding, full settings, legal disclaimer | ✅ |

\* iOS widget needs one manual Xcode step — see "Open items".

## Layout (feature-first)

```
lib/
  app/        app.dart, router.dart, theme/*, controllers/ (locale, theme)
  data/       models/ (tip, category, localized_text, content_pillar)
              sources/ (asset_tip_source, local_store=Hive)
              repositories/ (tip_repository, favorites_repository)
  features/   onboarding, feed, browse, detail, favorites, settings
  services/   daily_tip_service, notification_service, widget_service, share_service, reminder_copy
  widgets/    tip_card, time_arc, category_tile, pill_badge, tip_actions, share_card, empty_state
  l10n/       app_en.arb, app_tr.arb (+ generated app_localizations*)
assets/       data/tips.json · fonts/ (Fraunces, Inter) · icon/
android/ ios/ docs/ (ios_widget_setup, store_listing) · PRIVACY.md · README.md
```

## Commands

```bash
flutter pub get
flutter gen-l10n
dart run flutter_launcher_icons
flutter test
flutter run -d <device>
# show feed without onboarding (QA): --dart-define=SKIP_ONBOARDING=true
```

## ⚠️ Gotchas (read before working)

1. **`flutter analyze` CRASHES here** — repo path has Turkish `İ`
   (`/Volumes/ProjectVault/VAKTİ`), which corrupts the analysis-server LSP rootUri
   (`FormatException at character 288`). **Use `dart analyze lib test` instead.**
   `flutter test` is unaffected.
2. **Riverpod 3** — blueprint shows v2 `StateNotifierProvider`; we use modern
   `Notifier`/`NotifierProvider`. `AsyncValue` has no `valueOrNull` → use `.asData?.value`.
   Controllers set `state` BEFORE awaiting Hive persistence (optimistic) — otherwise
   real disk I/O stalls under the test fake-async clock.
3. **Widget tests** use `LocalStore.instance.initInMemory()` (no Hive). Real Hive writes
   scheduled under fake-async never settle and deadlock teardown. setUp also resets the
   **global** `appRouter` (`appRouter.go('/feed')`) and sets `onboardingDone=true`.
4. **flutter_local_notifications v22** = named params: `initialize(settings:)`,
   `zonedSchedule(id:/scheduledDate:/notificationDetails:)`, `cancel(id:)`.
   `flutter_timezone` v5 returns `TimezoneInfo` → use `.identifier`.
5. **iOS deployment target = 14.0** (Podfile + pbxproj + post_install) — workmanager_apple
   needs ≥14. **Android** needs core-library desugaring + `desugar_jdk_libs:2.1.4`
   (local_notifications v22).
6. Communication tip titles are **quoted sentences** in JSON (rendered text includes
   literal `"`) — use substring finders in tests.

## Open items / what's next

**Required before store submission**
- [ ] **iOS widget Xcode step** — add Widget Extension target `VaktiWidget`, wire App Group
      `group.com.vakti.app` on Runner + widget, point at `ios/VaktiWidget/*`.
      See `docs/ios_widget_setup.md`. (Hand-editing pbxproj was skipped to keep the iOS
      build launchable.)
- [ ] Host `PRIVACY.md` at a public URL (both stores require it).
- [ ] Real signing config (Android release keystore; iOS team/provisioning).
- [ ] Store screenshots (TR + EN) per `docs/store_listing.md` checklist.
- [ ] Verify widget on real Android device + iOS after the Xcode step.

**Nice to have / deferred**
- [x] Streak (günlük seri) — shipped in v1.1 (`streak_service`, feed 🔥 chip, settings banner).
- [x] in_app_review for the "Rate" action — shipped (`review_service`).
- [ ] Expand content beyond 88 cards if desired.
- [ ] Adult/partner communication content (currently child/parent only).
- [ ] Remove `SKIP_ONBOARDING` QA flag before release if undesired (defaults false).

**Not yet done**
- [ ] CI (flutter analyze via `dart analyze` + flutter test).

## Current design & features (snapshot — v1.1.1+3)

State as shipped to closed test on Play. Reference when picking work back up.

### Design language
- **Identity:** editorial "golden hour". Dark ink ground (`#14181F`) / warm paper
  light (`#F7F3EC`), single saffron accent (`#E0A24B`, deep `#C07F2E`). No generic
  gradients, **no shadows**. Cards r20, inner hero r16, buttons r14, pills r999.
- **Signature motif:** the **time arc** (zaman yayı) — `widgets/time_arc.dart`.
  Animates; `arcPositionForTip()` currently maps per-tip, **not** the real clock.
- **Type:** Fraunces (display) + Inter (body), bundled — no runtime google_fonts.
  Scale in `app/theme/app_typography.dart` (`titleXL/titleL`, `bodyL/M`, `labelCaps`).
- **Category tints:** 11 category colors, blended at ~6% over surface for card grounds.

### Screens / features
- **Feed** (`features/feed`): vertical full-screen `PageView` of tip cards; pillar
  filter chips (All / Wellness / Communication); 🔥 streak chip appears at 2+ days;
  haptic on page change; floating `TipActions` (favorite / share) per card.
- **Tip card** (`widgets/tip_card.dart`): per-tip watercolor hero
  `assets/images/cards/<id>.webp` (all 88 present), pill badge + emoji, title,
  WHEN/WHY lines. Falls back to time-arc + emoji if art missing.
- **Detail** (`features/detail`): encyclopedic. Pinned SliverAppBar hero, badge,
  title, WHEN/WHY, then rich sections — origin, how to use, fun fact, countries.
- **Browse** (`features/browse`): category grid + text search (`search_provider`),
  per-category detail screen.
- **Favorites** (`features/favorites`): Hive-backed heart, dedicated tab.
- **Settings** (`features/settings`): language (TR/EN/system), theme
  (light/dark/system), daily reminder on/off + time picker, interests selector,
  streak banner (current/best), share app, rate (in_app_review), legal/about.
- **Onboarding** (`features/onboarding`): 3 screens, legal disclaimer.
- **Services:** deterministic daily tip (`daily_tip_service`), local notifications
  (`notification_service`), Android home widget (`widget_service`, iOS pending Xcode
  step), 4:5 PNG share (`share_service`), streak (`streak_service`), review.
- **Content:** 88 cards in `assets/data/tips.json`, fully bilingual TR/EN, two
  pillars (wellness, communication). Communication titles are quoted sentences.

### Ideas backlog
Visual/design:
- [x] Feed depth-stack transition on the vertical PageView (`depthTransform`).
- [ ] Wire time-arc to the real time of day — **deliberately not done**: the arc
      encodes the *tip's* moment by design; user opted to keep that semantic.
- [x] Detail hero parallax (`heroParallax`, lag + pull-down zoom; editorial
      title-below kept, no scrim per decision).
- [x] Deeper category-color in detail — tint accent bar on section headers.
- [x] Custom empty-state illustration — time-arc motif framing the emoji.
- [x] Onboarding micro-animation — time-arc draw-in entrance.

Feature:
- [x] **Streak calendar + milestones** (`features/streak/`, 90-day grid + 3/7/30/100
      badges + one-time celebration).
- [x] **"Today's card" hero** — daily tip pinned first with a "Today's Card" badge
      (`pinFirst`).
- [x] Richer haptics on favorite toggle + streak milestone.
- [x] **User collections/lists** — named Hive collections on the Favorites tab
      (Favorites|Collections segment), collection detail screen, add-to-collection
      sheet from the detail app bar (`features/collections/`).
- [ ] Multiple reminder times + quiet hours. *(not started — product/UX decisions on
      defaults)*
- [ ] Search history / popular tags.
- [ ] "Seen" flag to dim viewed tips — **low value** for a single-card PageView feed;
      parked.
- [ ] Finish **iOS widget** (Xcode target — see Open items). *Manual Xcode step; can't
      be done/verified headlessly here.*
- [ ] Story (9:16) + square (1:1) share formats — **needs visual verification** of the
      rendered PNG layouts; deferred to a session where output can be eyeballed.
- [ ] Content: adult/partner communication; grow beyond 88 cards. *(content authoring)*

Done this round (uncommitted-to-remote unless pushed): streak calendar, today's card,
feed depth transition, detail hero parallax, section accent bars, time-arc empty
state, onboarding arc draw-in, richer haptics.

## Memory

Persistent notes live in
`~/.claude/projects/-Volumes-ProjectVault-VAKT-/memory/vakti-project.md`.
