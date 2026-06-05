// borewin_lib.scad — enclosed teardrop bores with front grab-windows
// Retention is GEOMETRIC and tolerance-proof: each pen lives in a closed
// teardrop tube (0.4mm clearance) and is loaded by sliding in from the +X end.
// A teardrop grab-window (apex up, self-supporting) is cut through the front
// face into each bore; it is narrower/shorter than the pen (so the pen can be
// seen and pushed but cannot fall out the front). No snap, no flex, no test
// print needed.
include <common.scad>

LBLK = PEN_L + 7;   // 172  body length (< 177.8), end walls + dial relief

// 2D teardrop, apex toward +Y. Contact stays at the circle's 45deg point (so no
// shallow circle arc is exposed), but the apex is raised to APEXK*r so the roof
// walls are STEEPER than 45deg -> firmly self-supporting, minimal overhang.
// ak = apex height factor: 1.4142 = classic 45deg; higher = steeper roof walls
module td2d(r, ak=1.4142) {
    union() {
        circle(r=r);
        polygon([[ 0.7071*r, 0.7071*r],
                 [ 0,         ak*r],
                 [-0.7071*r,  0.7071*r]]);
    }
}

// teardrop bore cut, axis along X
module td_bore(len, r=RCH, ak=1.4142) {
    rotate([0,90,0]) linear_extrude(height=len, center=true) td2d(r, ak);
}

// n       : pens
// stepy   : front-to-back offset per pen (0 = vertical column)
// stepz   : rise per pen
// rwin    : grab-window radius (window stays < pen Ø20 -> pen can't escape)
// rr      : dial-relief radius (wider mouth, breaks out the +X end)
// window  : cut the front grab-windows
// plate   : recess a nameplate into the flat back face
// base_w  : width of a stabilizing base slab (0 = none)
module borewin(n=4, stepy=12, stepz=19, rwin=6.5, rr=RCH+2,
               window=true, plate=false, base_w=0, apexk=1.4142) {
    yc = [for (i=[0:n-1]) (-(n-1)/2 + i) * stepy];
    zc = [for (i=[0:n-1]) (WALL + RCH) + i * stepz];
    ymn = min(yc) - RCH - WALL;
    ymx = max(yc) + RCH + WALL;
    Wb  = ymx - ymn;
    ycen = (ymx + ymn) / 2;
    Hb  = max(zc) + apexk*RCH + WALL;      // enclose the teardrop apex
    relief_cx = LBLK/2 - 12;
    base_h = 6;

    difference() {
        union() {
            translate([0, ycen, Hb/2]) cube([LBLK, Wb, Hb], center=true);
            if (base_w > 0)
                translate([0, ycen, base_h/2])
                    cube([LBLK, base_w, base_h], center=true);
        }
        for (i = [0:n-1]) {
            // enclosed teardrop bore (the pen channel), open only at the +X end
            translate([0, yc[i], zc[i]]) td_bore(PEN_L, RCH, apexk);
            // dial relief: wider teardrop breaking out the +X face
            translate([relief_cx, yc[i], zc[i]]) td_bore(34, rr, apexk);
            // front grab-window: teardrop tunnel (apex up) out the -Y face
            if (window)
                translate([0, yc[i], zc[i]])
                    rotate([90,0,0])
                        linear_extrude(height = yc[i] - ymn + 1) td2d(rwin, apexk);
        }
        // optional nameplate recess in the flat back (+Y) face
        if (plate)
            translate([0, ymx + EPS, Hb*0.55])
                rotate([90,0,0]) translate([0,0,-0.8])
                    linear_extrude(1.2) square([90, 16], center=true);
    }
}
