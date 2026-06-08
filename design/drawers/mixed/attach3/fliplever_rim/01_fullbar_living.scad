// 01_fullbar_living.scad
// FLIP-LEVER / CAM-LATCH RIM CLAMP — Variant 1
// One full-length flip bar per long side, living hinge (thinned wall ~0.6mm).
// Hinge root on new tray outer wall at z≈46 (4mm below top face).
// Open (lock=0): bar lies outward/down at ~100° from vertical (below new tray rim).
// Locked (lock=1): bar flips UP-AND-IN, cam lip hooks over top tray rim (z=83).
// A small detent bump on the bar snaps into a pocket on the tray wall at locked pos.
// TOP TRAY: FIXED REFERENCE — zero geometry added.
//
// Usage: openscad -D 'lock=0' or -D 'lock=1'

lock = 0;  // 0=open/folded-out, 1=closed/clamped

// ── master dims ────────────────────────────────────────────────
TW = 305;  TD = 102;  TH = 33;   // top tray (FIXED)
NW = 305;  ND = 102;  NH = 50;   // new tray
wall = 3;

// rim geometry
rim_top_z = NH + TH;  // = 83

// ── bar geometry ───────────────────────────────────────────────
bar_len   = 260;   // full-length bar along X (centered)
bar_h     = 14;    // bar arm height (radial length from hinge)
bar_t     = 3.0;   // bar arm thickness
lhinge_t  = 0.6;   // living hinge thickness at root
lip_ext   = 5;     // cam lip horizontal reach over rim (inward)
lip_t     = 3.5;   // cam lip vertical thickness (hooks UNDER rim top)
lip_ramp  = 2;     // chamfer on leading edge of lip

// hinge pivot location on new tray outer wall
hinge_z   = NH - 4;   // z=46, just below new tray top

// clearance for top tray wall when bar is closed
tray_wall_gap = 0.6;   // gap between bar inner face and top tray outer wall

// open angle: bar tips outward-down from hinge (measured from +Z up axis, rotating outward)
ang_open   = 100;   // 100° = bar lies below horizontal, out of the way
ang_locked = -8;    // -8° = bar slightly past vertical inward → cam lip hooks over rim

bar_ang = lock ? ang_locked : ang_open;

// detent bump
det_r = 1.2;
det_h = 1.0;

// ── colours ────────────────────────────────────────────────────
C_new   = "#1565C0";
C_top   = "#90A4AE";
C_lever = "#EF6C00";

$fn = 48;

// ── modules ────────────────────────────────────────────────────
module new_tray() {
    color(C_new)
    difference() {
        cube([NW, ND, NH]);
        translate([wall, wall, wall])
            cube([NW-2*wall, ND-2*wall, NH]);
        // living-hinge thinned groove on front outer face (y=0 side)
        // groove is a shallow slot at z=hinge_z to create a flex point
        translate([(NW-bar_len)/2 - 2, -0.1, hinge_z - lhinge_t/2])
            cube([bar_len + 4, wall - lhinge_t + 0.1, lhinge_t]);
        // same on back face
        translate([(NW-bar_len)/2 - 2, ND - wall + lhinge_t - 0.1, hinge_z - lhinge_t/2])
            cube([bar_len + 4, wall - lhinge_t + 0.1, lhinge_t]);
        // detent socket at locked position — front face
        translate([NW/2, -0.1, hinge_z + bar_h - 2])
            rotate([-90,0,0])
            cylinder(r=det_r+0.15, h=det_h+0.1);
        translate([NW/2, ND - wall + lhinge_t, hinge_z + bar_h - 2])
            rotate([-90,0,0])
            cylinder(r=det_r+0.15, h=det_h+0.1);
    }
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

// One full-length flip bar.
// Hinge root at local origin. Bar arm goes in +Z when angle=0.
// lip curls inward (+Y for front, -Y for back).
// inward_sign: +1 = toward +Y (back side), -1 = toward -Y (front side)
module flip_bar(inward_sign) {
    color(C_lever)
    rotate([bar_ang * inward_sign, 0, 0])  // rotate about X axis
    union() {
        // bar arm shaft
        translate([0, 0, 0])
            cube([bar_len, bar_t, bar_h]);
        // cam lip at top — curls inward
        translate([0, bar_t * (inward_sign > 0 ? 1 : -1) * 0 - (inward_sign > 0 ? 0 : lip_ext),
                   bar_h - lip_t])
            difference() {
                cube([bar_len, lip_ext + bar_t, lip_t]);
                // leading-edge chamfer on lip
                translate([0, 0, lip_t])
                    rotate([45, 0, 0])
                    cube([bar_len, lip_ramp * 1.4, lip_ramp * 1.4]);
            }
        // detent bump at mid-length on the back face of bar (contacts tray wall when locked)
        translate([bar_len/2 - det_r, 0, bar_h - 2 - det_r])
            rotate([90, 0, 0])
            cylinder(r=det_r, h=det_h);
        // finger tab at far end
        translate([bar_len - 18, bar_t, bar_h * 0.3])
            cube([16, 6, bar_h * 0.5]);
    }
}

// Front face flip bar: pivot at y=0, rotates outward in -Y direction when open
module front_bar() {
    translate([(NW - bar_len)/2, lhinge_t, hinge_z])
        flip_bar(-1);
}

// Back face flip bar: pivot at y=ND, rotates outward in +Y direction when open
module back_bar() {
    translate([(NW - bar_len)/2, ND - lhinge_t - bar_t, hinge_z])
        flip_bar(1);
}

// ── scene ──────────────────────────────────────────────────────
new_tray();
top_tray();
front_bar();
back_bar();
