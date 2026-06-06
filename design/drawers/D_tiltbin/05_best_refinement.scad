// 05 — Best Refinement: Tilt-Bins + Stair Tiers + Labels + Modular Split
// Open concept: no solid top — three zones clearly visible from above/front:
//   Zone A (bottom, z=0..50):    2 front-tilt bins for syringes, shown open
//   Zone B (middle, z=50..120):  3-tier staircase vial display with pocket slabs
//   Zone C (top, z=120..139):    angled guard lip + top display row of vials
// Outer shell = left half + right half, snap together at centre.
// Each half: ≤ 188 × 375 × 139 mm — fits any 220 mm print bed.
// Capacity: 6 syringes (bins) + 48 vials (stairs) + 8 vials (top) = 56 vials total

$fn = $fn > 0 ? $fn : 40;

/* ── Global params ────────────────────────────────────────── */
outer_w   = 375;
outer_d   = 375;
outer_h   = 139;
wall      = 3.0;

bin_zone_h   = 50;
n_bins       = 2;
bin_h_each   = (bin_zone_h - wall*(n_bins+1)) / n_bins;  // ~21 mm
bin_tilt     = 40;

stair_zone_h = 70;
n_tiers      = 3;
tier_d       = (outer_d - wall*(n_tiers+1)) / n_tiers;   // ~120 mm
step_h       = stair_zone_h / n_tiers;                    // ~23 mm
tier_base_z  = bin_zone_h;

lip_z        = bin_zone_h + stair_zone_h;   // 120

vial_r       = 11;
vial_h       = 52;
pocket_r     = vial_r + 0.9;
pocket_depth = 13;
pen_r        = 9.5;

frame_col  = [0.22, 0.35, 0.55];
bin_col    = [0.78, 0.85, 0.95];
tier_col_a = [0.30, 0.56, 0.52];
tier_col_b = [0.25, 0.47, 0.43];
lip_col    = [0.88, 0.73, 0.32];
vial_col   = [0.60, 0.92, 0.80];
pen_col    = [0.95, 0.62, 0.58];
label_col  = [0.97, 0.97, 0.90];
foot_col   = [0.12, 0.12, 0.12];

hw = outer_w / 2;  // 187.5 mm

/* ═══════════════════════════════════════════════════════════
   HALF-FRAME: side walls + bottom + back only (open top/front)
   Each piece: 188 × 375 × 139 mm — ≤ 240 mm print bed
   ══════════════════════════════════════════════════════════ */
module frame_half(side) {
    tx = side * hw;
    color(frame_col)
    translate([tx, 0, 0]) {
        // Bottom floor slab
        cube([hw, outer_d, wall]);
        // Back wall
        translate([0, outer_d - wall, 0]) cube([hw, wall, outer_h]);
        // Outer side wall
        if (side == 0)
            cube([wall, outer_d, outer_h]);        // left outer wall
        else
            translate([hw - wall, 0, 0]) cube([wall, outer_d, outer_h]);  // right outer wall
        // Inner divider wall (centre-join face) — thin
        if (side == 0)
            translate([hw - wall*0.5, 0, 0]) cube([wall*0.5, outer_d, outer_h]);
        else
            cube([wall*0.5, outer_d, outer_h]);
        // Zone A floor and bin-zone horizontal shelves
        for (b=[0:n_bins]) {
            bz = b*(bin_h_each + wall);
            if (bz <= bin_zone_h)
                translate([0, 0, bz]) cube([hw, outer_d, wall]);
        }
    }
}

/* ── Snap pins ────────────────────────────────────────────── */
module snap_pins() {
    color(frame_col)
    for (py=[outer_d*0.3, outer_d*0.65]) {
        translate([hw - 0.1, py, outer_h * 0.45])
            cube([wall*0.8, 5, 7]);
    }
}

/* ═══════════════════════════════════════════════════════════
   ZONE A: TILT BINS (open, pivoting forward)
   ══════════════════════════════════════════════════════════ */
module bin_open_body(bw) {
    bh = bin_h_each - 1.2;
    bd = outer_d - wall*2 - 10;
    rotate([-bin_tilt, 0, 0])
    color(bin_col)
    difference() {
        cube([bw, bd, bh]);
        translate([wall, 0, wall]) cube([bw - wall*2, bd - wall, bh - wall]);
        // finger scoop
        translate([bw*0.5, -1, bh*0.25]) scale([1,0.6,1]) cylinder(r=bh*0.32, h=bh*0.6);
        // label slot
        translate([wall*2, -1, bh*0.63]) cube([bw - wall*4, wall*0.5+1, bh*0.28]);
    }
}

module bin_syringes(bw) {
    bh = bin_h_each - 1.2;
    bd = outer_d - wall*2 - 10;
    n  = 3;
    sp = (bw - wall*2) / n;
    rotate([-bin_tilt, 0, 0])
    for (i=[0:n-1]) {
        cx = wall + sp*(i+0.5);
        translate([cx, bd*0.42, wall + pen_r + 2])
        rotate([0, 90, 0])
        color(pen_col) cylinder(r=pen_r, h=100, center=true);
    }
}

module bin_label(bw) {
    bh = bin_h_each - 1.2;
    rotate([-bin_tilt, 0, 0])
    color(label_col)
    translate([wall*2, -0.3, bh*0.63]) cube([bw - wall*4, 0.4, bh*0.28]);
}

module bin_zone() {
    bw = outer_w - wall*2 - 1.2;
    for (b=[0:n_bins-1]) {
        bz = wall + b*(bin_h_each + wall);
        translate([wall + 0.6, wall + 5, bz]) {
            bin_open_body(bw);
            bin_syringes(bw);
            bin_label(bw);
        }
    }
}

/* ═══════════════════════════════════════════════════════════
   ZONE B: STAIR TIERS — freestanding slabs on the frame floor
   ══════════════════════════════════════════════════════════ */
module stair_slab(t) {
    hw2    = outer_w - wall*2;
    n_v    = 16;
    sp     = hw2 / n_v;
    y0     = wall + t*(tier_d + wall);
    z0     = tier_base_z + wall + t*step_h;
    slab_h = step_h + wall;
    col    = (t % 2 == 0) ? tier_col_a : tier_col_b;

    color(col)
    translate([wall, y0, z0])
    difference() {
        cube([hw2, tier_d, slab_h]);
        for (k=[0:n_v-1]) {
            cx = sp*(k+0.5);
            translate([cx, tier_d*0.5, slab_h - pocket_depth + 0.1])
                cylinder(r=pocket_r, h=pocket_depth + 0.1);
        }
        // front finger notch
        translate([hw2*0.5 - 22, -1, slab_h*0.05])
            scale([1, 0.55, 1]) cylinder(r=22, h=slab_h*0.7);
        // label recess on front face
        translate([5, -1, slab_h*0.63]) cube([hw2-10, wall*0.4+1, slab_h*0.28]);
    }

    // Vials
    for (k=[0:n_v-1]) {
        cx = wall + sp*(k+0.5);
        translate([cx, y0 + tier_d*0.5, z0 + slab_h - pocket_depth + 2])
        color(vial_col) cylinder(r=vial_r, h=vial_h);
    }
    // Label card
    color(label_col)
    translate([wall+5, y0-0.2, z0 + slab_h*0.63]) cube([hw2-10, 0.4, slab_h*0.28]);
}

module stair_zone() {
    for (t=[0:n_tiers-1]) stair_slab(t);
}

/* ═══════════════════════════════════════════════════════════
   ZONE C: TOP ANGLED LIP + display vials
   ══════════════════════════════════════════════════════════ */
module top_lip() {
    dz  = lip_z;
    hw2 = outer_w - wall*2;
    lh  = outer_h - dz;
    n_v = 8;
    sp  = hw2 / n_v;

    color(lip_col)
    translate([wall, wall, dz]) {
        // Angled back brace
        hull() {
            cube([hw2, wall, wall]);
            translate([0, outer_d - wall*6, lh - wall]) cube([hw2, wall, wall]);
        }
        // Front guard lip
        cube([hw2, wall*3, lh]);
    }
    // Display vials leaning against the back brace
    for (k=[0:n_v-1]) {
        cx = wall + sp*(k+0.5);
        translate([cx, outer_d * 0.38, dz + 3])
        rotate([-16, 0, 0])
        color(vial_col) cylinder(r=vial_r, h=vial_h);
    }
}

/* ═══════════════════════════════════════════════════════════
   FEET + ASSEMBLE
   ══════════════════════════════════════════════════════════ */
module feet() {
    color(foot_col)
    for (x=[18, outer_w-18], y=[18, outer_d-18])
        translate([x, y, -5]) cylinder(r=6.5, h=5);
}

frame_half(0);
frame_half(1);
snap_pins();

bin_zone();
stair_zone();
top_lip();
feet();
