// =============================================================================
// Mixed peptide drawer cabinet — front access, engineered slide  (iter pass)
// Two columns, each with vial / pen / supply drawers that slide OUT THE FRONT
// on a rib-in-groove runner. Real dims: vials Ø22×52, pens Ø19×150.
// Modes: closed | open | exploded | section | vialdetail | pendetail
// =============================================================================
mode = "open";

/* envelope */
W=375; D=372; H=136;          // ~14.8 x 14.6 x 5.35 in  (taller vial bay)
ow=4;                          // outer wall
cw=6;                          // centre divider
shelf=4;                       // shelf / floor / top thickness
backw=4;                       // back wall

/* contents (from the other projects) */
vial_d=22; vial_h=52; vial_clr=1.6;          // 10 mL vial -> hole Ø23.6
v3_d=17;  v3_h=40;                            // 3 mL vial  -> hole Ø18.6
vial_split=0.68;                             // front fraction of the drawer for 3 mL
pen_d=19; pen_len=150; pen_clr=1.6;          // -> cradle Ø20.6, lane >=156

/* drawer slide */
run_clr=0.5;                  // body-to-wall side gap
gdep=3; ghei=5;               // groove (in frame wall): depth(X) x height(Z)
rwid=2.4; rhei=4;             // rail (on drawer): width(X) x height(Z)
dfloor=4; dwall=3;            // drawer floor / wall thickness
dh_clr=2;                     // drawer top-to-shelf clearance

/* preview */
open_ext=170;                 // how far an opened drawer slides forward
$fn=40;

vial_grip=17;                 // ring height gripping the vial base (anti-tip)
ring_wall=2;                  // vial ring wall (open rack -> saves plastic vs solid block)
cup=2;                        // bottom indent that seats the vial base

// bays bottom->top  [interior height, type]
bays=[[60,"vial"],[30,"pen"],[30,"supply"]];   // vial bay raised to fit taller collar
function zb(i)= i<=0 ? shelf : zb(i-1)+bays[i-1][0]+shelf;
ntot = H;                     // (echo check)
colw=(W-2*ow-cw)/2;
function colL(c)= ow + c*(colw+cw);   // left inner face of column c (0,1)
function colR(c)= colL(c)+colw;

// ---------------------------------------------------------------- FRAME
module frame(){
  color("#9aa3b2") difference(){
    cube([W,D,H]);
    // hollow each column/bay from the front
    for(c=[0,1]) for(i=[0:len(bays)-1])
      translate([colL(c),-1,zb(i)]) cube([colw, D-backw+1, bays[i][0]]);
    // slide grooves on both side faces of each column bay
    for(c=[0,1]) for(i=[0:len(bays)-1]){
      gz=zb(i)+ (bays[i][0]-ghei)/2;
      // left face groove (cut into the wall to -X)
      translate([colL(c)-gdep, 6, gz]) cube([gdep+0.1, D-backw-6, ghei]);
      // right face groove (cut into wall to +X)
      translate([colR(c)-0.1, 6, gz]) cube([gdep+0.1, D-backw-6, ghei]);
    }
    // fridge condensation drain holes through the bottom of each bay
    for(c=[0,1]) for(i=[0:len(bays)-1]) for(jx=[0:3]) for(jy=[0:5])
      translate([colL(c)+25+jx*42, 40+jy*52, -1]) cylinder(h=shelf+2, d=5);
    // back vent
    translate([W/2-120, D-backw-0.1, 16]) cube([240, backw+1, H-34]);
  }
  // front anti-pull-out stops (small lip at the front top of each groove)
  color("#9aa3b2") for(c=[0,1]) for(i=[0:len(bays)-1]){
    gz=zb(i)+(bays[i][0]-ghei)/2;
    for(fx=[colL(c)-gdep, colR(c)+gdep-2])
      translate([fx,4,gz+ghei-1.6]) cube([2,3,1.6]);
  }
}

// ---------------------------------------------------------------- DRAWER
module drawer(c,i,ext){
  type=bays[i][1];
  h=bays[i][0]; dz=zb(i);
  bw=colw-2*run_clr;                 // drawer body width
  bd=D-backw-8;                      // drawer depth
  bh=h-dh_clr;                       // drawer height
  col = type=="vial"?"#7c9cf0": type=="pen"?"#f0a23b":"#34d399";
  translate([colL(c)+run_clr, -ext, dz]) color(col){
    difference(){
      union(){
        // open-top box
        difference(){ cube([bw,bd,bh]);
          translate([dwall,dwall,dfloor]) cube([bw-2*dwall,bd-2*dwall,bh]); }
        // front face + finger pull
        cube([bw, 4, bh+ (type=="vial"?14: 8)]);
        translate([bw/2-45,-9, bh*0.4]) cube([90,9,16]);
        // side rails that ride in the grooves
        rz=(bh-rhei)/2 + 1;
        for(s=[-1,1]) translate([s>0?bw:-rwid, 6, rz]) cube([rwid, bd-12, rhei]);
        // rail back-bump = the anti-pull-out catch
        for(s=[-1,1]) translate([s>0?bw:-rwid, bd-12, rz]) cube([rwid,4,rhei+1.4]);
      }
      // finger relief notch in the front face (lift contents)
      translate([bw/2,-2, bh+4]) rotate([-90,0,0]) cylinder(h=8,r=9);
      // recessed label patch on the drawer front
      translate([bw/2-32,-0.1,5]) cube([64,1.2,11]);
      // drain holes through the floor (fridge condensation can't pool)
      for(jx=[0:3]) for(jy=[0:5])
        translate([dwall+18+jx*(bw-2*dwall-36)/3, dwall+18+jy*(bd-2*dwall-36)/5, -1])
          cylinder(h=dfloor+2,d=4);
    }
    if(type=="vial")   vial_tray(bw,bd,bh);
    if(type=="pen")    pen_tray(bw,bd,bh);
    if(type=="supply") supply_tray(bw,bd,bh);
  }
}

top_th=5;                          // top plate thickness
bot_th=8;                          // bottom plate (thicker, holds the indent)
indent_d=5;                        // base indent depth
topz_v=dfloor+24;                  // single top plate height (grips both vial sizes)

// drill one zone's holes (top through-hole + chamfer + base indent + drain)
module vzone(bore, x0,y0,x1,y1){
  p=bore+4; nx=floor((x1-x0-2)/p); ny=floor((y1-y0-2)/p);
  ox=x0+(x1-x0-(nx-1)*p)/2; oy=y0+(y1-y0-(ny-1)*p)/2;
  for(ix=[0:nx-1])for(iy=[0:ny-1]) translate([ox+ix*p,oy+iy*p,0]){
    translate([0,0,topz_v-1]) cylinder(h=top_th+2,d=bore);
    translate([0,0,topz_v+top_th-1.4]) cylinder(h=2.6,d1=bore,d2=bore+4);
    translate([0,0,dfloor+bot_th-indent_d]) cylinder(h=indent_d+0.1,d=bore);
    translate([0,0,-1]) cylinder(h=dfloor+bot_th,d=4);
  }
  echo(str("  ",(bore<20?"3 mL":"10 mL")," zone -> ",nx,"x",ny,"=",nx*ny));
}

module vial_tray(bw,bd,bh){
  // TWO PLATES bonded to all 4 walls, with TWO zones: front = 3 mL, back = 10 mL
  ysplit = dwall + (bd-2*dwall)*vial_split;
  color("#6f8fe6") difference(){
    union(){
      translate([dwall,dwall,dfloor]) cube([bw-2*dwall, bd-2*dwall, bot_th]);   // bottom plate
      translate([dwall,dwall,topz_v]) cube([bw-2*dwall, bd-2*dwall, top_th]);   // top plate
    }
    vzone(v3_d+vial_clr,   dwall, dwall,  bw-dwall, ysplit);     // 3 mL field (front)
    vzone(vial_d+vial_clr, dwall, ysplit, bw-dwall, bd-dwall);   // 10 mL field (back)
  }
}
module pen_tray(bw,bd,bh){
  // pens lie ACROSS the width (broadside to you) -> lanes run left-right, stacked front-to-back
  r=(pen_d+pen_clr)/2; p=pen_d+pen_clr+4;   // front-back pitch ~24.6
  n=floor((bd-2*dwall-2)/p);
  oy=dwall+(bd-2*dwall-(n-1)*p)/2;
  laneL=pen_len+6;                          // cradle length along X (fits a 150 mm pen)
  ox=dwall+(bw-2*dwall-laneL)/2;
  color("#e0922f") for(k=[0:n-1]){
    ly=oy+k*p;
    difference(){
      translate([ox-2, ly-p/2+2, dfloor]) cube([laneL+4, p-4, r+5]);     // cradle block
      translate([ox, ly, dfloor+r+2]) rotate([0,90,0]) cylinder(h=laneL, r=r); // pen channel along X
      translate([ox+laneL/2-9, ly-p, dfloor+r-2]) cube([18,2*p,r+8]);    // center finger-dip (lift pen)
    }
    // end stops so a pen can't slide out the sides
    translate([ox-2, ly-r, dfloor]) cube([2.5,2*r,r+3]);
    translate([ox+laneL-0.5, ly-r, dfloor]) cube([2.5,2*r,r+3]);
  }
  echo(str("pen drawer: ",n," pens lie BROADSIDE (",pen_len,"mm across width ",bw,"mm)"));
}
module supply_tray(bw,bd,bh){
  color("#2bb98a"){
    for(k=[1:2]) translate([dwall+k*(bw-2*dwall)/3-1,dwall,dfloor]) cube([2,bd-2*dwall,bh-dfloor]);
    translate([dwall,dwall+(bd-2*dwall)/2-1,dfloor]) cube([bw-2*dwall,2,bh-dfloor]);
  }
}

// ---------------------------------------------------------------- assembly
module cabinet(exts){
  frame();
  for(c=[0,1]) for(i=[0:len(bays)-1]) drawer(c,i,exts[c][i]);
}
closed=[[6,6,6],[6,6,6]];
opened=[[open_ext,40,40],[40,110,open_ext]];   // a few pulled to show interiors

if(mode=="closed")    cabinet(closed);
else if(mode=="open") cabinet(opened);
else if(mode=="exploded") cabinet([[open_ext,open_ext,open_ext],[open_ext,open_ext,open_ext]]);
else if(mode=="section"){
  // horizontal slice at the vial-bay rail height -> shows rib-in-groove in plan
  gz=zb(0)+(bays[0][0]-ghei)/2;
  intersection(){ cabinet([[60,6,6],[6,6,6]]); translate([-10,-260,gz+1]) cube([W+20,640,3]); }
}
else if(mode=="vialsection"){   // vertical slice through a row of vial holders
  intersection(){ translate([-colL(0)-colw/2,0,-zb(0)]) drawer(0,0,0);
                  translate([-300,140,-10]) cube([600,3,130]); }
}
else if(mode=="vialxray"){       // ghost walls, solid holders
  translate([-colL(0)-colw/2,0,-zb(0)]){ %drawer(0,0,0); }
}
else if(mode=="pendetail")  translate([-colL(0)-colw/2,0,-zb(1)]) drawer(0,1,0);
else if(mode=="vialdetail") translate([-colL(0)-colw/2,0,-zb(0)]) drawer(0,0,0);
else cabinet(opened);

echo(str("outer ",W,"x",D,"x",H,"  top of stack=", zb(len(bays))));
