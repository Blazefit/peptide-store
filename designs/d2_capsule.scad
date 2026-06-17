// d2_capsule — enclosed twin teardrop bores ("capsule")
// Family: capsule / enclosed tube bundle. Pens slide in from the open dial end.
// Creative variation: fully enclosed self-supporting teardrop tubes give a
// clean pill/capsule body that protects the pens from dust; one end is opened
// with a top relief so the dose dial is reachable and pens slide out.
include <common.scad>

LBLK = 172;
PITCH = 2*RCH + WALL;             // 22.4
Y1 = -PITCH/2;
Y2 =  PITCH/2;
ZC = WALL + RCH;                  // channel center
APEX = ZC + 1.4142*RCH;           // teardrop apex height ~26.7
HBLK = APEX + WALL;               // enclose apex with a cover  ~28.3
WBLK = PITCH + 2*RCH + 2*WALL;    // 46.4
RELIEF_LEN = 30;
RELIEF_X = PEN_L/2 - RELIEF_LEN/2 + 4;   // open the +X end

difference() {
    translate([0,0,HBLK/2]) cube([LBLK, WBLK, HBLK], center=true);

    // enclosed teardrop tubes (closed top + ends)
    translate([0, Y1, ZC]) teardrop_cut(PEN_L);
    translate([0, Y2, ZC]) teardrop_cut(PEN_L);

    // open the +X end of each tube: top slot + through opening for dial access
    for (y = [Y1, Y2]) {
        translate([RELIEF_X, y, ZC]) trough_cut(RELIEF_LEN, RCH+0.6, 80);
    }
}
