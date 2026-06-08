// 02_front_end_cams.scad
// VARIANT 2: FRONT corners + SHORT ENDS only — flush back guide wall
//
// Posts at front two corners (x=0,y<0) and (x=305,y<0), plus short-end mid cams at
// (x<0, y=51) and (x>305, y=51). The entire back/door side is completely flush — no
// posts or hardware past y=102. A 3mm-tall raised guide lip along the back edge of
// the NEW tray locates the top tray but adds zero protrusion beyond y=102.
//
// Operation:
//   lock=0  lobes swept outward/away  → top tray drops straight down
//   lock=1  lobes swept ~90° inward over rim (z=83) and cam ramp pulls tray tight
//
// Tray dims:
//   New tray : 305 × 102 × 50, wall=3
//   Top tray : 305 × 102 × 33, base z=50, rim top z=83

lock = 1;  // 0=open, 1=locked

$fn = 48;

C_new = "#1565C0";
C_top = "#90A4AE";
C_cam = "#6A1B9A";

// ── master dims ─────────────────────────────────────────────────────────
NW = 305; ND = 102; NH = 50;
TW = 305; TD = 102; TH = 33;
wall = 3;

rim_top_z = NH + TH;  // 83

// ── post / cam geometry ─────────────────────────────────────────────────
post_r  = 6;
post_h  = 40;    // post extends from NH to NH+40 = z=90
cam_bot = 28;    // relative to post base → absolute z = NH+28 = 78
cam_top = 38;    // relative to post base → absolute z = NH+38 = 88
cam_h   = cam_top - cam_bot;  // 10 mm
lobe_r  = 12;
cap_r   = post_r + 2.5;
cap_h   = 5;
gap     = 0.4;   // print-in-place clearance

// ── post positions and inward angles ─────────────────────────────────────
//  id=1  front-left  corner  (x=0,  y<0)   inward toward center = +X +Y → 45°
//  id=2  front-right corner  (x=NW, y<0)   inward = -X +Y → 135°
//  id=3  left-end    mid     (x<0,  y=ND/2) inward = +X → 0° (but lobe goes over X face rim)
//  id=4  right-end   mid     (x>NW, y=ND/2) inward = -X → 180°

post_off = post_r + gap + 1.2;

// [pos_x, pos_y, id]
posts = [
    [-post_off,      -post_off,   1],   // front-left
    [ NW+post_off,   -post_off,   2],   // front-right
    [-post_off,       ND/2,       3],   // left-end mid
    [ NW+post_off,    ND/2,       4],   // right-end mid
];

function inward_ang(id) =
    id==1 ?  45 :
    id==2 ? 135 :
    id==3 ?   0 :
    180;

function open_ang(id) = inward_ang(id) + 90;  // 90° away from locked

// ── modules ─────────────────────────────────────────────────────────────

module new_tray() {
    color(C_new) {
        difference() {
            cube([NW, ND, NH]);
            translate([wall, wall, wall])
                cube([NW-2*wall, ND-2*wall, NH]);
        }
        // Back guide lip: locates top tray, flush with y=ND face (no protrusion past y=102)
        translate([0, ND-wall, NH])
            cube([NW, wall, 4]);
    }
}

module top_tray() {
    color(C_top)
    translate([0, 0, NH])
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
                // lobe: D-shape extending outward along +X axis before rotation
                intersection() {
                    cylinder(r=lobe_r, h=cam_h);
                    translate([0, -lobe_r, 0]) cube([lobe_r+1, 2*lobe_r, cam_h]);
                }
                // knurled finger ridges on top face of lobe
                for (a = [-20,0,20])
                    rotate([0,0,a])
                    translate([post_r+1, -1, cam_h-2])
                        cube([lobe_r-post_r-2, 2, 3]);
            }
            // bore: rotates on post
            cylinder(r=post_r+gap, h=cam_h+1);
            // underside taper ramp (3°) so lobe bottom cams tray down as it swings in
            translate([0,0,-0.1])
            rotate([3,0,0])
                translate([-lobe_r-1, -lobe_r-1, -0.5])
                cube([2*(lobe_r+1), lobe_r+1, 2.5]);
        }
    }
}

module post_assembly(id) {
    color(C_new) {
        cylinder(r=post_r, h=post_h);
        // retaining cap (keeps cam captive on post)
        translate([0,0, cam_top+gap])
        difference() {
            cylinder(r=cap_r, h=cap_h);
            cylinder(r=post_r+gap, h=cap_h+1);
        }
        // base flange
        cylinder(r=post_r+4, h=3);
        // rotation stop nubs at open and locked positions
        for (sa = [inward_ang(id), open_ang(id)])
            rotate([0,0,sa])
            translate([post_r-0.5, -1.2, 0])
                cube([2.5, 2.4, 3]);
    }
    translate([0,0,cam_bot]) cam_body(id);
}

// ── assembly ─────────────────────────────────────────────────────────────
new_tray();
top_tray();

for (p = posts)
    translate([p[0], p[1], NH])
        post_assembly(p[2]);
