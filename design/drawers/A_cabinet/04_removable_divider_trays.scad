// 04 — Drawers with Removable Internal Dividers / Drop-in Vial Trays
// Outer: 376 × 376 × 138 mm
// Two drawer sizes: one tall (65 mm) for drop-in vial trays, two medium (28 mm) for supplies
// MODULAR SPLIT: frame = LEFT + RIGHT halves (~188 mm each, pegged together)
//                drawers = single pieces ≤ 240 mm (fit as-is)
//                vial tray = two halves (~180 mm each)
//                divider inserts = individual pieces ~80–120 mm

$fn = 40;

// ── Parameters ──────────────────────────────────────────────────────────────
OUTER_W  = 376;
OUTER_D  = 376;
OUTER_H  = 138;
WALL     = 4.5;
FLOOR    = 3;

DRAWER_GAP  = 1.5;
DRAWER_WALL = 3;
RUNNER_H    = 6;
RUNNER_W    = 6;

// Tall drawer (vial tray host)
TALL_H      = 65;
// Medium drawers
MED_H       = 26;
NUM_MED     = 2;

// Vial tray (drop-in)
TRAY_WALL   = 2;
TRAY_FLOOR  = 2;
VIAL_D      = 23.5;
VIAL_ROWS   = 4;
VIAL_COLS   = 6;

// Divider inserts for medium drawers
DIV_T       = 2;    // divider thickness

// Handle — T-bar profile
HANDLE_W    = 72;
HANDLE_H    = 15;
HANDLE_PROJ = 13;
HANDLE_T    = 5.5;

// ── Computed ─────────────────────────────────────────────────────────────────
INNER_W  = OUTER_W - 2*WALL - 2*DRAWER_GAP;
INNER_D  = OUTER_D - 2*WALL - 2*DRAWER_GAP;
TRAY_W   = INNER_W - 2*DRAWER_WALL - 2;   // slight clearance inside drawer
TRAY_D   = INNER_D - 2*DRAWER_WALL - 2;
TRAY_IW  = TRAY_W - 2*TRAY_WALL;
TRAY_ID  = TRAY_D - 2*TRAY_WALL;
VIAL_PX  = (TRAY_IW - VIAL_D) / max(VIAL_COLS - 1, 1);
VIAL_PY  = (TRAY_ID - VIAL_D) / max(VIAL_ROWS - 1, 1);

// ── Modules ─────────────────────────────────────────────────────────────────

module t_bar_handle(h_center) {
    // T-bar: vertical stem + horizontal bar, clean radiused look
    translate([INNER_W/2 - HANDLE_W/2, -HANDLE_PROJ, h_center - HANDLE_H/2])
    union() {
        // Horizontal grip bar
        hull() {
            translate([HANDLE_T, HANDLE_PROJ - 1, HANDLE_T])
                rotate([-90,0,0]) cylinder(d=HANDLE_T*2, h=1);
            translate([HANDLE_W - HANDLE_T, HANDLE_PROJ - 1, HANDLE_T])
                rotate([-90,0,0]) cylinder(d=HANDLE_T*2, h=1);
            translate([HANDLE_T, 1, HANDLE_T])
                rotate([-90,0,0]) cylinder(d=HANDLE_T*2, h=1);
            translate([HANDLE_W - HANDLE_T, 1, HANDLE_T])
                rotate([-90,0,0]) cylinder(d=HANDLE_T*2, h=1);
        }
        // Mounting stem
        translate([HANDLE_W/2 - HANDLE_T, 0, 0])
            cube([HANDLE_T*2, HANDLE_PROJ, HANDLE_H]);
    }
}

module runner_cut(dh) {
    translate([-0.1, INNER_D/2 - RUNNER_H/2, dh - RUNNER_H - 0.5])
        cube([RUNNER_W + 0.1, RUNNER_H, RUNNER_H + 0.1]);
    translate([INNER_W - RUNNER_W, INNER_D/2 - RUNNER_H/2, dh - RUNNER_H - 0.5])
        cube([RUNNER_W + 0.1, RUNNER_H, RUNNER_H + 0.1]);
}

module drawer_shell(dw, dh) {
    // Generic drawer shell with interior pocket and runner cuts
    iw = dw - 2*DRAWER_WALL;
    id = INNER_D - 2*DRAWER_WALL;
    difference() {
        cube([dw, INNER_D, dh]);
        translate([DRAWER_WALL, DRAWER_WALL, FLOOR])
            cube([iw, id, dh]);
        runner_cut(dh);
    }
}

module vial_tray() {
    // Drop-in tray with vial pocket matrix; sits inside tall drawer
    color("Goldenrod", 0.92)
    difference() {
        cube([TRAY_W, TRAY_D, TALL_H - FLOOR - 2]);
        // Interior scoop
        translate([TRAY_WALL, TRAY_WALL, TRAY_FLOOR])
            cube([TRAY_IW, TRAY_ID, TALL_H]);
        // Vial pocket cylinders
        for (r = [0:VIAL_ROWS-1])
            for (c = [0:VIAL_COLS-1])
                translate([TRAY_WALL + VIAL_D/2 + c*VIAL_PX,
                           TRAY_WALL + VIAL_D/2 + r*VIAL_PY,
                           -0.1])
                    cylinder(d=VIAL_D, h=TRAY_FLOOR + 1);
    }
}

module tall_drawer(open_off = 0) {
    translate([0, -open_off, 0]) {
        color("SteelBlue", 0.88)
        union() {
            drawer_shell(INNER_W, TALL_H);
            t_bar_handle(TALL_H / 2);
        }
        // Vial tray dropped in — offset slightly from drawer walls
        translate([DRAWER_WALL + 1, DRAWER_WALL + 1, FLOOR])
            vial_tray();
    }
}

module divider_insert(slot_w, slot_d, slot_h, num_x, num_y) {
    // Grid of cross-lap dividers for supply drawer
    wall = DIV_T;
    for (i = [0:num_x])
        translate([i * slot_w, 0, 0])
            cube([wall, slot_d * num_y + wall*(num_y+1), slot_h * 0.8]);
    for (j = [0:num_y])
        translate([0, j * slot_d, 0])
            cube([slot_w * num_x + wall*(num_x+1), wall, slot_h * 0.8]);
}

module med_drawer(open_off = 0, show_dividers = true) {
    iw = INNER_W - 2*DRAWER_WALL;
    id = INNER_D - 2*DRAWER_WALL;
    ih = MED_H - FLOOR;

    translate([0, -open_off, 0]) {
        color("MediumSlateBlue", 0.88)
        union() {
            drawer_shell(INNER_W, MED_H);
            t_bar_handle(MED_H / 2);
        }
        // Drop-in divider grid: 4 cols × 3 rows of supply cells
        if (show_dividers) {
            cell_w = (iw - DIV_T*5) / 4;
            cell_d = (id - DIV_T*4) / 3;
            color("Wheat", 0.9)
            translate([DRAWER_WALL + DIV_T, DRAWER_WALL + DIV_T, FLOOR + 0.5])
                divider_insert(cell_w, cell_d, ih, 3, 2);
        }
    }
}

module cabinet_frame() {
    z_tall = WALL;
    z_med1 = WALL + TALL_H + WALL;
    z_med2 = z_med1 + MED_H + WALL;

    difference() {
        cube([OUTER_W, OUTER_D, OUTER_H]);
        translate([WALL, WALL, WALL])
            cube([OUTER_W-2*WALL, OUTER_D-2*WALL, OUTER_H-WALL]);
        // Drawer openings
        translate([-0.1, -0.1, z_tall])
            cube([WALL+0.2, OUTER_D+0.2, TALL_H+0.2]);
        translate([-0.1, -0.1, z_med1])
            cube([WALL+0.2, OUTER_D+0.2, MED_H+0.2]);
        translate([-0.1, -0.1, z_med2])
            cube([WALL+0.2, OUTER_D+0.2, MED_H+0.2]);
        // Back vent
        translate([OUTER_W*0.2, OUTER_D-WALL-0.1, WALL*2])
            cube([OUTER_W*0.6, WALL+0.2, OUTER_H-WALL*4]);
        // Frame split groove (left-right join, cosmetic)
        translate([OUTER_W/2 - 0.75, -0.1, WALL])
            cube([1.5, OUTER_D+0.2, OUTER_H-WALL]);
    }

    // Shelves
    translate([WALL, WALL, z_med1 - WALL/2])
        cube([OUTER_W-2*WALL, OUTER_D-2*WALL, WALL]);
    translate([WALL, WALL, z_med2 - WALL/2])
        cube([OUTER_W-2*WALL, OUTER_D-2*WALL, WALL]);

    // Runner rails
    for (slot = [[z_tall, TALL_H], [z_med1, MED_H], [z_med2, MED_H]]) {
        dz = slot[0] + slot[1] - RUNNER_H;
        translate([WALL, WALL, dz]) cube([RUNNER_W, OUTER_D-2*WALL, RUNNER_H]);
        translate([OUTER_W-WALL-RUNNER_W, WALL, dz]) cube([RUNNER_W, OUTER_D-2*WALL, RUNNER_H]);
    }

    // End-stop pegs (half-sphere bumps)
    for (slot = [[z_tall, TALL_H], [z_med1, MED_H], [z_med2, MED_H]]) {
        mid_z = slot[0] + slot[1]/2;
        translate([WALL+3, OUTER_D-WALL-4, mid_z]) sphere(d=5);
        translate([OUTER_W-WALL-3, OUTER_D-WALL-4, mid_z]) sphere(d=5);
    }
}

// ── Assembly ─────────────────────────────────────────────────────────────────
z_tall = WALL;
z_med1 = WALL + TALL_H + WALL;
z_med2 = z_med1 + MED_H + WALL;

color("LightSlateGray", 0.82) cabinet_frame();

// Tall vial drawer — pulled open, tray visible
translate([WALL + DRAWER_GAP, WALL + DRAWER_GAP, z_tall])
    tall_drawer(open_off = 190);

// Med drawer 1 — closed, dividers inside
translate([WALL + DRAWER_GAP, WALL + DRAWER_GAP, z_med1])
    med_drawer(open_off = 0, show_dividers = true);

// Med drawer 2 — slightly open, dividers inside
translate([WALL + DRAWER_GAP, WALL + DRAWER_GAP, z_med2])
    med_drawer(open_off = 90, show_dividers = true);
