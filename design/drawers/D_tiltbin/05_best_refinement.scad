// 05 — Best Refinement: Tilt-Bins + Stair Tiers + Labels + Modular Split
// Three zones in one unit:
//   Zone A (bottom): 2 full-width tilt-out bins (pivot front-bottom) for syringes/supplies
//   Zone B (middle): 3-tier stair-stepped vial holders with circular pockets
//   Zone C (top):    open angled display row (tallest vials most visible)
// Finger-scoop cutouts on each bin front. Label recesses on every face.
// Outer envelope: 375 × 375 × 139 mm
// Splits: LEFT half (≤188×375×139) + RIGHT half (≤188×375×139) — snap-fit dovetail joint
// Capacity: 2 tilt-bins (each ~4 syringes + misc); 3 stair tiers × 16 vials = 48 vials;
//            top display row × 12 vials = 12 vials. Total: ~60 vials, 8 syringes.

$fn = $fn > 0 ? $fn : 40;

/* ── Global params ────────────────────────────────────────── */
outer_w   = 375;
outer_d   = 375;
outer_h   = 139;
wall      = 3.2;

// Zone heights
bin_zone_h   = 44;      // two tilt-bins
stair_zone_h = 68;      // three stepped tiers
disp_zone_h  = outer_h - bin_zone_h - stair_zone_h - wall*2;  // ~20 mm lip

// Tilt-bin params
n_bins     = 2;
bin_h      = (bin_zone_h - wall*(n_bins+1)) / n_bins;   // ~18.2 mm each
bin_tilt   = 38;   // shown open angle

// Stair params
n_tiers    = 3;
tier_d     = (outer_d - wall*(n_tiers+1)) / n_tiers;    // ~120 mm
step_h     = stair_zone_h / n_tiers;                     // ~22.7 mm
tier_base_z = wall + bin_zone_h;

// Vial / pen
vial_r     = 11;
vial_h     = 52;
pocket_r   = vial_r + 0.9;
pocket_depth = 12;
pen_r      = 9.5;
pen_len    = 155;

/* ── Colours ──────────────────────────────────────────────── */
frame_col  = [0.22, 0.35, 0.55];
bin_col    = [0.78, 0.85, 0.95];
tier_col_a = [0.30, 0.56, 0.52];
tier_col_b = [0.25, 0.47, 0.43];
disp_col   = [0.88, 0.73, 0.32];
vial_col   = [0.70, 0.95, 0.85, 0.82];
pen_col    = [0.95, 0.62, 0.58, 0.88];
label_col  = [0.96, 0.96, 0.96];
foot_col   = [0.15, 0.15, 0.15];

/* ═══════════════════════════════════════════════════════════
   HALF-WIDTH FRAME SHELL (left or right; prints ≤188 mm wide)
   ══════════════════════════════════════════════════════════ */
hw = outer_w / 2;   // 187.5 mm — well within 240 mm limit

module frame_half(side=0) {
    // side 0 = left (x 0..hw), side 1 = right (translated to hw..outer_w)
    tx = side * hw;
    color(frame_col)
    translate([tx, 0, 0])
    difference() {
        cube([hw, outer_d, outer_h]);
        // hollow out interior (back, top, sides kept as shell)
        translate([wall, wall, wall])
            cube([hw - wall*2, outer_d - wall*2, outer_h - wall]);
        // Bin zone front openings (tilt clearance)
        for (b=[0:n_bins-1]) {
            bz = wall + b*(bin_h + wall);
            translate([wall - 0.1, -0.1, bz])
                cube([hw - wall*2 + 0.2, wall + 0.2, bin_h]);
        }
        // Dovetail socket at centre join edge
        // Simple rectangular slot for snap pin
        translate([hw - wall - 1, outer_d*0.25, outer_h*0.3])
            cube([wall + 1.2, 6, 8]);
        translate([hw - wall - 1, outer_d*0.65, outer_h*0.3])
            cube([wall + 1.2, 6, 8]);
    }
}

/* ── Centre snap pins (male, on right half's left edge) ──── */
module snap_pins() {
    color(frame_col)
    for (py=[outer_d*0.25, outer_d*0.65]) {
        translate([hw, py + 1, outer_h*0.3])
            cube([wall, 4, 6]);
    }
}

/* ═══════════════════════════════════════════════════════════
   TILT-OUT BINS (shown open)
   ══════════════════════════════════════════════════════════ */
module tilt_bin(bw, col_i) {
    // bw = bin width, pivots at y=wall (front face)
    bd = outer_d - wall*2 - 6;
    bh = bin_h - 0.8;
    ang = bin_tilt;

    rotate([ang, 0, 0])
    color(bin_col)
    difference() {
        cube([bw, bd, bh]);
        // interior cavity
        translate([wall, wall, wall])
            cube([bw - wall*2, bd - wall, bh - wall]);
        // finger scoop on front face
        translate([bw*0.5 - 14, -0.1, bh*0.25])
            scale([1, 0.6, 1])
            cylinder(r=14, h=bh*0.55);
        // label recess on front face
        translate([wall*2, -0.1, bh*0.62])
            cube([bw - wall*4, wall*0.5 + 0.1, bh*0.28]);
    }
}

module syringe_in_bin(bw) {
    bd = outer_d - wall*2 - 6;
    bh = bin_h - 0.8;
    // two syringes lying flat, shown inside open bin
    for (i=[0,1]) {
        cx = bw * (0.28 + i*0.44);
        translate([cx, bd * 0.45, wall + pen_r + 1])
        rotate([0, 90, 0])
        color(pen_col) cylinder(r=pen_r, h=pen_len, center=true);
    }
}

module bin_zone() {
    bw = outer_w - wall*2 - 1;
    for (b=[0:n_bins-1]) {
        bz = wall + b*(bin_h + wall);
        translate([wall + 0.5, wall, bz]) {
            tilt_bin(bw, b);
            syringe_in_bin(bw);
        }
    }
}

/* ═══════════════════════════════════════════════════════════
   STAIR TIERS (3 steps, lowest at front)
   ══════════════════════════════════════════════════════════ */
module stair_tier(t) {
    // t=0 → front (lowest), t=2 → back (highest)
    hw2   = outer_w - wall*2;
    n_v   = 16;    // 16 vials per tier across full width
    sp    = hw2 / n_v;

    y0    = wall + t*(tier_d + wall);
    z0    = tier_base_z + t*step_h;
    slab_h = step_h + wall;
    col   = (t % 2 == 0) ? tier_col_a : tier_col_b;

    // Main slab
    color(col)
    translate([wall, y0, z0])
    difference() {
        cube([hw2, tier_d, slab_h]);
        // vial pockets on top
        for (k=[0:n_v-1]) {
            cx = sp*(k+0.5);
            translate([cx, tier_d*0.5, slab_h - pocket_depth + 0.1])
                cylinder(r=pocket_r, h=pocket_depth + 0.1);
        }
        // finger access notch at front
        translate([hw2*0.5 - 18, -0.1, slab_h*0.1])
            scale([1, 0.7, 1])
            cylinder(r=18, h=slab_h*0.6);
        // label recess
        translate([4, -0.1, slab_h*0.65])
            cube([hw2 - 8, wall*0.4 + 0.1, slab_h*0.25]);
    }

    // Vials
    for (k=[0:n_v-1]) {
        cx = wall + sp*(k+0.5);
        translate([cx, y0 + tier_d*0.5, z0 + slab_h - pocket_depth + 2])
        color(vial_col) cylinder(r=vial_r, h=vial_h);
    }

    // Front-face label strip (white card slot indicator)
    color(label_col)
    translate([wall+4, y0-0.1, z0 + slab_h*0.65])
        cube([hw2-8, 0.8, slab_h*0.25]);
}

module stair_zone() {
    for (t=[0:n_tiers-1])
        stair_tier(t);
}

/* ═══════════════════════════════════════════════════════════
   TOP ANGLED DISPLAY ROW
   ══════════════════════════════════════════════════════════ */
module top_display() {
    // Single angled row at the top of the unit, 12 vials front-facing
    dz    = tier_base_z + n_tiers*step_h + wall;
    hw2   = outer_w - wall*2;
    n_v   = 12;
    sp    = hw2 / n_v;
    ang   = 20;   // forward lean angle

    // Angled back support
    color(disp_col)
    translate([wall, wall, dz]) {
        hull() {
            cube([hw2, wall, wall]);
            translate([0, outer_d - wall*4, disp_zone_h - wall])
                cube([hw2, wall, wall]);
        }
        // front lip
        cube([hw2, wall*2, outer_h - dz]);
    }

    // Vials (angled forward)
    for (k=[0:n_v-1]) {
        cx  = wall + sp*(k+0.5);
        py  = outer_d * 0.35;
        pz  = dz + 4;
        translate([cx, py, pz])
        rotate([-ang, 0, 0])
        color(vial_col) cylinder(r=vial_r, h=vial_h);
    }
}

/* ═══════════════════════════════════════════════════════════
   FEET
   ══════════════════════════════════════════════════════════ */
module feet() {
    color(foot_col)
    for (x=[18, outer_w-18], y=[18, outer_d-18])
        translate([x, y, -5]) cylinder(r=6.5, h=5);
}

/* ═══════════════════════════════════════════════════════════
   TOP BACK CAP (completes the enclosure above display zone)
   ══════════════════════════════════════════════════════════ */
module top_cap() {
    color(frame_col)
    translate([0, 0, outer_h - wall])
        cube([outer_w, outer_d, wall]);
}

/* ═══════════════════════════════════════════════════════════
   ASSEMBLE FULL UNIT
   ══════════════════════════════════════════════════════════ */
frame_half(0);   // left half
frame_half(1);   // right half (translated inside the module)
snap_pins();

bin_zone();
stair_zone();
top_display();
top_cap();
feet();

// Back wall
color(frame_col)
translate([0, outer_d - wall, 0]) cube([outer_w, wall, outer_h]);

// Bottom
color(frame_col)
cube([outer_w, outer_d, wall]);
