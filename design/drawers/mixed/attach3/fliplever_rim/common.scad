// common.scad — shared geometry for FLIP-LEVER / CAM-LATCH RIM CLAMP family
// Coordinate frame:
//   X: 0..305 (long axis)   Y: 0..102 (Y=0 FRONT/open, Y=102 BACK/door=FLUSH)
//   Z: up.  New tray base z=0, top face z=50.  Top tray base z=50, rim top z=83.
// ALL levers/hinges live on FRONT wall (y=0) and SHORT ENDS (x=0, x=305).
// NOTHING crosses y=102 (door face). Top tray gets ZERO added geometry.

// ── master dims ────────────────────────────────────────────────
NW = 305;  ND = 102;  NH = 50;   // new tray
TW = 305;  TD = 102;  TH = 33;   // top tray (FIXED reference)
wall = 3;
rim_top_z = NH + TH;             // = 83

// ── colours ────────────────────────────────────────────────────
C_new   = "#1565C0";
C_top   = "#90A4AE";
C_lever = "#EF6C00";   // override per file if desired

// ── core tray bodies ───────────────────────────────────────────
module new_tray() {
    color(C_new)
    difference() {
        cube([NW, ND, NH]);
        translate([wall, wall, wall])
            cube([NW-2*wall, ND-2*wall, NH]);
        // side windows (long walls): 45(X)x16(Z), center z=64 -> 56..72
        for (cx = [76.25, 152.5, 228.75]) {
            // FRONT wall y=0..3
            translate([cx-22.5, -0.1, 56]) cube([45, wall+0.2, 16]);
            // BACK wall y=99..102
            translate([cx-22.5, ND-wall-0.1, 56]) cube([45, wall+0.2, 16]);
        }
    }
}

// FLUSH back guide wall: a low rib on the new tray top face along the BACK
// edge that pockets the top tray's outer wall from the INSIDE only.
// It rises to z below the rim and DOES NOT overhang the drop path and
// NEVER crosses y=102 (it sits inboard of the door face).
module back_guide() {
    gw = 2.4;          // guide rib thickness
    gh = 12;           // rib height above new tray top (z=50..62)
    inset = wall;      // inner face aligns to tray inner wall (y=99 plane outer)
    color(C_new)
    translate([wall+1, ND - wall - gw, NH])
        cube([NW - 2*(wall+1), gw, gh]);
}

module top_tray() {
    color(C_top)
    translate([0, 0, NH])
    difference() {
        cube([TW, TD, TH]);
        translate([wall, wall, 0])
            cube([TW-2*wall, TD-2*wall, TH-wall]);
    }
}
