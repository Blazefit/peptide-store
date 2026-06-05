#!/usr/bin/env python3
"""
Ground-truth verifier for the Horizontal Peptide Pen Holder Design Loop.

Renders each design's .scad -> .stl with OpenSCAD, then measures the mesh with
trimesh/numpy and prints PASS/FAIL against the locked constraints.

Constraints enforced (from KICKOFF.md / LOCKED PEN SPECIFICATION):
    L <= 177.8 mm   (7.0 in)   bounding-box extent along X (pen long axis)
    W <=  63.5 mm   (2.5 in)   bounding-box extent along Y
    H <= 152.4 mm   (6.0 in)   bounding-box extent along Z
    watertight mesh (manifold, no holes)
    overhang area fraction <= 0.15

Overhang metric (FDM, print bed = Z-min, build direction +Z):
    A downward-facing triangle needs support if the angle between its outward
    normal and straight-down (0,0,-1) is < 45 deg, i.e. normal_z < -cos(45).
    Faces resting on the print bed (within BED_EPS of Z-min) are excluded
    because the bed supports them. Reported value is supported-overhang area
    divided by total surface area.

Trust these numbers over any reasoning about the geometry.
"""

import os
import sys
import math
import json
import subprocess

import numpy as np
import trimesh

HERE = os.path.dirname(os.path.abspath(__file__))
DESIGNS = os.path.join(HERE, "designs")

# Locked limits (mm)
L_MAX = 177.8
W_MAX = 63.5
H_MAX = 152.4
OVERHANG_MAX = 0.15

# Overhang geometry
OVERHANG_COS = math.cos(math.radians(45.0))  # 0.7071...
BED_EPS = 0.6  # mm: faces this close to Z-min are bed-supported

import glob

# Preferred display order; any other designs/*.scad are appended automatically.
PREFERRED = ["d1_cradle", "d2_capsule", "d3_modular", "d4_magnetic", "d5_vialcombo"]


def discover_designs():
    found = []
    for path in sorted(glob.glob(os.path.join(DESIGNS, "*.scad"))):
        name = os.path.splitext(os.path.basename(path))[0]
        if name in ("common", "rack_lib", "borewin_lib", "gate_lib"):
            continue
        found.append(name)
    ordered = [d for d in PREFERRED if d in found]
    ordered += [d for d in found if d not in PREFERRED]
    return ordered


DESIGN_IDS = discover_designs()


def render(scad_path, stl_path):
    """Compile a .scad file to .stl via OpenSCAD. Returns (ok, message)."""
    try:
        res = subprocess.run(
            ["openscad", "-o", stl_path, scad_path],
            capture_output=True, text=True, timeout=300,
        )
    except FileNotFoundError:
        return False, "openscad not found"
    except subprocess.TimeoutExpired:
        return False, "render timeout"
    if res.returncode != 0 or not os.path.exists(stl_path):
        err = (res.stderr or res.stdout or "").strip().splitlines()
        tail = " | ".join(err[-3:]) if err else "unknown render error"
        return False, tail
    return True, "ok"


def overhang_fraction(mesh):
    """Supported-overhang area / total area."""
    normals = mesh.face_normals
    areas = mesh.area_faces
    total = float(areas.sum())
    if total <= 0:
        return 1.0
    nz = normals[:, 2]
    downward = nz < -OVERHANG_COS
    # exclude bed-contact faces (all vertices near global Z-min)
    zmin = mesh.vertices[:, 2].min()
    tri_z = mesh.vertices[mesh.faces][:, :, 2]  # (F,3)
    on_bed = np.all(tri_z <= zmin + BED_EPS, axis=1)
    overhang = downward & ~on_bed
    return float(areas[overhang].sum() / total)


def check_design(did):
    scad = os.path.join(DESIGNS, did + ".scad")
    stl = os.path.join(DESIGNS, did + ".stl")
    rec = {"id": did, "status": "FAIL", "checks": {}, "L": None, "W": None,
           "H": None, "watertight": None, "overhang": None, "note": ""}

    if not os.path.exists(scad):
        rec["note"] = "missing .scad"
        return rec

    ok, msg = render(scad, stl)
    if not ok:
        rec["note"] = "render failed: " + msg
        return rec

    try:
        mesh = trimesh.load(stl, force="mesh")
    except Exception as e:  # noqa
        rec["note"] = "load failed: %s" % e
        return rec

    if mesh.is_empty or len(mesh.faces) == 0:
        rec["note"] = "empty mesh"
        return rec

    ext = mesh.bounding_box.extents
    L, W, H = float(ext[0]), float(ext[1]), float(ext[2])
    wt = bool(mesh.is_watertight)
    of = overhang_fraction(mesh)

    checks = {
        "L<=177.8": L <= L_MAX,
        "W<=63.5": W <= W_MAX,
        "H<=152.4": H <= H_MAX,
        "watertight": wt,
        "overhang<=0.15": of <= OVERHANG_MAX,
    }
    rec.update({
        "L": round(L, 2), "W": round(W, 2), "H": round(H, 2),
        "watertight": wt, "overhang": round(of, 4), "checks": checks,
        "status": "PASS" if all(checks.values()) else "FAIL",
    })
    return rec


def main():
    results = []
    npass = 0
    print("=" * 74)
    print("HORIZONTAL PEPTIDE PEN HOLDER — VERIFY")
    print("limits: L<=%.1f  W<=%.1f  H<=%.1f  watertight  overhang<=%.2f"
          % (L_MAX, W_MAX, H_MAX, OVERHANG_MAX))
    print("=" * 74)
    for did in DESIGN_IDS:
        rec = check_design(did)
        results.append(rec)
        if rec["status"] == "PASS":
            npass += 1
        if rec["L"] is None:
            print("%-13s %-4s  %s" % (did, rec["status"], rec["note"]))
        else:
            failed = [k for k, v in rec["checks"].items() if not v]
            tail = "" if not failed else "  FAILS: " + ", ".join(failed)
            print("%-13s %-4s  L=%6.2f W=%5.2f H=%6.2f  wt=%-5s ovh=%.3f%s"
                  % (did, rec["status"], rec["L"], rec["W"], rec["H"],
                     str(rec["watertight"]), rec["overhang"], tail))
    print("-" * 74)
    print("PASSING: %d / %d" % (npass, len(DESIGN_IDS)))
    print("=" * 74)

    with open(os.path.join(HERE, "verify_results.json"), "w") as f:
        json.dump({"pass_count": npass, "results": results}, f, indent=2)

    return 0 if npass >= 3 else 1


if __name__ == "__main__":
    sys.exit(main())
