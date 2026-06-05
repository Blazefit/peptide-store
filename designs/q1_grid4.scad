// q1_grid4 — 2x2 enclosed teardrop grid (compact 4-pen brick)
// Family: clustered. Four pens in a tight 2-wide x 2-tall block; teardrop
// bores are self-supporting so the lower row prints without a ceiling overhang.
// Dial relief: a wider teardrop counterbore breaks out the +X end of each bore.
include <common.scad>

LBLK    = 172;
PITCH_Y = 2*RCH + WALL;            // 22.4  column spacing
ROW_DZ  = 2.4142*RCH + WALL;       // 26.7  row spacing (apex + clearance)
RR      = RCH + 2;                 // dial-relief radius

Y = [-PITCH_Y/2, PITCH_Y/2];
Z = [WALL + RCH, WALL + RCH + ROW_DZ];

WBLK = PITCH_Y + 2*RCH + 2*WALL;                 // 46.4  < 63.5
HBLK = Z[1] + 1.4142*RR + WALL;                  // enclose top relief apex
RELIEF_X = LBLK/2 - 10;                           // pokes through +X end

difference() {
    translate([0,0,HBLK/2]) cube([LBLK, WBLK, HBLK], center=true);
    for (zc = Z) for (yc = Y) {
        translate([0, yc, zc]) teardrop_cut(PEN_L);             // bore
        translate([RELIEF_X, yc, zc]) teardrop_cut(30, RR);    // dial relief
    }
}
