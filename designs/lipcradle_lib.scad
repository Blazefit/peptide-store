// lipcradle_lib.scad — SINGLE-PART reclined rack with a little front lip per
// cradle (no cover). Pens nestle into half-pipe cradles and lift out the front
// over a small rounded lip. The lip is a proud bump (not an undercut), so you
// lift the pen over it — no snap, no flex, nothing tolerance-critical.
include <common.scad>

LBLK = PEN_L + 7;   // 172

// n     : pens
// phi   : ramp angle (shallower holds better with a small lip; steeper fits more)
// P     : along-ramp spacing
// liph  : how far the front lip stands proud of the ramp (the "little lip")
// rr    : dial-relief radius
module lipcradle(n=3, phi=30, P=22.5, liph=4, rr=RCH+2, rlen=34) {
    cph=cos(phi); sph=sin(phi);
    yc=[for(i=[0:n-1]) (-(n-1)/2+i)*P*cph];
    zc=[for(i=[0:n-1]) (WALL+RCH)+i*P*sph];
    ymn=min(yc)-RCH-WALL; ymx=max(yc)+RCH+WALL;
    Wb=ymx-ymn; ycen=(ymx+ymn)/2; Hb=max(zc)+RCH+8;
    big=800; relief_cx=LBLK/2-12;
    nrY=-sph; nrZ=cph;          // ramp normal (up-front)
    tY=cph;   tZ=sph;           // up-slope tangent

    union() {
        difference() {
            // sheared wedge (ramp passes through the cradle centers)
            difference() {
                translate([0,ycen,Hb/2]) cube([LBLK,Wb,Hb],center=true);
                translate([0,yc[0],zc[0]]) rotate([phi,0,0])
                    translate([0,0,big/2]) cube([LBLK+2,big,big],center=true);
            }
            // half-pipe cradles (open up-front) + dial relief
            for(i=[0:n-1]) {
                translate([0,yc[i],zc[i]]) rotate([0,90,0])
                    cylinder(h=LBLK+2, r=RCH, center=true);
                translate([relief_cx,yc[i],zc[i]]) rotate([0,90,0])
                    cylinder(h=rlen, r=rr, center=true);
            }
        }
        // little rounded front lip along each cradle's down-slope rim (added
        // after the cut so it stands proud and gently narrows the opening)
        for(i=[0:n-1]) {
            rimY = yc[i] - RCH*tY;   rimZ = zc[i] - RCH*tZ;
            translate([0, rimY + 0.3*liph*nrY, rimZ + 0.3*liph*nrZ])
                rotate([0,90,0]) cylinder(h=LBLK, r=liph*0.75, center=true);
        }
    }
}
