// 06_flush_guide_posts.scad
// Variant 6: Front bar with finger-ring grip + CONTINUOUS rear guide wall (best back capture)
// Combines the best features:
//   - Push-in bar (+Y) with ergonomic open-loop finger ring for push/pull
//   - Continuous rear guide wall (full-width, within y=99..102) for back capture
//   - Three individual post shafts inside the rear guide wall for stiff alignment
//   - Short-end rim lips for corner hold
//   - Dual detent positions (locked + unlocked click)
//   - Wide 18mm travel for confident engagement
//   - Tongue clearance: 7.5mm X, 3mm Z each side inside 45×16 window
//
// lock=0: bar retracted, tongues at y<0 exterior, drop path clear
// lock=1: bar pushed in, tongues engage all 3 front windows

lock = 1;
$fn = 48;

TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;

WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;   // 56
WIN_Z_TOP = WIN_Z_CTR + WIN_H/2;   // 72
WIN_XS = [TW*1/4, TW*2/4, TW*3/4];

TONGUE_W = 30; TONGUE_H = 10; CL = 1.2;

// Bar
BAR_W = TW - 2*WALL - 4;
BAR_H = WIN_H + 6;
BAR_D = 16;
BAR_Z0 = WIN_Z_BOT - 3;

// Travel
TONGUE_REACH  = 10;
TONGUE_ENGAGE = 8;
TRAVEL        = TONGUE_REACH + TONGUE_ENGAGE;

// Finger ring tab
RING_W = 60; RING_H = 16; RING_T = 3.5;

// Detent
DET_R = 2.2;

// Rear continuous guide wall
RGW_T = WALL;   // Y thickness = 3mm, occupies y=99..102 (within footprint, flush)
RGW_H = WIN_H + 4;
RGW_Z = WIN_Z_BOT - 2;

// Stiffening posts inside rear guide wall
RPOST_W = 26; RPOST_H = WIN_H + 2;
RPOST_D = WALL;  // same thickness as guide wall

// End lips
LIP_T = WALL; LIP_W = 32; LIP_H = 8;

COL_NEW  = "#1565C0"; COL_TOP = "#90A4AE"; COL_BOLT = "#C62828";

module new_tray() {
    color(COL_NEW) union() {
        difference() {
            cube([TW, TD, TH_NEW]);
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // tongue pass-through slots in front wall
            for (wx = WIN_XS)
                translate([wx - TONGUE_W/2 - CL, -0.1, WIN_Z_BOT + CL])
                    cube([TONGUE_W + 2*CL, WALL + 0.2, TONGUE_H]);
            // bar housing channel on exterior
            translate([WALL+2, -BAR_D - 1, BAR_Z0 - 1])
                cube([BAR_W, BAR_D + 0.5, BAR_H + 2]);
            // detent sockets
            translate([TW/2, -BAR_D/2 - 0.5, BAR_Z0 + BAR_H/2 + 2])
                sphere(r=DET_R);
            translate([TW/2, -BAR_D/2 - 0.5 - TRAVEL, BAR_Z0 + BAR_H/2 + 2])
                sphere(r=DET_R);
        }

        // Housing flanges (top + bottom captive rails)
        translate([WALL+2, -BAR_D - 4, BAR_Z0 + BAR_H + 1])
            cube([BAR_W, BAR_D + 2, WALL]);
        translate([WALL+2, -BAR_D - 4, BAR_Z0 - WALL - 1])
            cube([BAR_W, BAR_D + 2, WALL]);

        // End stops (keep bar captive in X)
        translate([WALL, -BAR_D - 4, BAR_Z0 - WALL - 1])
            cube([2, BAR_D + 2, BAR_H + 2*WALL + 2]);
        translate([TW - WALL - 2, -BAR_D - 4, BAR_Z0 - WALL - 1])
            cube([2, BAR_D + 2, BAR_H + 2*WALL + 2]);

        // Rear continuous guide wall (flush with y=102 back face)
        translate([WALL, TD - RGW_T, RGW_Z])
            cube([TW - 2*WALL, RGW_T, RGW_H]);

        // Individual alignment posts (inside rear guide wall, stiffen engagement)
        for (wx = WIN_XS)
            translate([wx - RPOST_W/2, TD - RPOST_D, RGW_Z])
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

module push_bar(off_y) {
    color(COL_BOLT) translate([0, off_y, 0]) {
        // main bar
        translate([WALL+2 + 0.6, -BAR_D - 0.6, BAR_Z0])
            cube([BAR_W - 1.2, BAR_D - 0.2, BAR_H]);
        // tongues
        for (wx = WIN_XS)
            translate([wx - TONGUE_W/2, -TONGUE_REACH, WIN_Z_BOT + CL])
                cube([TONGUE_W, TONGUE_REACH + TONGUE_ENGAGE + WALL, TONGUE_H]);
        // open-loop finger ring tab
        translate([TW/2 - RING_W/2, -BAR_D - RING_H - 1.6, BAR_Z0 + 1])
        difference() {
            cube([RING_W, RING_H, BAR_H - 2]);
            translate([RING_T, RING_T, -0.1])
                cube([RING_W - 2*RING_T, RING_H - 2*RING_T, BAR_H]);
        }
        // detent nub
        translate([TW/2, -BAR_D/2 - 0.5, BAR_Z0 + BAR_H/2 + 2])
            sphere(r=DET_R * 0.82);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
bar_y = (lock == 1) ? TRAVEL : 0;

new_tray();
top_tray();
push_bar(bar_y);
