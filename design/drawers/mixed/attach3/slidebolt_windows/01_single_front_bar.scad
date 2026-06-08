// 01_single_front_bar.scad
// Variant 1: Single front actuator bar – push forward (+Y) to lock
// 3 tongues on the bar slide into the 3 front windows simultaneously.
// Back side: 3 fixed rear posts capture back windows on drop.
// lock=0: bar retracted, tongues clear, top tray lifts straight up
// lock=1: bar pushed in, tongues enter front windows

lock = 1; // 0=unlocked, 1=locked
$fn = 48;

// ── Tray geometry ──────────────────────────────────────────────────────────
TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW; // z=50, top tray floor

// Top tray window geometry (front wall y=0..3, back wall y=99..102)
WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2; // 56
WIN_Z_TOP = WIN_Z_CTR + WIN_H/2; // 72
WIN_XS = [TW*1/4, TW*2/4, TW*3/4]; // [76.25, 152.5, 228.75]

// ── Tongue & slider geometry ───────────────────────────────────────────────
TONGUE_W = 30;   // X – fits inside 45mm window with clearance
TONGUE_H = 10;   // Z – fits inside 16mm window with clearance
TONGUE_L = 12;   // Y travel depth into window (wall=3, so 3 in pocket + 9 into window)

// Slider bar lives inside a channel cut into the new tray top, near y=0 face
BAR_W = TW - 2*WALL - 6;
BAR_H = TONGUE_H + 4;   // Z
BAR_D = 16;              // Y body depth (sits behind front wall)

TRAVEL = 10;             // how far bar moves in +Y to lock

// Channel cut into new tray top: bar rides here
CH_Y0    = 0;            // channel starts at front wall exterior
CH_DEPTH = BAR_D + TRAVEL + 3;
CH_H     = BAR_H + 1.5; // generous Z clearance
CH_Z0    = TH_NEW - CH_H; // channel floor z

// Tongue y-position when locked: tongue face reaches y=0 (front wall inner face at y=3)
// When bar is at travel=TRAVEL, tongue front is at y = WALL - TONGUE_L (through window)
// We need tongue to enter window which spans y=0..3, and protrude to at most y=-0.5

// Fixed rear capture posts (back side passive): go INSIDE footprint, y<99
POST_W = 30; POST_H = 14; POST_D = 5; // XZ of post, Y depth inward from back wall
POST_Z = WIN_Z_BOT; // base of post = window bottom

// End hooks at x=0 and x=305 corners
HOOK_T = 3;  // hook thickness
HOOK_H = 10; // hook overhang height

// Detent
DET_R = 2.0;

// Colors
COL_NEW  = "#1565C0";
COL_TOP  = "#90A4AE";
COL_BOLT = "#C62828";

// ── Modules ────────────────────────────────────────────────────────────────

module new_tray() {
    color(COL_NEW)
    union() {
        difference() {
            cube([TW, TD, TH_NEW]);
            // hollow interior
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // front channel slot for slider bar (open at y=0 face)
            translate([WALL+3, -0.1, CH_Z0 - 0.5])
                cube([TW-2*WALL-6, CH_DEPTH+0.1, CH_H+1]);
            // detent socket for LOCKED position
            translate([TW/2, CH_DEPTH - TRAVEL - 1, TH_NEW - 2])
                sphere(r=DET_R);
            // detent socket for UNLOCKED position
            translate([TW/2, CH_DEPTH - TRAVEL - 1 - TRAVEL, TH_NEW - 2])
                sphere(r=DET_R);
        }

        // Fixed rear capture posts – inside footprint, no protrusion past y=102
        // Posts project upward from new tray top, captured in back windows when top tray drops
        color(COL_NEW)
        for (wx = WIN_XS) {
            translate([wx - POST_W/2, TD - WALL - POST_D, TH_NEW])
                cube([POST_W, POST_D, POST_H]);
        }

        // End hooks at short sides – hook OVER top tray rim
        // Left end (x=0 side)
        translate([0, TD/2 - 15, TH_NEW])
            cube([HOOK_T, 30, HOOK_H]);
        // Right end (x=305)
        translate([TW-HOOK_T, TD/2 - 15, TH_NEW])
            cube([HOOK_T, 30, HOOK_H]);
    }
}

module top_tray() {
    color(COL_TOP)
    translate([0, 0, TOP_BASE_Z])
    difference() {
        cube([TW, TD, TH_TOP]);
        // hollow interior
        translate([WALL, WALL, WALL])
            cube([TW-2*WALL, TD-2*WALL, TH_TOP]);
        // front windows (3×)
        for (wx = WIN_XS)
            translate([wx - WIN_W/2, -0.1, WIN_Z_BOT - TOP_BASE_Z])
                cube([WIN_W, WALL+0.2, WIN_H]);
        // back windows (3×)
        for (wx = WIN_XS)
            translate([wx - WIN_W/2, TD-WALL-0.1, WIN_Z_BOT - TOP_BASE_Z])
                cube([WIN_W, WALL+0.2, WIN_H]);
    }
}

module slide_bar(off_y) {
    // off_y = 0 → retracted (unlocked), TRAVEL → locked
    translate([0, off_y, 0])
    color(COL_BOLT) {
        // main bar body sits in channel
        translate([WALL+3, WALL, CH_Z0 + 0.75])
            cube([BAR_W, BAR_D, BAR_H - 1.5]);
        // 3 tongues project toward −Y from bar front face
        for (wx = WIN_XS) {
            translate([wx - TONGUE_W/2, WALL - TONGUE_L, WIN_Z_BOT + 2])
                cube([TONGUE_W, TONGUE_L, TONGUE_H]);
        }
        // finger tab at center front
        translate([TW/2 - 12, WALL - TONGUE_L - 6, WIN_Z_BOT + 2])
            cube([24, 6, TONGUE_H]);
        // detent bump on top
        translate([TW/2, WALL + BAR_D - DET_R - 2, TH_NEW - 1])
            sphere(r=DET_R * 0.8);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
bar_y = (lock == 1) ? TRAVEL : 0;

new_tray();
top_tray();
slide_bar(bar_y);
