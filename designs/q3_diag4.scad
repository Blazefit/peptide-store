// q3_diag4 — four teardrop bores in a diagonal echelon (staircase look)
// Family: staggered/clustered. Pens climb up-and-back so the four dose dials
// fan out and stay reachable. Enclosed teardrops => no overhang ceilings even
// though the pens overlap in side profile.
include <common.scad>

LBLK  = 172;
STEPY = 12;                        // back-step per pen
STEPZ = 19;                        // rise per pen (diag 22.47 > 22.4 min spacing)
RR    = RCH + 1.5;                 // dial-relief radius

Y = [for (i=[0:3]) -1.5*STEPY + i*STEPY];   // -18,-6,6,18
Z = [for (i=[0:3]) WALL + RCH + i*STEPZ];   // 12,31,50,69

WBLK = (max(Y) - min(Y)) + 2*RCH + 2*WALL;  // 36 + 24 = 60  < 63.5
YCEN = (max(Y) + min(Y)) / 2;               // 0
HBLK = Z[3] + 1.4142*RR + WALL;
RELIEF_X = LBLK/2 - 10;

difference() {
    translate([0, YCEN, HBLK/2]) cube([LBLK, WBLK, HBLK], center=true);
    for (i = [0:3]) {
        translate([0, Y[i], Z[i]]) teardrop_cut(PEN_L);
        translate([RELIEF_X, Y[i], Z[i]]) teardrop_cut(30, RR);
    }
}
