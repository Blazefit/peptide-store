// 01 — Front Tilt-Out Bins
// 3 columns × 2 rows of tilt-out bins in a frame.
// Bins pivot at front-bottom, tip open OUTWARD so contents face up.
// Top row shown fully open, bottom row closed. Vials/syringes visible inside open bins.
// Outer envelope: 375 × 375 × 130 mm
// Splits: left-frame half (≤188×375×130) + right-frame half; bins ≤122×360 mm each
// Capacity: 12 bins × ~4 vials = ~48 vials; 3 bins for syringes lying flat

$fn = $fn > 0 ? $fn : 40;

/* ── Parameters ──────────────────────────────────────────── */
outer_w  = 375;
outer_d  = 375;
outer_h  = 130;
wall     = 3.5;
cols     = 3;
rows     = 2;
bin_w    = (outer_w - wall*(cols+1)) / cols;  // ~119 mm
bin_h    = (outer_h - wall*(rows+1)) / rows;  // ~61 mm
bin_d    = outer_d - wall*2 - 14;             // ~350 mm
tilt_a   = 40;   // degrees open (bins tip outward/downward from frame front)

vial_r   = 11;
vial_h   = 52;
pen_r    = 9.5;

frame_col = [0.22, 0.40, 0.62];
bin_col   = [0.84, 0.88, 0.94];
vial_col  = [0.55, 0.88, 0.76];
pen_col   = [0.93, 0.60, 0.55];
label_col = [1.0, 0.98, 0.80];
foot_col  = [0.18, 0.18, 0.18];

/* ── Frame — open top and open front faces ────────────────── */
module frame() {
    color(frame_col)
    difference() {
        cube([outer_w, outer_d, outer_h]);
        // Remove interior (keep only shell)
        translate([wall, wall, wall])
            cube([outer_w-wall*2, outer_d-wall*2, outer_h]);
        // Remove front face of each bin slot so bins can tilt out
        for (c=[0:cols-1], r=[0:rows-1]) {
            x0 = wall + c*(bin_w+wall);
            z0 = wall + r*(bin_h+wall);
            translate([x0, -1, z0])
                cube([bin_w, wall+2, bin_h+0.5]);
        }
        // Remove top face so bin contents visible from above
        translate([wall, wall, outer_h-wall-0.1])
            cube([outer_w-wall*2, outer_d-wall*2, wall+1]);
    }
    // Add horizontal dividers between rows (retain bin_h spacing)
    color(frame_col)
    for (r=[0:rows]) {
        z0 = r*(bin_h+wall);
        translate([wall, wall, z0]) cube([outer_w-wall*2, outer_d-wall*2, wall]);
    }
}

/* ── Closed bin ──────────────────────────────────────────── */
module bin_closed(bw, bh, bd) {
    color(bin_col)
    difference() {
        cube([bw, bd, bh]);
        translate([wall, wall, wall])
            cube([bw-wall*2, bd-wall, bh-wall]);
        translate([wall*1.5, -1, bh*0.6])
            cube([bw-wall*3, wall*0.5+1, bh*0.3]);
    }
}

/* ── Open bin: rotated about FRONT-BOTTOM edge ──────────────
   Positive tilt_a → top tips AWAY from frame (outward/downward).
   Pivot is at local y=0, z=0, so no translation needed.           */
module bin_open(bw, bh, bd) {
    rotate([tilt_a, 0, 0])    // positive = top tips toward viewer (outward)
    color(bin_col)
    difference() {
        cube([bw, bd, bh]);
        translate([wall, wall, wall])
            cube([bw-wall*2, bd-wall, bh-wall]);
        // finger scoop on front
        translate([bw*0.5, -1, bh*0.28])
            scale([1, 0.65, 1]) cylinder(r=bh*0.3, h=bh*0.55);
        // label recess
        translate([wall*1.5, -1, bh*0.6])
            cube([bw-wall*3, wall*0.5+1, bh*0.3]);
    }
}

module vials_open(bw, bh, n=4) {
    rotate([tilt_a, 0, 0]) {
        sp = (bw-wall*2)/n;
        for (i=[0:n-1]) {
            cx = wall + sp*(i+0.5);
            translate([cx, 35, wall+2])
            color(vial_col) cylinder(r=vial_r, h=vial_h);
        }
    }
}

module syringe_open(bw) {
    rotate([tilt_a, 0, 0])
    translate([bw*0.5, 90, wall+pen_r+3])
    rotate([0,90,0])
    color(pen_col) cylinder(r=pen_r, h=140, center=true);
}

module label_open(bw, bh) {
    rotate([tilt_a, 0, 0])
    color(label_col)
    translate([wall*1.5, -0.3, bh*0.6]) cube([bw-wall*3, 0.4, bh*0.3]);
}

/* ── Assembly ─────────────────────────────────────────────── */
frame();

for (c=[0:cols-1], r=[0:rows-1]) {
    bw = bin_w-1.4;
    bh = bin_h-1.4;
    bd = bin_d;
    x0 = wall + c*(bin_w+wall) + 0.7;
    z0 = wall + wall + r*(bin_h+wall) + 0.7;  // wall offset for row divider
    is_open = (r == rows-1);

    // Bins sit inside the frame; their front edge aligns with frame front face
    translate([x0, wall+7, z0]) {
        if (is_open) {
            bin_open(bw, bh, bd);
            if (c == 1) syringe_open(bw);
            else vials_open(bw, bh, 4);
            label_open(bw, bh);
        } else {
            bin_closed(bw, bh, bd);
        }
    }
}

// Rubber feet
color(foot_col)
for (x=[18, outer_w-18], y=[18, outer_d-18])
    translate([x, y, -4]) cylinder(r=6, h=4);
