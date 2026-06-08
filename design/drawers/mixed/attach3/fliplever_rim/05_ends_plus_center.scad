// 05_ends_plus_center.scad
// FLIP-LEVER RIM CLAMP — Minimalist 3-latch: ONE central FRONT cam lever +
// one END clamp at each SHORT END. Three clamp points form a stable tripod
// (front-center + two ends) that pins the rigid top tray down; the BACK/door
// edge is held by the flush back guide wall + the tray's own corners.
// NONE on back/door.
//
// Living-hinge web on FRONT outer wall; end clamps on the END walls.
include <common.scad>
C_lever = "#2E7D32";
lock = 0;
$fn = 48;

hinge_z   = NH - 6;
arm_len   = rim_top_z - hinge_z + 4;
bar_t     = 3.2;
lhinge_t  = 0.6;
lip_ext   = 6;
lip_t     = 3.0;
cam_w     = 70;            // wide central lever

ang_open   = -105;
ang_locked = 6;
cam_ang = lock ? ang_locked : ang_open;

module front_cam(cx) {
    color(C_lever)
    translate([cx-cam_w/2, lhinge_t, hinge_z])
    rotate([cam_ang, 0, 0])
    union() {
        translate([0, -bar_t, 0]) cube([cam_w, bar_t, arm_len]);
        translate([0, 0, arm_len-lip_t]) cube([cam_w, lip_ext, lip_t]);
        translate([0, lip_ext, arm_len-lip_t])
            rotate([45,0,0]) translate([0,-1.2,-1.2]) cube([cam_w,1.7,1.7]);
        translate([cam_w/2-14, -bar_t-6, 2]) cube([28,6,8]);
    }
    color(C_lever)
    translate([cx-cam_w/2, 0, hinge_z-3]) cube([cam_w, lhinge_t, 3]);
}

end_w = 34;
module end_clamp(side) {
    xbase = side<0 ? lhinge_t : NW - lhinge_t;
    eang = lock ? 6 : -105;
    yoff = (ND-end_w)/2;
    sx = side<0 ? 1 : -1;
    color(C_lever)
    translate([xbase, yoff, hinge_z])
    rotate([0, side<0 ? -eang : eang, 0])
    union() {
        translate([sx<0 ? -bar_t:0, 0, 0]) cube([bar_t, end_w, arm_len]);
        translate([sx<0 ? -lip_ext:0, 0, arm_len-lip_t]) cube([lip_ext, end_w, lip_t]);
        translate([sx<0 ? -bar_t-6:bar_t, end_w/2-4, 2]) cube([6,8,8]);
    }
}

new_tray();
back_guide();
top_tray();
front_cam(NW/2);
end_clamp(-1);
end_clamp(1);
