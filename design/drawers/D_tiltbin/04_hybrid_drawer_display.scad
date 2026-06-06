// 04 — Hybrid: Pull Drawer (bottom) + Angled Open Vial Display (top)
// Lower zone: 2 full-width pull drawers for syringes / supplies
// Upper zone: 3-column angled vial display (front-low angle ~15°)
// Outer envelope: 375 × 375 × 130 mm
// Splits: outer box left/right halves (≤188×375×130), drawers fit inside (≤230×175 mm)
// Capacity: top display ~36 vials; 2 drawers × 3 syringes each = 6 syringes + small supplies

$fn = $fn > 0 ? $fn : 40;

/* ── Parameters ──────────────────────────────────────────── */
outer_w   = 375;
outer_d   = 375;
outer_h   = 130;
wall      = 3.0;

drawer_h  = 44;    // height of each pull drawer
n_drawers = 2;
drawer_zone_h = n_drawers * drawer_h + wall*(n_drawers+1);  // ~95 mm

display_h = outer_h - drawer_zone_h - wall;  // ~32 mm (angled display zone)
disp_cols = 3;
disp_angle = 18;   // degrees forward tilt

vial_r    = 11;
vial_h    = 52;
pen_r     = 9.5;
pen_len   = 155;

box_col    = [0.28, 0.38, 0.58];
drawer_col = [0.70, 0.78, 0.92];
disp_col   = [0.88, 0.72, 0.35];
vial_col   = [0.70, 0.93, 0.85, 0.82];
pen_col    = [0.95, 0.60, 0.55, 0.88];
pull_col   = [0.55, 0.55, 0.60];

/* ── Outer box shell (left half, ≤188×375×130) ──────────── */
module box_left() {
    hw = outer_w/2;
    color(box_col)
    difference() {
        cube([hw, outer_d, outer_h]);
        // interior cutout
        translate([wall, wall, wall])
            cube([hw-wall*2, outer_d-wall*2, outer_h-wall]);
        // drawer face openings
        for (d=[0:n_drawers-1]) {
            z0 = wall + d*(drawer_h+wall);
            translate([wall-0.1, -0.1, z0])
                cube([hw-wall*2+0.2, wall+0.2, drawer_h]);
        }
    }
}

/* ── Outer box shell (right half) ─────────────────────────── */
module box_right() {
    hw = outer_w/2;
    translate([hw, 0, 0])
    color(box_col)
    difference() {
        cube([hw, outer_d, outer_h]);
        translate([wall, wall, wall])
            cube([hw-wall*2, outer_d-wall*2, outer_h-wall]);
        for (d=[0:n_drawers-1]) {
            z0 = wall + d*(drawer_h+wall);
            translate([wall-0.1, -0.1, z0])
                cube([hw-wall*2+0.2, wall+0.2, drawer_h]);
        }
    }
}

/* ── Divider shelf between drawers and display ──────────── */
module divider_shelf() {
    color(box_col)
    translate([0, 0, drawer_zone_h])
        cube([outer_w, outer_d, wall]);
}

/* ── Pull Drawer (prints within 230×175 mm) ─────────────── */
module pull_drawer(dw, which=0) {
    dh = drawer_h - 1;
    dd = outer_d - wall*3;
    color(drawer_col)
    difference() {
        cube([dw, dd, dh]);
        translate([wall, wall, wall])
            cube([dw-wall*2, dd-wall, dh-wall]);
    }
    // Pull handle
    color(pull_col)
    translate([dw/2, -wall*0.5, dh*0.5])
    rotate([90,0,0])
    difference() {
        cylinder(r=10, h=wall*1.5, center=true);
        cylinder(r=7, h=wall*1.5+0.2, center=true);
    }

    // Syringe cradles inside drawer
    n_pens = 3;
    sp = (dw - wall*2) / n_pens;
    for (i=[0:n_pens-1]) {
        cx = wall + sp*(i+0.5);
        translate([cx, dd*0.5, wall+pen_r+2])
        rotate([0,90,0])
        color(pen_col) cylinder(r=pen_r, h=pen_len, center=true);
    }
}

/* ── Angled display section (3-col vial holders) ─────────── */
module angled_display() {
    col_w = (outer_w - wall*(disp_cols+1)) / disp_cols;  // ~119 mm
    dz    = drawer_zone_h + wall;
    n_v_per_col = 12;
    spacing_y   = (outer_d - wall*2) / n_v_per_col;

    for (c=[0:disp_cols-1]) {
        cx = wall + c*(col_w+wall);

        // Column back wall (structural)
        color(disp_col)
        translate([cx, 0, dz]) {
            // angled ramp surface
            hull() {
                translate([0, 0, 0])          cube([col_w, wall, wall]);
                translate([0, outer_d-wall, display_h-2]) cube([col_w, wall, wall]);
            }
            // left divider
            cube([wall, outer_d, display_h]);
        }

        // Vials along this column
        for (k=[0:n_v_per_col-1]) {
            py  = wall + spacing_y*(k+0.5);
            frac = py / outer_d;
            pz  = dz + wall + frac*(display_h-wall*3);
            translate([cx + col_w/2, py, pz])
            rotate([-disp_angle, 0, 0])
            color(vial_col) cylinder(r=vial_r, h=vial_h);
        }
    }
    // Rightmost wall
    color(disp_col) translate([outer_w-wall, 0, dz]) cube([wall, outer_d, display_h]);
}

/* ── Drawers pulled out slightly for display ──────────────── */
module drawers_shown() {
    pull_out = [55, 0];   // top drawer pulled out 55 mm
    dw = outer_w - wall*2;
    for (d=[0:n_drawers-1]) {
        z0 = wall + d*(drawer_h+wall);
        translate([wall, wall - pull_out[d], z0 + 0.5])
            pull_drawer(dw, d);
    }
}

/* ── Assemble ─────────────────────────────────────────────── */
box_left();
box_right();
divider_shelf();
drawers_shown();
angled_display();

// Back wall
color(box_col) translate([0, outer_d-wall, 0]) cube([outer_w, wall, outer_h]);
// Bottom
color(box_col) cube([outer_w, outer_d, wall]);

// Feet
color([0.15,0.15,0.15])
for (x=[15, outer_w-15], y=[15, outer_d-15])
    translate([x, y, -4]) cylinder(r=5.5, h=4);
