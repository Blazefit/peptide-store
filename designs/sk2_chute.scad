// sk2_chute — GRAVITY-FEED magazine (Jason's sketch, option #2).
// Drop a pen onto the ramp at the open back/top; it rolls DOWN to the front and
// stacks against the front catch wall (like a fridge can-dispenser). Take the
// front pen out over the lip; the next rolls forward. One open tray, 4 pens
// single-file. Prints support-free (sloped floor is a solid wedge; walls vertical).
include <common.scad>

THETA  = 30;              // ramp angle (gentle, so pens roll without slamming)
LXIN   = PEN_L + 1.0;     // inner length between end walls (pen + clearance)
EW     = 2.4;            // end wall thickness
LX     = LXIN + 2*EW;     // 171.8 outer (X)
BASE   = 3;              // floor thickness at the front
DEPTH  = 82;             // Y depth (~4 pens single-file)
FW     = 5;              // front catch wall thickness
HW     = 2*RCH + 2;      // side wall height above the floor (contains pens)
FLIP   = 6;              // front wall rises this far above the front pen center

t = tan(THETA);
ramp_back = BASE + DEPTH*t;          // floor height at the back
HT = ramp_back + HW;                 // overall height

// floor solid (front face = BASE tall, top = ramp rising to the back)
module floor_solid()
    translate([EW,0,0]) rotate([90,0,90]) linear_extrude(height=LXIN)
        polygon([[0,0],[DEPTH,0],[DEPTH,ramp_back],[0,BASE]]);

// one side wall: follows the ramp, stands HW above the floor
module side_wall()
    rotate([90,0,90]) linear_extrude(height=EW)
        polygon([[0,0],[DEPTH,0],[DEPTH,ramp_back+HW],[0,BASE+HW]]);

union() {
    floor_solid();
    translate([0,0,0])      side_wall();          // -X end wall
    translate([LX-EW,0,0])  side_wall();          // +X end wall
    // front catch wall + lip (retains the front pen)
    cube([LX, FW, BASE + RCH + FLIP]);
}
