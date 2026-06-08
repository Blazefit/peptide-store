# End clips — connect layer 2 to the top piece (add-on, no modification)

Two small **separate clips** (one per short end) that lock the original
`layer2.stl` to the original top piece (`top_piece.stl`). **Nothing is modified on
either part** — you print the clips and snap them on.

## How each clip grabs (verified on the real STLs)
- A **barb drops into layer 2's end window** (z26–44) → anchors the clip to layer 2.
- A **notch caps over the top piece's end-wall top edge** (z83), with an inner lip
  that hooks behind it → holds the top piece down.
- Result: the top piece can't lift off. Checks against the real meshes:
  - clip ∩ layer 2 = **0** (barb sits in the open window, no interference)
  - clip ∩ top piece = **0** at rest (drops together cleanly)
  - top piece lifted 2 mm → **672 mm³** runs into the clip = **positively blocked**
- Clips are on the **short ENDS**, so the long fridge-door side stays clear.

## Print
| File | Qty | Size |
|---|---|---|
| `clip.stl` | **2** (print two) | 15 × 44 × 53 mm, ~10.7 cm³ each |

- **Orientation:** lay the clip on its flat outer (spine) face so the barb, top
  notch and finger tab all point up — prints with no supports.
- **Material:** PETG/PLA, 3 perimeters, 20% infill.

## Install / remove
1. Set the top piece on layer 2 as normal.
2. At one end, **hook the bottom barb into layer 2's window**, then **press the top
   notch down over the top piece's top edge** until the detent clicks.
3. Repeat at the other end.
4. To remove: pull the **finger tab** outward to release the top notch, lift the clip.

## Tuning (`clip_ends.scad`)
| Want | Change |
|---|---|
| Tighter/looser grip | `IN_LIP_X1`, `BB_X` |
| Wider (stronger) clip | `CY0`/`CY1` |
| Snap firmness | `DET_Z` detent bump |

Source `clip_ends.scad` imports `layer2.stl` + `top_piece.stl` for fit only.
