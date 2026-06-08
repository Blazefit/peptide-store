#!/usr/bin/env python3
"""
verify_final.py — stricter check for the finalized lift-lock.
Adds to verify.py's endpoint tests:
  • CARRIAGE is ONE connected body (a real single part)
  • TRAVEL PATH is clear: at mid-lift poses the moving carriage must NOT pass
    through the seated top tray (catches the 'hook buried in the wall' flaw)
Design .scad must support:
  -D show="new"|"carriage"|"top"   and   -D pose=<0..1>   (0 stowed, 1 locked)
Usage: python3 verify_final.py design.scad
"""
import sys, os, subprocess, tempfile, json
import numpy as np, trimesh
from verify import repair, vol, load_top   # reuse robust helpers

def export(scad, show, pose):
    f=tempfile.NamedTemporaryFile(suffix=".stl",delete=False).name
    r=subprocess.run(["openscad","-o",f,"--render","-D",f'show="{show}"',
                      "-D",f"pose={pose}","-D","$fn=40",scad],capture_output=True,text=True)
    if "ERROR" in (r.stderr or "") or not os.path.exists(f) or os.path.getsize(f)<100:
        print("  export FAILED",show,pose,"\n",r.stderr[-600:]); return None
    return repair(trimesh.load(f))

def main():
    scad=sys.argv[1]; name=os.path.basename(scad); res={}; ok=True
    # 1) carriage is one body
    car=export(scad,"carriage",1.0)
    nbody = len(car.split(only_watertight=False)) if car is not None else -1
    res["carriage_bodies"]=nbody; ok &= (nbody==1)
    # 2) endpoints + path
    n0=export(scad,"new",0.0); n1=export(scad,"new",1.0)
    nmid=export(scad,"new",0.5); nhi=export(scad,"new",0.9)
    if None in (n0,n1,nmid,nhi): print(f"FAIL {name}: export"); sys.exit(1)
    res["door_flush_maxY"]=round(max(n0.bounds[1][1],n1.bounds[1][1]),2)
    ok &= res["door_flush_maxY"]<=101.8
    res["seat_unlocked"]=round(vol(n0,load_top(0)),1); ok&=res["seat_unlocked"]<=60
    lc=[round(vol(n0,load_top(d)),1) for d in (2,15,40)]
    res["lift_clear_unlocked"]=lc; ok&=all(x<=60 for x in lc)
    # travel path: top seated, carriage at mid/high lift must stay clear of it
    res["path_clear_mid(0.5)"]=round(vol(nmid,load_top(0)),1); ok&=res["path_clear_mid(0.5)"]<=80
    res["path_clear_hi(0.9)"]=round(vol(nhi,load_top(0)),1);  ok&=res["path_clear_hi(0.9)"]<=150
    # locked: seats at rest, blocks a 2mm lift
    res["seat_locked"]=round(vol(n1,load_top(0)),1); ok&=res["seat_locked"]<=60
    res["capture_locked(+2)"]=round(vol(n1,load_top(2)),1); ok&=res["capture_locked(+2)"]>=200
    res["PASS"]=bool(ok)
    print(f"{'PASS' if ok else 'FAIL'} {name}: "+json.dumps(res))
    sys.exit(0 if ok else 1)

if __name__=="__main__": main()
