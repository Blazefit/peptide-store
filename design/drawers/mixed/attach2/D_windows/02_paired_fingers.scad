// 02_paired_fingers.scad
// RETROFIT ATTACHMENT — Version 2: Paired Fingers per Side
//
// NEW tray (z=0..50, blue) carries TWO narrower fingers side-by-side on each
// long face, at each of the two OUTER windows (windows 0 and 2).
// A base bridge connects the pair.  Both fingers of a pair hook the SAME
// window, doubling retention force and preventing rocking.
//
// TOP tray (z=50..83, grey) FIXED — ZERO geometry added.
//
// explode=0 engaged, explode=1 lifted apart.

explode = 0;

W    = 305;   D  = 102;   Hn = 50;   Ht = 33;   wall = 3;

win_w  = 45;   win_h = 16;   win_zc = 64;
function win_cx(i) = W * (i+1) / 4;

// Paired-finger geometry
fng_t    = 2.4;   // finger thickness
fng_w    = 14;    // single finger width (X)
fng_gap  = 10;    // gap between the two fingers of a pair
pad_h    = 6;     // base bridge height below new-tray top
hook_dep = 2.2;
hook_h   = 3.5;
lead_in  = 1.0;
root_z   = pad_h;

hook_z = win_zc - win_h/2 + 2;

expl = 45 * explode;

c_new  = [0.22, 0.55, 0.85, 1.00];
c_top  = [0.80, 0.80, 0.80, 0.80];
c_clip = [0.12, 0.72, 0.30, 1.00];   // green

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

// One pair of fingers hooking window win_i on given side
module finger_pair(side, win_i) {
    cx   = win_cx(win_i);
    y0   = (side==0) ? -fng_t : D;
    inwd = (side==0) ? 1 : -1;

    // X positions of the two fingers (centred on window)
    half_span = fng_gap/2 + fng_w/2;
    xs = [cx - half_span - fng_w/2, cx + half_span - fng_w/2];

    stem_bot = Hn - root_z;
    stem_top = hook_z + hook_h + 2;

    color(c_clip) {
        // base bridge connecting both fingers
        bridge_x0 = cx - half_span - fng_w/2;
        bridge_x1 = cx + half_span + fng_w/2;
        translate([bridge_x0, y0, stem_bot])
            cube([bridge_x1 - bridge_x0, fng_t, pad_h]);

        // two fingers
        for (fx = xs) {
            // stem
            translate([fx, y0, stem_bot])
                cube([fng_w, fng_t, stem_top - stem_bot]);
            // hook
            translate([fx, y0, hook_z])
            hull() {
                cube([fng_w, fng_t + hook_dep, hook_h]);
                translate([0, inwd * (-hook_dep), hook_h - lead_in])
                    cube([fng_w, fng_t, lead_in + 0.01]);
            }
        }
    }
}

// ASSEMBLY — pairs at outer windows 0 and 2, both sides
new_tray_body();
for (wi = [0, 2]) {
    finger_pair(0, wi);
    finger_pair(1, wi);
}
top_tray();
