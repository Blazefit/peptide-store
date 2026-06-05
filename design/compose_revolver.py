#!/usr/bin/env python3
"""Compose the OpenSCAD renders into one labeled preview sheet."""
import base64, cairosvg

def img64(path):
    return "data:image/png;base64," + base64.b64encode(open(path,"rb").read()).decode()

both=img64("view_both.png"); drum=img64("view_drum.png"); base=img64("view_base.png")
BG="#0f0f13"; INK="#e2e2f0"; SUB="#9393b0"; ACC="#7c5cfc"; ACC2="#a78bfa"; GRN="#34d399"
W,H=1240,940
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" '
   f'font-family="Segoe UI, system-ui, sans-serif">']
s.append(f'<rect width="{W}" height="{H}" fill="{BG}"/>')
def t(x,y,txt,fill=INK,sz=15,a="start",w="400",it=False):
    st="italic" if it else "normal"
    s.append(f'<text x="{x}" y="{y}" fill="{fill}" font-size="{sz}" font-weight="{w}" '
             f'font-style="{st}" text-anchor="{a}">{txt}</text>')
def img(href,x,y,w,h):
    s.append(f'<image href="{href}" x="{x}" y="{y}" width="{w}" height="{h}" '
             f'preserveAspectRatio="xMidYMid meet"/>')
def chip(x,y,txt,col):
    bw=len(txt)*7.4+22
    s.append(f'<rect x="{x}" y="{y-15}" width="{bw}" height="22" rx="11" '
             f'fill="{col}" fill-opacity="0.16" stroke="{col}" stroke-width="1"/>')
    t(x+11,y+1,txt,col,12.5,"start","600")
    return x+bw+10

t(W/2,42,"Peptide Pen “Revolver”",INK,30,"middle","700")
t(W/2,68,"horizontal rotating cylinder · 6 chambers · snap-on base · click detent",SUB,15,"middle")

# big assembly
t(40,108,"ASSEMBLED",ACC2,17,"start","700")
t(190,108,"— spin it like a gun cylinder; index the pen to the top",SUB,13)
img(both, 20, 120, 790, 600)
# callouts on assembly
t(800,470,"axle pin + click detent  ▶",GRN,12.5,"end","600")
t(470,690,"6 chambers · pens lie flat · loaded from the open front, closed backs stop them",
  ACC2,12.5,"middle")

# parts column
t(1020,108,"DRUM",ACC2,16,"middle","700")
img(drum, 820, 118, 400, 360)
t(1020,498,"prints standing, back-face down — no supports",SUB,12,"middle")
t(1020,540,"BASE",ACC2,16,"middle","700")
img(base, 830, 552, 380, 250)
t(1020,818,"prints flat — drum sockets snap onto the pins",SUB,12,"middle")

# spec bar
y=860
t(40,y-22,"Specs (defaults — all parametric)",INK,15,"start","600")
x=40
x=chip(x,y,"6 chambers",ACC)
x=chip(x,y,"pen Ø19 × 150 mm",ACC)
x=chip(x,y,"drum Ø77 × 155 mm",ACC2)
x=chip(x,y,"base 170 × 73 mm",ACC2)
x=chip(x,y,"overall H ≈ 84 mm",ACC2)
x=chip(x,y,"2 printed parts, no hardware",GRN)
t(40,y+34,"Load: drop a pen in the front · Closed backs hold them · "
          "Push out via the ejector hole behind each chamber",SUB,12.5)

s.append('</svg>')
svg="\n".join(s)
open("/home/user/peptide-store/design/revolver-preview.svg","w").write(svg)
cairosvg.svg2png(bytestring=svg.encode(),
                 write_to="/home/user/peptide-store/design/revolver-preview.png",
                 output_width=W*2, output_height=H*2)
print("wrote revolver-preview.png")
