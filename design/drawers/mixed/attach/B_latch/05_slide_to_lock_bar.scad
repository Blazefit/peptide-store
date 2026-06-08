// 05_slide_to_lock_bar.scad
// Slide-to-lock cross-bar: a short flat bar lives in a guide channel on the
// FRONT long face of the upper tray. Sliding it +X causes its hook-tab to
// drop into a mortise slot in the lower tray wall, capturing the upper tray
// both vertically (no lift) and laterally (no pull-apart).
// A fixed stop ear on the channel prevents over-travel.
// Two bars (front + back) for symmetric grip.
//
// Engage: push bar +X until hook-tab seats in mortise (tactile stop).
// Release: push bar -X to retract hook, then lift upper tray.

explode = 18; // 0=engaged, 18=exploded

lx = 305; ly = 102; lz_lo = 50; lz_hi = 33;
wall = 3;

color_lo  = [0.35, 0.55, 0.80, 1];
color_hi  = [0.55, 0.78, 0.95, 1];
color_bar = [0.22, 0.72, 0.42, 1];   // bar – green
color_ch  = [0.18, 0.50, 0.32, 1];   // channel – dark green
color_mort= [0.55, 0.35, 0.70, 1];   // mortise block – purple

module lower_tray() { color(color_lo) cube([lx, ly, lz_lo]); }
module upper_tray() {
    color(color_hi) translate([0, 0, lz_lo + explode]) cube([lx, ly, lz_hi]);
}

// ── Parameters ────────────────────────────────────────────────────────────────
bar_l    = 60;    // bar total X length
bar_h    = 10;    // bar height Z
bar_t    = 4;     // bar thickness Y (depth into face)

hook_w   = 16;    // hook section X width
hook_drop= 7;     // hook drops DOWN by this amount into mortise
hook_t   = bar_t; // same thickness

ch_wt    = 3;     // channel wall/rail thickness
ch_extra = 4;     // channel extends past bar each side

travel   = (explode == 0) ? hook_w : 0; // bar shift when locked

mort_w   = hook_w + 1.0;
mort_h   = hook_drop + 2;
mort_t   = ch_wt + 2;

// Bar centred at 1/4 of lx from +X end (near right short wall)
bar_cx   = lx * 3/4 - bar_l / 2;  // nominal start X when unlocked

// ── Channel (mounted on outside of upper tray face) ───────────────────────────
module bar_channel(sy) {
    y_sign = (sy == 0) ? -1 : 1;
    uz = lz_lo + explode;
    x0 = bar_cx - ch_extra;
    cl = bar_l + ch_extra * 2;

    color(color_ch) {
        // Back plate
        translate([x0, sy, uz + 2])
            cube([cl, y_sign * ch_wt, bar_h + ch_wt]);
        // Top retaining rail
        translate([x0, sy + y_sign * ch_wt, uz + bar_h + 2])
            cube([cl, y_sign * (ch_wt + 1), ch_wt]);
        // Bottom retaining rail
        translate([x0, sy + y_sign * ch_wt, uz + 2])
            cube([cl, y_sign * (ch_wt + 1), ch_wt]);
        // Fixed stop ear at +X end (prevents over-travel)
        translate([x0 + cl - ch_wt, sy, uz + 2 - 1])
            cube([ch_wt, y_sign * (ch_wt * 2 + bar_t + 2), bar_h + ch_wt + 2]);
    }
}

// ── Mortise block on lower tray face (visual — represents slot in wall) ───────
module mortise_block(sy) {
    y_sign = (sy == 0) ? -1 : 1;
    // Mortise is at the +X end of bar travel, at the mating face level
    mx = bar_cx + bar_l - mort_w;
    color(color_mort)
    translate([mx, sy, lz_lo - mort_h])
        cube([mort_w, y_sign * mort_t, mort_h]);
}

// ── Sliding bar ───────────────────────────────────────────────────────────────
module slide_bar(sy) {
    y_sign = (sy == 0) ? -1 : 1;
    uz = lz_lo + explode;
    bx = bar_cx + travel;

    color(color_bar) {
        // Main bar body
        translate([bx, sy + y_sign * ch_wt, uz + 2 + ch_wt])
            cube([bar_l - hook_w, bar_t, bar_h]);

        // Thumb push tab (raised ridge on bar top)
        translate([bx + (bar_l - hook_w) * 0.35, sy + y_sign * ch_wt, uz + 2 + ch_wt + bar_h])
            cube([18, bar_t, 4]);

        // Hook-tab at +X end: protrudes DOWN when bar is pushed locked
        // When exploded (unlocked) it sits level; drop is shown in locked state
        hook_dz = (explode == 0) ? -hook_drop : 0;
        translate([bx + bar_l - hook_w, sy + y_sign * ch_wt, uz + 2 + ch_wt + hook_dz])
            cube([hook_w, bar_t, bar_h]);
    }
}

// ── Assembly ──────────────────────────────────────────────────────────────────
lower_tray();
upper_tray();

for (sy = [0, ly]) {
    bar_channel(sy);
    mortise_block(sy);
    slide_bar(sy);
}
