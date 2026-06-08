// 01_twin_hooks.scad
// RETROFIT: Twin hook-over-rim fingers — 2 per long side (4 fingers total per side).
// Tall J-shaped arms rise from the NEW tray's outer wall, clear the top tray height,
// then curl inward with a flat lip that bears down on the top rim (z=83).
// TOP TRAY FIXED — NO geometry added to it. All clips integral to NEW tray.
//
// LEFT side: ENGAGED (top tray seated, lips over rim)
// RIGHT side: EXPLODED (top tray lifted 40 mm clear)

// ── master dims ─────────────────────────────────────────────────
TW = 305; TD = 102; TH = 33;   // top tray outer (FIXED)
NW = 305; ND = 102; NH = 50;   // new tray outer
wall = 3;

// ── hook geometry ───────────────────────────────────────────────
hk_w    = 20;    // finger width along X
hk_t    = 3.5;  // arm wall thickness
hk_h    = TH + 8; // arm height from z=NH upward (surpasses rim by 8 mm)
lip_ext = 7;     // lip horizontal reach over top rim
lip_t   = 4;     // lip vertical thickness
gap     = 0.4;   // clearance between hook arm inner face and top tray outer face

// x-positions of two hook pairs
x_pos_L = NW * 0.22;
x_pos_R = NW * 0.72;

// ── colours ─────────────────────────────────────────────────────
C_new  = "#1565C0";  // blue  — new tray
C_top  = "#90A4AE";  // grey  — top tray (fixed)
C_clip = "#E65100";  // deep orange — hook arms (on new tray)

sep = NW + 40;  // separation between engaged and exploded scenes

// ────────────────────────────────────────────────────────────────
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

// One J-hook finger.  Local origin at bottom of arm base.
// Arm rises in +Z, lip curls toward +Y (inward from front face).
module hook_finger_base() {
    color(C_clip) {
        // vertical arm
        cube([hk_w, hk_t, hk_h]);
        // rim lip at top — extends inward (+Y)
        translate([0, 0, hk_h - lip_t])
            cube([hk_w, hk_t + lip_ext, lip_t]);
    }
}

module hooks_on_new_tray() {
    for (xp = [x_pos_L, x_pos_R]) {
        // FRONT side (y=0): arm outer face at y = -gap, extends to y = -(hk_t+gap)
        translate([xp - hk_w/2, -(hk_t + gap), NH])
            hook_finger_base();

        // BACK side (y=ND): mirror front
        translate([xp - hk_w/2, ND + gap + hk_t, NH])
            mirror([0,1,0])
            hook_finger_base();
    }
}

// ── LEFT: Engaged ────────────────────────────────────────────────
translate([0, 0, 0]) {
    new_tray_body();
    hooks_on_new_tray();
    top_tray_body(0);
}

// ── RIGHT: Exploded (top tray lifted) ───────────────────────────
translate([sep, 0, 0]) {
    new_tray_body();
    hooks_on_new_tray();
    top_tray_body(40);   // top tray lifted 40 mm above engaged position
}
