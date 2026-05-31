#!/usr/bin/env python3
"""
HUMAN+  —  Periodic Table of Enhancement
Vector tile generator for the t-shirt line.

Edit the ELEMENTS table below, then run:
    python3 generate_tiles.py
Outputs print-ready SVGs to ./svg and PNG previews to ./preview.

DESIGN NOTES
------------
- Every tile is 1200 x 1400 px = a 12in x 14in print area at 100 DPI.
- Artwork is WHITE + ONE ACCENT on a TRANSPARENT background (built for a dark
  garment). Previews are rendered on near-black so you can see them.
- Big symbol is ALWAYS a 2-letter code so every tile reads the same from across
  a room (true periodic-table feel). Recognizability comes from the full name
  spelled out underneath + the number in the top-left.
- Two families:
    PEPTIDE  -> top-left = the number already in the name (157, 500, 141) when it
                has one, else the amino-acid count; top-right = amino-acid count.
                Accent = mint green.
    HORMONE  -> steroids/small molecules numbered by MOLECULAR WEIGHT (g/mol).
                Accent = amber/gold.
- Fonts here are DejaVu/Liberation (Helvetica-like + a mono) so previews render
  on this box. For final print, swap to a licensed grotesque (Neue Haas / Helvetica
  Now / Space Grotesk) and a mono (JetBrains Mono) and OUTLINE the text.
"""

import os, subprocess

# ----------------------------------------------------------------------------
# THE ELEMENT TABLE
# (sym, full_name, sub, family, name_num, count, tagline, formula)
#   sym       = 2-letter code shown big in the tile center
#   full_name = spelled-out compound name shown below the symbol
#   family    = "PEP" peptide (count = amino acids) | "HOR" hormone (count = g/mol)
#   name_num  = the number already in the name ("157","500","141"); "" if none
#   count     = amino-acid count (PEP) or molecular weight in g/mol (HOR)
#   formula   = chemical formula (HOR) or "" (PEP)
# ----------------------------------------------------------------------------
ELEMENTS = [
    # --- PEPTIDE FAMILY ---
    ("Gh", "Somatropin",     "Human Growth Hormone",  "PEP", "",     191, "GROW OR DIE",            ""),
    ("Bp", "BPC-157",        "Body Protection Cmpd",  "PEP", "157",  15,  "THE BODY'S REPAIR CODE", ""),
    ("Tb", "TB-500",         "Thymosin Beta-4",       "PEP", "500",  43,  "HEAL WITHOUT PERMISSION",""),
    ("Sg", "Semaglutide",    "GLP-1 Agonist",         "PEP", "",     31,  "APPETITE, OVERRULED",    ""),
    ("Tz", "Tirzepatide",    "GIP / GLP-1",           "PEP", "",     39,  "DUAL-ACTION OVERRIDE",   ""),
    ("Re", "Retatrutide",    "GIP / GLP-1 / Glucagon","PEP", "",     39,  "TRIPLE THREAT",          ""),
    ("Ip", "Ipamorelin",     "GH Secretagogue",       "PEP", "",     5,   "CLEAN PULSE",            ""),
    ("Cj", "CJC-1295",       "GHRH Analog",           "PEP", "1295", 29,  "SUSTAINED SIGNAL",       ""),
    ("Sr", "Sermorelin",     "GRF (1-29)",            "PEP", "",     29,  "WAKE THE PITUITARY",     ""),
    ("Tm", "Tesamorelin",    "GHRH Analog",           "PEP", "",     44,  "CUT THE VISCERAL",       ""),
    ("Gk", "GHK-Cu",         "Copper Tripeptide",     "PEP", "",     3,   "COPPER-BOUND RENEWAL",   ""),
    ("Mt", "Melanotan II",   "Melanocortin Agonist",  "PEP", "II",   7,   "SUN IN A VIAL",          ""),
    ("Pt", "PT-141",         "Bremelanotide",         "PEP", "141",  7,   "DESIRE, DECODED",        ""),
    ("Ox", "Oxytocin",       "Nonapeptide",           "PEP", "",     9,   "THE BOND MOLECULE",      ""),
    ("Sk", "Selank",         "Anxiolytic Peptide",    "PEP", "",     7,   "CALM, WEAPONIZED",       ""),
    ("Sx", "Semax",          "Nootropic Peptide",     "PEP", "",     7,   "FOCUS PROTOCOL",         ""),
    ("Ep", "Epitalon",       "Telomerase Activator",  "PEP", "",     4,   "RESET THE CLOCK",        ""),
    ("Ta", "Thymosin a-1",   "Immune Modulator",      "PEP", "1",    28,  "IMMUNE FIRMWARE",        ""),
    ("Ig", "IGF-1 LR3",      "Long R3 IGF-1",         "PEP", "1",    83,  "GROWTH, AMPLIFIED",      ""),
    ("Mc", "MOTS-c",         "Mitochondrial Peptide", "PEP", "c",    16,  "MITOCHONDRIAL COMMAND",  ""),
    ("Gn", "Gonadorelin",    "GnRH Decapeptide",      "PEP", "",     10,  "RESTART THE AXIS",       ""),
    ("Ks", "Kisspeptin-10",  "KISS1 Fragment",        "PEP", "10",   10,  "IGNITE THE CASCADE",     ""),
    ("Hx", "Hexarelin",      "GH Secretagogue",       "PEP", "",     6,   "MAX PULSE",              ""),
    ("Gp", "GHRP-6",         "GH-Releasing Peptide",  "PEP", "6",    6,   "HUNGER + GROWTH",        ""),
    ("Ad", "AOD-9604",       "hGH Fragment 176-191",  "PEP", "9604", 16,  "FAT-LOSS FRAGMENT",      ""),
    ("Ss", "SS-31",          "Elamipretide",          "PEP", "31",   4,   "MITOCHONDRIAL ARMOR",    ""),
    ("Kp", "KPV",            "a-MSH Fragment",        "PEP", "",     3,   "INFLAMMATION OFF",       ""),
    ("Ds", "DSIP",           "Delta Sleep Peptide",   "PEP", "",     9,   "DELTA SLEEP",            ""),
    ("In", "Insulin",        "A21 / B30 Chains",      "PEP", "",     51,  "THE MASTER SWITCH",      ""),
    # --- HORMONE / STEROID FAMILY : numbered by molecular weight (g/mol) ---
    ("Te", "Testosterone",   "Androgen",             "HOR", "", 288, "THE ORIGINAL UPGRADE", "C19H28O2"),
    ("Nd", "Nandrolone",     "19-Nortestosterone",   "HOR", "", 274, "JOINTS OF STEEL",      "C18H26O2"),
    ("Tr", "Trenbolone",     "Androgen",             "HOR", "", 270, "NO COMPROMISE",        "C18H22O2"),
    ("An", "Anavar",         "Oxandrolone",          "HOR", "", 306, "THE CUT",              "C19H30O3"),
    ("Ms", "Masteron",       "Drostanolone",         "HOR", "", 304, "HARD & DRY",           "C20H32O2"),
    ("Pr", "Primobolan",     "Methenolone",          "HOR", "", 302, "LEAN TISSUE, KEPT",    "C20H30O2"),
    ("Es", "Estradiol",      "Estrogen",             "HOR", "", 272, "BALANCE THE EQUATION", "C18H24O2"),
    ("Dh", "DHEA",           "Adrenal Precursor",    "HOR", "", 288, "THE PRECURSOR",        "C19H28O2"),
    ("T3", "Liothyronine",   "Thyroid T3",           "HOR", "", 651, "THROTTLE THE FURNACE", "C15H12I3NO4"),
    ("Ml", "Melatonin",      "Pineal Hormone",       "HOR", "", 232, "LIGHTS OUT",           "C13H16N2O2"),
]

# Curated stacks: (name, subtitle, [component symbols], tagline)
STACKS = [
    ("WOLVERINE", "Regeneration Protocol",   ["Bp", "Tb"],             "REGENERATE EVERYTHING"),
    ("GLOW",      "Skin / Hair / Recovery",  ["Gk", "Bp", "Tb"],       "FROM THE INSIDE OUT"),
    ("KLOW",      "Full Repair Protocol",    ["Kp", "Gk", "Bp", "Tb"], "THE COMPLETE OVERHAUL"),
]
STACK_COLORS = ["#2BE8B0", "#7C5CFC", "#FF5C8A", "#38BDF8", "#FFB020"]

# ----------------------------------------------------------------------------
PALETTE = {
    "PEP": "#2BE8B0",   # electric mint  (peptides)
    "HOR": "#FFB020",   # amber/gold     (hormones/steroids)
}
WHITE = "#FFFFFF"
BG_PREVIEW = "#0d0d12"  # near-black garment for previews

SANS = "DejaVu Sans, Liberation Sans, Arial, sans-serif"
MONO = "DejaVu Sans Mono, Liberation Mono, monospace"


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def hero_tile(sym, full, sub, fam, name_num, count, tagline, formula):
    """One large element tile, centered, 1200x1400, transparent bg. 2-letter symbol."""
    acc = PALETTE[fam]
    tx, ty, tw, th = 200, 360, 800, 800
    cx = tx + tw / 2

    # ---- top corners ----
    if fam == "PEP":
        if name_num:
            tl_big, tl_label = name_num, "SERIES"
            tr = f'''<text x="{tx+tw-45}" y="{ty+62}" font-family="{MONO}" font-size="28" letter-spacing="3"
        text-anchor="end" fill="{WHITE}" fill-opacity="0.6">AMINO ACIDS</text>
  <text x="{tx+tw-45}" y="{ty+128}" font-family="{MONO}" font-size="64" font-weight="700"
        text-anchor="end" fill="{acc}">{count}</text>'''
        else:
            tl_big, tl_label = str(count), "AMINO ACIDS"
            tr = f'''<text x="{tx+tw-45}" y="{ty+62}" font-family="{MONO}" font-size="28" letter-spacing="4"
        text-anchor="end" fill="{WHITE}" fill-opacity="0.6">PEPTIDE</text>'''
    else:  # HOR
        tl_big, tl_label = str(count), "g/mol"
        tr = f'''<text x="{tx+tw-45}" y="{ty+62}" font-family="{MONO}" font-size="28" letter-spacing="4"
        text-anchor="end" fill="{WHITE}" fill-opacity="0.6">HORMONE</text>
  <text x="{tx+tw-45}" y="{ty+118}" font-family="{SANS}" font-size="34" letter-spacing="1"
        text-anchor="end" fill="{acc}">{esc(formula)}</text>'''

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400" width="1200" height="1400">
  <!-- HUMAN+ tile : {esc(full)} -->
  <text x="600" y="190" font-family="{SANS}" font-size="92" font-weight="800"
        text-anchor="middle" letter-spacing="6" fill="{WHITE}">HUMAN<tspan fill="{acc}">+</tspan></text>
  <text x="600" y="240" font-family="{MONO}" font-size="26" text-anchor="middle"
        letter-spacing="8" fill="{WHITE}" fill-opacity="0.45">THE PERIODIC TABLE OF ENHANCEMENT</text>

  <rect x="{tx}" y="{ty}" width="{tw}" height="{th}" rx="20" fill="none" stroke="{acc}" stroke-width="10"/>
  <line x1="{tx}" y1="{ty+150}" x2="{tx+tw}" y2="{ty+150}" stroke="{acc}" stroke-width="3" stroke-opacity="0.4"/>

  <!-- top-left number -->
  <text x="{tx+45}" y="{ty+108}" font-family="{MONO}" font-size="84" font-weight="700" fill="{acc}">{tl_big}</text>
  <text x="{tx+48}" y="{ty+145}" font-family="{MONO}" font-size="28" letter-spacing="3" fill="{WHITE}" fill-opacity="0.6">{tl_label}</text>

  <!-- top-right -->
  {tr}

  <!-- giant 2-letter symbol (raised so descenders like p/g/y never hit the name) -->
  <text x="{cx}" y="{ty+460}" font-family="{SANS}" font-size="340" font-weight="800"
        text-anchor="middle" fill="{WHITE}">{esc(sym)}</text>

  <!-- full name -->
  <text x="{cx}" y="{ty+665}" font-family="{SANS}" font-size="74" font-weight="800"
        text-anchor="middle" fill="{acc}">{esc(full)}</text>
  <text x="{cx}" y="{ty+712}" font-family="{SANS}" font-size="33" letter-spacing="2"
        text-anchor="middle" fill="{WHITE}" fill-opacity="0.7">{esc(sub.upper())}</text>

  <!-- tagline -->
  <text x="{cx}" y="{ty+772}" font-family="{MONO}" font-size="33" font-weight="700" letter-spacing="6"
        text-anchor="middle" fill="{WHITE}">{esc(tagline)}</text>

  <text x="600" y="1300" font-family="{MONO}" font-size="28" letter-spacing="4"
        text-anchor="middle" fill="{WHITE}" fill-opacity="0.4">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
</svg>'''
    return svg


def modified_human():
    """The 'Factory Default -> Human+' two-tile concept."""
    acc = "#2BE8B0"
    grey = "#6b6b78"
    def tile(x, sym, label, subtitle, color, glow):
        g = 'filter="url(#glow)"' if glow else ''
        fs = 150 if len(sym) <= 2 else 120
        return f'''
  <rect x="{x}" y="500" width="380" height="420" rx="18" fill="none" stroke="{color}" stroke-width="9" {g}/>
  <text x="{x+30}" y="575" font-family="{MONO}" font-size="40" fill="{color}">{'00' if not glow else '01'}</text>
  <text x="{x+190}" y="745" font-family="{SANS}" font-size="{fs}" font-weight="800" text-anchor="middle" fill="{color}">{sym}</text>
  <text x="{x+190}" y="850" font-family="{SANS}" font-size="38" font-weight="700" text-anchor="middle" fill="{color}">{label}</text>
  <text x="{x+190}" y="895" font-family="{MONO}" font-size="22" letter-spacing="2" text-anchor="middle" fill="{color}" fill-opacity="0.7">{subtitle}</text>'''
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400" width="1200" height="1400">
  <defs>
    <filter id="glow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="9" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <text x="600" y="300" font-family="{SANS}" font-size="100" font-weight="800" text-anchor="middle" letter-spacing="6" fill="{WHITE}">HUMAN<tspan fill="{acc}">+</tspan></text>
  <text x="600" y="370" font-family="{MONO}" font-size="30" text-anchor="middle" letter-spacing="6" fill="{WHITE}" fill-opacity="0.5">FACTORY DEFAULT IS NOT FINAL</text>
  {tile(150, "Hs", "Homo sapiens", "FACTORY DEFAULT", grey, False)}
  <text x="600" y="730" font-family="{SANS}" font-size="120" font-weight="800" text-anchor="middle" fill="{acc}">&#8594;</text>
  {tile(670, "Hs+", "Homo sapiens +", "MODIFIED EDITION", acc, True)}
  <text x="600" y="1080" font-family="{MONO}" font-size="34" letter-spacing="8" text-anchor="middle" fill="{WHITE}">UPGRADE THE OPERATOR</text>
</svg>'''


def periodic_poster():
    """Full table laid out as a grid poster, two families color-coded.
    All symbols are 2 letters so the grid reads uniformly."""
    cols = 6
    cell_w, cell_h = 170, 190
    pad = 14
    margin_x, margin_y = 90, 360
    cells = []
    for i, (sym, full, sub, fam, name_num, count, tag, formula) in enumerate(ELEMENTS):
        r, c = divmod(i, cols)
        x = margin_x + c * (cell_w + pad)
        y = margin_y + r * (cell_h + pad)
        acc = PALETTE[fam]
        if fam == "PEP":
            tl = name_num if name_num else str(count)
            tr = f"{count}aa"
        else:
            tl = str(count)
            tr = "g/mol"
        cells.append(f'''
  <g>
    <rect x="{x}" y="{y}" width="{cell_w}" height="{cell_h}" rx="10" fill="none" stroke="{acc}" stroke-width="4"/>
    <text x="{x+14}" y="{y+40}" font-family="{MONO}" font-size="26" fill="{acc}">{tl}</text>
    <text x="{x+cell_w-12}" y="{y+34}" font-family="{MONO}" font-size="16" text-anchor="end" fill="{WHITE}" fill-opacity="0.5">{tr}</text>
    <text x="{x+cell_w/2}" y="{y+118}" font-family="{SANS}" font-size="78" font-weight="800" text-anchor="middle" fill="{WHITE}">{esc(sym)}</text>
    <text x="{x+cell_w/2}" y="{y+162}" font-family="{SANS}" font-size="18" font-weight="700" text-anchor="middle" fill="{acc}">{esc(full)}</text>
  </g>''')
    rows = (len(ELEMENTS) + cols - 1) // cols
    height = margin_y + rows * (cell_h + pad) + 200
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 {height}" width="1200" height="{height}">
  <text x="600" y="170" font-family="{SANS}" font-size="120" font-weight="800" text-anchor="middle" letter-spacing="6" fill="{WHITE}">HUMAN<tspan fill="{PALETTE['PEP']}">+</tspan></text>
  <text x="600" y="240" font-family="{MONO}" font-size="30" text-anchor="middle" letter-spacing="10" fill="{WHITE}" fill-opacity="0.6">THE PERIODIC TABLE OF ENHANCEMENT</text>
  <rect x="330" y="285" width="26" height="26" rx="5" fill="none" stroke="{PALETTE['PEP']}" stroke-width="4"/>
  <text x="368" y="306" font-family="{MONO}" font-size="24" fill="{WHITE}" fill-opacity="0.8">PEPTIDE (amino acids)</text>
  <rect x="730" y="285" width="26" height="26" rx="5" fill="none" stroke="{PALETTE['HOR']}" stroke-width="4"/>
  <text x="768" y="306" font-family="{MONO}" font-size="24" fill="{WHITE}" fill-opacity="0.8">HORMONE (g/mol)</text>
  {''.join(cells)}
  <text x="600" y="{height-60}" font-family="{MONO}" font-size="26" letter-spacing="6" text-anchor="middle" fill="{WHITE}" fill-opacity="0.4">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
</svg>'''


def stack_tile(name, subtitle, comps, tagline):
    """A combined 'stack' tile: big name + a row of component mini element-tiles."""
    lut = {e[0]: e for e in ELEMENTS}
    n = len(comps)
    bw, gap = 230, 34
    total = n * bw + (n - 1) * gap
    start = 600 - total / 2
    box_y, box_h = 640, 300
    minis = []
    stops = []
    for i, csym in enumerate(comps):
        e = lut[csym]
        col = STACK_COLORS[i % len(STACK_COLORS)]
        x = start + i * (bw + gap)
        cxm = x + bw / 2
        stops.append(f'<stop offset="{int(i*100/(max(n-1,1)))}%" stop-color="{col}"/>')
        minis.append(f'''
  <rect x="{x}" y="{box_y}" width="{bw}" height="{box_h}" rx="14" fill="none" stroke="{col}" stroke-width="7"/>
  <text x="{cxm}" y="{box_y+150}" font-family="{SANS}" font-size="120" font-weight="800" text-anchor="middle" fill="{WHITE}">{esc(e[0])}</text>
  <text x="{cxm}" y="{box_y+215}" font-family="{SANS}" font-size="30" font-weight="700" text-anchor="middle" fill="{col}">{esc(e[1])}</text>
  <text x="{cxm}" y="{box_y+258}" font-family="{MONO}" font-size="22" text-anchor="middle" fill="{WHITE}" fill-opacity="0.6">{e[5]}{'aa' if e[3]=='PEP' else ''}</text>''')
        if i < n - 1:
            plus_x = x + bw + gap / 2
            minis.append(f'<text x="{plus_x}" y="{box_y+box_h/2+22}" font-family="{SANS}" font-size="70" font-weight="800" text-anchor="middle" fill="{WHITE}" fill-opacity="0.5">+</text>')
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400" width="1200" height="1400">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="0">{''.join(stops)}</linearGradient></defs>
  <text x="600" y="180" font-family="{SANS}" font-size="80" font-weight="800" text-anchor="middle" letter-spacing="6" fill="{WHITE}">HUMAN<tspan fill="{STACK_COLORS[0]}">+</tspan></text>
  <text x="600" y="230" font-family="{MONO}" font-size="24" text-anchor="middle" letter-spacing="6" fill="{WHITE}" fill-opacity="0.45">STACK SERIES</text>
  <text x="600" y="420" font-family="{SANS}" font-size="200" font-weight="800" text-anchor="middle" fill="url(#g)">{esc(name)}</text>
  <text x="600" y="500" font-family="{MONO}" font-size="34" letter-spacing="6" text-anchor="middle" fill="{WHITE}" fill-opacity="0.75">{esc(subtitle.upper())}</text>
  {''.join(minis)}
  <text x="600" y="1080" font-family="{MONO}" font-size="40" font-weight="700" letter-spacing="8" text-anchor="middle" fill="{WHITE}">{esc(tagline)}</text>
  <text x="600" y="1320" font-family="{MONO}" font-size="26" letter-spacing="4" text-anchor="middle" fill="{WHITE}" fill-opacity="0.4">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
</svg>'''


def build_gallery(prev_dir, names):
    """Write a responsive index.html so all tiles are reviewable on any device."""
    cards = "\n".join(
        f'    <figure><img src="preview/{n}.png" alt="{n}" loading="lazy"><figcaption>{n}</figcaption></figure>'
        for n in names)
    return f'''<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HUMAN+ — Design Gallery</title>
<style>
  body {{ margin:0; background:#0d0d12; color:#e2e2f0; font-family:system-ui,sans-serif; }}
  header {{ padding:24px; text-align:center; }}
  h1 {{ font-size:2rem; margin:0; }} h1 span {{ color:#2BE8B0; }}
  p.sub {{ color:#9393b0; letter-spacing:3px; font-size:.8rem; }}
  .grid {{ display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:16px; padding:16px; max-width:1600px; margin:0 auto; }}
  figure {{ margin:0; background:#1a1a24; border:1px solid #2e2e4a; border-radius:12px; overflow:hidden; }}
  img {{ width:100%; display:block; }}
  figcaption {{ padding:8px 12px; font-size:.75rem; color:#9393b0; font-family:monospace; }}
</style></head><body>
<header><h1>HUMAN<span>+</span></h1><p class="sub">THE PERIODIC TABLE OF ENHANCEMENT — DESIGN GALLERY</p></header>
<div class="grid">
{cards}
</div></body></html>'''


def render_png(svg_path, png_path, bg=BG_PREVIEW):
    subprocess.run(["rsvg-convert", "-b", bg, "-w", "900", "-o", png_path, svg_path], check=True)


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    svg_dir = os.path.join(here, "svg")
    prev_dir = os.path.join(here, "preview")
    os.makedirs(svg_dir, exist_ok=True)
    os.makedirs(prev_dir, exist_ok=True)

    made = []
    # every compound gets its own hero tile
    for el in ELEMENTS:
        sym = el[0]
        svg = hero_tile(*el)
        base = f"tile_{sym}_{el[1].replace(' ', '').replace('/', '-')}"
        sp = os.path.join(svg_dir, base + ".svg")
        with open(sp, "w") as f:
            f.write(svg)
        render_png(sp, os.path.join(prev_dir, base + ".png"))
        made.append(base)

    # stack tiles
    for name, subtitle, comps, tagline in STACKS:
        svg = stack_tile(name, subtitle, comps, tagline)
        base = f"stack_{name}"
        sp = os.path.join(svg_dir, base + ".svg")
        with open(sp, "w") as f:
            f.write(svg)
        render_png(sp, os.path.join(prev_dir, base + ".png"))
        made.append(base)

    # concept + poster
    for name, fn in [("concept_HumanPlus", modified_human), ("poster_PeriodicTable", periodic_poster)]:
        sp = os.path.join(svg_dir, name + ".svg")
        with open(sp, "w") as f:
            f.write(fn())
        render_png(sp, os.path.join(prev_dir, name + ".png"))
        made.append(name)

    # gallery for multi-device review
    order = [n for n in made if n.startswith("poster")] + \
            [n for n in made if n.startswith("stack")] + \
            [n for n in made if n.startswith("concept")] + \
            [n for n in made if n.startswith("tile")]
    with open(os.path.join(here, "index.html"), "w") as f:
        f.write(build_gallery(prev_dir, order))

    print(f"Generated {len(made)} designs + index.html")


if __name__ == "__main__":
    main()
