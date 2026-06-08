// 05_c_clip.scad
// RETROFIT ATTACHMENT — Version 5: Flexible C-Clip (Over-the-Wall Clasp)
//
// NEW tray (z=0..50, blue) has C-shaped clips — one per window (3/side × 2
// sides = 6 total).  Each clip has:
//   outer leg : rises on the OUTSIDE of the top-tray long wall
//   crown     : horizontal bridge that rides over the TOP EDGE of the wall
//   inner leg : drops INSIDE the top-tray wall; a retention nub snaps into
//               the window from the INSIDE, locking the top tray DOWN.
//
// Engagement: press crown down until nub pops into window.
// Release: squeeze outer leg inward (away from tray) to un-snap.
//
// TOP tray (z=50..83, grey) FIXED — ZERO geometry added.
//
// explode=0 engaged, explode=1 lifted apart.

explode = 0;

W    = 305;   D  = 102;   Hn = 50;   Ht = 33;   wall = 3;

win_w  = 45;   win_h = 16;   win_zc = 64;
function win_cx(i) = W * (i+1) / 4;

// C-clip geometry
cc_leg_t  = 2.0;   // leg thickness (thin = spring)
cc_w      = 34;    // clip width (X), fits inside window

// outer leg: root on new tray, rises to clear top of top tray
cc_outer_h = Ht + 4;   // above new-tray top face (reaches z = Hn+Ht+4 = 87)
cc_root    = 5;         // how far below new-tray top the outer leg roots

// crown (spans top-tray wall thickness + a little slop)
cc_crown_y = wall + 2.0;   // Y span of crown

// inner leg: drops from crown to just past window UPPER edge
// window upper edge absolute Z = win_zc + win_h/2 = 72
// inner leg bottom needs to reach to lock in window
inner_drop = Ht - (win_zc - Hn - win_h/2) + 2;   // from top of top tray down to window lower edge + 2

// retention nub (inside face of inner leg, pops into window)
nub_dep   = 2.2;
nub_h     = 3.0;
nub_taper = 1.2;
// nub sits at window upper edge height
nub_z = win_zc + win_h/2 - nub_h;   // absolute Z

expl = 45 * explode;

c_new  = [0.22, 0.55, 0.85, 1.00];
c_top  = [0.80, 0.80, 0.80, 0.80];
c_clip = [0.75, 0.20, 0.90, 1.00];   // purple

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

// C-clip for window win_i on given side
// side=0 → front (y=0), side=1 → back (y=D)
module c_clip(side, win_i) {
    cx = win_cx(win_i);

    // OUTER LEG position (outside the new/top tray long wall)
    y_out = (side==0) ? -cc_leg_t : D;

    // INNER LEG position (just inside the top-tray wall)
    y_in  = (side==0) ? wall : D - wall - cc_leg_t;

    // Crown: bridges from outer to inner leg at top of outer leg
    crown_y_start = (side==0) ? y_out : y_in;
    crown_y_span  = cc_crown_y + cc_leg_t;

    outer_bot  = Hn - cc_root;
    outer_top  = Hn + cc_outer_h;           // absolute Z of crown bottom
    inner_bot  = outer_top - inner_drop;     // absolute Z of inner leg bottom

    color(c_clip) {
        // OUTER LEG
        translate([cx - cc_w/2, y_out, outer_bot])
            cube([cc_w, cc_leg_t, cc_outer_h + cc_root]);

        // CROWN (flat horizontal bridge over top edge of top-tray wall)
        cy = (side==0) ? y_out : y_out - cc_crown_y;
        translate([cx - cc_w/2, cy, outer_top])
            cube([cc_w, cc_crown_y + cc_leg_t, cc_leg_t]);

        // INNER LEG
        translate([cx - cc_w/2, y_in, inner_bot])
            cube([cc_w, cc_leg_t, outer_top - inner_bot + cc_leg_t]);

        // RETENTION NUB on inner leg inner face (snaps into window)
        inwd = (side==0) ? 1 : -1;
        translate([cx - cc_w/2, y_in, nub_z])
        hull() {
            cube([cc_w, cc_leg_t + nub_dep, nub_h]);
            translate([0, inwd*(-nub_dep), nub_h - nub_taper])
                cube([cc_w, cc_leg_t, nub_taper + 0.01]);
        }
    }
}

// ASSEMBLY — all 3 windows × 2 sides
new_tray_body();
for (i=[0:2]) {
    c_clip(0, i);
    c_clip(1, i);
}
top_tray();
