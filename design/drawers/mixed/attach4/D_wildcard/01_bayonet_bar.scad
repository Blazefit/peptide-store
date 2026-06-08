// 01_bayonet_bar.scad
// WILDCARD: SLIDING END-CLAMP LOCK ("C-Clip Jaw")
//
// Mechanism:
//   Each short-end outer face of the new tray has a C-shaped jaw/clamp that
//   slides VERTICALLY on the tray end face.  In UNLOCKED state the jaws are
//   slid DOWN — their hook tops are below z=50 (below top tray base), so the
//   top tray seats freely.  A single push-UP on either jaw (both are linked by
//   a connecting spine along the front face) raises both jaws simultaneously.
//   When jaws are raised, the hook-nose (inner face of C) reaches ABOVE z=83
//   (the end-wall top of the top tray), capturing the top tray.  An over-center
//   snap ridge holds jaws in raised position.
//
//   The C-jaw wraps around the end face of the NEW tray and ALWAYS maintains
//   contact via the outer guide flange, ensuring a single connected manifold.
//
//   Different from A/B/C:
//     A = slide-bolt linear, B = corner twist-cams, C = flip-levers.
//     This = C-jaw vertical slide on end faces, linked spine, snap-lock.
//
// Verifier interface: show="all"|"new"|"top", lock=0|1

show = "all"; // [all,new,top]
lock = 1;     // 0=open (jaws down), 1=locked (jaws up, hooks over end walls)

include <../top_ref.scad>

$fn = 48;

// ─── New-tray dims ──────────────────────────────────────────────────────────
NTX = 304.8;  NTY = 101.6;  NTZ = 50;  WALL = 3;

// ─── Top tray end wall (seated) ─────────────────────────────────────────────
// End wall: x=0..3 and x=301.8..304.8, y=0..101.6, z=50..83 (seated)
// End-wall outer face: x=0 (left) and x=304.8 (right)
END_WALL_T = 3;   // end wall thickness in X
END_TOP_Z  = 83;  // end wall top z (seated)

// ─── C-jaw geometry ──────────────────────────────────────────────────────────
// The jaw slides in Z along the new tray end face.
// Jaw outer flange: glides on the outer face of new tray end wall.
// Jaw inner arm:    hooks over the top tray's end wall top.
//
// Cross-section (viewed from X direction):
//   [outer flange ] gap [new tray end wall x=0..3] gap [inner arm → hook]
//
// Jaw Y-span: y=10..80 (clear of corners y=0..6 and y=95..101.6, door side)
JAW_Y0   = 10;    // jaw starts at y=10 (away from front corners)
JAW_Y1   = 80;    // jaw ends at y=80 (away from back/door corners)
JAW_YW   = JAW_Y1 - JAW_Y0;    // 70mm wide jaw
JAW_T    = 4;     // jaw flange/arm thickness in X
JAW_GAP  = 0.6;   // clearance between jaw and tray wall

// Jaw Z height:  enough to travel from unlock to lock
// Unlocked: jaw hook-top at z=47 (below z=50), jaw bottom at z=47-JAW_H
// Locked:   jaw hook-top at z=84.5 (above z=83), jaw bottom at z=84.5-JAW_H
// JAW_H (inner arm height) should be about 10mm
JAW_H_INNER = 10; // inner arm height in Z
JAW_H_OUTER = 55; // outer flange height (spans the travel + hook length)

// Jaw hook nose: extends inward from inner arm
HOOK_DEPTH  = 8;  // how far hook extends inward (in X) over end wall top
HOOK_H      = 5;  // hook nose height in Z

// Z positions:
// Jaw positioned so inner arm top = JAW_HOOK_Z in each state
// Hook occupies z=hook_z..hook_z+HOOK_H.  Must stay < z=50 when unlocked
// and must be > z=83 when locked.
JAW_HOOK_Z_UNLOCK = 40;    // hook bottom z unlocked: hook z=40..45, well below z=50
JAW_HOOK_Z_LOCK   = 83.5;  // hook bottom z locked: hook z=83.5..88.5, above z=83

// ─── New tray ────────────────────────────────────────────────────────────────
module new_tray() {
    color("#1565C0")
    difference() {
        cube([NTX, NTY, NTZ]);
        translate([WALL, WALL, WALL])
            cube([NTX-2*WALL, NTY-2*WALL, NTZ-WALL+0.1]);
    }
}

// ─── Single C-jaw ────────────────────────────────────────────────────────────
// side=0 → left (x=0 outer face),  side=1 → right (x=NTX outer face)
// lock_state drives Z position of jaw
module c_jaw(side, lock_state) {
    hook_z = lock_state==1 ? JAW_HOOK_Z_LOCK : JAW_HOOK_Z_UNLOCK;
    outer_z0 = hook_z - JAW_H_OUTER;

    // For left (side=0):
    //   Outer flange: x = -(JAW_T+JAW_GAP) .. -JAW_GAP    [outside tray, x<0]
    //   Gap for wall: x = -JAW_GAP .. END_WALL_T+JAW_GAP   [new tray end wall zone]
    //   Inner arm:    x = END_WALL_T+JAW_GAP .. END_WALL_T+JAW_GAP+JAW_T  [inside tray]
    // For right (side=1): mirror at x=NTX

    // Build C-jaw as three separate parts to ensure manifold geometry
    // (union of outer flange + web at bottom + inner arm)

    // Sign-corrected x positions
    of_x  = side==0 ? -(JAW_T+JAW_GAP) : NTX+JAW_GAP;      // outer flange left x
    ia_x  = side==0 ?  END_WALL_T+JAW_GAP : NTX-END_WALL_T-JAW_GAP-JAW_T; // inner arm left x
    web_x = side==0 ? -(JAW_T+JAW_GAP) : NTX-END_WALL_T-JAW_GAP-JAW_T;  // web left x
    web_w = side==0 ? (END_WALL_T+JAW_GAP+JAW_T + JAW_T+JAW_GAP)
                    : (END_WALL_T+JAW_GAP+JAW_T + JAW_T+JAW_GAP); // total span

    color("#D84315")
    translate([0, JAW_Y0, 0])
    union() {
        // Outer flange (runs full height on outside of tray end)
        translate([of_x, 0, outer_z0])
            cube([JAW_T, JAW_YW, JAW_H_OUTER + HOOK_H]);

        // Bottom web connecting outer flange to inner arm base
        translate([web_x, 0, outer_z0])
            cube([web_w, JAW_YW, 3]);

        // Inner arm (starts at inner face of tray end wall + clearance)
        // Runs only JAW_H_INNER tall from the hook position down
        translate([ia_x, 0, hook_z - JAW_H_INNER])
            cube([JAW_T, JAW_YW, JAW_H_INNER + HOOK_H]);

        // Thumb tab for pushing jaw up (on outer flange side)
        translate([of_x - (side==0?4:0), JAW_YW/2-10, hook_z - 10])
            cube([JAW_T + 4, 20, 10]);
    }
}

// ─── New assembly ─────────────────────────────────────────────────────────────
module new_assembly(lock_state) {
    new_tray();
    c_jaw(0, lock_state);   // left jaw
    c_jaw(1, lock_state);   // right jaw
}

// ─── Render ───────────────────────────────────────────────────────────────────
if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
