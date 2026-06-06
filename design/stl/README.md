# Print-ready STLs

Exported from the OpenSCAD sources at default parameters (pen Ø19 × 150 mm).
To resize for a different pen, edit `pen_diameter` / `pen_length` / `num_chambers`
in the `.scad` source and re-export — these STLs are fixed-size snapshots.

## Drop-Selector Revolver (the main design) — print 3 parts
| File | Qty | Orientation / notes |
|---|---|---|
| `dropper_drum.stl` | 1 | stand on an end face; 0.2 mm; 15–20 % infill; no supports |
| `dropper_body.stl` | 1 | tray down; light **tree supports** under the curved shroud; rest support-free |
| `dropper_shutter.stl` | 1 | flat; 0.2 mm |
| `dropper_lid.stl` | 0–1 | optional dust cover; arch-up, no supports |

Assemble: slide the shutter into the front track, then drop the drum's stubs into
the open-top bearings. No fasteners. (Optional: push a Ø6 mm rod through the drum
for a metal axle.)

## Revolver (simpler 2-part spin-to-select) — print 2 parts
| File | Qty |
|---|---|
| `revolver_drum.stl` | 1 |
| `revolver_base.stl` | 1 |

## Lane rack / holder — print 1 part
| File | Qty |
|---|---|
| `holder.stl` | 1 |

## General
- Material: PLA or PETG (PETG is a little tougher for the moving parts).
- Layer height 0.2 mm, 3 perimeters, 15–20 % infill is plenty.
- If the drum spins too tight or too loose, re-export after changing `bearing_gap`;
  same for the shutter with `shutter_gap`.
