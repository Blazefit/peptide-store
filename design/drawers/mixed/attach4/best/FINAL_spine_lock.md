# Finalized lock — "Lift-&-Click" spine (design #2)

A place-then-secure lock that holds the **top tray** down onto the **new layer**.
Drop the top tray straight down (loose), then **sweep the front handle up until it
clicks** — two end hooks rise up the *outside* of the tray's end walls and cam
*inward* over the wall tops, locking it against lift. Sweep down to release.

## Verified (numeric, against the REAL uploaded trays)
`verify_final.py` (single-body carriage + clear travel path + endpoints) and a
direct check on the real layer + real top tray (`L1.stl` + `L3.stl`):

| Check | Result |
|---|---|
| Carriage = one rigid part | ✅ 1 body |
| Existing groove / layer kept | ✅ **0 mm³ of the layer removed** (purely additive, +15.6 cm³) |
| Door (back) side flush | ✅ maxY 101.6 |
| Unlocked: top seats loose & lifts straight off | ✅ 0 mm³ at rest / +2 / +40 |
| Travel path clear (no part passes through a wall) | ✅ 0 mm³ at mid & high lift |
| Locked: no interference at rest | ✅ 0 mm³ |
| Locked: blocks a 2 mm lift (positive capture) | ✅ **504 mm³** (need ≥ 200) |

## Print files (in this folder)
| File | Qty | What |
|---|---|---|
| `layer_with_lock.stl` | 1 | your real layer with the guide rails fused on (groove untouched) |
| `carriage.stl` | 1 | the one-piece U-handle + end hooks (prints in the stowed pose) |

## How it's built
- **Purely additive**: the guides are raised rails on the FRONT + the two SHORT END
  exterior faces only. Nothing is cut from your layer, so the **sliding groove and
  every other feature are exactly as before**. The **back (door) face is bare**.
- **One-piece carriage**: front handle bar + two side rails + two end hooks, joined
  at the front corners — a single printed part that slides vertically in the guides.
- **Kinematically correct**: the hooks travel up the *outside* of the end walls
  (clear), and only flex/cam *inward* over the wall tops in the last few mm → a
  real snap, not a hook passing through a wall. A detent nub gives the click.

## Assembly & printing
1. Print `layer_with_lock.stl` flat (open top up) and `carriage.stl` flat (U lying
   on its back — hooks and rails print without support).
2. **Assemble once:** press the carriage's two side rails into the end-guide
   channels; the retaining lips flex and capture it. It now slides up/down between
   the bottom stop (unlocked) and the detent (locked) and can't fall out.
3. **Use:** set the top tray on, sweep the handle up until it clicks. To remove the
   top tray, sweep down.

## Tuning (re-export from `spine_final.scad`)
| Want | Change |
|---|---|
| Looser/tighter slide & snap | `GAP` (0.6) |
| Stronger lock | `NOSE_IN` (5) / `NOSE_H` (6) |
| Longer/shorter sweep | `TRAVEL` (44) |
| Hook width (strength) | `STEM_W` (70) |

Source: `spine_final.scad` (parametric).  `tray_src="box"` for the test tray,
`tray_src="stl"` to build on `layer_real.stl` (your real layer).
