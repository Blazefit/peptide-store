// q4_hybrid4 — 2x2: enclosed bottom row + open-top display row
// Family: combo. The bottom two pens ride in enclosed teardrop bores (dust
// protected, self-supporting); the top two sit in open-top cradles so they are
// easy to grab. Best of storage + display in one 4-pen block.
include <common.scad>

LBLK    = 172;
PITCH_Y = 2*RCH + WALL;            // 22.4
ROW_DZ  = 2.4142*RCH + WALL;       // 26.7  bottom apex -> top trough clearance
RR      = RCH + 2;

Y  = [-PITCH_Y/2, PITCH_Y/2];
ZB = WALL + RCH;                   // 12   bottom (enclosed) row
ZT = ZB + ROW_DZ;                  // 38.7 top (open) row

WBLK = PITCH_Y + 2*RCH + 2*WALL;   // 46.4
HBLK = ZT + RCH;                   // open trough opens at the top  (49.1)
RELIEF_X = LBLK/2 - 10;

difference() {
    translate([0,0,HBLK/2]) cube([LBLK, WBLK, HBLK], center=true);

    // bottom row: enclosed teardrop bores + teardrop dial relief
    for (yc = Y) {
        translate([0, yc, ZB]) teardrop_cut(PEN_L);
        translate([RELIEF_X, yc, ZB]) teardrop_cut(30, RR);
    }
    // top row: open-top cradles + widened open dial relief
    for (yc = Y) {
        translate([0, yc, ZT]) trough_cut(PEN_L);
        translate([RELIEF_X, yc, ZT]) trough_cut(30, RR);
    }
}
