// standtray — STANDING pen tray (final). Sleek angled tray, 4 pens in lanes,
// front catch lip + BACK WALL (no back fall-out) + end walls, open top, finger
// scoops, flat stable base. One solid piece, prints flat support-free.
// Pen O20mm x 165mm. Footprint ~6.75 x 3.41 in, 2.6 in tall.
include <tray_lib.scad>
standtray(n=4, ang=30, P=22, clear=0.5, lip_h=6, back_h=11,
          endw=3, base=3.5, lipw=3, bw=3, yfront=14, scoop=true, dial=false, cham=1.2);
