#!/usr/bin/env python3
"""
HUMAN+  —  MYTHOS series  (second design line)
================================================
A separate, more "mythical" series: every compound is rendered as a stylized
heraldic CHARACTER CARD (a relic / trading card), and stacks render as
EVOLUTIONS ("forged from ...").  Two visual treatments share one layout:

    MYTHIC  (default) -> dark stone + gold/bronze, serif display, runic corners.
                         Less colorful, more "Lord of the Rings relic".
    ARCANE            -> brighter, rounded, energy-typed.  The "Pokemon-like"
                         option the brief asked to keep as a toggle.

The figures are code-drawn SILHOUETTES (head + body archetype + emblem add-ons).
They are deliberately iconic, not painted — they hold the layout and are a
drop-in slot for commissioned / AI art later (same window, swap the <g>).

Run:  python3 generate_mythic.py
Outputs SVGs to ./mythic_svg, PNG previews to ./mythic_preview (both styles),
and builds mythic.html (gallery) + home.html (hub linking both series).
"""

import os, subprocess, json, math
from generate_tiles import ELEMENTS, STACKS

SANS  = "'Segoe UI',system-ui,-apple-system,sans-serif"
SERIF = "'Cinzel','Trajan Pro',Georgia,'DejaVu Serif',serif"
MONO  = "ui-monospace,'Courier New',monospace"

# ---------------------------------------------------------------------------
# Mythic palette — muted, metallic, low-neon (the "less childlike" direction)
AURAS = {
    "gold":      "#C9A24B", "bronze":   "#A9772F", "emerald": "#3E9E6E",
    "sapphire":  "#3E72C9", "crimson":  "#B23A48", "violet":  "#7A5AA8",
    "silver":    "#AEB7C2", "verdigris":"#3FA7B8", "rose":    "#C46A8A",
    "steel":     "#6E7B8C", "marble":   "#CDBE94", "obsidian":"#6B5E83",
    "stone":     "#9A9486",
}

# ---------------------------------------------------------------------------
# Per-compound mythic identity:  sym -> (creature name, archetype, aura, lore)
# archetype drives the silhouette; aura drives the color treatment.
MYTHIC = {
    # peptides
    "Gh": ("THE PROGENITOR",  "ascendant", "gold",     "First flame of growth, from which all forms rise."),
    "Bp": ("THE MENDER",      "warden",    "emerald",  "Stitches living flesh back from ruin."),
    "Tb": ("THE RESTORER",    "warden",    "emerald",  "What is torn, it makes whole again."),
    "Sg": ("THE FAMINE",      "hunter",    "silver",   "Hunger itself kneels before its gaze."),
    "Tz": ("THE TWINBLADE",   "hunter",    "silver",   "Two appetites severed with a single edge."),
    "Re": ("THE TRIUNE",      "hunter",    "sapphire", "Three hungers bound to one lean will."),
    "Ip": ("THE PULSE",       "ascendant", "gold",     "A clean, rhythmic call to the deep."),
    "Cj": ("THE SUSTAINER",   "ascendant", "gold",     "Holds the signal long after others fade."),
    "Sr": ("THE WAKER",       "ascendant", "gold",     "Rouses the sleeping engine of youth."),
    "Tm": ("THE CARVER",      "hunter",    "silver",   "Pares the hidden weight from within."),
    "Gk": ("THE BLUE WEAVER", "warden",    "verdigris","Copper-born, it reweaves skin and strand."),
    "Mt": ("THE SUNBRINGER",  "seraph",    "bronze",   "Carries the sun beneath the skin."),
    "Pt": ("THE LONGING",     "seraph",    "crimson",  "Looses the old arrow of wanting."),
    "Ox": ("THE BOND",        "seraph",    "rose",     "Binds two souls with an unseen thread."),
    "Sk": ("THE STILL MIND",  "sage",      "violet",   "Quiets the storm without dulling the blade."),
    "Sx": ("THE FOCUSED",     "sage",      "violet",   "Narrows the world to a single bright point."),
    "Ep": ("THE TIMELESS",    "ascendant", "silver",   "Turns the falling sand back up the glass."),
    "Ta": ("THE SENTINEL",    "warden",    "emerald",  "Stands the long watch against the unseen."),
    "Ig": ("THE AMPLIFIER",   "titan",     "gold",     "Takes the whisper of growth and roars it."),
    "Mc": ("THE CORE",        "ascendant", "sapphire", "Speaks the old language of the furnace within."),
    "Gn": ("THE AXIS",        "alchemist", "bronze",   "Restarts the wheel from which all turns."),
    "Ks": ("THE SPARK",       "seraph",    "crimson",  "Ignites the cascade that wakes the line."),
    "Hx": ("THE SURGE",       "ascendant", "gold",     "A sudden flood where there was a trickle."),
    "Gp": ("THE RAVENER",     "ascendant", "gold",     "Brings hunger and growth in the same breath."),
    "Ad": ("THE EMBER",       "hunter",    "silver",   "A small fire that eats only fat."),
    "Ss": ("THE WARD",        "warden",    "sapphire", "Armor for the engine-room of the cell."),
    "Kp": ("THE QUELLER",     "warden",    "emerald",  "Where it walks, the fire of inflammation dies."),
    "Ds": ("THE DREAMER",     "sage",      "violet",   "Pulls the mind down into deep, dark water."),
    "In": ("THE MASTER KEY",  "alchemist", "gold",     "The one key that opens every cellular door."),
    "Hc": ("THE BEACON",      "alchemist", "bronze",   "Keeps the home fires of the axis lit."),
    # hormones (curated set)
    "Te": ("THE TITAN",       "titan",     "bronze",   "The original crown. The first upgrade."),
    "Nd": ("THE IRONBOUND",   "titan",     "bronze",   "Mass with mercy for the joints that carry it."),
    "Oa": ("THE WHITTLER",    "hunter",    "bronze",   "Strips away all that is not the cut."),
    "Es": ("THE BALANCE",     "alchemist", "rose",     "Holds the equation in perfect tension."),
    "Dh": ("THE PRECURSOR",   "alchemist", "bronze",   "The seed from which the others are grown."),
    "T3": ("THE FURNACE",     "alchemist", "crimson",  "Throttles the fire at the body's center."),
    "Ml": ("THE DUSK",        "sage",      "violet",   "Draws the curtain so the work can begin."),
    # molecules
    "Na": ("THE CURRENT",     "ascendant", "violet",   "The coin every cell must spend to live."),
    "Mq": ("THE UNMAKER",     "alchemist", "violet",   "Deletes the gene that hoards the fat."),
    "Mb": ("THE AZURE",       "alchemist", "sapphire", "Lends electrons to the failing light."),
}

# Per-stack evolution identity:  STACK NAME -> (archetype, aura, lore)
EVO = {
    "WOLVERINE":        ("berserker", "steel",    "Heals as fast as it tears. It does not stop."),
    "ADAMANTIUM":       ("colossus",  "steel",    "Forged unbreakable, bone laced with metal."),
    "SPARTAN":          ("berserker", "bronze",   "No retreat. No surrender. Only the line."),
    "FIELD REPAIR":     ("warden",    "emerald",  "Patch the wound and march on."),
    "PHOENIX":          ("seraph",    "crimson",  "Burns to ash, then rises from it whole."),
    "THE FOUNDATION":   ("titan",     "bronze",   "Everything great is built upon this stone."),
    "WORKHORSE":        ("titan",     "bronze",   "It shows up. Every single day."),
    "PRIME":            ("titan",     "gold",     "Held at the very peak of condition."),
    "THE HOLY TRINITY": ("ascendant", "gold",     "Three powers. Nothing more is needed."),
    "BLACK LABEL":      ("colossus",  "obsidian", "Top shelf only. Reserved for the few."),
    "OLD GUARD":        ("titan",     "bronze",   "Earned across years. Never simply given."),
    "GREEK GOD":        ("titan",     "marble",   "Carved from marble in a forgotten age."),
    "MASS MONSTER":     ("colossus",  "crimson",  "Maximum overload. The mountain that walks."),
    "SHREDDER":         ("hunter",    "silver",   "Shrink-wrapped down to the living architecture."),
    "STOIC":            ("sage",      "stone",    "Unmoved by the storm. Unshaken at the core."),
    "LIMITLESS":        ("sage",      "violet",   "No ceiling remains above the cleared mind."),
    "LOCK IN":          ("sage",      "sapphire", "Tunnel vision. The world goes quiet."),
    "IRON MIND":        ("sage",      "bronze",   "The mind, forged and hammered into iron."),
    "CLEAR HEAD":       ("sage",      "silver",   "Signal, with all the noise stripped away."),
    "GAME DAY":         ("hunter",    "gold",     "Everything sharpened to a single point: now."),
    "REACTOR":          ("ascendant", "sapphire", "The core powered to a steady, endless hum."),
    "OVERDRIVE":        ("ascendant", "violet",   "The engine redlined past every safe limit."),
    "SHOWTIME":         ("seraph",    "bronze",   "Made to be seen. Made to steal the light."),
    "THE VAULT":        ("warden",    "silver",   "Longevity, sealed and locked away for keeps."),
}

# ---------------------------------------------------------------------------
def esc(s):
    return (str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))

def _mix(hex_a, hex_b, t):
    a = int(hex_a[1:], 16); b = int(hex_b[1:], 16)
    ar, ag, ab = (a >> 16) & 255, (a >> 8) & 255, a & 255
    br, bg, bb = (b >> 16) & 255, (b >> 8) & 255, b & 255
    r = round(ar + (br - ar) * t); g = round(ag + (bg - ag) * t); bl = round(ab + (bb - ab) * t)
    return f"#{(r << 16) + (g << 8) + bl:06x}"

def lighten(hex_c, t): return _mix(hex_c, "#ffffff", t)
def darken(hex_c, t):  return _mix(hex_c, "#000000", t)

def poly(pts, **a):
    d = " ".join(f"{k.replace('_','-')}=\"{v}\"" for k, v in a.items())
    p = " ".join(f"{x:.1f},{y:.1f}" for x, y in pts)
    return f'<polygon points="{p}" {d}/>'

def circ(cx, cy, r, **a):
    d = " ".join(f"{k.replace('_','-')}=\"{v}\"" for k, v in a.items())
    return f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r:.1f}" {d}/>'

def ell(cx, cy, rx, ry, **a):
    d = " ".join(f"{k.replace('_','-')}=\"{v}\"" for k, v in a.items())
    return f'<ellipse cx="{cx:.1f}" cy="{cy:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" {d}/>'

# ---------------------------------------------------------------------------
# THE SILHOUETTE LIBRARY
# Each archetype draws a stylized figure within a vertical box (cx, top..bot).
# fill = main color, edge = darker rim. Returns an SVG fragment string.
def silhouette(kind, cx, top, bot, fill, edge):
    H = bot - top
    W = H * 0.62
    headR    = H * 0.078
    headCY   = top + headR * 1.45
    shoulderY= headCY + headR + H * 0.035
    waistY   = top + H * 0.46
    hipY     = top + H * 0.54
    footY    = bot
    parts = []
    fa = dict(fill=fill, stroke=edge, stroke_width=6, stroke_linejoin="round")

    def legs(hw, thick=0.9):
        gap = W * 0.05
        lw = (hw - gap) * thick
        return [
            poly([(cx-hw, hipY), (cx-gap, hipY), (cx-gap, footY), (cx-gap-lw, footY)], **fa),
            poly([(cx+hw, hipY), (cx+gap, hipY), (cx+gap, footY), (cx+gap+lw, footY)], **fa),
        ]

    def torso(sw, hw):
        return poly([(cx-sw, shoulderY), (cx+sw, shoulderY),
                     (cx+hw, hipY), (cx-hw, hipY)], **fa)

    def arms(sw, t, raise_=0.0):
        # raise_ in [0..1] lifts the hands (0 = down by hips, 1 = up by head)
        sy = shoulderY + H*0.01
        ey = waistY - (waistY - shoulderY) * raise_ + H*0.10*(1-raise_)
        ex = sw + W*0.10 + W*0.16*raise_
        return [
            poly([(cx-sw, sy), (cx-sw-t, sy+H*0.01), (cx-ex, ey), (cx-ex+t, ey)], **fa),
            poly([(cx+sw, sy), (cx+sw+t, sy+H*0.01), (cx+ex, ey), (cx+ex-t, ey)], **fa),
        ]

    head = circ(cx, headCY, headR, **fa)

    if kind == "titan":
        sw, hw, t = W*0.60, W*0.34, W*0.15
        parts += legs(hw, 1.0) + [torso(sw, hw)] + arms(sw, t) + [head]
    elif kind == "colossus":
        sw, hw, t = W*0.74, W*0.46, W*0.20
        # horns
        parts += [poly([(cx-headR*1.1, headCY-headR*0.6),(cx-headR*1.9, headCY-headR*1.7),(cx-headR*0.5, headCY-headR*0.9)], **fa),
                  poly([(cx+headR*1.1, headCY-headR*0.6),(cx+headR*1.9, headCY-headR*1.7),(cx+headR*0.5, headCY-headR*0.9)], **fa)]
        parts += legs(hw, 1.0) + [torso(sw, hw)] + arms(sw, t) + [head]
    elif kind == "hunter":
        sw, hw, t = W*0.40, W*0.26, W*0.075
        parts += legs(hw, 0.75) + [torso(sw, hw)] + arms(sw, t)
        # bow arc on the left
        parts += [f'<path d="M{cx-sw-W*0.30:.1f},{shoulderY:.1f} Q{cx-sw-W*0.62:.1f},{(shoulderY+footY)/2:.1f} {cx-sw-W*0.30:.1f},{hipY+H*0.10:.1f}" '
                  f'fill="none" stroke="{edge}" stroke-width="9"/>',
                  f'<line x1="{cx-sw-W*0.30:.1f}" y1="{shoulderY:.1f}" x2="{cx-sw-W*0.30:.1f}" y2="{hipY+H*0.10:.1f}" stroke="{fill}" stroke-width="4"/>']
        parts += [head]
    elif kind == "seraph":
        sw, hw, t = W*0.42, W*0.27, W*0.08
        # wings behind
        wa = dict(fill=darken(fill,0.15), stroke=edge, stroke_width=5, stroke_linejoin="round")
        parts += [poly([(cx-sw*0.4, shoulderY), (cx-W*0.95, shoulderY-H*0.10),
                        (cx-W*1.02, shoulderY+H*0.14), (cx-sw*0.5, waistY)], **wa),
                  poly([(cx+sw*0.4, shoulderY), (cx+W*0.95, shoulderY-H*0.10),
                        (cx+W*1.02, shoulderY+H*0.14), (cx+sw*0.5, waistY)], **wa)]
        parts += legs(hw, 0.7) + [torso(sw, hw)] + arms(sw, t) + [head]
    elif kind == "sage":
        # hooded robe: big cloak triangle, hood over head, staff on right
        parts += [poly([(cx, shoulderY-H*0.02), (cx-W*0.55, footY), (cx+W*0.55, footY)], **fa)]
        parts += [poly([(cx-headR*1.3, headCY+headR*0.2), (cx, headCY-headR*1.5),
                        (cx+headR*1.3, headCY+headR*0.2)], **fa)]
        parts += [circ(cx, headCY+headR*0.15, headR*0.78, fill=darken(fill,0.45))]
        parts += [f'<line x1="{cx+W*0.5:.1f}" y1="{shoulderY-H*0.06:.1f}" x2="{cx+W*0.5:.1f}" y2="{footY:.1f}" stroke="{edge}" stroke-width="10"/>',
                  circ(cx+W*0.5, shoulderY-H*0.07, W*0.06, fill=lighten(fill,0.3), stroke=edge, stroke_width=4)]
    elif kind == "warden":
        sw, hw, t = W*0.50, W*0.32, W*0.12
        parts += legs(hw, 0.9) + [torso(sw, hw)] + arms(sw, t) + [head]
        # helm crest
        parts += [poly([(cx-headR*0.3, headCY-headR), (cx, headCY-headR*2.0), (cx+headR*0.3, headCY-headR)], **fa)]
        # shield over the chest
        parts += [f'<path d="M{cx-W*0.30:.1f},{shoulderY+H*0.02:.1f} L{cx+W*0.30:.1f},{shoulderY+H*0.02:.1f} '
                  f'L{cx+W*0.30:.1f},{waistY:.1f} L{cx:.1f},{waistY+H*0.10:.1f} L{cx-W*0.30:.1f},{waistY:.1f} Z" '
                  f'fill="{lighten(fill,0.18)}" stroke="{edge}" stroke-width="7"/>',
                  circ(cx, (shoulderY+waistY)/2, W*0.07, fill=edge)]
    elif kind == "ascendant":
        sw, hw, t = W*0.42, W*0.27, W*0.08
        # radiant rays
        for i in range(12):
            ang = math.radians(i*30 - 90)
            r1, r2 = H*0.20, H*0.30
            x1, y1 = cx+r1*math.cos(ang), headCY+r1*math.sin(ang)
            x2, y2 = cx+r2*math.cos(ang), headCY+r2*math.sin(ang)
            parts.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="{lighten(fill,0.25)}" stroke-width="5" stroke-opacity="0.7"/>')
        # halo
        parts += [circ(cx, headCY, headR*1.9, fill="none", stroke=lighten(fill,0.3), stroke_width=6, stroke_opacity="0.8")]
        # body, arms slightly raised, feet lifted (levitate)
        lift = H*0.04
        parts += [poly([(cx-hw, hipY), (cx-W*0.05, hipY), (cx-W*0.05, footY-lift), (cx-hw*0.8, footY-lift)], **fa),
                  poly([(cx+hw, hipY), (cx+W*0.05, hipY), (cx+W*0.05, footY-lift), (cx+hw*0.8, footY-lift)], **fa)]
        parts += [torso(sw, hw)] + arms(sw, t, raise_=0.55) + [head]
    elif kind == "alchemist":
        sw, hw, t = W*0.46, W*0.30, W*0.09
        parts += legs(hw, 0.85) + [torso(sw, hw)]
        # arms forward cradling an orb
        oy = (shoulderY+waistY)/2 + H*0.02
        parts += [poly([(cx-sw, shoulderY), (cx-sw-t, shoulderY+H*0.01), (cx-W*0.10, oy+W*0.10), (cx-W*0.02, oy)], **fa),
                  poly([(cx+sw, shoulderY), (cx+sw+t, shoulderY+H*0.01), (cx+W*0.10, oy+W*0.10), (cx+W*0.02, oy)], **fa)]
        parts += [circ(cx, oy+W*0.02, W*0.20, fill="none", stroke=lighten(fill,0.35), stroke_width=4, stroke_opacity="0.6"),
                  circ(cx, oy+W*0.02, W*0.135, fill=lighten(fill,0.30), stroke=edge, stroke_width=5)]
        parts += [head]
    elif kind == "berserker":
        # hunched, head forward, claws
        sw, hw, t = W*0.58, W*0.36, W*0.16
        hx = cx + W*0.10  # head shifted forward
        parts += legs(hw, 1.0)
        parts += [poly([(cx-sw, shoulderY+H*0.03), (cx+sw, shoulderY-H*0.02),
                        (cx+hw, hipY), (cx-hw, hipY)], **fa)]
        # arms down with claws
        for sgn in (-1, 1):
            ax = cx + sgn*(sw+W*0.04)
            ay = shoulderY + H*0.02
            ex = cx + sgn*(sw+W*0.22)
            ey = hipY + H*0.06
            parts.append(poly([(ax, ay), (ax-sgn*t, ay), (ex-sgn*t, ey), (ex, ey)], **fa))
            for k in range(3):
                cxx = ex + sgn*(k-1)*W*0.05
                parts.append(poly([(cxx, ey), (cxx+sgn*W*0.015, ey+H*0.07), (cxx-sgn*W*0.02, ey)], fill=lighten(fill,0.2), stroke=edge, stroke_width=3))
        parts += [circ(hx, headCY+H*0.02, headR, **fa)]
    else:
        parts += [head]
    return f'<g>{"".join(parts)}</g>'

# ---------------------------------------------------------------------------
def card(title, real_name, archetype, aura_key, lore, power_label, power_val,
         chain_label, chain_text, style="mythic"):
    acc = AURAS.get(aura_key, AURAS["gold"])
    M = (style == "mythic")
    fx, fy, fw, fh = 60, 60, 1080, 1280   # outer frame
    # portrait window
    px, py, pw, ph = 150, 300, 900, 690
    name_font = SERIF if M else SANS
    body_bg   = "#0c0a08" if M else "#0f1118"
    frame_in  = darken(acc, 0.25) if M else acc
    frame_out = acc if M else lighten(acc, 0.25)
    txt       = "#ece4d2" if M else "#eef2f8"
    txt_dim   = "#998f78" if M else "#9aa3b5"

    # portrait background gradient (mythic: aura->near-black; arcane: light aura)
    if M:
        g0, g1 = _mix(acc, "#000000", 0.55), "#060504"
        fig_fill, fig_edge = _mix(acc, "#1a1712", 0.35), darken(acc, 0.55)
    else:
        g0, g1 = lighten(acc, 0.45), darken(acc, 0.10)
        fig_fill, fig_edge = lighten(acc, 0.10), darken(acc, 0.40)

    # corner ornaments
    corners = ""
    if M:
        for (ox, oy, sx, sy) in [(fx, fy, 1, 1), (fx+fw, fy, -1, 1),
                                 (fx, fy+fh, 1, -1), (fx+fw, fy+fh, -1, -1)]:
            corners += (f'<path d="M{ox+sx*14},{oy+sy*14} l{sx*64},0 m{-sx*64},0 l0,{sy*64}" '
                        f'fill="none" stroke="{acc}" stroke-width="5"/>'
                        f'<circle cx="{ox+sx*30}" cy="{oy+sy*30}" r="6" fill="{acc}"/>')

    # type gem (arcane) / sigil (mythic) top-right of portrait
    gem = ""
    if not M:
        gem = (f'<circle cx="{px+pw-58}" cy="{py+58}" r="40" fill="{lighten(acc,0.2)}" stroke="#fff" stroke-width="5"/>'
               f'<circle cx="{px+pw-58}" cy="{py+58}" r="40" fill="url(#gloss)"/>')

    frame_rx = 10 if M else 34
    pw_rx    = 8 if M else 26
    sub_caps = real_name.upper()
    pf = f"{power_val}"
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400" width="1200" height="1400">
  <defs>
    <radialGradient id="port" cx="50%" cy="42%" r="75%">
      <stop offset="0%" stop-color="{g0}"/><stop offset="100%" stop-color="{g1}"/>
    </radialGradient>
    <linearGradient id="gloss" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.55"/>
      <stop offset="55%" stop-color="#ffffff" stop-opacity="0"/>
    </linearGradient>
    <linearGradient id="card" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{'#17130d' if M else '#10131b'}"/>
      <stop offset="100%" stop-color="{'#0b0907' if M else '#0a0c12'}"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="1200" height="1400" fill="{body_bg}"/>
  <rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" rx="{frame_rx}" fill="url(#card)" stroke="{frame_out}" stroke-width="6"/>
  <rect x="{fx+12}" y="{fy+12}" width="{fw-24}" height="{fh-24}" rx="{max(frame_rx-4,4)}" fill="none" stroke="{frame_in}" stroke-width="2" stroke-opacity="0.7"/>
  {corners}

  <text x="600" y="{fy+128}" font-family="{name_font}" font-size="74" font-weight="800" letter-spacing="{6 if M else 2}" text-anchor="middle" fill="{txt}">{esc(title)}</text>
  <text x="600" y="{fy+178}" font-family="{MONO}" font-size="26" letter-spacing="5" text-anchor="middle" fill="{acc}">{esc(sub_caps)}</text>

  <rect x="{px}" y="{py}" width="{pw}" height="{ph}" rx="{pw_rx}" fill="url(#port)" stroke="{frame_in}" stroke-width="4"/>
  {gem}
  {silhouette(archetype, 600, py+70, py+ph-55, fig_fill, fig_edge)}

  <text x="600" y="{py+ph+70}" font-family="{name_font}" font-size="40" font-weight="700" letter-spacing="4" text-anchor="middle" fill="{txt}">{esc(archetype.upper())}</text>
  <text x="600" y="{py+ph+112}" font-family="{MONO}" font-size="24" letter-spacing="4" text-anchor="middle" fill="{txt_dim}">{esc(aura_key.upper())} AURA &#183; {esc(power_label)} {esc(pf)}</text>

  <text x="600" y="{py+ph+170}" font-family="{MONO}" font-size="23" letter-spacing="3" text-anchor="middle" fill="{acc}">{esc(chain_label)}</text>
  <text x="600" y="{py+ph+206}" font-family="{name_font}" font-size="30" font-weight="700" letter-spacing="2" text-anchor="middle" fill="{txt}">{esc(chain_text)}</text>

  <text x="600" y="{fy+fh-86}" font-family="{name_font}" font-size="27" font-style="italic" text-anchor="middle" fill="{txt_dim}">{esc(lore)}</text>
  <text x="600" y="{fy+fh-40}" font-family="{MONO}" font-size="22" letter-spacing="6" text-anchor="middle" fill="{txt_dim}" fill-opacity="0.8">HUMAN+ &#183; MYTHOS</text>
</svg>'''

# ---------------------------------------------------------------------------
def build_data():
    """Assemble compound + evolution records, resolving evolution chains."""
    EL = {e[0]: e for e in ELEMENTS}
    # which stack each compound first evolves into
    first_evo = {}
    for s in STACKS:
        for sym in s[2]:
            first_evo.setdefault(sym, s[0])
    compounds = []
    for e in ELEMENTS:
        sym = e[0]
        if sym not in MYTHIC:
            continue
        name, arch, aura, lore = MYTHIC[sym]
        power_label = "ESSENCE" if e[3] == "PEP" else "MASS"
        compounds.append({
            "sym": sym, "title": name, "real": e[1], "arch": arch, "aura": aura,
            "lore": lore, "plabel": power_label, "pval": e[5],
            "evo": first_evo.get(sym, ""),
        })
    evolutions = []
    for s in STACKS:
        name, sub, comps, tag, extras = s
        arch, aura, lore = EVO.get(name, ("titan", "gold", tag))
        forged = " + ".join(MYTHIC[c][0].replace("THE ", "") for c in comps if c in MYTHIC)
        evolutions.append({
            "name": name, "sub": sub, "comps": comps, "arch": arch, "aura": aura,
            "lore": lore, "tag": tag, "forged": forged, "extras": extras,
        })
    return compounds, evolutions

def render(svg, png_path, bg):
    subprocess.run(["rsvg-convert", "-b", bg, "-w", "760", "-o", png_path],
                   input=svg.encode("utf-8"), check=True)

def main():
    here = os.path.dirname(os.path.abspath(__file__))
    svg_dir = os.path.join(here, "mythic_svg")
    prev_dir = os.path.join(here, "mythic_preview")
    os.makedirs(svg_dir, exist_ok=True)
    os.makedirs(prev_dir, exist_ok=True)

    compounds, evolutions = build_data()
    made = 0
    for c in compounds:
        chain = ("EVOLVES INTO", c["evo"]) if c["evo"] else ("BASE FORM", "—")
        for style in ("mythic", "arcane"):
            svg = card(c["title"], c["real"], c["arch"], c["aura"], c["lore"],
                       c["plabel"], c["pval"], chain[0], chain[1], style)
            base = f"c_{c['sym']}_{style}"
            with open(os.path.join(svg_dir, base + ".svg"), "w") as f:
                f.write(svg)
            render(svg, os.path.join(prev_dir, base + ".png"),
                   "#0c0a08" if style == "mythic" else "#0f1118")
            made += 1
    for e in evolutions:
        for style in ("mythic", "arcane"):
            svg = card(e["name"], e["sub"], e["arch"], e["aura"], e["lore"],
                       "TIER", len(e["comps"]), "FORGED FROM", e["forged"], style)
            base = f"e_{e['name'].replace(' ', '_')}_{style}"
            with open(os.path.join(svg_dir, base + ".svg"), "w") as f:
                f.write(svg)
            render(svg, os.path.join(prev_dir, base + ".png"),
                   "#0c0a08" if style == "mythic" else "#0f1118")
            made += 1

    # embed data for the live page
    db = {
        "compounds": [{"sym": c["sym"], "title": c["title"], "real": c["real"],
                       "arch": c["arch"], "aura": c["aura"], "lore": c["lore"],
                       "plabel": c["plabel"], "pval": c["pval"], "evo": c["evo"]}
                      for c in compounds],
        "evolutions": [{"name": e["name"], "sub": e["sub"], "comps": e["comps"],
                        "arch": e["arch"], "aura": e["aura"], "lore": e["lore"],
                        "tag": e["tag"], "forged": e["forged"], "extras": e["extras"]}
                       for e in evolutions],
        "auras": AURAS,
    }
    from mythic_template import MYTHIC_TEMPLATE, HOME_TEMPLATE
    html = MYTHIC_TEMPLATE.replace("/*__DATA__*/", json.dumps(db))
    with open(os.path.join(here, "mythic.html"), "w") as f:
        f.write(html)
    with open(os.path.join(here, "home.html"), "w") as f:
        f.write(HOME_TEMPLATE)

    print(f"MYTHOS: {made} card PNGs ({len(compounds)} compounds + {len(evolutions)} evolutions, 2 styles)")
    print("Built mythic.html + home.html")

if __name__ == "__main__":
    main()
