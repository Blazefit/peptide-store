include <../designs/lipcradle_lib.scad>
N=4; PHI=36; PP=22.5; LH=6;
color([0.30,0.50,0.90]) lipcradle(n=N, phi=PHI, P=PP, lip=LH, scoop=false, side_open=true);
for(i=[0:N-1]){
    yc=(-(N-1)/2+i)*PP*cos(PHI);
    zc=(WALL+RCH)+i*PP*sin(PHI);
    color([0.62,0.62,0.64]) translate([0,yc,zc]) rotate([0,90,0])
        cylinder(h=PEN_L, r=PEN_B/2, center=true);
}
