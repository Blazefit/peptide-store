// spine_final.scad — FINALIZED "lift-&-click" spine lock (design #2)
// Correct kinematics: end hooks ride UP the OUTSIDE of the top-tray end walls
// (clear of them) and cam/snap INWARD over the wall tops only at the very top of
// the lift. One rigid U-carriage (front handle + 2 side rails + 2 end hooks).
// Purely ADDITIVE guide rails on the tray FRONT + END exterior faces (no cuts →
// existing groove untouched). Back (fridge-door) side stays flush.
//
// show = all | new | top | carriage | guides | tray
// pose = 0 (stowed/unlocked) .. 1 (locked).

show = "all";
pose = 1;
lock = pose;
tray_src = "box";   // "box" = parametric test tray; "stl" = real layer (best/layer_real.stl)

include <../top_ref.scad>
$fn = 40;

NTX=304.8; NTY=101.6; NTZ=50; WALL=3;
ENDTOP=83; GAP=0.6; TRAVEL=44;
BAR_T=3.2; BARH=12; BASE_Z=18;     // U-rail cross-section + stow base z
STEM_T=3.0; STEM_W=70; HOOK_Y0=16;
NOSE_IN=5; NOSE_H=6;
NOSE_BOT_STOW=39.5;                // +TRAVEL = 83.5 locked (0.5mm over the z=83 wall top)
GY0=8; GY1=90; GUIDE_Z0=15; GUIDE_Z1=78;

zoff = pose*TRAVEL;
flex = pose>0.95 ? (pose-0.95)/0.05 : 0;       // cam-in only in the last 5% of travel
nose_r = -GAP + flex*(NOSE_IN+GAP);            // nose inner edge x: out(-GAP) -> in(+NOSE_IN)

function railx(side) = side==0 ? -(GAP+BAR_T) : NTX+GAP;   // U side-rail / stem outer face
function noser(side) = side==0 ? nose_r : NTX-nose_r;

C_NEW="#1565C0"; C_GD="#F9A825"; C_CAR="#D84315";

// ---- TRAY: parametric box for testing, or the REAL layer STL (additive only) ----
module tray() {
    color(C_NEW)
    if (tray_src=="stl") import("layer_real.stl");
    else difference(){
        cube([NTX,NTY,NTZ]);
        translate([WALL,WALL,WALL]) cube([NTX-2*WALL,NTY-2*WALL,NTZ]);
    }
}

// ---- ADDITIVE GUIDES (fixed, all hardware kept clear of the wall: |x| ≥ GAP) ----
module end_guide(side){
    rx = railx(side);                 // rail outer face (left: -3.8)
    inner = side==0 ? -GAP : NTX+GAP; // closest the guide may come to the end face
    // two ribs straddling the rail in Y (slide track) — span only the rail zone
    color(C_GD){
        x0 = side==0 ? rx-1.0 : inner;          // keep within x<0 (or x>NTX)
        w  = (BAR_T+1.0);
        for(y=[GY0,GY1]) translate([x0, y-1.5, GUIDE_Z0]) cube([w, 3, GUIDE_Z1-GUIDE_Z0]);
        // outer retaining lip (overhangs rail outer face, captures it in X)
        lipx = side==0 ? rx-1.4 : rx+BAR_T+0.4;
        translate([lipx, GY0, GUIDE_Z0]) cube([1.0, GY1-GY0, GUIDE_Z1-GUIDE_Z0]);
        // bottom stop
        translate([x0, GY0, GUIDE_Z0]) cube([w, GY1-GY0, 2]);
        // detent nub near locked height (rail bump clicks past)
        translate([x0, (GY0+GY1)/2-6, GUIDE_Z0+TRAVEL]) cube([w,12,1.4]);
    }
}
module front_guide(){
    by=-(GAP+BAR_T);
    color(C_GD) for(x=[6,NTX-9]) translate([x,by-1.0,GUIDE_Z0]) cube([3,BAR_T+1.0,GUIDE_Z1-GUIDE_Z0-22]);
}
module guides(){ end_guide(0); end_guide(1); front_guide(); }

// ---- CARRIAGE (one rigid body; all joints overlap ≥1mm) ----
module hook(side){
    sx = railx(side);
    nr = noser(side);
    // stem (thin cantilever)
    translate([sx, HOOK_Y0, BASE_Z+BARH-0.1])
        cube([STEM_T, STEM_W, NOSE_BOT_STOW-(BASE_Z+BARH)+0.1]);
    // nose: from stem outer face inward to nose_r
    nx0 = min(sx, side==0?nr:sx);
    lo = side==0 ? sx : min(sx, nr);
    hi = side==0 ? max(sx+STEM_T, nr) : sx+STEM_T;
    translate([lo, HOOK_Y0, NOSE_BOT_STOW]) cube([hi-lo, STEM_W, NOSE_H]);
}
module carriage(){
    translate([0,0,zoff]) color(C_CAR){
        // front bar
        translate([2,-(GAP+BAR_T),BASE_Z]) cube([NTX-4,BAR_T,BARH]);
        // side rails (start in front-corner zone for overlap with joiner)
        translate([railx(0),-4,BASE_Z]) cube([BAR_T,95,BARH]);
        translate([railx(1),-4,BASE_Z]) cube([BAR_T,95,BARH]);
        // front corner joiners — stay entirely in the EXTERIOR corner (y<0) so they
        // never enter the top-tray footprint; bridge side rail <-> front bar in X.
        translate([railx(0)-0.1,-(GAP+BAR_T)-0.1,BASE_Z]) cube([BAR_T+0.1+3, BAR_T+GAP+0.1-0.4, BARH]);
        translate([NTX-3, -(GAP+BAR_T)-0.1,BASE_Z])       cube([railx(1)+BAR_T-(NTX-3)+0.1, BAR_T+GAP+0.1-0.4, BARH]);
        // stem bases (bridge rail -> hook), overlap into rail
        for(side=[0,1]) translate([railx(side),HOOK_Y0,BASE_Z]) cube([STEM_T,STEM_W,BARH+0.2]);
        // hooks
        hook(0); hook(1);
        // handle grip on front bar (with integral grip ridges on its own front face)
        translate([NTX/2-35,-(GAP+BAR_T)-6,BASE_Z]) cube([70,6.1,BARH]);
        for(rx=[-30:15:30]) translate([NTX/2+rx-1.5,-(GAP+BAR_T)-7.5,BASE_Z+1]) cube([3,2.1,BARH-2]);
        // detent bumps on side rails (click past the guide nub)
        for(side=[0,1]){ ox = side==0 ? railx(0)-0.5 : railx(1)+BAR_T-0.5;
            translate([ox,(GY0+GY1)/2-5,BASE_Z+BARH-0.1]) cube([0.6,10,2]); }
    }
}

if (show=="new")           { tray(); guides(); carriage(); }
else if (show=="carriage")   carriage();
else if (show=="guides")     guides();
else if (show=="tray")       tray();
else if (show=="lock_layer"){ tray(); guides(); }   // the printable layer-with-lock
else if (show=="top")        top_ref(50);
else { tray(); guides(); carriage(); top_ref(50); }
