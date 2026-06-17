// Assembly preview: real pens (gray) seated in a rack (blue). NOT a design file
// (lives outside designs/, so the verifier ignores it). Params via -D.
include <../designs/rack_lib.scad>
N    = 4;
PHI  = 58;
Pp   = 22.5;
LIPp = 2.5;
FLEXp = 0;

color([0.30, 0.50, 0.90]) rack(n=N, phi=PHI, P=Pp, lip=LIPp, endwall=3, scoop=true, flex=FLEXp);

cph = cos(PHI);
sph = sin(PHI);
for (i = [0:N-1]) {
    yc = (-(N-1)/2 + i) * Pp * cph;
    zc = (RCH + WALL) + i * Pp * sph;
    color([0.62, 0.62, 0.64])
        translate([0, yc, zc]) rotate([0,90,0])
            cylinder(h = PEN_L, r = PEN_B/2, center=true);   // true pen: r=10
    // dose dial: a slightly fatter ring near the +X end
    color([0.45,0.45,0.47])
        translate([PEN_L/2 - 8, yc, zc]) rotate([0,90,0])
            cylinder(h = 14, r = PEN_B/2 + 0.6, center=true);
}
