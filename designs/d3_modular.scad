// d3_modular — single-pen module with vertical dovetail joints
// Family: modular units that join together. Slide modules together TOP-DOWN;
// the dovetail is extruded vertically so its angled faces are vertical planes
// (zero printing overhang). Build a 1-, 2-, 3-... wide bank as needed.
// Creative variation: each pen is its own snap-together tile.
include <common.scad>

LBLK = 172;
HBLK = WALL + 2*RCH;              // 22.4
WBLK = 2*RCH + 2*WALL;           // 24.0 single-channel module
ZC = WALL + RCH;

// dovetail trapezoid (cross-section in X-Z), extruded along Z (vertical)
DT_D = 4;        // dovetail depth (into +Y / out of -Y)
DT_W = 10;       // wide face width
DT_N = 6;        // narrow face width  (narrow on the OUTER side -> undercut lock)

module dovetail_solid() {
    // male tongue protruding +Y, prism along Z, trapezoid in X (wide at root)
    translate([0, WBLK/2, 0])
        linear_extrude(height=HBLK)
            polygon([[-DT_W/2, 0], [ DT_W/2, 0],
                     [ DT_N/2, DT_D], [-DT_N/2, DT_D]]);
}
module dovetail_cut() {
    // female pocket on -Y face, matching, with a hair of clearance
    translate([0, -WBLK/2 + EPS, -EPS])
        linear_extrude(height=HBLK + 2*EPS)
            offset(delta=CLEAR)
                polygon([[-DT_W/2, 0], [ DT_W/2, 0],
                         [ DT_N/2, DT_D], [-DT_N/2, DT_D]]);
}

difference() {
    union() {
        translate([0,0,HBLK/2]) cube([LBLK, WBLK, HBLK], center=true);
        dovetail_solid();
    }
    // pen trough + dial relief at +X end
    translate([0, 0, ZC]) trough_cut(PEN_L);
    translate([0, 0, ZC]) dial_relief(PEN_L/2 - 10);
    // female dovetail on opposite face
    dovetail_cut();
}
