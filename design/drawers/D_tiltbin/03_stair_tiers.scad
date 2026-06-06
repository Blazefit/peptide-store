// 03 — Stair-Stepped Tiers
// 4 rows stepping up toward the back; each step holds vials standing upright
// in molded circular pockets. Front row lowest, back row highest.
// Outer envelope: 375 × 375 × 130 mm
// Splits: 2 half-width tier modules (each ~187×375) that clip together
// Capacity: 4 tiers × 16 vials = 64 vials; syringe tray at front base

$fn = $fn > 0 ? $fn : 40;

/* ── Parameters ──────────────────────────────────────────── */
outer_w   = 375;
outer_d   = 375;
outer_h   = 130;
wall      = 3.0;
n_tiers   = 4;
tier_d    = (outer_d - wall*(n_tiers+1)) / n_tiers;   // ~87 mm per tier
step_h    = (outer_h - wall*2 - 20) / n_tiers;        // ~26 mm step height
base_h    = 20;  // front syringe tray base height

vial_r    = 11;
vial_h    = 52;
pocket_r  = vial_r + 0.8;
pocket_h  = 14;

pen_r     = 9.5;
pen_len   = 160;

tier_col  = [0.30, 0.55, 0.50];
alt_col   = [0.25, 0.45, 0.40];
vial_col  = [0.75, 0.95, 0.88, 0.85];
pen_col   = [0.90, 0.65, 0.60, 0.90];
base_col  = [0.20, 0.30, 0.45];

/* ── Clip joint geometry (male pin, 3mm) ─────────────────── */
module clip_pin() {
    translate([0, 0, -3]) cylinder(r=2, h=6);
}
module clip_socket() {
    cylinder(r=2.3, h=6);
}

/* ── One tier slab with vial pockets ─────────────────────── */
module tier_slab(tier_i, half=0) {
    // half=0 → left half (0..outer_w/2), half=1 → right
    hw   = outer_w/2 - wall/2;
    n_v  = 8;   // vials per half-width per tier
    spacing_x = hw / n_v;
    y0   = wall + tier_i*(tier_d + wall);
    z0   = wall + base_h + tier_i*step_h;
    slab_h = step_h + wall;

    color(tier_i % 2 == 0 ? tier_col : alt_col)
    difference() {
        cube([hw, tier_d, slab_h]);
        // vial pockets
        for (k=[0:n_v-1]) {
            cx = spacing_x*(k+0.5);
            translate([cx, tier_d*0.45, slab_h-pocket_h+0.1])
                cylinder(r=pocket_r, h=pocket_h+0.1);
        }
        // label groove on front face
        translate([2, -0.1, slab_h*0.3])
            cube([hw-4, wall*0.5+0.1, slab_h*0.35]);
    }
}

/* ── Vials in a tier ─────────────────────────────────────── */
module vials_in_tier(tier_i, half=0) {
    hw   = outer_w/2 - wall/2;
    n_v  = 8;
    spacing_x = hw / n_v;
    slab_h = step_h + wall;
    for (k=[0:n_v-1]) {
        cx = spacing_x*(k+0.5);
        translate([cx, tier_d*0.45, slab_h - pocket_h + 2])
        color(vial_col) cylinder(r=vial_r, h=vial_h);
    }
}

/* ── Front syringe tray ──────────────────────────────────── */
module syringe_tray(half=0) {
    hw = outer_w/2 - wall/2;
    color(base_col)
    difference() {
        cube([hw, outer_d, base_h]);
        translate([wall, wall, wall])
            cube([hw-wall*2, outer_d-wall*2, base_h]);
    }
    // 3 syringe channels
    n_ch = 3;
    sp   = (hw - wall*2) / n_ch;
    for (i=[0:n_ch-1]) {
        cx = wall + sp*(i+0.5);
        translate([cx, outer_d*0.5, wall])
        rotate([0, 90, 0])
        color(pen_col) cylinder(r=pen_r, h=pen_len, center=true);
    }
}

/* ── Outer frame walls ───────────────────────────────────── */
module outer_frame(hw) {
    color(base_col) {
        // back wall
        translate([0, outer_d-wall, 0]) cube([hw, wall, outer_h]);
        // bottom
        cube([hw, outer_d, wall]);
        // left/right handled by assembly mirror
    }
}

/* ── Left half (prints separately, ≤ 188×375×130) ───────── */
module left_half() {
    hw = outer_w/2 - wall/2;
    outer_frame(hw);
    syringe_tray(0);
    for (t=[0:n_tiers-1]) {
        y0 = wall + t*(tier_d+wall);
        z0 = wall + base_h + t*step_h;
        translate([0, y0, z0]) {
            tier_slab(t, 0);
            vials_in_tier(t, 0);
        }
    }
    // side wall
    color(base_col) cube([wall, outer_d, outer_h]);
}

/* ── Right half (mirror of left + center divider) ────────── */
module right_half() {
    hw = outer_w/2 - wall/2;
    translate([outer_w/2 + wall/2, 0, 0]) {
        outer_frame(hw);
        syringe_tray(1);
        for (t=[0:n_tiers-1]) {
            y0 = wall + t*(tier_d+wall);
            z0 = wall + base_h + t*step_h;
            translate([0, y0, z0]) {
                tier_slab(t, 1);
                vials_in_tier(t, 1);
            }
        }
        color(base_col) translate([hw-wall, 0, 0]) cube([wall, outer_d, outer_h]);
    }
}

/* ── Center join strip ───────────────────────────────────── */
module center_join() {
    color([0.15, 0.20, 0.30])
    translate([outer_w/2 - wall/2, 0, 0])
        cube([wall, outer_d, outer_h]);
}

/* ── Assemble ─────────────────────────────────────────────── */
left_half();
right_half();
center_join();

// Feet
color([0.15,0.15,0.15])
for (x=[15, outer_w-15], y=[15, outer_d-15])
    translate([x, y, -4]) cylinder(r=5.5, h=4);
