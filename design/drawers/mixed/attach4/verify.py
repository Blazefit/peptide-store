#!/usr/bin/env python3
"""
verify.py  —  numeric correctness check for a place-then-secure attachment design,
tested against the REAL uploaded top tray (/tmp/L3.stl).

Each design .scad MUST support:
   -D show="new"   -> ONLY the new tray + lock hardware (NO top tray)
   -D lock=0 / 1   -> unlocked / locked
Usage:  python3 verify.py path/to/design.scad
Exit 0 if all checks PASS.

Seated frame: new-tray top face at z=50, top tray base at z=50, min corner (0,0).
"""
import sys, os, subprocess, tempfile, json
import numpy as np, trimesh
from trimesh.boolean import intersection

TOPSTL = "/tmp/L3.stl"
BASE_Z = 50.0
THRESH_SEAT = 60.0   # mm^3 tolerated overlap when top is at rest (loose touch ok)
THRESH_LOCK = 200.0  # mm^3 min overlap on a 2mm lift => positive capture
MAXY = 101.8         # door side flush limit (real back face 101.6)

def load_top(dz=0.0):
    m = trimesh.load(TOPSTL)
    m.apply_translation(-m.bounds[0])            # min corner -> origin
    m.apply_translation([0,0,BASE_Z+dz])         # seat on new tray, optional lift
    return m

def export_new(scad, lock):
    f = tempfile.NamedTemporaryFile(suffix=".stl", delete=False).name
    r = subprocess.run(["openscad","-o",f,"--render","-D",'show="new"',
                        "-D",f"lock={lock}","-D","$fn=40",scad],
                       capture_output=True,text=True)
    if "ERROR" in (r.stderr or "") or not os.path.exists(f) or os.path.getsize(f)<100:
        print("  openscad export FAILED:\n",r.stderr[-800:]); return None
    return trimesh.load(f)

def vol(a,b):
    try:
        c = intersection([a,b], engine="manifold")
        return float(abs(c.volume)) if (c is not None and len(c.faces)) else 0.0
    except Exception as e:
        print("   boolean err",e); return -1.0

def main():
    scad=sys.argv[1]; name=os.path.basename(scad)
    n0=export_new(scad,0); n1=export_new(scad,1)
    if n0 is None or n1 is None: print(f"FAIL {name}: export"); sys.exit(1)
    res={}; ok=True
    # door flush (both states)
    my=max(n0.bounds[1][1], n1.bounds[1][1])
    res["door_flush_maxY"]=round(my,2); flush = my<=MAXY
    ok&=flush
    # seat ok unlocked
    s0=vol(n0, load_top(0)); res["seat_unlocked"]=round(s0,1); ok&=(0<=s0<=THRESH_SEAT)
    # lift clear unlocked at +2/+15/+40
    lc=[round(vol(n0,load_top(d)),1) for d in (2,15,40)]
    res["lift_clear_unlocked(+2,+15,+40)"]=lc; ok&=all(0<=x<=THRESH_SEAT for x in lc)
    # locked still seats (rest) but blocks a 2mm lift
    s1=vol(n1, load_top(0)); res["seat_locked"]=round(s1,1); ok&=(0<=s1<=THRESH_SEAT)
    cap=vol(n1, load_top(2)); res["capture_locked(+2)"]=round(cap,1); ok&=(cap>=THRESH_LOCK)
    res["PASS"]=bool(ok)
    print(f"{'PASS' if ok else 'FAIL'} {name}: "+json.dumps(res))
    sys.exit(0 if ok else 1)

if __name__=="__main__":
    main()
