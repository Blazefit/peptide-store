#!/usr/bin/env python3
"""
HUMAN+  —  Periodic Table of Enhancement
Vector tile generator for the t-shirt line.

Edit the ELEMENTS table below, then run:
    python3 generate_tiles.py
Outputs print-ready SVGs to ./svg and PNG previews to ./preview.
Also writes high-res, transparent, Printful-ready PNGs to ./print (dark
garment) and ./print/light (white ink swapped to near-black for light garments).

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

import os, re, subprocess, json
from site_template import SITE_TEMPLATE

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
    ("Hc", "HCG",            "Chorionic Gonadotropin","PEP", "",     237, "KEEP THE SIGNAL LIVE",   ""),
    # --- HORMONE FAMILY : numbered by molecular weight (g/mol) ---
    #     Curated for POD sale to FDA-APPROVED anabolics + NON-controlled hormones,
    #     using GENERIC (non-trademarked) names only:
    #       - Testosterone, Nandrolone, Oxandrolone are FDA-approved anabolic
    #         steroids. NOTE: anabolic steroids are still Schedule III controlled
    #         substances even when FDA-approved, so these carry some POD review risk.
    #       - Estradiol, DHEA, Liothyronine (T3), Melatonin are non-controlled.
    #     DROPPED (never FDA-approved for human use): Trenbolone, Masteron
    #     (Drostanolone), Primobolan (Methenolone). Brand names (Anavar, etc.)
    #     renamed to generic to avoid trademark exposure.
    ("Te", "Testosterone",   "Androgen",             "HOR", "", 288, "THE ORIGINAL UPGRADE", "C19H28O2"),
    ("Nd", "Nandrolone",     "19-Nortestosterone",   "HOR", "", 274, "JOINTS OF STEEL",      "C18H26O2"),
    ("Oa", "Oxandrolone",    "Anabolic Steroid",     "HOR", "", 306, "THE CUT",              "C19H30O3"),
    ("Es", "Estradiol",      "Estrogen",             "HOR", "", 272, "BALANCE THE EQUATION", "C18H24O2"),
    ("Dh", "DHEA",           "Adrenal Precursor",    "HOR", "", 288, "THE PRECURSOR",        "C19H28O2"),
    ("T3", "Liothyronine",   "Thyroid T3",           "HOR", "", 651, "THROTTLE THE FURNACE", "C15H12I3NO4"),
    ("Ml", "Melatonin",      "Pineal Hormone",       "HOR", "", 232, "LIGHTS OUT",           "C13H16N2O2"),
    # --- MOLECULE FAMILY : metabolic cofactors / small-molecule nootropics, by g/mol ---
    ("Mg", "Magnesium",      "Essential Mineral",    "MOL", "", 24,  "THE SPARK PLUG",      "Mg"),
    ("Na", "NAD+",           "Nicotinamide Dinucl.", "MOL", "", 663, "CELLULAR CURRENCY",    "C21H27N7O14P2"),
    ("Mq", "5-Amino-1MQ",    "NNMT Inhibitor",       "MOL", "", 159, "DELETE THE FAT GENE",  "C10H11N2"),
    ("Mb", "Methylene Blue", "Methylthioninium",     "MOL", "", 320, "ELECTRON DONOR",       "C16H18ClN3S"),
]

# Curated stacks: (name, subtitle, [component symbols], tagline, extras)
#   comps  = element symbols rendered as mini element-tiles (must exist in ELEMENTS)
#   extras = supportive ingredients with no element tile (supplements, blends),
#            shown as a small "+ ..." line under the tiles. "" if none.
STACKS = [
    # --- Recovery / repair ---
    ("WOLVERINE",       "Recovery / Repair",   ["Bp", "Tb"],             "REGENERATE EVERYTHING",  ""),
    ("ADAMANTIUM",      "Recovery / Repair",   ["Bp", "Tb", "Kp", "Gk"], "UNBREAKABLE",            ""),
    ("SPARTAN",         "Recovery / Repair",   ["Bp", "Tb", "Cj", "Ip"], "NO RETREAT",             ""),
    ("FIELD REPAIR",    "Recovery / Repair",   ["Bp", "Gk"],             "PATCH AND DEPLOY",       ""),
    ("PHOENIX",         "Recovery / Repair",   ["Ep", "Na", "Bp", "Tb"], "RISE FROM THE ASHES",    ""),
    # --- Hormone-base performance ---
    ("THE FOUNDATION",  "Hormone Performance", ["Te", "Hc"],             "BUILT ON BEDROCK",       "estrogen management"),
    ("WORKHORSE",       "Hormone Performance", ["Te", "Gh"],             "SHOW UP EVERY DAY",      ""),
    ("PRIME",           "Hormone Performance", ["Te", "Gh", "Hc"],       "PEAK CONDITION",         ""),
    # --- Advanced body composition ---
    ("THE HOLY TRINITY","Body Composition",    ["Te", "Gh", "Re"],       "THREE IS ALL YOU NEED",  ""),
    ("THE OVERHAUL",    "Recomp / Repair",     ["Gh", "Re", "Kl"],       "REBUILD FROM SCRATCH",   ""),
    ("BLACK LABEL",     "Body Composition",    ["Te", "Gh", "Ig", "Re"], "TOP SHELF ONLY",         "KLOW blend"),
    ("OLD GUARD",       "Body Composition",    ["Te", "Nd", "Gh", "Re"], "EARNED NOT GIVEN",       "KLOW blend"),
    ("GREEK GOD",       "Body Composition",    ["Te", "Gh", "Cj"],       "CARVED FROM MARBLE",     "GH peptide support"),
    ("MASS MONSTER",    "Body Composition",    ["Te", "Gh", "Ig"],       "MAXIMUM OVERLOAD",       ""),
    ("SHREDDER",        "Body Composition",    ["Te", "Sg", "Gh", "Re"], "SHRINK-WRAPPED",         ""),
    # --- Cognitive / nootropic ---
    ("STOIC",           "Cognitive / Nootropic",["Sk"],                  "UNSHAKEABLE",            "adaptogen + nootropic support"),
    ("LIMITLESS",       "Cognitive / Nootropic",["Sx", "Mb"],            "NO CEILING",             "nootropic support"),
    ("LOCK IN",         "Cognitive / Nootropic",["Sx"],                  "TUNNEL VISION",          "caffeine + L-theanine + tyrosine"),
    ("IRON MIND",       "Cognitive / Nootropic",["Sk"],                  "FORGE THE MIND",         "Lion's Mane + Rhodiola + Bacopa"),
    ("CLEAR HEAD",      "Cognitive / Nootropic",["Sk", "Mg"],            "SIGNAL NO NOISE",        "L-theanine"),
    ("GAME DAY",        "Cognitive / Nootropic",["Sx"],                  "GO TIME",                "performance nootropic support"),
    # --- Mito / longevity / aesthetic ---
    ("REACTOR",         "Mito / Longevity",    ["Ss", "Mc"],             "POWER THE CORE",         ""),
    ("OVERDRIVE",       "Mito / Longevity",    ["Mc", "Mq", "Na"],       "REDLINE THE ENGINE",     ""),
    ("SHOWTIME",        "Mito / Aesthetic",    ["Gk", "Mt"],             "STEAL THE STAGE",        "aesthetic support"),
    ("THE VAULT",       "Mito / Longevity",    ["Mc", "Ss", "Na"],       "LOCK IN LONGEVITY",      ""),
    # --- Sexual health / hormone axis ---
    ("LIBIDO",          "Hormone Performance", ["Pt", "Ox", "Ks"],       "DESIRE UNCHAINED",       ""),
    ("THE CATALYST",    "Hormone Performance", ["Gn", "Hc"],             "FIRE THE AXIS",          ""),
    ("EQUILIBRIUM",     "Hormone Performance", ["Es", "Dh"],             "BALANCE RESTORED",       ""),
    # --- Sleep / skin / gut / immune ---
    ("SANDMAN",         "Recovery / Sleep",    ["Ds", "Ep", "Ml"],       "INTO THE DEEP",          ""),
    ("BRONZED",         "Skin / Recovery",     ["Mt", "Gk"],             "SUN-FORGED",             ""),
    ("GUT CHECK",       "Gut / Repair",        ["Kp", "Bp"],             "SEAL THE LINING",        ""),
    ("FORTRESS",        "Immune / Repair",     ["Ta", "Bp"],             "HOLD THE WALL",          ""),
    # --- GH-peptide secretagogue combos ---
    ("SECRETAGOGUE",    "Body Composition",    ["Sr", "Gp"],             "WAKE THE GLAND",         ""),
    ("PULSE WAVE",      "Body Composition",    ["Hx", "Ip"],             "MAX AMPLITUDE",          ""),
    ("VISCERAL",        "Body Composition",    ["Tm", "Ad"],             "BURN THE CORE",          ""),
    ("THE LADDER",      "Body Composition",    ["Sr", "Tm", "Cj"],       "CLIMB THE AXIS",         ""),
    ("METABOLIC",       "Body Composition",    ["Tz", "T3"],             "FURNACE ONLINE",         ""),
]
STACK_COLORS = ["#2BE8B0", "#7C5CFC", "#FF5C8A", "#38BDF8", "#FFB020"]

# Blend tiles: a "stack within a tile". Each is selectable like a single compound
# but expands to several. Symbol is TWO CAPITAL letters so it reads as a blend
# (KL, WO, GL) vs a normal element (Bp, Te). Used to keep big stacks from getting
# scrunched: e.g. GH + Reta + KLOW = 3 tiles instead of 6.
# (sym, full, subtitle, [component symbols], accent, tagline)
BLENDS = [
    ("Kl", "KLOW",      "Full Repair Blend", ["Bp", "Tb", "Gk", "Kp"], "#3FA7B8", "THE COMPLETE OVERHAUL"),
    ("Wo", "WOLVERINE", "Recovery / Repair", ["Bp", "Tb"],             "#6E7B8C", "REGENERATE EVERYTHING"),
    ("Gl", "GLOW",      "Skin / Hair / Recovery", ["Gk", "Bp", "Tb"],  "#2BE8B0", "FROM THE INSIDE OUT"),
]
BLEND_SYMS = {b[0] for b in BLENDS}

# ----------------------------------------------------------------------------
PALETTE = {
    "PEP": "#2BE8B0",   # electric mint  (peptides)
    "HOR": "#FFB020",   # amber/gold     (hormones/steroids)
    "MOL": "#7C5CFC",   # electric violet (metabolic cofactors / small molecules)
}
BRAND_GREEN = "#2BE8B0"  # the HUMAN+ logo "+" color; used for stack "+" separators
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
            tr = f'''<text x="{tx+tw-45}" y="{ty+58}" font-family="{MONO}" font-size="28" letter-spacing="3"
        text-anchor="end" fill="{WHITE}" fill-opacity="0.6">AMINO ACIDS</text>
  <text x="{tx+tw-45}" y="{ty+126}" font-family="{MONO}" font-size="62" font-weight="700"
        text-anchor="end" fill="{acc}">{count}</text>'''
        else:
            tl_big, tl_label = str(count), "AMINO ACIDS"
            tr = f'''<text x="{tx+tw-45}" y="{ty+58}" font-family="{MONO}" font-size="28" letter-spacing="4"
        text-anchor="end" fill="{WHITE}" fill-opacity="0.6">PEPTIDE</text>'''
    else:  # HOR or MOL : numbered by molecular weight
        tl_big, tl_label = str(count), "g/mol"
        fam_word = "HORMONE" if fam == "HOR" else "MOLECULE"
        tr = f'''<text x="{tx+tw-45}" y="{ty+58}" font-family="{MONO}" font-size="28" letter-spacing="4"
        text-anchor="end" fill="{WHITE}" fill-opacity="0.6">{fam_word}</text>
  <text x="{tx+tw-45}" y="{ty+120}" font-family="{SANS}" font-size="34" letter-spacing="1"
        text-anchor="end" fill="{acc}">{esc(formula)}</text>'''

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400" width="1200" height="1400">
  <!-- HUMAN+ tile : {esc(full)} -->
  <text x="600" y="190" font-family="{SANS}" font-size="92" font-weight="800"
        text-anchor="middle" letter-spacing="6" fill="{WHITE}">HUMAN<tspan fill="{acc}">+</tspan></text>
  <text x="600" y="240" font-family="{MONO}" font-size="26" text-anchor="middle"
        letter-spacing="8" fill="{WHITE}" fill-opacity="0.45">THE PERIODIC TABLE OF ENHANCEMENT</text>

  <rect x="{tx}" y="{ty}" width="{tw}" height="{th}" rx="20" fill="none" stroke="{acc}" stroke-width="10"/>
  <line x1="{tx}" y1="{ty+170}" x2="{tx+tw}" y2="{ty+170}" stroke="{acc}" stroke-width="3" stroke-opacity="0.4"/>

  <!-- top-left number (roomy spacing above the divider) -->
  <text x="{tx+45}" y="{ty+102}" font-family="{MONO}" font-size="80" font-weight="700" fill="{acc}">{tl_big}</text>
  <text x="{tx+48}" y="{ty+150}" font-family="{MONO}" font-size="26" letter-spacing="3" fill="{WHITE}" fill-opacity="0.6">{tl_label}</text>

  <!-- top-right -->
  {tr}

  <!-- giant 2-letter symbol (raised so descenders like p/g/y never hit the name) -->
  <text x="{cx}" y="{ty+475}" font-family="{SANS}" font-size="340" font-weight="800"
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
  <rect x="150" y="285" width="26" height="26" rx="5" fill="none" stroke="{PALETTE['PEP']}" stroke-width="4"/>
  <text x="188" y="306" font-family="{MONO}" font-size="24" fill="{WHITE}" fill-opacity="0.8">PEPTIDE (aa)</text>
  <rect x="470" y="285" width="26" height="26" rx="5" fill="none" stroke="{PALETTE['HOR']}" stroke-width="4"/>
  <text x="508" y="306" font-family="{MONO}" font-size="24" fill="{WHITE}" fill-opacity="0.8">HORMONE (g/mol)</text>
  <rect x="850" y="285" width="26" height="26" rx="5" fill="none" stroke="{PALETTE['MOL']}" stroke-width="4"/>
  <text x="888" y="306" font-family="{MONO}" font-size="24" fill="{WHITE}" fill-opacity="0.8">MOLECULE (g/mol)</text>
  {''.join(cells)}
  <text x="600" y="{height-60}" font-family="{MONO}" font-size="26" letter-spacing="6" text-anchor="middle" fill="{WHITE}" fill-opacity="0.4">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
</svg>'''


def fit_text(text, max_w, base_fs, avg=0.82):
    """Return (font_size, attr) so heavy-weight caps never exceed max_w px.
    librsvg ignores textLength, so we guarantee fit by font-size alone.
    avg≈0.82 is calibrated to DejaVu Sans Bold uppercase advance width."""
    fs = base_fs
    if len(text) * avg * fs <= max_w:
        return fs, ""
    fs = int(max_w / (len(text) * avg))
    return fs, ""


def comp_display(csym):
    """Display fields for a stack component, whether an element or a blend.
    Returns (symbol, full_name, third_line)."""
    for e in ELEMENTS:
        if e[0] == csym:
            return e[0], e[1], (f"{e[5]}aa" if e[3] == "PEP" else f"{e[5]}")
    for b in BLENDS:
        if b[0] == csym:
            return b[0], b[1], "BLEND"
    raise KeyError(f"unknown stack component {csym!r}")


def _fit(text, max_w, base, avg):
    """Shrink font-size only as needed so `text` fits `max_w` (librsvg has no
    textLength), so mini-tile names never bleed past their box at high counts."""
    return base if len(text) * avg * base <= max_w else max(12, int(max_w / (len(text) * avg)))


def front_design():
    """The shared FRONT print for every periodic shirt: the HUMAN+ chest logo.
    Same on every garment, so it's one reusable print file."""
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400" width="1200" height="1400">
  <text x="600" y="690" font-family="{SANS}" font-size="150" font-weight="800" text-anchor="middle" letter-spacing="8" fill="{WHITE}">HUMAN<tspan fill="{BRAND_GREEN}">+</tspan></text>
  <text x="600" y="770" font-family="{MONO}" font-size="34" text-anchor="middle" letter-spacing="10" fill="{WHITE}" fill-opacity="0.5">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
</svg>'''


def stack_tile(name, subtitle, comps, tagline, extras=""):
    """A combined 'stack' tile: big name + a row of component mini-tiles.
    Components may be elements OR blends (KL/WO/GL). `extras` is a free-text list
    of supportive ingredients with no tile, shown as a small "+ ..." line.

    This is the BACK print: stack name + tiles + tagline + slogan. The HUMAN+
    logo is printed on the FRONT (see front_design()), so it is intentionally
    omitted here. The 'STACK SERIES' eyebrow stays as a small header."""
    n = len(comps)
    # wider band + tighter gaps at high counts so 5-6 tiles don't get scrunched
    band = 1120
    gap = 70 if n <= 4 else 40
    bw = min(230, int((band - (n - 1) * gap) / n))
    total = n * bw + (n - 1) * gap
    start = 600 - total / 2
    box_y, box_h = 640, 300
    sym_fs = min(116, int(bw * 0.60))
    minis = []
    stops = []
    for i, csym in enumerate(comps):
        sy, full, third = comp_display(csym)
        col = STACK_COLORS[i % len(STACK_COLORS)]
        x = start + i * (bw + gap)
        cxm = x + bw / 2
        name_fs = _fit(full, bw - 14, 30, 0.55)      # mixed-case bold
        third_fs = _fit(third, bw - 14, 22, 0.62)
        stops.append(f'<stop offset="{int(i*100/(max(n-1,1)))}%" stop-color="{col}"/>')
        minis.append(f'''
  <rect x="{x}" y="{box_y}" width="{bw}" height="{box_h}" rx="14" fill="none" stroke="{col}" stroke-width="7"/>
  <text x="{cxm}" y="{box_y+150}" font-family="{SANS}" font-size="{sym_fs}" font-weight="800" text-anchor="middle" fill="{WHITE}">{esc(sy)}</text>
  <text x="{cxm}" y="{box_y+212}" font-family="{SANS}" font-size="{name_fs}" font-weight="700" text-anchor="middle" fill="{col}">{esc(full)}</text>
  <text x="{cxm}" y="{box_y+255}" font-family="{MONO}" font-size="{third_fs}" text-anchor="middle" fill="{WHITE}" fill-opacity="0.6">{esc(third)}</text>''')
        if i < n - 1:
            # brand-style "+" : green, bold, scaled to the gap so it never overlaps
            plus_x = x + bw + gap / 2
            pfs = min(80, gap + 20)
            minis.append(f'<text x="{plus_x}" y="{box_y+box_h/2+30}" font-family="{SANS}" font-size="{pfs}" font-weight="800" text-anchor="middle" fill="{BRAND_GREEN}">+</text>')
    name_fs, name_len = fit_text(name, 1080, 200)
    extras_svg = ""
    if extras:
        et = "+ " + extras.upper()
        efs = min(32, int(1060 / (len(et) * 0.6)))
        extras_svg = (f'<text x="600" y="1000" font-family="{MONO}" font-size="{efs}" '
                      f'letter-spacing="2" text-anchor="middle" fill="{BRAND_GREEN}" '
                      f'fill-opacity="0.85">{esc(et)}</text>')
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400" width="1200" height="1400">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="0">{''.join(stops)}</linearGradient></defs>
  <text x="600" y="210" font-family="{MONO}" font-size="26" text-anchor="middle" letter-spacing="8" fill="{WHITE}" fill-opacity="0.45">HUMAN+ STACK SERIES</text>
  <text x="600" y="370" font-family="{SANS}" font-size="{name_fs}" font-weight="800" text-anchor="middle" fill="url(#g)"{name_len}>{esc(name)}</text>
  <text x="600" y="450" font-family="{MONO}" font-size="34" letter-spacing="6" text-anchor="middle" fill="{WHITE}" fill-opacity="0.75">{esc(subtitle.upper())}</text>
  {''.join(minis)}
  {extras_svg}
  <text x="600" y="1090" font-family="{MONO}" font-size="40" font-weight="700" letter-spacing="8" text-anchor="middle" fill="{WHITE}">{esc(tagline)}</text>
  <text x="600" y="1320" font-family="{MONO}" font-size="26" letter-spacing="4" text-anchor="middle" fill="{WHITE}" fill-opacity="0.4">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
</svg>'''


def build_site():
    """Self-contained interactive site: clickable periodic table -> stack builder
    -> garment visualizer. Single source of truth = ELEMENTS + STACKS, embedded
    as JSON so the same data drives the SVG previews and the live app."""
    els = [
        {"sym": e[0], "full": e[1], "sub": e[2], "fam": e[3],
         "name_num": e[4], "count": e[5], "tag": e[6], "formula": e[7]}
        for e in ELEMENTS
    ]
    stacks = [{"name": s[0], "sub": s[1], "comps": s[2], "tag": s[3], "extras": s[4]} for s in STACKS]
    blends = [{"sym": b[0], "full": b[1], "sub": b[2], "comps": b[3],
               "accent": b[4], "tag": b[5], "blend": True} for b in BLENDS]
    data = json.dumps({"elements": els, "stacks": stacks, "blends": blends,
                       "palette": PALETTE, "green": BRAND_GREEN,
                       "stackColors": STACK_COLORS}, indent=0)
    return SITE_TEMPLATE.replace("/*__DATA__*/", data)


def build_gallery(names):
    """Static fallback gallery of rendered PNGs (gallery.html)."""
    cards = "\n".join(
        f'    <figure><img src="preview/{n}.png" alt="{n}" loading="lazy"><figcaption>{n}</figcaption></figure>'
        for n in names)
    return f'''<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HUMAN+ — Render Gallery</title>
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
<header><h1>HUMAN<span>+</span></h1><p class="sub">RENDER GALLERY (static PNGs) — see index.html for the interactive builder</p></header>
<div class="grid">
{cards}
</div></body></html>'''


def render_png(svg_path, png_path, bg=BG_PREVIEW):
    subprocess.run(["rsvg-convert", "-b", bg, "-w", "900", "-o", png_path, svg_path], check=True)


# ---- PRINT / POD EXPORT ---------------------------------------------------
# Printful direct-to-garment wants a high-res PNG with a real alpha channel.
# Our SVGs are already white+accent art on a transparent canvas (no full-canvas
# background rect), so the print PNG is just the same vector rendered with NO
# `-b` background flag and a large pixel width. strip_bg() is a belt-and-braces
# guard that removes any full-canvas background <rect> should one ever be added.
PRINT_W = 4500  # 4500 x ~5250 px (6:7) ≈ 300 DPI on a 15in x 17.5in print area
WHITE_INK = "#14141c"  # near-black ink used on the LIGHT-garment variant


def strip_bg(svg):
    """Remove any full-canvas (x=0 y=0, 100%/1200-wide) background <rect> so the
    rendered PNG keeps a transparent alpha. No-op for the current art."""
    pat = re.compile(
        r'<rect\b[^>]*\bx="0"[^>]*\by="0"[^>]*'
        r'(?:width="(?:1200|100%)"[^>]*height="(?:1400|100%)"|'
        r'height="(?:1400|100%)"[^>]*width="(?:1200|100%)")'
        r'[^>]*/>',
        re.IGNORECASE)
    return pat.sub("", svg)


def light_variant(svg):
    """Light-garment version: swap white ink to near-black, mirroring the
    luminance swap the website does in `garmentSVG` (site_template.py)."""
    return (svg.replace("#FFFFFF", WHITE_INK).replace("#ffffff", WHITE_INK)
               .replace("#FFF", WHITE_INK).replace("#fff", WHITE_INK))


# Printful standard front DTG print area: 12in x 16in @ 300 DPI = 3600 x 4800 px.
# Our art is 12in x 14in (1200x1400, 6:7); we center it on the 16in-tall canvas.
PF_W, PF_H = 3600, 4800
PF_ART_W, PF_ART_H = 3600, 4200            # art keeps 6:7 at full width
PF_OFF_Y = (PF_H - PF_ART_H) // 2          # 300px top/bottom margin


def printful_wrap(svg):
    """Center the 1200x1400 art on Printful's 3600x4800 transparent print area."""
    inner = re.sub(r'^\s*<\?xml[^>]*\?>', '', svg)
    inner = re.sub(r'^\s*<svg[^>]*>', '', inner).rsplit('</svg>', 1)[0]
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{PF_W}" height="{PF_H}" '
            f'viewBox="0 0 {PF_W} {PF_H}">'
            f'<svg x="0" y="{PF_OFF_Y}" width="{PF_ART_W}" height="{PF_ART_H}" '
            f'viewBox="0 0 1200 1400" preserveAspectRatio="xMidYMid meet">{inner}</svg></svg>')


def render_printful(svg, png_path, light=False):
    """Render a Printful-template PNG: art centered on a 3600x4800 transparent
    canvas (12x16in @ 300 DPI), ready to drop straight into Printful's print zone."""
    art = strip_bg(svg)
    if light:
        art = light_variant(art)
    art = printful_wrap(art)
    subprocess.run(["rsvg-convert", "-w", str(PF_W), "-h", str(PF_H), "-o", png_path, "-"],
                   input=art.encode("utf-8"), check=True)


def render_print(svg, png_path, light=False):
    """Render `svg` (a string) to a transparent, high-res print PNG.
    rsvg-convert with no `-b` flag preserves the SVG's transparent background."""
    art = strip_bg(svg)
    if light:
        art = light_variant(art)
    subprocess.run(["rsvg-convert", "-w", str(PRINT_W), "-o", png_path, "-"],
                   input=art.encode("utf-8"), check=True)


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    svg_dir = os.path.join(here, "svg")
    prev_dir = os.path.join(here, "preview")
    print_dir = os.path.join(here, "print")          # dark-garment print PNGs
    print_light_dir = os.path.join(print_dir, "light")  # light-garment variant
    pf_dir = os.path.join(here, "print", "printful")        # Printful 3600x4800 (dark ink)
    pf_light_dir = os.path.join(pf_dir, "light")            # Printful 3600x4800 (light-garment ink)
    os.makedirs(svg_dir, exist_ok=True)
    os.makedirs(prev_dir, exist_ok=True)
    os.makedirs(print_dir, exist_ok=True)
    os.makedirs(print_light_dir, exist_ok=True)
    os.makedirs(pf_dir, exist_ok=True)
    os.makedirs(pf_light_dir, exist_ok=True)

    made = []
    printed = 0
    # every compound gets its own hero tile
    for el in ELEMENTS:
        sym = el[0]
        svg = hero_tile(*el)
        base = f"tile_{sym}_{el[1].replace(' ', '').replace('/', '-').replace('+', '')}"
        sp = os.path.join(svg_dir, base + ".svg")
        with open(sp, "w") as f:
            f.write(svg)
        render_png(sp, os.path.join(prev_dir, base + ".png"))
        render_print(svg, os.path.join(print_dir, base + ".png"))
        render_print(svg, os.path.join(print_light_dir, base + ".png"), light=True)
        render_printful(svg, os.path.join(pf_dir, base + ".png"))
        render_printful(svg, os.path.join(pf_light_dir, base + ".png"), light=True)
        printed += 1
        made.append(base)

    # stack tiles
    for name, subtitle, comps, tagline, extras in STACKS:
        svg = stack_tile(name, subtitle, comps, tagline, extras)
        base = f"stack_{name.replace(' ', '_')}"
        sp = os.path.join(svg_dir, base + ".svg")
        with open(sp, "w") as f:
            f.write(svg)
        render_png(sp, os.path.join(prev_dir, base + ".png"))
        render_print(svg, os.path.join(print_dir, base + ".png"))
        render_print(svg, os.path.join(print_light_dir, base + ".png"), light=True)
        render_printful(svg, os.path.join(pf_dir, base + ".png"))
        render_printful(svg, os.path.join(pf_light_dir, base + ".png"), light=True)
        printed += 1
        made.append(base)

    # blend cards (a stack-within-a-tile, rendered as its own stack card)
    for bsym, bfull, bsub, bcomps, baccent, btag in BLENDS:
        base = f"stack_{bfull.replace(' ', '_')}"
        if base in made:          # already produced by STACKS (e.g. WOLVERINE)
            continue
        svg = stack_tile(bfull, bsub, bcomps, btag, "")
        sp = os.path.join(svg_dir, base + ".svg")
        with open(sp, "w") as f:
            f.write(svg)
        render_png(sp, os.path.join(prev_dir, base + ".png"))
        render_print(svg, os.path.join(print_dir, base + ".png"))
        render_print(svg, os.path.join(print_light_dir, base + ".png"), light=True)
        render_printful(svg, os.path.join(pf_dir, base + ".png"))
        render_printful(svg, os.path.join(pf_light_dir, base + ".png"), light=True)
        printed += 1
        made.append(base)

    # concept + poster
    for name, fn in [("concept_HumanPlus", modified_human), ("poster_PeriodicTable", periodic_poster)]:
        svg = fn()
        sp = os.path.join(svg_dir, name + ".svg")
        with open(sp, "w") as f:
            f.write(svg)
        render_png(sp, os.path.join(prev_dir, name + ".png"))
        render_print(svg, os.path.join(print_dir, name + ".png"))
        render_print(svg, os.path.join(print_light_dir, name + ".png"), light=True)
        printed += 1
        made.append(name)

    # the shared FRONT print (HUMAN+ logo) — one file, used on every shirt front
    fsvg = front_design()
    fbase = "front_HumanPlus"
    with open(os.path.join(svg_dir, fbase + ".svg"), "w") as f:
        f.write(fsvg)
    render_png(os.path.join(svg_dir, fbase + ".svg"), os.path.join(prev_dir, fbase + ".png"))
    render_print(fsvg, os.path.join(print_dir, fbase + ".png"))
    render_print(fsvg, os.path.join(print_light_dir, fbase + ".png"), light=True)
    render_printful(fsvg, os.path.join(pf_dir, fbase + ".png"))
    render_printful(fsvg, os.path.join(pf_light_dir, fbase + ".png"), light=True)
    printed += 1
    made.append(fbase)

    # static render-gallery fallback
    order = [n for n in made if n.startswith("poster")] + \
            [n for n in made if n.startswith("stack")] + \
            [n for n in made if n.startswith("concept")] + \
            [n for n in made if n.startswith("tile")]
    with open(os.path.join(here, "gallery.html"), "w") as f:
        f.write(build_gallery(order))

    # interactive site (the main deliverable)
    with open(os.path.join(here, "index.html"), "w") as f:
        f.write(build_site())

    print(f"Generated {len(made)} designs + index.html (interactive) + gallery.html")
    print(f"Print-ready PNGs: {printed} dark (print/) + {printed} light (print/light/) "
          f"@ {PRINT_W}px wide, transparent background")


if __name__ == "__main__":
    main()
