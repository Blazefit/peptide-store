// Assembly preview: pens (gray) inside enclosed-bore + grab-window racks (blue).
// Lives outside designs/ so the verifier ignores it. Params via -D.
include <../designs/borewin_lib.scad>
N=4; STEPY=12; STEPZ=19; APX=1.4142; BASEW=0; RW=6.5;

color([0.30,0.50,0.90]) borewin(n=N, stepy=STEPY, stepz=STEPZ, rwin=RW,
                                 window=true, base_w=BASEW, apexk=APX);
for (i=[0:N-1]) {
    yc=(-(N-1)/2+i)*STEPY;
    zc=(WALL+RCH)+i*STEPZ;
    color([0.62,0.62,0.64])
        translate([0,yc,zc]) rotate([0,90,0]) cylinder(h=PEN_L, r=PEN_B/2, center=true);
    color([0.45,0.45,0.47])
        translate([PEN_L/2-8,yc,zc]) rotate([0,90,0]) cylinder(h=14, r=PEN_B/2+0.6, center=true);
}
