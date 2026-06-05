// Assembly preview: open-cradle body (blue) + pens (gray) + lift-off gate (orange).
include <../designs/gate_lib.scad>
N=4; PHI=62; PP=22.5; SHOWGATE=1;
color([0.30,0.50,0.90]) body(n=N, phi=PHI, P=PP);
for(i=[0:N-1]){
    yc=_yc(N,PP,PHI,i); zc=_zc(N,PP,PHI,i);
    color([0.62,0.62,0.64]) translate([0,yc,zc]) rotate([0,90,0])
        cylinder(h=PEN_L, r=PEN_B/2, center=true);
}
// lay the standing gate onto the ramp face, just in front of the openings
ymn=_ymn(N,PP,PHI);
if (SHOWGATE)
  color([0.90,0.45,0.15])
    translate([0, ymn-2.5, 1])
      rotate([-(90-PHI),0,0])
        gate(n=N, phi=PHI, P=PP);
