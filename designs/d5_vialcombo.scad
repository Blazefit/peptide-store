// d5_vialcombo — one pen trough + a row of vertical vial wells
// Family: combo variant (pen + reconstitution vials). The pen rides in an
// open-top trough on one side; a parallel row of open-top vial wells holds the
// BAC water / lyophilized vials alongside.
// Creative variation: a single-station "kit" that pairs a pen with its vials.
include <common.scad>

LBLK = 172;
ZC_DEPTH = 24;                    // overall block height (vial depth driven)
HBLK = ZC_DEPTH;                  // 24  < 152.4

PEN_Y  = -10;                     // pen trough center in Y
VIAL_Y =  12;                     // vial row center in Y
ZC = HBLK - RCH;                  // raise pen so trough opens at the top

// width: pen side reaches PEN_Y-RCH-WALL ; vial side reaches VIAL_Y+VR+WALL
VIAL_D = 14;                      // vial well diameter
VR = VIAL_D/2;
WBLK = (VIAL_Y + VR + WALL) - (PEN_Y - RCH - WALL);   // ~ 45  < 63.5
YCEN = (PEN_Y - RCH - WALL + VIAL_Y + VR + WALL)/2;   // block Y center

VIAL_DEPTH = 20;                  // open-top blind wells
VIAL_X = [-50, 0, 50];           // three wells along the length

difference() {
    translate([0, YCEN, HBLK/2]) cube([LBLK, WBLK, HBLK], center=true);

    // pen trough + dial relief at +X end
    translate([0, PEN_Y, ZC]) trough_cut(PEN_L);
    translate([0, PEN_Y, ZC]) dial_relief(PEN_L/2 - 10);

    // vertical vial wells, open at the top (no ceiling -> no overhang)
    for (x = VIAL_X) {
        translate([x, VIAL_Y, HBLK - VIAL_DEPTH])
            cylinder(h = VIAL_DEPTH + EPS, d = VIAL_D);
    }
}
