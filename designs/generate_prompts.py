#!/usr/bin/env python3
"""
HUMAN+ MYTHOS — DALL-E / ChatGPT art prompt pack generator.

Turns the MYTHOS identity data (archetype + aura + lore, per compound and per
stack) into a ready-to-paste prompt for each character. Each prompt = one fixed
HOUSE STYLE block (paste-identical every time for a cohesive set) + a tailored
subject description + a per-character STYLE MODE:

    beast  -> feral monster: horns, fangs, claws, hulking inhuman anatomy
    god    -> divine statue/deity: marble + bronze, heroic, restrained palette
    dark   -> dark-fantasy figure: armored knight / hooded sorcerer / ranger

Output: ART-PROMPTS.md  (paste into ChatGPT, one character at a time)

Run:  python3 generate_prompts.py
"""

import os
from generate_tiles import ELEMENTS, STACKS
from generate_mythic import MYTHIC, EVO

# Paste this verbatim ABOVE every character prompt so the whole set matches.
HOUSE_STYLE = (
    "STYLE (keep identical for every character in this series): a single epic "
    "fantasy character, full body, centered, vertical 6:7 composition. Highly "
    "detailed digital oil painting, cinematic dramatic side lighting, deep "
    "shadows, weathered and ancient, mature and serious — NOT cartoon, NOT "
    "cute, NOT childish. Muted, desaturated, metallic palette (stone, iron, "
    "bronze, gold) with ONE restrained accent color of glowing energy. Plain "
    "dark stone/void background, subtle rim light separating the figure from "
    "the background. Mythic, legendary, Lord-of-the-Rings / Dark Souls energy. "
    "No text, no letters, no words, no logos, no watermark, no border, no UI."
)

# aura key -> the accent color + material words used in the prompt
AURA_WORDS = {
    "gold":      "radiant warm gold",
    "bronze":    "burnished bronze and amber",
    "emerald":   "deep emerald green",
    "sapphire":  "cold sapphire blue",
    "crimson":   "blood crimson red",
    "violet":    "arcane violet",
    "silver":    "pale silver-white",
    "verdigris": "oxidized copper-teal (verdigris)",
    "rose":      "soft rose-pink",
    "steel":     "cold gunmetal steel",
    "marble":    "ivory marble and pale gold",
    "obsidian":  "black obsidian with violet sheen",
    "stone":     "grey weathered stone",
}

# archetype -> (default mode, body/pose/attribute description)
ARCH = {
    "titan":     ("god",  "a colossal, immensely muscular heroic male deity, broad shoulders, "
                          "powerful stance, fragments of ancient armor, the build of a god of strength"),
    "colossus":  ("beast","a towering horned brute, monstrous hulking muscle, thick hide and "
                          "bone plating, heavy fists, more monster than man"),
    "berserker": ("beast","a feral hunched predator-warrior mid-snarl, long bladed claws, "
                          "scarred sinewy muscle, savage and unstoppable, animal ferocity"),
    "hunter":    ("dark", "a lean, lithe predatory ranger, taut whipcord muscle, hooded cloak, "
                          "a great bow, sharp economical danger, nothing wasted"),
    "seraph":    ("god",  "a winged divine being, vast feathered or membranous wings spread wide, "
                          "noble and otherworldly, radiant halo of energy"),
    "sage":      ("dark", "a hooded robed sorcerer-monk, face in shadow beneath the cowl, holding "
                          "a long staff topped with a glowing focus, ancient calm power"),
    "warden":    ("dark", "a heavy armored guardian-knight, great tower shield and crested helm, "
                          "immovable, sworn protector, weathered plate armor"),
    "ascendant": ("god",  "an ascended radiant figure, levitating slightly, ringed by a halo and "
                          "rays of light, serene transcendent power"),
    "alchemist": ("dark", "a robed mystic alchemist cradling a glowing orb of energy, intricate "
                          "arcane garb, scholar of forbidden craft"),
}

# Per-character motif overrides: extra, specific visual hooks for the headliners.
# (sym -> short phrase woven into the prompt)
MOTIF = {
    "Te": "the original god-king of strength, a crown of bronze laurels",
    "Re": "marked everywhere with the number three — three claws, three eyes, a trident; gaunt and ravenous",
    "Sg": "famine incarnate, gaunt and skeletal-lean, hollow hungry presence",
    "Tz": "twin curved blades, a two-headed motif",
    "Pt": "a cupid reforged as a dread archer of desire — great wings and a drawn bow with a glowing arrow of longing",
    "Gk": "forged of living copper turned brilliant blue-green, healing filaments weaving across its body",
    "Mt": "bronze sun-touched skin glowing from within, a small sun cradled in its chest",
    "Gh": "the first flame of creation, primordial and ancient, the progenitor of all the others",
    "In": "ringed with floating keys of light, master of every lock",
    "Ig": "amplifying the whisper of growth into a deafening roar, surrounded by surging energy",
    "Ep": "an hourglass with the sand falling upward, ageless and timeless",
    "Mc": "glowing core-furnace visible in its chest, the engine-spirit of the cell",
    "Mb": "veins of glowing azure electricity, lending light to the dying",
    "Na": "a glowing coin/current of pure cellular energy orbiting its hands",
    "Ox": "an unbreakable thread of light binding outward, the spirit of the bond",
    "T3": "a living furnace burning at its core, throttling an inner fire",
    "Ml": "drawing a curtain of deep night, the bringer of dusk and sleep",
    "Es": "perfectly balanced, holding twin scales of light in equilibrium",
}

# Per-stack motif overrides (evolutions / the named beasts)
EVO_MOTIF = {
    "WOLVERINE":  "an adamantine berserker with three long metal claws bursting from each fist, regenerating wounds, feral fury",
    "ADAMANTIUM": "an unbreakable colossus, bone laced with shining metal, impervious",
    "PHOENIX":    "a being of rebirth wreathed in dying-and-rising fire, ash reforming into flesh",
    "GREEK GOD":  "a flawless marble statue come to life, the physique of a classical deity, ivory and gold",
    "MASS MONSTER":"the mountain that walks — a vast horned colossus of overwhelming muscle",
    "BLACK LABEL":"an elite obsidian-armored champion, top-shelf and forbidden, violet sheen on black plate",
    "THE HOLY TRINITY":"three radiant powers fused into one ascended divine warrior",
    "SHOWTIME":   "a beautiful winged figure made to be seen, catching and stealing the light",
    "STOIC":      "an unmoving stone-grey monk, utterly unshaken at the core",
    "LIMITLESS":  "a sage whose mind opens into an endless violet cosmos above, no ceiling",
}


def mode_for(arch, override=None):
    return override or ARCH[arch][0]


def build_prompt(title, real, arch, aura, lore, motif, kind_label, forged=""):
    mode, body = ARCH[arch]
    mode_word = {"beast": "FERAL BEAST", "god": "GOD-STATUE / DEITY",
                 "dark": "DARK-FANTASY FIGURE"}[mode]
    accent = AURA_WORDS.get(aura, "glowing energy")
    extra = (" " + motif + ".") if motif else ""
    forged_line = (f" It is an evolved fusion forged from {forged}, so it should "
                   f"feel like a higher, more powerful form.") if forged else ""
    subject = (
        f"Subject: \"{title}\" — the mythic embodiment of {real}. "
        f"Render as a {mode_word}: {body}. "
        f"Its signature energy/accent color is {accent} (use sparingly, as glowing "
        f"highlights only — keep the overall image dark and desaturated). "
        f"Character essence: {lore}{extra}{forged_line}"
    )
    return f"{HOUSE_STYLE}\n\n{subject}"


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    EL = {e[0]: e for e in ELEMENTS}

    out = []
    out.append("# HUMAN+ MYTHOS — DALL·E / ChatGPT Art Prompt Pack\n")
    out.append(
        "Paste one block at a time into ChatGPT (DALL·E 3). The first paragraph "
        "(HOUSE STYLE) is **identical in every prompt on purpose** — it's what "
        "keeps all 64 characters looking like one cohesive set. The second "
        "paragraph is the character.\n")
    out.append(
        "**Workflow & tips**\n"
        "- Generate them in one ChatGPT conversation so it 'remembers' the house style — consistency improves.\n"
        "- If a result is too colorful or cartoonish, reply: *“darker, more desaturated, more painterly, more serious, less saturated color.”*\n"
        "- DALL·E can't do transparent backgrounds; that's fine — keep the **plain dark background** and I'll drop each image into the card frame (the frame already supplies the name, lore, and border).\n"
        "- **Save each image** named exactly like the tag shown (e.g. `art_Te.png` for a compound, `art_WOLVERINE.png` for a stack) and drop them in `designs/mythic_art/`. Then tell me and I'll wire them into the cards automatically.\n"
        "- Aim for the largest size ChatGPT offers (1024×1792 portrait is ideal — it matches the 6:7 card).\n")
    out.append("\n---\n")

    # Compounds
    out.append("\n## BASE FORMS — Compounds\n")
    for e in ELEMENTS:
        sym = e[0]
        if sym not in MYTHIC:
            continue
        title, arch, aura, lore = MYTHIC[sym]
        mode = ARCH[arch][0]
        p = build_prompt(title, e[1], arch, aura, lore, MOTIF.get(sym, ""), "compound")
        out.append(f"\n### {title} — {e[1]}  \n"
                   f"`art_{sym}.png` · archetype: **{arch}** · style: **{mode}** · aura: {aura}\n\n"
                   f"```\n{p}\n```\n")

    # Evolutions
    out.append("\n---\n\n## EVOLUTIONS — Stacks\n")
    for s in STACKS:
        name, sub, comps, tag, extras = s
        arch, aura, lore = EVO.get(name, ("titan", "gold", tag))
        forged = " + ".join(MYTHIC[c][0] for c in comps if c in MYTHIC)
        mode = ARCH[arch][0]
        p = build_prompt(name, sub, arch, aura, lore, EVO_MOTIF.get(name, ""),
                         "stack", forged=forged)
        fn = name.replace(" ", "_")
        out.append(f"\n### {name} — {sub}  \n"
                   f"`art_{fn}.png` · archetype: **{arch}** · style: **{mode}** · aura: {aura} · forged from: {forged}\n\n"
                   f"```\n{p}\n```\n")

    md = "\n".join(out)
    with open(os.path.join(here, "ART-PROMPTS.md"), "w") as f:
        f.write(md)
    n = len([e for e in ELEMENTS if e[0] in MYTHIC]) + len(STACKS)
    print(f"Wrote ART-PROMPTS.md — {n} prompts ({len([e for e in ELEMENTS if e[0] in MYTHIC])} compounds + {len(STACKS)} stacks)")


if __name__ == "__main__":
    main()
