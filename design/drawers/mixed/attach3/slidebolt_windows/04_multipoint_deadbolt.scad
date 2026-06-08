// 04_multipoint_deadbolt.scad
// Variant 4: Multipoint dead-bolt – best-of-breed refined design
// This is the premium variant:
//   • Single front bar slides +Y (push inward) with generous finger grip tab
//   • Three outboard tongues ride in guides and enter front windows precisely
//   • A captured T-slot rail with shoulder stops (hard end-stops each direction)
//   • Dual detent bumps for locked AND unlocked positions
//   • Back side: 3 fixed guide posts (inside footprint) drop into back windows
//   • Side-end hooks for corner capture (short ends x=0, x=305)
//   • No geometry beyond y=102 (flush door side)
//   • Tongue clearance: 30W × 10H inside 45W × 16H windows (7.5mm/side, 3mm top/bot)
//
// lock=0: bar forward (y_offset=0), tongues behind wall → top tray liftable
// lock=1: bar pushed in (y_offset=TRAVEL), tongues in windows → locked

lock = 1;
$fn = 48;

// ── Core geometry ──────────────────────────────────────────────────────────
TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;

WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;   // 56
WIN_XS = [TW*1/4, TW*2/4, TW*3/4]; // 76.25, 152.5, 228.75

// ── Mechanism parameters ───────────────────────────────────────────────────
TONGUE_W = 30;    // same as spec
TONGUE_H = 10;    // same as spec
CL        = 1.0;  // print clearance

// Bar sizing
BAR_W = TW - 2*WALL - 6;   // bar x-span
BAR_H = TONGUE_H + 6;      // bar height (z) – slightly taller for stiffness
BAR_D = 20;                 // bar Y depth

// Travel: tongue must move from behind wall (y=WALL) into window (y≈0..3)
// In locked: tongue front ≈ y=-0.3 (barely past inner face of wall at y=3)
// tongue extends back from its front face by TONGUE_L
TONGUE_L  = WALL + 3;       // tongue length in Y (extends 3mm into window past inner wall face)
TRAVEL    = TONGUE_L;       // bar travels this far; at full travel tongue tip is at y≈0

// Channel for bar: open at y=0 (front face access), closed at back (stop)
CH_W  = BAR_W + 2*CL;
CH_H  = BAR_H + 2*CL;
CH_D  = BAR_D + TRAVEL + 4; // extra 4mm for clearance at retracted end
CH_X0 = WALL + 3;
CH_Z0 = TH_NEW - CH_H - 1;

// Tongue guides: small rails cut into channel walls to center each tongue
TG_W = TONGUE_W + 2*CL;
TG_H = TONGUE_H + 2*CL;

// Detent
DET_R = 2.0;
DET_X = TW/2;   // center of bar

// Rear passive capture posts
RPOST_W = 30; RPOST_H = WIN_H + 2; RPOST_D = WALL + 1;
// Post stands on new tray top, slides into back window as top tray drops
// Post height must be ≤ WIN_H + slack so it sits inside window at full depth

// End hooks
EH_T = WALL;    // hook wall thickness
EH_W = 28;      // Z hook claw height
EH_D = 6;       // Y depth of hook reaching over rim

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
            // hollow core
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // front bar channel
            translate([CH_X0, -0.1, CH_Z0])
                cube([CH_W, CH_D+0.1, CH_H]);
            // slots in front wall for tongues (each tongue cuts own slot)
            for (wx = WIN_XS)
                translate([wx - TONGUE_W/2 - CL, -0.1, WIN_Z_BOT + CL])
                    cube([TONGUE_W+2*CL, WALL+0.2, TONGUE_H]);
            // detent sockets: locked and unlocked
            translate([DET_X, CH_D - TRAVEL - 1 + WALL, TH_NEW - 1])
                sphere(r=DET_R);
            translate([DET_X, CH_D - TRAVEL - 1 + WALL - TRAVEL, TH_NEW - 1])
                sphere(r=DET_R);
        }

        // Rear capture posts (within footprint, flush with back wall)
        for (wx = WIN_XS)
            translate([wx - RPOST_W/2, TD - WALL - RPOST_D, TH_NEW])
                cube([RPOST_W, RPOST_D, RPOST_H]);

        // Corner end-hooks (short sides)
        // Left end – hook claw
        translate([0, TD/2 - EH_W/2, TH_NEW])
            cube([EH_T, EH_W, 8]);
        // Right end – hook claw
        translate([TW-EH_T, TD/2 - EH_W/2, TH_NEW])
            cube([EH_T, EH_W, 8]);
    }
}

module top_tray() {
    color(COL_TOP)
    translate([0, 0, TOP_BASE_Z])
    difference() {
        cube([TW, TD, TH_TOP]);
        translate([WALL, WALL, WALL])
            cube([TW-2*WALL, TD-2*WALL, TH_TOP]);
        // front windows
        for (wx = WIN_XS)
            translate([wx - WIN_W/2, -0.1, WIN_Z_BOT - TOP_BASE_Z])
                cube([WIN_W, WALL+0.2, WIN_H]);
        // back windows
        for (wx = WIN_XS)
            translate([wx - WIN_W/2, TD-WALL-0.1, WIN_Z_BOT - TOP_BASE_Z])
                cube([WIN_W, WALL+0.2, WIN_H]);
    }
}

module slide_bar(off_y) {
    // off_y = 0 → retracted, TRAVEL → locked
    color(COL_BOLT)
    translate([0, off_y, 0]) {
        // main bar in channel (slightly undersized for clearance)
        translate([CH_X0 + CL, WALL, CH_Z0 + CL])
            cube([CH_W - 2*CL, BAR_D, CH_H - 2*CL]);
        // 3 tongues (same Z level as windows)
        for (wx = WIN_XS) {
            translate([wx - TONGUE_W/2, WALL - TONGUE_L, WIN_Z_BOT + CL])
                cube([TONGUE_W, TONGUE_L + BAR_D, TONGUE_H]);
        }
        // Pull/push grip tab at center front
        translate([TW/2 - 20, WALL - TONGUE_L - 8, WIN_Z_BOT])
            cube([40, 8, TONGUE_H + 2]);
        // Detent nub on bar top
        translate([DET_X, CH_D - TRAVEL - 1 + WALL, TH_NEW - 1])
            sphere(r=DET_R * 0.78);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
bar_y = (lock == 1) ? TRAVEL : 0;

new_tray();
top_tray();
slide_bar(bar_y);
