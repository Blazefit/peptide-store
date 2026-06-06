// =============================================================================
// Parts for peptide-pen-dropper.scad (SIMPLE edition): body, shutter, previews
// Included by the main file, so it can use all of its derived variables.
// =============================================================================
function pz(a, r) = axle_z + r*cos(a);     // world Z at angle a (0=up), radius r
function py(a, r) = r*sin(a);              // world Y

// ----------------------------- 2D helpers ------------------------------------
module wedge2d(a1, a2, r) {
    polygon(concat([[0,0]], [for (a=[a1:1:a2]) [r*cos(a), r*sin(a)]]));
}
top_open = 96;                            // wide top opening (drum shows + lifts out)
module shroud2d() {
    difference() {
        difference() { circle(shroud_or); circle(shroud_ir); }
        wedge2d(-top_open, top_open, shroud_or+5);              // open top
        wedge2d(180-win_ang, 180+win_ang, shroud_or+5);        // drop window
    }
}

// ----------------------------- catch tray ------------------------------------
B = tray_back_y;  F = tray_front_y;  W = wall;  Lt = tray_lip;
catch_low = F - 10;                       // pen settles here, against the lip
module tray2d() {                         // cross-section in (worldZ, worldY)
    polygon([
        [0,     -B-W],  [Lt+6, -B-W],  [Lt+6, -B],     // back wall
        [24,    -B],    [14, -B+14],   [8, -6],        // concave landing slope
        [5.5, 16],      [4, catch_low],[7.5, F-6],     // rolls to rest by the lip
        [Lt+2,  F-6],   [Lt+2, F+W],   [0, F+W]        // tall front lip + outer
    ]);
}
module cushion_fingers() {
    n = max(3, round(upright_x_in/13));
    color("#26b07e")
    for (i = [0:n-1]) {
        cx = -upright_x_in + 9 + i*(2*upright_x_in-18)/(n-1);
        translate([cx, -3, 7]) rotate([14,0,0]) cube([3.2, 1.3, 13]);
    }
}

// =============================================================================
//  SHUTTER  — one flat slide. Closed = covers the window; pull it forward to drop.
// =============================================================================
z_sh = axle_z - shroud_ir - shutter_gap - shutter_th;   // sits just below the window
sw   = 2*upright_x_in - 1;                               // full width (ends in tracks)
hw   = min(2*upright_x_in - 20, 46);                     // handle width (narrower)
win_y = shroud_ir*sin(win_ang);

module shutter(state="closed") {
    dy = (state == "open") ? shutter_travel : 0;
    color("#fbbf24") translate([0, dy, 0]) {
        translate([-sw/2, -win_y-3, z_sh]) cube([sw, 2*win_y+6, shutter_th]);   // gate
        translate([-hw/2,  win_y+3, z_sh]) cube([hw, F+8-(win_y+3), shutter_th]); // handle
        translate([-hw/2,  F+5, z_sh])     cube([hw, 4, 11]);                    // grip tab
    }
}

// =============================================================================
//  AUTO-INDEX DETENT  — leaf spring on the right upright; nub clicks into the
//  bottom dimple of the drum end-face ring (flexes into a relief pocket).
// =============================================================================
det_xf = drum_len/2;          // +X drum end face
det_xl = upright_x_in;        // right upright inner face
module detent_spring() {
    az = det_nz + 24;  bx = det_xf + 0.6;
    color("#f0a23b") {
        translate([bx, -5, az-3]) cube([det_xl - bx + 4, 10, 9]);     // anchor foot
        translate([bx, -5, det_nz-3]) cube([detent_t, 10, az-det_nz]); // leaf
        translate([bx, 0, det_nz]) sphere(r = detent_nub + 0.6);       // nub
    }
}

// =============================================================================
//  BODY  — tray + uprights + open-top bearings + shroud + shutter track (1 part)
// =============================================================================
module body() {
    color("#34d399") {
        difference() {
            union() {
                // concave catch tray (floor + front lip + back wall), between uprights
                rotate([0,-90,0]) linear_extrude(height = 2*upright_x_in, center = true)
                    tray2d();
                // two uprights (also the tray side walls)
                for (sx = [-1,1])
                    translate([sx*upright_x_in - (sx<0?upright_th:0), -B-W, 0])
                        cube([upright_th, B+F+2*W, upright_top_z]);
                // shroud trough spanning between the uprights
                translate([0,0,axle_z]) rotate([0,-90,0])
                    linear_extrude(height = 2*upright_x_in, center = true) shroud2d();
            }
            // open-top bearings (cylinder along X + slot up to the top)
            translate([0,0,axle_z]) rotate([0,90,0])
                cylinder(h = 2*body_out_x+2, r = stub_d/2 + bearing_gap, center=true);
            translate([-body_out_x-1, -(stub_d/2+bearing_gap), axle_z])
                cube([2*body_out_x+2, stub_d+2*bearing_gap, upright_top_z]);
            // shutter track grooves on the inner faces of the uprights
            for (sx = [-1,1]) {
                gx = sx*upright_x_in;
                translate([sx>0 ? gx-0.1 : gx-3+0.1, -win_y-6, z_sh-shutter_gap])
                    cube([3, F+8-(-win_y-6), shutter_th+2*shutter_gap]);
            }
            // relief pocket so the detent leaf-spring can flex into the right upright
            if (detent_on)
                translate([det_xl-0.1, -6, det_nz-6]) cube([5, 12, 32]);
            // i1: front finger scoops flanking the handle — pinch the dropped pen out
            if (finger_scoop)
                for (sx=[-1,1])
                    translate([sx*(hw/2+16), F-7, tray_lip+2]) rotate([-90,0,0])
                        cylinder(h=W+10, r=9);
        }
        if (detent_on)  detent_spring();
        if (cushion_on) cushion_fingers();
        // i4: raised arrows on the uprights pointing to the dispense (front) side
        if (sel_pointer)
            for (sx=[-1,1])
                translate([sx*upright_x, F-12, upright_top_z])
                    linear_extrude(1.6) polygon([[-5,0],[5,0],[0,9]]);
        // i5: bearing keeper bumps — snap the drum in; lift out with a firm pull
        if (bearing_keep)
            for (sx=[-1,1]) for (sy=[-1,1])
                translate([sx*upright_x, sy*(stub_d/2+bearing_gap), axle_z+3])
                    sphere(r=1.3);
    }
}

// =============================================================================
//  PREVIEW ASSEMBLIES
// =============================================================================
module assembled() {
    body();
    shutter(shutter_state);
    color("#7c5cfc") drum_in_place(0);
    if (show_pen) demo_pen();
}

module caught_pen() {
    color("#e8e8f5")
    translate([-pen_length/2, catch_low, 4 + pen_diameter/2])
        rotate([0,90,0]) cylinder(h = pen_length, r = pen_diameter/2);
}

module section() {
    difference() {
        union() {
            body(); shutter(shutter_state);
            color("#7c5cfc") drum_in_place(0);
            if (show_pen && shutter_state == "open") caught_pen();
        }
        translate([0, -250, -50]) cube([300, 500, 400]);   // keep X < 0 half
    }
}

// cutaway near the +X end to verify the auto-index detent click
module detentview() {
    intersection() {
        union() { body(); color("#7c5cfc") drum_in_place(0); }
        translate([58, -200, -200]) cube([44, 400, 400]);
    }
}

module exploded() {
    body();
    translate([0,0,46]) shutter("closed");
    color("#6a4ae0") translate([0,0,92]) drum_in_place(0);
    if (show_pen) translate([0,0,92]) demo_pen();
}
