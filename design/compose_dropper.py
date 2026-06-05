#!/usr/bin/env python3
"""Compose the drop-selector revolver renders into one labeled preview sheet."""
import base64, cairosvg

def u(p): return "data:image/png;base64,"+base64.b64encode(open(p,"rb").read()).decode()
both,expl,sec,flap,drum = (u("drop_both.png"),u("drop_exploded.png"),
                           u("drop_section.png"),u("drop_flap.png"),u("drop_drum.png"))
BG="#0f0f13";INK="#e2e2f0";SUB="#9393b0";ACC="#7c5cfc";ACC2="#a78bfa";GRN="#34d399";YEL="#fbbf24"
W,H=1280,1010
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" '
   f'font-family="Segoe UI, system-ui, sans-serif">',f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def esc(v): return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def t(x,y,txt,fill=INK,sz=15,a="start",w="400"):
    s.append(f'<text x="{x}" y="{y}" fill="{fill}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{esc(txt)}</text>')
def img(h,x,y,w,ht): s.append(f'<image href="{h}" x="{x}" y="{y}" width="{w}" height="{ht}" preserveAspectRatio="xMidYMid meet"/>')
def chip(x,y,txt,c):
    bw=len(txt)*7.3+22
    s.append(f'<rect x="{x}" y="{y-15}" width="{bw}" height="22" rx="11" fill="{c}" fill-opacity="0.16" stroke="{c}"/>')
    t(x+11,y+1,txt,c,12.5,"start","600"); return x+bw+10

t(W/2,40,"Peptide Pen “Drop-Selector Revolver”",INK,29,"middle","700")
t(W/2,64,"spin to the pen you want · press the button · it drops into the catch tray below",SUB,15,"middle")

# hero
t(34,98,"ASSEMBLED",ACC2,16,"start","700")
img(both,20,108,720,610)
t(150,150,"◀ fluted drum + loaded pen show through the open top",SUB,12.5)
t(380,690,"upper unit slides down into the catch-tray base",SUB,12.5,"middle")

# right column: exploded + section
t(770,98,"EXPLODED",ACC2,15,"start","700")
img(expl,752,106,250,235)
t(1030,98,"CROSS-SECTION",ACC2,15,"start","700")
img(sec,1010,104,250,250)
t(1135,300,"6 chambers · drop path",SUB,11,"middle")
# trapdoor
t(770,370,"TRAPDOOR + LATCH",ACC2,15,"start","700")
img(flap,755,378,250,165)
t(880,556,"hinge rod · latch lip",SUB,11,"middle")
# drum
t(1030,370,"DRUM",ACC2,15,"start","700")
img(drum,1035,360,210,210)
t(1135,560,"fluted, side-open chambers",SUB,11,"middle")

# how it works
y0=620
t(770,y0-6,"How the drop works",INK,16,"start","700")
steps=[("1","Spin",  "rotate the chosen chamber to the bottom drop station"),
       ("2","Press", "push the button — the latch releases the trapdoor"),
       ("3","Drop",  "the trapdoor swings open and that one pen falls"),
       ("4","Catch", "it lands in the angled tray and rolls to the front lip")]
yy=y0+18
for n,h,d in steps:
    s.append(f'<circle cx="784" cy="{yy-4}" r="10" fill="{ACC}" fill-opacity="0.25" stroke="{ACC2}"/>')
    t(784,yy,n,ACC2,12,"middle","700"); t(804,yy-2,h,INK,13.5,"start","600"); t(804,yy+13,d,SUB,11.5)
    yy+=40

# specs
y=900
t(34,y-22,"Specs (defaults — all parametric)",INK,15,"start","600")
x=34
for c,col in [("6 chambers",ACC),("pen Ø19 × 150 mm",ACC),("drum Ø75 × 158 mm",ACC2),
              ("4 printed parts",GRN),("drum + cradle + flap + base",GRN),("one-button release",YEL)]:
    x=chip(x,y,c,col)
t(34,y+32,"Parts: fluted drum · cradle (legs+shroud+latch) · trapdoor flap · secondary catch base. "
          "Mechanism shown closed — see README for motion & tuning.",SUB,12)

s.append('</svg>')
svg="\n".join(s); open("dropper-preview.svg","w").write(svg)
cairosvg.svg2png(bytestring=svg.encode(),write_to="dropper-preview.png",output_width=W*2,output_height=H*2)
print("wrote dropper-preview.png")
