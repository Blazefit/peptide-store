// q2_tower4 — vertical 4-high teardrop column on a stabilizing base
// Family: stacked column (smallest footprint). Four pens stacked in one
// vertical wall-rack; teardrop bores keep every level self-supporting.
// A wide base flange resists side-tipping. Dial relief breaks out the +X end.
include <common.scad>

LBLK   = 172;
ROW_DZ = 2.4142*RCH + WALL;        // 26.7
RR     = RCH + 2;

Z = [for (i=[0:3]) WALL + RCH + i*ROW_DZ];   // 12, 38.7, 65.4, 92.1
COLW = 2*RCH + 2*WALL;             // 24 tower width
HBLK = Z[3] + 1.4142*RR + WALL;    // enclose top relief apex (~111)

BASE_W = 56;                       // < 63.5  base flange width
BASE_H = 6;
RELIEF_X = LBLK/2 - 10;

difference() {
    union() {
        translate([0,0,BASE_H/2]) cube([LBLK, BASE_W, BASE_H], center=true);  // base
        translate([0,0,HBLK/2])   cube([LBLK, COLW,  HBLK],  center=true);    // tower
    }
    for (zc = Z) {
        translate([0, 0, zc]) teardrop_cut(PEN_L);
        translate([RELIEF_X, 0, zc]) teardrop_cut(30, RR);
    }
}
