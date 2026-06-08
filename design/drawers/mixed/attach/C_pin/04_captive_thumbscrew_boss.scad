// 04_captive_thumbscrew_boss.scad
// Printed ear-boss on each short end of the lower tray (outer face, near top).
// A matching flange ear on the upper tray aligns over it.
// An M4 thumbscrew passes through the upper flange and threads into the lower boss,
// clamping the trays together. One boss per short end (2 total).
// ENGAGE: press trays together, twist thumbscrew finger-tight.
// RELEASE: unscrew thumbscrew ~5 turns; lift upper tray.
//
// explode=0  → engaged
// explode=38 → exploded/open

explode = 38;

lx=305; ly=102; lz=50;
ux=305; uy=102; uz=33;

m4_clear  = 4.6;   // clearance hole Ø
m4_tap    = 3.5;   // printed thread Ø
ear_w     = 22;    // ear width in Y (centred on tray)
ear_h     = 18;    // ear height in Z
ear_t     = 7;     // ear protrusion in X from end face
knurl_d   = 18;    // thumbscrew head Ø
knurl_h   = 9;
shaft_d   = 5;

// Lower ear is at top of lower tray, centred at Z = lz - ear_h*0.4
// so ~60% of ear height is in lower tray, ~40% straddles the joint
lower_ear_cz = lz - ear_h * 0.4;
// Upper flange ear mirrors: in upper tray local Z it's at +ear_h*0.4
upper_ear_cz_local = ear_h * 0.4;  // in upper tray local coords

module lower_tray() { color("SteelBlue",0.85)    cube([lx,ly,lz]); }
module upper_tray() { color("LightSkyBlue",0.85) cube([ux,uy,uz]); }

// Ear protruding outward from end face
module ear_body(side, x_off, cz, tapped) {
    x0 = (side==0) ? x_off - ear_t : x_off;
    difference() {
        translate([x0, ly/2 - ear_w/2, cz - ear_h/2])
            cube([ear_t, ear_w, ear_h]);
        translate([(side==0) ? x0-0.1 : x0-0.1, ly/2, cz])
            rotate([0, 90, 0])
                cylinder(d = tapped ? m4_tap : m4_clear, h=ear_t+0.2, $fn=18);
    }
}

// Lower tray + lower ears
lower_tray();
color("DarkOrange",0.92)
for(s=[0,1]) {
    x_off = (s==0) ? 0 : lx;
    ear_body(s, x_off, lower_ear_cz, true);
}

// Upper tray + upper flanges (lifted by explode)
translate([0, 0, lz + explode]) {
    upper_tray();
    color("CornflowerBlue",0.92)
    for(s=[0,1]) {
        x_off = (s==0) ? 0 : ux;
        ear_body(s, x_off, upper_ear_cz_local, false);
    }
}

// Thumbscrews — shown alongside upper tray when exploded
// World Z of upper ear centres = lz + explode + upper_ear_cz_local
for(s=[0,1]) {
    ear_world_z = lz + explode + upper_ear_cz_local;
    head_x = (s==0) ? -(ear_t + knurl_h + 5) : lx + ear_t + knurl_h + 5;
    color("Silver",0.95)
    translate([head_x, ly/2, ear_world_z])
    rotate([0, (s==0) ? -90 : 90, 0]) {
        cylinder(d=knurl_d, h=knurl_h, $fn=6);
        for(i=[1,2])
            translate([0,0, i*(knurl_h/3)])
                difference() {
                    cylinder(d=knurl_d+1.2, h=1.5, $fn=6);
                    cylinder(d=knurl_d-0.5, h=1.5, $fn=6);
                }
        translate([0, 0, -ear_t-12])
            cylinder(d=shaft_d, h=ear_t+12, $fn=18);
    }
}
