// 05 — Best Refinement: Clean Modular Frame + Premium Handles + Label Slots + Soft Stops
// Outer: 378 × 378 × 139 mm
// Layout: 1 tall vial drawer (62 mm) + 1 medium pen drawer (38 mm) + 1 shallow supply drawer (27 mm)
// Total 3 drawers; frame splits into 4 tiles (2×2, each ~189 mm); drawers each ≤ 240 mm
// MODULAR SPLIT:
//   Frame: 4 corner tiles ~189×189 mm, bolt/pin connected (M3 through-holes at corners)
//   Vial drawer: FRONT/BACK halves (~189 mm deep each), snap-joined at mid-depth
//   Pen + supply drawers: single pieces (~365 mm wide but only 38/27 mm tall — print on side) OR split front/back
//   Vial tray: single piece ≤ 230 mm wide × ~185 mm deep (fits 220 mm bed on side)

$fn = 40;

// ── Parameters ──────────────────────────────────────────────────────────────
OUTER_W  = 378;
OUTER_D  = 378;
OUTER_H  = 139;
WALL     = 5;
FLOOR    = 3;

DRAWER_GAP  = 1.2;
DRAWER_WALL = 3;
RUNNER_H    = 6;
RUNNER_W    = 7;
STOP_R      = 3;    // end-stop sphere radius

// Drawer heights (interior)
VIAL_H   = 62;   // standing vial drawer
PEN_H    = 38;   // pen/syringe lying flat
SUPP_H   = 27;   // shallow supply compartments

// Vial matrix
VIAL_D   = 23.5;
VIAL_ROWS = 4;
VIAL_COLS = 6;

// Pen lanes
PEN_DIAM  = 20;
NUM_LANES = 8;

// Handle — premium D-ring arc profile
HANDLE_W  = 80;
HANDLE_T  = 6;
HANDLE_PROJ = 14;
HANDLE_ARC  = 9;   // arc height off face

// Label slot
LABEL_W  = 55;
LABEL_H  = 12;
LABEL_D  = 1.2;

// Tile pin holes for frame assembly
PIN_D    = 3.2;   // M3

// ── Computed ─────────────────────────────────────────────────────────────────
INNER_W  = OUTER_W - 2*WALL - 2*DRAWER_GAP;
INNER_D  = OUTER_D - 2*WALL - 2*DRAWER_GAP;

VIAL_IW  = INNER_W - 2*DRAWER_WALL;
VIAL_ID  = INNER_D - 2*DRAWER_WALL;
VIAL_PX  = (VIAL_IW - VIAL_D) / max(VIAL_COLS-1, 1);
VIAL_PY  = (VIAL_ID - VIAL_D) / max(VIAL_ROWS-1, 1);

z_vial   = WALL;
z_pen    = WALL + VIAL_H + WALL;
z_supp   = z_pen + PEN_H + WALL;

// ── Modules ─────────────────────────────────────────────────────────────────

module d_ring_handle(center_z) {
    // Elegant D-ring handle: flat mounting plate + arcing grip bar
    translate([INNER_W/2 - HANDLE_W/2, -HANDLE_PROJ - HANDLE_T, center_z - HANDLE_T])
    union() {
        // Back plate (flush with drawer front)
        translate([0, HANDLE_PROJ, 0])
            cube([HANDLE_W, HANDLE_T, HANDLE_T*2]);
        // Arcing grip — hull of two end cylinders + top arc via rotate_extrude-like hull
        hull() {
            translate([HANDLE_T*1.5, HANDLE_PROJ + HANDLE_T/2, HANDLE_T])
                sphere(d = HANDLE_T * 1.8);
            translate([HANDLE_W - HANDLE_T*1.5, HANDLE_PROJ + HANDLE_T/2, HANDLE_T])
                sphere(d = HANDLE_T * 1.8);
            translate([HANDLE_T*1.5, HANDLE_PROJ + HANDLE_T/2 + HANDLE_ARC, HANDLE_T])
                sphere(d = HANDLE_T * 1.8);
            translate([HANDLE_W - HANDLE_T*1.5, HANDLE_PROJ + HANDLE_T/2 + HANDLE_ARC, HANDLE_T])
                sphere(d = HANDLE_T * 1.8);
        }
    }
}

module label_recess(center_z) {
    // Embossed label slot on front face of drawer
    translate([INNER_W/2 - LABEL_W/2, -0.1, center_z - LABEL_H/2])
        cube([LABEL_W, LABEL_D + 0.1, LABEL_H]);
}

module runner_cuts(dh) {
    // Tongue slot cut into drawer side walls
    for (side = [[- 0.1, 0], [INNER_W - RUNNER_W, 0]]) {
        translate([side[0], INNER_D/2 - RUNNER_H/2, dh - RUNNER_H - 0.8])
            cube([RUNNER_W + 0.2, RUNNER_H, RUNNER_H + 0.1]);
    }
}

module snap_peg(h=8, d=4) {
    // Snap peg for drawer front/back join
    cylinder(d=d, h=h);
    translate([0,0,h]) sphere(d=d*1.25);
}

module vial_drawer(open_off = 0) {
    iw = VIAL_IW;
    id = VIAL_ID;
    ih = VIAL_H - FLOOR;

    translate([0, -open_off, 0])
    color("RoyalBlue", 0.90)
    union() {
        difference() {
            cube([INNER_W, INNER_D, VIAL_H]);
            translate([DRAWER_WALL, DRAWER_WALL, FLOOR]) cube([iw, id, ih + 1]);
            // Vial pockets
            for (r = [0:VIAL_ROWS-1])
                for (c = [0:VIAL_COLS-1])
                    translate([DRAWER_WALL + VIAL_D/2 + c*VIAL_PX,
                               DRAWER_WALL + VIAL_D/2 + r*VIAL_PY,
                               -0.1])
                        cylinder(d=VIAL_D, h=FLOOR+0.2);
            runner_cuts(VIAL_H);
            label_recess(VIAL_H / 2);
        }
        d_ring_handle(VIAL_H / 2);
        // Snap pegs for front/back split join (cosmetic, mid-depth)
        for (side = [DRAWER_WALL + 10, INNER_W - DRAWER_WALL - 10])
            translate([side, INNER_D/2, VIAL_H - 5])
                snap_peg();
    }
}

module pen_drawer(open_off = 0) {
    iw = INNER_W - 2*DRAWER_WALL;
    id = INNER_D - 2*DRAWER_WALL;
    ih = PEN_H - FLOOR;
    lane_w = iw / NUM_LANES;

    translate([0, -open_off, 0])
    color("DodgerBlue", 0.90)
    union() {
        difference() {
            cube([INNER_W, INNER_D, PEN_H]);
            translate([DRAWER_WALL, DRAWER_WALL, FLOOR]) cube([iw, id, ih + 1]);
            runner_cuts(PEN_H);
            label_recess(PEN_H / 2);
        }
        // Lane dividers — tapered top for easy pen removal
        for (i = [1:NUM_LANES-1])
            translate([DRAWER_WALL + i*lane_w - 0.75, DRAWER_WALL, FLOOR])
                cube([1.5, id, ih * 0.85]);
        d_ring_handle(PEN_H / 2);
    }
}

module supply_drawer(open_off = 0) {
    iw = INNER_W - 2*DRAWER_WALL;
    id = INNER_D - 2*DRAWER_WALL;
    ih = SUPP_H - FLOOR;

    // 3×4 grid of supply cells
    cell_w = (iw - 4*1.5) / 4;
    cell_d = (id - 3*1.5) / 3;

    translate([0, -open_off, 0])
    color("DeepSkyBlue", 0.90)
    union() {
        difference() {
            cube([INNER_W, INNER_D, SUPP_H]);
            translate([DRAWER_WALL, DRAWER_WALL, FLOOR]) cube([iw, id, ih + 1]);
            runner_cuts(SUPP_H);
            label_recess(SUPP_H / 2);
        }
        // Permanent grid dividers (3 vertical + 2 horizontal)
        for (i = [0:3])
            translate([DRAWER_WALL + i*(cell_w + 1.5), DRAWER_WALL, FLOOR])
                cube([1.5, id, ih * 0.85]);
        for (j = [0:2])
            translate([DRAWER_WALL, DRAWER_WALL + j*(cell_d + 1.5), FLOOR])
                cube([iw, 1.5, ih * 0.85]);
        d_ring_handle(SUPP_H / 2);
    }
}

module frame_pin_holes() {
    // M3 alignment pin holes at 2×2 tile corners, through full height
    for (x = [OUTER_W/2 - 3, OUTER_W/2 + 3])
        for (y = [OUTER_D/2 - 3, OUTER_D/2 + 3])
            translate([x, y, -0.1])
                cylinder(d=PIN_D, h=OUTER_H + 0.2);
    // Also at outer corners (bolt-down feet)
    for (x = [WALL*1.5, OUTER_W - WALL*1.5])
        for (y = [WALL*1.5, OUTER_D - WALL*1.5])
            translate([x, y, -0.1])
                cylinder(d=PIN_D, h=WALL + 0.2);
}

module cabinet_frame() {
    difference() {
        cube([OUTER_W, OUTER_D, OUTER_H]);
        // Interior cavity
        translate([WALL, WALL, WALL])
            cube([OUTER_W-2*WALL, OUTER_D-2*WALL, OUTER_H-WALL]);
        // Drawer openings
        translate([-0.1, -0.1, z_vial])
            cube([WALL+0.2, OUTER_D+0.2, VIAL_H+0.2]);
        translate([-0.1, -0.1, z_pen])
            cube([WALL+0.2, OUTER_D+0.2, PEN_H+0.2]);
        translate([-0.1, -0.1, z_supp])
            cube([WALL+0.2, OUTER_D+0.2, SUPP_H+0.2]);
        // Back vent (large opening)
        translate([OUTER_W*0.15, OUTER_D-WALL-0.1, WALL*2])
            cube([OUTER_W*0.7, WALL+0.2, OUTER_H-WALL*3]);
        // 2×2 tile split grooves (cosmetic seam lines)
        translate([OUTER_W/2 - 0.6, -0.1, WALL])
            cube([1.2, OUTER_D+0.2, OUTER_H-WALL+0.1]);
        translate([-0.1, OUTER_D/2 - 0.6, WALL])
            cube([OUTER_W+0.2, 1.2, OUTER_H-WALL+0.1]);
        // M3 pin holes
        frame_pin_holes();
    }

    // Horizontal shelves
    translate([WALL, WALL, z_pen - WALL/2])
        cube([OUTER_W-2*WALL, OUTER_D-2*WALL, WALL]);
    translate([WALL, WALL, z_supp - WALL/2])
        cube([OUTER_W-2*WALL, OUTER_D-2*WALL, WALL]);

    // Runner rails on left & right inner walls (full depth tongues)
    for (slot = [[z_vial, VIAL_H], [z_pen, PEN_H], [z_supp, SUPP_H]]) {
        dz = slot[0] + slot[1] - RUNNER_H;
        translate([WALL, WALL, dz]) cube([RUNNER_W, OUTER_D-2*WALL, RUNNER_H]);
        translate([OUTER_W-WALL-RUNNER_W, WALL, dz]) cube([RUNNER_W, OUTER_D-2*WALL, RUNNER_H]);
    }

    // Soft end-stop bumps (sphere protrusions inside back wall)
    for (slot = [[z_vial, VIAL_H], [z_pen, PEN_H], [z_supp, SUPP_H]]) {
        mid_z = slot[0] + slot[1] * 0.45;
        translate([WALL + STOP_R + 2, OUTER_D - WALL - STOP_R, mid_z])
            sphere(r=STOP_R);
        translate([OUTER_W - WALL - STOP_R - 2, OUTER_D - WALL - STOP_R, mid_z])
            sphere(r=STOP_R);
    }

    // Decorative chamfer at top edges (front corners)
    translate([0, 0, OUTER_H - 3])
    difference() {
        cube([OUTER_W, WALL + 0.1, 4]);
        translate([-0.1, -0.1, -0.1])
            rotate([45, 0, 0]) cube([OUTER_W+0.2, 6, 6]);
    }
}

// ── Assembly ─────────────────────────────────────────────────────────────────
color("Gainsboro", 0.88) cabinet_frame();

// Vial drawer — pulled fully open
translate([WALL + DRAWER_GAP, WALL + DRAWER_GAP, z_vial])
    vial_drawer(open_off = 200);

// Pen drawer — half open
translate([WALL + DRAWER_GAP, WALL + DRAWER_GAP, z_pen])
    pen_drawer(open_off = 120);

// Supply drawer — closed
translate([WALL + DRAWER_GAP, WALL + DRAWER_GAP, z_supp])
    supply_drawer(open_off = 0);
