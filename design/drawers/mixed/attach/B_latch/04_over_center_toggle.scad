// 04_over_center_toggle.scad
// Over-center toggle latch on each SHORT end-wall.
// A pivoting lever on the upper tray pulls a wire bale over-center,
// drawing the trays together and locking mechanically (cannot spring open).
// Engage: hook bale over stud, push lever down past centre → clamps tight.
// Release: lift lever back past centre, unhook bale.

explode = 18; // 0=engaged, 18=exploded

lx = 305; ly = 102; lz_lo = 50; lz_hi = 33;
wall = 3;

color_lo  = [0.35, 0.55, 0.80, 1];
color_hi  = [0.55, 0.78, 0.95, 1];
color_lev = [0.85, 0.25, 0.25, 1];  // lever – red
color_bale= [0.90, 0.65, 0.10, 1];  // bale – amber
color_stud= [0.70, 0.70, 0.70, 1];  // stud – grey

module lower_tray() { color(color_lo) cube([lx, ly, lz_lo]); }
module upper_tray() {
    color(color_hi) translate([0, 0, lz_lo + explode]) cube([lx, ly, lz_hi]);
}

// ── Catch stud on lower tray end face ────────────────────────────────────────
stud_r   = 4;
stud_prot= 9;   // protrusion from end face
stud_z   = lz_lo - 15;  // height up the lower tray

module catch_stud(ex) {
    x_dir = (ex == 0) ? -1 : 1;
    color(color_stud)
    translate([ex, ly/2, stud_z])
        rotate([0, 90 * x_dir, 0])
            cylinder(r = stud_r, h = stud_prot, $fn=24);
    // Stud base pad
    color(color_stud)
    translate([ex + x_dir * 0, ly/2 - 8, stud_z - 6])
        cube([x_dir * 3, 16, stud_r * 2 + 12]);
}

// ── Toggle latch assembly on upper tray end face ──────────────────────────────
lever_l  = 32;
lever_w  = 18;
lever_t  = 4;
bale_w   = 18;   // inner span of bale (Y)
bale_t   = 3;    // bale wire thickness
bale_ht  = 18;   // bale loop height

module toggle_latch(ex) {
    x_dir = (ex == 0) ? -1 : 1;
    uz = lz_lo + explode;

    // Pivot on upper tray end, centred Y, 5 mm above mating face
    piv_z = uz + 6;
    piv_x = ex;

    // Lever angle: slightly past centre when locked, swung open when exploded
    lev_ang = (explode > 0) ? 55 : -8;

    // Pivot bosses (two ears on tray end face)
    for (dy = [-lever_w/2 - 1, lever_w/2 - 3])
    color(color_lev)
    translate([piv_x, ly/2 + dy, piv_z])
        rotate([0, 90 * x_dir, 0])
            cylinder(r = 3, h = 4, $fn=18);

    // Lever body
    color(color_lev)
    translate([piv_x + x_dir * 4, ly/2, piv_z])
    rotate([lev_ang, 0, 0])
    translate([0, -lever_w/2, 0])
    union() {
        cube([x_dir * lever_l, lever_w, lever_t]);
        // Finger grip nub at end
        translate([x_dir * (lever_l - 6), lever_w/2 - 5, lever_t])
            cube([x_dir * 6, 10, 5]);
    }

    // Bale (wire loop) – hangs from lever tip and hooks under stud
    bale_ax = piv_x + x_dir * (4 + lever_l * cos(lev_ang));
    bale_az = piv_z + lever_l * sin(lev_ang * 3.14159/180) * (explode > 0 ? 0.5 : 1.0);

    color(color_bale)
    translate([bale_ax, ly/2 - bale_w/2, stud_z - 4]) {
        cube([bale_t, bale_w, bale_ht]);              // left rail
        translate([0, bale_w - bale_t, 0]) cube([bale_t, bale_t, bale_ht]); // right rail
        cube([bale_t, bale_w, bale_t]);               // bottom (hooks under stud)
        translate([0, 0, bale_ht - bale_t]) cube([bale_t, bale_w, bale_t]); // top bar
    }
}

// ── Assembly ──────────────────────────────────────────────────────────────────
lower_tray();
upper_tray();
for (ex = [0, lx]) {
    catch_stud(ex);
    toggle_latch(ex);
}
