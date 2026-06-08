// 01_tall_finger.scad
// RETROFIT ATTACHMENT — Version 1: Single Tall Finger per Side
//
// NEW tray (z=0..50, blue) has ONE wide upward finger on EACH long-side
// outer face, rising past the top tray wall and hooking inward into the
// CENTER window (window 1) of the TOP tray.
//
// TOP tray (z=50..83, grey) is FIXED — ZERO geometry added to it.
// All attachment features live ONLY on the NEW tray.
//
// explode=0 → engaged   explode=1 → parts separated for inspection

explode = 0;   // change to 1 for exploded view

// ── Global dimensions ─────────────────────────────────────────────────────
W    = 305;   // tray length (X)
D    = 102;   // tray depth (Y)
Hn   = 50;    // new tray height
Ht   = 33;    // top tray height
wall = 3;     // wall thickness (both trays)

// ── Top-tray window geometry (EXISTING features — read-only) ──────────────
win_w  = 45;   // window width  (X)
win_h  = 16;   // window height (Z)
win_zc = 64;   // window centre Z (absolute)
// 3 windows per long side, evenly spaced:  X = W/4, W/2, 3W/4
function win_cx(i) = W * (i+1) / 4;   // i = 0,1,2

// ── Clip geometry (all on NEW tray) ───────────────────────────────────────
fng_t    = 2.8;   // finger wall thickness
fng_w    = 40;    // finger width (X)  — slightly less than win_w
root_z   = 5;     // how far the finger base drops below new-tray top
hook_dep = 2.5;   // inward hook depth (engages window edge)
hook_h   = 4.0;   // hook block height
lead_in  = 1.5;   // chamfer on hook leading edge

// Absolute Z of hook bottom (engages lower half of window)
hook_z = win_zc - win_h/2 + 2;   // 2 mm above window lower edge

// ── Explode offset ────────────────────────────────────────────────────────
expl = 45 * explode;

// ── Colors ────────────────────────────────────────────────────────────────
c_new  = [0.22, 0.55, 0.85, 1.00];   // blue   – new tray
c_top  = [0.80, 0.80, 0.80, 0.80];   // grey   – top tray (semi-transparent)
c_clip = [0.95, 0.42, 0.08, 1.00];   // orange – fingers/clips

// ═══════════════════════════════════════════════════════════════════════════
// TOP TRAY  — FIXED, modelled only for context (never modified)
// ═══════════════════════════════════════════════════════════════════════════
module top_tray() {
    color(c_top)
    translate([0, 0, Hn + expl])
    difference() {
        cube([W, D, Ht]);
        // hollow interior (open top)
        translate([wall, wall, -0.01])
            cube([W-2*wall, D-2*wall, Ht-wall+0.01]);
        // 3 windows on front wall (y=0)
        for (i=[0:2]) {
            translate([win_cx(i)-win_w/2, -0.01, (win_zc-Hn)-win_h/2])
                cube([win_w, wall+0.02, win_h]);
        }
        // 3 windows on back wall (y=D)
        for (i=[0:2]) {
            translate([win_cx(i)-win_w/2, D-wall-0.01, (win_zc-Hn)-win_h/2])
                cube([win_w, wall+0.02, win_h]);
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// NEW TRAY BODY  — hollow box, no top face
// ═══════════════════════════════════════════════════════════════════════════
module new_tray_body() {
    color(c_new)
    difference() {
        cube([W, D, Hn]);
        translate([wall, wall, wall])
            cube([W-2*wall, D-2*wall, Hn]);  // open top
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// TALL FINGER CLIP  (attached to NEW tray, hooks TOP tray center window)
// side=0 → front face (Y=0), side=1 → back face (Y=D)
// ═══════════════════════════════════════════════════════════════════════════
module tall_finger(side) {
    cx    = win_cx(1);                       // center window
    y0    = (side==0) ? -fng_t : D;          // outer face position
    inwd  = (side==0) ? 1 : -1;              // inward direction in Y

    color(c_clip) {
        // ── vertical stem, roots 'root_z' below tray top ──────────────────
        stem_bot = Hn - root_z;
        stem_top = hook_z + hook_h + 2;      // just above hook
        translate([cx - fng_w/2, y0, stem_bot])
            cube([fng_w, fng_t, stem_top - stem_bot]);

        // ── inward hook nose with chamfered lead-in ────────────────────────
        // Hull: full hook depth at bottom, taper to flush at top
        translate([cx - fng_w/2, y0, hook_z])
        hull() {
            cube([fng_w, fng_t + hook_dep, hook_h]);
            translate([0, inwd * (-hook_dep), hook_h - lead_in])
                cube([fng_w, fng_t, lead_in + 0.01]);
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// ASSEMBLY
// ═══════════════════════════════════════════════════════════════════════════
new_tray_body();
tall_finger(0);   // front
tall_finger(1);   // back
top_tray();
