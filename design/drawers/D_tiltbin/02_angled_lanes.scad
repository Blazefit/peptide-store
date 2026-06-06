// 02 — Fixed Angled Lanes / Sloped Shelves
// Three sloped lanes (front-low, back-high) so vials are visible from above.
// Syringes rest in side channels along lane walls.
// Outer envelope: 375 × 375 × 130 mm
// Splits: 3 lane modules (each 120×375×130) snap together side-by-side + base tray
// Capacity: 3 lanes × 14 vials = 42 vials; 6 syringes (2 per lane side)

$fn = $fn > 0 ? $fn : 40;

/* ── Parameters ──────────────────────────────────────────── */
outer_w = 375;
outer_d = 375;
outer_h = 130;
wall    = 3.0;
n_lanes = 3;
lane_w  = (outer_w - wall*(n_lanes+1)) / n_lanes;  // ~119 mm

slope_front_h = 12;   // height of shelf at front edge
slope_back_h  = 90;   // height at back edge (creates ~11° slope over 375 mm)
slope_angle   = atan((slope_back_h - slope_front_h) / outer_d);

vial_r  = 11;
vial_h  = 52;
pen_r   = 9.5;
pen_len = 160;

lane_col  = [0.88, 0.75, 0.40];
base_col  = [0.30, 0.42, 0.60];
vial_col  = [0.65, 0.92, 0.82, 0.85];
pen_col   = [0.95, 0.60, 0.55, 0.90];

/* ── Base / outer tray ───────────────────────────────────── */
module base_tray() {
    color(base_col)
    difference() {
        cube([outer_w, outer_d, slope_front_h]);
        translate([wall, wall, wall])
            cube([outer_w-wall*2, outer_d-wall*2, slope_front_h]);
    }
}

/* ── One angled lane module (prints separately) ─────────── */
module lane_module(i) {
    lw = lane_w;
    ld = outer_d;
    color(lane_col)
    union() {
        // Left wall — full angled profile
        linear_extrude(wall)
        polygon([[0,0],[lw,0],[lw,ld],[0,ld]]);

        // Two side divider walls (left and right of channel)
        for (side=[0,1]) {
            translate([side*(lw-wall), 0, 0])
            difference() {
                // angled side wall
                linear_extrude(wall)
                    square([wall, ld]);
                // not needed for shape
            }
            // rebuild as solid side walls using hull
        }
        // Angled floor of the lane
        hull() {
            translate([0, 0, slope_front_h])
                cube([lw, wall, wall]);
            translate([0, ld-wall, slope_back_h])
                cube([lw, wall, wall]);
        }

        // Front retaining lip
        translate([0, 0, slope_front_h])
            cube([lw, wall*2, wall*2.5]);

        // Vial divider pegs on the slope (14 positions)
        n_vials = 14;
        for (k=[0:n_vials-1]) {
            frac = (k+0.5)/n_vials;
            py = frac * (ld - wall*3) + wall;
            pz = slope_front_h + frac*(slope_back_h-slope_front_h);
            translate([lw/2, py, pz])
                cylinder(r=1.5, h=8);
        }

        // Syringe channel on left side wall (recessed shelf)
        translate([0, wall, slope_front_h+wall*2])
        rotate([0, slope_angle, 0])
        {
            // thin shelf for pen to rest on
            cube([wall*2, pen_len, wall]);
        }
    }
}

/* ── Vials on slope ────────────────────────────────────────── */
module vials_on_lane(lw) {
    n = 14;
    for (k=[0:n-1]) {
        frac = (k+0.5)/n;
        py = frac*(outer_d-wall*3)+wall;
        pz = slope_front_h+frac*(slope_back_h-slope_front_h);
        translate([lw/2, py, pz+wall])
        // tilt vial to be perpendicular to slope
        rotate([-slope_angle, 0, 0])
        color(vial_col) cylinder(r=vial_r, h=vial_h);
    }
}

/* ── Syringes ─────────────────────────────────────────────── */
module syringe_on_lane(lw) {
    translate([lw/2, outer_d*0.5, slope_front_h + 18])
    rotate([0, 90, 0])
    color(pen_col) cylinder(r=pen_r, h=pen_len, center=true);
}

/* ── Assemble ─────────────────────────────────────────────── */
base_tray();

for (i=[0:n_lanes-1]) {
    tx = wall + i*(lane_w+wall);
    translate([tx, 0, 0]) {
        lane_module(i);
        vials_on_lane(lane_w);
        syringe_on_lane(lane_w);
    }
}

// Outer side walls
color(base_col) {
    cube([wall, outer_d, outer_h]);
    translate([outer_w-wall, 0, 0]) cube([wall, outer_d, outer_h]);
}

// Rubber feet
color([0.15,0.15,0.15])
for (x=[15, outer_w-15], y=[15, outer_d-15])
    translate([x, y, -4]) cylinder(r=5.5, h=4);
