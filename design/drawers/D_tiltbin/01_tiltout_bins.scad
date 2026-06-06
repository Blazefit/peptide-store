// 01 — Front Tilt-Out Bins
// Frame holds 3 columns × 2 rows of tilt-out bins.
// Each bin pivots at its front-bottom edge to tip open.
// Outer envelope: 375 × 375 × 130 mm
// Splits: left-frame half, right-frame half, and individual bins (each ≤ 185×160 mm)
// Capacity: 12 bins × ~4 vials each = ~48 vials standing; syringes lie in dedicated bins
// $fn handled via CLI -D '$fn=40'

$fn = $fn > 0 ? $fn : 40;

/* ── Parameters ──────────────────────────────────────────── */
outer_w   = 375;   // X
outer_d   = 375;   // Y
outer_h   = 130;   // Z
wall      = 3.0;
cols      = 3;
rows      = 2;
bin_w     = (outer_w - wall*(cols+1)) / cols;   // ~121 mm
bin_h     = (outer_h - wall*(rows+1)) / rows;   // ~61 mm
bin_d     = outer_d - wall*2 - 8;              // ~361 mm deep inside frame

tilt_angle = 35;   // shown open
vial_r     = 11;
vial_h     = 52;

/* ── Colours ─────────────────────────────────────────────── */
frame_col = [0.25, 0.45, 0.65];
bin_col   = [0.85, 0.88, 0.92];
vial_col  = [0.7, 0.93, 0.85, 0.8];

/* ── Frame shell (split into left/right halves at x=half) ── */
module frame_shell() {
    color(frame_col)
    difference() {
        cube([outer_w, outer_d, outer_h]);
        // hollow interior — each cell opening
        for (c=[0:cols-1], r=[0:rows-1]) {
            x0 = wall + c*(bin_w+wall);
            z0 = wall + r*(bin_h+wall);
            translate([x0, wall, z0])
                cube([bin_w, outer_d-wall*2, bin_h]);
        }
        // front face openings (taller for tilt clearance)
        for (c=[0:cols-1], r=[0:rows-1]) {
            x0 = wall + c*(bin_w+wall);
            z0 = wall + r*(bin_h+wall);
            translate([x0, -0.1, z0])
                cube([bin_w, wall+0.2, bin_h]);
        }
    }
}

/* ── One tilt-out bin body ─────────────────────────────────
   pivot = front-bottom edge; shown at tilt_angle open        */
module one_bin(open=true) {
    ang = open ? tilt_angle : 0;
    bw  = bin_w - 0.6;
    bh  = bin_h - 0.6;
    bd  = bin_d;

    rotate([ang, 0, 0])
    color(bin_col)
    difference() {
        cube([bw, bd, bh]);
        // interior cavity
        translate([wall, wall, wall])
            cube([bw-wall*2, bd-wall, bh-wall]);
        // front label slot
        translate([wall, -0.1, bh*0.55])
            cube([bw-wall*2, wall*0.6+0.2, bh*0.35]);
    }
}

/* ── Vials inside an open bin ────────────────────────────── */
module vials_in_bin(n=4) {
    bw = bin_w - 0.6;
    bd = bin_d;
    bh = bin_h - 0.6;
    spacing = (bw - wall*2) / n;
    for (i=[0:n-1]) {
        cx = wall + spacing*(i+0.5);
        cy = wall*2 + vial_r;
        translate([cx, cy, wall])
        rotate([0,0,0])
        color(vial_col)
        cylinder(r=vial_r, h=vial_h);
    }
}

/* ── Assemble ─────────────────────────────────────────────── */
// Frame
frame_shell();

// Bins in each cell — top row shown open, bottom row closed
for (c=[0:cols-1]) {
    for (r=[0:rows-1]) {
        x0 = wall + c*(bin_w+wall) + 0.3;
        z0 = wall + r*(bin_h+wall) + 0.3;
        is_open = (r == rows-1);   // top row open
        translate([x0, wall, z0])
        {
            one_bin(open=is_open);
            if (is_open) vials_in_bin(4);
        }
    }
}

// Bottom rubber feet
color([0.2,0.2,0.2])
for (x=[20, outer_w-20], y=[20, outer_d-20])
    translate([x, y, -4]) cylinder(r=6, h=4);
