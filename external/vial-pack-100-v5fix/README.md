# vial-pack-100 v5 fix — staged here

These are the finished fixes for **`Blazefit/vial-pack-100`** (the stackable
lid + tray "100× 3 mL vial" tower). They're parked in this repo because this
work session is scoped to `blazefit/peptide-store` only — the environment's
allow-list doesn't include `vial-pack-100`, so the commit (`983a0c6`) could not
be pushed to its home repo. This folder preserves the work and gives you a link.

## What was wrong (left unfinished in the v5 "design-review" commit)
1. **`current/tray.stl` was not manifold** — it was a preview export (69
   interpenetrating shells, not watertight) even though the README claimed all
   parts were manifold. The stacklid and lid were fine.
2. **Audits validated stale dimensions** — `fit_audit.py` / `checks_lidded.py`
   still hardcoded the pre-v5 `rim 3.0 / floor 2.0`; v5 trimmed them to `2.5 / 1.6`.
3. **README numbers were stale** — pitch 46.74 / 3-layer 143.2 mm / footprint 107×120.

## What's fixed (verified)
- **`tray.stl`** — re-rendered via CGAL into a clean **single watertight manifold**
  (99.4 cm³). All three parts now watertight, 1 component.
- **`fit_audit.py` / `checks_lidded.py`** — synced to `rim 2.5 / floor 1.6`; both
  **PASS** on the real geometry now.
- **READMEs** — authoritative numbers: pitch **46.34 mm**, 3-layer **142.0 mm**
  (139.0 flush), footprint **106×119 mm**. `tray.png` re-rendered.

## Files
| File | Maps to in vial-pack-100 |
|---|---|
| `tray.stl` | `current/tray.stl` (the manifold print file) |
| `tray.png` | `current/tray.png` |
| `current_README.md` | `current/README.md` |
| `root_README.md` | `README.md` |
| `fit_audit.py` | `current/fit_audit.py` |
| `checks_lidded.py` | `current/checks_lidded.py` |
| `v5fix.patch` | the full commit `983a0c6` (apply with `git am`) |

## How to apply to vial-pack-100
From a clone of vial-pack-100 on `main`:
```
git am /path/to/v5fix.patch        # applies commit 983a0c6 exactly
# or copy the files above into place, then commit
git push origin main
```
Or, to have me push it directly, add `Blazefit/vial-pack-100` to this
environment's allowed repositories and reconnect.
