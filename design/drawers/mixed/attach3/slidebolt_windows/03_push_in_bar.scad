// 03_push_in_bar.scad
// Variant 3: Push-in bar with T-slot captive rail and 3 tongues.
// Bar lives in a recessed T-slot channel on EXTERIOR of new tray front face.
// Push bar +Y to lock (tongues enter windows). Pull back to unlock.
// T-slot geometry provides captive rail without separate assembly.
// Generous 14mm travel gives easy one-finger actuation.
// Finger grip: wide tab at center front that sticks out at y<-20 (easy reach).
//
// lock=0: bar retracted (tongues at y<0, top tray can lift straight up)
// lock=1: bar pushed in (tongues at y=0..8, inside front windows)

lock = 1;
$fn = 48;

TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;

WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;
WIN_XS = [TW*1/4, TW*2/4, TW*3/4];

TONGUE_W = 30; TONGUE_H = 10; CL = 1.2;

// T-slot channel on exterior of new tray front face
// Bar body rides in this channel at correct window height
BAR_W    = TW - 2*WALL - 6;
BAR_H    = WIN_H + 4;     // Z
BAR_D    = 16;            // Y exterior depth (bigger = easier to hold)
BAR_Z0   = WIN_Z_BOT - 2;

// T-slot dimensions
TS_STEM_W  = BAR_W;          // X width of stem
TS_STEM_H  = BAR_H;          // Z
TS_STEM_D  = BAR_D;          // Y depth of main channel
TS_FLANGE  = 3;              // Z flange on top and bottom of T
TS_FL_Y    = 4;              // Y depth of T flange

// Travel
TONGUE_REACH  = 10;  // tongue sticks out -Y from bar face
TONGUE_ENGAGE = 8;   // how deep tongue goes into window when locked
TRAVEL        = TONGUE_REACH + TONGUE_ENGAGE;  // 18mm

// Finger tab
TAB_W = 50; TAB_H = 12; TAB_D = 10;

// Detent
DET_R = 2.2;

// Rear posts
RPOST_W = 28; RPOST_H = 14; RPOST_D = WALL;

// End hooks
LIP_T = WALL; LIP_W = 28; LIP_H = 8;

COL_NEW  = "#1565C0"; COL_TOP = "#90A4AE"; COL_BOLT = "#C62828";

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
            // T-slot stem pocket (on exterior front face)
            translate([WALL+3, -TS_STEM_D - 0.5, BAR_Z0 - 0.5])
                cube([TS_STEM_W - 2, TS_STEM_D, TS_STEM_H + 1]);
            // detent sockets
            translate([TW/2, -TS_STEM_D/2 - 0.5, BAR_Z0 + BAR_H/2 + 2])
                sphere(r=DET_R);
            translate([TW/2, -TS_STEM_D/2 - 0.5 - TRAVEL, BAR_Z0 + BAR_H/2 + 2])
                sphere(r=DET_R);
        }

        // T-slot flange rails (top and bottom, captive)
        translate([WALL+3, -TS_STEM_D - TS_FL_Y - 0.5, BAR_Z0 + BAR_H])
            cube([TS_STEM_W - 2, TS_FL_Y, TS_FLANGE]);
        translate([WALL+3, -TS_STEM_D - TS_FL_Y - 0.5, BAR_Z0 - TS_FLANGE])
            cube([TS_STEM_W - 2, TS_FL_Y, TS_FLANGE]);

        // End stops (prevent bar from sliding out x-direction)
        translate([WALL + 1, -TS_STEM_D - TS_FL_Y - 0.5, BAR_Z0 - TS_FLANGE])
            cube([2, TS_FL_Y, TS_STEM_H + 2*TS_FLANGE]);
        translate([TW - WALL - 3, -TS_STEM_D - TS_FL_Y - 0.5, BAR_Z0 - TS_FLANGE])
            cube([2, TS_FL_Y, TS_STEM_H + 2*TS_FLANGE]);

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

module push_bar(off_y) {
    color(COL_BOLT) translate([0, off_y, 0]) {
        // bar body in T-slot
        translate([WALL+3 + 0.6, -TS_STEM_D, BAR_Z0])
            cube([TS_STEM_W - 3.2, TS_STEM_D - 0.5, BAR_H]);
        // tongues
        for (wx = WIN_XS)
            translate([wx - TONGUE_W/2, -TONGUE_REACH, WIN_Z_BOT + CL])
                cube([TONGUE_W, TONGUE_REACH + TONGUE_ENGAGE + WALL, TONGUE_H]);
        // wide finger tab at center (extends far forward for easy push)
        translate([TW/2 - TAB_W/2, -TS_STEM_D - TAB_D, BAR_Z0 + 2])
            cube([TAB_W, TAB_D, TAB_H]);
        // detent nub
        translate([TW/2, -TS_STEM_D/2, BAR_Z0 + BAR_H/2 + 2])
            sphere(r=DET_R * 0.82);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
bar_y = (lock == 1) ? TRAVEL : 0;

new_tray();
top_tray();
push_bar(bar_y);
