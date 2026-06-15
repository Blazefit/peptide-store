#!/usr/bin/env python3
"""
HUMAN+ MYTHOS — DALL-E / ChatGPT art prompt pack generator.

The MYTHOS page has a two-form slider:  MYTHIC  |  ANIME FORM  (same character,
two art styles). So every character needs TWO real images. This script turns
the MYTHOS identity data (archetype + aura + lore) into TWO ready-to-paste
DALL-E prompts per character:

    MYTHIC form  -> epic dark-fantasy oil painting (LOTR / Dark Souls).
                    Per-character mode: beast / god-statue / dark-fantasy.
    ANIME form   -> vibrant anime / collectible-creature style (the bright,
                    Pokemon-like look) — clean cel shading, energetic.

Each prompt = a fixed HOUSE STYLE block (paste-identical within its form so the
set stays cohesive) + a tailored subject. Save images as:
    art_<sym>_mythic.png / art_<sym>_anime.png        (compounds)
    art_<NAME>_mythic.png / art_<NAME>_anime.png       (stacks)
into designs/mythic_art/ , then I wire them into the cards.

Output: ART-PROMPTS.md      Run:  python3 generate_prompts.py
"""

import os
from generate_tiles import ELEMENTS, STACKS
from generate_mythic import MYTHIC, EVO

# ── house styles ────────────────────────────────────────────────────────────
HOUSE_MYTHIC = (
    "MYTHIC-FORM STYLE (keep identical for every character): a single epic "
    "fantasy character, full body, centered, vertical 6:7 composition. Highly "
    "detailed digital oil painting, cinematic dramatic side lighting, deep "
    "shadows, weathered and ancient, mature and serious — NOT cartoon, NOT "
    "cute. Muted, desaturated, metallic palette (stone, iron, bronze, gold) "
    "with ONE restrained accent color of glowing energy. Plain dark stone/void "
    "background, subtle rim light. Mythic, legendary, Lord-of-the-Rings / Dark "
    "Souls energy. No text, no letters, no logos, no watermark, no border."
)
HOUSE_ANIME = (
    "ANIME-FORM STYLE (keep identical for every character): a single heroic "
    "anime / collectible-creature character, full body, centered, vertical 6:7 "
    "composition. Clean cel-shaded anime illustration, bold confident line art, "
    "vibrant saturated colors, dynamic action pose, expressive and energetic, "
    "glowing elemental effects — like a premium trading-card creature. Simple "
    "complementary gradient background with a soft energy glow behind the "
    "figure. Polished, high-quality, NOT childish-chibi, NOT photoreal. No "
    "text, no letters, no logos, no watermark, no border."
)

AURA_WORDS = {
    "gold": "radiant warm gold", "bronze": "burnished bronze and amber",
    "emerald": "deep emerald green", "sapphire": "cold sapphire blue",
    "crimson": "blood crimson red", "violet": "arcane violet",
    "silver": "pale silver-white", "verdigris": "oxidized copper-teal (verdigris)",
    "rose": "soft rose-pink", "steel": "cold gunmetal steel",
    "marble": "ivory marble and pale gold", "obsidian": "black obsidian with violet sheen",
    "stone": "grey weathered stone",
}

# archetype -> (mythic_mode, mythic_body, anime_body)
ARCH = {
    "titan": ("god",
        "a colossal, immensely muscular heroic male deity, broad shoulders, "
        "powerful stance, fragments of ancient armor, the build of a god of strength",
        "a hugely muscular heroic warrior, confident powerful stance, fierce determined face"),
    "colossus": ("beast",
        "a towering horned brute, monstrous hulking muscle, thick hide and bone "
        "plating, heavy fists, more monster than man",
        "a giant horned creature-warrior, massive muscle, fierce roaring pose, armored plating"),
    "berserker": ("beast",
        "a feral hunched predator-warrior mid-snarl, long bladed claws, scarred "
        "sinewy muscle, savage and unstoppable, animal ferocity",
        "a feral clawed fighter mid-lunge, wild spiked hair, bladed claws, fierce battle snarl"),
    "hunter": ("dark",
        "a lean, lithe predatory ranger, taut whipcord muscle, hooded cloak, a "
        "great bow, sharp economical danger, nothing wasted",
        "a sleek agile ranger mid-motion, hooded cloak flowing, drawing a glowing bow, sharp and quick"),
    "seraph": ("god",
        "a winged divine being, vast feathered or membranous wings spread wide, "
        "noble and otherworldly, radiant halo of energy",
        "a winged celestial hero, large glowing wings spread wide, radiant halo, graceful heroic pose"),
    "sage": ("dark",
        "a hooded robed sorcerer-monk, face in shadow beneath the cowl, holding "
        "a long staff topped with a glowing focus, ancient calm power",
        "a robed spellcaster channeling energy, glowing staff/orb, swirling magic, focused intense eyes"),
    "warden": ("dark",
        "a heavy armored guardian-knight, great tower shield and crested helm, "
        "immovable, sworn protector, weathered plate armor",
        "an armored guardian-knight, big shield and crested helm, planted protective stance, glowing crest"),
    "ascendant": ("god",
        "an ascended radiant figure, levitating slightly, ringed by a halo and "
        "rays of light, serene transcendent power",
        "a glowing ascended hero floating with energy rays and a halo, arms outstretched, radiant power"),
    "alchemist": ("dark",
        "a robed mystic alchemist cradling a glowing orb of energy, intricate "
        "arcane garb, scholar of forbidden craft",
        "a mystic hero holding a glowing orb of energy, ornate robes, swirling arcane particles"),
}

MOTIF = {
    "Te": "the original god-king of strength, a crown of bronze laurels",
    "Re": "marked with the number three — three claws, three eyes, a trident; gaunt and ravenous",
    "Sg": "famine incarnate, gaunt and skeletal-lean, a hollow hungry presence",
    "Tz": "twin curved blades, a two-headed motif",
    "Pt": "a cupid reforged as a dread archer of desire — great wings and a drawn bow with a glowing heart-tipped arrow",
    "Gk": "forged of living copper turned brilliant blue-green, healing filaments weaving across its body",
    "Mt": "bronze sun-touched skin glowing from within, a small sun cradled in its chest",
    "Gh": "the first flame of creation, primordial and ancient, progenitor of all the others",
    "In": "ringed with floating keys of light, master of every lock",
    "Ig": "amplifying a whisper of growth into a deafening roar, surging energy",
    "Ep": "an hourglass with the sand falling upward, ageless and timeless",
    "Mc": "a glowing core-furnace visible in its chest, the engine-spirit of the cell",
    "Mb": "veins of glowing azure electricity, lending light to the dying",
    "Na": "a glowing coin/current of pure cellular energy orbiting its hands",
    "Ox": "an unbreakable thread of light binding outward, the spirit of the bond",
    "T3": "a living furnace burning at its core, throttling an inner fire",
    "Ml": "drawing a curtain of deep night, bringer of dusk and sleep",
    "Es": "perfectly balanced, holding twin scales of light in equilibrium",
}
EVO_MOTIF = {
    "WOLVERINE": "an adamantine berserker with three long metal claws bursting from each fist, regenerating wounds, feral fury",
    "ADAMANTIUM": "an unbreakable colossus, bone laced with shining metal, impervious",
    "PHOENIX": "a being of rebirth wreathed in dying-and-rising fire, ash reforming into flesh",
    "GREEK GOD": "a flawless marble statue come to life, the physique of a classical deity, ivory and gold",
    "MASS MONSTER": "the mountain that walks — a vast horned colossus of overwhelming muscle",
    "BLACK LABEL": "an elite obsidian-armored champion, top-shelf and forbidden, violet sheen on black plate",
    "THE HOLY TRINITY": "three radiant powers fused into one ascended divine warrior",
    "SHOWTIME": "a beautiful winged figure made to be seen, catching and stealing the light",
    "STOIC": "an unmoving stone-grey monk, utterly unshaken at the core",
    "LIMITLESS": "a sage whose mind opens into an endless violet cosmos above, no ceiling",
}

MODE_WORD = {"beast": "FERAL BEAST", "god": "GOD-STATUE / DEITY", "dark": "DARK-FANTASY FIGURE"}


def subject(form, title, real, arch, aura, lore, motif, forged=""):
    mythic_mode, mbody, abody = ARCH[arch]
    accent = AURA_WORDS.get(aura, "glowing energy")
    extra = (" " + motif + ".") if motif else ""
    forged_line = (f" It is an evolved fusion forged from {forged} — make it feel "
                   f"like a higher, more powerful form.") if forged else ""
    if form == "mythic":
        return (f"Subject: \"{title}\" — the mythic embodiment of {real}. Render as a "
                f"{MODE_WORD[mythic_mode]}: {mbody}. Signature accent color {accent} "
                f"(use sparingly, glowing highlights only; keep it dark and desaturated). "
                f"Essence: {lore}{extra}{forged_line}")
    return (f"Subject: \"{title}\" — the anime hero form of {real}: {abody}. Its "
            f"signature element/energy color is {accent} (used boldly in the glow and "
            f"effects). Essence: {lore}{extra}{forged_line}")


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    out = []
    out.append("# HUMAN+ MYTHOS — DALL·E / ChatGPT Art Prompt Pack\n")
    out.append(
        "The MYTHOS page slider has **two forms per character: MYTHIC and ANIME FORM**. "
        "So each character below has **two prompts** — generate both. Within each form, "
        "the first paragraph (HOUSE STYLE) is identical on purpose: that's what keeps the "
        "set cohesive.\n")
    out.append(
        "**Workflow**\n"
        "- Do all MYTHIC prompts in one ChatGPT chat, all ANIME prompts in another — consistency improves when the chat remembers the house style.\n"
        "- Too colorful/cartoonish in MYTHIC? reply *“darker, more desaturated, more painterly, more serious.”* Too dull in ANIME? reply *“brighter, bolder line art, more vibrant, more dynamic.”*\n"
        "- DALL·E can't do transparent backgrounds — that's fine, I drop each image into the card frame.\n"
        "- **Save each image with the exact filename shown** into `designs/mythic_art/`, then tell me and I'll auto-wire them into the cards.\n"
        "- Use the largest portrait size offered (1024×1792 ≈ the 6:7 card).\n")
    out.append("\n---\n")

    def block(title, real, arch, aura, lore, motif, tag_base, forged=""):
        b = [f"\n### {title} — {real}  ",
             f"archetype: **{arch}** · aura: {aura}" + (f" · forged from: {forged}" if forged else "")]
        for form, house in (("mythic", HOUSE_MYTHIC), ("anime", HOUSE_ANIME)):
            label = "MYTHIC form" if form == "mythic" else "ANIME form"
            fname = f"art_{tag_base}_{form}.png"
            s = subject(form, title, real, arch, aura, lore, motif, forged)
            b.append(f"\n**{label}** → save as `{fname}`\n\n```\n{house}\n\n{s}\n```")
        return "\n".join(b) + "\n"

    out.append("\n## BASE FORMS — Compounds\n")
    for e in ELEMENTS:
        sym = e[0]
        if sym not in MYTHIC:
            continue
        title, arch, aura, lore = MYTHIC[sym]
        out.append(block(title, e[1], arch, aura, lore, MOTIF.get(sym, ""), sym))

    out.append("\n---\n\n## EVOLUTIONS — Stacks\n")
    for name, sub, comps, tag, extras in STACKS:
        arch, aura, lore = EVO.get(name, ("titan", "gold", tag))
        forged = " + ".join(MYTHIC[c][0] for c in comps if c in MYTHIC)
        out.append(block(name, sub, arch, aura, lore, EVO_MOTIF.get(name, ""),
                         name.replace(" ", "_"), forged=forged))

    with open(os.path.join(here, "ART-PROMPTS.md"), "w") as f:
        f.write("\n".join(out))
    nc = len([e for e in ELEMENTS if e[0] in MYTHIC])
    ns = len(STACKS)
    print(f"Wrote ART-PROMPTS.md — {(nc+ns)*2} prompts "
          f"({nc} compounds + {ns} stacks, x2 forms)")


if __name__ == "__main__":
    main()
