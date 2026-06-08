// 03_sliderail.scad — Continuous Slide-Rail Lock
// A single continuous rail slider (full 304.8mm span) with a distributed
// tongue shelf.  The shelf runs z=78.5..81.5 the full interior width
// (x=7..297.8) at y=0..3 when locked.  Unlocked, it retracts to y=-8..-5.
// Provides maximum capture area (>10000mm³) and maximum front rigidity.
//
// Key difference from 01: tongue is one continuous shelf (not 4 discrete caps),
// producing a strong, even clamping line along the entire front rail.
// Housing is shorter (just behind bar) for a lower-profile appearance.

show  = "all";  // [all, new, top]
lock  = 1;      // 0=unlocked  1=locked

include <../top_ref.scad>

T_X = 304.8;  T_Y = 101.6;  T_Z = 50;  T_W = 3;

BAR_TRAVEL = 8;
BAR_D      = 8;
BAR_H      = 6;
BAR_Z0     = T_Z - BAR_H - 2;  // z=42

bar_front  = lock ? 0.0 : -BAR_TRAVEL;
bar_rear   = bar_front - BAR_D;

// Continuous shelf (full-width tongue)
SHELF_Z0  = 78.5;
SHELF_Z1  = 81.5;
SHELF_TH  = T_W;      // 3mm in Y
SHELF_X0  = 7.0;      // avoid left corner posts
SHELF_X1  = 297.8;    // avoid right corner posts

// Thin vertical arm: stays at y<0 even when locked
ARM_TH  = 0.4;
ARM_Y   = bar_front - 0.5;

// Housing: y = -(BAR_D + BAR_TRAVEL) .. 0
HSG_Z0  = BAR_Z0 - 2;
HSG_H   = BAR_H + 4;

// Three handle/detent positions along the bar
HANDLE_CX = [60, 152, 242];
HANDLE_W  = 30;
HANDLE_D  = 6;

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
        // Three finger openings
        for (cx = HANDLE_CX) {
            translate([cx - HANDLE_W/2, -1, BAR_Z0 - 1])
                cube([HANDLE_W, 5, BAR_H + 2]);
        }
    }
}

module sliding_bar() {
    ARM_Z0 = BAR_Z0 + BAR_H;
    ARM_Z1 = 78.4;

    color("#C62828") {
        // Bar body
        translate([0, bar_rear, BAR_Z0])
            cube([T_X, BAR_D, BAR_H]);

        // Continuous shelf above front top rail
        translate([SHELF_X0, bar_front, SHELF_Z0])
            cube([SHELF_X1 - SHELF_X0, SHELF_TH, SHELF_Z1 - SHELF_Z0]);

        // Thin arm connecting bar top to shelf base (stays at y<0)
        translate([SHELF_X0, ARM_Y, ARM_Z0])
            cube([SHELF_X1 - SHELF_X0, ARM_TH, ARM_Z1 - ARM_Z0]);

        // Horizontal bridge connecting arm top to shelf bottom-rear
        translate([SHELF_X0, ARM_Y, SHELF_Z0])
            cube([SHELF_X1 - SHELF_X0, bar_front - ARM_Y + SHELF_TH, 0.8]);

        // Grip tabs at three positions
        for (cx = HANDLE_CX) {
            translate([cx - HANDLE_W/2, bar_rear - HANDLE_D, BAR_Z0])
                cube([HANDLE_W, HANDLE_D, BAR_H]);
        }

        // Detent nubs (top of bar at handle positions)
        for (cx = HANDLE_CX) {
            translate([cx, bar_rear + BAR_D/2, BAR_Z0 + BAR_H])
                cylinder(r=1.6, h=1.0, $fn=16);
        }
    }
}

module new_assembly(lk) {
    new_tray();
    housing_fixed();
    sliding_bar();
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
