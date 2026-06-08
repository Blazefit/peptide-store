// 02_linked_clamp.scad
// WILDCARD variant 2: LINKED CLAMP with SPINE BAR — single push locks both ends
//
// Refinement over 01: the two L-jaw clamps are now linked by a horizontal
// SPINE BAR running along the FRONT face (y<0, z below tray top). Pushing
// the spine bar UP simultaneously drives both clamps upward — truly a
// single-motion lock.  A snap-detent ridge on each clamp arm holds the
// locked position.
//
// The spine bar is at y<0 (in front of new tray), so it stays clear of the
// top tray geometry while also being below z=83 (unlocked overhead constraint).
//
// Additional feature: the spine bar has a CENTER PUSH BOSS — a large ribbed
// thumb area to push with one finger.

show = "all"; // [all,new,top]
lock = 1;

include <../top_ref.scad>

$fn = 48;

NTX = 304.8;  NTY = 101.6;  NTZ = 50;  WALL = 3;
END_WALL_T = 3;
END_TOP_Z  = 83;

// Jaw geometry (same principle as variant 1)
JAW_T      = 4;
JAW_GAP    = 0.6;
JAW_YW     = 70;      // jaw width in Y
JAW_Y0     = 10;      // jaw starts y=10
JAW_H_OUTER = 55;     // stem height
HOOK_H      = 5;      // hook nose height
JAW_HOOK_Z_UNLOCK = 40;
JAW_HOOK_Z_LOCK   = 83.5;

// Spine bar
SPINE_H   = 10;    // spine bar height in Z
SPINE_T   = 5;     // spine bar thickness in Y (protrudes forward from tray)
SPINE_Z0_UNLOCK = 22;  // spine bottom z when unlocked (stow low)
SPINE_Z0_LOCK   = 22 + (JAW_HOOK_Z_LOCK - JAW_HOOK_Z_UNLOCK);  // = 22 + 43.5 = 65.5
// Spine z top: unlock=32 (below z=50 ✓), lock=75.5 (above z=50, enters front slot)

// For capture: spine at y=-(SPINE_T)..-0 is outside the top tray.
// The top tray front slot (z=59..74) is at y=0..3. Spine at y<0 doesn't enter it.
// Spine is for DRIVING only, not for capture. Capture is still via end hooks.

module new_tray() {
    color("#1565C0")
    difference() {
        cube([NTX, NTY, NTZ]);
        translate([WALL, WALL, WALL])
            cube([NTX-2*WALL, NTY-2*WALL, NTZ-WALL+0.1]);
    }
}

module l_jaw(side, lock_state) {
    hook_z  = lock_state==1 ? JAW_HOOK_Z_LOCK : JAW_HOOK_Z_UNLOCK;
    outer_z0 = hook_z - JAW_H_OUTER;
    of_x    = side==0 ? -(JAW_T+JAW_GAP) : NTX+JAW_GAP;
    hook_x0 = side==0 ? -(JAW_T+JAW_GAP) : NTX-END_WALL_T-JAW_GAP;
    hook_xw = JAW_T + END_WALL_T + 2*JAW_GAP;

    color("#D84315")
    translate([0, JAW_Y0, 0])
    union() {
        // Vertical stem
        translate([of_x, 0, outer_z0])
            cube([JAW_T, JAW_YW, JAW_H_OUTER]);
        // Hook nose
        translate([hook_x0, 0, hook_z])
            cube([hook_xw, JAW_YW, HOOK_H]);
        // Snap detent ridge (small bump that catches on tray edge in locked pos)
        // A ridge at z = hook_z - 3 that is 1mm proud on outer face
        translate([of_x - 1, JAW_YW/2-8, hook_z - 4])
            cube([1.5, 16, 4]);
        // Connector tab to spine bar (at front of stem, y=0 face of stem)
        translate([of_x, 0, outer_z0 + JAW_H_OUTER/2 - SPINE_H/2])
            cube([JAW_T, 2, SPINE_H]);
    }
}

module spine_bar(lock_state) {
    sz0 = lock_state==1 ? SPINE_Z0_LOCK : SPINE_Z0_UNLOCK;
    color("#D84315")
    union() {
        // Main bar spanning between jaws
        translate([-(JAW_T+JAW_GAP), -(SPINE_T), sz0])
            cube([NTX + 2*(JAW_T+JAW_GAP), SPINE_T, SPINE_H]);
        // Center push boss (ribbed thumb push area)
        translate([NTX/2 - 20, -(SPINE_T+5), sz0])
            cube([40, SPINE_T+5, SPINE_H]);
        // Ribs on push boss
        for (rx = [-12, -4, 4, 12]) {
            translate([NTX/2 + rx - 1, -(SPINE_T+5), sz0])
                cube([2, 5, SPINE_H]);
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
