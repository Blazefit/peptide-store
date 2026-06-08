// 03_overcenter_clamp.scad
// WILDCARD variant 3: OVER-CENTER SPINE LOCK
//
// Refinement: the spine bar now incorporates OVER-CENTER geometry.
// Instead of just sliding up, the spine bar is hinged at two front bosses on the
// new tray and SWINGS upward from a low stowed position into a locked
// over-center position.  At the top of the swing the jaw hooks snap over the
// end wall tops AND the spine bar's center section enters the front open slot
// (z=59..74) pressing upward into the front top rail — DOUBLE ENGAGEMENT.
//
// Physical action: one sweep of the thumb bar from down to up → both end hooks
// engage + front rail engaged = 3-point lock.  Over-center means the lock
// becomes MORE secure under pull-out load (tries to cam further in, not back).
//
// For simplicity in this simulation: the spine bar moves UP (like variant 2)
// but also has an inward-shifted section that enters the front slot in locked state.

show = "all"; // [all,new,top]
lock = 1;

include <../top_ref.scad>

$fn = 48;

NTX = 304.8;  NTY = 101.6;  NTZ = 50;  WALL = 3;
END_WALL_T = 3;
END_TOP_Z  = 83;
SLOT_BOT   = 59;   // front open slot bottom z
SLOT_TOP   = 74;   // front open slot top z
RAIL_BOT   = 75;   // front top rail bottom z

// Jaw (same L-hook as v1/v2)
JAW_T      = 5;    // slightly thicker for strength
JAW_GAP    = 0.6;
JAW_YW     = 68;
JAW_Y0     = 10;
JAW_H_OUTER = 55;
HOOK_H      = 5;
JAW_HOOK_Z_UNLOCK = 40;
JAW_HOOK_Z_LOCK   = 83.5;

// Spine with front-slot engagement
// In locked state: spine bottom enters front slot from outside
// Spine runs at y = -(SPINE_T) to y=0 (outside front face) when unlocked,
// and y = -(SPINE_T) to y=WALL (inserted to inside of front wall) when locked
SPINE_H_MAIN  = 12;   // main spine section height
SPINE_T_MAIN  = 5;    // spine depth in Y
SPINE_Z_LOCK  = 66;   // spine center Z when locked (mid of open slot z=59..74)
SPINE_Z_UNLOCK= 30;   // spine center Z when unlocked (below tray top z=50)

// Front-slot tongue: section of spine that enters the slot
// y goes from 0 to 2.5 (inside front wall slot area, clear of rails)
// Tongue must stay within z=59..74 (open slot)
TONGUE_T  = 2.5;   // tongue depth in Y (into front slot)
TONGUE_H  = 10;    // tongue height (z=61..71, safely inside open slot 59..74)
TONGUE_X0 = 20;    // tongue starts x=20 (clear of corners)
TONGUE_X1 = NTX-20;  // tongue ends x=284.8

module new_tray() {
    color("#1565C0")
    difference() {
        cube([NTX, NTY, NTZ]);
        translate([WALL, WALL, WALL])
            cube([NTX-2*WALL, NTY-2*WALL, NTZ-WALL+0.1]);
        // Front wall slot for tongue passage (z=61..71, inside open slot zone 59..74)
        translate([TONGUE_X0, -0.1, SPINE_Z_LOCK - TONGUE_H/2])
            cube([TONGUE_X1-TONGUE_X0, WALL+0.2, TONGUE_H]);
    }
}

module l_jaw(side, lock_state) {
    hook_z   = lock_state==1 ? JAW_HOOK_Z_LOCK : JAW_HOOK_Z_UNLOCK;
    outer_z0 = hook_z - JAW_H_OUTER;
    of_x     = side==0 ? -(JAW_T+JAW_GAP) : NTX+JAW_GAP;
    hook_x0  = side==0 ? -(JAW_T+JAW_GAP) : NTX-END_WALL_T-JAW_GAP;
    hook_xw  = JAW_T + END_WALL_T + 2*JAW_GAP;

    color("#D84315")
    translate([0, JAW_Y0, 0])
    union() {
        translate([of_x, 0, outer_z0])
            cube([JAW_T, JAW_YW, JAW_H_OUTER]);
        translate([hook_x0, 0, hook_z])
            cube([hook_xw, JAW_YW, HOOK_H]);
    }
}

module spine_bar(lock_state) {
    sz_ctr = lock_state==1 ? SPINE_Z_LOCK : SPINE_Z_UNLOCK;
    sz0    = sz_ctr - SPINE_H_MAIN/2;
    sy0    = -(SPINE_T_MAIN);

    color("#D84315")
    union() {
        // Main spine bar (at y<0, in front of new tray)
        translate([-(JAW_T+JAW_GAP), sy0, sz0])
            cube([NTX + 2*(JAW_T+JAW_GAP), SPINE_T_MAIN, SPINE_H_MAIN]);

        // Tongue section (only present when locked — enters front slot)
        if (lock_state == 1) {
            translate([TONGUE_X0, sy0, sz_ctr - TONGUE_H/2])
                cube([TONGUE_X1-TONGUE_X0, SPINE_T_MAIN + TONGUE_T, TONGUE_H]);
        } else {
            // Unlocked: no tongue protruding into slot
            translate([TONGUE_X0, sy0, sz_ctr - TONGUE_H/2])
                cube([TONGUE_X1-TONGUE_X0, SPINE_T_MAIN, TONGUE_H]);
        }

        // Center push grip on spine bar (ribbed area)
        translate([NTX/2 - 22, sy0 - 6, sz0])
            cube([44, 6, SPINE_H_MAIN]);
        for (rx = [-16, -8, 0, 8, 16]) {
            translate([NTX/2 + rx - 1, sy0 - 6, sz0])
                cube([2, 6, SPINE_H_MAIN]);
        }
    }
}

module new_assembly(lock_state) {
    new_tray();
    l_jaw(0, lock_state);
    l_jaw(1, lock_state);
    spine_bar(lock_state);
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
