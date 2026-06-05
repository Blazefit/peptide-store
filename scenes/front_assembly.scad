// Assembly preview: open-cradle body (blue) + pens (gray) + lift-off gate (orange).
include <../designs/gate_lib.scad>
N=4; PHI=62; PP=22.5; SHOWGATE=1; EXPLODE=0;
color([0.30,0.50,0.90]) body(n=N, phi=PHI, P=PP);
for(i=[0:N-1]){
    yc=_yc(N,PP,PHI,i); zc=_zc(N,PP,PHI,i);
    color([0.62,0.62,0.64]) translate([0,yc,zc]) rotate([0,90,0])
        cylinder(h=PEN_L, r=PEN_B/2, center=true);
}
// lay the standing gate onto the ramp face so windows align with the pens
nry=-sin(PHI); nrz=cos(PHI);     // ramp normal (up-front)
ty=cos(PHI);   tz=sin(PHI);      // ramp up-slope tangent
yc0=_yc(N,PP,PHI,0); zc0=_zc(N,PP,PHI,0);
gap=0.6; lip=2;
P0=[0, yc0+(lip+gap+EXPLODE)*nry-(RCH+4)*ty, zc0+(lip+gap+EXPLODE)*nrz-(RCH+4)*tz];
if (SHOWGATE)
  color([0.90,0.45,0.15])
    translate(P0) rotate([PHI-90,0,0]) gate(n=N, phi=PHI, P=PP);
