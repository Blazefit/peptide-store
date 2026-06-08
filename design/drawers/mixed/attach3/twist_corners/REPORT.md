# Twist-Corner Cam Variants — Design Report

## Variants Summary

| File | Description | Cam count | Grip style |
|------|-------------|-----------|------------|
| `01_corner_cam.scad` | Two front-corner D-lobe cams + flush back guide wall | 2 | Grip ribs on lobe face |
| `02_front_end_cams.scad` | 2 front corners + 2 short-end mid cams, D-lobe | 4 | Top-face finger ribs |
| `03_wide_lobe.scad` | 2 front corners + 2 short ends, 120° wide arc lobe (teal) | 4 | Wide arc + rim step |
| `04_end_hook_cams.scad` | 2 front corners (D-lobe) + 2 short-end hook cams | 4 | Hook toe over rim |
| `05_front_mid_cam.scad` | 2 front corners + 1 front midpoint + 2 short ends | 5 | Large-lobe center grip |
| `06_lever_cam.scad` | Eccentric disk + integral lever arm, 4 posts | 4 | Thumb paddle lever |

---

## Best Pick: `04_end_hook_cams.scad`

### Why

1. **Positive locking feel**: The short-end hook cams rotate 90° so the L-shaped toe
   goes over the rim and a 2mm-deep pull-down notch on the underside grabs the rim
   top face. This provides a distinct tactile "caught" feel rather than friction-only
   clamping — more reliable and easier to verify locked.

2. **Ergonomics**: Front two corners use D-lobe cams (y=0 front face, one-finger twist).
   Short-end hook cams are accessed from x=0 and x=305 faces. All four cams need
   only ~90° rotation, no overhead clearance, no tools.

3. **Geometry separation**: D-lobe covers front rim; L-hooks cover short-end rims.
   Together all four sides of the top-tray rim are engaged without touching the back.

4. **Flush back constraint**: Zero hardware past y=102.

---

## Operation

1. **Open** (`lock=0`): All lobes/hooks point outward. Top tray (305×102) drops
   straight down between posts with no interference on any side.
2. **Lower top tray**: Place straight down. Back guide wall on new tray registers
   back edge flush at y=102.
3. **Secure** (`lock=1`): Twist each cam ~90° inward. Front D-lobes swing over
   front rim (z≥83). Short-end hooks swing so L-toe overhangs short-end rim at z=83
   and the underside notch rests on rim top, pulling tray down. Stop nubs click at
   both open and locked positions.
4. **Minimal overhead**: Cam top is z=88, only ~5mm above rim — minimal shelf intrusion.
   No downward snap, no reaching from above.

---

## How the Door (Back) Side Stays Flush

- No posts at back corners — all posts are at y<0 (front) or y=ND/2=51 (ends).
- No geometry past y=102 on any variant.
- **Back guide wall**: A 3mm × 5mm raised strip on the new tray top face at y=99–102
  (within the tray's own wall thickness). It registers the top tray's back face.
- Clamping force: pulling any non-back side of the rigid top-tray shell downward also
  pulls the back edge down against the guide wall. The tray is rigid (305×102×33 shell).

---

## Print Orientation

Print in assembled Z orientation, posts pointing up.

- **Posts**: Print vertically, no supports needed. Post cap bridges ~6mm — fine for
  PLA/PETG without support.
- **Cams (print-in-place)**: Cam sleeve rotates on post. Gap is 0.4mm radial
  (bore = post_r×2 + 2×0.4). Standard FDM print-in-place; rotate free after removing
  elephant-foot buildup with a craft knife if needed.
- **Cam ramp underside**: 3–4° taper, self-supporting (near-vertical overhang).

### Print-in-Place Clearance Table

| Gap location | Value | Notes |
|---|---|---|
| Cam bore radial clearance | 0.40 mm | Cam rotates on post |
| Cam bottom axial (vs flange) | 0.40 mm | Prevents cam welding to base |
| Cam top axial (vs cap) | 0.40 mm | Cam cannot escape post |
| Lobe tip vs tray wall (open) | ≥2 mm | Tray drops freely |
| Hook toe vs rim (open) | ≥1.5 mm | All-clear for vertical drop |

Recommended: 0.2mm layer height, PETG or PLA, 0.4mm nozzle, no scaling needed.

---

## Verification

- All 6 files compile with `openscad -o .csg` returning exit 0 (zero ERRORs).
- Renders confirm: grey top tray on blue new tray, purple/teal cams on front and
  short-end faces only, back face visually flat.
- `lock=0` lobes clear; `lock=1` lobes/hooks over rim.
- Zero geometry added to the top tray (grey, never modified).
