// top_ref.scad  — FAITHFUL reference of the real uploaded top tray (L3.stl)
// Extracted from L3.stl by voxel analysis. Coordinates: new-tray top face = z=0 here,
// call top_ref(base=50) to seat it on a 50mm-tall new tray.
// DO NOT MODIFY THIS PART IN ANY DESIGN — it represents an already-printed tray.
//
// Real dims: 304.8 (X) x 101.6 (Y) x 33 (Z).
//  - END walls (short, x=0..3 and 301.8..304.8): SOLID full height -> top at z=33 (seated 83)
//  - LONG sides (front y=0..3, back y=98.6..101.6): OPEN FRAME
//        bottom rail z=4..8, top rail z=25..28, OPEN between (z=9..24)
//        side top edge at z=28 (seated 78)
//  - Corners: full height to z=33 (seated 83)
//  - Floor plate: z=4..6
// Seated mapping (base=50): add 50 to every z below.

TR_X = 304.8;
TR_Y = 101.6;
TR_Z = 33;
TR_wall = 3;        // side/end wall thickness
TR_endw = 3;        // short-end wall thickness
TR_botrail_z0 = 4;  TR_botrail_z1 = 8;     // long-side bottom rail
TR_toprail_z0 = 25; TR_toprail_z1 = 28;    // long-side top rail (side top edge=28)
TR_floor_z0 = 4;    TR_floor_z1 = 6;
TR_corner = 6;      // corner post footprint (x & y) kept full height

module top_ref(base=50, col="#90A4AE", alpha=1.0) {
    color(col, alpha)
    translate([0,0,base])
    union() {
        // ---- floor plate ----
        translate([TR_endw, TR_wall, TR_floor_z0])
            cube([TR_X-2*TR_endw, TR_Y-2*TR_wall, TR_floor_z1-TR_floor_z0]);
        // ---- two short END walls: full height ----
        cube([TR_endw, TR_Y, TR_Z]);
        translate([TR_X-TR_endw,0,0]) cube([TR_endw, TR_Y, TR_Z]);
        // ---- long-side OPEN FRAMES (front & back) ----
        for (yy=[0, TR_Y-TR_wall]) {
            // bottom rail
            translate([0, yy, TR_botrail_z0]) cube([TR_X, TR_wall, TR_botrail_z1-TR_botrail_z0]);
            // top rail (side top edge)
            translate([0, yy, TR_toprail_z0]) cube([TR_X, TR_wall, TR_toprail_z1-TR_toprail_z0]);
        }
        // ---- corner posts full height (tie frames together, reach z=33) ----
        for (xx=[0, TR_X-TR_corner], yy=[0, TR_Y-TR_corner])
            translate([xx,yy,0]) cube([TR_corner, TR_corner, TR_Z]);
    }
}

// Convenience constants a design can reference (seated, base=50):
//   END-wall top edge:        z = 50+33 = 83  (over the short ends -> strong clamp)
//   Long-side top rail top:   z = 50+28 = 78  (hook over / under along front)
//   Long-side open slot:      z = 50+9 .. 50+24 = 59..74 (reach a tongue in anywhere)
//   Corner top:               z = 83
