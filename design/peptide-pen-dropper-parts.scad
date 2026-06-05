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
        if (detent_on) detent_spring();
        latch_mount();
    }
    color("#8b6df0") latch_spring(latch_state);     // the springy part
}

module shroud_body() {
    translate([0,0,axle_z]) rotate([0,-90,0])
        linear_extrude(height = shroud_len, center = true) shroud2d();
}

module leg(sx) {
    x = sx*axle_x;
    difference() {
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
      // relief pocket so the detent leaf-spring can flex into the right leg
      if (detent_on && sx == 1)
          translate([det_xl - 0.1, -6, det_nz - 6]) cube([5, 12, 32]);
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

// -----------------------------------------------------------------------------
//  PRINT-IN-PLACE BUTTON LATCH
//  An external cantilever spring on the front of the shroud. Its hook blocks an
//  outward lip-tab on the flap from dropping. Push the button toward the drum to
//  flex the blade; the hook lifts clear and the trapdoor swings open. The blade,
//  hook and button print as one springy part attached only at the anchor.
// -----------------------------------------------------------------------------
function P(a, r) = [py(a, r), pz(a, r)];            // world [y, z] at angle/radius

// A hanging cantilever: anchored to the shroud front up high, hangs DOWN to a
// hook at the bottom tip. The hook's outer (+Y) face catches the inner (-Y)
// face of an outboard nub on the flap's lip, blocking the flap from swinging
// down. Pressing the button rotates the blade about its anchor, retracting the
// hook inward (-Y) until it clears the nub -> the trapdoor drops.
latch_A  = P(116, shroud_or);                       // top anchor on shroud front
lip_a    = win_a1 + 4;                              // lip-tab angle (just inside the window edge)
lip_tipr = shroud_or + 4;                           // nub radius (pokes past the shroud)
latch_T  = P(lip_a, lip_tipr);                      // blade tip / hook seat [y,z]
blade_L  = norm([latch_T[0]-latch_A[0], latch_T[1]-latch_A[1]]);
press_ang = atan(latch_throw / blade_L);            // deg the blade swings to release

// the springy part: blade + hook + button, swung about the anchor when pressed
module latch_spring(state="closed") {
    th = (state == "pressed") ? press_ang : 0;      // +X rotation retracts the tip inward
    translate([0, latch_A[0], latch_A[1]]) rotate([th,0,0])
        translate([0, -latch_A[0], -latch_A[1]]) {
            // tapered spring blade, anchor -> tip
            hull() {
                translate([-latch_b/2, latch_A[0]-latch_t, latch_A[1]-latch_t])
                    cube([latch_b, latch_t, latch_t]);
                translate([-latch_b/2, latch_T[0]-latch_t, latch_T[1]])
                    cube([latch_b, latch_t, latch_t]);
            }
            // hook tab at the tip, protruding +Y to catch the nub's inner face
            translate([-latch_b/2, latch_T[0], latch_T[1]-1])
                cube([latch_b, hook_grab+1.2, hook_grab+3]);
            // button pad (thumb pushes it inward, -Y)
            translate([-latch_b/2-3, latch_T[0]+hook_grab+1, latch_T[1]-1])
                cube([latch_b+6, 6, 12]);
        }
}

// anchor bracket that fuses the spring to the shroud (does not move)
module latch_mount() {
    translate([-latch_b/2-3, latch_A[0]-latch_t-2, latch_A[1]-latch_t-3])
        cube([latch_b+6, latch_t+6, latch_t+7]);
}

// flap's outward lip-tab + catch nub (rigid with the trapdoor)
module flap_lip() {
    p0 = P(lip_a, shroud_ir + 1);
    p1 = P(lip_a, lip_tipr + latch_t);
    hull() {
        translate([-latch_b/2, p0[0]-1.4, p0[1]-1.4]) cube([latch_b, 2.8, 2.8]);
        translate([-latch_b/2, p1[0]-1.4, p1[1]-1.4]) cube([latch_b, 2.8, 2.8]);
    }
    // catch nub: sits just +Y (outboard) of the hook, caught on its inner face
    translate([-latch_b/2, latch_T[0]+hook_grab+1, latch_T[1]-1])
        cube([latch_b, 2.4, hook_grab+3]);
}

module latch(state="closed") { latch_mount(); latch_spring(state); }

// =============================================================================
//  FLAP  — the trapdoor that fills the bottom window and drops the pen
// =============================================================================
module flap_body() {
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
    // outward lip-tab the latch hook grabs
    flap_lip();
}

module flap(state="closed") {
    h = P(hinge_a, amid);
    a = (state == "open") ? -flap_open_ang : 0;      // swing down about the hinge
    color("#7c5cfc")
        translate([0, h[0], h[1]]) rotate([a,0,0]) translate([0, -h[0], -h[1]])
            flap_body();
}

// =============================================================================
//  SECONDARY BASE  — receives the cradle legs, angled catch tray + front lip
// =============================================================================
// catch-tray cross-section in (worldZ, worldY): concave floor that lands the pen
// gently, a low rest just behind a tall front lip so it cannot bounce out, and a
// tall back wall. Drawn in the shroud convention (sketch-x -> Z, sketch-y -> Y).
B = tray_back_y;  F = tray_front_y;  W = sec_wall;  Lt = 28;
catch_low = F - 10;                                    // pen settles here, against the lip
module tray2d() {
    polygon([
        [0,      -B-W],   [Lt+6, -B-W],  [Lt+6, -B],    // back wall
        [24,     -B],     [14, -B+14],   [8, -6],       // concave landing slope
        [5.5, 16],        [4, catch_low],[7.5, F-6],    // rolls forward -> rests by lip
        [Lt+2,  F-6],     [Lt+2, F+W],   [0, F+W]       // tall front lip + outer
    ]);
}

// optional print-in-place cushion fingers in the landing zone — thin angled
// blades the pen touches first; they flex forward to soften the drop & kill bounce
module cushion_fingers() {
    n = max(3, round(sec_inner_x/13));
    color("#26b07e")
    for (i = [0:n-1]) {
        cx = -sec_inner_x + 9 + i*(2*sec_inner_x-18)/(n-1);
        translate([cx, -3, 7]) rotate([14,0,0])
            cube([3.2, 1.3, 13]);                       // springy blade, leans forward
    }
}

module secondary() {
    color("#34d399") difference() {
        union() {
            // tray body (concave floor + front lip + back wall) extruded along X
            rotate([0,-90,0]) linear_extrude(height = 2*sec_inner_x, center = true)
                tray2d();
            // two side walls
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
    if (cushion_on) cushion_fingers();
}

// -----------------------------------------------------------------------------
//  AUTO-INDEX DETENT  — leaf spring on the right leg whose rounded nub drops
//  into the bottom dimple of the drum's end-face ring. Spinning the drum makes
//  the nub ride over each ridge and click into the next chamber's dimple, so
//  every chamber self-locates at the bottom drop station. Flexes axially (X)
//  into the leg's relief pocket.
// -----------------------------------------------------------------------------
module detent_spring() {
    az = det_nz + 24;                 // anchor height on the leg
    bx = det_xf + 0.6;                // blade plane, just outside the drum end face
    color("#f0a23b") {
        // anchor foot fused into the leg
        translate([bx, -5, az-3]) cube([det_xl - bx + 4, 10, 9]);
        // leaf blade hanging down in the axial gap (thickness detent_t in X)
        translate([bx, -5, det_nz-3]) cube([detent_t, 10, az - det_nz]);
        // rounded nub poking -X into the bottom dimple
        translate([bx, 0, det_nz]) sphere(r = detent_nub + 0.6);
    }
}

// =============================================================================
//  TEST HARNESSES  — thin side-on slices for tuning the mechanisms
// =============================================================================
module latchtest() {
    color("#cfc9f5") shroud_body();
    flap(flap_state);
    color("#9a8bd8") latch_mount();
    color("#e23b3b") latch_spring(latch_state);
}

module detenttest() {
    color("#cccccc") drum_in_place(0);   // drum (dimple ring on the +X end face)
    if (detent_on) detent_spring();      // orange leaf spring + nub
    %leg(1);                             // ghost leg for context
}

// =============================================================================
//  PREVIEW ASSEMBLIES
// =============================================================================
module assembled() {
    secondary();
    cradle();
    flap(flap_state);
    color("#7c5cfc") drum_in_place(0);
    if (show_pen) demo_pen();
}

// a pen that has dropped and settled against the front lip of the catch tray
module caught_pen() {
    color("#e8e8f5")
    translate([-pen_length/2, catch_low, 4 + pen_diameter/2])
        rotate([0,90,0]) cylinder(h = pen_length, r = pen_diameter/2);
}

// vertical cross-section through the middle — shows the drop path
module section() {
    difference() {
        union() { assembled(); if (show_pen) caught_pen(); }
        translate([0, -250, -50]) cube([300, 500, 400]);   // keep X < 0 half
    }
}

module exploded() {
    secondary();
    translate([0,0,55]) { cradle(); flap(); }
    color("#6a4ae0") translate([0,0,55]) drum_in_place(0);
    if (show_pen) translate([0,0,55]) demo_pen();
}
