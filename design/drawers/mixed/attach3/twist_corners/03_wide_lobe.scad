// 03_wide_lobe.scad
// VARIANT 3: Wide "spanner" lobe — front corners + short ends, flush back guide
//
// Like V2 but the lobe is wider (spans ~120° arc) so it's easier to grip and
// covers more rim area. Also adds a stepped undercut on the lobe underside so
// the rim snaps into a shallow pocket in lock=1, giving a positive locked feel.
// Back/door side: no hardware, flush guide wall on new tray.
//
// Tray dims:
//   New tray : 305 × 102 × 50, wall=3
//   Top tray : 305 × 102 × 33, base z=50, rim top z=83

lock = 1;  // 0=open, 1=locked

$fn = 48;

C_new = "#1565C0";
C_top = "#90A4AE";
C_cam = "#00897B";  // teal variant

NW = 305; ND = 102; NH = 50;
TW = 305; TD = 102; TH = 33;
wall = 3;

rim_top_z = NH + TH;  // 83

post_r    = 6.5;
post_h    = 42;
cam_bot   = 27;   // z=77 (a little below rim bottom)
cam_top   = 39;   // z=89
cam_h     = cam_top - cam_bot;
lobe_r    = 13;   // larger radius for wider grip
lobe_ang  = 120;  // arc sweep of lobe
cap_r     = post_r + 3;
cap_h     = 5;
gap       = 0.4;

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
        // Back flush guide wall
        translate([0, ND-wall, NH])
            cube([NW, wall, 5]);
        // Front alignment ledge (thin, 1mm protrusion inward, doesn't block drop)
        translate([wall, 0, NH])
            cube([NW-2*wall, 1, 2]);
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

module cam_body(id) {
    rot = lock==1 ? inward_ang(id) : open_ang(id);
    color(C_cam)
    rotate([0,0,rot]) {
        difference() {
            union() {
                // wide arc lobe
                rotate_extrude(angle=lobe_ang)
                    translate([post_r+0.5, 0, 0])
                    square([lobe_r - post_r - 0.5, cam_h]);
                // top cap disc for finger grip
                translate([0,0,cam_h-2])
                    difference() {
                        rotate_extrude(angle=lobe_ang)
                            translate([post_r+0.5,0,0])
                            square([lobe_r-post_r+2, 2]);
                        cylinder(r=post_r+gap+0.1, h=3);
                    }
                // radial finger ribs on outer edge
                for (a = [20, 60, 100])
                    rotate([0,0,a])
                    translate([lobe_r-1, -1.5, 1])
                        cube([3, 3, cam_h-3]);
            }
            // bore
            cylinder(r=post_r+gap, h=cam_h+1);
            // stepped undercut on lobe underside: 1.5mm deep pocket to catch rim top
            // The rim top is 3mm wide, pocket grabs rim when fully rotated
            rotate_extrude(angle=lobe_ang+5)
                translate([post_r+gap+0.5, 0, 0])
                polygon([[0,0],[lobe_r-post_r-gap,0],[lobe_r-post_r-gap,2],[3,2],[3,0]]);
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
        for (sa = [inward_ang(id), open_ang(id)])
            rotate([0,0,sa])
            translate([post_r-0.5, -1.2, 0])
                cube([2.5, 2.4, 3]);
    }
    translate([0,0,cam_bot]) cam_body(id);
}

new_tray();
top_tray();

for (p = posts)
    translate([p[0], p[1], NH])
        post_assembly(p[2]);
