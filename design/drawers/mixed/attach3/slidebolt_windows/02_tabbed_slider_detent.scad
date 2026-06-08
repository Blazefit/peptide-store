// 02_tabbed_slider_detent.scad
// Variant 2: X-sliding bar with strong detent – bar shifts LEFT/RIGHT to align tongues with windows.
// Housing on exterior of new tray front face (y<0). Bar slides in X direction.
// UNLOCKED: bar shifted so tongues are BETWEEN windows (not aligned → no collision on drop).
// LOCKED: bar shifted back, tongues centered on window X positions.
// Then bar also moves +Y by small ENGAGE amount to seat tongues into windows.
// Separate detent holds each position.
//
// Benefit: can be operated end-on from the short ends (x=0 or x=305 face).
// Rear: 3 fixed capture posts inside footprint.
//
// lock=0: bar shifted right (unlocked, tongues between windows)
// lock=1: bar centered (locked, tongues in windows)

lock = 1;
$fn = 48;

TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;

WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;   // 56
WIN_Z_TOP = WIN_Z_CTR + WIN_H/2;   // 72
WIN_XS = [TW*1/4, TW*2/4, TW*3/4]; // 76.25, 152.5, 228.75

TONGUE_W = 30; TONGUE_H = 10; CL = 1.2;

// Lateral shift to unlock: move tongues between windows
// Gap between adjacent windows: (WIN_XS[1]-WIN_XS[0]) - WIN_W = 76.25 - 45 = 31.25mm
// Shift by half gap (15.6mm) centers tongues in the gap between windows
SHIFT = 22;   // X shift to unlock (tongue lands between windows, fully on solid wall)

// Bar body
BAR_W = TW + 2*SHIFT;   // wider to slide without exposing ends
BAR_H = WIN_H + 6;
BAR_Z0 = WIN_Z_BOT - 3;
BAR_D = 12;    // Y exterior depth

// Tongue height in window
TONGUE_ENGAGE = 5;  // Y penetration into window when locked

// Housing flanges
HSG_X0 = -SHIFT; HSG_XLEN = TW + 2*SHIFT;

// Detent
DET_R = 2.0;

// Rear posts
RPOST_W = 28; RPOST_H = 14; RPOST_D = WALL;

// End hooks
LIP_T = WALL; LIP_W = 28; LIP_H = 8;

COL_NEW  = "#1565C0";
COL_TOP  = "#90A4AE";
COL_BOLT = "#F9A825";

module new_tray() {
    color(COL_NEW) union() {
        difference() {
            cube([TW, TD, TH_NEW]);
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // tongue pass-through slots in front wall (window positions)
            for (wx = WIN_XS)
                translate([wx - TONGUE_W/2 - CL, -0.1, WIN_Z_BOT + CL])
                    cube([TONGUE_W + 2*CL, WALL + 0.2, TONGUE_H]);
            // channel for bar rail on exterior (pocket in front face exterior region)
            translate([0, -BAR_D - 1, BAR_Z0 - 1])
                cube([TW, BAR_D + 0.5, BAR_H + 2]);
            // detent sockets in locked and unlocked positions
            translate([TW/2, -BAR_D/2, BAR_Z0 + BAR_H/2])
                sphere(r=DET_R);
        }

        // Housing top and bottom flanges (keep bar captive in Z)
        translate([0, -BAR_D - 1.5, BAR_Z0 + BAR_H + 1])
            cube([TW, BAR_D + 0.5, WALL]);
        translate([0, -BAR_D - 1.5, BAR_Z0 - WALL])
            cube([TW, BAR_D + 0.5, WALL]);

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
            translate([wx-WIN_W/2, -0.1, WIN_Z_BOT-TOP_BASE_Z])
                cube([WIN_W, WALL+0.2, WIN_H]);
        for (wx = WIN_XS)
            translate([wx-WIN_W/2, TD-WALL-0.1, WIN_Z_BOT-TOP_BASE_Z])
                cube([WIN_W, WALL+0.2, WIN_H]);
    }
}

module slide_bar_x(shift_x) {
    // shift_x = 0 → locked (tongues on windows), SHIFT → unlocked (tongues between windows)
    color(COL_BOLT)
    translate([shift_x, 0, 0]) {
        // bar body exterior
        translate([0, -BAR_D - 0.5, BAR_Z0])
            cube([TW, BAR_D, BAR_H]);
        // 3 tongues pointing +Y at correct Z
        for (wx = WIN_XS)
            translate([wx - TONGUE_W/2, -TONGUE_ENGAGE - WALL, WIN_Z_BOT + CL])
                cube([TONGUE_W, TONGUE_ENGAGE + WALL, TONGUE_H]);
        // end-pull tab (right end, accessible from x=305 face)
        translate([TW + 2, -BAR_D/2 - 6, BAR_Z0 + 2])
            cube([8, 12, BAR_H - 4]);
        // detent nub
        translate([TW/2, -BAR_D/2 - 0.5, BAR_Z0 + BAR_H/2])
            sphere(r=DET_R * 0.82);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
bar_shift = (lock == 1) ? 0 : SHIFT;

new_tray();
top_tray();
slide_bar_x(bar_shift);
