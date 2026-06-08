import base64, cairosvg
def u(p): return "data:image/png;base64,"+base64.b64encode(open(p,"rb").read()).decode()
imgs={k:u("best/"+v) for k,v in {
 "1l":"1_slidebar_locked.png","1e":"1_slidebar_exploded.png",
 "2l":"2_cornersnap_locked.png","2e":"2_cornersnap_exploded.png",
 "3l":"3_snaplip_locked.png","3e":"3_snaplip_exploded.png"}.items()}
BG="#0f0f13";INK="#e2e2f0";SUB="#9393b0";GRN="#34d399";YEL="#fbbf24";ACC="#7c9cf0"
W,H=1320,980
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">',f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def e(v):return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def t(x,y,s2,f=INK,sz=15,a="start",w="400"):s.append(f'<text x="{x}" y="{y}" fill="{f}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{e(s2)}</text>')
def panel(x,y,w,h,c):s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="#17171f" stroke="{c}" stroke-opacity="0.5"/>')
t(W/2,40,"Layer attachment — best 3 of 15",INK,28,"middle","700")
t(W/2,63,"more secure than the slide groove · tool-free · low-profile · no loose parts · clear of the vial holes",SUB,14,"middle")
cards=[(GRN,"① Slide-to-lock bar","imgs1",
        ["Push a small bar sideways → a hook drops into a slot.","Locks lift AND side-pull · one-finger, stays in footprint.",
         "Release: slide the bar back. Most intuitive / discreet."]),
       (ACC,"② Corner snap tabs","imgs2",
        ["Press the upper tray straight down → 4 corner clips snap on.","Resists lift + X + Y slide · nothing protrudes.",
         "Release: flex a corner tab out. Simplest push-on."]),
       (YEL,"③ Continuous snap lip","imgs3",
        ["A full-length bead clicks into a groove down each side.","Strongest hold + full anti-slide · tiniest feature (just a bead).",
         "Release: pry a side with a fingernail. Most secure of the three."])]
cw=(W-4*22)/3
for i,(c,title,key,bl) in enumerate(cards):
    x=22+i*(cw+22); panel(x,80,cw,860,c)
    t(x+16,108,title,c,18,"start","700")
    s.append(f'<image href="{imgs[str(i+1)+"l"]}" x="{x+8}" y="118" width="{cw-16}" height="300"/>'); t(x+18,136,"LOCKED",c,12,"start","700")
    s.append(f'<image href="{imgs[str(i+1)+"e"]}" x="{x+8}" y="430" width="{cw-16}" height="300"/>'); t(x+18,448,"EXPLODED",c,12,"start","700")
    for j,b in enumerate(bl): t(x+16,760+j*30,"• "+b,SUB,12.5)
t(W/2,H-16,"All integral to the trays (no parts to lose), print without supports. Pick one and I'll add it to your actual layer STL + the top piece, then verify the fit.",SUB,12.5,"middle")
s.append('</svg>')
cairosvg.svg2png(bytestring="\n".join(s).encode(),write_to="best/attach-best3.png",output_width=W*2,output_height=H*2)
print("ok")
