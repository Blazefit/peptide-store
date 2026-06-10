#!/usr/bin/env python3
"""
check_stl_manifold.py — fail CI if any committed STL is not a printable manifold.

Catches the real failure mode we hit once: a preview-exported STL (overlapping
shells / open edges) getting committed while docs claim "manifold". A watertight
mesh = every edge shared by exactly two faces = a solid a slicer can trust.

- Scans for *.stl (default: whole repo).
- Skips paths listed in .manifoldignore (gitignore-style globs, one per line).
- A file PASSES if trimesh reports it watertight (multi-body parts are fine as
  long as every body is closed).
- Exits non-zero if any non-ignored STL fails -> the GitHub Action goes red.

Usage:  python3 tools/check_stl_manifold.py [paths...]
"""
import sys, glob, os, fnmatch
import trimesh

def load_ignores(path=".manifoldignore"):
    pats = []
    if os.path.exists(path):
        for line in open(path):
            line = line.split("#", 1)[0].strip()
            if line:
                pats.append(line)
    return pats

def ignored(rel, pats):
    rel = rel.replace("\\", "/")
    return any(fnmatch.fnmatch(rel, p) or fnmatch.fnmatch(rel, p.rstrip("/") + "/*")
               for p in pats)

def main():
    roots = sys.argv[1:] or ["."]
    pats = load_ignores()
    files = []
    for r in roots:
        files += glob.glob(os.path.join(r, "**", "*.stl"), recursive=True) if os.path.isdir(r) else [r]
    files = sorted(set(os.path.relpath(f) for f in files))

    fails, skipped = [], []
    print(f"Checking {len(files)} STL file(s) for manifoldness\n")
    for f in files:
        if ignored(f, pats):
            skipped.append(f); continue
        try:
            m = trimesh.load(f)
            wt = bool(m.is_watertight)
            comps = len(m.split(only_watertight=False))
            tag = "PASS" if wt else "FAIL"
            print(f"  [{tag}] {f}  watertight={wt}  bodies={comps}  vol={m.volume/1000:.1f}cm3")
            if not wt:
                fails.append(f)
        except Exception as e:
            print(f"  [FAIL] {f}  load error: {e}")
            fails.append(f)

    if skipped:
        print(f"\n  ({len(skipped)} ignored via .manifoldignore)")
    print("\n" + "-" * 60)
    if fails:
        print(f"RESULT: FAIL — {len(fails)} non-manifold STL(s):")
        for f in fails:
            print(f"   - {f}")
        print("Fix: re-export with a real CGAL/Manifold render (not preview), or add to")
        print(".manifoldignore if it is an intentional non-printable artifact.")
        sys.exit(1)
    print("RESULT: PASS — every checked STL is watertight/manifold.")

if __name__ == "__main__":
    main()
