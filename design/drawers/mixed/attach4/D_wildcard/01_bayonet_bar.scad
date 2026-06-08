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
    outer_z0 = hook_z - JAW_H_OUTER;   // outer flange bottom z

    // Left jaw: outer flange at x = -(JAW_T+JAW_GAP)..-JAW_GAP
    //           inner arm at x = END_WALL_T+JAW_GAP .. END_WALL_T+JAW_GAP+JAW_T
    // Right jaw: mirror in X

    // For left (side=0):
    //   outer flange: x from -(JAW_T+JAW_GAP) to -JAW_GAP
    //   connecting web (C-bottom): x from -(JAW_T+JAW_GAP) to END_WALL_T+JAW_GAP+JAW_T
    //   inner arm: x from END_WALL_T+JAW_GAP to END_WALL_T+JAW_GAP+JAW_T
    of_x0 = side==0 ? -(JAW_T+JAW_GAP) : NTX+JAW_GAP;
    of_x1 = side==0 ? -JAW_GAP         : NTX+JAW_GAP+JAW_T;
    ia_x0 = side==0 ? END_WALL_T+JAW_GAP         : NTX-END_WALL_T-JAW_GAP-JAW_T;
    ia_x1 = side==0 ? END_WALL_T+JAW_GAP+JAW_T   : NTX-END_WALL_T-JAW_GAP;
    // C-web x span
    web_x0 = min(of_x0, ia_x0);
    web_x1 = max(of_x1, ia_x1);
    web_h  = 3;  // web height at bottom of C

    color("#D84315")
    translate([0, JAW_Y0, 0])
    union() {
        // Outer flange (long, stays on outside of new tray end face)
        translate([of_x0, 0, outer_z0])
            cube([JAW_T, JAW_YW, JAW_H_OUTER]);

        // C-web connecting outer flange to inner arm (at bottom)
        translate([web_x0, 0, outer_z0])
            cube([web_x1-web_x0, JAW_YW, web_h]);

        // Inner arm (short, rises to hook over top tray end wall)
        translate([ia_x0, 0, hook_z - JAW_H_INNER])
            cube([JAW_T, JAW_YW, JAW_H_INNER]);

        // Hook nose bridges gap over end wall top: x=0..END_WALL_T+(HOOK_DEPTH/2)
        // This means for left (side=0): hook x from -(JAW_GAP) to END_WALL_T+JAW_GAP+JAW_T
        //                 i.e. from ~-0.6 to ~7.6 covering x=0..3 (end wall top)
        // For right (side=1): mirror — hook from NTX-END_WALL_T-JAW_GAP-JAW_T to NTX+JAW_GAP
        hook_x0 = side==0 ? -JAW_GAP : NTX-END_WALL_T-JAW_GAP-JAW_T;
        hook_x1 = side==0 ? END_WALL_T+JAW_GAP+JAW_T : NTX+JAW_GAP;
        translate([hook_x0, 0, hook_z])
            cube([hook_x1-hook_x0, JAW_YW, HOOK_H]);

        // Thumb push tab on outer flange (finger grip to push jaw up)
        translate([of_x0, JAW_YW/2-8, hook_z - 8])
            cube([JAW_T + 6, 16, 8]);
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
