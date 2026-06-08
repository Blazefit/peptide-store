// 06_lever_cam.scad
// VARIANT 6: Eccentric-disk cam with integral lever arm — front+ends, flush back
//
// Instead of a D-lobe, each cam is an eccentric disk:
//   • In lock=0: disk center shifted outward → disk clears rim (tray drops free)
//   • In lock=1: disk center shifted inward  → disk overhangs rim + eccentric
//                ramp portion cams the rim DOWN as you rotate
//
// Integral flat lever arm (thumb paddle) extends from disk outboard edge for
// easy one-finger 90° twist. Low-profile — lever lies flat, well below overhead
// shelf concern. Accessible from front and short ends.
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

rim_top = NH + TH;  // 83

post_r     = 6;
post_h     = 38;
cam_bot    = 27;   // z=77 absolute
cam_h      = 11;
cam_top    = cam_bot + cam_h;
disk_r     = 10;   // eccentric disk radius
ecc        = 4;    // eccentricity offset
lever_len  = 20;   // lever arm length beyond disk edge
lever_w    = 8;
lever_t    = 4;    // lever thickness
cap_r      = post_r + 2.5;
cap_h      = 5;
gap        = 0.4;

post_off = post_r + gap + 1.2;

posts = [
    [-post_off,    -post_off, 1],
    [ NW+post_off, -post_off, 2],
    [-post_off,     ND/2,     3],
    [ NW+post_off,  ND/2,     4],
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

module eccentric_cam(id) {
    rot = lock==1 ? inward_ang(id) : open_ang(id);
    color(C_cam)
    rotate([0,0,rot]) {
        difference() {
            union() {
                // eccentric disk shifted in +X direction
                translate([ecc, 0, 0])
                    cylinder(r=disk_r, h=cam_h);
                // lever arm extending outward
                translate([ecc+disk_r-1, -lever_w/2, cam_h/2-lever_t/2])
                    cube([lever_len, lever_w, lever_t]);
                // lever tip roundover (grip pad)
                translate([ecc+disk_r+lever_len-1, 0, cam_h/2])
                    rotate([90,0,0])
                    cylinder(r=lever_t/2+0.5, h=lever_w, center=true);
                // texture nubs on lever
                for (lx=[4,10,16])
                    translate([ecc+disk_r+lx-1, -lever_w/2-0.5, cam_h/2-1])
                        cube([2, lever_w+1, 2]);
            }
            // bore
            cylinder(r=post_r+gap, h=cam_h+1);
            // eccentric underside wedge ramp (2mm at inboard edge → 0 at outboard)
            // creates the cam pull-down when swinging inward
            translate([ecc, 0, -0.1])
            rotate([3,0,0])
                cylinder(r=disk_r+0.5, h=2.5);
        }
    }
}

module post_assembly(id) {
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
    translate([0,0,cam_bot]) eccentric_cam(id);
}

new_tray();
top_tray();

for (p = posts)
    translate([p[0], p[1], NH])
        post_assembly(p[2]);
