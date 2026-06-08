// 03_sliding_bolt_detent.scad
// Sliding bolt with snap-ball detent on the SHORT end-wall of the upper tray.
// A rectangular bolt rides in a channel on the end face; sliding it down/in
// causes the tip to enter a pocket in the lower tray end-wall, locking both
// lift and pull-apart. A snap-ball detent clicks in OPEN and LOCKED positions.
// Engage: push bolt downward (−Z) until it clicks into the lower pocket.
// Release: pull bolt upward (+Z) until it clicks out, then lift upper tray.
//
// Two bolts (one per short end face) for positive grip at both ends.

explode = 18; // 0=engaged, 18=exploded

lx = 305; ly = 102; lz_lo = 50; lz_hi = 33;
wall = 3;

color_lo  = [0.35, 0.55, 0.80, 1];
color_hi  = [0.55, 0.78, 0.95, 1];
color_bolt= [0.85, 0.58, 0.10, 1];   // amber bolt
color_ch  = [0.22, 0.40, 0.65, 1];   // dark-blue channel housing
color_pkt = [0.50, 0.30, 0.70, 1];   // purple pocket indicator

module lower_tray() { color(color_lo) cube([lx, ly, lz_lo]); }
module upper_tray() {
    color(color_hi) translate([0, 0, lz_lo + explode]) cube([lx, ly, lz_hi]);
}

// ── Parameters ────────────────────────────────────────────────────────────────
ch_w   = 16;    // channel interior width (Y)
ch_h   = 22;    // channel interior height (Z span on end face)
ch_t   = 3;     // channel housing wall thickness
prot   = 6;     // channel protrudes this much out from end-face (X)

bolt_w = ch_w - 1.5;
bolt_h = ch_h - 1.5;
bolt_t = prot - 0.8;
tip_d  = 12;    // how far bolt plunges into lower pocket when locked

// Travel: bolt slides -Z to engage
locked = (explode == 0);
bolt_dz = locked ? -tip_d : 0;   // bolt position shift

by = ly / 2;  // centre of short face

// ── Channel housing on upper tray end face ───────────────────────────────────
module channel_box(ex) {
    x_dir = (ex == 0) ? -1 : 1;
    uz = lz_lo + explode;
    // Channel sits centred on Y, from just above mating face upward
    color(color_ch) {
        // back plate (against tray face)
        translate([ex, by - ch_w/2 - ch_t, uz + 2])
            cube([x_dir * ch_t, ch_w + ch_t * 2, ch_h + ch_t]);
        // top cap
        translate([ex, by - ch_w/2 - ch_t, uz + 2 + ch_h])
            cube([x_dir * (ch_t + prot + ch_t), ch_w + ch_t * 2, ch_t]);
        // left side wall
        translate([ex, by - ch_w/2 - ch_t, uz + 2])
            cube([x_dir * (prot + ch_t), ch_t, ch_h + ch_t]);
        // right side wall
        translate([ex, by + ch_w/2, uz + 2])
            cube([x_dir * (prot + ch_t), ch_t, ch_h + ch_t]);
    }
}

// ── Receiving pocket on lower tray end face ───────────────────────────────────
module lower_pocket(ex) {
    x_dir = (ex == 0) ? -1 : 1;
    // Pocket straddles mating face: dips below lz_lo
    color(color_pkt)
    translate([ex, by - bolt_w/2, lz_lo - tip_d])
        cube([x_dir * (prot + ch_t - 1), bolt_w, tip_d + 1]);
}

// ── Bolt body ─────────────────────────────────────────────────────────────────
module bolt(ex) {
    x_dir = (ex == 0) ? -1 : 1;
    uz = lz_lo + explode;
    bz = uz + 2 + ch_t * 0.6 + bolt_dz;

    color(color_bolt) {
        // Main bolt slab
        translate([ex + x_dir * ch_t, by - bolt_w/2, bz])
            cube([x_dir * bolt_t, bolt_w, bolt_h]);
        // Thumb pull tab at top
        translate([ex + x_dir * ch_t, by - 8, bz + bolt_h - 2])
            cube([x_dir * (bolt_t + 5), 16, 7]);
    }

    // Detent balls (two positions: open and locked)
    for (dz = [bolt_h * 0.25, bolt_h * 0.25 + tip_d])
    color([0.95, 0.95, 0.25])
    translate([ex + x_dir * (ch_t + bolt_t/2), by, bz + dz])
        sphere(r = 2.5, $fn=18);
}

// ── Assembly ──────────────────────────────────────────────────────────────────
lower_tray();
upper_tray();
for (ex = [0, lx]) {
    channel_box(ex);
    lower_pocket(ex);
    bolt(ex);
}
