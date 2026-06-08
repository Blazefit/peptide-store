// 01_bayonet_bar.scad
// WILDCARD: PUSH-IN WEDGE-BAR FRONT LOCK
//
// Mechanism: A horizontal wedge bar slides into the FRONT open slot of the
// already-seated top tray (z=59..74, front y=0..3). The bar has a
// trapezoidal cross-section; as it slides in (pushed from front/outside),
// its angled top face wedges UP under the front top rail (z=75..78),
// clamping the top tray down. The bar is captive via two end-stop tabs on
// the new tray. A 90-degree quarter-turn thumb latch at center LOCKS the bar
// in-place (over-center pin that drops into a detent in the bar).
//
// This is a DIFFERENT approach from A/B/C:
//   - No slide-bolt (A), no corner twist-cams (B), no flip-levers (C)
//   - Single-action: slide bar in from front, thumb-latch clicks
//   - Positive capture: wedge jams top tray rail against bar top
//   - Door flush: everything stays within y=0..101.6
//
// Coordinates: origin = front-left-bottom of new tray, z=50 = new tray top face

show="all"; // [all,new,top]
lock=1;     // 0=unlocked (bar retracted), 1=locked (bar wedged in)

include <../top_ref.scad>

$fn = 48;

// ── New tray dimensions ──────────────────────────────────────────────────────
NTX = 304.8;
NTY = 101.6;
NTZ = 50;
WALL = 3;

// ── Key seated z-heights (absolute, base=50) ────────────────────────────────
SLOT_BOT = 59;   // front open slot bottom z=59
SLOT_TOP = 74;   // front open slot top z=74
RAIL_BOT = 75;   // top rail bottom face
RAIL_TOP = 78;   // top rail top face (side top edge)
END_TOP  = 83;   // end wall top z

// ── Wedge bar geometry ───────────────────────────────────────────────────────
// Bar sits in front slot. Width spans tray interior (x=3..301.8 = 298.8mm).
// Height 10mm fits easily in 15mm slot (59..74).
// Wedge taper: top face angled 8° so pushing in (increasing Y) lifts front rail.
// In locked state bar is fully inserted at y=0..10 (front wall outside face to y=10).
// Wait — front wall is y=0..3 (inside face y=3). Bar must reach INTO slot.
// Bar is at z=SLOT_BOT+2=61, occupying z=61..68.
// In UNLOCKED: bar at y = -12 (retracted, outside front face)
// In LOCKED: bar at y = 0..10 (inserted into slot, behind front wall inner face y=3..10)

// Corner posts in top tray: x=0..6 and x=298.8..304.8, y=0..6 full height
// Bar must clear corners — start x=7, end x=297.8
BAR_X0  = 8;          // bar starts x=8 (clear of corner posts x=0..6)
BAR_X1  = 296.8;      // bar ends x=296.8 (clear of corner posts x=298.8..304.8)
BAR_LEN = BAR_X1 - BAR_X0;   // 288.8 mm
BAR_H   = 10;         // bar body height
BAR_Y_DEPTH = 10;     // how deep bar goes into slot (Y direction)
BAR_Z0  = SLOT_BOT + 2;      // z=61 (bar bottom face)
BAR_Z1  = BAR_Z0 + BAR_H;    // z=71

// Wedge: top surface of bar is angled so that at y=10 insertion the bar top
// face at y=10 is at BAR_Z1 but at y=0 it is BAR_Z1-WEDGE_RISE
WEDGE_RISE = 3;   // top face rises 3mm over 10mm depth -> grabs rail

// In locked state: bar inserted, angled top presses rail from below
// Bar travels 13mm in Y: unlocked at y=-13..(-3), locked at y=0..10

BAR_Y_UNLOCK = -13;   // bar back face Y when unlocked (protruding forward)
BAR_Y_LOCK   = 0;     // bar front face Y when locked (flush with outer tray face)

// ── Guide rails on new tray (keep bar captive in X and Z) ───────────────────
// Two short guide tabs at x-ends, on the front face of new tray, z=60..72
GUIDE_W   = 8;
GUIDE_H   = BAR_H + 4;
GUIDE_D   = 14;   // depth in Y of guide (holds bar in Z while inserting)

// ── Center latch pin ─────────────────────────────────────────────────────────
// A small quarter-turn knob sits at center-X on the front face.
// When rotated 90° (CW = lock), a pin sweeps over the bar and prevents retraction.
// Knob is on a small boss on the new tray front face (between tray top and bar).
LATCH_X   = NTX / 2;
LATCH_Z   = 46;         // center of latch knob (below tray top face z=50)
LATCH_R   = 9;          // knob radius
LATCH_D   = 10;         // knob protrusion in -Y from front face
LATCH_PIN_R = 3;
LATCH_PIN_L = GUIDE_D;  // pin sweeps over bar

module new_tray() {
    color("#1565C0")
    difference() {
        cube([NTX, NTY, NTZ]);
        translate([WALL, WALL, WALL])
            cube([NTX-2*WALL, NTY-2*WALL, NTZ - WALL + 0.1]);
        // Slot in front wall for bar passage (z=61..71, full width x=3..301.8)
        translate([BAR_X0, -0.1, BAR_Z0])
            cube([BAR_LEN, WALL + 0.2, BAR_H]);
    }
    // Guide rails at each end of bar slot
    color("#1565C0")
    for (sx = [0, 1]) {
        gx = sx == 0 ? BAR_X0 - GUIDE_W : BAR_X1;
        translate([gx, -GUIDE_D, BAR_Z0 - 2])
            cube([GUIDE_W, GUIDE_D, GUIDE_H]);
    }
    // Latch boss on front face (cylindrical boss for latch pivot)
    color("#1565C0")
    translate([LATCH_X, -3, LATCH_Z])
    rotate([90, 0, 0])
        cylinder(r=LATCH_R+2, h=6, $fn=24);
}

// ── Wedge bar ────────────────────────────────────────────────────────────────
module wedge_bar(y_pos) {
    // y_pos: front face Y of the bar
    // Bar with angled top face (wedge profile) — use hull of two rectangles
    color("#D84315")
    // Front face of bar at y_pos, bottom at BAR_Z0
    // Wedge: front top at z = BAR_Z0 + BAR_H - WEDGE_RISE, back top at z = BAR_Z0 + BAR_H
    hull() {
        // Front bottom edge
        translate([BAR_X0, y_pos, BAR_Z0])
            cube([BAR_LEN, 0.1, BAR_H - WEDGE_RISE]);
        // Back bottom edge (full height)
        translate([BAR_X0, y_pos + BAR_Y_DEPTH - 0.1, BAR_Z0])
            cube([BAR_LEN, 0.1, BAR_H]);
    }
}

// ── Latch knob ───────────────────────────────────────────────────────────────
// Quarter-turn knob on front face at center. Rotates 90° to lock.
// lock=0: pin points up (clear of bar), lock=1: pin points inward (over bar)
module latch_knob(lock_state) {
    knob_angle = lock_state * 90;  // 0° = up (unlocked), 90° = inward (locked)
    color("#D84315")
    translate([LATCH_X, -3, LATCH_Z])
    rotate([90, 0, 0]) {
        // Knob body (octagonal)
        cylinder(r=LATCH_R, h=LATCH_D, $fn=8);
        // Latch pin (rotates with knob)
        rotate([0, 0, knob_angle])
        translate([0, LATCH_R*0.5, 0])
            cylinder(r=LATCH_PIN_R, h=LATCH_PIN_L + 3, $fn=12);
    }
}

// ── New assembly ─────────────────────────────────────────────────────────────
module new_assembly(lock_state) {
    new_tray();
    // Bar position: locked = inserted (y=0), unlocked = retracted (y=-13)
    bar_y = lock_state == 1 ? BAR_Y_LOCK : BAR_Y_UNLOCK;
    wedge_bar(bar_y);
    latch_knob(lock_state);
}

// ── Render ───────────────────────────────────────────────────────────────────
if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
