// 04_window_hook_cams.scad
// FLIP-LEVER RIM CLAMP — Variant: THREE front cam levers whose hook does DOUBLE
// duty — a finger enters the front WINDOW (z56..72) to key/locate the lever, and
// the same arm's upper lip reaches OVER the rim (z>=83) to clamp the TOP tray.
// + end clamps. NONE on back/door.
//
// Why both: the window finger resists side-shift and hides the lever profile
// (low overhead); the rim lip provides the actual vertical clamp on the rigid
// top tray. Pure window entry alone cannot clamp the top tray, so we add the
// rim lip. Living-hinge web on the FRONT outer wall, axis along X at z=44.
include <common.scad>
C_lever = "#EF6C00";
lock = 0;
$fn = 48;

hinge_z   = NH - 6;
arm_len   = rim_top_z - hinge_z + 4;   // up past rim
bar_t     = 3.0;
lhinge_t  = 0.6;
lip_ext   = 5;
lip_t     = 3.0;
cam_w     = 40;
windows_x = [76.25, 152.5, 228.75];

// window finger: short stub partway up the arm that swings into the window slot
win_finger_z = 56 - hinge_z;   // local z where window starts (=12)
win_finger_h = 14;

ang_open   = -105;
ang_locked = 6;
cam_ang = lock ? ang_locked : ang_open;

module front_cam(cx) {
    color(C_lever)
    translate([cx-cam_w/2, lhinge_t, hinge_z])
    rotate([cam_ang, 0, 0])
    union() {
        translate([0, -bar_t, 0]) cube([cam_w, bar_t, arm_len]);
        // window-keying finger reaching inward (+Y) into the slot span
        translate([cam_w/2-20, 0, win_finger_z])
            cube([40-0.6, 4, win_finger_h]);   // slightly narrower than 45 window
        // rim clamp lip on top
        translate([0, 0, arm_len-lip_t]) cube([cam_w, lip_ext, lip_t]);
        translate([0, lip_ext, arm_len-lip_t])
            rotate([45,0,0]) translate([0,-1.2,-1.2]) cube([cam_w,1.7,1.7]);
        translate([cam_w/2-8, -bar_t-5, 2]) cube([16,5,7]);
    }
    color(C_lever)
    translate([cx-cam_w/2, 0, hinge_z-3]) cube([cam_w, lhinge_t, 3]);
}

end_w = 26;
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
        translate([sx<0 ? -bar_t-5:bar_t, end_w/2-3, 2]) cube([5,6,7]);
    }
}

new_tray();
back_guide();
top_tray();
for (cx = windows_x) front_cam(cx);
end_clamp(-1);
end_clamp(1);
