// d1_cradle — twin staggered open-top cradle troughs
// Family: stacked/clustered (2-wide). Pens drop in from the top.
// Creative variation: the two dial-relief pockets sit at OPPOSITE ends so the
// two dose dials never collide and the pens read like a staggered pair.
include <common.scad>

LBLK = 172;                       // < 177.8
PITCH = 2*RCH + WALL;             // 22.4 center-to-center
Y1 = -PITCH/2;                    // -11.2
Y2 =  PITCH/2;                    //  11.2
HBLK = WALL + 2*RCH;              // 22.4 (floor + full diameter)
WBLK = PITCH + 2*RCH + 2*WALL;    // 46.4  < 63.5
ZC = WALL + RCH;                  // channel center height

difference() {
    translate([0,0,HBLK/2]) cube([LBLK, WBLK, HBLK], center=true);

    // channel 1 + dial relief at +X end
    translate([0, Y1, ZC]) trough_cut(PEN_L);
    translate([0, Y1, ZC]) dial_relief( PEN_L/2 - 10);

    // channel 2 + dial relief at -X end (staggered)
    translate([0, Y2, ZC]) trough_cut(PEN_L);
    translate([0, Y2, ZC]) dial_relief(-(PEN_L/2 - 10));
}
