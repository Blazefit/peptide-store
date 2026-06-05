// rack_lib.scad — parametric reclined "toast-rack" for horizontal pens
// One module, driven by params, so each design iteration is an attributable
// change. Pens load from the top-front long face (radially into each groove);
// the ramp faces up so it prints support-free.
include <common.scad>

LBLK = PEN_L + 7;   // 172  overall body length (< 177.8), leaves end walls

// n       : number of pens
// phi     : ramp angle from horizontal (deg) — steeper = narrower + more top-load
// P       : along-ramp center spacing (>= 22.4 so pens don't intersect)
// lip     : grooves cut this far below the ramp plane -> snap-retention lip
// rr      : dial-relief radius (wider mouth at +X end)
// rlen    : dial-relief length along X
// endwall : solid wall thickness left at each end of a groove (containment)
// scoop   : add a thumb-scallop at the +X mouth for easy pen removal
// plate   : recess a nameplate/label pocket into the flat back face
// vials   : number of vertical vial wells bored into the back-top shelf (0 = none)
module rack(n=4, phi=58, P=22.5, lip=2.5, rr=RCH+1.5, rlen=30,
            endwall=3, scoop=false, plate=false, vials=0) {
    cph = cos(phi);
    sph = sin(phi);
    yc  = [for (i=[0:n-1]) (-(n-1)/2 + i) * P * cph];
    zc  = [for (i=[0:n-1]) (RCH + WALL) + i * P * sph];

    ymin = yc[0]   - RCH - WALL;
    ymax = yc[n-1] + RCH + WALL;
    Wb   = ymax - ymin;
    ycen = (ymax + ymin) / 2;
    Hbox = zc[n-1] + RCH + (vials > 0 ? 16 : 8);   // extra back-top stock for wells
    glen = LBLK - 2 * endwall;
    relief_cx = LBLK/2 - rlen/2 + 3;               // pokes ~3 past +X face
    big = 800;

    difference() {
        // ---- solid wedge: box with its top sheared off along the ramp plane ----
        difference() {
            translate([0, ycen, Hbox/2]) cube([LBLK, Wb, Hbox], center=true);
            translate([0, yc[0], zc[0] + lip])
                rotate([phi, 0, 0])
                    translate([0, 0, big/2]) cube([LBLK + 2, big, big], center=true);
        }

        // ---- grooves + dial relief (+ optional thumb scoop) ----
        for (i = [0:n-1]) {
            translate([0, yc[i], zc[i]])                       // main groove
                rotate([0,90,0]) cylinder(h=glen, r=RCH, center=true);
            translate([relief_cx, yc[i], zc[i]])               // dial relief mouth
                rotate([0,90,0]) cylinder(h=rlen, r=rr, center=true);
            if (scoop)
                translate([LBLK/2, yc[i] - 0.30*RCH, zc[i]]) sphere(r=7.5);
        }

        // ---- optional vertical vial wells in the back-top shelf ----
        if (vials > 0) {
            wy = ymax - 9;                                     // along the back edge
            for (k = [0:vials-1]) {
                wx = -((vials-1)/2)*44 + k*44;
                translate([wx, wy, Hbox - 22 + EPS])
                    cylinder(h = 22, d = 14);
            }
        }

        // ---- optional nameplate recess in the flat back face ----
        if (plate)
            translate([0, ymax + EPS, zc[n-1]*0.5])
                rotate([90,0,0]) translate([0,0,-0.8])
                    linear_extrude(1.2) square([90, 16], center=true);
    }
}
