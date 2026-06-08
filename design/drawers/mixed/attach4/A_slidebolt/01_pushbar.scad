// 01_pushbar.scad — Multipoint Push-Bar Slide-Bolt
// Place-then-secure: lower top tray straight down (loose), then push the
// front bar +Y to drive tongue caps above the front top-rail, blocking lift.
//
// Capture geometry (all Z values = seated, base=50):
//   Top tray front top-rail:  y=0..3, z=75..78 (solid)
//   Empty space above rail:   y=0..3, z=78..83 (open, except corners x<7 & x>297.8)
//   Tongue cap: y=0..3, z=78.5..81.5 → 0.5mm clear at rest, captures +2mm lift
//
// Y-motion (bar slides +Y to lock):
//   Bar occupies y = bar_rear .. bar_front
//   UNLOCKED: bar_front = -8,  bar_rear = -16
//   LOCKED:   bar_front =  0,  bar_rear = -8
//   Cap is at y = bar_front .. bar_front+3  (0..3 when locked, -8..-5 when unlocked)
//   Arm rises at y = bar_front-0.2 (just outside front face, clear of top-tray wall)

show  = "all";   // [all, new, top]
lock  = 1;       // 0=unlocked  1=locked

include <../top_ref.scad>

T_X = 304.8;  T_Y = 101.6;  T_Z = 50;  T_W = 3;

BAR_TRAVEL = 8;
BAR_D      = 8;
BAR_H      = 7;
BAR_CLR    = 0.3;
BAR_Z0     = T_Z - BAR_H - 2;   // z=41

// Bar front/rear Y based on lock
bar_front = lock ? 0.0 : -BAR_TRAVEL;
bar_rear  = bar_front - BAR_D;

// Arm Y: just in front of bar front face but behind tray-wall exterior
// Arm is at y = bar_front - 0.5 .. bar_front + 0.1 (thin, y<0 when unlocked, y<0.1 when locked)
// Actually: arm attaches to bar front face and rises vertically
// To avoid overlapping with top tray walls, arm must be at y < 0
// Even when locked (bar_front=0), arm at y = -0.4..0 is just outside front wall of top tray
ARM_Y0     = bar_front - 0.5;   // arm rear face
ARM_TH_Y   = 0.4;               // arm thickness in Y (stays at y<0 even locked)
ARM_Z_LOW  = BAR_Z0 + BAR_H;   // z=48
ARM_Z_HIGH = 78.4;              // just below cap base, keeping arm out of top rail

// Cap (overhangs into y=0..3 only when locked)
CAP_Z0   = 78.5;   // 0.5mm above top rail top z=78
CAP_Z1   = 81.5;   // 3mm tall
CAP_TH   = T_W;    // 3mm in Y (y=0..3 when locked)
CAP_W    = 56;     // each cap width in X

// Four caps, avoiding corner posts (x<7 and x>297.8)
CAP_CX   = [55, 115, 185, 245];

// Housing: y = -(BAR_D + BAR_TRAVEL) .. 0 = -16..0
HSG_Y0   = -(BAR_D + BAR_TRAVEL);
HSG_Z0   = BAR_Z0 - 3;
HSG_H    = BAR_H + 6;

// Back passive rail (lateral only, no lift-block)
// Sits in back open slot y=98.6..101.6, z=58..75 (empty)
BKRL_TH  = 2.0;
BKRL_Z0  = 61;
BKRL_Z1  = 73;
BKRL_W   = 26;
BKRL_CX  = [55, 152, 245];

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
        // Main housing block
        translate([0, HSG_Y0, HSG_Z0])
            cube([T_X, -HSG_Y0, HSG_H]);
        // Bar channel (full travel range, print-in-place clearance)
        translate([-1, -(BAR_D + BAR_TRAVEL) - BAR_CLR, BAR_Z0 - BAR_CLR])
            cube([T_X+2, BAR_D + BAR_TRAVEL + 2*BAR_CLR, BAR_H + 2*BAR_CLR]);
        // Finger opening through front face
        translate([T_X/2 - 20, -1, BAR_Z0 - 1])
            cube([40, 5, BAR_H + 2]);
    }
}

module sliding_bar() {
    color("#C62828") {
        // ── Bar body ──
        translate([0, bar_rear, BAR_Z0])
            cube([T_X, BAR_D, BAR_H]);

        // ── Tongue caps above top-rail ──
        for (cx = CAP_CX) {
            tx0 = max(cx - CAP_W/2, 7.0);
            tx1 = min(cx + CAP_W/2, 297.8);
            tw  = tx1 - tx0;
            if (tw > 5) {
                // Cap: extends from y=bar_front to y=bar_front+CAP_TH
                translate([tx0, bar_front, CAP_Z0])
                    cube([tw, CAP_TH, CAP_Z1 - CAP_Z0]);
                // Arm: rises from bar top to cap base, stays at y<0
                translate([tx0, ARM_Y0, ARM_Z_LOW])
                    cube([tw, ARM_TH_Y, ARM_Z_HIGH - ARM_Z_LOW]);
                // Bridge: horizontal piece connecting arm top to cap bottom-rear
                translate([tx0, ARM_Y0, CAP_Z0])
                    cube([tw, bar_front - ARM_Y0 + CAP_TH, 0.8]);
            }
        }

        // ── Finger tab (pull tab for unlocking) ──
        translate([T_X/2 - 14, bar_rear - 5, BAR_Z0])
            cube([28, 5, BAR_H]);

        // ── Detent nub ──
        translate([T_X/2, bar_rear + BAR_D/2, BAR_Z0 + BAR_H])
            cylinder(r=1.8, h=1.0, $fn=16);
    }
}

module back_passive_rail() {
    // Passive rail sits below the back bottom rail (z<54) for lateral capture.
    // At y=T_Y-BKRL_TH, z=50..53: below bottom rail of back wall → no overlap at rest
    // or any lift (bottom rail only moves UP on lift).
    color("#F9A825")
    for (cx = BKRL_CX) {
        translate([cx - BKRL_W/2, T_Y - BKRL_TH, 50.2])
            cube([BKRL_W, BKRL_TH, 3.0]);
    }
}

module new_assembly(lk) {
    new_tray();
    housing_fixed();
    sliding_bar();
    back_passive_rail();
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
