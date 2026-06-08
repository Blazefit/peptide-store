// 06_overcenter_cam.scad
// FLIP-LEVER RIM CLAMP — Variant: full-length FRONT cam bar with an OVER-CENTER
// camming lip that PULLS the rim DOWN. As the bar rotates from open to locked it
// rolls past top-dead-center; the lip's eccentric underside (a ramped cam face)
// presses the rim top and seats into a locked over-center pocket so it cannot
// spring back. + end clamps. NONE on back/door.
//
// Captive pin hinge (0.4mm) on the FRONT wall, axis along X at z=42 so the cam
// throw is generous.
include <common.scad>
C_lever = "#EF6C00";
lock = 0;
$fn = 48;

hinge_z   = NH - 8;        // z=42, lower pivot => more cam throw
pin_r     = 2.0;
knuckle_r = pin_r + 2.4;
bar_len   = 250;
bar_t     = 3.2;
arm_len   = rim_top_z - hinge_z + 3;   // reach just over rim
n_knuck   = 9;

// over-center: locked angle goes a touch PAST vertical-inward so the lip is
// captured; open angle folds down/out.
ang_open   = -108;
ang_locked = 10;           // past TDC -> over-center hold
bar_ang = lock ? ang_locked : ang_open;

module wall_knuckles() {
    seg = bar_len/n_knuck;
    color(C_new)
    for (i=[0:2:n_knuck-1])
        translate([(NW-bar_len)/2 + i*seg, 0, hinge_z])
            rotate([0,90,0]) cylinder(r=knuckle_r, h=seg*0.96);
}
module bar_knuckles() {
    seg = bar_len/n_knuck;
    for (i=[1:2:n_knuck-1])
        translate([(NW-bar_len)/2 + i*seg, 0, hinge_z])
            rotate([0,90,0]) cylinder(r=knuckle_r, h=seg*0.96);
}

// cam lip with ramped (eccentric) underside that bites the rim as it rotates
module cam_lip() {
    lip_ext = 6;
    lip_t   = 4.0;
    difference() {
        translate([(NW-bar_len)/2, 0, arm_len-lip_t]) cube([bar_len, lip_ext, lip_t]);
        // eccentric ramp on the underside (the cam working face)
        translate([(NW-bar_len)/2-1, -0.1, arm_len-lip_t-0.1])
            rotate([18,0,0]) cube([bar_len+2, lip_ext+1, 2.4]);
    }
}

module front_cam_bar() {
    color(C_lever)
    translate([0,0,hinge_z])
    rotate([bar_ang,0,0])
    union() {
        bar_knuckles();
        translate([(NW-bar_len)/2, -bar_t, 0]) cube([bar_len, bar_t, arm_len]);
        cam_lip();
        translate([NW/2-13, -bar_t-6, 2]) cube([26,6,8]);  // finger tab
    }
    color(C_lever)
    translate([(NW-bar_len)/2-2,0,hinge_z]) rotate([0,90,0])
        cylinder(r=pin_r, h=bar_len+4);
}

end_w = 30;
module end_clamp(side) {
    xbase = side<0 ? 0.6 : NW - 0.6;
    eang = lock ? 8 : -108;
    yoff = (ND-end_w)/2;
    sx = side<0 ? 1 : -1;
    la = rim_top_z - hinge_z + 4;
    color(C_lever)
    translate([xbase, yoff, hinge_z])
    rotate([0, side<0 ? -eang : eang, 0])
    union() {
        translate([sx<0 ? -bar_t:0, 0, 0]) cube([bar_t, end_w, la]);
        translate([sx<0 ? -6:0, 0, la-4]) cube([6, end_w, 4]);
        translate([sx<0 ? -bar_t-6:bar_t, end_w/2-4, 2]) cube([6,8,8]);
    }
}

new_tray();
back_guide();
top_tray();
wall_knuckles();
front_cam_bar();
end_clamp(-1);
end_clamp(1);
