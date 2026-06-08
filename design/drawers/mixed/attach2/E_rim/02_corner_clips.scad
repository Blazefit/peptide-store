// 02_corner_clips.scad
// RETROFIT: Four L-shaped corner clips integral to the NEW tray.
// Each clip wraps around ONE corner of the top tray (grabbing two outer faces)
// and projects a horizontal shelf that hooks OVER the top rim at z=83.
// Engagement: push top tray straight down — clips flex slightly then snap.
// Release: squeeze opposing corner pairs inward slightly, lift top tray.
// TOP TRAY FIXED — NO geometry added to it.
//
// LEFT: ENGAGED  |  RIGHT: EXPLODED

TW = 305; TD = 102; TH = 33;
NW = 305; ND = 102; NH = 50;
wall = 3;

// clip geometry
cl_leg   = 28;   // length of each L-leg along the tray edge
cl_t     = 3.5; // clip arm wall thickness
cl_h     = TH + 7;  // clip height above z=NH (must clear top tray TH=33)
lip_ext  = 6;   // rim lip horizontal reach inward
lip_t    = 4;   // rim lip vertical thickness
gap      = 0.4; // clearance between clip inner face and top tray outer face
// lead-in chamfer on clip inner bottom edge (aids snap-in)
chamfer  = 3;

C_new  = "#1565C0";
C_top  = "#90A4AE";
C_clip = "#C62828";  // deep red — corner clips

sep = NW + 40;

module new_tray_body() {
    color(C_new)
    difference() {
        cube([NW, ND, NH]);
        translate([wall, wall, wall])
            cube([NW-2*wall, ND-2*wall, NH]);
    }
}

module top_tray_body(dz=0) {
    color(C_top)
    translate([0, 0, NH + dz])
    difference() {
        cube([TW, TD, TH]);
        translate([wall, wall, 0])
            cube([TW-2*wall, TD-2*wall, TH-wall]);
    }
}

// Single L-clip, placed at the x=0,y=0 corner.
// The L wraps: one arm along +X (covering front face y<0),
//              one arm along +Y (covering left face x<0).
// Both arms have a rim-lip at the top.
module corner_clip() {
    color(C_clip)
    union() {
        // X-arm: covers outside of front face (y=0) for length cl_leg
        // outer face of arm at y = -(gap + cl_t), inner face at y = -gap
        translate([-cl_t, -(cl_t + gap), 0]) {
            difference() {
                cube([cl_leg + cl_t, cl_t, cl_h]);
                // lead-in chamfer on inner bottom
                translate([0, 0, 0])
                    rotate([45, 0, 0])
                    translate([0, -cl_t, 0])
                    cube([cl_leg + cl_t, cl_t*1.5, cl_t*1.5]);
            }
            // rim lip over top — extends inward (+Y)
            translate([0, 0, cl_h - lip_t])
                cube([cl_leg + cl_t, cl_t + lip_ext, lip_t]);
        }

        // Y-arm: covers outside of left face (x=0) for length cl_leg
        translate([-(cl_t + gap), -cl_t, 0]) {
            difference() {
                cube([cl_t, cl_leg + cl_t, cl_h]);
                translate([0, 0, 0])
                    rotate([0, -45, 0])
                    translate([-cl_t, 0, 0])
                    cube([cl_t*1.5, cl_leg + cl_t, cl_t*1.5]);
            }
            // rim lip
            translate([0, 0, cl_h - lip_t])
                cube([cl_t + lip_ext, cl_leg + cl_t, lip_t]);
        }
    }
}

module all_clips() {
    // Front-left corner (x=0, y=0)
    translate([0, 0, NH]) corner_clip();

    // Front-right corner (x=NW, y=0) — mirror X
    translate([NW, 0, NH]) mirror([1,0,0]) corner_clip();

    // Back-left corner (x=0, y=ND) — mirror Y
    translate([0, ND, NH]) mirror([0,1,0]) corner_clip();

    // Back-right corner (x=NW, y=ND) — mirror X+Y
    translate([NW, ND, NH]) mirror([1,0,0]) mirror([0,1,0]) corner_clip();
}

// ENGAGED
translate([0,0,0]) {
    new_tray_body();
    all_clips();
    top_tray_body(0);
}

// EXPLODED
translate([sep,0,0]) {
    new_tray_body();
    all_clips();
    top_tray_body(40);
}
