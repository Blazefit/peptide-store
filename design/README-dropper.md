# Peptide Pen "Drop-Selector Revolver"

The next evolution of the [revolver](README-revolver.md): spin the fluted drum
to the pen you want, **press one button**, and that single pen is released — it
drops through a trapdoor into an angled catch tray below and rolls forward to a
lip where you grab it.

![preview](dropper-preview.png)

## How the drop works
1. **Spin** the drum to bring the chosen chamber to the bottom "drop station".
2. **Press** the button — the latch releases the trapdoor.
3. **Drop** — the trapdoor swings open and that one pen falls.
4. **Catch** — it lands in the angled tray and rolls forward to the front lip.

## The four printed parts
| Part | What it is |
|---|---|
| **Drum** | Fluted revolver cylinder. Chambers are **side-open pockets** (rounded cradles) so a pen can drop straight out — this is what gives it the "not completely round" revolver look you wanted. |
| **Cradle** | Legs + axle pins (the drum spins on them) + a **shroud** that wraps the lower half to keep pens in + the **button latch**. |
| **Flap** | The **trapdoor**. Its hinge rod snaps into clips on the cradle; the latch hook holds its front edge shut until you press the button. |
| **Secondary base** | The lower catch unit. The cradle legs **slide down into grooves** in its side walls ("the panel slides into and is received by"). Inside is the **angled tray + front lip**. |

## Why the chambers are open-sided (the honest trade-off)
A pen lying in a *closed* round bore (like the plain revolver) can't fall out
sideways — great for holding, impossible for a gravity drop. To let a chamber
**drop its pen on demand**, each chamber is an outward-open pocket and the
**shroud** holds the pens in everywhere except the top (where gravity does it)
and the bottom drop window (closed by the trapdoor). Net effect: it still reads
as a fluted revolver, and it can release one pen at a time.

## About the mechanism (please read)
This model captures the **geometry and motion** of the latch/hinge/trapdoor in
the **closed position**. It is a working *concept* you can print and refine — the
exact spring feel of the button latch and the hinge friction will need a tuning
pass on your printer (wall thickness, clearances). It is **not** a
guaranteed-on-the-first-print spring mechanism. Think of this as the CAD that
proves the layout works; budget one or two iterations on the latch.

If you'd rather de-risk it, two easy fallbacks are in the tuning table below
(manual flip-up flap, or a sliding bolt instead of a sprung latch).

## Default dimensions
| | |
|---|---|
| Pen assumed | Ø19 × 150 mm |
| Chambers | 6 |
| Drum | Ø75 × 158 mm |
| Overall | ≈ 200 (W) × 110 (D) × 140 (H) mm |

All parametric — change `pen_diameter`, `pen_length`, `num_chambers` and the
rest resizes.

## Files
- `peptide-pen-dropper.scad` — main model + parameters (open this).
- `peptide-pen-dropper-parts.scad` — cradle / flap / secondary / preview modules (auto-included).
- `compose_dropper.py` — builds the labeled preview sheet.
- `dropper-preview.png`, `drop_*.png` — the images above.

## Print & assemble
1. In [OpenSCAD](https://openscad.org), set your real pen size, then export each
   part by setting `part` to `"drum"`, `"cradle"`, `"flap"`, `"secondary"` and
   rendering (F6) → Export STL.
2. Suggested print settings:
   - **Drum:** standing on its back face, 0.2 mm, 15–20% infill, no supports.
   - **Cradle:** shroud-up; light supports under the axle pins and latch.
   - **Flap:** flat, 0.2 mm.
   - **Secondary:** flat, 15% infill.
   - **Material:** PETG (a bit tougher for the latch/hinge).
3. Snap the flap's hinge rod into the cradle clips; snap the drum onto the axle
   pins; slide the cradle legs down into the secondary base grooves.

## Tuning cheatsheet
| Want… | Change |
|---|---|
| More / fewer chambers | `num_chambers` |
| Looser / tighter pen fit | `clearance` |
| More / less of the drum visible | top opening angle in `shroud2d()` (`±68`) |
| Stronger / weaker flutes | `flute_depth` |
| Steeper roll to the lip | `tray_incline` |
| Bigger air gap above the tray | `drop_clear` |
| **Simpler, no-spring flap** | print the flap without the latch and just flip it up by hand to drop |
| **Sliding bolt instead of latch** | replace `latch()` with a pull-tab bolt across the flap lip |

> Print the **drum + cradle + flap** first and get the spin/drop feeling right
> before printing the larger secondary base.
