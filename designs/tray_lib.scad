// tray_lib.scad — STANDING pen tray (evolved from sk2, gravity removed).
// Sleek low angled tray: pens lie parallel in shallow lane-grooves on a sloped
// floor, enclosed by a front catch lip, a BACK WALL (no more back fall-out), and
// two end walls. Open top -> drop pens in / lift them out. Prints flat, support-
// free (sloped floor is a solid wedge; all walls vertical). Inch-first intent;
// modeled in mm. Pen = O20 mm (0.79 in) x 165 mm (6.5 in).
include <common.scad>

// 2D teardrop helper (apex +Y) for self-supporting dial window if needed
module _td(r){ union(){ circle(r=r);
    polygon([[0.7071*r,0.7071*r],[0,1.4142*r],[-0.7071*r,0.7071*r]]); } }

module standtray(
    n=4, ang=28, P=22, clear=0.4,
    lip_h=5, back_h=9,
    endw=3, base=3, lipw=3, bw=3, yfront=7,
    scoop=true, dial=true, dialr=RCH+2, dial_len=24,
    cham=1.2, foot=0, divider=0)
{
    r  = PEN_B/2 + clear;            // groove radius (10.4)
    t  = tan(ang);
    LX = PEN_L + clear + 2*endw;     // overall length (X)
    yc = [for(i=[0:n-1]) yfront + i*P*cos(ang)];
    zc = [for(i=[0:n-1]) base + yc[i]*t + r];
    depth = yc[n-1] + r + bw + 2;
    Hb = zc[n-1] + back_h;           // back wall top
    Hl = zc[0]  + lip_h;             // front lip top
    eps = 0.02;
    relief_cx = LX - endw - dial_len/2 - 5;   // dial pocket, held 5mm off the end wall

    difference() {
        union() {
            cube([LX, depth, base]);                                  // base slab
            // sloped floor wedge (between the end walls)
            translate([endw,0,0]) rotate([90,0,90])
                linear_extrude(LX-2*endw)
                    polygon([[0,0],[depth,0],[depth, base+depth*t],[0,base]]);
            // end walls (sloped top: lip height at front -> back-wall height at back)
            for (sx=[0, LX-endw])
                translate([sx,0,0]) rotate([90,0,90])
                    linear_extrude(endw)
                        polygon([[0,0],[depth,0],[depth,Hb],[0,Hl]]);
            cube([LX, lipw, Hl]);                                     // front lip
            translate([0, depth-bw, 0]) cube([LX, bw, Hb]);          // back wall
            if (foot>0)                                               // anti-slip feet
                for (fx=[foot, LX-foot]) for (fy=[foot, depth-foot])
                    translate([fx,fy,-1.0]) cylinder(h=1.2, r=foot*0.6);
        }
        // ---- lane grooves (open top), pen cradles ----
        for (i=[0:n-1])
            translate([endw-eps, yc[i], zc[i]]) rotate([0,90,0])
                cylinder(h=LX-2*endw+2*eps, r=r);
        // ---- finger scoop: scallop front lip at mid-length of each lane ----
        if (scoop)
            for (i=[0:n-1])
                translate([LX/2, yc[i]-r-1, zc[i]]) scale([1,1,0.9]) sphere(r=8.5);
        // ---- dial relief: wider open pocket near +X end of each lane ----
        if (dial)
            for (i=[0:n-1])
                translate([relief_cx, yc[i], zc[i]]) rotate([0,90,0])
                    cylinder(h=dial_len, r=dialr);
        // ---- cosmetic chamfer on the four top vertical corners ----
        if (cham>0)
            for (cx=[0,LX]) for (cy=[0,depth])
                translate([cx,cy,-1]) rotate([0,0,45])
                    cube([cham*2, cham*2, Hb+2], center=true);
    }
}
