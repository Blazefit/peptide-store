// 05_endslide_hooks.scad
// Variant 5: End-operated slide bar (SHORT-END actuators) + front passive windows
// Instead of one long bar, TWO short sliders live inside the short-end walls
// (x=0 and x=305 faces). Each slider has a tongue that engages the NEAREST
// front window when pushed inward from the end (+X / -X).
// A third central tongue is driven by a connecting link.
// This variant shows the short-end operated version as an alternative to
// pure front operation; it can be useful when the front is very tight.
//
// Simplification for clarity: each short-end slider drives 1 tongue each;
// center tongue is on a separate push-in mini-tab at center front.
//
// lock=0: end sliders retracted, tongues clear
// lock=1: end sliders pushed in TRAVEL mm, tongues in windows

lock = 1;
$fn = 48;

// ── Geometry ───────────────────────────────────────────────────────────────
TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;
WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;
WIN_XS = [TW*1/4, TW*2/4, TW*3/4];

// ── End-slider parameters ──────────────────────────────────────────────────
TONGUE_W = 28; TONGUE_H = 10; TONGUE_L = 8; // tongue into front window (Y)
TRAVEL   = 18; // X inward travel to align tongue with window

// End-slider body: rides inside X-axis channel near front of new tray top
SL_W = TRAVEL + 12; // X length of slider body
SL_H = TONGUE_H + 4; SL_D = 12; // Z, Y of slider
SL_Z0 = WIN_Z_BOT - 1;

// Channel for end slider (open at short face)
CH_H = SL_H + 1.2; CH_D = SL_D + 1.2;
CH_X_L = -0.1;           // left channel: from x=-0 inward
CH_X_R = TW - SL_W - 4;  // right channel starts here

CL = 1.0;

// Center mini-tab (third tongue)
CTR_W = 30; CTR_H = 10; CTR_D = 10; // push-in center tab
CTR_TRAVEL = 9;

// Rear posts
POST_W = 28; POST_H = 14; POST_D = 4;

COL_NEW  = "#1565C0"; COL_TOP = "#90A4AE"; COL_BOLT = "#F9A825";

module new_tray() {
    color(COL_NEW) union() {
        difference() {
            cube([TW, TD, TH_NEW]);
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // LEFT end-slider channel (open at x=0)
            translate([CH_X_L, WALL, SL_Z0 - CL])
                cube([SL_W + TRAVEL + 2, CH_D, CH_H]);
            // RIGHT end-slider channel (open at x=TW)
            translate([TW - SL_W - TRAVEL - 2, WALL, SL_Z0 - CL])
                cube([SL_W + TRAVEL + 2 + 0.1, CH_D, CH_H]);
            // center push-tab slot (open at y=0)
            translate([TW/2 - CTR_W/2 - CL, -0.1, WIN_Z_BOT + CL])
                cube([CTR_W+2*CL, WALL + CTR_TRAVEL + 2, CTR_H]);
            // tongue slots in front wall for each window
            for (wx = WIN_XS)
                translate([wx - TONGUE_W/2 - CL, -0.1, WIN_Z_BOT + CL])
                    cube([TONGUE_W+2*CL, WALL+0.2, TONGUE_H]);
        }
        // Rear capture posts
        for (wx = WIN_XS)
            translate([wx - POST_W/2, TD - WALL - POST_D, TH_NEW])
                cube([POST_W, POST_D, POST_H]);
        // End-wall trim (outer faces of short sides)
        // No protrusion – short side wall at x=0 and x=TW is already WALL thick
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

module end_slider_left(off_x) {
    // slides in +X direction to lock (tongue enters left front window)
    color(COL_BOLT)
    translate([off_x, 0, 0]) {
        // slider body
        translate([CL, WALL + CL, SL_Z0])
            cube([SL_W, SL_D, SL_H]);
        // tongue projecting toward −Y through front wall
        translate([WIN_XS[0] - TONGUE_W/2, WALL - TONGUE_L, WIN_Z_BOT + 2])
            cube([TONGUE_W, TONGUE_L + 2, TONGUE_H]);
        // grip tab at x=0 face
        translate([CL, WALL + CL, SL_Z0]) cube([4, SL_D, SL_H]);
    }
}

module end_slider_right(off_x) {
    // slides in -X direction to lock (tongue enters right front window)
    color(COL_BOLT)
    translate([off_x, 0, 0]) {
        translate([TW - SL_W - CL, WALL + CL, SL_Z0])
            cube([SL_W, SL_D, SL_H]);
        translate([WIN_XS[2] - TONGUE_W/2, WALL - TONGUE_L, WIN_Z_BOT + 2])
            cube([TONGUE_W, TONGUE_L + 2, TONGUE_H]);
        translate([TW - CL - 4, WALL + CL, SL_Z0]) cube([4, SL_D, SL_H]);
    }
}

module center_tab(off_y) {
    color(COL_BOLT)
    translate([0, off_y, 0]) {
        // push-in mini bar for center window
        translate([TW/2 - CTR_W/2, WALL, WIN_Z_BOT + CL + 0.6])
            cube([CTR_W, CTR_D, CTR_H - 1.2]);
        // tongue through front wall
        translate([WIN_XS[1] - TONGUE_W/2, WALL - TONGUE_L, WIN_Z_BOT + 2])
            cube([TONGUE_W, TONGUE_L + CTR_D, TONGUE_H]);
        // grip tab
        translate([TW/2 - 12, WALL - TONGUE_L - 6, WIN_Z_BOT + 2])
            cube([24, 6, TONGUE_H]);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
sl_off_l = (lock == 1) ? TRAVEL : 0;
sl_off_r = (lock == 1) ? -TRAVEL : 0;
ctr_off  = (lock == 1) ? CTR_TRAVEL : 0;

new_tray();
top_tray();
end_slider_left(sl_off_l);
end_slider_right(sl_off_r);
center_tab(ctr_off);
