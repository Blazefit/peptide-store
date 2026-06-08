// 03_pinhinge_bar.scad
// FLIP-LEVER RIM CLAMP — Variant (a') full-length FRONT flip bar on a
// PRINT-IN-PLACE CAPTIVE PIN hinge (knuckles + 0.4mm clearance) + end clamps.
// Captive pin gives a crisper, more durable axis than a living hinge for a
// full-width bar. NONE on back/door.
//
// Hinge axis: horizontal along X at z=44 on the FRONT wall.
include <common.scad>
C_lever = "#2E7D32";
lock = 0;
$fn = 48;

hinge_z   = NH - 6;        // z=44 pivot center
pin_r     = 2.0;
pin_gap   = 0.4;           // print-in-place clearance
knuckle_r = pin_r + 2.2;
bar_len   = 250;
bar_t     = 3.0;
arm_len   = rim_top_z - hinge_z + 4;
lip_ext   = 5;
lip_t     = 3.0;
n_knuck   = 9;

ang_open   = -105;
ang_locked = 6;
bar_ang = lock ? ang_locked : ang_open;

// fixed knuckles on the tray front wall (alternate with moving ones)
module wall_knuckles() {
    seg = bar_len/n_knuck;
    color(C_new)
    for (i = [0:2:n_knuck-1])
        translate([(NW-bar_len)/2 + i*seg, 0, hinge_z])
            rotate([0,90,0]) cylinder(r=knuckle_r, h=seg*0.96);
}

module bar_knuckles() {
    seg = bar_len/n_knuck;
    for (i = [1:2:n_knuck-1])
        translate([(NW-bar_len)/2 + i*seg, 0, hinge_z])
            rotate([0,90,0]) cylinder(r=knuckle_r, h=seg*0.96);
}

module front_flip_bar() {
    color(C_lever)
    translate([0, 0, hinge_z])
    rotate([bar_ang, 0, 0])
    union() {
        bar_knuckles();
        // arm shaft from the pin outward then up
        translate([(NW-bar_len)/2, -bar_t, 0]) cube([bar_len, bar_t, arm_len]);
        translate([(NW-bar_len)/2, 0, arm_len-lip_t]) cube([bar_len, lip_ext, lip_t]);
        translate([(NW-bar_len)/2, lip_ext, arm_len-lip_t])
            rotate([45,0,0]) translate([0,-1.2,-1.2]) cube([bar_len,1.7,1.7]);
        // finger tab
        translate([NW/2-11, -bar_t-5, 2]) cube([22,5,7]);
    }
    // the captive pin itself (prints inside the knuckle bores)
    color(C_lever)
    translate([(NW-bar_len)/2-2, 0, hinge_z]) rotate([0,90,0])
        cylinder(r=pin_r, h=bar_len+4);
}

end_w = 26;
module end_clamp(side) {
    xbase = side<0 ? 0.6 : NW - 0.6;
    eang = lock ? 6 : -105;
    yoff = (ND-end_w)/2;
    sx = side<0 ? 1 : -1;
    color(C_lever)
    translate([xbase, yoff, hinge_z])
    rotate([0, side<0 ? -eang : eang, 0])
    union() {
        translate([sx<0 ? -bar_t:0, 0, 0]) cube([bar_t, end_w, arm_len]);
        translate([sx<0 ? -lip_ext:0, 0, arm_len-lip_t]) cube([lip_ext, end_w, lip_t]);
        translate([sx<0 ? -bar_t-5:bar_t, end_w/2-3, 2]) cube([5,6,7]);
    }
}

new_tray();
back_guide();
top_tray();
wall_knuckles();
front_flip_bar();
end_clamp(-1);
end_clamp(1);
