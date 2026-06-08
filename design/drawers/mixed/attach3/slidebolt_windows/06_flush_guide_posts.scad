// 06_flush_guide_posts.scad
// Variant 6: Front bar + back GUIDE WALL (flush) + extra rim lips
//
// Key refinement over 01-04:
//   • The back passive capture is a CONTINUOUS guide wall (not individual posts)
//     that is exactly flush with y=102 — the top tray's back windows lower onto
//     this wall which stays entirely within y=99..102 (behind the back wall inner face).
//   • Front: same push-in bar with 3 tongues as variant 04 but with smoother
//     T-slot and pull-tab shaped as a finger ring for easier one-hand operation.
//   • Two rim-lip hooks at each short end give positive Z retention at corners.
//   • Dual detents (locked + unlocked) in channel floor.
//   • Comprehensive clearances: 1mm on all faces of tongue inside window.
//
// lock=0: bar retracted (tongues behind front wall, top tray liftable)
// lock=1: bar in (tongues 3mm into front windows, back wall captured)

lock = 1;
$fn = 48;

// ── Reference dims ─────────────────────────────────────────────────────────
TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;
WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;
WIN_XS = [TW*1/4, TW*2/4, TW*3/4];

// ── Mechanism dims ─────────────────────────────────────────────────────────
CL = 1.0;         // print clearance all around tongue
TONGUE_W = 30;    TONGUE_H = 10;
TONGUE_L = WALL + 2; // tongue total Y length; 2mm protrudes into window past inner wall
TRAVEL = 10;      // +Y travel of bar from retracted to locked

// Bar body
BAR_W = TW - 2*WALL - 8;
BAR_H = TONGUE_H + 6;
BAR_D = 18;

// Channel (T-slot in new tray top, open at front y=0)
CH_W = BAR_W + 2*CL;
CH_H = BAR_H + 2*CL;
CH_D = BAR_D + TRAVEL + 4;
CH_X0 = WALL + 4;
CH_Z0 = TH_NEW - CH_H - 1;

// Finger ring (open rectangular pull tab)
RING_W = 40; RING_H = 14; RING_T = 3;

// Detent sockets
DET_R = 2.0;

// Back guide wall: continuous strip inside back wall, fills back window gaps
// Stays within y=99..102 (inside footprint, flush with y=102 back)
BGW_H = WIN_H + 4; // Z height of guide wall (spans window height + margin)
BGW_T = WALL;      // Y thickness (= back wall inner face to y=102)
BGW_Z = WIN_Z_BOT - 2;

// Rim lip hooks on short ends
LIP_T = WALL;
LIP_H = 6; LIP_W = 30;

COL_NEW  = "#1565C0"; COL_TOP = "#90A4AE"; COL_BOLT = "#C62828";

module new_tray() {
    color(COL_NEW) union() {
        difference() {
            cube([TW, TD, TH_NEW]);
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // front T-slot for bar
            translate([CH_X0, -0.1, CH_Z0])
                cube([CH_W, CH_D+0.1, CH_H]);
            // front wall tongue openings
            for (wx = WIN_XS)
                translate([wx - TONGUE_W/2 - CL, -0.1, WIN_Z_BOT + CL])
                    cube([TONGUE_W+2*CL, WALL+0.2, TONGUE_H]);
            // detent socket locked
            translate([TW/2, CH_D - TRAVEL + WALL - 1, TH_NEW - 1.5])
                sphere(r=DET_R);
            // detent socket unlocked
            translate([TW/2, CH_D - 2*TRAVEL + WALL - 1, TH_NEW - 1.5])
                sphere(r=DET_R);
        }

        // Back guide wall (flush with y=102, within footprint)
        // Sits between inner back wall face (y=99) and y=102
        translate([WALL, TD - WALL, BGW_Z])
            cube([TW - 2*WALL, BGW_T, BGW_H]);

        // Short-end rim lip hooks
        translate([0, TD/2 - LIP_W/2, TH_NEW])
            cube([LIP_T, LIP_W, LIP_H]);
        translate([TW-LIP_T, TD/2 - LIP_W/2, TH_NEW])
            cube([LIP_T, LIP_W, LIP_H]);
    }
}

module top_tray() {
    color(COL_TOP) translate([0,0,TOP_BASE_Z]) difference() {
        cube([TW, TD, TH_TOP]);
        translate([WALL, WALL, WALL]) cube([TW-2*WALL, TD-2*WALL, TH_TOP]);
        for (wx = WIN_XS)
            translate([wx-WIN_W/2, -0.1, WIN_Z_BOT-TOP_BASE_Z]) cube([WIN_W, WALL+0.2, WIN_H]);
        for (wx = WIN_XS)
            translate([wx-WIN_W/2, TD-WALL-0.1, WIN_Z_BOT-TOP_BASE_Z]) cube([WIN_W, WALL+0.2, WIN_H]);
    }
}

module slide_bar(off_y) {
    color(COL_BOLT)
    translate([0, off_y, 0]) {
        // bar body
        translate([CH_X0+CL, WALL, CH_Z0+CL])
            cube([CH_W-2*CL, BAR_D, CH_H-2*CL]);
        // tongues
        for (wx = WIN_XS)
            translate([wx-TONGUE_W/2, WALL-TONGUE_L, WIN_Z_BOT+CL])
                cube([TONGUE_W, TONGUE_L+BAR_D, TONGUE_H]);
        // finger ring pull tab at center (open loop)
        translate([TW/2 - RING_W/2, WALL - TONGUE_L - RING_H - 1, WIN_Z_BOT - 2])
        difference() {
            cube([RING_W, RING_H, TONGUE_H + 4]);
            translate([RING_T, RING_T, -0.1])
                cube([RING_W - 2*RING_T, RING_H - 2*RING_T, TONGUE_H + 5]);
        }
        // detent nub
        translate([TW/2, CH_D - TRAVEL + WALL - 1, TH_NEW - 1.5])
            sphere(r=DET_R * 0.78);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
bar_y = (lock == 1) ? TRAVEL : 0;

new_tray();
top_tray();
slide_bar(bar_y);
