include <../designs/tray_lib.scad>
N=4; ANG=30; P=22; YF=14; BASE=3; CLR=0.5; ENDW=3;
color([0.30,0.50,0.90]) standtray(n=N,ang=ANG,P=P,clear=CLR,lip_h=6,back_h=11,dial=false);
for(i=[0:N-1]){
  yc=YF+i*P*cos(ANG); zc=BASE+yc*tan(ANG)+(PEN_B/2+CLR);
  LX=PEN_L+CLR+2*ENDW;
  color([0.62,0.62,0.64]) translate([LX/2,yc,zc]) rotate([0,90,0]) cylinder(h=PEN_L,r=PEN_B/2,center=true);
}
