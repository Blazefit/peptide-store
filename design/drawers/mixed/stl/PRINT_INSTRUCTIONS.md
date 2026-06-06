# Mixed Peptide Drawer Cabinet — Print Instructions

Front-access drawer cabinet for a fridge shelf. Spin nothing — every drawer
**pulls out the front**. Two columns × three drawers.

## Overall size
≈ **375 (W) × 372 (D) × 136 (H) mm**  (≈ 14.8 × 14.6 × 5.35 in — under the 5.5 in fridge limit).

## Parts & quantities
| File | Qty | What it is |
|---|---|---|
| `frame.stl` | 1 | The cabinet shell (2 columns, shelves, slide grooves, rear vent) |
| `drawer_vial.stl` | 2 | Vial drawer — 3 mL field (Ø19) + two 10 mL columns (Ø23.6) on a two-plate rack |
| `drawer_pen.stl` | 2 | Pen drawer — 14 broadside cradles (Ø20.6) with end-stops + lift dip |
| `drawer_supply.stl` | 2 | Supply drawer — divided cells (wipes/caps/needles) |

**Capacity (all 6 drawers):** ~160× 3 mL + 52× 10 mL vials · 28 pens/syringes · 12 supply cells.

## ⚠ Bed size — these parts are bigger than a 256 mm bed
The frame (375 × 372) and the drawers (~180 × 360 deep) **won't fit a 220–256 mm
bed whole**. Two options:

1. **Large-format printer (≥ 380 mm):** print as-is.
2. **Normal bed (recommended for most):** use your slicer's **Cut tool**
   (PrusaSlicer: *Cut*; Bambu Studio: *Cut*; Cura: *Mesh Tools*) to split:
   - **Drawers:** one cut across the **middle of the depth** → two ~180 × 185 halves. Enable **dowels/connectors** in the cut dialog, then glue (CA/epoxy). The cut lands on a flat wall, so the slide stays smooth.
   - **Frame:** cut **once down the centre** (between the two columns) and **once across the middle of the depth** → four ~189 × 186 quarter-tiles. Add connectors + glue, or bolt with M3.

   (If you tell me your exact bed size I can ship pre-split STLs with the dowel holes already in — no slicer work.)

## Slicer settings
- **Material:** PETG (tougher for the sliding parts) or PLA.
- **Layer height:** 0.2 mm · **Walls/perimeters:** 3 · **Infill:** 15–20 %.
- **Supports:**
  - **Frame:** none needed (grooves are open-topped).
  - **Vial drawers:** the top plate spans an open frame, so enable **supports
    “everywhere” inside the drawer** (they lift out through the open top + holes).
    Or print the drawer **upside-down** (top plate on the bed) for support-free —
    then the base indents need light support instead; either works.
  - **Pen / supply drawers:** none.
- **Scale:** 100 %. Don't auto-scale.

## Assembly
1. If you split parts, glue the halves (with the connectors/dowels) and let cure.
2. Slide each drawer into its bay from the front — the **side ribs** drop into the
   **frame grooves**. Push until the **back-bump** passes the **front lip** (light
   click): the drawer now can't fall out when pulled.
3. Load: 3 mL vials in the small-hole field, 10 mL in the two big columns, pens
   lying across the pen drawer, supplies in the cells.
4. Add a label to each drawer's front label patch.

## Fridge notes
- Every floor has **drain holes** so condensation can't pool.
- The frame has a **rear vent** for airflow.
- Designed to sit between shelves and be worked **entirely from the front**.

## Tuning (re-export from `mixed_cabinet.scad` if needed)
| Want | Change |
|---|---|
| Looser/tighter drawer slide | `run_clr` / `gdep`/`rwid` |
| Different vial sizes | `v3_d`, `vial_d` (holes = vial Ø + `vial_clr`) |
| 3 mL / 10 mL ratio | `vial_split` (0.68 ≈ 70/30) |
| Handle style | `handle_style` = `bar` / `scoop` / `dpull` |
| Pen size/count | `pen_d`, `pen_len` |
| Add a third column (wider) | duplicate a column module |

---
## LIGHT version (cheaper) — `*_light.stl`
Same fit and function, ~40 % less material (the frame is 63 % lighter: open
skeleton instead of solid slabs). Print **`frame_light` ×1, `drawer_vial_light`
×2, `drawer_pen_light` ×2, `drawer_supply_light` ×2**. Quote both sets on
Craftcloud and pick whichever comes back cheaper — the light set should win.
Walls/plates are thinner (drawer walls 2.4 mm, vial plates 3.5/5.5 mm), so prefer
PETG or Nylon over brittle PLA for the light version.
