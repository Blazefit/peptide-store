// 01_corner_cam.scad
// VARIANT 1: Corner post + D-lobe cam (simple quarter-turn)
// Four posts at corners, just outside the 305×102 top tray footprint.
// Each post has a print-in-place captive D-lobe cam retained by a flange cap.
// lock=0  → lobe rotated outward/away  (top tray drops freely between posts)
// lock=1  → lobe rotated 90° inward over rim (z≥83), clamping top tray down
//
// Tray dims (fixed reference):
//   New tray:  305 × 102 × 50,  wall=3
//   Top tray:  305 × 102 × 33,  base z=50, rim top z=83
//
// Print orientation: posts up, cam in-place on post.

lock = 1;  // 0=open, 1=locked

$fn = 48;

// ── colours ─────────────────────────────────────────────────────────
C_new  = "#1565C0";
C_top  = "#90A4AE";
C_cam  = "#6A1B9A";

// ── master dims ─────────────────────────────────────────────────────
NW = 305; ND = 102; NH = 50;
TW = 305; TD = 102; TH = 33;
wall = 3;

// ── post / cam geometry ─────────────────────────────────────────────
post_r   = 6;       // post cylinder radius
post_h   = 40;      // total post height above z=NH (post top at z=90)
cam_bot  = 28;      // cam bottom relative to post base → z=78 (just below rim at 83)
cam_top  = 38;      // cam top relative to post base   → z=88 (above rim)
cam_h    = cam_top - cam_bot;   // 10 mm
lobe_r   = 11;      // lobe tip radius from post axis
cap_r    = post_r + 2.5;
cap_h    = 5;
prn_gap  = 0.4;     // print-in-place clearance (all around cam bore)

// rotation stops: a small tab on post base that the cam index notch catches
stop_w   = 2.5;
stop_h   = 3;

// Posts just outside the 305×102 top-tray footprint — FRONT CORNERS ONLY
// Back/door side is flush — no posts at back corners.
// Back guide wall (flush, no protrusion) locates back of top tray.
post_off = post_r + prn_gap + 1.0;  // clearance between post inner and tray outer wall
corners = [
    [-post_off,        -post_off,        1],  // FL: inward dir = +X+Y = 45°
    [ TW + post_off,   -post_off,        2],  // FR: inward = -X+Y = 135°
];

// inward angle (toward tray centre) and open angle per corner id
function inward_ang(id) =
    id == 1 ? 45 :
    135; // id==2

function open_ang(id) = inward_ang(id) + 180;

// ── modules ─────────────────────────────────────────────────────────

module new_tray() {
    color(C_new) {
        difference() {
            cube([NW, ND, NH]);
            translate([wall, wall, wall])
                cube([NW-2*wall, ND-2*wall, NH]);
        }
        // Back guide wall — flush with y=ND, zero protrusion past y=102
        translate([0, ND-wall, NH]) cube([NW, wall, 5]);
    }
}

module top_tray() {
    color(C_top)
    translate([0, 0, NH])
    difference() {
        cube([TW, TD, TH]);
        translate([wall, wall, 0])
            cube([TW-2*wall, TD-2*wall, TH - wall]);
    }
}

// The cam lobe: a sector hull around the hub, with ramp on underside
module cam_body(id) {
    rot = lock == 1 ? inward_ang(id) : open_ang(id);
    color(C_cam)
    rotate([0, 0, rot]) {
        difference() {
            union() {
                // hub sleeve around post
                difference() {
                    cylinder(r = post_r - prn_gap, h = cam_h);
                    cylinder(r = post_r + prn_gap, h = cam_h + 1);
                }
                // D-lobe: half-disc extending outward
                intersection() {
                    cylinder(r=lobe_r, h=cam_h);
                    translate([0, -lobe_r, 0])
                        cube([lobe_r + 1, 2*lobe_r, cam_h]);
                }
                // finger grip tabs on lobe outboard edge
                for (gz = [1, cam_h - 4])
                    translate([lobe_r - 3, 0, gz])
                        rotate([0, 90, 0])
                        cylinder(r=2, h=4);
            }
            // bore: cam rotates on post with gap
            cylinder(r = post_r + prn_gap, h = cam_h + 1);
            // underside cam ramp: 4° taper so lobe face at z=0 is slightly lower than lobe_r tip
            // This pulls the tray down as lobe swings inward
            translate([0, 0, -0.1])
            rotate([4, 0, 0])
                translate([-lobe_r-1, -lobe_r-1, -0.5])
                cube([2*(lobe_r+1), lobe_r+1, 2.5]);
        }
    }
}

// Post: cylinder + retaining cap + base flange
module post_assembly(id) {
    color(C_new) {
        // main post shaft
        cylinder(r=post_r, h=post_h);
        // retaining flange cap (overhang keeps cam captive)
        translate([0, 0, cam_top + prn_gap])
            difference() {
                cylinder(r=cap_r, h=cap_h);
                cylinder(r=post_r + prn_gap, h=cap_h + 1);
            }
        // base flange (bonds post to new tray top face)
        cylinder(r=post_r + 4, h=3);
        // rotation stop tab (at open and locked positions) — tiny nub on base flange
        for (sa = [inward_ang(id), open_ang(id)])
            rotate([0,0,sa])
                translate([post_r - 1, -stop_w/2, 0])
                cube([stop_w, stop_w, stop_h]);
    }
    // cam, positioned on post at cam_bot
    translate([0, 0, cam_bot])
        cam_body(id);
}

// ── assembly ────────────────────────────────────────────────────────
new_tray();
top_tray();

for (c = corners) {
    translate([c[0], c[1], NH])
        post_assembly(c[2]);
}
