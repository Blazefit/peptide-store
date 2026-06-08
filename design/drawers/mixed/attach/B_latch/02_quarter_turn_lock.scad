// 02_quarter_turn_lock.scad
// Quarter-turn (bayonet / cam) twist lock on each SHORT end-wall.
// A cylindrical boss on the lower tray end carries two radial lugs.
// A matching socket on the bottom of the upper tray end-wall has entry
// slots at 90°/270°; after inserting the boss, twist 90° to lock.
// Engage: drop upper tray so boss enters socket, twist 90°.
// Release: twist back 90°, lift upper tray.

explode = 20; // 0=engaged, 20=exploded

lx = 305; ly = 102; lz_lo = 50; lz_hi = 33;
wall = 3;

color_lo  = [0.35, 0.55, 0.80, 1];
color_hi  = [0.55, 0.78, 0.95, 1];
color_boss= [0.85, 0.28, 0.28, 1];  // red boss
color_sock= [0.65, 0.20, 0.20, 1];  // dark red socket ring

module lower_tray() { color(color_lo) cube([lx, ly, lz_lo]); }
module upper_tray() {
    color(color_hi) translate([0, 0, lz_lo + explode]) cube([lx, ly, lz_hi]);
}

// ── Bayonet boss on top face of lower tray END wall ──────────────────────────
boss_r   = 11;   // main cylinder radius
boss_h   = 8;    // height above mating face
lug_ext  = 7;    // how far lug extends beyond boss radius
lug_w    = 5;    // lug width (tangential)
lug_t    = 3;    // lug axial (Z) thickness

// Centred on Y; one boss per short end (at X=0 face and X=lx face)
by = ly / 2;

module bayonet_boss(bx) {
    x_dir = (bx == 0) ? -1 : 1;  // points outward from tray
    translate([bx, by, lz_lo])
    rotate([0, 90 * x_dir, 0])
    union() {
        color(color_boss) cylinder(r = boss_r, h = boss_h, $fn=36);
        // Two opposing radial lugs at 0° and 180°
        for (a = [0, 180])
            rotate([0, 0, a])
            translate([boss_r - 2, -lug_w/2, boss_h - lug_t])
            color(color_boss)
                cube([lug_ext + 2, lug_w, lug_t]);
        // Drive slot / finger grip line on face
        color([0.3, 0.1, 0.1])
        translate([-1.5, -boss_r * 0.8, boss_h])
            cube([3, boss_r * 1.6, 1]);
    }
}

// ── Matching socket flange on the BOTTOM of the upper tray end-wall ──────────
sock_r   = boss_r + 1.0;
flange_t = 3.5;

module bayonet_socket(bx) {
    x_dir = (bx == 0) ? -1 : 1;
    uz = lz_lo + explode;
    translate([bx, by, uz])
    rotate([0, 90 * x_dir, 0])
    color(color_sock) {
        // Outer flange ring
        difference() {
            cylinder(r = sock_r + 5, h = flange_t, $fn=36);
            cylinder(r = sock_r, h = flange_t + 1, $fn=36);
        }
        // Entry slot indicators (two cutout zones at 90° offset from lugs)
        for (a = [90, 270])
            rotate([0, 0, a])
            translate([sock_r - 2, -(lug_w/2 + 0.4), 0])
            color([0.15, 0.05, 0.05, 0.9])
                cube([lug_ext + 3, lug_w + 0.8, flange_t]);
    }
}

// ── Assembly ──────────────────────────────────────────────────────────────────
lower_tray();
upper_tray();
for (bx = [0, lx]) {
    bayonet_boss(bx);
    bayonet_socket(bx);
}
