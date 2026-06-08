// 05_front_mid_cam.scad
// VARIANT 5: Front corners + front MIDPOINT cam — 3 points on front edge only
//
// Three posts on the FRONT edge (y≤0):
//   • Two corner posts at (0,-off) and (305,-off)
//   • One mid post at (152,-off)
// Two end posts at (x<0, y=51) and (x>305, y=51) for short-end clamping.
// Back completely flush — a full-width back guide wall on the new tray.
//
// The mid-front cam has a larger lobe (r=14) for easy centering pull-down.
//
// Tray dims:
//   New tray : 305 × 102 × 50, wall=3
//   Top tray : 305 × 102 × 33, base z=50, rim top z=83

lock = 1;

$fn = 48;

C_new = "#1565C0";
C_top = "#90A4AE";
C_cam = "#00897B";

NW = 305; ND = 102; NH = 50;
TW = 305; TD = 102; TH = 33;
wall = 3;

post_r    = 6;
post_h    = 40;
cam_bot   = 27;
cam_h     = 11;
cam_top   = cam_bot + cam_h;
lobe_r    = 12;
lobe_r_mid= 14;    // bigger lobe at center
cap_r     = post_r + 2.5;
cap_h     = 5;
gap       = 0.4;

post_off = post_r + gap + 1.2;

// [x, y, id, lobe_radius]
posts = [
    [-post_off,    -post_off,  1, lobe_r],      // front-left
    [ NW+post_off, -post_off,  2, lobe_r],      // front-right
    [ NW/2,        -post_off,  5, lobe_r_mid],  // front-mid
    [-post_off,     ND/2,      3, lobe_r],      // left-end
    [ NW+post_off,  ND/2,      4, lobe_r],      // right-end
];

// inward angle (toward tray center):
//   corner posts: diagonal in; end posts: horizontal in; mid-front: +Y in
function inward_ang(id) =
    id==1 ?  45 :
    id==2 ? 135 :
    id==3 ?   0 :
    id==4 ? 180 :
    90;   // mid-front: straight inward (toward +Y)

function open_ang(id) = inward_ang(id) + 90;

module new_tray() {
    color(C_new) {
        difference() {
            cube([NW, ND, NH]);
            translate([wall, wall, wall])
                cube([NW-2*wall, ND-2*wall, NH]);
        }
        // Full-width back guide wall — flush with y=ND, zero protrusion
        translate([0, ND-wall, NH]) cube([NW, wall, 5]);
    }
}

module top_tray() {
    color(C_top)
    translate([0,0,NH])
    difference() {
        cube([TW, TD, TH]);
        translate([wall, wall, 0])
            cube([TW-2*wall, TD-2*wall, TH-wall]);
    }
}

module cam_body(id, lr) {
    rot = lock==1 ? inward_ang(id) : open_ang(id);
    color(C_cam)
    rotate([0,0,rot]) {
        difference() {
            union() {
                // D-lobe
                intersection() {
                    cylinder(r=lr, h=cam_h);
                    translate([0,-lr,0]) cube([lr+1, 2*lr, cam_h]);
                }
                // grip ribs
                for (a=[-15,0,15])
                    rotate([0,0,a]) translate([post_r+1,-1.2,cam_h-2])
                        cube([lr-post_r-2, 2.4, 3.5]);
            }
            cylinder(r=post_r+gap, h=cam_h+1);
            // underside pull-down ramp
            translate([0,0,-0.1]) rotate([4,0,0])
                translate([-lr-1,-lr-1,-0.5]) cube([2*(lr+1),lr+1,3]);
        }
    }
}

module post_assembly(id, lr) {
    color(C_new) {
        cylinder(r=post_r, h=post_h);
        translate([0,0,cam_top+gap])
        difference() {
            cylinder(r=cap_r, h=cap_h);
            cylinder(r=post_r+gap, h=cap_h+1);
        }
        cylinder(r=post_r+4, h=3);
        for (sa=[inward_ang(id), open_ang(id)])
            rotate([0,0,sa])
            translate([post_r-0.5,-1.2,0]) cube([2.5,2.4,3]);
    }
    translate([0,0,cam_bot]) cam_body(id, lr);
}

new_tray();
top_tray();

for (p = posts)
    translate([p[0], p[1], NH])
        post_assembly(p[2], p[3]);
