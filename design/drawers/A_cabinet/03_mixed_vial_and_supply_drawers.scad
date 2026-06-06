// 03 — Mixed: One Tall Vial Drawer + Two Shallow Supply Drawers
// Outer: 372 × 372 × 138 mm
// Drawer 1 (bottom): 66 mm tall — standing vials 4×6 matrix
// Drawers 2 & 3 (top): 28 mm tall — pens lying flat + small supplies
// MODULAR SPLIT: frame LEFT/RIGHT halves (~186 mm each)
//                tall drawer: FRONT/BACK halves; shallow drawers: single piece ≤240 mm

$fn = 40;

// ── Parameters ──────────────────────────────────────────────────────────────
OUTER_W = 372;
OUTER_D = 372;
OUTER_H = 138;
WALL    = 4;
FLOOR   = 3;

DRAWER_GAP   = 1.2;
DRAWER_WALL  = 3;
RUNNER_H     = 5;
RUNNER_W     = 5;

// Tall vial drawer
VIAL_DRW_H   = 66;
VIAL_D       = 23;
VIAL_ROWS    = 4;
VIAL_COLS    = 6;

// Shallow supply drawers
SHAL_DRW_H   = 28;
NUM_SHAL     = 2;

// Handle
HANDLE_W     = 65;
HANDLE_T     = 5;
HANDLE_PROJ  = 11;

// ── Computed ─────────────────────────────────────────────────────────────────
INNER_W = OUTER_W - 2*WALL - 2*DRAWER_GAP;
INNER_D = OUTER_D - 2*WALL - 2*DRAWER_GAP;

VIAL_PITCH_X = (INNER_W - 2*DRAWER_WALL - VIAL_D) / (VIAL_COLS - 1);
VIAL_PITCH_Y = (INNER_D - 2*DRAWER_WALL - VIAL_D) / (VIAL_ROWS - 1);

// ── Modules ─────────────────────────────────────────────────────────────────

module d_handle(drawer_h) {
    translate([INNER_W/2 - HANDLE_W/2, -HANDLE_PROJ, drawer_h/2 - HANDLE_T])
    hull() {
        translate([HANDLE_T, HANDLE_PROJ*0.8, HANDLE_T]) sphere(d = HANDLE_T*2);
        translate([HANDLE_W - HANDLE_T, HANDLE_PROJ*0.8, HANDLE_T]) sphere(d = HANDLE_T*2);
        translate([HANDLE_T, 0, HANDLE_T]) sphere(d = HANDLE_T*2);
        translate([HANDLE_W - HANDLE_T, 0, HANDLE_T]) sphere(d = HANDLE_T*2);
    }
}

module runner_slots(drawer_h) {
    // Cut runner tongue slots
    translate([-0.1,
               INNER_D/2 - RUNNER_H/2,
               drawer_h - RUNNER_H - 0.5])
        cube([RUNNER_W + 0.1, RUNNER_H, RUNNER_H]);
    translate([INNER_W - RUNNER_W,
               INNER_D/2 - RUNNER_H/2,
               drawer_h - RUNNER_H - 0.5])
        cube([RUNNER_W + 0.1, RUNNER_H, RUNNER_H]);
}

module vial_drawer(open_off = 0) {
    iw = INNER_W - 2*DRAWER_WALL;
    id = INNER_D - 2*DRAWER_WALL;
    ih = VIAL_DRW_H - FLOOR;

    translate([0, -open_off, 0])
    union() {
        difference() {
            cube([INNER_W, INNER_D, VIAL_DRW_H]);
            translate([DRAWER_WALL, DRAWER_WALL, FLOOR])
                cube([iw, id, ih + 1]);
            translate([DRAWER_WALL + VIAL_D/2,
                       DRAWER_WALL + VIAL_D/2,
                       -0.1])
                for (r = [0:VIAL_ROWS-1])
                    for (c = [0:VIAL_COLS-1])
                        translate([c * VIAL_PITCH_X, r * VIAL_PITCH_Y, 0])
                            cylinder(d = VIAL_D, h = FLOOR + 0.2);
            runner_slots(VIAL_DRW_H);
        }
        d_handle(VIAL_DRW_H);
    }
}

module shallow_drawer(open_off = 0) {
    iw = INNER_W - 2*DRAWER_WALL;
    id = INNER_D - 2*DRAWER_WALL;
    ih = SHAL_DRW_H - FLOOR;

    translate([0, -open_off, 0])
    union() {
        difference() {
            cube([INNER_W, INNER_D, SHAL_DRW_H]);
            translate([DRAWER_WALL, DRAWER_WALL, FLOOR])
                cube([iw, id, ih + 1]);
            runner_slots(SHAL_DRW_H);
        }
        // Pen lanes (6 lanes)
        pen_lane_w = iw / 6;
        for (i = [1:5])
            translate([DRAWER_WALL + i * pen_lane_w, DRAWER_WALL, FLOOR])
                cube([1.5, id * 0.65, ih * 0.85]);
        // Supply cross wall
        translate([DRAWER_WALL, DRAWER_WALL + id * 0.65, FLOOR])
            cube([iw, 1.5, ih * 0.85]);
        // Supply cells (3)
        for (i = [1:2])
            translate([DRAWER_WALL + i * iw/3, DRAWER_WALL + id * 0.65, FLOOR])
                cube([1.5, id * 0.35, ih * 0.85]);
        d_handle(SHAL_DRW_H);
    }
}

module cabinet_frame() {
    // Z positions of each drawer slot
    z0 = WALL;                                 // vial drawer
    z1 = WALL + VIAL_DRW_H + WALL;            // shallow 1
    z2 = z1 + SHAL_DRW_H + WALL;             // shallow 2

    difference() {
        cube([OUTER_W, OUTER_D, OUTER_H]);
        // Interior cavity
        translate([WALL, WALL, WALL])
            cube([OUTER_W - 2*WALL, OUTER_D - 2*WALL, OUTER_H - WALL]);
        // Drawer openings front face
        translate([-0.1, -0.1, z0])
            cube([WALL + 0.2, OUTER_D + 0.2, VIAL_DRW_H]);
        translate([-0.1, -0.1, z1])
            cube([WALL + 0.2, OUTER_D + 0.2, SHAL_DRW_H]);
        translate([-0.1, -0.1, z2])
            cube([WALL + 0.2, OUTER_D + 0.2, SHAL_DRW_H]);
        // Back vent
        translate([OUTER_W*0.25, OUTER_D - WALL - 0.1, WALL*2])
            cube([OUTER_W*0.5, WALL + 0.2, OUTER_H - WALL*4]);
    }

    // Horizontal shelves between drawer zones
    translate([WALL, WALL, z1 - WALL/2])
        cube([OUTER_W - 2*WALL, OUTER_D - 2*WALL, WALL]);
    translate([WALL, WALL, z2 - WALL/2])
        cube([OUTER_W - 2*WALL, OUTER_D - 2*WALL, WALL]);

    // Runner rails per slot
    for (slot = [[z0, VIAL_DRW_H], [z1, SHAL_DRW_H], [z2, SHAL_DRW_H]]) {
        dz = slot[0] + slot[1] - RUNNER_H;
        translate([WALL, WALL, dz]) cube([RUNNER_W, OUTER_D - 2*WALL, RUNNER_H]);
        translate([OUTER_W - WALL - RUNNER_W, WALL, dz]) cube([RUNNER_W, OUTER_D - 2*WALL, RUNNER_H]);
    }

    // Label recesses (front face, shallow emboss)
    for (slot = [[z0, VIAL_DRW_H], [z1, SHAL_DRW_H], [z2, SHAL_DRW_H]]) {
        translate([OUTER_W*0.35, -0.1, slot[0] + slot[1]/2 - 5])
            cube([OUTER_W*0.3, 1.5, 10]);
    }
}

// ── Assembly ─────────────────────────────────────────────────────────────────
z1 = WALL + VIAL_DRW_H + WALL;
z2 = z1 + SHAL_DRW_H + WALL;

color("DarkSlateGray", 0.85) cabinet_frame();

// Vial drawer — pulled open
color("IndianRed", 0.88)
translate([WALL + DRAWER_GAP, WALL + DRAWER_GAP, WALL])
    vial_drawer(open_off = 170);

// Shallow drawer 1 — closed
color("Salmon", 0.88)
translate([WALL + DRAWER_GAP, WALL + DRAWER_GAP, z1])
    shallow_drawer(open_off = 0);

// Shallow drawer 2 — slightly open
color("LightSalmon", 0.88)
translate([WALL + DRAWER_GAP, WALL + DRAWER_GAP, z2])
    shallow_drawer(open_off = 80);
