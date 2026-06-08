// 02_tabbed_slider_detent.scad
// Variant 2: Tabbed slider with strong spring-detent and captive end-stops
// The bar slides in X (left-right). In the LOCKED position the bar is shifted
// left so that the 3 tongue tabs (which are part of the bar) align with the
// front windows and project into them.  In UNLOCKED position the tongues are
// offset sideways so they clear the windows completely.
//
// This gives a truly captive, captive slider with hard end-stops machined
// into the channel, and a deep detent ball/groove for positive lock feel.
//
// lock=0: slider centered, tongues mis-aligned with windows → clear
// lock=1: slider shifted -X by SHIFT, tongues inside windows

lock = 1; // 0=unlocked, 1=locked
$fn = 48;

// ── Tray dims ──────────────────────────────────────────────────────────────
TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;

WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;
WIN_XS = [TW*1/4, TW*2/4, TW*3/4];

// ── Slider geometry ────────────────────────────────────────────────────────
TONGUE_W = 28;   TONGUE_H = 10;   TONGUE_L = 10; // tongue dims (Y=into window)
SHIFT = (WIN_W - TONGUE_W)/2 - 1; // ~8 mm lateral shift to unlock

// Bar sliding in X inside front pocket
BAR_RAIL_W = TW - 2*WALL - 4;  // channel x range
BAR_H = TONGUE_H + 4;
BAR_D = 14;       // Y
BAR_X0 = WALL + 2; // channel start X

// Vertical position: bar rides inside a slot on top of new tray front area
CH_H  = BAR_H + 1.5;
CH_Z0 = TH_NEW - CH_H - 0.5;  // channel floor

// Detent groove positions: two grooves in channel bottom
DET_R = 1.8;

// Rear capture posts (passive)
POST_W = 30; POST_H = 14; POST_D = 5;

// Colors
COL_NEW  = "#1565C0";
COL_TOP  = "#90A4AE";
COL_BOLT = "#F9A825";

module new_tray() {
    color(COL_NEW)
    union() {
        difference() {
            cube([TW, TD, TH_NEW]);
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // front bar channel (open at y=0)
            translate([BAR_X0 - 0.1, -0.1, CH_Z0])
                cube([BAR_RAIL_W + 0.2, BAR_D + SHIFT + 3, CH_H]);
            // end-stop notches (bar can't slide past)
            translate([BAR_X0 - 2, -0.1, CH_Z0])
                cube([2, BAR_D + SHIFT + 3, CH_H]);
            translate([BAR_X0 + BAR_RAIL_W, -0.1, CH_Z0])
                cube([2, BAR_D + SHIFT + 3, CH_H]);
            // detent socket – locked (bar shifted -X)
            translate([TW/2 - SHIFT, BAR_D - 2, TH_NEW - 1.5])
                sphere(r=DET_R);
            // detent socket – unlocked
            translate([TW/2, BAR_D - 2, TH_NEW - 1.5])
                sphere(r=DET_R);
        }
        // rear capture posts
        for (wx = WIN_XS)
            translate([wx - POST_W/2, TD - WALL - POST_D, TH_NEW])
                cube([POST_W, POST_D, POST_H]);
    }
}

module top_tray() {
    color(COL_TOP)
    translate([0, 0, TOP_BASE_Z])
    difference() {
        cube([TW, TD, TH_TOP]);
        translate([WALL, WALL, WALL])
            cube([TW-2*WALL, TD-2*WALL, TH_TOP]);
        for (wx = WIN_XS)
            translate([wx - WIN_W/2, -0.1, WIN_Z_BOT - TOP_BASE_Z])
                cube([WIN_W, WALL+0.2, WIN_H]);
        for (wx = WIN_XS)
            translate([wx - WIN_W/2, TD-WALL-0.1, WIN_Z_BOT - TOP_BASE_Z])
                cube([WIN_W, WALL+0.2, WIN_H]);
    }
}

module slide_bar(shift_x) {
    // shift_x: 0=unlocked (tongues beside windows), -SHIFT=locked (tongues in windows)
    color(COL_BOLT)
    translate([shift_x, 0, 0]) {
        // bar body
        translate([BAR_X0, WALL, CH_Z0 + 0.75])
            cube([BAR_RAIL_W, BAR_D, BAR_H - 1.5]);
        // tongues project forward through front face
        for (wx = WIN_XS)
            translate([wx - TONGUE_W/2, WALL - TONGUE_L, WIN_Z_BOT + 3])
                cube([TONGUE_W, TONGUE_L, TONGUE_H]);
        // finger tab protruding from right end at front
        translate([BAR_X0 + BAR_RAIL_W, WALL, CH_Z0 + 1])
            cube([10, 12, BAR_H - 2]);
        // detent nub
        translate([TW/2, BAR_D - 2 + WALL, TH_NEW - 1.5])
            sphere(r=DET_R * 0.75);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
bar_shift = (lock == 1) ? -SHIFT : 0;

new_tray();
top_tray();
slide_bar(bar_shift);
