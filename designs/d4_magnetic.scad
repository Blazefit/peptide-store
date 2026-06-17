// d4_magnetic — twin cradle on an L-base with a magnet-pocket back wall
// Family: magnetic / wall-mount carrier. Pens lie in open troughs; a vertical
// back wall carries blind magnet pockets so the whole carrier snaps onto a
// steel shelf or fridge rail.
// Creative variation: mountable carrier — vertical back wall = no overhang,
// magnet pockets are drilled horizontally into the wall from the back.
include <common.scad>

LBLK = 172;
PITCH = 2*RCH + WALL;             // 22.4
Y1 = -PITCH/2;
Y2 =  PITCH/2;
HBASE = WALL + 2*RCH;             // 22.4 trough block
WBASE = PITCH + 2*RCH + 2*WALL;   // 46.4
ZC = WALL + RCH;

BWALL = 3.0;                      // back wall thickness
BWALL_H = 38;                     // back wall height  (< 152.4)
YBACK = WBASE/2;                  // back wall at +Y edge
WTOT = WBASE + BWALL;             // 49.4  < 63.5

MAG_D = 6.2;                      // magnet diameter pocket
MAG_DEPTH = 2.2;                  // blind depth

difference() {
    union() {
        // trough base
        translate([0,0,HBASE/2]) cube([LBLK, WBASE, HBASE], center=true);
        // vertical back wall along +Y edge (faces vertical -> no overhang)
        translate([0, YBACK + BWALL/2, BWALL_H/2])
            cube([LBLK, BWALL, BWALL_H], center=true);
    }
    // two pen troughs + dial reliefs (both at +X end)
    translate([0, Y1, ZC]) trough_cut(PEN_L);
    translate([0, Y1, ZC]) dial_relief(PEN_L/2 - 10);
    translate([0, Y2, ZC]) trough_cut(PEN_L);
    translate([0, Y2, ZC]) dial_relief(PEN_L/2 - 10);

    // magnet pockets: blind holes drilled from the BACK (+Y) into the wall
    for (x = [-55, 0, 55]) {
        translate([x, YBACK + BWALL + EPS, BWALL_H*0.6])
            rotate([90,0,0]) cylinder(h=MAG_DEPTH + EPS, d=MAG_D);
    }
}
