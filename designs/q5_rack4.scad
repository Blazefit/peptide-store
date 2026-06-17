// q5_rack4 — reclined "toast-rack": 4 pens loaded from the long FRONT face
// Family: staggered/clustered. Each pen sits behind-and-above the last on a
// 58deg ramp, so all four grooves open on the top-front long face — you clip
// each pen in from the front instead of sliding it in the end. The ramp faces
// up, so it still prints support-free. A small lip (grooves cut deeper than a
// semicircle) snap-retains each pen.
include <common.scad>

LBLK = 172;
PHI  = 58;                         // ramp angle from horizontal
P    = 22.5;                       // along-ramp pen spacing (> 22.4 min)
LIP  = 2.5;                        // groove cut this far below ramp -> snap lip
RR   = RCH + 1.5;                  // dial-relief radius

Yc = [for (i=[0:3])  -1.5*P*cos(PHI) + i*P*cos(PHI)];   // centered in Y
Zc = [for (i=[0:3])  (RCH + WALL)    + i*P*sin(PHI)];   // climb upward

WBLK = (max(Yc) - min(Yc)) + 2*RCH + 2*WALL;            // ~59.8 < 63.5
HBOX = max(Zc) + RCH + 8;                                // box tall enough
RELIEF_X = LBLK/2 - 10;
BIG = 600;

difference() {
    // wedge = box with its top sheared off along the ramp plane
    difference() {
        translate([0, 0, HBOX/2]) cube([LBLK, WBLK, HBOX], center=true);
        // remove everything above the ramp plane (plane raised LIP above centers)
        translate([0, Yc[0], Zc[0] + LIP])
            rotate([PHI, 0, 0])
                translate([0, 0, BIG/2]) cube([LBLK + 2, BIG, BIG], center=true);
    }
    // four open grooves on the ramp + dial relief at the +X end of each
    for (i = [0:3]) {
        translate([0, Yc[i], Zc[i]])
            rotate([0,90,0]) cylinder(h = LBLK + 2, r = RCH, center=true);
        translate([RELIEF_X, Yc[i], Zc[i]])
            rotate([0,90,0]) cylinder(h = 40, r = RR, center=true);
    }
}
