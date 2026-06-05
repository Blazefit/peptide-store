// lipcradle_lib.scad — SINGLE-PART reclined rack with an integral front lip per
// cradle (no cover). Continuous solid curbs (ramp sheared above the pen centers)
// + a solid base. Pens nestle in and lift out the front over the lip — no snap,
// nothing tolerance-critical.
//   endcaps : closed walls at BOTH ends of every channel so pens can't slide out
//             the ends if the rack is tipped sideways.
//   scoop   : a finger scallop at the front-center of each cradle so you can get
//             a fingertip under a pen to lift it out.
//   dial relief : a wider open-top pocket at the +X end so the dose dial clears
//             and can be turned (kept inside the end wall).
include <common.scad>

LBLK = PEN_L + 7;   // 172
ENDW = (LBLK - PEN_L) / 2;   // 3.5 mm end wall each side when endcaps=true

module lipcradle(n=4, phi=36, P=22.5, lip=6, rr=RCH+2, rlen=25,
                 base_h=3, endcaps=true, scoop=true) {
    cph=cos(phi); sph=sin(phi);
    yc=[for(i=[0:n-1]) (-(n-1)/2+i)*P*cph];
    zc=[for(i=[0:n-1]) (WALL+RCH)+i*P*sph];
    ymn=min(yc)-RCH-WALL; ymx=max(yc)+RCH+WALL;
    Wb=ymx-ymn; ycen=(ymx+ymn)/2; Hb=max(zc)+RCH+8;
    big=800;
    chan_len = endcaps ? PEN_L : LBLK+2;       // closed ends vs through
    relief_cx = PEN_L/2 - rlen/2;              // dial pocket inside the +X wall

    difference() {
        union() {
            // wedge sheared 'lip' above the cradle centers -> continuous curbs
            difference() {
                translate([0,ycen,Hb/2]) cube([LBLK,Wb,Hb],center=true);
                translate([0,yc[0],zc[0]+lip]) rotate([phi,0,0])
                    translate([0,0,big/2]) cube([LBLK+2,big,big],center=true);
            }
            translate([0,ycen,base_h/2]) cube([LBLK,Wb,base_h],center=true); // base
        }
        for(i=[0:n-1]) {
            // pen channel (closed both ends when endcaps)
            translate([0,yc[i],zc[i]]) rotate([0,90,0])
                cylinder(h=chan_len, r=RCH, center=true);
            // dial relief: wider open-top pocket near the +X end (inside the wall)
            translate([relief_cx,yc[i],zc[i]]) rotate([0,90,0])
                cylinder(h=rlen, r=rr, center=true);
            // finger scoop: scallop the front curb at mid-length to lift the pen
            if (scoop)
                translate([0, yc[i]-RCH*cph-1.5, zc[i]-RCH*sph+1.5])
                    scale([0.7,1,1]) sphere(r=11);
        }
    }
}
