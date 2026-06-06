#!/usr/bin/env python3
"""Compose the SIMPLE-edition preview sheet."""
import base64, cairosvg
def u(p): return "data:image/png;base64,"+base64.b64encode(open(p,"rb").read()).decode()
HERO,EXPL = u("simple_hero.png"),u("simple_exploded.png")
CLO,OPN   = u("simple_closed.png"),u("simple_open.png")
BG="#0f0f13";INK="#e2e2f0";SUB="#9393b0";ACC="#7c5cfc";ACC2="#a78bfa";GRN="#34d399";YEL="#fbbf24"
W,H=1300,1000
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">',
   f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def esc(v): return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def t(x,y,txt,fill=INK,sz=15,a="start",w="400"):
    s.append(f'<text x="{x}" y="{y}" fill="{fill}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{esc(txt)}</text>')
def img(h,x,y,w,ht): s.append(f'<image href="{h}" x="{x}" y="{y}" width="{w}" height="{ht}" preserveAspectRatio="xMidYMid meet"/>')
def panel(x,y,w,h,c=ACC,fill="#17171f"):
    s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="{fill}" stroke="{c}" stroke-opacity="0.45"/>')
def chip(x,y,txt,c):
    bw=len(txt)*7.4+24
    s.append(f'<rect x="{x}" y="{y-16}" width="{bw}" height="24" rx="12" fill="{c}" fill-opacity="0.16" stroke="{c}"/>')
    t(x+12,y+1,txt,c,13,"start","600"); return x+bw+10
def dot(x,y,n,c):
    s.append(f'<circle cx="{x}" cy="{y}" r="13" fill="{c}" fill-opacity="0.22" stroke="{c}"/>')
    t(x,y+5,n,c,14,"middle","700")

t(W/2,44,"Drop-Selector Revolver — simple edition",INK,29,"middle","700")
t(W/2,68,"spin to your pen · pull the slide · it drops into the tray. 3 printed parts, no fasteners, no springs.",SUB,15,"middle")

# hero (left)
panel(24,86,640,560,ACC)
img(HERO,30,92,628,548)
t(44,118,"ASSEMBLED",ACC2,15,"start","700")
t(340,636,"drum just drops into the open bearings — lift it out to refill",SUB,12,"middle")

# exploded (right)
panel(680,86,596,560,GRN)
img(EXPL,686,96,584,520)
t(700,118,"THREE PARTS",GRN,15,"start","700")
x=720
for lab,c in [("① Drum (drops in)",ACC2),("② Shutter (one flat slide)",YEL),("③ Body (tray + bearings + shroud)",GRN)]:
    x=chip(x,636,lab,c)

# bottom-left: closed/open
y=672
t(24,y+6,"How the gate works",INK,17,"start","700")
panel(24,y+18,300,300,ACC); img(CLO,30,y+30,288,280); t(168,y+40,"CLOSED — pen held",ACC2,12.5,"middle","600")
panel(332,y+18,300,300,YEL); img(OPN,338,y+30,288,280); t(476,y+40,"OPEN — that pen drops",YEL,12.5,"middle","600")

# bottom-right: use + why simple
bx=672
t(bx,y+6,"Use it",INK,17,"start","700")
for i,(h,d) in enumerate([("Spin","the drum clicks each chamber to the drop station"),
                          ("Pull","slide the shutter out ~3 cm — one pen drops"),
                          ("Grab","it settles against the front lip; pick it up"),
                          ("Push","slide the shutter back; spin to the next")]):
    yy=y+44+i*34
    dot(bx+13,yy-4,str(i+1),ACC2); t(bx+34,yy-6,h,INK,14,"start","600"); t(bx+34,yy+10,d,SUB,11.5)
t(bx,y+196,"Why it's simpler now",GRN,14,"start","700")
for i,d in enumerate(["drop-in axle (was a snap-fit) — lift out to refill",
                      "one sliding shutter replaces the trapdoor + hinge + sprung latch",
                      "no springs to fatigue; the only flex is the optional index click"]):
    t(bx+4,y+216+i*19,"• "+d,SUB,12)

# badges
yb=H-26
x=24
for c,col in [("3 parts",ACC),("no fasteners",GRN),("no springs",GRN),
              ("drop-in drum",ACC2),("slide to dispense",YEL),("all parametric",ACC)]:
    x=chip(x,yb,c,col)

s.append('</svg>')
svg="\n".join(s); open("dropper-preview.svg","w").write(svg)
cairosvg.svg2png(bytestring=svg.encode(),write_to="dropper-preview.png",output_width=W*2,output_height=H*2)
print("wrote dropper-preview.png")
