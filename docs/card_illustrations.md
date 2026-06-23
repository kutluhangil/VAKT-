# Card Illustrations — Gemini prompt sheet

Per-card watercolor + line-art illustration for every tip. Drop each PNG at
`assets/images/cards/<tip.id>.png`. `TipCard` shows it as the hero; missing
files fall back to the time-arc, so the set rolls out incrementally.

- Export square (~2048 is fine, the app downscales to **1024**).
- No text / no letters / no pill / no border baked into the image.
- File name = exactly `<tip.id>.png` (single dot).

## STYLE A — objects (wellness cards)

Paste this, then a `Subject:` line.

> Soft editorial watercolor illustration with fine sepia/brown ink line-art on
> top. Muted golden-hour palette: sage green, warm peach, cream, soft saffron.
> Loose watercolor wash background with soft bleeding edges. Centered
> composition, a few botanical leaves framing the subject, calm and premium,
> hand-drawn storybook feel. No text, no letters, no border. Square composition,
> cream background.

## STYLE B — warm scenes (communication cards)

Same look, but tender parent/child storybook scenes. Keep figures **soft and
simple, seen from behind or as gentle silhouettes — no detailed faces.**

> Soft editorial watercolor illustration with fine sepia/brown ink line-art on
> top. Muted golden-hour palette: sage green, warm peach, cream, soft saffron.
> Loose watercolor wash background with soft bleeding edges. Warm tender
> storybook scene; any people are soft and simple, shown from behind or as
> gentle silhouettes, no detailed facial features. Centered composition, a few
> botanical leaves framing the scene, calm and premium. No text, no letters,
> no border. Square composition, cream background.

---

## Done (batches 1–4): w_ginger_tea, w_kefir, w_walk_after_meal, w_fennel_tea,
w_yogurt, w_chew_slowly, w_warm_water_meal, w_mint, w_lemon_water, w_garlic,
w_honey, w_orange, w_soup, w_rest_when_tired, w_ventilate, w_handwash,
w_chamomile, w_screen_off, w_dim_lights, w_cool_room, w_no_late_coffee,
w_consistent_bedtime, w_journal, w_breathe, w_sunlight, w_stretch,
w_breakfast_protein, w_short_break, w_walk_outside, w_water_when_tired, w_music,
w_open_window, w_water_for_skin, w_sunscreen, w_gentle_cleanse.

---

## Remaining — STYLE A (objects), `filename → Subject:`

- `w_moisturize` → a jar of moisturizing cream with a soft dollop and a couple of leaves, fresh skincare
- `w_sleep_for_skin` → a soft pillow and folded blanket with a gentle crescent moon and a sprig, restful glow
- `w_lukewarm_shower` → a shower head with gentle warm water streaming and soft steam, calm
- `w_veggies` → a colorful assortment of fresh vegetables — tomato, carrot, leafy greens, bell pepper — arranged together, vibrant and healthy
- `w_hands_off_face` → a calm open palm with a small soft sparkle and a couple of leaves, gentle mindful awareness
- `w_water_morning` → a clear glass of water on a windowsill catching soft morning light, fresh start
- `w_water_bottle` → a reusable water bottle with a few water droplets and a couple of leaves, on the go
- `w_water_before_meal` → a glass of water beside a simple place setting (plate and fork) before a meal, calm
- `w_herbal_tea` → a cup of herbal tea with dried herbs and small flowers beside it, gentle steam, cozy
- `w_fruit_water` → juicy sliced fruits — watermelon, orange, berries — fresh and dewy, refreshing
- `w_water_after_activity` → a water bottle beside a folded towel and a pair of sneakers, post-exercise refresh
- `w_warm_in_winter` → a warm mug of water with rising steam beside a cozy knit and a sprig, winter warmth
- `w_notice_thirst` → a clear glass of water with soft sparkles and a couple of leaves, mindful hydration

## Remaining — STYLE B (warm scenes), `filename → Subject:`

### boundaries
- `c_help_not_for_you` → a large gentle adult hand guiding a small child's hand building wooden blocks, supportive
- `c_stop_to_keep_safe` → a protective adult hand gently held out with a small child safe behind, warm and reassuring
- `c_my_job` → warm sheltering arms or a big umbrella around a small child seen from behind, protective
- `c_listening_no_change` → an adult and a child sitting calmly together seen from behind, steady and warm
- `c_no_is_complete` → a single closed wooden garden gate in soft sunny light, a gentle boundary metaphor
- `c_choice_within_limit` → a small child's hand choosing between two little baskets on a table, gentle freedom
- `c_calm_repeat` → a cozy steady home corner with a warm wall clock and a parent and child softly together, calm
- `c_after_you_finish` → a small basket of toys to tidy with a sunny doorway beyond, a clear "first this, then that" order

### emotions
- `c_feelings_ok` → a small child hugging a soft teddy bear, gentle disappointment being soothed, warm
- `c_name_emotion` → a small child with a soft thoughtful posture and a little floating heart-cloud, gentle
- `c_im_here` → an adult sitting close beside a child with a comforting hand on the shoulder, seen softly from behind
- `c_all_feelings_ok` → a warm glowing heart with gentle swirling watercolor colors, accepting all feelings
- `c_take_a_moment` → a cozy calm corner with a cushion and a warm cup, a quiet pause to settle
- `c_tell_me_more` → an adult and child sitting together with two cups between them, soft open conversation, from the side
- `c_it_was_hard` → a tender evening scene of a parent and child resting together on a couch, soft and warm
- `c_proud_of_calm` → a small child taking a calming breath with soft swirling air, gentle quiet pride

### cooperation
- `c_try_together` → adult and child hands working together on a wooden puzzle, teamwork
- `c_what_first` → a simple little checklist or two task tokens with a child's hand pointing, choosing what comes first
- `c_tidy_race` → toys being cheerfully tossed into a basket, playful lighthearted tidying
- `c_when_then` → a tidy cozy room with a sunny park visible through the window, a reward-after metaphor
- `c_your_help` → a small child helping carry a little basket alongside an adult, seen from behind, helpful
- `c_two_minutes` → a small sand hourglass on a table beside a few toys, a gentle transition heads-up
- `c_show_me` → a child's hands proudly tying a shoelace while an adult watches warmly, capable
- `c_thank_you_specific` → a neatly set table with plates and cutlery and a child's hand placing a fork, appreciation

### confidence
- `c_you_can_handle` → a small child reaching up to climb a low step with a gentle adult hand nearby, encouraging
- `c_you_worked_hard` → a finished child's drawing on a table with scattered crayons, effort shown, warm
- `c_mistakes_ok` → a tipped-over cup of crayons spilling gently, a small mistake in a warm forgiving mood, learning
- `c_how_did_you` → a child curiously examining a finished little block tower, quiet discovery
- `c_try_first` → a child attempting a small task while an adult stands back supportively, seen from behind
- `c_remember_when` → a tiny sprout growing into a small leafy plant, a past-to-now resilience metaphor
- `c_your_idea` → a child's bright drawing with a small glowing idea-sparkle above it, a valued idea
- `c_almost` → a child stacking blocks that almost reach the top, an encouraging "try once more" mood

### earlyYears
- `c_name_the_feeling` → a small toddler with a soft little storm cloud above gently softening into calm
- `c_simple_order` → a small plate of food beside a toy in a clear simple sequence, bright and friendly
- `c_narrate` → a pair of tiny shoes being put onto small feet, an everyday routine, warm
- `c_i_see_you_trying` → a toddler stacking colorful rings on a peg toy, focused effort, encouraging
- `c_almost_bedtime` → a cozy bedtime scene with an open picture book and a soft warm lamp, one last story
- `c_gentle_hands` → two small gentle hands softly cupping a little bird or flower, gentleness
- `c_you_are_safe` → a toddler wrapped in a warm blanket beside a soft glowing nightlight, safe and calm
- `c_bye_routine` → a small heart and a softly waving little hand at a sunny doorway, a gentle goodbye
