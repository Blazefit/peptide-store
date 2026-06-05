// lipcradle_lib.scad — SINGLE-PART reclined rack with an integral front lip per
// cradle (no cover). The lip is formed by shearing the ramp slightly ABOVE the
// pen centers, so each lip is a continuous solid curb (not a perched nub). A
// base slab keeps the bottom-front solid (no knife edge). Pens nestle in and
// lift out the front over the lip — no snap, nothing tolerance-critical.
include <common.scad>

LBLK = PEN_L + 7;   // 172

// n      : pens
// phi    : ramp angle (shallower = holds better with a small lip)
// P      : along-ramp spacing
// lip    : ramp is sheared this far ABOVE the pen centers -> front curb height
// rr     : dial-relief radius (wider mouth at +X end)
// base_h : flat base slab thickness (solid bottom, kills the knife-edge toe)
module lipcradle(n=4, phi=36, P=22.5, lip=4, rr=RCH+2, rlen=34, base_h=3) {
    cph=cos(phi); sph=sin(phi);
    yc=[for(i=[0:n-1]) (-(n-1)/2+i)*P*cph];
    zc=[for(i=[0:n-1]) (WALL+RCH)+i*P*sph];
    ymn=min(yc)-RCH-WALL; ymx=max(yc)+RCH+WALL;
    Wb=ymx-ymn; ycen=(ymx+ymn)/2; Hb=max(zc)+RCH+8;
    big=800; relief_cx=LBLK/2-12;

    difference() {
        union() {
            // wedge sheared 'lip' above the cradle centers -> continuous curbs
            difference() {
                translate([0,ycen,Hb/2]) cube([LBLK,Wb,Hb],center=true);
                translate([0,yc[0],zc[0]+lip]) rotate([phi,0,0])
                    translate([0,0,big/2]) cube([LBLK+2,big,big],center=true);
            }
            // solid base slab (flat bottom, no fragile toe)
            translate([0,ycen,base_h/2]) cube([LBLK,Wb,base_h],center=true);
        }
        // half-pipe cradles + dial relief at the +X end
        for(i=[0:n-1]) {
            translate([0,yc[i],zc[i]]) rotate([0,90,0])
                cylinder(h=LBLK+2, r=RCH, center=true);
            translate([relief_cx,yc[i],zc[i]]) rotate([0,90,0])
                cylinder(h=rlen, r=rr, center=true);
        }
    }
}
