// 01_pushbar.scad — Multipoint Push-Bar Slide-Bolt
// Place-then-secure: lower top tray straight down (loose, ~0.6mm), then push the
// front bar +Y to drive tongues ABOVE the front top-rail (seated z=75..78),
// blocking any lift once locked.
//
// Capture logic:
//   - Top tray front top-rail seated at y=0..3, z=75..78 (solid)
//   - Above the top rail at y=0..3, z=78..83 is EMPTY (between rail top and corner top)
//   - Tongue tip sits at z=78.5 (0.5mm clear of rail top) in that empty space
//   - On +2mm lift the top rail moves to z=77..80: tongue at z=78.5..80.5 overlaps
//   - In UNLOCKED: tongue retracts to y<0 (outside tray) → zero overlap

show  = "all";  // [all, new, top]
lock  = 1;      // 0=unlocked  1=locked

include <../top_ref.scad>

// ── Tray dims ──────────────────────────────────────────────────────────────
T_X   = 304.8;
T_Y   = 101.6;
T_Z   = 50;
T_W   = 3;

// ── Bar / housing ─────────────────────────────────────────────────────────
// Housing sits on the front face of the new tray (y=0..3 is the front wall)
// Housing block: y = -12..0,  z = 36..50
HSG_D    = 12;      // depth in -Y
HSG_H    = 14;      // height
HSG_Z0   = T_Z - HSG_H;     // = 36
BAR_D    = 8;       // bar depth in Y
BAR_H    = 8;       // bar height
BAR_CLR  = 0.3;     // print-in-place clearance
BAR_Z0   = HSG_Z0 + (HSG_H - BAR_H) / 2;  // = 39
BAR_TRAVEL = 8;     // mm of +Y push to lock

lock_dy  = lock ? BAR_TRAVEL : 0;

// ── Tongue geometry ────────────────────────────────────────────────────────
// The tongue is a thin vertical blade that rides on the bar.
// Stem (below tray top = z<50): stays at y=-12..bar_front → no overlap with top tray
// Cap (above tray top = z>50): extends from bar_front_y to y=T_W when locked
//
// CRITICAL: only the portion z > 78.5 is at y=0..T_W; the rest is at y<0.
// We split: "arm" connects bar to "cap".

TONG_CAP_Z0  = 78.5;    // bottom of cap (0.5mm clear of top rail top at z=78)
TONG_CAP_Z1  = 81.5;    // top of cap (below corner top z=83)
TONG_CAP_TH  = T_W;     // cap thickness in Y = 3mm (fills y=0..3 when locked)
TONG_CAP_W   = 60;      // each cap width in X

// In locked: bar front face at y = -BAR_D + BAR_TRAVEL = 0
// Cap at y = bar_front .. bar_front + TONG_CAP_TH = 0..3
// In unlocked: bar front at y = -BAR_D = -8
// Cap at y = -8..-5  → completely outside y=0..T_Y

// Four cap positions, away from corners (corner posts x=0..6 & x=298.8..304.8)
TONG_CX = [50, 110, 180, 240];

// ── End-cap hooks on bar (catch over short end wall top z=83) ─────────────
// Short-end walls: x=0..3 & x=301.8..304.8, solid to z=83
// Hook lip sits at z=83.5 when locked, in the same bar +Y slide
// (bar slides from y=HSG_D inward; at full lock, hook is at y=0..2)
// Hook dims:
HOOK_Z0  = 50;      // hook base (at new tray top)
HOOK_Z1  = 84.5;    // hook lip top (above end-wall top z=83)
HOOK_LIP = 1.5;     // lip overhang in +X / -X over end wall
HOOK_W   = 4;       // hook body width in X (sits just outside end wall)
HOOK_TH  = T_W;     // thickness in Y

// Arm (rises from bar top, stays at y<0 until locked)
// Arm goes from bar top (z=BAR_Z0+BAR_H=47) up to TONG_CAP_Z0=78.5
// Arm stays in Y: same as bar (retracts to y<0 when unlocked)
ARM_TH   = 2;       // arm thickness in Y

// ─────────────────────────────────────────────────────────────────────────
module new_tray() {
    color("#1565C0") {
        cube([T_X, T_W, T_Z]);                          // front wall
        translate([0, T_Y-T_W, 0]) cube([T_X, T_W, T_Z]);   // back wall
        cube([T_W, T_Y, T_Z]);                          // left wall
        translate([T_X-T_W, 0, 0]) cube([T_W, T_Y, T_Z]);   // right wall
        cube([T_X, T_Y, T_W]);                          // floor
    }
}

module housing_block() {
    // Shell, y=-HSG_D..0, z=HSG_Z0..T_Z
    color("#F9A825") {
        difference() {
            translate([0, -HSG_D, HSG_Z0]) cube([T_X, HSG_D, HSG_H]);
            // Bar channel (print-in-place)
            translate([-1, -BAR_D - BAR_CLR, BAR_Z0 - BAR_CLR])
                cube([T_X+2, BAR_D + BAR_CLR, BAR_H + 2*BAR_CLR]);
            // Finger opening in front face (centre span)
            translate([T_X/2 - 22, -HSG_D - 1, BAR_Z0 - 1])
                cube([44, 6, BAR_H + 2]);
        }
    }
}

module bar_with_tongues() {
    bar_y0 = -BAR_D + lock_dy;   // y of bar rear face
    bar_yf = bar_y0 + BAR_D;     // y of bar front face  (= lock_dy - 0 = 0 when locked)

    color("#C62828") {
        // ── Bar body ──
        translate([0, bar_y0, BAR_Z0])
            cube([T_X, BAR_D, BAR_H]);

        // ── Tongue caps: only at z=78.5..81.5, positioned at bar front face ──
        for (cx = TONG_CX) {
            tx0 = cx - TONG_CAP_W/2;
            tx1 = cx + TONG_CAP_W/2;
            tx0c = max(tx0, 7);
            tx1c = min(tx1, 297.8);
            tw   = tx1c - tx0c;
            if (tw > 5) {
                // Cap: at bar front face, extending +Y by TONG_CAP_TH
                // z = TONG_CAP_Z0..TONG_CAP_Z1
                translate([tx0c, bar_yf, TONG_CAP_Z0])
                    cube([tw, TONG_CAP_TH, TONG_CAP_Z1 - TONG_CAP_Z0]);
                // Arm: connects bar top (z=BAR_Z0+BAR_H) up to cap bottom
                // Arm at bar front face position, ARM_TH thick
                translate([tx0c, bar_yf, BAR_Z0 + BAR_H])
                    cube([tw, ARM_TH, TONG_CAP_Z0 - (BAR_Z0 + BAR_H)]);
            }
        }

        // ── Finger tab ──
        translate([T_X/2 - 15, bar_y0 - 5, BAR_Z0])
            cube([30, 5, BAR_H]);
    }
}

module back_passive_rail() {
    // Passive Y-capture: 2mm rail flush with back face (y=101.6)
    // Sits in back open slot (y=98.6..101.6, z=59..74 — empty)
    // Does not extend past y=101.6
    color("#F9A825") {
        for (cx = [50, 152, 250]) {
            translate([cx - 15, T_Y - 2, 60])
                cube([30, 2, 12]);
        }
    }
}

module new_assembly(lk) {
    new_tray();
    housing_block();
    bar_with_tongues();
    back_passive_rail();
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
