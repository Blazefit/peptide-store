# Place-then-secure stacking lock — TOP 5 (verified)

All five attach the NEW bottom tray to the already-printed top tray. They:
- let the top tray drop **straight down, loose** (no sliding on at an angle, no snap),
- lock with a **separate horizontal action from the FRONT / SHORT ENDS** (no overhead reach),
- keep the **back (fridge-door) side completely flush**,
- add **zero geometry to the top tray** and **keep the existing sliding groove**.

Each was checked numerically against the **real uploaded tray (L3.stl)** with `../verify.py`
(door-flush ≤101.8, loose seat, free vertical lift when unlocked, and a **2 mm lift physically
blocked when locked** — "capture" ≥ 200 mm³).

| # | Design | File | capture(+2mm) | Operation |
|---|--------|------|--------------|-----------|
| ① | **Slide-rail bolt** (recommended) | `A_slidebolt/03_sliderail.scad` | 1308 mm³ | one front push → shelf over front rail + ends |
| ② | Lift-&-click spine | `D_wildcard/04_best_clamp.scad` | 533 mm³ | one upward sweep → both end hooks snap over |
| ③ | Flip-levers | `C_fliplever/02_discret_cams.scad` | 651 mm³ | flip 3 front + 2 end levers; fold flat open |
| ④ | Tri-lock twist cams | `B_twist/04_trilock.scad` | 288 mm³ | quarter-turn 2 end knobs + 1 front cam |
| ⑤ | Twin-tab bolt (lightest) | `A_slidebolt/04_twintab.scad` | 747 mm³ | one front push → 2 slim tabs into the slot |

Renders (front / low / **rear=door side** / open) for each are in `renders/`.
Comparison sheet: `attach-top5.png`.

Pick one and it gets unioned onto the real layer STL (groove preserved) and re-verified.
