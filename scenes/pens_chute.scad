include <../designs/sk2_chute.scad>
// 4 pens rolled to the front, stacked against the catch wall
for (i=[0:3]) {
    yc = FW + RCH + i*2*RCH*cos(THETA);
    zc = BASE + yc*t + RCH*cos(THETA);
    color([0.62,0.62,0.64])
        translate([EW+LXIN/2, yc, zc]) rotate([0,90,0])
            cylinder(h=PEN_L, r=PEN_B/2, center=true);
}
