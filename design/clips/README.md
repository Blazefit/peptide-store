# End clips — connect layer 2 to the top piece (add-on, no modification)

Two small **separate clips** (one per short end) that lock the original
`layer2.stl` to the original top piece (`top_piece.stl`). **Nothing is modified on
either part** — print the clips and snap them on.

## How each clip grabs (verified on the real STLs)
- A **barb drops into layer 2's end window** (z26–44) → anchors the clip to layer 2.
- A **notch caps over the top piece's end-wall top edge** (z83), inner lip hooks
  behind it → holds the top piece down. A detent bump clicks to hold.
- Checks vs the real meshes: clip∩layer2 = 0, clip∩top = 0 at rest;
  top piece lifted 2 mm → **648 mm³** runs into the clip = **positively blocked**.
- Clips are on the **short ENDS**, so the long fridge-door side stays clear.

## Ordering on Craftcloud
- **Quantity: 2** of the same clip (one per end). Each ~**10.7 cm³**, 15.6 × 44 × 53 mm
  → a small, cheap part.
- **Recommended material: Nylon PA12 (MJF or SLS).** It's tough and slightly flexible
  — ideal for a snap clip, prints support-free, and is usually the cheapest option
  for small parts. **Avoid standard/brittle SLA resin** (it will crack on the snap);
  if you want resin, choose a "tough"/PP-like one. FDM **PETG or Nylon** is also fine.
- Craftcloud/the bureau auto-orients; MJF/SLS need no supports. Units are mm.

### Fit variants (pick based on the process you order)
Bureau tolerances vary, and you can't easily re-print, so three fits are provided
(clearance at the wall-grip notch):
| File | Clearance | Use for |
|---|---|---|
| `clip_tight.stl` | 0.25 mm | precise processes (SLA/Polyjet) |
| `clip.stl` | 0.40 mm | **default — MJF / SLS Nylon** |
| `clip_loose.stl` | 0.60 mm | FDM, or if the default won't seat |
Cheapest hedge: order **clip.stl ×2**; the part is small enough that adding one
`clip_tight` + one `clip_loose` to the same order costs little if you want to test fit.

## Install / remove
1. Set the top piece on layer 2 as normal.
2. At one end: **hook the bottom barb into layer 2's window**, then **press the top
   notch down over the top piece's top edge** until the detent clicks.
3. Repeat at the other end. To remove: pull the **finger tab** out, lift the clip.

## Tuning (`clip_ends.scad`)
`CLR` = notch clearance · `BB_X` = barb depth · `CY0/CY1` = clip width · `DET_Z` = detent.
