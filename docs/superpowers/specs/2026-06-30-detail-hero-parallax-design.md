# Detail Hero Parallax — Design

**Date:** 2026-06-30
**Status:** Approved
**Feature:** A subtle parallax on the detail-screen hero image — it scrolls slower
than the page and zooms slightly on pull-down — while the editorial layout (title
below the image) is preserved.

## Goal

Add depth and life to the detail screen without changing its editorial identity. Today
the hero is a static rounded image with the badge/title/summary in a column below it.

## Non-goals (YAGNI)

- No gradient scrim (the title stays below the image, not over it).
- No SliverAppBar restructure (the pinned bar stays as-is).
- No change to the time-arc, the fallback, or the detail sections.

## Mechanics (`lib/features/detail/detail_screen.dart`)

`_DetailBody` becomes a `StatefulWidget` owning a `ScrollController` passed to the
`CustomScrollView`. The hero image block is extracted into a `_ParallaxHero` widget
that rebuilds from the controller via `AnimatedBuilder`. The badge, title, WHEN/WHY
summary, and detail sections are unchanged and stay below the hero.

## Pure helper

```dart
({double dy, double scale}) heroParallax(double scrollOffset, double maxShift)
```

- `scrollOffset >= 0` (content scrolling up): `dy = (scrollOffset * 0.3).clamp(0, maxShift)`,
  `scale = 1.0` — the image lags behind the frame (parallax).
- `scrollOffset < 0` (overscroll / pull-down): `dy = 0`,
  `scale = (1.0 - scrollOffset * 0.0015).clamp(1.0, 1.12)` — a gentle zoom-in.

Pure and unit-testable.

## Hero render

`LayoutBuilder` gives the available width; height = `width / 1.4` (current aspect).
`ClipRRect(r20)` wraps an `OverflowBox` (`maxHeight = H + maxShift`, `maxShift = 48`,
`alignment: Alignment.bottomCenter`) containing `Transform.translate(Offset(0, dy))`
→ `Transform.scale(scale)` → an over-height `Image.asset` (`BoxFit.cover`). The
existing `_HeroFallback` stays as the image `errorBuilder`. Bottom alignment + the
extra height mean no gap is ever revealed as `dy` moves through `[0, maxShift]`.

## Accessibility

When `MediaQuery.of(context).disableAnimations` is true, render the current static
hero (plain `ClipRRect` + `AspectRatio(1.4)` + `Image.asset`) with no parallax.

## Error handling

`controller.offset` is read only when `controller.hasClients`; otherwise treat the
offset as `0.0` (identity) for the first frame.

## Testing (`test/`)

- `heroParallax` pure tests: `offset 0` → `(0, 1.0)`; large positive offset → `dy`
  clamps to `maxShift`, `scale == 1.0`; negative offset (overscroll) → `dy == 0`,
  `scale > 1.0` and clamped at `1.12`.
- Light widget test: the detail screen renders the hero image and the title, and a
  scroll settles without throwing.

## Files touched

- `lib/features/detail/detail_screen.dart` — stateful `_DetailBody`, `_ParallaxHero`,
  `heroParallax` helper.
- `test/detail_hero_test.dart` — new (`heroParallax` + render/scroll smoke).
