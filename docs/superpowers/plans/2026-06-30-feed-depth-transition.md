# Feed Depth Transition Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a depth-stacking transition to the vertical feed PageView — outgoing cards recede (scale + fade + lag) while the incoming card stacks over them.

**Architecture:** A pure `depthTransform(delta)` helper returns scale/opacity/lag for a card at page-delta `delta`. `FeedScreen` becomes a `ConsumerStatefulWidget` owning a `PageController`; each page is wrapped in an `AnimatedBuilder` that applies the transform. Reduced-motion users get the plain card.

**Tech Stack:** Flutter 3.44 / Dart 3.12, Riverpod 3, go_router.

## Global Constraints

- Offline-first; no backend, no analytics. No new dependencies.
- **Do NOT run `flutter analyze`** (crashes on Turkish `İ` path). Use
  `dart analyze lib test`. `flutter test` is fine.
- Widget tests use `LocalStore.instance.initInMemory()`; `setUp` resets the global
  `appRouter` (`appRouter.go('/feed')`) and sets `onboardingDone = true`.
- `dailyTipProvider` is date-dependent → widget tests that pump the app override it
  (`dailyTipProvider.overrideWithValue(...)`).
- No shadows (brand). Depth = scale + opacity + lag only. Do NOT touch the time-arc,
  `TipCard`, or the pillar-filter row.
- Transform constants are fixed: scale `1.0 → 0.92` (`+0.08*t`), opacity
  `(1.0 + 1.4*t).clamp(0,1)`, lag `-t`, lag translate factor `0.65`.

---

### Task 1: `depthTransform` helper + feed PageView transition

Build the pure helper, convert `FeedScreen` to own a `PageController`, and apply the
per-page transform. Honor reduced-motion.

**Files:**
- Modify: `lib/features/feed/feed_screen.dart`
- Test: `test/feed_depth_test.dart` (create)

**Interfaces:**
- Consumes: `feedTipsProvider`, `tipRepositoryProvider`, `pillarFilterProvider`,
  `TipCard`, `TipActions`, `_TodayBadge` (already in this file), `AppLocalizations`.
- Produces: top-level `({double scale, double opacity, double lag}) depthTransform(double delta)`.

- [ ] **Step 1: Write failing pure tests for `depthTransform`**

Create `test/feed_depth_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vakti/features/feed/feed_screen.dart';

void main() {
  group('depthTransform', () {
    test('centered card is identity', () {
      final r = depthTransform(0);
      expect(r.scale, 1.0);
      expect(r.opacity, 1.0);
      expect(r.lag, 0.0);
    });

    test('incoming card below is identity', () {
      final r = depthTransform(1);
      expect(r.scale, 1.0);
      expect(r.opacity, 1.0);
      expect(r.lag, 0.0);
    });

    test('fully outgoing card recedes, fades out, and lags', () {
      final r = depthTransform(-1);
      expect(r.scale, closeTo(0.92, 1e-9));
      expect(r.opacity, 0.0);
      expect(r.lag, 1.0);
    });

    test('half-outgoing card is partway', () {
      final r = depthTransform(-0.5);
      expect(r.scale, closeTo(0.96, 1e-9));
      expect(r.opacity, closeTo(0.3, 1e-9));
      expect(r.lag, closeTo(0.5, 1e-9));
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

Run: `flutter test test/feed_depth_test.dart`
Expected: FAIL — `depthTransform` not defined.

- [ ] **Step 3: Implement `depthTransform`**

In `lib/features/feed/feed_screen.dart`, add at the bottom of the file (top-level):

```dart
/// Per-card transform for the feed's depth-stack transition, given the card's
/// page-delta (`delta = itemIndex - page`). Outgoing cards (delta < 0) recede,
/// fade, and lag so the incoming card stacks over them; others are identity.
({double scale, double opacity, double lag}) depthTransform(double delta) {
  if (delta >= 0) return (scale: 1.0, opacity: 1.0, lag: 0.0);
  final t = delta.clamp(-1.0, 0.0);
  return (
    scale: 1.0 + 0.08 * t,
    opacity: (1.0 + 1.4 * t).clamp(0.0, 1.0),
    lag: -t,
  );
}
```

- [ ] **Step 4: Run pure tests to verify they pass**

Run: `flutter test test/feed_depth_test.dart`
Expected: PASS (all four `depthTransform` tests).

- [ ] **Step 5: Convert `FeedScreen` to a stateful widget owning a `PageController`**

In `lib/features/feed/feed_screen.dart`, replace the `FeedScreen` class (the
`ConsumerWidget` from `class FeedScreen` through its closing `}`) with a
`ConsumerStatefulWidget` that owns a `PageController` and applies the transform.
Keep `_PillarFilter`, `_StreakChip`, `_Chip`, and `_TodayBadge` unchanged.

```dart
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final repoAsync = ref.watch(tipRepositoryProvider);
    final pillar = ref.watch(pillarFilterProvider);
    final tips = ref.watch(feedTipsProvider);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return SafeArea(
      child: Column(
        children: [
          _PillarFilter(selected: pillar, l: l),
          Expanded(
            child: repoAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (_) => PageView.builder(
                key: ValueKey(pillar),
                controller: _controller,
                scrollDirection: Axis.vertical,
                onPageChanged: (_) => HapticFeedback.selectionClick(),
                itemCount: tips.length,
                itemBuilder: (context, i) {
                  final tip = tips[i];
                  final card = Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: TipCard(
                            tip: tip,
                            onTap: () => context.push('/tip/${tip.id}'),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 28,
                          child: TipActions(tip: tip),
                        ),
                        if (i == 0)
                          Positioned(
                            left: 12,
                            top: 20,
                            child: _TodayBadge(label: l.feedTodayBadge),
                          ),
                      ],
                    ),
                  );

                  if (reduceMotion) return card;

                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final page = _controller.hasClients &&
                              _controller.position.hasContentDimensions
                          ? (_controller.page ?? i.toDouble())
                          : i.toDouble();
                      final delta = i - page;
                      final tr = depthTransform(delta);
                      final h = context.size?.height ?? 0;
                      return Transform.translate(
                        offset: Offset(0, tr.lag * h * 0.65),
                        child: Transform.scale(
                          scale: tr.scale,
                          child: Opacity(opacity: tr.opacity, child: child),
                        ),
                      );
                    },
                    child: card,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Add a widget smoke test for the swipe**

Append to `test/feed_depth_test.dart` — add these imports at the top (with the
existing ones):

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vakti/app/app.dart';
import 'package:vakti/app/router.dart';
import 'package:vakti/data/models/tip.dart';
import 'package:vakti/data/repositories/tip_repository.dart';
import 'package:vakti/data/sources/local_store.dart';
import 'package:vakti/services/daily_tip_service.dart';
```

And add this group inside `main()` (after the `depthTransform` group):

```dart
  group('feed swipe', () {
    late TipRepository repo;

    setUpAll(() {
      final raw = File('assets/data/tips.json').readAsStringSync();
      final list = json.decode(raw) as List<dynamic>;
      repo = TipRepository(
        list.map((e) => Tip.fromJson(e as Map<String, dynamic>)).toList(),
      );
    });

    setUp(() {
      LocalStore.instance.initInMemory();
      LocalStore.instance.set(LocalStore.kOnboardingDone, true);
      appRouter.go('/feed');
    });

    tearDown(() => LocalStore.instance.resetInMemory());

    testWidgets('renders first card and survives a vertical swipe',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tipRepositoryProvider.overrideWith((ref) => repo),
            dailyTipProvider.overrideWithValue(null),
          ],
          child: const VaktiApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ginger Tea'), findsOneWidget); // first card

      // Swipe up to the next card; should settle without throwing.
      await tester.fling(find.text('Ginger Tea'), const Offset(0, -600), 1000);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
```

- [ ] **Step 7: Run the widget test**

Run: `flutter test test/feed_depth_test.dart`
Expected: PASS (depthTransform group + feed-swipe group).

- [ ] **Step 8: Run the full suite + analyze**

Run: `flutter test && dart analyze lib test`
Expected: all PASS; analyze clean.

- [ ] **Step 9: Commit**

```bash
git add lib/features/feed/feed_screen.dart test/feed_depth_test.dart
git commit -m "feat(feed): depth-stacking transition on the vertical feed"
```

---

## Notes for the implementer

- After the task: `flutter test` (existing + new green) and `dart analyze lib test`
  (clean). Optionally `flutter run -d <device>` and swipe the feed — outgoing cards
  recede and the next card stacks over them; no shadows.
- Reduced-motion (`MediaQuery.disableAnimations`) renders the plain card — verify the
  swipe test still passes (it does not enable reduced motion, so the transform path is
  exercised).
- No new dependencies.
