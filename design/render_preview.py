#!/usr/bin/env python3
"""Render a dimensioned preview (FRONT / SIDE / 3-D) of the pen holder.
Numbers here mirror the defaults in peptide-pen-holder.scad."""
import math, cairosvg

# ---- parameters (keep in sync with the .scad defaults) ----------------------
pen_d, pen_len   = 19, 150
num_lanes        = 5
incline_deg      = 8
clearance, wall  = 2.5, 2.6
floor_thick      = 3.0
divider_rise     = 17
lip_thick        = 4
back_runout      = 14

lane_w   = pen_d + clearance
cradle_r = lane_w / 2
lane_len = pen_len + lip_thick + back_runout
rise     = lane_len * math.tan(math.radians(incline_deg))
axis_z   = floor_thick + cradle_r
top_front = floor_thick + cradle_r + divider_rise
top_back  = top_front + rise
lip_top   = axis_z + cradle_r * 0.45
total_w   = wall * (num_lanes + 1) + num_lanes * lane_w
lane_x = lambda i: wall + lane_w/2 + i * (lane_w + wall)

# ---- style ------------------------------------------------------------------
BG="#0f0f13"; INK="#e2e2f0"; SUB="#9393b0"; ACC="#7c5cfc"; ACC2="#a78bfa"
GREEN="#34d399"; RED="#f87171"; PART="#23233a"; PARTL="#2e2e4a"; PEN="#a78bfa"
S=2.5            # px per mm
W,H=1200,980
out=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
     f'viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">']
def add(s): out.append(s)
add(f'<rect width="{W}" height="{H}" fill="{BG}"/>')

def txt(x,y,s,fill=INK,size=15,anchor="start",weight="400",italic=False):
    st="italic" if italic else "normal"
    add(f'<text x="{x:.1f}" y="{y:.1f}" fill="{fill}" font-size="{size}" '
        f'font-weight="{weight}" font-style="{st}" text-anchor="{anchor}">{s}</text>')
def line(x1,y1,x2,y2,stroke=SUB,w=1,dash=None):
    d=f' stroke-dasharray="{dash}"' if dash else ''
    add(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
        f'stroke="{stroke}" stroke-width="{w}"{d}/>')

# arrow dimension line
def dim(x1,y1,x2,y2,label,off=0,fill=SUB):
    line(x1,y1,x2,y2,fill,1)
    for (px,py,ang) in ((x1,y1,math.atan2(y2-y1,x2-x1)),
                        (x2,y2,math.atan2(y1-y2,x1-x2))):
        for da in (0.4,-0.4):
            add(f'<line x1="{px:.1f}" y1="{py:.1f}" '
                f'x2="{px-8*math.cos(ang+da):.1f}" y2="{py-8*math.sin(ang+da):.1f}" '
                f'stroke="{fill}" stroke-width="1"/>')
    mx,my=(x1+x2)/2,(y1+y2)/2
    txt(mx,my-6+off,label,fill,12,"middle")

add(f'<text x="{W/2}" y="38" fill="{INK}" font-size="26" font-weight="700" '
    f'text-anchor="middle">Peptide Injector-Pen Holder</text>')
txt(W/2,60,f"{num_lanes}-lane gravity-feed rack · injector pens "
           f"Ø{pen_d}×{pen_len} mm · {incline_deg}° self-feed incline",
    SUB,14,"middle")
txt(W/2,80,f"overall  {total_w:.0f} (W) × {lane_len:.0f} (L) × {top_back:.0f} (H) mm  "
           f"· 3-D printable, prints flat",ACC2,13,"middle")

# =============================== FRONT VIEW ==================================
# origin: bottom-left of the front face
fx, fy = 70, 430
def FX(x): return fx + x*S
def FY(z): return fy - z*S
txt(fx, fy+46, "FRONT  (low end — where pens rest against the lip)", ACC, 15, weight="600")

# body silhouette
add(f'<rect x="{FX(0):.1f}" y="{FY(top_front):.1f}" width="{total_w*S:.1f}" '
    f'height="{top_front*S:.1f}" rx="4" fill="{PART}" stroke="{PARTL}" stroke-width="1.5"/>')
# lanes (rounded-bottom slots) + pens
for i in range(num_lanes):
    cx=lane_x(i)
    x0,x1=FX(cx-cradle_r),FX(cx+cradle_r)
    yb=FY(floor_thick); yt=FY(top_front)
    r=cradle_r*S
    add(f'<path d="M {x0:.1f} {yt:.1f} L {x0:.1f} {yb-r:.1f} '
        f'A {r:.1f} {r:.1f} 0 0 0 {x1:.1f} {yb-r:.1f} L {x1:.1f} {yt:.1f} Z" '
        f'fill="{BG}" stroke="{PARTL}" stroke-width="1"/>')
    add(f'<circle cx="{FX(cx):.1f}" cy="{FY(axis_z):.1f}" r="{pen_d/2*S:.1f}" '
        f'fill="{PEN}" fill-opacity="0.85" stroke="{ACC}" stroke-width="1.2"/>')
# lip bar across the front
add(f'<rect x="{FX(0):.1f}" y="{FY(lip_top):.1f}" width="{total_w*S:.1f}" '
    f'height="{lip_top*S:.1f}" fill="{ACC}" fill-opacity="0.18" '
    f'stroke="{ACC2}" stroke-width="1" stroke-dasharray="4 3"/>')
txt(FX(total_w)+10, FY(lip_top/2)+4, "lip", ACC2, 12)
# dims
dim(FX(0), fy+18, FX(total_w), fy+18, f"{total_w:.0f} mm")
dim(FX(lane_x(0)-cradle_r), FY(top_front)-14, FX(lane_x(0)+cradle_r),
    FY(top_front)-14, f"Ø{lane_w:.0f}")
txt(FX(lane_x(num_lanes-1)), FY(top_front)-26, "lane (pen + clearance)", SUB,11,"middle")

# =============================== SIDE VIEW ===================================
sx, sy = 690, 430
def SXc(y): return sx + y*S
def SY(z):  return sy - z*S
txt(sx, sy+46, "SIDE  (laid flat — internal ramp feeds pens forward)", ACC, 15, weight="600")
# wedge outline: front(0) low -> back(lane_len) high, flat bottom
pts=[(SXc(0),SY(0)),(SXc(lane_len),SY(0)),
     (SXc(lane_len),SY(top_back)),(SXc(0),SY(top_front))]
add('<polygon points="'+" ".join(f"{p[0]:.1f},{p[1]:.1f}" for p in pts)+
    f'" fill="{PART}" stroke="{PARTL}" stroke-width="1.5"/>')
# inclined lane floor
line(SXc(lip_thick),SY(floor_thick),SXc(lane_len),SY(floor_thick+rise),GREEN,2)
txt(SXc(lane_len*0.55),SY(floor_thick+rise*0.55)-8,"inclined floor",GREEN,12,"middle",italic=True)
# pen resting against lip (front)
add(f'<circle cx="{SXc(lip_thick+pen_d/2):.1f}" cy="{SY(axis_z):.1f}" '
    f'r="{pen_d/2*S:.1f}" fill="{PEN}" fill-opacity="0.85" stroke="{ACC}" stroke-width="1.2"/>')
# a couple of pens queued up the ramp (faint)
for k in (1,2):
    yc=lip_thick+pen_d/2+k*(pen_d+1.5)
    zc=floor_thick+ (yc)*math.tan(math.radians(incline_deg)) + cradle_r
    add(f'<circle cx="{SXc(yc):.1f}" cy="{SY(zc):.1f}" r="{pen_d/2*S:.1f}" '
        f'fill="{PEN}" fill-opacity="0.30" stroke="{ACC}" stroke-opacity="0.5" stroke-width="1"/>')
# lip at front
add(f'<rect x="{SXc(0):.1f}" y="{SY(lip_top):.1f}" width="{lip_thick*S:.1f}" '
    f'height="{lip_top*S:.1f}" fill="{ACC}" fill-opacity="0.30" stroke="{ACC2}" stroke-width="1"/>')
# labels / arrows
txt(SXc(0)-8, SY(lip_top)-6, "lip catches pen", RED,12,"end")
line(SXc(0)-6,SY(lip_top)-2,SXc(lip_thick/2),SY(lip_top/2),RED,1)
txt(SXc(lane_len), SY(top_back)-10, "OPEN — load here", GREEN,12,"end")
line(SXc(lane_len)-2,SY(top_back)-6,SXc(lane_len)-2,SY(top_back*0.78),GREEN,1)
# incline angle arc
ax,ay=SXc(lip_thick),SY(floor_thick)
add(f'<path d="M {ax+38:.1f} {ay:.1f} A 38 38 0 0 0 '
    f'{ax+38*math.cos(math.radians(incline_deg)):.1f} '
    f'{ay-38*math.sin(math.radians(incline_deg)):.1f}" '
    f'fill="none" stroke="{SUB}" stroke-width="1"/>')
txt(ax+46, ay-8, f"{incline_deg}°", SUB,12)
dim(SXc(0), sy+18, SXc(lane_len), sy+18, f"{lane_len:.0f} mm")

# ============================= 3-D (isometric) ==============================
ox, oy = 360, 900
iso_s = 2.0
ca,sa = math.cos(math.radians(30)), math.sin(math.radians(30))
def P(x,y,z):
    # x=width, y=depth, z=height
    return (ox + (x - y)*ca*iso_s,
            oy - (z + (x + y)*sa)*iso_s)
def quad(a,b,c,d,fill,stroke=PARTL,op=1.0,sw=1.0):
    add(f'<polygon points="'+" ".join(f"{p[0]:.1f},{p[1]:.1f}" for p in (a,b,c,d))+
        f'" fill="{fill}" fill-opacity="{op}" stroke="{stroke}" stroke-width="{sw}"/>')
txt(ox-150, oy-330, "3-D VIEW", ACC, 15, weight="600")
W3,L3=total_w,lane_len
# right side wall (wedge profile)
quad(P(W3,0,0),P(W3,L3,0),P(W3,L3,top_back),P(W3,0,top_front),"#1c1c2c",PARTL,1,1.2)
# back (high, open) face frame
quad(P(0,L3,0),P(W3,L3,0),P(W3,L3,top_back),P(0,L3,top_back),"#15151f",PARTL,1,1.2)
# top inclined surface with lanes carved
quad(P(0,0,top_front),P(W3,0,top_front),P(W3,L3,top_back),P(0,L3,top_back),
     PART,PARTL,1,1.2)
for i in range(num_lanes):
    cx=lane_x(i)
    a=P(cx-cradle_r,lip_thick,axis_z); b=P(cx+cradle_r,lip_thick,axis_z)
    c=P(cx+cradle_r,L3,axis_z+rise);   d=P(cx-cradle_r,L3,axis_z+rise)
    quad(a,b,c,d,BG,PARTL,1,1)
    # pen sitting at the front of each lane
    pa=P(cx-pen_d/2,lip_thick,axis_z); pb=P(cx+pen_d/2,lip_thick,axis_z)
    pc=P(cx+pen_d/2,lip_thick+pen_len*0.5,axis_z+pen_len*0.5*math.tan(math.radians(incline_deg)))
    pd=P(cx-pen_d/2,lip_thick+pen_len*0.5,axis_z+pen_len*0.5*math.tan(math.radians(incline_deg)))
    quad(pa,pb,pc,pd,PEN,ACC,0.8,1)
# front lip bar
quad(P(0,0,0),P(W3,0,0),P(W3,0,lip_top),P(0,0,lip_top),ACC,ACC2,0.30,1.2)
txt(ox-150, oy-300, "pens load at the open back, slide to the front lip", SUB,12)

add('</svg>')
svg="\n".join(out)
open("/home/user/peptide-store/design/preview.svg","w").write(svg)
cairosvg.svg2png(bytestring=svg.encode(),write_to="/home/user/peptide-store/design/preview.png",
                 output_width=W*2, output_height=H*2)
print("wrote preview.svg + preview.png")
print(f"footprint {total_w:.0f} x {lane_len:.0f} x {top_back:.0f} mm")
