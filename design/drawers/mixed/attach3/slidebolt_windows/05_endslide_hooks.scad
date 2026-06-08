// 05_endslide_hooks.scad
// Variant 5: End-operated slide bolts – one bolt per short end, push from end face.
// Two bolts slide in X axis (one from each end), each with 1 tongue for the nearest window.
// Center window: driven by a small push-tab on the front face.
// Good option if front face is crowded or needs to match a specific aesthetic.
// Three bolts operate independently but can be pushed together with one sweep.
//
// SHORT-END access: user pushes left bolt (x=0 face) inward → right,
//                   right bolt (x=305 face) inward → left.
// Center tab: push from front face (+Y direction).
//
// lock=0: all bolts retracted, tongues outside footprint
// lock=1: all bolts engaged, tongues in respective front windows

lock = 1;
$fn = 48;

TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;

WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;
WIN_XS = [TW*1/4, TW*2/4, TW*3/4];

TONGUE_W = 30; TONGUE_H = 10; CL = 1.2;

// End bolt parameters
// Bolt slides in X: from outside the tray footprint inward
// Housing on exterior of front face at each end
BOLT_W = 20;  // X length of bolt body
BOLT_H = WIN_H + 4;  BOLT_D = 14;  // Z and Y of bolt body
BOLT_Z0 = WIN_Z_BOT - 2;

TONGUE_REACH = 8;   // tongue reach in -Y exterior when unlocked
TONGUE_ENG   = 6;   // tongue Y engagement into window when locked
TRAVEL_X     = WIN_XS[0] - TONGUE_W/2 - WALL - 4;  // ~40mm – how far bolt slides in X

// Center push tab
CTR_W = 40; CTR_H = WIN_H + 4; CTR_D = 12;
CTR_TRAVEL = TONGUE_REACH + TONGUE_ENG;  // 14mm

// Rear posts
RPOST_W = 28; RPOST_H = 14; RPOST_D = WALL;

// End hooks (doubled up since end bolts also grip)
LIP_T = WALL; LIP_W = 28; LIP_H = 8;

COL_NEW  = "#1565C0"; COL_TOP = "#90A4AE"; COL_BOLT = "#F9A825";

module new_tray() {
    color(COL_NEW) union() {
        difference() {
            cube([TW, TD, TH_NEW]);
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // tongue slots in front wall for all 3 windows
            for (wx = WIN_XS)
                translate([wx - TONGUE_W/2 - CL, -0.1, WIN_Z_BOT + CL])
                    cube([TONGUE_W + 2*CL, WALL + 0.2, TONGUE_H]);
            // left end bolt channel (on exterior of front face, open at x=0)
            translate([-0.1, -BOLT_D - 1, BOLT_Z0 - 0.5])
                cube([TRAVEL_X + BOLT_W + 0.2, BOLT_D, BOLT_H + 1]);
            // right end bolt channel (open at x=305)
            translate([TW - TRAVEL_X - BOLT_W - 0.1, -BOLT_D - 1, BOLT_Z0 - 0.5])
                cube([TRAVEL_X + BOLT_W + 0.2, BOLT_D, BOLT_H + 1]);
            // center tab slot (open at y=0 face)
            translate([TW/2 - CTR_W/2 - CL, -CTR_D - 1, BOLT_Z0 - 0.5])
                cube([CTR_W + 2*CL, CTR_D + 0.5, CTR_H + 1]);
        }

        // Housing flanges for end bolts (left)
        translate([0, -BOLT_D - 4, BOLT_Z0 + BOLT_H])
            cube([TRAVEL_X + BOLT_W, BOLT_D + 2, WALL]);
        translate([0, -BOLT_D - 4, BOLT_Z0 - WALL])
            cube([TRAVEL_X + BOLT_W, BOLT_D + 2, WALL]);

        // Housing flanges for end bolts (right)
        translate([TW - TRAVEL_X - BOLT_W, -BOLT_D - 4, BOLT_Z0 + BOLT_H])
            cube([TRAVEL_X + BOLT_W, BOLT_D + 2, WALL]);
        translate([TW - TRAVEL_X - BOLT_W, -BOLT_D - 4, BOLT_Z0 - WALL])
            cube([TRAVEL_X + BOLT_W, BOLT_D + 2, WALL]);

        // Center tab flanges
        translate([TW/2 - CTR_W/2 - 1, -CTR_D - 4, BOLT_Z0 + BOLT_H])
            cube([CTR_W + 2, CTR_D + 2, WALL]);
        translate([TW/2 - CTR_W/2 - 1, -CTR_D - 4, BOLT_Z0 - WALL])
            cube([CTR_W + 2, CTR_D + 2, WALL]);

        // Rear capture posts
        for (wx = WIN_XS)
            translate([wx - RPOST_W/2, TD - WALL - RPOST_D, TOP_BASE_Z])
                cube([RPOST_W, RPOST_D, RPOST_H]);

        // End rim-lip hooks
        translate([0, TD/2 - LIP_W/2, TOP_BASE_Z])
            cube([LIP_T, LIP_W, LIP_H]);
        translate([TW - LIP_T, TD/2 - LIP_W/2, TOP_BASE_Z])
            cube([LIP_T, LIP_W, LIP_H]);
    }
}

module top_tray() {
    color(COL_TOP) translate([0, 0, TOP_BASE_Z]) difference() {
        cube([TW, TD, TH_TOP]);
        translate([WALL, WALL, WALL]) cube([TW-2*WALL, TD-2*WALL, TH_TOP]);
        for (wx = WIN_XS)
            translate([wx-WIN_W/2, -0.1, WIN_Z_BOT-TOP_BASE_Z]) cube([WIN_W, WALL+0.2, WIN_H]);
        for (wx = WIN_XS)
            translate([wx-WIN_W/2, TD-WALL-0.1, WIN_Z_BOT-TOP_BASE_Z]) cube([WIN_W, WALL+0.2, WIN_H]);
    }
}

module left_bolt(off_x) {
    color(COL_BOLT) translate([off_x, 0, 0]) {
        // bolt body
        translate([0, -BOLT_D - 0.5, BOLT_Z0])
            cube([BOLT_W, BOLT_D, BOLT_H]);
        // tongue
        translate([WIN_XS[0] - TONGUE_W/2, -TONGUE_REACH, WIN_Z_BOT + CL])
            cube([TONGUE_W, TONGUE_REACH + TONGUE_ENG + WALL, TONGUE_H]);
        // end grip tab (at x=0 face, sticks out in -X)
        translate([-8, -BOLT_D/2 - 5, BOLT_Z0 + 2])
            cube([8, 10, BOLT_H - 4]);
    }
}

module right_bolt(off_x) {
    color(COL_BOLT) translate([off_x, 0, 0]) {
        translate([TW - BOLT_W, -BOLT_D - 0.5, BOLT_Z0])
            cube([BOLT_W, BOLT_D, BOLT_H]);
        translate([WIN_XS[2] - TONGUE_W/2, -TONGUE_REACH, WIN_Z_BOT + CL])
            cube([TONGUE_W, TONGUE_REACH + TONGUE_ENG + WALL, TONGUE_H]);
        translate([TW, -BOLT_D/2 - 5, BOLT_Z0 + 2])
            cube([8, 10, BOLT_H - 4]);
    }
}

module center_tab(off_y) {
    color(COL_BOLT) translate([0, off_y, 0]) {
        translate([TW/2 - CTR_W/2, -CTR_D - 0.5, BOLT_Z0])
            cube([CTR_W, CTR_D, CTR_H]);
        translate([WIN_XS[1] - TONGUE_W/2, -TONGUE_REACH, WIN_Z_BOT + CL])
            cube([TONGUE_W, TONGUE_REACH + TONGUE_ENG + WALL, TONGUE_H]);
        translate([TW/2 - 18, -CTR_D - 9, BOLT_Z0 + 2])
            cube([36, 9, CTR_H - 4]);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
l_off  = (lock == 1) ? TRAVEL_X  : 0;
r_off  = (lock == 1) ? -TRAVEL_X : 0;
c_off  = (lock == 1) ? CTR_TRAVEL : 0;

new_tray();
top_tray();
left_bolt(l_off);
right_bolt(r_off);
center_tab(c_off);
