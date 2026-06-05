// gate_lib.scad — two-part front-removable rack: open cradle BODY + lift-off GATE
// The body is a reclined ramp with open grooves; pens pull straight out the
// front. A slim gate drops into a catch at each end and spans the front, blocking
// the pens until you lift it off. Everything is a loose/positive fit -> nothing
// tolerance-critical, no snap, no test print.
include <common.scad>

LBLK = PEN_L + 7;     // 172 body length
GTH  = 3.0;           // gate thickness
GCL  = 0.6;           // generous clearance for the gate-to-catch fit
TABW = 10;            // gate end-tab width (along X)

// ---- shared layout ---------------------------------------------------------
function _yc(n,P,phi,i) = (-(n-1)/2 + i) * P * cos(phi);
function _zc(n,P,phi,i) = (WALL + RCH) + i * P * sin(phi);
function _ymn(n,P,phi)  = _yc(n,P,phi,0)   - RCH - WALL;
function _ymx(n,P,phi)  = _yc(n,P,phi,n-1) + RCH + WALL;
function _Hb(n,P,phi)   = _zc(n,P,phi,n-1) + RCH + 10;
// up-slope length of the ramp face (gate height when printed standing)
function _faceL(n,P)    = (n-1)*P + 2*RCH + 8;

// 2D teardrop (45deg apex toward +Y) for self-supporting windows
module _td2d(r) {
    union() {
        circle(r=r);
        polygon([[0.7071*r,0.7071*r],[0,1.4142*r],[-0.7071*r,0.7071*r]]);
    }
}

// ===================== BODY (prints in this orientation) ====================
module body(n=4, phi=52, P=22.5, lip=2.0, rr=RCH+2, rlen=34) {
    cph=cos(phi); sph=sin(phi);
    yc=[for(i=[0:n-1]) _yc(n,P,phi,i)];
    zc=[for(i=[0:n-1]) _zc(n,P,phi,i)];
    ymn=_ymn(n,P,phi); ymx=_ymx(n,P,phi);
    Wb=ymx-ymn; ycen=(ymx+ymn)/2; Hb=_Hb(n,P,phi);
    relief_cx=LBLK/2-12; big=800;
    cxtab = LBLK/2 - TABW/2;     // catch sits just inside each end

    difference() {
        union() {
            // sheared wedge
            difference() {
                translate([0,ycen,Hb/2]) cube([LBLK,Wb,Hb],center=true);
                translate([0,yc[0],zc[0]+lip]) rotate([phi,0,0])
                    translate([0,0,big/2]) cube([LBLK+2,big,big],center=true);
            }
            // two end CATCHES: posts at the front-bottom corners with an
            // up-slope-open pocket the gate end-tab drops into
            for (sx=[-1,1])
                translate([sx*cxtab, ymn - GTH - GCL, 0])
                    catch_post(phi);
        }
        // open grooves (pen pulls out the front) + dial relief
        for (i=[0:n-1]) {
            translate([0,yc[i],zc[i]]) rotate([0,90,0]) cylinder(h=LBLK+2,r=RCH,center=true);
            translate([relief_cx,yc[i],zc[i]]) rotate([0,90,0]) cylinder(h=rlen,r=rr,center=true);
        }
        // pocket inside each catch (the slot the gate tab sits in)
        for (sx=[-1,1])
            translate([sx*cxtab, ymn - GTH/2, 0])
                catch_slot();
    }
}

module catch_post(phi) {
    // a small block in front of the ramp toe, tall enough to hold the gate
    translate([0,0,18/2]) cube([TABW, GTH+2, 18], center=true);
}
module catch_slot() {
    // open-topped slot the gate end-tab drops into (loose fit)
    translate([0,0,30]) cube([TABW+2*GCL, GTH+2*GCL, 60], center=true);
}

// ===================== GATE (authored STANDING for printing) ================
// Printed as a thin upright wall: X = length, Z = ramp-face height, Y = thickness
module gate(n=4, phi=52, P=22.5, rwin=6.5) {
    faceL=_faceL(n,P);
    difference() {
        union() {
            // main panel
            translate([0,0,faceL/2]) cube([LBLK, GTH, faceL], center=true);
            // two end tabs that drop into the body catches (extend below panel)
            for (sx=[-1,1])
                translate([sx*(LBLK/2 - TABW/2), 0, -7])
                    cube([TABW, GTH, 16], center=true);
        }
        // grab windows aligned to each pen's up-slope position
        for (i=[0:n-1])
            translate([0, 0, RCH + 4 + i*P])
                rotate([90,0,0]) linear_extrude(height=GTH+2, center=true) _td2d(rwin);
    }
}
