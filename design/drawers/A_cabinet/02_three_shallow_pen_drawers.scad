// 02 — Three Shallow Drawers for Pens/Syringes & Supplies (lying flat)
// Outer: 375 × 375 × 136 mm
// Three drawers, each ~36 mm interior height, with lane dividers
// MODULAR SPLIT: frame = LEFT half + RIGHT half (~187.5 mm each)
//                each drawer = FRONT half + BACK half (~187.5 mm each)

$fn = 40;

// ── Parameters ──────────────────────────────────────────────────────────────
OUTER_W = 375;
OUTER_D = 375;
OUTER_H = 136;
WALL    = 4;
FLOOR   = 2.5;

NUM_DRAWERS  = 3;
DRAWER_GAP   = 1.2;
DRAWER_H     = 38;    // interior ~35 mm for lying pens (Ø19 mm)
DRAWER_WALL  = 2.5;
RUNNER_H     = 5;
RUNNER_W     = 5;

// Pen / syringe lanes
PEN_D        = 20;    // Ø19 + clearance
PEN_LEN      = 165;
LANE_W       = PEN_D + 2;
NUM_LANES    = 8;     // lanes per drawer

// Small supply section (front 1/3 of drawer)
SUPPLY_SECTION_D = 100;

// Handle
HANDLE_W     = 70;
HANDLE_H     = 12;
HANDLE_PROJ  = 10;
HANDLE_T     = 4.5;

// ── Modules ─────────────────────────────────────────────────────────────────

module lane_dividers(num_lanes, lane_w, depth, height) {
    // Thin walls separating pen lanes
    for (i = [1:num_lanes-1])
        translate([i * lane_w, 0, 0])
            cube([1.5, depth, height]);
}

module handle_bar() {
    hull() {
        translate([HANDLE_T, HANDLE_PROJ - 0.5, HANDLE_T])
            sphere(d = HANDLE_T * 2);
        translate([HANDLE_W - HANDLE_T, HANDLE_PROJ - 0.5, HANDLE_T])
            sphere(d = HANDLE_T * 2);
        translate([HANDLE_T, 0.5, HANDLE_T])
            sphere(d = HANDLE_T * 2);
        translate([HANDLE_W - HANDLE_T, 0.5, HANDLE_T])
            sphere(d = HANDLE_T * 2);
    }
}

module drawer_body(open_offset = 0) {
    iw = OUTER_W - 2*WALL - 2*DRAWER_GAP - 2*DRAWER_WALL;
    id = OUTER_D - 2*WALL - 2*DRAWER_GAP - 2*DRAWER_WALL;
    ih = DRAWER_H - FLOOR;

    translate([0, -open_offset, 0])
    {
        difference() {
            cube([OUTER_W - 2*WALL - 2*DRAWER_GAP,
                  OUTER_D - 2*WALL - 2*DRAWER_GAP,
                  DRAWER_H]);
            // Interior pocket
            translate([DRAWER_WALL, DRAWER_WALL, FLOOR])
                cube([iw, id, ih + 1]);
            // Runner tongue slots
            translate([-0.1,
                       (OUTER_D - 2*WALL - 2*DRAWER_GAP)/2 - RUNNER_H/2,
                       DRAWER_H - RUNNER_H - 0.5])
                cube([RUNNER_W + 0.1, RUNNER_H, RUNNER_H]);
            translate([OUTER_W - 2*WALL - 2*DRAWER_GAP - RUNNER_W,
                       (OUTER_D - 2*WALL - 2*DRAWER_GAP)/2 - RUNNER_H/2,
                       DRAWER_H - RUNNER_H - 0.5])
                cube([RUNNER_W + 0.1, RUNNER_H, RUNNER_H]);
        }
        // Lane dividers (pen section — rear 2/3)
        translate([DRAWER_WALL,
                   DRAWER_WALL + SUPPLY_SECTION_D,
                   FLOOR])
            lane_dividers(NUM_LANES,
                          iw / NUM_LANES,
                          id - SUPPLY_SECTION_D,
                          ih * 0.9);
        // Supply section divider (cross-wall)
        translate([DRAWER_WALL,
                   DRAWER_WALL + SUPPLY_SECTION_D - 1.5,
                   FLOOR])
            cube([iw, 1.5, ih * 0.9]);
        // Supply sub-dividers (3 cells)
        for (i = [1:2])
            translate([DRAWER_WALL + i * iw/3,
                       DRAWER_WALL,
                       FLOOR])
                cube([1.5, SUPPLY_SECTION_D - 1.5, ih * 0.9]);
        // Handle
        translate([iw/2 + DRAWER_WALL - HANDLE_W/2,
                   -HANDLE_PROJ,
                   DRAWER_H/2 - HANDLE_H/2])
            handle_bar();
    }
}

module cabinet_frame() {
    difference() {
        cube([OUTER_W, OUTER_D, OUTER_H]);
        // Interior
        translate([WALL, WALL, WALL])
            cube([OUTER_W - 2*WALL, OUTER_D - 2*WALL, OUTER_H - WALL]);
        // Drawer openings (front face)
        for (i = [0:NUM_DRAWERS-1]) {
            dz = WALL + i * (DRAWER_H + WALL);
            translate([-0.1, -0.1, dz])
                cube([WALL + 0.2,
                      OUTER_D + 0.2,
                      DRAWER_H + 0.2]);
        }
        // Back vent
        translate([OUTER_W*0.2, OUTER_D - WALL - 0.1, WALL*2])
            cube([OUTER_W*0.6, WALL + 0.2, OUTER_H - WALL*4]);
    }
    // Horizontal shelf dividers
    for (i = [1:NUM_DRAWERS-1]) {
        dz = WALL + i * (DRAWER_H + WALL) - WALL/2;
        translate([WALL, WALL, dz])
            cube([OUTER_W - 2*WALL, OUTER_D - 2*WALL, WALL]);
    }
    // Runner rails
    for (i = [0:NUM_DRAWERS-1]) {
        dz = WALL + i * (DRAWER_H + WALL) + DRAWER_H - RUNNER_H;
        translate([WALL, WALL, dz])
            cube([RUNNER_W, OUTER_D - 2*WALL, RUNNER_H]);
        translate([OUTER_W - WALL - RUNNER_W, WALL, dz])
            cube([RUNNER_W, OUTER_D - 2*WALL, RUNNER_H]);
    }
    // End-stop bumps
    for (i = [0:NUM_DRAWERS-1]) {
        dz = WALL + i * (DRAWER_H + WALL) + DRAWER_H/2;
        translate([WALL + 3, OUTER_D - WALL - 5, dz])
            sphere(d = 4);
        translate([OUTER_W - WALL - 3, OUTER_D - WALL - 5, dz])
            sphere(d = 4);
    }
}

// ── Assembly ─────────────────────────────────────────────────────────────────
color("DimGray", 0.85)
    cabinet_frame();

// Bottom & middle drawers — closed
for (i = [0:1]) {
    color(i == 0 ? "Teal" : "MediumSeaGreen", 0.88)
    translate([WALL + DRAWER_GAP,
               WALL + DRAWER_GAP,
               WALL + i * (DRAWER_H + WALL)])
        drawer_body(open_offset = 0);
}

// Top drawer — pulled open
color("MediumAquamarine", 0.88)
translate([WALL + DRAWER_GAP,
           WALL + DRAWER_GAP,
           WALL + 2 * (DRAWER_H + WALL)])
    drawer_body(open_offset = 200);
