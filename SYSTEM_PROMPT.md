# SYSTEM_PROMPT — Horizontal Peptide Pen Holder Design Loop

> Reconstructed from KICKOFF.md (the original scaffold file was not present in
> the repo). This captures the authoritative spec the loop runs against. The
> objective ground truth is always `verify.py`.

## 1. Objective
Design a desk/drawer organizer that holds peptide injector **pens lying
horizontally**. Produce five distinct `.scad` designs; at least **three** must
PASS every objective check in `verify.py`.

## 2. LOCKED PEN SPECIFICATION (verbatim)
- Pen length: **165 mm**
- Pen cross-section: **17 mm × 20 mm** (treated as a 20 mm-diameter envelope)
- Print/fit clearance: **CLEAR = 0.4 mm**
- Channel radius used = 20/2 + 0.4 = **10.4 mm**

## 3. Hard constraints (enforced by verify.py)
| Check        | Limit            |
|--------------|------------------|
| Length (X)   | ≤ 177.8 mm (7")  |
| Width (Y)    | ≤ 63.5 mm (2.5") |
| Height (Z)   | ≤ 152.4 mm (6")  |
| Watertight   | manifold, true   |
| Overhang     | area frac ≤ 0.15 |

Walls ≥ 1.6 mm, `$fn = 64`, and a **local dial relief pocket at one end of
each channel** (so the dose dial can be turned / clears the body).

## 4. Approved arrangement families (never a flat side-by-side tray)
A flat 5-across tray exceeds the 63.5 mm width limit and is **banned**.
Approved families:
1. **Stacked / clustered** vertically or in a tight 2-wide group.
2. **Capsule / enclosed tube** bundle (self-supporting bores).
3. **Modular** single-pen units that join together.
4. **Magnetic / wall-mount** carrier.
(plus combo variants, e.g. pen + vial.)

## 5. Design slots
`d1_cradle`, `d2_capsule`, `d3_modular`, `d4_magnetic`, `d5_vialcombo`.

## 6. Printability notes baked into the geometry
- Open-top **U-troughs** have vertical side walls above the channel center →
  no ceiling → ~zero overhang.
- Enclosed bores use a **teardrop** profile (45° self-supporting apex).
- Dovetails for modular joints are extruded **vertically** so their angled
  faces are vertical planes (no overhang).
- A solid floor ≥ 1.6 mm keeps the bottom watertight.

## 7. Loop procedure
1. Edit ≤ 2 failing `.scad` files per iteration; leave PASSING ones untouched.
2. Re-run `python3 verify.py`.
3. Append cause → fix → expected-effect to `DESIGN_SUMMARY.md`.
4. Thrash guard: same check fails 3 iterations in a row → log and abandon.
5. Stop at ≥ 3 PASS (success) or 15 iterations (`needs_human`).

## 8. Handoff
Print final STATE JSON, export passing meshes, list `designs/`, and report the
3+ passing designs with measured bounding boxes and the creative variation each
explored.

## 9. STATE JSON schema
```json
{
  "iteration": 0,
  "status": "in_progress | success | failed | needs_human",
  "pass_count": 0,
  "designs": {
    "d1_cradle":   {"status": "PASS|FAIL", "L": 0, "W": 0, "H": 0,
                     "watertight": true, "overhang": 0.0, "note": ""}
  },
  "passing": ["d1_cradle"]
}
```
