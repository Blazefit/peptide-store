#!/usr/bin/env python3
"""Compose the mechanism-refinement preview sheet (latch / detent / catch)."""
import base64, cairosvg
def u(p): return "data:image/png;base64,"+base64.b64encode(open(p,"rb").read()).decode()
L1,L2,L3 = u("m_latch1.png"),u("m_latch2.png"),u("m_latch3.png")
D1,D2     = u("m_detent1.png"),u("m_detent2.png")
SEC       = u("m_section.png")
BG="#0f0f13";INK="#e2e2f0";SUB="#9393b0";ACC="#7c5cfc";ACC2="#a78bfa";GRN="#34d399";YEL="#fbbf24";RED="#e23b3b"
W,H=1280,1080
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">',
   f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def esc(v): return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def t(x,y,txt,fill=INK,sz=15,a="start",w="400"):
    s.append(f'<text x="{x}" y="{y}" fill="{fill}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{esc(txt)}</text>')
def img(h,x,y,w,ht): s.append(f'<image href="{h}" x="{x}" y="{y}" width="{w}" height="{ht}" preserveAspectRatio="xMidYMid meet"/>')
def panel(x,y,w,h,c=ACC):
    s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="9" fill="#17171f" stroke="{c}" stroke-opacity="0.4"/>')
def badge(x,y,n,c):
    s.append(f'<circle cx="{x}" cy="{y}" r="13" fill="{c}" fill-opacity="0.22" stroke="{c}"/>')
    t(x,y+5,n,c,15,"middle","700")

t(W/2,42,"Drop-Selector — mechanism refinements",INK,28,"middle","700")
t(W/2,66,"verified in OpenSCAD across the throw / index / catch",SUB,15,"middle")

# ---- Row 1: print-in-place latch sequence ----
y=86
t(30,y+18,"1 · Print-in-place button latch",ACC2,18,"start","700")
t(30,y+38,"one springy part (blade + hook + button); the throw is derived from the engagement so pressing always clears it",SUB,12.5)
fy=y+50; fw=392; fh=300
for i,(im,lab,sub,c) in enumerate([
    (L1,"CLOSED","hook blocks the lip nub",GRN),
    (L2,"PRESSED","blade flexes — hook retracts clear",YEL),
    (L3,"RELEASED","trapdoor swings down, pen drops",RED)]):
    x=30+i*(fw+12)
    panel(x,fy,fw,fh)
    img(im,x+6,fy+30,fw-12,fh-40)
    badge(x+22,fy+22,str(i+1),c)
    t(x+40,fy+27,lab,c,14,"start","700")
    t(x+40,fy+fh-8,sub,SUB,11.5)

# ---- Row 2: detent + catch ----
y2=fy+fh+26
# detent (left two)
t(30,y2+18,"2 · Auto-index detent",ACC2,18,"start","700")
t(30,y2+37,"a leaf-spring nub clicks into one dimple per chamber — every chamber self-locates at the drop station",SUB,12.5)
dy=y2+48; dw=300; dh=300
panel(30,dy,dw,dh,GRN); img(D1,36,dy+28,dw-12,dh-38)
t(180,dy+22,"dimple ring (1 / chamber)",GRN,12.5,"middle","600")
panel(30+dw+12,dy,dw,dh,YEL); img(D2,36+dw+12,dy+28,dw-12,dh-38)
t(180+dw+12,dy+22,"nub seated in bottom dimple",YEL,12.5,"middle","600")

# catch section (right)
t(30+2*(dw+12)+8,y2+18,"3 · Catch ramp + cushion",ACC2,18,"start","700")
t(30+2*(dw+12)+8,y2+37,"concave landing, springy fingers, settles by a tall lip",SUB,12.5)
cx=30+2*(dw+12)+8; cw=W-cx-30
panel(cx,dy,cw,dh,RED); img(SEC,cx+4,dy+26,cw-8,dh-34)
t(cx+cw/2,dy+22,"drop path: chamber → open flap → caught by lip",RED,12,"middle","600")

# footer
t(30,H-26,"All geometry compiles; latch/detent/cushion are print-in-place springs (tune blade thickness & clearances to your printer).",SUB,12.5)
t(30,H-9,"States are parametric: latch_state, flap_state, detent_on, cushion_on — see README-dropper.md.",SUB,12.5)

s.append('</svg>')
svg="\n".join(s); open("dropper-mechanisms.svg","w").write(svg)
cairosvg.svg2png(bytestring=svg.encode(),write_to="dropper-mechanisms.png",output_width=W*2,output_height=H*2)
print("wrote dropper-mechanisms.png")
