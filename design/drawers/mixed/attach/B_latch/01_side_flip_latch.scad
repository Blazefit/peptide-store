// 01_side_flip_latch.scad
// Small flip-over latch on each long side: a pivoting arm on the upper tray
// clips over a catch pin on the lower tray. Two latches per long face.
// Engage: rotate arm down over pin. Release: flip arm up past vertical.
// explode = 0 → engaged/closed, explode > 0 → open/separated view.

explode = 18; // 0=engaged, 18=exploded

lx = 305; ly = 102; lz_lo = 50; lz_hi = 33;
wall = 3;

color_lo  = [0.35, 0.55, 0.80, 1];
color_hi  = [0.55, 0.78, 0.95, 1];
color_lat = [0.90, 0.55, 0.10, 1];  // latch arm – orange
color_pin = [0.70, 0.70, 0.70, 1];  // catch pin – grey

module lower_tray() { color(color_lo) cube([lx, ly, lz_lo]); }
module upper_tray() {
    color(color_hi) translate([0, 0, lz_lo + explode]) cube([lx, ly, lz_hi]);
}

// ── Catch pin on the outside of the lower tray long wall ─────────────────────
pin_r   = 3.5;
pin_len = 8;
// Two pin positions along X per side
px_list  = [60, lx - 60];

module catch_pin(sy) {
    y_sign = (sy == 0) ? -1 : 1;
    for (px = px_list) {
        color(color_pin)
        translate([px, sy, lz_lo - 14])
            rotate([90, 0, 0])
                cylinder(r = pin_r, h = pin_len * y_sign, $fn=24);
    }
}

// ── Latch arm pivoting from the upper tray ───────────────────────────────────
arm_l  = 22;
arm_w  = 10;
arm_t  = 3.5;
hook_d = 6;   // hook tail that wraps under pin
hook_t = 3.5;
boss_r = 4;

module latch_arm(sy, px) {
    y_sign = (sy == 0) ? -1 : 1;
    uz = lz_lo + explode;
    piv_z = uz + 4;  // pivot just above mating face of upper tray

    // Open angle when exploded, closed (down) when engaged
    rot_ang = (explode > 0) ? 55 : 5;

    color(color_lat) {
        // Pivot boss on side wall of upper tray
        translate([px, sy, piv_z])
            rotate([90, 0, 0])
                cylinder(r = boss_r, h = 5 * y_sign, $fn=24);

        // Arm body + hook, rotated about pivot
        translate([px, sy + y_sign * 5.5, piv_z])
        rotate([y_sign * rot_ang, 0, 0])
        translate([0, 0, 0])
        union() {
            // Main flat arm going downward
            translate([-arm_w/2, 0, -arm_l])
                cube([arm_w, arm_t, arm_l]);
            // Hook tail curling inward under pin
            translate([-arm_w/2, 0, -arm_l])
                cube([arm_w, arm_t + hook_t, hook_d]);
        }
    }
}

// ── Assembly ──────────────────────────────────────────────────────────────────
lower_tray();
upper_tray();

for (sy = [0, ly]) {
    catch_pin(sy);
    for (px = px_list)
        latch_arm(sy, px);
}
