// 04_corner_hook.scad
// RETROFIT ATTACHMENT — Version 4: Corner L-Hook
//
// NEW tray (z=0..50, blue) has an L-shaped hook at each of the 4 corners.
// Each L-hook has:
//   - a short horizontal arm running along the short-end face (X direction)
//   - a vertical stem that turns along the long-side face
//   - an inward hook at the top that grabs the NEAREST long-side window
//     (window 0 at X≈76 for the left corners; window 2 at X≈229 for right)
//
// Corner placement keeps clips well away from vial holes; 4 hooks share load.
//
// TOP tray (z=50..83, grey) FIXED — ZERO geometry added.
//
// explode=0 engaged, explode=1 lifted apart.

explode = 0;

W    = 305;   D  = 102;   Hn = 50;   Ht = 33;   wall = 3;

win_w  = 45;   win_h = 16;   win_zc = 64;
function win_cx(i) = W * (i+1) / 4;

// Corner hook geometry
ch_t    = 2.8;   // hook thickness
ch_yw   = 18;    // width of stem along long-side (Y-axis extent of stem)
ch_h    = 38;    // stem height above new-tray top
arm_len = 12;    // length of corner arm along short-end face
root_z  = 6;     // how deep the base roots below new-tray top
hook_dep = 2.4;
hook_h   = 4.0;
lead_in  = 1.2;

hook_z = win_zc - win_h/2 + 2;

expl = 45 * explode;

c_new  = [0.22, 0.55, 0.85, 1.00];
c_top  = [0.80, 0.80, 0.80, 0.80];
c_clip = [0.95, 0.78, 0.05, 1.00];   // yellow

module top_tray() {
    color(c_top)
    translate([0, 0, Hn + expl])
    difference() {
        cube([W, D, Ht]);
        translate([wall, wall, -0.01])
            cube([W-2*wall, D-2*wall, Ht-wall+0.01]);
        for (i=[0:2]) {
            translate([win_cx(i)-win_w/2, -0.01, (win_zc-Hn)-win_h/2])
                cube([win_w, wall+0.02, win_h]);
            translate([win_cx(i)-win_w/2, D-wall-0.01, (win_zc-Hn)-win_h/2])
                cube([win_w, wall+0.02, win_h]);
        }
    }
}

module new_tray_body() {
    color(c_new)
    difference() {
        cube([W, D, Hn]);
        translate([wall, wall, wall])
            cube([W-2*wall, D-2*wall, Hn]);
    }
}

// L-hook at one corner
// cx_side: 0=left (X=0), 1=right (X=W)
// cy_side: 0=front (Y=0), 1=back (Y=D)
module corner_hook(cx_side, cy_side) {
    win_i = (cx_side == 0) ? 0 : 2;   // nearest window
    wcx   = win_cx(win_i);             // window centre X

    y0   = (cy_side==0) ? -ch_t : D;
    inwd = (cy_side==0) ? 1 : -1;

    // Stem X extent: centred on window centre
    stem_x0 = wcx - ch_yw/2;
    stem_x1 = wcx + ch_yw/2;

    // Corner arm runs from stem_x edge to the short end wall
    arm_x0 = (cx_side==0) ? -ch_t : W;
    arm_x1 = (cx_side==0) ? stem_x0 + ch_t : stem_x1;   // connects to stem

    stem_bot = Hn - root_z;
    stem_top = hook_z + hook_h + 2;

    color(c_clip) {
        // vertical stem on long-side face
        translate([stem_x0, y0, stem_bot])
            cube([ch_yw, ch_t, stem_top - stem_bot]);

        // horizontal arm along short-end face (low section only)
        arm_len_actual = abs(arm_x1 - arm_x0);
        translate([min(arm_x0, arm_x1), y0, stem_bot])
            cube([arm_len_actual, ch_t, root_z + 8]);

        // hook nose
        translate([stem_x0, y0, hook_z])
        hull() {
            cube([ch_yw, ch_t + hook_dep, hook_h]);
            translate([0, inwd*(-hook_dep), hook_h - lead_in])
                cube([ch_yw, ch_t, lead_in + 0.01]);
        }
    }
}

// ASSEMBLY — 4 corners
new_tray_body();
corner_hook(0, 0);   // left-front
corner_hook(0, 1);   // left-back
corner_hook(1, 0);   // right-front
corner_hook(1, 1);   // right-back
top_tray();
