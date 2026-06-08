import base64, cairosvg
R="renders/"
def u(p): return "data:image/png;base64,"+base64.b64encode(open(R+p,"rb").read()).decode()
BG="#0f0f13";INK="#e6e6f0";SUB="#9a9ab8";GRN="#34d399";YEL="#fbbf24";BLU="#7c9cf0";RED="#ef5350";PUR="#c264e0";ORN="#fb923c"
W,H=1880,1180
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">',f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def e(v):return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def t(x,y,s2,f=INK,sz=15,a="start",w="400"):s.append(f'<text x="{x}" y="{y}" fill="{f}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{e(s2)}</text>')
def panel(x,y,w,h,c):s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="12" fill="#16161e" stroke="{c}" stroke-opacity="0.6"/>')
t(W/2,44,"Place-then-secure stacking lock — TOP 5 (all verified against your real tray STL)",INK,30,"middle","700")
t(W/2,70,"drop the top tray straight DOWN (loose) → lock from the FRONT/ENDS · door side stays flush · existing groove kept · nothing added to the top tray",SUB,15.5,"middle")
# card data: hero, unlocked, accent, title, tag, capture, lines
cards=[
 ("A_sliderail_L_low.png","A_sliderail_U_front.png",GRN,"① Slide-rail bolt","RECOMMENDED · one push · lowest profile","1308 mm³",
   ["Push the front bar in once → a full-width shelf slides","over the front rail; both ends captured too.",
    "Nothing rises above the tray — best under a shelf."]),
 ("D_spinelock_L_low.png","D_spinelock_U_front.png",ORN,"② Lift-&-click spine","one upward sweep · self-clicks","533 mm³",
   ["Sweep the front spine bar up once → both end hooks","crest the end-wall tops and snap over with a click.",
    "Very secure 3-point grab, satisfying detent."]),
 ("C_discretcams_L_low.png","C_discretcams_U_front.png",BLU,"③ Flip-levers","familiar · folds flat when open","651 mm³",
   ["Flip up 3 front levers + 2 end clamps over the rim.","Levers lie flat against the wall when unlocked.",
    "Simple, intuitive, lots of hold."]),
 ("B_trilock_L_low.png","B_trilock_U_front.png",PUR,"④ Tri-lock twist cams","quarter-turn knobs","288 mm³",
   ["Twist 2 end knobs + 1 front cam 90°; lobes swing","over the end-wall tops and cam the tray down tight.",
    "Note: knobs sit slightly proud — needs a little headroom."]),
 ("A_twintab_L_low.png","A_twintab_U_front.png",RED,"⑤ Twin-tab bolt","lightest · least plastic","747 mm³",
   ["Same one-push front bar as ①, but just two slim tabs","reach into the side slot — minimal material, low profile.",
    "Great if you want the simplest, lightest add-on."]),
]
cw=362; gap=14; x0=14; iy=92; ih=276
for i,(hero,unl,c,title,tag,cap,lines) in enumerate(cards):
    x=x0+i*(cw+gap); panel(x,iy,cw,ih+330,c)
    s.append(f'<image href="{u(hero)}" x="{x+6}" y="{iy+6}" width="{cw-12}" height="{ih-6}" preserveAspectRatio="xMidYMid meet"/>')
    # unlocked inset
    iw=120
    s.append(f'<rect x="{x+cw-iw-12}" y="{iy+ih-92}" width="{iw}" height="86" rx="6" fill="#0c0c10" stroke="{c}" stroke-opacity="0.5"/>')
    s.append(f'<image href="{u(unl)}" x="{x+cw-iw-10}" y="{iy+ih-90}" width="{iw-4}" height="82" preserveAspectRatio="xMidYMid meet"/>')
    t(x+cw-iw-6,iy+ih-78,"OPEN",c,10,"start","700")
    yy=iy+ih+26
    t(x+16,yy,title,c,21,"start","700")
    t(x+16,yy+22,tag,INK,13,"start","600")
    t(x+16,yy+48,f"lift-block capture: {cap}",YEL,13.5,"start","700")
    t(x+16,yy+66,"door-flush ✓  ·  drop-in ✓  ·  verified ✓",GRN,11.5,"start","600")
    for j,ln in enumerate(lines): t(x+16,yy+92+j*22,ln,SUB,12.5)
t(W/2,H-58,"Each card's small inset = UNLOCKED state (top tray lifts straight off). Every design also has front / low / REAR(door) / open renders in the renders/ folder.",SUB,13,"middle")
t(W/2,H-34,"'capture' = solid volume that physically blocks a 2 mm lift when locked (measured against the real L3 tray; must exceed 200 mm³ to pass).",SUB,12.5,"middle")
t(W/2,H-14,"All keep the existing sliding groove and add ZERO geometry to the already-printed top tray.",INK,12.5,"middle","600")
s.append('</svg>')
cairosvg.svg2png(bytestring="\n".join(s).encode(),write_to="attach-top5.png",output_width=W,output_height=H)
print("ok")
