// 01_fullbar_living.scad
// FLIP-LEVER RIM CLAMP — Variant (a): one FULL-LENGTH flip bar on the FRONT
// (living hinge) + one end clamp at each SHORT END. NOTHING on the back/door.
//
// Hinge: living hinge (thinned 0.6mm web) at the bar root on the FRONT outer
// wall, axis horizontal along X at z=44 (6mm below new-tray top, well below rim).
// OPEN  (lock=0): bar folded DOWN-AND-OUT flat against front wall (-Y), low
//                 profile, leaves the vertical drop path clear -> top lifts up.
// LOCKED(lock=1): bar flips UP-AND-IN; cam lip reaches over the rim (z>=83)
//                 and a wall detent holds it. End clamps swing in over the rim
//                 corners.
//
// Render: -D 'lock=0' or -D 'lock=1'
include <common.scad>
C_lever = "#2E7D32";
lock = 0;
$fn = 48;

// ── front bar geometry ─────────────────────────────────────────
hinge_z   = NH - 6;        // z=44 pivot, below rim
bar_len   = 250;           // along X, centered
bar_t     = 3.0;           // bar thickness (radial)
arm_len   = rim_top_z - hinge_z + 4;   // reach from pivot up past rim = ~43
lhinge_t  = 0.6;           // living hinge web
lip_ext   = 5;             // cam lip inward reach over rim
lip_t     = 3.0;           // lip thickness (sits at/above rim top)

// Angle: bar measured about +X axis. 0 = pointing straight UP (+Z).
// open: rotate -100deg so the arm lies down/out toward -Y (front, outward).
// locked: rotate to ~+6deg so the arm leans slightly inward, lip over rim.
ang_open   = -105;
ang_locked = 6;
bar_ang = lock ? ang_locked : ang_open;

// rotate about X at pivot. Front pivot sits at y = lhinge_t (just off wall).
module front_flip_bar() {
    color(C_lever)
    translate([(NW-bar_len)/2, lhinge_t, hinge_z])
    rotate([bar_ang, 0, 0])
    union() {
        // arm shaft (grows in +Z; thickness in -Y so lip curls toward +Y inward)
        translate([0, -bar_t, 0]) cube([bar_len, bar_t, arm_len]);
        // cam lip at top, curls INWARD (+Y) over the rim
        translate([0, 0, arm_len - lip_t])
            cube([bar_len, lip_ext, lip_t]);
        // lead chamfer on lip underside
        translate([0, lip_ext, arm_len - lip_t])
            rotate([45,0,0]) translate([0,-1.2,-1.2]) cube([bar_len,1.7,1.7]);
        // detent bump (back face of arm) that snaps to wall pocket when locked
        translate([bar_len/2-6, -bar_t-0.8, arm_len*0.45])
            rotate([0,90,0]) cylinder(r=1.1, h=12);
        // finger tab projecting outward (-Y) at one end
        translate([bar_len-26, -bar_t-5, 2]) cube([22, 5, 7]);
    }
}

// living-hinge web connecting bar root to front wall (drawn at rest, vertical)
module front_hinge_web() {
    color(C_lever)
    translate([(NW-bar_len)/2, 0, hinge_z-3])
        cube([bar_len, lhinge_t, 3]);
}

// ── END CLAMP (short ends x=0 and x=305) ───────────────────────
// Pin/living-hinge lever on the END wall, axis horizontal along Y at z=44.
// Swings up-and-over the rim CORNER. side = -1 (x=0 end) or +1 (x=305 end).
end_arm_len = arm_len;
end_w       = 26;          // width along Y
module end_clamp(side) {
    // place at x=0 (side -1) or x=305 (side +1); pivot just off the end face
    xbase = side<0 ? lhinge_t : NW - lhinge_t;
    // open: fold out along the end (away in X); locked: up-and-in over corner
    eo = -105; el = 6;
    eang = lock ? el : eo;
    yoff = (ND-end_w)/2;
    color(C_lever)
    translate([xbase, yoff, hinge_z])
    // rotate about Y axis; mirror for the +X end
    rotate([0, side<0 ? -eang : eang, 0])
    union() {
        // arm grows +Z; thickness pushes outward in X then lip curls in
        sx = side<0 ? 1 : -1;
        translate([sx<0 ? -bar_t:0, 0, 0]) cube([bar_t, end_w, end_arm_len]);
        // lip curls inward over rim corner
        translate([sx<0 ? -lip_ext:0, 0, end_arm_len-lip_t])
            cube([lip_ext, end_w, lip_t]);
        // finger tab
        translate([sx<0 ? -bar_t-5:bar_t, end_w/2-3, 2]) cube([5,6,7]);
    }
}

// ── assembly ───────────────────────────────────────────────────
new_tray();
back_guide();
top_tray();
front_hinge_web();
front_flip_bar();
end_clamp(-1);
end_clamp(1);
