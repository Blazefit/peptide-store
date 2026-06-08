// 02_discret_cams.scad  —  Variant 2: Discrete front cam-levers (3 positions) + end hook-clamps
//
// Mechanism: Three discrete cam-levers on the front wall (x=50, x=152.4, x=254.8),
// plus two end-wall hook-clamps. All hinge outside front/end walls.
// Open=arms hang in -Y/-X outward. Closed=arms stand +Z, cam/hook captures rail/edge.
// Back wall remains flush (nothing added beyond y=101.6).

show = "all";  // [all,new,top]
lock = 1;      // 0=open, 1=closed

include <../top_ref.scad>

// ─── Tray constants ──────────────────────────────────────────────────────────
NT_X = 304.8;  NT_Y = 101.6;  NT_Z = 50;  NT_W = 3;

RAIL_TOP = 78;   // front top rail top face
END_TOP  = 83;   // end wall top face

// ─── Cam lever params ────────────────────────────────────────────────────────
CAM_LT   = 5.0;   // cam lever thickness
H_PIN    = 1.4;
H_BOR    = 2.0;

CAM_HY   = -CAM_LT/2 - 0.5;  // hinge y: outside front face (-3.0)
CAM_HZ   = 47;
CAM_ARM  = 32;   // arm → tip z=79

// Hook at cam tip
CAM_HOOK_Y = 11;  // Y-extent of cap over rail
CAM_HOOK_T  = 3;  // cap Z thickness

// 3 cam positions along front
CAM_XS = [50, 152.4, 254.8];
CAM_W  = 16;  // cam lever width in X

// End clamp (same as variant 1 geometry)
EC_HX_L = -(CAM_LT/2 + 1.0);
EC_HX_R = NT_X + CAM_LT/2 + 1.0;
EC_HZ   = 46;
EC_ARM  = END_TOP - EC_HZ;   // 37
EC_W    = 24;
EC_HY0  = (NT_Y - EC_W) / 2;
EC_LEDGE_X = 12;
EC_LEDGE_T = 4;

// Angles
function cam_a(lk) = lk ? 0 : 90;    // 0=closed(+Z), 90=open(-Y)
function ecL_a(lk) = lk ? 0 : -90;   // left end: 0=closed, -90=open(-X)
function ecR_a(lk) = lk ? 0 :  90;   // right end: 0=closed, +90=open(+X)

// ─── New tray ─────────────────────────────────────────────────────────────────
module new_tray() {
    color("#1565C0")
    difference() {
        cube([NT_X, NT_Y, NT_Z]);
        translate([NT_W, NT_W, NT_W])
            cube([NT_X - 2*NT_W, NT_Y - 2*NT_W, NT_Z]);
    }
}

// ─── Single cam lever ─────────────────────────────────────────────────────────
module cam_lever(cx, lk) {
    color("#2E7D32")
    translate([cx - CAM_W/2, CAM_HY, CAM_HZ]) {
        // pin along X (lever width direction)
        rotate([0, 90, 0])
            cylinder(h=CAM_W, r=H_PIN, $fn=32);
        rotate([cam_a(lk), 0, 0]) {
            // arm slab
            translate([0, -CAM_LT/2, 0])
                cube([CAM_W, CAM_LT, CAM_ARM]);
            // hook cap over front rail
            translate([0, -CAM_LT/2, CAM_ARM])
                cube([CAM_W, CAM_LT + CAM_HOOK_Y, CAM_HOOK_T]);
            // finger tab (outward -Y side of arm)
            translate([CAM_W*0.1, -CAM_LT/2 - 7, CAM_ARM * 0.35])
                cube([CAM_W*0.8, 7, 9]);
        }
    }
}

// Hinge boss for one cam lever (ring on front wall)
module cam_boss(cx) {
    color("#1565C0")
    translate([cx - CAM_W/2 - 3, CAM_HY, CAM_HZ])
    rotate([0, 90, 0])
        difference() {
            cylinder(h=3, r=H_BOR + 1.8, $fn=32);
            cylinder(h=3, r=H_BOR, $fn=32);
        }
    translate([cx + CAM_W/2, CAM_HY, CAM_HZ])
    rotate([0, 90, 0])
        difference() {
            cylinder(h=3, r=H_BOR + 1.8, $fn=32);
            cylinder(h=3, r=H_BOR, $fn=32);
        }
}

// All 3 cam levers
module all_cams(lk) {
    for (cx = CAM_XS)
        cam_lever(cx, lk);
}
module all_cam_bosses() {
    for (cx = CAM_XS)
        cam_boss(cx);
}

// ─── End clamps (identical to variant 1) ─────────────────────────────────────
module end_clamp_left(lk) {
    color("#EF6C00")
    translate([EC_HX_L, EC_HY0, EC_HZ]) {
        rotate([90, 0, 0])
        translate([0, 0, -EC_W/2])
            cylinder(h=EC_W, r=H_PIN, $fn=32);
        rotate([0, ecL_a(lk), 0]) {
            translate([-CAM_LT/2, 0, 0])
                cube([CAM_LT, EC_W, EC_ARM]);
            translate([-CAM_LT/2, 0, EC_ARM])
                cube([CAM_LT/2 + EC_LEDGE_X, EC_W, EC_LEDGE_T]);
            translate([-CAM_LT/2 - 2, EC_W*0.3, EC_ARM * 0.4])
                cube([CAM_LT + 4, EC_W * 0.4, 9]);
        }
    }
}
module end_clamp_right(lk) {
    color("#EF6C00")
    translate([EC_HX_R, EC_HY0, EC_HZ]) {
        rotate([90, 0, 0])
        translate([0, 0, -EC_W/2])
            cylinder(h=EC_W, r=H_PIN, $fn=32);
        rotate([0, ecR_a(lk), 0]) {
            translate([-CAM_LT/2, 0, 0])
                cube([CAM_LT, EC_W, EC_ARM]);
            translate([-(CAM_LT/2 + EC_LEDGE_X), 0, EC_ARM])
                cube([CAM_LT/2 + EC_LEDGE_X, EC_W, EC_LEDGE_T]);
            translate([-CAM_LT/2 - 2, EC_W*0.3, EC_ARM * 0.4])
                cube([CAM_LT + 4, EC_W * 0.4, 9]);
        }
    }
}

module end_hinge_bosses() {
    color("#1565C0")
    for (ey = [EC_HY0 - 4, EC_HY0 + EC_W]) {
        translate([EC_HX_L, ey, EC_HZ])
        rotate([90, 0, 0])
        translate([0, 0, -4])
            difference() {
                cylinder(h=4, r=H_BOR + 1.8, $fn=32);
                cylinder(h=4, r=H_BOR, $fn=32);
            }
        translate([EC_HX_R, ey, EC_HZ])
        rotate([90, 0, 0])
        translate([0, 0, -4])
            difference() {
                cylinder(h=4, r=H_BOR + 1.8, $fn=32);
                cylinder(h=4, r=H_BOR, $fn=32);
            }
    }
}

// ─── Assembly ─────────────────────────────────────────────────────────────────
module new_assembly(lk=1) {
    new_tray();
    all_cam_bosses();
    end_hinge_bosses();
    all_cams(lk);
    end_clamp_left(lk);
    end_clamp_right(lk);
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
