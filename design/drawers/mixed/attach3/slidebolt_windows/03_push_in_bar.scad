// 03_push_in_bar.scad
// Variant 3: Push-in bar (+Y direction) with captive T-slot rail and 3 front tongues
// The entire actuator bar rides in a T-slot channel on top of the new tray
// and is pushed INWARD (toward back, +Y). Tongues project forward (-Y) through
// the front wall into the three front windows. Over-travel stop: shoulder on bar
// hits end of channel.
//
// Extra feature: a spring leaf flexure (simulated as detent) holds locked position.
// Back side: 3 fixed posts for passive rear capture.
// End hooks on x=0 and x=305 grip rim of top tray.
//
// lock=0: bar retracted toward front (y≈0), tongues behind front wall
// lock=1: bar pushed in (+Y by TRAVEL), tongues protrude into windows

lock = 1;
$fn = 48;

// ── Tray dims ──────────────────────────────────────────────────────────────
TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;

WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;   // 56
WIN_Z_TOP = WIN_Z_CTR + WIN_H/2;   // 72
WIN_XS = [TW*1/4, TW*2/4, TW*3/4];

// ── Mechanism dims ─────────────────────────────────────────────────────────
TONGUE_W = 28;  TONGUE_H = 10;
// In LOCKED state tongue front face should reach y ≈ 0 (inside window opening)
// Tongue extends from bar's y_front backward.  Bar body starts at WALL.
// When bar at y_offset=TRAVEL, tongue_front = WALL + TRAVEL - TONGUE_REACH
// We want tongue_front < 3 (into window), so TONGUE_REACH = WALL + TRAVEL - 1

TRAVEL = 11;          // push bar +Y this far
TONGUE_REACH = WALL + TRAVEL - 1; // tongue length in −Y so tip at WALL+TRAVEL-TONGUE_REACH=1

// Bar body
BAR_W = TW - 2*WALL - 8;
BAR_H = TONGUE_H + 4;
BAR_D = 18;  // Y span of bar body itself

// T-slot channel cut into new tray top surface
TS_W   = BAR_W + 1.2;  // X slot width (bar fits loosely)
TS_H   = BAR_H + 1.2;  // Z slot height
TS_D   = BAR_D + TRAVEL + 4; // Y slot depth
TS_X0  = WALL + 4;
TS_Z0  = TH_NEW - TS_H - 0.5;

// Finger tab on front face of bar, projecting out at y=-6 area
TAB_W = 30; TAB_D = 7; TAB_H = 8;

// Detent nub + groove
DET_R = 1.8;

// Rear posts
POST_W = 28; POST_H = 14; POST_D = 5;

// Colors
COL_NEW  = "#1565C0";
COL_TOP  = "#90A4AE";
COL_BOLT = "#C62828";

module new_tray() {
    color(COL_NEW)
    union() {
        difference() {
            cube([TW, TD, TH_NEW]);
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // T-slot channel in front region of top surface
            translate([TS_X0, WALL - 0.1, TS_Z0])
                cube([TS_W, TS_D + 0.1, TS_H]);
            // front opening slot so tongue can poke through front wall
            for (wx = WIN_XS)
                translate([wx - TONGUE_W/2 - 0.5, -0.1, WIN_Z_BOT + 1.5])
                    cube([TONGUE_W+1, WALL + 0.2, TONGUE_H]);
            // detent groove – locked
            translate([TW/2, TS_D - TRAVEL - DET_R, TH_NEW - 1])
                sphere(r=DET_R);
            // detent groove – unlocked
            translate([TW/2, TS_D - TRAVEL - DET_R - TRAVEL, TH_NEW - 1])
                sphere(r=DET_R);
        }

        // Rear capture posts (passive, within footprint)
        for (wx = WIN_XS)
            translate([wx - POST_W/2, TD - WALL - POST_D, TH_NEW])
                cube([POST_W, POST_D, POST_H]);

        // End hooks on short sides
        translate([0,      TD/2 - 12, TH_NEW]) cube([WALL, 24, 10]);
        translate([TW-WALL, TD/2 - 12, TH_NEW]) cube([WALL, 24, 10]);
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

module push_bar(off_y) {
    // off_y = 0 → retracted, TRAVEL → locked
    color(COL_BOLT)
    translate([0, off_y, 0]) {
        // bar body inside channel
        translate([TS_X0 + 0.6, WALL, TS_Z0 + 0.6])
            cube([TS_W - 1.2, BAR_D, TS_H - 1.2]);
        // tongues – extend from bar front face toward −Y through front wall
        for (wx = WIN_XS)
            translate([wx - TONGUE_W/2, WALL - TONGUE_REACH, WIN_Z_BOT + 3])
                cube([TONGUE_W, TONGUE_REACH, TONGUE_H]);
        // finger tab sticking out at front face
        translate([TW/2 - TAB_W/2, WALL - TONGUE_REACH - TAB_D, WIN_Z_BOT + 3])
            cube([TAB_W, TAB_D, TAB_H]);
        // detent nub
        translate([TW/2, TS_D - TRAVEL - DET_R + WALL, TH_NEW - 1])
            sphere(r=DET_R * 0.8);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
bar_y = (lock == 1) ? TRAVEL : 0;

new_tray();
top_tray();
push_bar(bar_y);
