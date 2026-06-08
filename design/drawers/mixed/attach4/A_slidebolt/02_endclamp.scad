// 02_endclamp.scad — End-Wall Clamp + Front Tongue Bar
// Variant with primary capture on the SHORT END WALLS (solid to z=83) AND
// secondary front tongue bar.  A single horizontal push (±X) on the bar
// simultaneously drives end clamps over the end-wall top edges and front
// tongues above the front top-rail.  Door side flush throughout.
//
// End walls (seated): x=0..3 (left) and x=301.8..304.8 (right), z=50..83 solid.
// End clamp: thin clip that slides in +X (left side) or -X (right side) to
// sit above end-wall top at z=83.5..86.5 — catches if top tray tries to lift.
//
// Front tongues: same capture approach as 01_pushbar — caps at z=78.5..81.5,
// y=0..3 when locked.

show  = "all";  // [all, new, top]
lock  = 1;      // 0=unlocked  1=locked

include <../top_ref.scad>

T_X = 304.8;  T_Y = 101.6;  T_Z = 50;  T_W = 3;

// ── Bar & travel ───────────────────────────────────────────────────────────
// Bar slides in +Y (push to lock) — same as 01 but narrower
BAR_TRAVEL = 8;
BAR_D      = 8;
BAR_H      = 7;
BAR_Z0     = T_Z - BAR_H - 2;   // z=41
bar_front  = lock ? 0.0 : -BAR_TRAVEL;
bar_rear   = bar_front - BAR_D;

HSG_Z0   = BAR_Z0 - 3;
HSG_H    = BAR_H + 6;

// ── Front tongue caps (primary front capture) ────────────────────────────
CAP_Z0  = 78.5;
CAP_Z1  = 81.5;
CAP_TH  = T_W;
CAP_W   = 50;
CAP_CX  = [70, 155, 230];   // 3 caps for this variant

ARM_Y0  = bar_front - 0.5;
ARM_TH  = 0.4;
ARM_Z0  = BAR_Z0 + BAR_H;
ARM_Z1  = 78.4;

// ── End-wall clamp geometry ───────────────────────────────────────────────
// Left end wall: x=0..3, z=50..83. Clamp rides on bar (bar slides +Y).
// Clamp lip: x = -1.5 .. 3.5 (straddles end wall top), z=83.1..85.5
// Clamp body: connects to bar, rises from bar top to z=84
//
// At locked (bar_front=0): clamp at y=0..4 (front of tray area)
// At unlocked (bar_front=-8): clamp at y=-8..-4 (retracted, clear of top tray)
//
// The clamp stays at a fixed X relative to the bar (no separate X motion here)
// Left clamp rides the leftmost part of the bar, right clamp the rightmost.
CLAMP_LIP_Z0   = 83.1;   // 0.1mm above end-wall top (z=83)
CLAMP_LIP_Z1   = 85.5;
CLAMP_LIP_XL   = -1.0;   // extends slightly past x=0 to straddle
CLAMP_LIP_XR   =  4.0;   // and slightly past x=3
CLAMP_LIP_Y    = 3.0;    // same as CAP_TH in Y
CLAMP_ARM_W    = 5.0;    // clamp arm width in X
CLAMP_ARM_TH   = 0.4;    // thin arm in Y (stays at y<0)
CLAMP_ARM_X_L  = 0.5;    // X position of left arm
CLAMP_ARM_X_R  = T_X - CLAMP_ARM_W - 0.5;

// Right end wall mirror
CLAMP_LIP_XR2  = T_X + 1.0;
CLAMP_LIP_XL2  = T_X - 4.0;

module new_tray() {
    color("#1565C0") {
        cube([T_X, T_W, T_Z]);
        translate([0, T_Y-T_W, 0]) cube([T_X, T_W, T_Z]);
        cube([T_W, T_Y, T_Z]);
        translate([T_X-T_W, 0, 0]) cube([T_W, T_Y, T_Z]);
        cube([T_X, T_Y, T_W]);
    }
}

module housing_fixed() {
    color("#F9A825")
    difference() {
        translate([0, -(BAR_D + BAR_TRAVEL), HSG_Z0])
            cube([T_X, BAR_D + BAR_TRAVEL, HSG_H]);
        // Bar channel
        translate([-1, -(BAR_D + BAR_TRAVEL) - 0.3, BAR_Z0 - 0.3])
            cube([T_X+2, BAR_D + BAR_TRAVEL + 0.6, BAR_H + 0.6]);
        // Finger opening
        translate([T_X/2 - 20, -1, BAR_Z0 - 1])
            cube([40, 5, BAR_H + 2]);
    }
}

module front_caps() {
    for (cx = CAP_CX) {
        tx0 = max(cx - CAP_W/2, 7.0);
        tx1 = min(cx + CAP_W/2, 297.8);
        tw  = tx1 - tx0;
        if (tw > 5) {
            translate([tx0, bar_front, CAP_Z0])
                cube([tw, CAP_TH, CAP_Z1 - CAP_Z0]);
            translate([tx0, ARM_Y0, ARM_Z0])
                cube([tw, ARM_TH, ARM_Z1 - ARM_Z0]);
            translate([tx0, ARM_Y0, CAP_Z0])
                cube([tw, bar_front - ARM_Y0 + CAP_TH, 0.8]);
        }
    }
}

module end_clamps() {
    // Clamp lip: at z=83.1..85.5, y=bar_front..bar_front+CLAMP_LIP_Y
    // Left clamp (over x=0..3 end wall)
    translate([CLAMP_LIP_XL, bar_front, CLAMP_LIP_Z0])
        cube([CLAMP_LIP_XR - CLAMP_LIP_XL, CLAMP_LIP_Y, CLAMP_LIP_Z1 - CLAMP_LIP_Z0]);
    // Left clamp arm (y < 0, rising from bar top)
    translate([CLAMP_ARM_X_L, ARM_Y0, ARM_Z0])
        cube([CLAMP_ARM_W, CLAMP_ARM_TH, CLAMP_LIP_Z0 - ARM_Z0]);
    // Left clamp horizontal bridge
    translate([CLAMP_ARM_X_L, ARM_Y0, CLAMP_LIP_Z0])
        cube([CLAMP_ARM_W, bar_front - ARM_Y0 + CLAMP_LIP_Y, 0.8]);

    // Right clamp (over x=301.8..304.8 end wall)
    translate([CLAMP_LIP_XL2, bar_front, CLAMP_LIP_Z0])
        cube([CLAMP_LIP_XR2 - CLAMP_LIP_XL2, CLAMP_LIP_Y, CLAMP_LIP_Z1 - CLAMP_LIP_Z0]);
    translate([CLAMP_ARM_X_R, ARM_Y0, ARM_Z0])
        cube([CLAMP_ARM_W, CLAMP_ARM_TH, CLAMP_LIP_Z0 - ARM_Z0]);
    translate([CLAMP_ARM_X_R, ARM_Y0, CLAMP_LIP_Z0])
        cube([CLAMP_ARM_W, bar_front - ARM_Y0 + CLAMP_LIP_Y, 0.8]);
}

module sliding_bar() {
    color("#C62828") {
        translate([0, bar_rear, BAR_Z0]) cube([T_X, BAR_D, BAR_H]);
        front_caps();
        end_clamps();
        // Finger tab
        translate([T_X/2 - 14, bar_rear - 5, BAR_Z0])
            cube([28, 5, BAR_H]);
        translate([T_X/2, bar_rear + BAR_D/2, BAR_Z0 + BAR_H])
            cylinder(r=1.8, h=1.0, $fn=16);
    }
}

module new_assembly(lk) {
    new_tray();
    housing_fixed();
    sliding_bar();
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
