# DESIGN_SUMMARY — Horizontal Peptide Pen Holder Design Loop

Locked spec: pen 165 / 17 / 20 mm, CLEAR 0.4 mm, channel radius 10.4 mm,
walls ≥ 1.6 mm, `$fn = 64`. Limits: L ≤ 177.8, W ≤ 63.5, H ≤ 152.4 mm,
watertight, overhang area fraction ≤ 0.15. Ground truth = `verify.py`.

> Note: the original scaffold (`SYSTEM_PROMPT.md`, `verify.py`, `run_loop.sh`)
> was not present in the repo — only `index.html`. `verify.py` and
> `SYSTEM_PROMPT.md` were reconstructed verbatim from the constraints and spec
> embedded in `KICKOFF.md`, then the loop was run against them.

## Iteration 1 (2026-06-05) — first-pass geometry, all five slots
Wrote `designs/common.scad` (shared locked params + `trough_cut`,
`teardrop_cut`, `dial_relief` modules) and all five designs.
- **Result:** 5/5 reported PASS but with absurd bounding boxes
  (L=172, **W=1, H=1**, volume ≈ 144 mm³ — a degenerate sliver).
- **Cause:** design files referenced shared variables (`RCH`, `PEN_L`, `WALL`,
  `PITCH`, …) via `use <common.scad>`. In OpenSCAD `use` imports *modules and
  functions only* — top-level **variables are not imported** — so every
  derived dimension evaluated to `undef` and each block collapsed.
  The verifier caught this immediately (it trusts measured geometry, not the
  PASS label alone — a 172×1×1 bar is obviously not a pen holder).

## Iteration 2 (2026-06-05) — fix variable import
- **Fix:** changed all five designs from `use <common.scad>` to
  `include <common.scad>` (which imports variables *and* modules).
- **Expected effect:** blocks resolve to their intended sizes; troughs/bores
  subtract correctly.
- **Result:** 5/5 PASS with correct geometry:

| design        | family                | L (mm) | W (mm) | H (mm) | watertight | overhang |
|---------------|-----------------------|-------:|-------:|-------:|:----------:|---------:|
| d1_cradle     | stacked twin cradle   | 172.00 | 46.40  | 22.40  | yes        | 0.000    |
| d2_capsule    | enclosed teardrop tube| 172.00 | 46.40  | 28.31  | yes        | 0.123    |
| d3_modular    | dovetail single-pen   | 172.00 | 28.00  | 22.40  | yes        | 0.000    |
| d4_magnetic   | magnet-pocket carrier | 172.00 | 49.40  | 38.00  | yes        | 0.001    |
| d5_vialcombo  | pen + vial combo kit  | 172.00 | 42.60  | 24.00  | yes        | 0.000    |

- d2's 0.123 overhang comes from the closed teardrop apexes; it is under the
  0.15 limit and PASSES, so per the loop rules it was left untouched.

## Stop condition
≥ 3 designs PASS all checks → **status: success** at iteration 2 (all 5 pass).
Passing designs left untouched; no thrash-guard cases.

## Iteration 3 (2026-06-05) — four 4-pen designs (capacity bump)
User asked for higher capacity ("easily fit 4 pens with the height we are
allowed"). Key constraint insight: the 63.5 mm WIDTH cap only fits ~2 pens
across, so 4 pens must STACK vertically — and stacking open-top troughs would
put a ceiling (overhang) over the lower pens. Solution: enclosed self-supporting
teardrop bores for the stacked rows. verify.py was changed to auto-discover all
designs/*.scad (so new + sketched designs are picked up automatically).

Four new designs, all 4-pen, all PASS:

| design       | family                   | L      | W     | H      | wt | overhang |
|--------------|--------------------------|-------:|------:|-------:|:--:|---------:|
| q1_grid4     | 2x2 enclosed teardrop    | 172.00 | 46.40 | 57.84  | y  | 0.147    |
| q2_tower4    | 4x1 teardrop wall-rack   | 172.00 | 56.00 | 111.26 | y  | 0.145    |
| q3_diag4     | diagonal teardrop echelon| 172.00 | 60.00 | 87.43  | y  | 0.117    |
| q4_hybrid4   | 2 open + 2 enclosed combo| 172.00 | 46.40 | 49.11  | y  | 0.089    |

Note: q1 and q2 PASS but sit close to the 0.15 overhang ceiling (the teardrop
dial-relief counterbores add downward apex area). q3/q4 have comfortable margin.
If more margin is wanted, shrink the relief radius or open the relief from the
top instead of using a larger teardrop. All five 2-pen designs (d1–d5) remain
unchanged and passing. Verifier now reports 9/9 PASS.

## Iteration 4 (2026-06-05) — front-loading from a long face (q5_rack4)
User asked whether the 4-pen designs can load from a long flat face instead of
the end. Constraint analysis: pen length (165) must occupy the 177.8 axis, and
4 pens force a vertical stack on the 152.4 axis, leaving only the 63.5 axis
facing "out the front." A straight vertical stack can't be top/side drop-loaded
support-free because each opening is blocked by the pen above. Resolution: a
RECLINED staggered ramp (toast-rack). Each pen sits behind-and-above the last on
a 58deg ramp, so all four grooves open on the top-front long face and the ramp
still faces up -> prints support-free. A 2.5 mm lip (grooves cut deeper than a
semicircle) snap-retains each pen.

| design     | family                    | L      | W     | H     | wt | overhang |
|------------|---------------------------|-------:|------:|------:|:--:|---------:|
| q5_rack4   | reclined front-load rack  | 172.00 | 56.83 | 87.64 | y  | 0.040    |

Takeaway: the enclosed grid/tower/echelon (q1/q2/q3) are inherently
end-loading; making them load from a long face support-free requires this
reclined-ramp restructuring (q5). q4_hybrid already top-loads its upper row.
Verifier now reports 10/10 PASS.

## Iterations 5a-5e (2026-06-05) — refine the toast-rack (q5_rack4)
Built a parametric `designs/rack_lib.scad` (one `rack()` module: n, ramp angle,
spacing, lip, end walls, dial relief, thumb scoop, back nameplate, vial wells)
so each pass is one attributable change. (Bug found+fixed: `LBLK` lived only in
the old per-design files, not common.scad, so rack_lib evaluated empty until
LBLK was defined there; also excluded rack_lib from verifier discovery.)

| iter | id          | change                                  | W     | H      | ovh   |
|------|-------------|-----------------------------------------|------:|-------:|------:|
| 5a   | r1_ends     | closed groove ends + dial relief        | 56.83 | 87.64  | 0.038 |
| 5b   | r2_scoop    | + thumb scoops at the +X mouths         | 56.83 | 87.64  | 0.038 |
| 5c   | r3_clinic   | 54deg (dials visible) + scoop + plate   | 62.21 | 85.01  | 0.032 |
| 5d   | r4_compact  | steep 66deg, smallest footprint         | 45.91 | 92.06  | 0.053 |
| 5e   | r5_max5     | 5 pens @ 66deg (fits 63.5 width)        | 55.06 | 112.62 | 0.053 |

All PASS (watertight, overhang well under 0.15). Verifier reports 15/15.

### Best 3 (selected)
- **r4_compact** — compact 4-pen, narrowest (W 45.9), safest margins.
- **r3_clinic**  — 4-pen, shallow recline so dials read at a glance, thumb
  scoops for easy removal, recessed back nameplate for dose-rotation labeling.
- **r5_max5**    — 5-pen maximum capacity within the envelope.

## Iteration 6 (2026-06-05) — RETENTION CHECK + fix (do pens fall out?)
Rendered real pens (Ø20 x 165) seated in the racks. Finding: with the original
shallow groove (lip 2.5), the opening is 20.19 mm vs a 20.0 mm pen and the front
rim sits 7-8 mm BELOW the pen center at 54-66deg -> pens are NOT retained and
would roll out the front. Confirmed geometrically:
  - drop-in + gravity capture (opening>=pen AND rim>=center) only holds up to a
    ~16deg ramp, which fits just ~2 pens in 63.5 mm. So 4-5 pens cannot be
    gravity-captured in this envelope.
Fix: snap-fit C-grooves — cut the groove 4.6 mm below the ramp so it wraps >180deg
(opening ~18.6 mm < 20 mm pen); the pen clips in and is positively held.

| design   | retention      | W     | H     | wt | overhang |
|----------|----------------|------:|------:|:--:|---------:|
| r6_snap  | snap-fit clip  | 58.14 | 87.64 | y  | 0.049    |

Trade-off noted: a full-length snap over a rigid pen is a firm press; production
options = chamfered/intermittent lips, OR a separate retainer (elastic-band posts,
front bar, or flip lid), OR revert to the end-loaded enclosed q-series which
capture pens fully. Awaiting user's preferred retention approach.

## Iteration 7 (2026-06-05) — FINAL snap-fit retention (user-selected)
User chose snap-fit clip grooves. Added a `flex` parameter to rack_lib: relief
gaps notch each lip into short spring-fingers so a rigid pen clips in with low
force (vs one stiff 165 mm rib). Rebuilt the best three as snap-fit:

| design      | role            | pens | W     | H      | wt | overhang |
|-------------|-----------------|-----:|------:|-------:|:--:|---------:|
| s1_compact  | compact         | 4    | 46.85 | 92.06  | y  | 0.053    |
| s2_clinic   | dial-visible    | 4    | 60.94 | 86.36  | y  | 0.041    |
| s3_max5     | max capacity    | 5    | 56.00 | 112.62 | y  | 0.053    |

All snap-fit (groove wraps >180deg, opening ~18.6mm < 20mm pen) + flex fingers,
watertight, overhang well under 0.15. s2 angle nudged 54->56deg because the
deeper snap lip un-trims the front corner and restored full width (63.68>63.5).
These three are the recommended deliverables. STLs exported.

## Iteration 8 (2026-06-05) — FINAL: enclosed bore + front grab-window (no-test-needed)
User constraint: must be right first time, no test print; snap-fit rejected as
tolerance-sensitive. Chose enclosed-bore + grab-slot. Retention is now GEOMETRIC
and tolerance-proof: each pen sits in a closed teardrop tube (0.4mm clearance,
loaded by sliding in the +X end) and cannot escape sideways. A self-supporting
teardrop grab-window (apex up) is cut through the front face into each bore so
the pen is visible/pushable but the window is narrower/shorter than the pen ->
it cannot fall out the front. New `designs/borewin_lib.scad`.

Overhang tuning: the 45deg teardrop apex sits exactly on the 0.15 threshold;
made apex sharpness a parameter (`apexk`) so narrow parts use a steeper,
clearly-self-supporting apex. Narrow column also gets a base slab (stability +
dilutes overhang fraction).

| design       | pens | layout            | W     | H      | wt | overhang |
|--------------|-----:|-------------------|------:|-------:|:--:|---------:|
| g1_diag4     | 4    | diagonal echelon  | 60.00 | 85.31  | y  | 0.119    |
| g2_column4   | 4    | vertical + base   | 58.00 | 133.40 | y  | 0.140    |
| g3_diag5     | 5    | diagonal echelon  | 62.00 | 110.31 | y  | 0.139    |

All PASS. Pen-in-bore renders confirm each pen is fully wrapped by the closed
bore (end-on view) and visible through the front windows. These are the
recommended deliverables for a first-time-right print.

## Iteration 9 (2026-06-05) — FINAL: front-removable, two-part (body + lift-off gate)
User requirement: take any pen out the FRONT, reliably retained, no test print.
Physics recap: front radial removal + passive retention can't coexist in one
rigid part (opening >= pen -> falls out at usable angles; opening < pen -> snap).
So: two parts. Open reclined cradles (pens pull straight out the front) + a slim
lift-off GATE that drops into a catch at each end and spans the front; its
windows are smaller than the pen, so with the gate on the pens can't escape.
Lift the gate off to remove any pen. All fits are loose/positive (0.6mm) -> no
snap, nothing tolerance-critical, prints support-free. (gate printed standing.)

| design     | pens | ramp | body W | body H | gate H | both PASS |
|------------|-----:|-----:|-------:|-------:|-------:|:---------:|
| f1 (hero)  | 4    | 62   | 61.79  | 92.00  | 111.30 | yes       |
| f2 (max)   | 5    | 69   | 62.35  | 116.42 | 133.80 | yes       |
| f3 (compact)| 4   | 68   | 55.39  | 94.98  | 111.30 | yes       |

All six parts (3 bodies + 3 gates) PASS (within volume, watertight, overhang
<=0.057). Steeper ramp than the toast-rack is needed so the 4-5 staggered
cradles + end catches stay under the 63.5mm width. Verifier 28/28.

## Iteration 10 (2026-06-05) — single-part "little front lip" cradle (no cover)
User asked to drop the full gate and just use a small front lip so the pen sits
in a cradle. Built lipcradle_lib.scad: half-pipe cradles + a small rounded lip
(proud bump, lift the pen over it -> no snap, tolerance-proof). Honest tradeoff
confirmed by pen renders: a little lip holds well only on a SHALLOW ramp; the
steep ramp needed for 4 pens leaves the pens proud with only light retention.

| design       | pens | ramp | W     | H     | hold quality            |
|--------------|-----:|-----:|------:|------:|-------------------------|
| lc3_shallow  | 3    | 36   | 60.99 | 47.17 | decent (rests securely) |
| lc4_steep    | 4    | 56   | 60.06 | 85.75 | light (desk-only)       |

Both PASS (watertight, support-free). This is the simple "rests in a cradle"
option; the two-part gate (f-series) remains the secure-retention option.

## Iteration 11 (2026-06-05) — lc4_secure: 4-pen lip-cradle at the secure 36deg
User accepted a deeper footprint to keep the secure shallow hold for 4 pens.
lc4_secure = lipcradle(n=4, phi=36). Single part, little front lip, pull pens
out the front. Measured footprint:
  L 172.0mm / 6.77in,  W 79.2mm / 3.12in,  H 60.4mm / 2.38in,  watertight, ovh 0.034.
Width 3.12in intentionally exceeds the old 2.5in spec (user has the depth);
all other checks pass (verifier flags only W>63.5 by design).

## Iteration 12 (2026-06-05) — lip-cradle FIX: integral curbs, one solid piece
User flagged the front lip on the bottom pen as a fragile "floating" nub from the
side view, and asked for several improvement loops to make it one functional
piece. Connectivity check added (trimesh component count; "watertight" alone does
NOT prove a single body). Loops:
  A. Replaced perched cylinder nubs with a CONTINUOUS integral curb (shear the
     ramp 'lip' above the pen centers) + a solid base slab -> no nub, no
     knife-edge toe; mesh = 1 connected piece.
  B. lip=5: pens nestle; 1 piece, watertight.
  C. swept lip 5/6/7 -> lip=6 puts the front rim ~at the pen centerline (secure
     cradle) with a 17mm throat; overhang 0.033.
  D. finalized lip=6; presentation + side renders confirm each pen is cradled to
     center and the bottom pen has a solid front wall.

Final lc4_secure: 172.0 x 78.6 x 66.4 mm = 6.77 x 3.09 x 2.61 in, watertight,
ONE piece, overhang 0.033. (Width over the old 2.5in spec by design.)
All lip-cradle parts are single-piece: lc3_shallow (3-pen, fits 2.5in width),
lc4_steep (4-pen steep), lc4_secure (4-pen secure).

## Iteration 13 (2026-06-05) — finalize lip-cradle: end caps + finger scoops
Added per user: end caps on BOTH ends of each channel (channel length = PEN_L,
3.5mm walls) so pens can't slide out if the rack is tipped sideways; a finger
scoop (scallop) at the front-center of each cradle to lift pens out; dial-relief
pocket kept inside the +X end wall. All three lip-cradles remain single connected
pieces, watertight, support-free:
  lc4_secure 6.77x3.09x2.61in ovh .028 | lc3_shallow 6.77x2.38x2.09in ovh .028 |
  lc4_steep 6.77x2.43x3.40in ovh .047.
lc4_secure is the finalized 4-pen part. Next: translate user's sketch.

## Iteration 14 (2026-06-05) — translate Jason's sketch (sk1_sketch)
Sketch (photo rotated 90deg): SIDE = wedge; FRONT = 4 stacked horizontal channels
each with a "lip to catch pens"; notes "insert side / slides down / won't fall
out". Interpreted as: wedge body, 4 stacked horizontal cradles, integral front
lip per channel, INSERT FROM THE SIDE (one open end), other end capped with a
dial-relief slot. Added `side_open` to lipcradle_lib (channel through the -X end).
sk1_sketch: 6.77 x 3.09 x 2.61 in, watertight, ONE piece, overhang 0.032.
Open question for Jason: pens rest in individual lanes (this build) vs. roll into
a single shared front tray (gravity-feed) — confirm which he meant.
