// 01_single_front_bar.scad
// Variant 1: Single push-in bar (+Y) with 3 tongues entering front windows.
// Housing clips onto front face of new tray (y<0 exterior side).
// UNLOCKED: bar retracted (tongues at y<0, clear of drop path).
// LOCKED: bar pushed in +Y, 3 tongues enter front windows (y=0..3 gap at z=56..72).
// Back side: 3 fixed posts inside footprint capture back windows on drop.
// End rim-lips at x=0, x=305 grip top tray corners.
//
// lock=0 → unlocked (top tray can lift straight up)
// lock=1 → locked (tongues in windows)

lock = 1;
$fn = 48;

// ── Tray geometry ──────────────────────────────────────────────────────────
TW = 305; TD = 102; TH_NEW = 50; TH_TOP = 33; WALL = 3;
TOP_BASE_Z = TH_NEW;  // z=50

// Windows in front (y=0..3) and back (y=99..102) walls of TOP tray
WIN_W = 45; WIN_H = 16; WIN_Z_CTR = 64;
WIN_Z_BOT = WIN_Z_CTR - WIN_H/2;  // 56
WIN_Z_TOP = WIN_Z_CTR + WIN_H/2;  // 72
WIN_XS = [TW*1/4, TW*2/4, TW*3/4];  // 76.25, 152.5, 228.75

// ── Mechanism parameters ───────────────────────────────────────────────────
// Tongue cross-section (fits inside window): 30W(X) × 10H(Z) inside 45W × 16H window
TONGUE_W = 30; TONGUE_H = 10;
CL = 1.2;  // clearance around tongue in window

// Bar body: rides in channel on front face of new tray (exterior, y<0)
// Housing is attached to new tray front face
BAR_W = TW - 2*WALL - 6;  // full span minus end clearance
BAR_H = WIN_H + 6;         // Z span covers window height with margin
BAR_Z0 = WIN_Z_BOT - 3;   // bar bottom z (3mm below window bottom)
BAR_D = 14;                // Y depth of bar body (exterior of new tray)

// Travel: bar pushed +Y from retracted to locked
// Tongue starts at y=-TONGUE_REACH, locked at y=0..TONGUE_ENGAGE
TONGUE_REACH = 8;    // how deep tongue sits outside wall before locking
TONGUE_ENGAGE = 6;   // how far tongue penetrates into window (y=0..ENGAGE)
TRAVEL = TONGUE_REACH + TONGUE_ENGAGE;  // total bar travel = 14mm

// Channel slot cut into new tray front wall to let tongues pass through at z=56..72
// (tongues move in Y through the front wall thickness as bar pushes in)
SLOT_H = TONGUE_H;  // Z height of slot in new tray front wall
SLOT_Z0 = WIN_Z_BOT + CL;  // slot z start

// Housing channel for bar rail (cut into new tray front wall exterior area)
// Bar body at y = -BAR_D..-0.5 (offset from y=0 face)
HSG_W = BAR_W + 2;
HSG_H = BAR_H + 2;
HSG_Z0 = BAR_Z0 - 1;

// Detent bumps for locked and unlocked positions
DET_R = 2.0;

// Rear capture posts (passive, within footprint)
RPOST_W = 28; RPOST_H = 14; RPOST_D = WALL;

// End rim-lip hooks on short sides
LIP_T = WALL; LIP_W = 28; LIP_H = 8;

// Colors
COL_NEW  = "#1565C0";
COL_TOP  = "#90A4AE";
COL_BOLT = "#C62828";

// ── Modules ────────────────────────────────────────────────────────────────

module new_tray() {
    color(COL_NEW) union() {
        difference() {
            cube([TW, TD, TH_NEW]);
            // hollow interior
            translate([WALL, WALL, WALL])
                cube([TW-2*WALL, TD-2*WALL, TH_NEW-WALL+0.1]);
            // tongue pass-through slots in front wall (tongues enter here when locking)
            for (wx = WIN_XS)
                translate([wx - TONGUE_W/2 - CL, -0.1, SLOT_Z0])
                    cube([TONGUE_W + 2*CL, WALL + 0.2, SLOT_H]);
            // housing rail channel on outside of front face: cut a groove for bar to ride
            // (bar housing is bolted on front face – groove is captive track)
            translate([WALL+3, -BAR_D - 1, BAR_Z0 - 1])
                cube([BAR_W - 2, BAR_D + 0.5, BAR_H + 2]);
            // detent sockets in front wall face for locked / unlocked
            translate([TW/2, -BAR_D/2, BAR_Z0 + BAR_H/2 + 3])
                rotate([0, 0, 0]) sphere(r=DET_R);
            translate([TW/2, -BAR_D/2 - TRAVEL, BAR_Z0 + BAR_H/2 + 3])
                sphere(r=DET_R);
        }

        // Housing frame plates (front flange keeping bar captive)
        // Top flange
        translate([WALL+2, -BAR_D - 1.5, BAR_Z0 + BAR_H + 1])
            cube([BAR_W - 2, BAR_D + 0.5, WALL]);
        // Bottom flange
        translate([WALL+2, -BAR_D - 1.5, BAR_Z0 - WALL])
            cube([BAR_W - 2, BAR_D + 0.5, WALL]);

        // End stop tabs (prevent bar sliding out of housing)
        translate([WALL + 1, -BAR_D - 1.5, BAR_Z0 - WALL])
            cube([2, BAR_D + 0.5, BAR_H + 2*WALL]);
        translate([TW - WALL - 3, -BAR_D - 1.5, BAR_Z0 - WALL])
            cube([2, BAR_D + 0.5, BAR_H + 2*WALL]);

        // Rear capture posts (within footprint, flush with back)
        for (wx = WIN_XS)
            translate([wx - RPOST_W/2, TD - WALL - RPOST_D, TOP_BASE_Z])
                cube([RPOST_W, RPOST_D, RPOST_H]);

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
        // front windows
        for (wx = WIN_XS)
            translate([wx-WIN_W/2, -0.1, WIN_Z_BOT-TOP_BASE_Z])
                cube([WIN_W, WALL+0.2, WIN_H]);
        // back windows
        for (wx = WIN_XS)
            translate([wx-WIN_W/2, TD-WALL-0.1, WIN_Z_BOT-TOP_BASE_Z])
                cube([WIN_W, WALL+0.2, WIN_H]);
    }
}

module push_bar(off_y) {
    // off_y=0 → retracted (unlocked); off_y=TRAVEL → locked
    // Bar body in the exterior housing, tongues enter windows as bar moves +Y
    color(COL_BOLT)
    translate([0, off_y, 0]) {
        // main bar body (exterior of new tray, y<0)
        translate([WALL+3 + 0.5, -BAR_D - 0.5, BAR_Z0])
            cube([BAR_W - 3, BAR_D, BAR_H]);
        // 3 tongues at window height, pointing in +Y direction
        for (wx = WIN_XS) {
            translate([wx - TONGUE_W/2, -TONGUE_REACH, WIN_Z_BOT + CL])
                cube([TONGUE_W, TONGUE_REACH + TONGUE_ENGAGE + WALL, TONGUE_H]);
        }
        // pull/push grip tab at center (extends forward in -Y for finger access)
        translate([TW/2 - 22, -BAR_D - 9, BAR_Z0 + 2])
            cube([44, 9, BAR_H - 4]);
        // detent nub on bar face (mates with socket in housing)
        translate([TW/2, -BAR_D/2 - 0.5, BAR_Z0 + BAR_H/2 + 3])
            sphere(r=DET_R * 0.82);
    }
}

// ── Assembly ───────────────────────────────────────────────────────────────
bar_y = (lock == 1) ? TRAVEL : 0;

new_tray();
top_tray();
push_bar(bar_y);
