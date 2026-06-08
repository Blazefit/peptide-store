// 04_twintab.scad — Twin-Tab Heavy-Duty Slide-Bolt
// Two wide capture tabs (front + end clamps) driven by one push-bar.
// Tabs are 80mm wide each, giving large surface contact.
// Also includes end-wall capture (same as 02_endclamp) for a 3-point lock.
// Unlocked: all hardware at y<0 or x<0 / x>T_X.
// Locking operation: push bar +Y (8mm travel).

show  = "all";  // [all, new, top]
lock  = 1;      // 0=unlocked  1=locked

include <../top_ref.scad>

T_X = 304.8;  T_Y = 101.6;  T_Z = 50;  T_W = 3;

BAR_TRAVEL = 10;   // slightly more travel for positive feel
BAR_D      = 10;
BAR_H      = 8;
BAR_Z0     = T_Z - BAR_H - 2;  // z=40

bar_front  = lock ? 0.0 : -BAR_TRAVEL;
bar_rear   = bar_front - BAR_D;

// Two large front caps
CAP_Z0  = 78.5;
CAP_Z1  = 82.0;    // 3.5mm tall for more material
CAP_TH  = T_W;
CAP_W   = 80;
CAP_CX  = [85, 215];   // two large tabs, symmetric

ARM_Y   = bar_front - 0.5;
ARM_TH  = 0.5;
ARM_Z0  = BAR_Z0 + BAR_H;
ARM_Z1  = 78.4;

// End clamps (same as 02)
EC_LIP_Z0 = 83.1;
EC_LIP_Z1 = 86.0;
EC_LIP_Y  = T_W;

// Housing
HSG_Z0   = BAR_Z0 - 3;
HSG_H    = BAR_H + 6;

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
        // Two finger openings
        for (cx = CAP_CX) {
            translate([cx - 22, -1, BAR_Z0 - 1])
                cube([44, 6, BAR_H + 2]);
        }
    }
}

module sliding_bar() {
    color("#C62828") {
        // Bar body
        translate([0, bar_rear, BAR_Z0])
            cube([T_X, BAR_D, BAR_H]);

        // Two large front caps
        for (cx = CAP_CX) {
            tx0 = max(cx - CAP_W/2, 7.0);
            tx1 = min(cx + CAP_W/2, 297.8);
            tw  = tx1 - tx0;
            if (tw > 5) {
                translate([tx0, bar_front, CAP_Z0])
                    cube([tw, CAP_TH, CAP_Z1 - CAP_Z0]);
                translate([tx0, ARM_Y, ARM_Z0])
                    cube([tw, ARM_TH, ARM_Z1 - ARM_Z0]);
                translate([tx0, ARM_Y, CAP_Z0])
                    cube([tw, bar_front - ARM_Y + CAP_TH, 0.8]);
            }
        }

        // End clamps (straddle left and right end walls, above z=83)
        // Left end wall x=0..3
        translate([-1.0, bar_front, EC_LIP_Z0])
            cube([5.5, EC_LIP_Y, EC_LIP_Z1 - EC_LIP_Z0]);
        translate([0.5, ARM_Y, ARM_Z0])
            cube([4.0, ARM_TH, EC_LIP_Z0 - ARM_Z0]);
        translate([0.5, ARM_Y, EC_LIP_Z0])
            cube([4.0, bar_front - ARM_Y + EC_LIP_Y, 0.8]);

        // Right end wall x=301.8..304.8
        translate([T_X - 4.5, bar_front, EC_LIP_Z0])
            cube([5.5, EC_LIP_Y, EC_LIP_Z1 - EC_LIP_Z0]);
        translate([T_X - 4.5, ARM_Y, ARM_Z0])
            cube([4.0, ARM_TH, EC_LIP_Z0 - ARM_Z0]);
        translate([T_X - 4.5, ARM_Y, EC_LIP_Z0])
            cube([4.0, bar_front - ARM_Y + EC_LIP_Y, 0.8]);

        // Large finger tabs with ergonomic shape
        for (cx = CAP_CX) {
            translate([cx - 18, bar_rear - 8, BAR_Z0])
                cube([36, 8, BAR_H]);
        }

        // Detent nubs (strong, 2 positions)
        for (cx = CAP_CX) {
            translate([cx, bar_rear + BAR_D/2, BAR_Z0 + BAR_H])
                cylinder(r=2.0, h=1.2, $fn=16);
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
