// 03_side_flap.scad
// RETROFIT ATTACHMENT — Version 3: Full-Height Side Flap with 3 Hooks
//
// NEW tray (z=0..50, blue) carries a thin full-length FLAP on each long side.
// The flap rises from the bottom of the new tray to just above the top-tray
// mid-point, carrying THREE hooks — one per window — that all snap inward
// simultaneously.  The flap is thin (1.8 mm) so it acts as a leaf spring:
// pressing outward at the middle releases all 3 hooks at once.
//
// TOP tray (z=50..83, grey) FIXED — ZERO geometry added.
//
// explode=0 engaged, explode=1 lifted apart.

explode = 0;

W    = 305;   D  = 102;   Hn = 50;   Ht = 33;   wall = 3;

win_w  = 45;   win_h = 16;   win_zc = 64;
function win_cx(i) = W * (i+1) / 4;

// Flap geometry
flap_t   = 1.8;    // flap thickness — thin for spring flex
flap_len = 288;    // flap length (X), centred, leaves 8.5 mm gap each end
flap_h   = Hn + Ht - 6;   // flap reaches z=77 (6 mm below top tray top)
hook_dep = 2.6;
hook_h   = 4.0;
hook_w   = 36;     // hook width (X) inside window
lead_in  = 1.5;
// hooks positioned at each window centre height
hook_zc  = win_zc;   // hook centred on window centre

expl = 45 * explode;

c_new  = [0.22, 0.55, 0.85, 1.00];
c_top  = [0.80, 0.80, 0.80, 0.80];
c_clip = [0.85, 0.18, 0.50, 1.00];   // magenta/pink

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

// Full-length flap with 3 hooks on one long side
module side_flap(side) {
    y0   = (side==0) ? -flap_t : D;
    inwd = (side==0) ? 1 : -1;
    x0   = (W - flap_len) / 2;

    color(c_clip) {
        // flap panel — from z=0 to z=flap_h
        translate([x0, y0, 0])
            cube([flap_len, flap_t, flap_h]);

        // 3 hooks, one per window
        for (i=[0:2]) {
            cx    = win_cx(i);
            hz    = hook_zc - hook_h/2;   // hook block bottom (absolute Z)
            translate([cx - hook_w/2, y0, hz])
            hull() {
                cube([hook_w, flap_t + hook_dep, hook_h]);
                translate([0, inwd*(-hook_dep), hook_h - lead_in])
                    cube([hook_w, flap_t, lead_in + 0.01]);
            }
        }
    }
}

// ASSEMBLY
new_tray_body();
side_flap(0);
side_flap(1);
top_tray();
