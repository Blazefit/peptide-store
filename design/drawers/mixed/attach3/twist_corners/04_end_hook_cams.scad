// 04_end_hook_cams.scad
// VARIANT 4: Short-end HOOK cams + two front corner cams — flush back
//
// The short-end cams (x=0, x=305) have an L-shaped hook profile:
//   In lock=0: hook tail points away from tray — open channel, drop freely
//   In lock=1: hook rotated 90° so the horizontal toe goes OVER the short-end rim
//              and a 2mm deep notch on the underside of the toe grabs/pulls rim down
//
// Front two posts are simple D-lobe cams for front alignment + security.
// Back guide wall on new tray — no hardware past y=102.
//
// Tray dims:
//   New tray : 305 × 102 × 50, wall=3
//   Top tray : 305 × 102 × 33, base z=50, rim top z=83

lock = 1;

$fn = 48;

C_new = "#1565C0";
C_top = "#90A4AE";
C_cam = "#6A1B9A";

NW = 305; ND = 102; NH = 50;
TW = 305; TD = 102; TH = 33;
wall = 3;

rim_top_z = NH + TH;  // 83

post_r  = 6;
post_h  = 40;
cam_bot = 27;
cam_h   = 12;
cam_top = cam_bot + cam_h;
lobe_r  = 12;
cap_r   = post_r + 2.5;
cap_h   = 5;
gap     = 0.4;

hook_toe_l  = 9;   // horizontal toe length (overhangs rim)
hook_toe_h  = 5;   // toe height
hook_notch  = 2;   // depth of pull-down notch

post_off = post_r + gap + 1.2;

// [x, y, id, type]
// type 0 = D-lobe,  type 1 = hook
posts = [
    [-post_off,    -post_off, 1, 0],   // front-left  D-lobe
    [ NW+post_off, -post_off, 2, 0],   // front-right D-lobe
    [-post_off,     ND/2,     3, 1],   // left-end    hook
    [ NW+post_off,  ND/2,     4, 1],   // right-end   hook
];

function inward_ang(id) =
    id==1 ?  45 :
    id==2 ? 135 :
    id==3 ?   0 :
    180;

function open_ang(id) = inward_ang(id) + 90;

module new_tray() {
    color(C_new) {
        difference() {
            cube([NW, ND, NH]);
            translate([wall, wall, wall])
                cube([NW-2*wall, ND-2*wall, NH]);
        }
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

module dlobe_cam(id) {
    rot = lock==1 ? inward_ang(id) : open_ang(id);
    color(C_cam)
    rotate([0,0,rot]) {
        difference() {
            union() {
                intersection() {
                    cylinder(r=lobe_r, h=cam_h);
                    translate([0,-lobe_r,0]) cube([lobe_r+1, 2*lobe_r, cam_h]);
                }
                for (a=[-15,0,15])
                    rotate([0,0,a]) translate([post_r+1,-1,cam_h-2]) cube([lobe_r-post_r-2,2,3]);
            }
            cylinder(r=post_r+gap, h=cam_h+1);
            translate([0,0,-0.1]) rotate([3,0,0])
                translate([-lobe_r-1,-lobe_r-1,-0.5]) cube([2*(lobe_r+1),lobe_r+1,2.5]);
        }
    }
}

// Hook cam: in locked position the hook toe goes over the rim
// Open: toe points away (rotated 90° from locked)
module hook_cam(id) {
    rot = lock==1 ? inward_ang(id) : open_ang(id);
    color(C_cam)
    rotate([0,0,rot]) {
        difference() {
            union() {
                // vertical shank (sleeve around post)
                cylinder(r=post_r-gap-0.2, h=cam_h);
                // L-shaped hook body:  shank at x+, horizontal toe going in +X
                // shank is the lobe body (parallel to post), toe overhangs rim
                translate([post_r-gap, -3.5, 0])
                    cube([hook_toe_l + 2, 7, cam_h]);
                // horizontal toe cap at top
                translate([post_r-gap, -(hook_toe_h/2), cam_h-hook_notch-1])
                    cube([hook_toe_l+2, hook_toe_h, hook_notch+2]);
                // finger grip ribs on side
                for (gz=[1, cam_h-6])
                    translate([post_r+hook_toe_l-1, -1.5, gz])
                        cube([3.5, 3, 3.5]);
            }
            // bore
            cylinder(r=post_r+gap, h=cam_h+1);
            // pull-down notch on toe underside (grabs rim top face)
            translate([post_r+2, -(hook_toe_h/2+1), cam_h-hook_notch-1])
                cube([hook_toe_l, hook_toe_h+2, hook_notch]);
        }
    }
}

module post_assembly(id, type) {
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
    translate([0,0,cam_bot]) {
        if (type==0) dlobe_cam(id);
        else         hook_cam(id);
    }
}

new_tray();
top_tray();

for (p = posts)
    translate([p[0], p[1], NH])
        post_assembly(p[2], p[3]);
