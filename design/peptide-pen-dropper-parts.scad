// =============================================================================
// Parts for peptide-pen-dropper.scad  (cradle, flap, secondary base, previews)
// Included by the main file, so it can use all of its derived variables.
// =============================================================================

// polar point in the drum cross-section -> world [y,z]   (angle a in 2D frame:
// 2D +x maps to world +Z(up), 2D +y maps to world +Y(front))
function pz(a, r) = axle_z + r*cos(a);
function py(a, r) = r*sin(a);

win_a1 = 148;  win_a2 = 212;          // bottom drop window angular span (2D)
amid   = (shroud_ir + shroud_or)/2;
hinge_a = win_a2;                      // back edge -> hinge
latch_a = win_a1;                      // front edge -> latch

shroud_len = drum_len + 0.5;
leg_top_z  = axle_z + drum_r*0.30;

// secondary base geometry
sec_inner_x  = axle_x + leg_th/2;                 // inner face of side walls
sec_wall     = 4;
sec_outer_x  = sec_inner_x + sec_wall;
tray_front_y = drum_r + 14;                        // lip is forward of the drum
tray_back_y  = drum_r + 6;
deck_z       = leg_top_z * 0.0;                    // (legs run to the table)
tongue_p = 3; tongue_w = 16; tongue_h = axle_z*0.55;

// ----------------------------- 2D helpers ------------------------------------
module wedge2d(a1, a2, r) {
    polygon(concat([[0,0]], [for (a=[a1:1:a2]) [r*cos(a), r*sin(a)]]));
}
module shroud2d() {
    difference() {
        difference() { circle(shroud_or); circle(shroud_ir); }
        wedge2d(-68, 68, shroud_or+5);             // wide top opening (drum shows;
                                                   // pens held by gravity up here)
        wedge2d(win_a1, win_a2, shroud_or+5);      // bottom drop window
    }
}

// =============================================================================
//  CRADLE  — legs + axle pins + shroud + hinge clips + button latch
// =============================================================================
module cradle() {
    color("#a78bfa") {
        shroud_body();
        leg(+1);
        leg(-1);
        hinge_clips();
        latch();
    }
}

module shroud_body() {
    translate([0,0,axle_z]) rotate([0,-90,0])
        linear_extrude(height = shroud_len, center = true) shroud2d();
}

module leg(sx) {
    x = sx*axle_x;
    union() {
        // main plate
        translate([x - leg_th/2, -(drum_r+8), 0])
            cube([leg_th, (drum_r+8) + (tray_front_y+2), leg_top_z]);
        // inward axle pin (chamfered tip)
        translate([x, 0, axle_z]) rotate([0, -sx*90, 0]) {
            cylinder(h = pin_engage + 1, r = pin_d/2);
            translate([0,0,pin_engage+1]) cylinder(h=1.4, r1=pin_d/2, r2=pin_d/2-1.4);
        }
        // outward tongue rail -> slides into the secondary base groove
        ox = x + sx*(leg_th/2 + tongue_p/2);
        translate([ox - tongue_p/2, -tongue_w/2, 0])
            cube([tongue_p, tongue_w, tongue_h]);
    }
}

// two C-clips that the flap's hinge rod snaps into (back edge of the window)
module hinge_clips() {
    hy = py(hinge_a, amid);  hz = pz(hinge_a, amid);
    for (sx = [-1, 1])
        translate([sx*(shroud_len/2 - 4), hy, hz])
            rotate([0,90,0])
                difference() {
                    cylinder(h = 4, r = 3.4, center=true);
                    cylinder(h = 5, r = 2.2, center=true);
                    translate([3.4,0,0]) cube([4,7,6], center=true);   // mouth
                }
}

// button latch: a sprung post at the front whose hook catches the flap lip.
// Modelled closed; pressing it toward -Y releases the flap (see README).
module latch() {
    ly = py(latch_a, amid);  lz = pz(latch_a, amid);
    // cantilever spring post rising from the front of the shroud
    translate([0, ly + 5, lz - 6]) {
        // spring blade
        translate([-6, 0, 0]) cube([12, 2.4, 22]);
        // button head
        translate([-9, -2, 18]) cube([18, 7, 8]);
        // hook that catches the flap front lip
        translate([-7, -3.5, -1]) cube([14, 4, 4]);
    }
}

// =============================================================================
//  FLAP  — the trapdoor that fills the bottom window and drops the pen
// =============================================================================
module flap() {
    color("#7c5cfc") {
        // window-filling arc segment
        translate([0,0,axle_z]) rotate([0,-90,0])
            linear_extrude(height = shroud_len - 2, center = true)
                difference() {
                    difference() { circle(shroud_or); circle(shroud_ir); }
                    wedge2d(-180, win_a1, shroud_or+5);
                    wedge2d(win_a2, 180,  shroud_or+5);
                }
        // hinge rod along X at the back edge (snaps into the cradle clips)
        translate([0, py(hinge_a, amid), pz(hinge_a, amid)])
            rotate([0,90,0]) cylinder(h = shroud_len + 6, r = 2.0, center=true);
        // front lip for the latch hook to grab
        translate([-7, py(latch_a, shroud_ir) - 2, pz(latch_a, shroud_ir) - 2])
            cube([14, 4, 5]);
    }
}

// =============================================================================
//  SECONDARY BASE  — receives the cradle legs, angled catch tray + front lip
// =============================================================================
module secondary() {
    color("#34d399") difference() {
        union() {
            // angled tray floor (front low -> back high)
            hull() {
                translate([-sec_inner_x, tray_front_y, tray_floor_z])
                    cube([2*sec_inner_x, 0.1, 0.1]);
                translate([-sec_inner_x, -tray_back_y,
                           tray_floor_z + (tray_front_y+tray_back_y)*tan(tray_incline)])
                    cube([2*sec_inner_x, 0.1, 0.1]);
                translate([-sec_inner_x, tray_front_y, 0])
                    cube([2*sec_inner_x, 0.1, 0.1]);
                translate([-sec_inner_x, -tray_back_y, 0])
                    cube([2*sec_inner_x, 0.1, 0.1]);
            }
            // front wall + catch lip
            translate([-sec_inner_x, tray_front_y, 0])
                cube([2*sec_inner_x, sec_wall, tray_floor_z + tray_lip]);
            // back wall
            translate([-sec_inner_x, -tray_back_y - sec_wall, 0])
                cube([2*sec_inner_x, sec_wall, tray_floor_z + tray_lip + 6]);
            // two side walls with tongue grooves
            for (sx = [-1,1])
                translate([sx*sec_inner_x - (sx<0?sec_wall:0),
                           -tray_back_y - sec_wall, 0])
                    cube([sec_wall, tray_front_y+tray_back_y+2*sec_wall, tongue_h+8]);
        }
        // grooves in the side walls to receive the leg tongues
        for (sx = [-1,1]) {
            ox = sx*(axle_x + leg_th/2 + tongue_p/2);
            translate([ox - (tongue_p+0.6)/2, -tongue_w/2 - 0.4, -1])
                cube([tongue_p+0.6, tongue_w+0.8, tongue_h+0.5]);
        }
    }
}

// =============================================================================
//  PREVIEW ASSEMBLIES
// =============================================================================
module assembled() {
    secondary();
    cradle();
    flap();
    color("#7c5cfc") drum_in_place(0);
    if (show_pen) demo_pen();
}

// vertical cross-section through the middle — shows the drop path
module section() {
    difference() {
        assembled();
        translate([0, -250, -50]) cube([300, 500, 400]);   // keep X < 0 half
    }
}

module exploded() {
    secondary();
    translate([0,0,55]) { cradle(); flap(); }
    color("#6a4ae0") translate([0,0,55]) drum_in_place(0);
    if (show_pen) translate([0,0,55]) demo_pen();
}
