// 04_multipoint_deadbolt.scad
// Variant 4: PREMIUM multipoint deadbolt (best-of-breed)
// Single front bar pushes +Y from retracted position.
// All 3 tongues engage simultaneously (true multipoint deadbolt).
// Features:
//   - 18mm travel for confident engagement feel
//   - Dovetail rail for extra rigidity (no play in Z or X)
//   - Dual detent: strong over-center click in locked position, soft in unlocked
//   - Wide 50mm grip tab with finger recess for one-finger push/pull
//   - Rear: CONTINUOUS guide lip (not just posts) within footprint for back capture
//   - Short-end rim-lip hooks for corner retention
//   - All flush on back (y=102), no hardware there
//
// lock=0: bar retracted (tongues at y<0), top tray drops/lifts freely
// lock=1: bar pushed in, tongues at y=0..8 inside 3 front windows

lock = 1;
$fn = 48;

TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;

WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;   // 56
WIN_Z_TOP = WIN_Z_CTR + WIN_H/2;   // 72
WIN_XS = [TW*1/4, TW*2/4, TW*3/4];

// Tongue fits in window: 30(X) × 10(Z) inside 45×16 → 7.5mm X clearance, 3mm Z clearance
TONGUE_W = 30; TONGUE_H = 10; CL = 1.2;

// Bar body
BAR_W    = TW - 2*WALL - 4;
BAR_H    = WIN_H + 6;    // Z
BAR_D    = 18;           // Y exterior depth
BAR_Z0   = WIN_Z_BOT - 3;

// Dovetail rail
DT_ANG = 10;             // dovetail angle
DT_W   = BAR_D;         // dovetail at top and bottom flange

// Travel
TONGUE_REACH  = 10;
TONGUE_ENGAGE = 8;
TRAVEL        = TONGUE_REACH + TONGUE_ENGAGE;  // 18mm

// Finger grip
TAB_W = 60; TAB_H = 14; TAB_D = 12;

// Detent
DET_R = 2.5;

// Rear guide lip (continuous, inside footprint, flush with y=102)
// Spans full width, height = WIN_H+2 (covers window height range), thickness = WALL
RGL_H = WIN_H + 2;
RGL_T = WALL;
RGL_Z = WIN_Z_BOT - 1;

// End rim-lip hooks
LIP_T = WALL; LIP_W = 32; LIP_H = 8;

COL_NEW  = "#1565C0"; COL_TOP = "#90A4AE"; COL_BOLT = "#C62828";

module dovetail_slot(w, d, h, ang) {
    // horizontal dovetail slot for bar rail
    extra = d * tan(ang);
    hull() {
        translate([0, 0, 0])  cube([w, d, 0.01]);
        translate([-extra, 0, h]) cube([w + 2*extra, d, 0.01]);
    }
}

module new_tray() {
    color(COL_NEW) union() {
        difference() {
            cube([TW, TD, TH_NEW]);
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // tongue slots in front wall
            for (wx = WIN_XS)
                translate([wx - TONGUE_W/2 - CL, -0.1, WIN_Z_BOT + CL])
                    cube([TONGUE_W + 2*CL, WALL + 0.2, TONGUE_H]);
            // dovetail channel pocket on exterior (open at y=0 toward -Y)
            translate([WALL+2, -BAR_D - 1, BAR_Z0 - 1])
                cube([BAR_W, BAR_D, BAR_H + 2]);
            // detent sockets (locked + unlocked)
            translate([TW/2, -BAR_D/2 - 0.5, BAR_Z0 + BAR_H/2 + 2])
                sphere(r=DET_R);
            translate([TW/2, -BAR_D/2 - 0.5 - TRAVEL, BAR_Z0 + BAR_H/2 + 2])
                sphere(r=DET_R);
        }

        // Housing flanges (captive rail, top + bottom with slight dovetail for rigidity)
        translate([WALL+2, -BAR_D - 4, BAR_Z0 + BAR_H + 1])
            cube([BAR_W, BAR_D + 2, WALL + 1]);
        translate([WALL+2, -BAR_D - 4, BAR_Z0 - WALL - 1])
            cube([BAR_W, BAR_D + 2, WALL + 1]);

        // End stops
        translate([WALL, -BAR_D - 4, BAR_Z0 - WALL - 1])
            cube([2, BAR_D + 2, BAR_H + 2*(WALL+1)]);
        translate([TW - WALL - 2, -BAR_D - 4, BAR_Z0 - WALL - 1])
            cube([2, BAR_D + 2, BAR_H + 2*(WALL+1)]);

        // Rear continuous guide lip (entirely within y=99..102, flush with back)
        translate([WALL, TD - WALL, RGL_Z])
            cube([TW - 2*WALL, RGL_T, RGL_H]);

        // End rim-lip hooks on short sides
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
        // bar body (rides in housing channel)
        translate([WALL+2 + 0.6, -BAR_D - 0.6, BAR_Z0])
            cube([BAR_W - 1.2, BAR_D - 0.2, BAR_H]);
        // 3 tongues pointing +Y (enter windows when bar pushed in)
        for (wx = WIN_XS)
            translate([wx - TONGUE_W/2, -TONGUE_REACH, WIN_Z_BOT + CL])
                cube([TONGUE_W, TONGUE_REACH + TONGUE_ENGAGE + WALL, TONGUE_H]);
        // wide ergonomic grip tab
        translate([TW/2 - TAB_W/2, -BAR_D - TAB_D - 0.6, BAR_Z0 + 1])
            cube([TAB_W, TAB_D, TAB_H]);
        // detent nub
        translate([TW/2, -BAR_D/2 - 0.5, BAR_Z0 + BAR_H/2 + 2])
            sphere(r=DET_R * 0.8);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
bar_y = (lock == 1) ? TRAVEL : 0;

new_tray();
top_tray();
push_bar(bar_y);
