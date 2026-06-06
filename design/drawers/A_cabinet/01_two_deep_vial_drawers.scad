// 01 — Two Deep Drawers for Standing Vials
// Outer: 370 × 370 × 138 mm
// Two drawers, each ~62 mm interior height, holding a 5×7 vial matrix
// MODULAR SPLIT: cabinet frame splits into LEFT and RIGHT halves (~185 mm each)
// Each drawer prints as a single piece ~356 × 348 × 64 mm — fits if split front/back
// Drawer split: FRONT half and BACK half, joined by snap pegs

$fn = 40;

// ── Parameters ──────────────────────────────────────────────────────────────
OUTER_W = 370;
OUTER_D = 370;
OUTER_H = 138;
WALL    = 4;
FLOOR   = 3;

// Drawer
NUM_DRAWERS   = 2;
DRAWER_GAP    = 1.2;   // clearance each side
DRAWER_H      = 62;    // interior vial height ~55 mm + floor
DRAWER_WALL   = 3;
RUNNER_H      = 6;
RUNNER_W      = 6;
STOP_D        = 4;

// Vial holes
VIAL_D        = 23;    // Ø23 with clearance
VIAL_ROWS     = 5;
VIAL_COLS     = 7;
VIAL_PITCH_X  = (OUTER_W - 2*WALL - 2*DRAWER_WALL - 2*DRAWER_GAP - VIAL_D) / (VIAL_COLS - 1);
VIAL_PITCH_Y  = (OUTER_D - 2*WALL - 2*DRAWER_WALL - 2*DRAWER_GAP - VIAL_D) / (VIAL_ROWS - 1);

// Handle
HANDLE_W      = 60;
HANDLE_H      = 14;
HANDLE_PROJ   = 12;
HANDLE_T      = 5;

// ── Modules ─────────────────────────────────────────────────────────────────

module vial_matrix(rows, cols, pitch_x, pitch_y) {
    // Grid of cylindrical vial pockets (cut from drawer floor from top)
    for (r = [0:rows-1])
        for (c = [0:cols-1])
            translate([c * pitch_x, r * pitch_y, 0])
                cylinder(d = VIAL_D, h = 50, center = false);
}

module drawer_body(open_offset = 0) {
    // open_offset pulls the drawer forward for exploded view
    iw = OUTER_W - 2*WALL - 2*DRAWER_GAP - 2*DRAWER_WALL;
    id = OUTER_D - 2*WALL - 2*DRAWER_GAP - 2*DRAWER_WALL;
    ih = DRAWER_H - FLOOR;

    translate([0, -open_offset, 0])
    difference() {
        // Outer drawer shell
        cube([OUTER_W - 2*WALL - 2*DRAWER_GAP,
              OUTER_D - 2*WALL - 2*DRAWER_GAP,
              DRAWER_H]);
        // Interior pocket
        translate([DRAWER_WALL, DRAWER_WALL, FLOOR])
            cube([iw, id, ih + 1]);
        // Vial holes in floor
        translate([DRAWER_WALL + VIAL_D/2,
                   DRAWER_WALL + VIAL_D/2,
                   -0.1])
            vial_matrix(VIAL_ROWS, VIAL_COLS, VIAL_PITCH_X, VIAL_PITCH_Y);
        // Runner grooves (sides)
        translate([-0.1, (OUTER_D - 2*WALL - 2*DRAWER_GAP)/2 - RUNNER_H/2, DRAWER_H - RUNNER_H - 1])
            cube([RUNNER_W + 0.1, RUNNER_H, RUNNER_H + 0.1]);
        translate([OUTER_W - 2*WALL - 2*DRAWER_GAP - RUNNER_W,
                   (OUTER_D - 2*WALL - 2*DRAWER_GAP)/2 - RUNNER_H/2,
                   DRAWER_H - RUNNER_H - 1])
            cube([RUNNER_W + 0.1, RUNNER_H, RUNNER_H + 0.1]);
    }
    // Handle on front face
    translate([(OUTER_W - 2*WALL - 2*DRAWER_GAP)/2 - HANDLE_W/2,
               -open_offset - HANDLE_PROJ,
               DRAWER_H/2 - HANDLE_H/2])
        handle_knob();
}

module handle_knob() {
    // Rounded bar handle
    hull() {
        translate([HANDLE_T, HANDLE_PROJ, HANDLE_T])
            rotate([-90, 0, 0])
                cylinder(d = HANDLE_T*2, h = 1);
        translate([HANDLE_W - HANDLE_T, HANDLE_PROJ, HANDLE_T])
            rotate([-90, 0, 0])
                cylinder(d = HANDLE_T*2, h = 1);
        translate([HANDLE_T, 0, HANDLE_T])
            rotate([-90, 0, 0])
                cylinder(d = HANDLE_T*2, h = 1);
        translate([HANDLE_W - HANDLE_T, 0, HANDLE_T])
            rotate([-90, 0, 0])
                cylinder(d = HANDLE_T*2, h = 1);
    }
}

module runner_rail() {
    // Rail that runs inside cabinet wall for drawer to slide on
    id = OUTER_D - 2*WALL;
    cube([RUNNER_W, id, RUNNER_H]);
}

module cabinet_frame() {
    difference() {
        cube([OUTER_W, OUTER_D, OUTER_H]);
        // Main interior cutout
        translate([WALL, WALL, WALL])
            cube([OUTER_W - 2*WALL, OUTER_D - 2*WALL, OUTER_H - WALL]);
        // Two drawer openings in front face
        for (i = [0:NUM_DRAWERS-1]) {
            dz = WALL + i * (DRAWER_H + WALL);
            translate([-0.1, -0.1, dz])
                cube([WALL + 0.2,
                      OUTER_D - 2*WALL + 2*DRAWER_GAP + 0.2,
                      DRAWER_H + 0.2]);
        }
        // Back ventilation slot
        translate([OUTER_W*0.25, OUTER_D - WALL - 0.1, WALL*2])
            cube([OUTER_W*0.5, WALL + 0.2, OUTER_H - WALL*4]);
    }
    // Internal horizontal shelves / drawer dividers
    for (i = [1:NUM_DRAWERS-1]) {
        dz = WALL + i * (DRAWER_H + WALL) - WALL/2;
        translate([WALL, WALL, dz])
            cube([OUTER_W - 2*WALL, OUTER_D - 2*WALL, WALL]);
    }
    // Runner rails on left & right inner walls
    for (i = [0:NUM_DRAWERS-1]) {
        dz = WALL + i * (DRAWER_H + WALL) + DRAWER_H - RUNNER_H;
        // Left rail
        translate([WALL, WALL, dz])
            runner_rail();
        // Right rail
        translate([OUTER_W - WALL - RUNNER_W, WALL, dz])
            runner_rail();
    }
    // Soft end-stop pegs (prevent drawer from pulling out fully)
    for (i = [0:NUM_DRAWERS-1]) {
        dz = WALL + i * (DRAWER_H + WALL) + DRAWER_H/2;
        translate([WALL + 2, OUTER_D - WALL - STOP_D - 2, dz])
            cylinder(d = STOP_D, h = STOP_D, center = true);
        translate([OUTER_W - WALL - 2, OUTER_D - WALL - STOP_D - 2, dz])
            cylinder(d = STOP_D, h = STOP_D, center = true);
    }
}

// ── Assembly ─────────────────────────────────────────────────────────────────
// Cabinet frame
color("SlateGray", 0.85)
    cabinet_frame();

// Bottom drawer — closed
color("SteelBlue", 0.9)
translate([WALL + DRAWER_GAP, WALL + DRAWER_GAP, WALL])
    drawer_body(open_offset = 0);

// Top drawer — pulled open 160 mm for visibility
color("CornflowerBlue", 0.9)
translate([WALL + DRAWER_GAP,
           WALL + DRAWER_GAP,
           WALL + DRAWER_H + WALL])
    drawer_body(open_offset = 160);
