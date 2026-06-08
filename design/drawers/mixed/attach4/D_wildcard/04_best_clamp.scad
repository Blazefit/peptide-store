// 04_best_clamp.scad
// WILDCARD BEST VARIANT: TRIPLE-ENGAGEMENT LIFT-LOCK
//
// The definitive design combining all strengths:
//
// MECHANISM — "Lift & Click":
//   1. Top tray placed down freely (jaws stowed below z=50, nothing above)
//   2. User grips the SPINE BAR (front face, z≈30, full-width handle) with
//      fingertips and sweeps it UPWARD in one motion (~44mm travel)
//   3. As the spine rises:
//      a. TWO L-HOOKS at the ends climb past z=83 and hook over the end-wall
//         tops → AXIAL LOCK (prevents Z lift)
//      b. A FRONT TONGUE integrated into the spine enters the front open slot
//         (z=59..74) and seats against the front top rail → ANTI-RATTLE
//      c. A SNAP RIDGE on each hook arm clicks over a tray ridge → DETENT HOLD
//   4. To unlock: squeeze the centre of spine bar inward (flex clears snap) and
//      sweep downward. ONE motion, ONE hand.
//
// CAPTURE GEOMETRY:
//   - End hooks: 5mm×70mm×2 sides → hook area = 5×70×2 = 700mm².
//     At 2mm lift of top tray, overlap = 700×min(2, HOOK_H=5) = 700mm³ >> 200mm³
//   - Front slot tongue adds anti-rattle without adding to capture count
//
// DOOR FLUSH: all hardware at x<0 or x>304.8 (ends) or y≤0 (front)
// OVERHEAD: unlocked state max z = 50 (new tray top face only)

show = "all"; // [all,new,top]
lock = 1;     // 0=open, 1=locked

include <../top_ref.scad>

$fn = 48;

// ─── Tray constants ──────────────────────────────────────────────────────────
NTX = 304.8;  NTY = 101.6;  NTZ = 50;  WALL = 3;
END_WALL_T = 3;   // top tray end wall thickness
END_TOP_Z  = 83;  // end wall top (seated)
SLOT_BOT   = 59;  // front open slot bottom z
SLOT_TOP   = 74;  // front open slot top z
RAIL_BOT   = 75;  // front top rail underside z

// ─── Hook arm parameters ─────────────────────────────────────────────────────
// Thicker hook arm for strength; slightly inset from tray corners
HOOK_STEM_T = 6;     // hook stem thickness in X
HOOK_GAP    = 0.6;   // clearance between hook and top tray end wall
HOOK_SPAN_Y = 74;    // hook arm span in Y (y=10..84, avoids door corner y=95+)
HOOK_Y0     = 10;    // hook arm starts at y=10

HOOK_NOSE_H  = 6;    // hook nose height in Z when locked (=overlap at 2mm lift → 6×74×2=888mm³)
HOOK_NOSE_XW = HOOK_STEM_T + END_WALL_T + 2*HOOK_GAP;  // nose spans end wall = 10.2mm

HOOK_STEM_H_OUTER = 57;   // full stem height in Z
HOOK_Z_UNLOCK     = 38;   // hook NOSE bottom z when unlocked (hook z=38..44, below z=50 ✓)
HOOK_Z_LOCK       = 83.5; // hook nose bottom z when locked (above z=83 ✓)
HOOK_TRAVEL       = HOOK_Z_LOCK - HOOK_Z_UNLOCK;  // 45.5mm

// ─── Spine bar parameters ─────────────────────────────────────────────────────
SPINE_H    = 14;   // spine bar height in Z (ergonomic grip)
SPINE_T    = 7;    // spine depth in Y (protrudes forward from tray face)
SPINE_Z_UNLOCK = 26;  // spine bar bottom z when unlocked (z=26..40, below z=50 ✓)
SPINE_Z_LOCK   = SPINE_Z_UNLOCK + HOOK_TRAVEL;  // = 71.5, top at 85.5 > 83 ✓
// Wait — when locked, spine_z_bottom=71.5, top=71.5+14=85.5. The spine bar
// when locked is at z=71.5..85.5, which is above new tray top (z=50). It will
// be outside the seated top tray's lateral footprint (y<0) so OK.

// Tongue geometry (front slot engagement)
// Tongue enters front slot z=59..74, from y=0..TONGUE_DEPTH inside front wall
TONGUE_Z_CTR = 66;        // tongue center z (in slot)
TONGUE_H_SIZE = 10;       // tongue height z=61..71 (well within 59..74)
TONGUE_DEPTH  = 2.0;      // tongue depth in Y (enters slot from outside)
TONGUE_X0     = 20;       // tongue start x (clear of corners)
TONGUE_X1     = NTX-20;   // tongue end x

// Snap detent: a ridge on the hook arm snaps over new tray rim in locked position
SNAP_H   = 1.5;   // snap ridge height (sticks out on outside face)
SNAP_W   = 3;     // snap ridge width in Z

// ─── New tray ─────────────────────────────────────────────────────────────────
module new_tray() {
    color("#1565C0")
    difference() {
        cube([NTX, NTY, NTZ]);
        // hollow interior
        translate([WALL, WALL, WALL])
            cube([NTX-2*WALL, NTY-2*WALL, NTZ-WALL+0.1]);
        // Front wall tongue slot (allows locked tongue to pass through)
        // Slot: y=0..WALL+clearance, z=tongue zone, x=tongue span
        translate([TONGUE_X0, -0.1, TONGUE_Z_CTR - TONGUE_H_SIZE/2])
            cube([TONGUE_X1-TONGUE_X0, WALL+0.2, TONGUE_H_SIZE]);
    }
    // Snap ledge on end faces (small ridge that hook snaps over)
    color("#1565C0")
    for (sx=[0,1]) {
        ledge_x = sx==0 ? -(HOOK_STEM_T+HOOK_GAP+SNAP_H) : NTX+HOOK_GAP;
        translate([ledge_x, HOOK_Y0 + HOOK_SPAN_Y/2 - 10, NTZ-4])
            cube([SNAP_H+0.5, 20, 4]);
    }
}

// ─── Single hook arm ─────────────────────────────────────────────────────────
module hook_arm(side, lock_state) {
    hook_z   = lock_state==1 ? HOOK_Z_LOCK : HOOK_Z_UNLOCK;
    stem_z0  = hook_z - HOOK_STEM_H_OUTER;

    // Stem x: outside the top tray end wall
    stem_x   = side==0 ? -(HOOK_STEM_T+HOOK_GAP) : NTX+HOOK_GAP;
    nose_x   = side==0 ? -(HOOK_STEM_T+HOOK_GAP) : NTX-END_WALL_T-HOOK_GAP;

    color("#D84315")
    translate([0, HOOK_Y0, 0])
    union() {
        // Main stem (vertical bar on outside face)
        translate([stem_x, 0, stem_z0])
            cube([HOOK_STEM_T, HOOK_SPAN_Y, HOOK_STEM_H_OUTER]);

        // Hook nose (extends inward over end wall top when raised)
        translate([nose_x, 0, hook_z])
            cube([HOOK_NOSE_XW, HOOK_SPAN_Y, HOOK_NOSE_H]);

        // Snap ridge on stem (bites over new tray rim ledge)
        snap_x = side==0 ? stem_x - SNAP_H : stem_x + HOOK_STEM_T;
        translate([snap_x, HOOK_SPAN_Y/2-10, hook_z - 5])
            cube([SNAP_H, 20, SNAP_W]);
    }
}

// ─── Spine bar ────────────────────────────────────────────────────────────────
module spine_bar(lock_state) {
    sz0  = lock_state==1 ? SPINE_Z_LOCK : SPINE_Z_UNLOCK;
    sy0  = -SPINE_T;   // front face of bar at y=-SPINE_T

    color("#D84315")
    union() {
        // Main horizontal spine (full width including hook zones)
        translate([-(HOOK_STEM_T+HOOK_GAP), sy0, sz0])
            cube([NTX + 2*(HOOK_STEM_T+HOOK_GAP), SPINE_T, SPINE_H]);

        // Tongue section (slides into front slot when locked)
        if (lock_state == 1) {
            translate([TONGUE_X0, sy0, TONGUE_Z_CTR - TONGUE_H_SIZE/2])
                cube([TONGUE_X1-TONGUE_X0, SPINE_T + TONGUE_DEPTH, TONGUE_H_SIZE]);
        }

        // Grip ridges on front face (ergonomic thumb grip for push-up)
        for (rx = [-60,-40,-20,0,20,40,60]) {
            translate([NTX/2+rx-2, sy0-3, sz0+1])
                cube([4, 3, SPINE_H-2]);
        }
        // Wide thumb boss in center
        translate([NTX/2-30, sy0-8, sz0])
            cube([60, 8, SPINE_H]);
    }
}

// ─── New assembly ─────────────────────────────────────────────────────────────
module new_assembly(lock_state) {
    new_tray();
    hook_arm(0, lock_state);
    hook_arm(1, lock_state);
    spine_bar(lock_state);
}

// ─── Render ───────────────────────────────────────────────────────────────────
if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
