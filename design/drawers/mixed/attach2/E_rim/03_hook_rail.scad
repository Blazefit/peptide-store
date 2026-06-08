// 03_hook_rail.scad
// RETROFIT: Full-length continuous hook rail along BOTH long sides of the NEW tray.
// Each rail is an upright plate rising from the new tray's outer wall, running the
// full 305 mm length.  At the top, a horizontal flange hooks INWARD over the top rim.
// Lightening slots cut through the vertical plate to save material and allow flex.
// Engagement: slide or press top tray straight down — rail flanges hook over rim.
// Release: flex rail outward at mid-span (both sides simultaneously), lift.
// TOP TRAY FIXED — NO geometry added to it.
//
// LEFT: ENGAGED  |  RIGHT: EXPLODED

TW = 305; TD = 102; TH = 33;
NW = 305; ND = 102; NH = 50;
wall = 3;

// rail geometry
rail_t   = 3.0;  // rail wall thickness
rail_h   = TH + 6; // rail arm height from z=NH (clears rim, lip wraps over)
flange   = 7;    // horizontal flange width over rim
flange_t = 3.5;  // flange thickness
gap      = 0.4;  // clearance between rail inner face and top tray outer face

// lightening slots
slot_w   = 18;
slot_h   = rail_h - flange_t - 6;  // leave solid strip at top and base
slot_gap = 28;   // period
slot_y0  = 3;    // from base

C_new  = "#1565C0";
C_top  = "#90A4AE";
C_clip = "#2E7D32";  // forest green — rails

sep = NW + 40;

module new_tray_body() {
    color(C_new)
    difference() {
        cube([NW, ND, NH]);
        translate([wall, wall, wall])
            cube([NW-2*wall, ND-2*wall, NH]);
    }
}

module top_tray_body(dz=0) {
    color(C_top)
    translate([0, 0, NH + dz])
    difference() {
        cube([TW, TD, TH]);
        translate([wall, wall, 0])
            cube([TW-2*wall, TD-2*wall, TH-wall]);
    }
}

// One full-length rail for the front face (y=0 outer face).
// Rail placed so inner face at y = -gap, outer face at y = -(gap + rail_t).
// Origin at (0, -(gap+rail_t), NH) — bottom-left of rail.
module rail_front() {
    color(C_clip)
    difference() {
        union() {
            // vertical plate
            cube([NW, rail_t, rail_h]);
            // top flange curling inward (+Y)
            translate([0, 0, rail_h - flange_t])
                cube([NW, rail_t + flange, flange_t]);
        }
        // lightening slots
        for (sx = [slot_gap/2 : slot_gap : NW - slot_gap/2]) {
            translate([sx - slot_w/2, -0.1, slot_y0])
                cube([slot_w, rail_t + 0.2, slot_h]);
        }
    }
}

module all_rails() {
    // front rail (y=0 face): inner face at y=-gap
    translate([0, -(rail_t + gap), NH]) rail_front();
    // back rail (y=ND face): mirror in Y, shift to ND+gap
    translate([NW, ND + gap, NH]) mirror([1,0,0]) mirror([0,1,0]) rail_front();
}

// ENGAGED
translate([0,0,0]) {
    new_tray_body();
    all_rails();
    top_tray_body(0);
}

// EXPLODED
translate([sep,0,0]) {
    new_tray_body();
    all_rails();
    top_tray_body(40);
}
