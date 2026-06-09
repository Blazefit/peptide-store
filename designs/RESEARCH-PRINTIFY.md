# Print-on-Demand Research: Selling "Periodic Table of Enhancement" Apparel via Printify

**Prepared for:** Jason (CrossFit Blaze) — peptide/hormone/steroid-themed apparel line (HUMAN+ / MYTHOS)
**Date:** 2026-06-09
**Scope:** Printify POD mechanics, print-file specs, costs/margins, sales channels, API/automation, content & IP risk, Printful comparison, and niche go-to-market.
**Companion doc:** Read alongside `RESEARCH-POD.md` (Printful). Sections are numbered to line up 1:1 for side-by-side comparison.

> **Verification note:** Specs and policy language below are drawn from Printify's own help/policy/developer/pricing pages plus corroborating sources, cited inline and in the Sources section. Two Printify help-center URLs returned HTTP 403 to the automated fetcher and were corroborated via Printify's Terms of Service, design guide, and secondary sources instead — those points are flagged **(verify live)**. Base prices and policy wording change frequently — anything marked **(verify live)** should be re-checked against the live Printify catalog/policy before you commit, because POD platforms update pricing and acceptable-content rules without notice. **The single most important structural fact: Printify is a marketplace of independent third-party print providers, so cost, quality, AND content-acceptance all vary by the provider you pick — there is no single in-house policy like Printful's.**

---

## Executive Summary

- **Printify is also free to start** — the **Free plan is $0/month**, up to 5 connected stores, unlimited designs, full catalog access; you pay only the provider's base cost + shipping per order. No transaction fee/commission on top. [Printify pricing](https://printify.com/pricing/)
- **The paid tier changed in 2026: "Printify Premium" now lists at "from $39/month" monthly (or ~$24.99/month billed annually)** and advertises **up to 33% off** products/branding (historically marketed as "up to 20%"), 10 stores, AI mockups, Printify Connect order management. **Re-verify the exact price and discount % live — it moved recently.** [Printify pricing](https://printify.com/pricing/), [Printify Premium help](https://help.printify.com/hc/en-us/articles/4483625875601-How-does-Printify-s-Premium-plan-work)
- **Your existing exports are upload-ready, with one tweak.** Printify wants **PNG, transparent, sRGB, 300 DPI**, and its design guide recommends **4500 × 5400 px** for a full-front tee (15×18 in @ 300 DPI) — *larger* than Printful's 3600×4800. Your **4500px transparent PNGs are ideal**; your **3600×4800 Printful export will upload and print fine** (Printify auto-enhances and 3600×4800 still exceeds the per-product minimum), but for a true full-bleed 15×18 front, **add a 4500×5400 export variant**. Max file size is **100 MB PNG/JPEG, 20 MB SVG** (Printful allows ~200 MB). [What print files does Printify require](https://help.printify.com/hc/en-us/articles/4483617936657-What-type-of-print-files-does-Printify-require), [Printify design guide](https://printify.com/guide/design-guide/), [color-profile help](https://help.printify.com/hc/en-us/articles/4483625994513-Which-color-profile-should-I-use-for-my-files)
- **Base costs are typically lower than Printful, but provider-dependent.** A US tee runs **~$8.70 (Monster Digital) to ~$11 (Bella+Canvas 3001 blank)**; Gildan 5000 from ~$8.80. Add ~20–33% off with Premium. That's roughly **$1–3/shirt cheaper than Printful's ~$9–13**, which compounds at volume. Hoodies/long-sleeves likewise run a bit under Printful. [How much does Printify charge per shirt](https://podvector.ai/articles/how-much-does-printify-charge-per-shirt), [Monster Digital](https://printify.com/shipping-rates/monster-digital/)
- **The API does everything your stack builder needs** — create products from blueprints, upload print files (image URL **or** base64), generate mockups, and submit/confirm orders. Auth via Personal Access Token or OAuth 2.0. **Rate limits: 600 req/min global, 100/min catalog, 200 product-publish per 30 min, errors must stay <5% of requests.** [Printify API](https://developers.printify.com/)
- **CONTENT-POLICY VERDICT — *less predictable* than Printful, not necessarily stricter.** Printify's Terms of Service prohibits 9 categories (child exploitation, harassment, hate, **illegal content**, IP violations, personal info, self-harm, terrorism, misinformation). Drugs/controlled substances are **not named explicitly**, but fall under the catch-all **"Illegal Content"** clause. Critically, **each independent print provider can refuse or cancel any order** — so the same steroid/peptide design might be accepted by one provider and rejected by another. This is *structurally riskier* for an edgy niche than Printful's single, centrally-enforced policy. [Printify ToS](https://printify.com/terms-of-service/), [Printify IP policy](https://printify.com/intellectual-property-policy/)
- **TRADEMARK VERDICT is identical to the Printful doc and provider-independent:** brand-name steroids (Anavar, Masteron, Primobolan, Winstrol) are registered trademarks — **the client's move to rename them to generic chemical names (oxandrolone, drostanolone, methenolone, stanozolol) was correct and is the single most important legal mitigation.** Printify also enforces IP aggressively per its IP policy.
- **Final recommendation:** **Launch on Printful (consistent quality + one predictable content policy + slightly stronger mockup tooling), connect both to Shopify, and add Printify at volume to cut base cost / add catalog breadth — choosing a specific high-rated US provider and locking it so routing doesn't shuffle you into a stricter or lower-quality printer.** Order samples from your chosen Printify provider before trusting it with the steroid tiles.

---

## 1. How Printify Works End-to-End

**The key structural difference vs Printful:** Printify does **not** print in-house. It is a **marketplace/aggregator of 80–90+ independent third-party print providers** across 100+ locations on 4 continents (US, Canada, UK, EU, China, Australia). You choose *which provider* fulfills each product, and that choice drives **cost, quality, shipping speed, and even whether your design is accepted**. Printful, by contrast, owns its facilities and applies one policy and one quality bar. [Printify print providers](https://printify.com/app/print-providers), [Printify Review 2026 – Style Factory](https://www.stylefactoryproductions.com/blog/printify-review)

| Step | What happens (Printify) | vs Printful |
|------|--------------------------|-------------|
| Setup | Free account; connect up to 5 stores on Free / 10 on Premium. No inventory, **no monthly fee on Free**. | Same model (free to start). |
| **Provider selection** | **You pick a print provider per product** from many options, each with its own price, location, ratings, and print methods. | No choice — Printful is the single provider. |
| Listing | Choose blueprint → choose provider → upload artwork → set placements & retail price → publish to store. | Similar, minus provider step. |
| Order | Customer buys → order routed to the chosen provider (or auto-rerouted by "Order Routing" if that provider is down). | Routed to Printful. |
| Charge | Printify charges you provider base cost + fulfillment + shipping; you keep retail − cost. | Same. |
| Production | **Printed per-order by the third-party provider** (DTG/DTF/embroidery/AOP). | Printed by Printful in-house. |
| Shipping | **White-label outer packaging** (mailers/boxes), but you **cannot add your brand to the outer packaging**; branded **packaging inserts** available from ~6 providers at **~$0.15/insert**. | White-label + more branding options (inside labels, etc.). |
| **Fulfillment time** | Most orders ship in **2–7 business days** (US/CA avg 2–5; EU 3–8). Express option ~2 business days. **(verify live)** | ~2–5 business days to fulfill. |
| **Returns/reprints** | Free reprint or refund **only** for damaged/defective/manufacturing errors, reported with a photo **within 30 days of delivery**; **no return for wrong size/color or buyer's remorse**. Refunds land in your Printify account balance. | Same philosophy (defects/errors only). |

**Quality variance (the trade-off):** Because order routing can send your item to a different machine/provider than your default, **print quality is less consistent than Printful's**. Printify acknowledges this; "Printify Choice" is a curated set of ~100+ best-sellers from vetted providers meant to improve reliability. **Order samples** to vet your chosen provider — **Printify does not offer free samples; all samples are placed at regular price** (Premium discount still applies). [Sample ordering](https://help.printify.com/hc/en-us/articles/4483617804689-How-does-sample-ordering-work), [Printify Choice](https://help.printify.com/hc/en-us/articles/18287001523345-What-is-Printify-Choice-and-how-does-it-work), [returns/refunds](https://help.printify.com/hc/en-us/articles/4483630299025-How-does-Printify-handle-refunds-and-returns)

**Free plan confirmed:** $0/month, 5 stores, unlimited designs, no commission. **Premium:** "from $39/month" (or ~$24.99/mo annually), up to ~33% off (formerly marketed "up to 20%"), 10 stores, AI mockups, Printify Connect. **Enterprise:** custom. [Printify pricing](https://printify.com/pricing/)

---

## 2. Print File Specifications (Exact Export Spec)

**Export your stack-builder artwork as follows for a front DTG print on a standard unisex tee (Printify):**

| Setting | Value (Printify) | Notes / vs Printful |
|---------|------------------|---------------------|
| **File format** | **PNG** (transparent background). JPEG (solid bg) and **SVG** also accepted. | Same as Printful, plus native SVG support (Printful is PNG/JPG/PDF). |
| **Resolution** | **300 DPI recommended.** Large items (leggings/blankets/tapestries) accept 120–150 DPI. | Same 300 DPI target; Printful's floor is 150 DPI. |
| **Recommended full-front pixel size** | **4500 × 5400 px** (15 × 18 in @ 300 DPI) per Printify's design guide | **Larger than Printful's 3600 × 4800 px** (12 × 16 in). Printify's standard front print area is bigger. |
| **Color profile** | **sRGB** — Printify recommends designing in sRGB from the start; it converts CMYK→RGB and saturated colors can shift. | Same sRGB workflow as Printful. |
| **Max file size** | **100 MB** (PNG/JPEG); **20 MB** (SVG) | **Smaller than Printful's ~200 MB.** Your art is well under either. |
| **Transparent background** | Fully supported and recommended. | Same. |
| **Auto-enhance** | Printify **auto-enhances** the print file before production. | Printful does not advertise this. |

Sources: [What print files does Printify require](https://help.printify.com/hc/en-us/articles/4483617936657-What-type-of-print-files-does-Printify-require), [Printify design guide](https://printify.com/guide/design-guide/), [color profile help](https://help.printify.com/hc/en-us/articles/4483625994513-Which-color-profile-should-I-use-for-my-files), [Printify image requirements – freeprinttools](https://freeprinttools.com/blog/printify-image-requirements/).

### Verdict on the client's existing exports
- **The 4500px transparent PNGs are ideal for Printify** — they match Printify's recommended 4500 × 5400 full-front spec exactly (if they're sized to 5400 tall; if they're 4500-square or otherwise, they'll still upload and just won't fill the full 18-in height).
- **The 3600 × 4800 Printful-template PNG will upload and print fine** — it comfortably exceeds Printify's per-product minimum and Printify auto-enhances — but it will **not fill Printify's larger 15×18 front area** (it covers ~12×16). For parity, **add a 4500 × 5400 px transparent-PNG export variant** to the stack builder for Printify.
- **Keep files under 100 MB** (vs Printful's 200 MB). Detailed periodic-table art is nowhere near this.
- **Bottom line:** the builder should emit **two front sizes** — 3600×4800 (Printful) and 4500×5400 (Printify) — both transparent PNG, sRGB, 300 DPI.

### White ink on dark garments (same physics as Printful)
DTG on dark garments lays a **white underbase** under your colors. Printify's specific warning: **avoid gradients that fade to full transparency** — transparent areas where ink fades out get "filled in with white under the base," producing an unwanted halo/box. So keep tile edges crisp and avoid soft transparent fades on dark colorways. Use transparent (not black-box) backgrounds. [Printify design guide](https://printify.com/guide/design-guide/)

### DTG vs AOP vs Embroidery (for detailed art) — same conclusion as Printful
**DTG is the right technique** for the detailed periodic-table graphic (handles fine detail, gradients, small text). AOP/cut-&-sew only if you want edge-to-edge bleed (bigger files per product, pricier). **Avoid embroidery** for detailed art — fine for a simple wordmark only.

---

## 3. Product Base Costs & Margins (USD)

**Approximate** base/fulfillment costs — **(verify live; these vary BY PROVIDER, color/size/region, and change often).** Common, well-regarded US providers include **Monster Digital, SwiftPOD, Print Geek, Drive Fulfillment, District Photo / DJ, Marco Fine Arts**, etc.

| Product (typical blank) | Approx. Printify base cost | Printful base (from RESEARCH-POD.md) | Suggested retail | Example gross margin* |
|--------------------------|----------------------------|--------------------------------------|------------------|------------------------|
| **Unisex t-shirt** | **~$8.70 (Monster Digital) – $11** (Gildan 5000 ~$8.80; B+C 3001 ~$10.98) | ~$9–13 | $28–32 | **~$17–23** |
| **Hoodie** | **~$18–30** (provider-dependent) **(verify live)** | ~$22–35 | $50–65 | **~$25–35** |
| **Long-sleeve tee** | **~$13–20** (provider-dependent) **(verify live)** | ~$16–22 | $38–45 | **~$20–28** |

\*Gross margin = retail − base cost, **before** shipping (~$3.50–5.00 domestic single tee), payment fees (~2.9% + $0.30), and platform fees. With **Premium's ~20–33% off**, a $10.98 tee drops to ~$7.35–8.78.

**Worked example (tee, Free plan):** Monster Digital base $8.70 → retail $30 → gross **$21.30**. Subtract ~$1.17 payment fee → net ~$20 before shipping treatment. On **Premium** (say 20% off → ~$6.96 base) the same tee nets **~$2/shirt more** — Premium's $39/mo (or ~$25/mo annual) breaks even at roughly **13–20 shirts/month**.

**Cost difference vs Printful (the headline):** Printify's tee base is typically **~$1–3 lower** than Printful's, before Premium discounts — and that gap **widens at volume** and with Premium's 20–33% off. For a high-volume catalog this is real money; for a low-volume launch the per-unit savings won't outweigh Printful's consistency and the operational simplicity of a single policy.

Sources: [How much does Printify charge per shirt](https://podvector.ai/articles/how-much-does-printify-charge-per-shirt), [Monster Digital](https://printify.com/shipping-rates/monster-digital/), [Printify t-shirt pricing calculator](https://printify.com/t-shirt-pricing-calculator/), [Printify pricing](https://printify.com/pricing/).

---

## 4. Selling Channels & Integrations

Printify ships official integrations with a **broader set of sales channels than Printful**, plus a native Pop-Up store and API.

| Channel | Integration depth | Best for |
|---------|-------------------|----------|
| **Shopify + Printify** | **Deepest two-way sync** (products, variants, inventory, orders, tracking, refunds, webhooks). | **Recommended home base** — full brand control, owns customer data, scales, supports the custom builder via API. |
| **Etsy + Printify** | OAuth integration; built-in discovery traffic. | Cold discovery; **but stricter on edgy/drug content — high rejection risk for steroid tiles.** |
| **WooCommerce + Printify** | API key-pair plugin; full control, self-hosted. | Tech-comfortable owner wanting no platform fee. |
| **TikTok Shop (US) + Printify** | OAuth; **added 2026.** | Native social-commerce for the visual/meme-able aesthetic — but TikTok Shop content moderation is strict on drug references. |
| **eBay (US), Amazon (US), Walmart Marketplace** | OAuth/managed. | Marketplace reach; **Amazon especially strict — avoid for this line.** |
| **Wix / Squarespace / BigCommerce / PrestaShop / Big Cartel** | Managed-app installs. | If the brand already lives on one of these. |
| **Printify Pop-Up Store** | Native, **free**, `storename.printify.me` URL; Printify handles fulfillment + customer support. | Zero-cost MVP/pilot — but **Pop-Up store designs are content-screened by Printify directly** (see §6). |
| **Printify API** | Full programmatic control for any unlisted channel / your stack builder. | Wiring the builder straight into fulfillment. |

**Does Printify's breadth exceed Printful's?** **Yes on raw channel count** (Printify lists ~11 external channels incl. TikTok Shop, Walmart, BigCommerce, PrestaShop). Printful's integration *depth* and mockup tooling are arguably more polished, and Printful's API is widely regarded as slightly more mature for an automated design→fulfillment pipeline. For *this* brand both roads lead to the same answer.

**Recommended home base for HUMAN+:** **Shopify.** It owns the customer relationship and email list (critical for the gym audience), gives the deepest Printify *and* Printful sync, and exposes the API your stack builder needs. **Connect both Printful and Printify to the same Shopify store** so you can route product-by-product. Use a **Printify Pop-Up store only as a free throwaway pilot**, not the long-term home.

Sources: [Printify integrations](https://printify.com/integrations/), [which sales channels does Printify integrate with](https://help.printify.com/hc/en-us/articles/4483630572945-Which-sales-channels-does-Printify-integrate-with), [Printify integrations guide – PodVector](https://podvector.ai/articles/printify/integrations/the-complete-guide-to-printify-integrations-for-pod-sellers).

---

## 5. Printify API & Automation

**Yes — your stack builder can hand a customer's chosen design + size straight into Printify fulfillment via the API.** [Printify API](https://developers.printify.com/)

| Capability | API support |
|------------|-------------|
| **Create products / variants** | Build products from **catalog blueprints** (blueprint = product type; you specify print provider + variants + placements). |
| **Upload print files** | Add files to the account **Media Library** via **image URL or base64-encoded contents**; reference the returned image IDs when creating/updating products. |
| **Generate mockups** | Place uploaded images on catalog products to produce product images/mockups (Premium also adds "AI Mockups" in-app). |
| **Submit & fulfill orders** | Create orders and submit them for production/fulfillment; track status. Note: product creation *as a result of order creation* is **not** rate-limited. |
| **Auth** | **Personal Access Token** (single merchant, scoped) **or OAuth 2.0** (multi-merchant apps). |
| **Rate limits** | **Global 600 req/min; catalog 100 req/min per integration; product-publish 200 req / 30 min; error responses must stay <5% of total requests.** Limits apply per account, not per token. |

**Architecture for the stack builder:** customer designs → app rasterizes to a **4500×5400 transparent PNG** → upload via Media Library (URL or base64) → create product against your chosen blueprint+provider → generate mockup for live preview → on checkout, create + submit the order with the chosen variant. No manual step.

**Approval/limits to note:** standard merchant API access needs only a generated token (no special gate). The **product-publish 200/30-min** limit and the **<5% error rate** rule matter if the builder batch-creates listings. The API does **not** bypass content review — **the chosen print provider can still cancel a flagged order after submission** (see §6). Printify's limits are *higher* than Printful's published ~120 calls/min, but Printful's mockup pipeline is the more battle-tested for live previews. **(verify current limits live.)**

Source: [Printify API Reference](https://developers.printify.com/).

---

## 6. Content Policy & Legal Risk (Read Carefully — Most Important)

### 6a. Printify acceptable-content policy — and why it's *less predictable* than Printful's
**Primary-source finding:** Printify's **Terms of Service (§H.8)** enumerates **nine** prohibited-content categories: child exploitation; harassment/bullying/defamation/threats; hateful content; **illegal content**; IP violations; personal/confidential info; self-harm; terrorist organizations; harmful misinformation. **Unlike Printful, Printify does NOT explicitly name "illegal drugs" or "controlled substances" as a category.** Drug/steroid content would instead fall under the catch-all **"Illegal Content"** clause — content that "facilitates or promotes activities that go against the laws of the jurisdictions in which you operate." [Printify ToS](https://printify.com/terms-of-service/)

**The structural risk unique to Printify — provider-level refusal:**
- Printify states plainly that **"Print Providers will cancel any orders containing prohibited designs."** Because providers are independent businesses, **each can apply its own additional restrictions and refuse a design** — so the same anabolic/peptide tile could be **accepted by Provider A and rejected by Provider B.** [Can any image be printed](https://help.printify.com/hc/en-us/articles/4483625985553-Can-any-image-be-printed) **(403 to fetcher — verify live)**
- This makes content acceptance **less predictable than Printful's single, centrally-enforced policy.** With Printful you get one yes/no; with Printify you can get inconsistent decisions and mid-stream cancellations depending on routing.
- **Printify Pop-Up store** designs are screened by **Printify directly** (separate, somewhat stricter review). [Pop-Up design rules](https://help.printify.com/hc/en-us/articles/12051654564241-What-kind-of-designs-can-be-used-with-Printify-Pop-Up-Store)

**Interpretation for the steroid/peptide/hormone line:**
- **Anabolic steroids are Schedule III controlled substances in the US** — naming/promoting them plausibly trips the "Illegal Content" clause AND any given provider's own rules. **Highest-risk tiles.**
- **Peptides/hormones (BPC-157, TB-500, NAD+, Testosterone/TRT, HGH/Somatropin, Retatrutide)** are lower risk — generic/research names, not scheduled the same way — but several aren't FDA-approved, so non-zero.
- **Enforcement is per-design, per-provider, and human-reviewed.** A clean **scientific/"periodic-table"** treatment (element tiles, chemical names, molecular motifs, no promotion) fares better than overt promotion — but **acceptance is not guaranteed and can vary by routed provider.**

**Mitigations (reduce, don't eliminate, risk):**
1. **Pick ONE specific high-rated provider per product and lock it** so Order Routing doesn't silently move you to a stricter/lower-quality printer mid-stream.
2. **Order samples of the steroid tiles from that provider first** to confirm acceptance before listing.
3. Avoid imperatives ("Take/Stack/Cycle X"), dosing, buy/sell language, needles/drug-use imagery, and medical/efficacy claims.
4. Favor generic chemical names over brand/street names; add a novelty/parody + "not medical advice" listing disclaimer.
5. **Keep Printful connected as the fallback fulfiller** for any design Printify's providers refuse.

**Verdict:** *Comparable strictness to Printful on paper, but materially LESS PREDICTABLE in practice* because routing exposes you to multiple independent reviewers. For an edgy niche this unpredictability is a real operational cost — favor Printful for the riskiest tiles and use Printify (locked provider) for the safe ones.

Sources: [Printify ToS](https://printify.com/terms-of-service/), [Printify IP policy](https://printify.com/intellectual-property-policy/), [Our Policies](https://printify.com/policies/), [Can any image be printed](https://help.printify.com/hc/en-us/articles/4483625985553-Can-any-image-be-printed), [Copyright 101: Can I print this](https://printify.com/blog/can-i-print-this/).

### 6b. Trademark / IP risk (the bigger, provider-independent risk — unchanged from the Printful doc)
This risk exists **regardless of fulfiller**. Drug **brand names** are registered trademarks; printing them is potential infringement even if no provider flags it. Printify's IP policy says it "does not tolerate IP infringements and reserves the right to remove any content."

| Tile name | Type | Generic / safer equivalent | Risk |
|-----------|------|----------------------------|------|
| **Anavar** | Brand (trademark) | oxandrolone | **High — rename (done)** |
| **Masteron** | Brand (trademark) | drostanolone | **High — rename (done)** |
| **Primobolan** | Brand (trademark) | methenolone | **High — rename (done)** |
| **Winstrol** | Brand (trademark) | stanozolol | **High — rename (done)** |
| Testosterone / TRT | Generic hormone | — | Low |
| HGH / Somatropin | Generic / INN | — | Low (avoid brands Genotropin/Norditropin) |
| BPC-157 / TB-500 | Research-peptide designations | — | Low |
| NAD+ | Chemical/coenzyme name | — | Low |
| Retatrutide | INN / generic (Lilly LY-3437943) | — | Low (never sub GLP-1 brands Ozempic/Wegovy/Mounjaro/Zepbound) |

**The client already renamed the brand-name steroids to generic chemical names — that is the correct and most important legal mitigation, and it carries over identically to Printify.** Avoid pharma logos/packaging trade dress/fonts. This is research, not legal advice — a short IP-attorney review of the final tile list is worth it.

Source: [Printify IP policy](https://printify.com/intellectual-property-policy/).

### 6c. Compared to Printful and to marketplaces
- **vs Printful:** Printful = one explicit policy (names "controlled substances"), centrally enforced, predictable. Printify = catch-all "illegal content" clause + **per-provider discretion** → **less predictable**. Neither is a clean "yes."
- **Amazon Merch on Demand / Etsy / TikTok Shop:** **all stricter than either Printful or Printify** on drug references — assume this line gets rejected there. Sell through **your own Shopify store**, where you control listings and pick the fulfiller.

---

## 7. Printify vs Printful — Direct Verdict

| Dimension | **Printful** | **Printify** |
|-----------|--------------|--------------|
| Model | In-house printing (vertically integrated) | **Marketplace of 80–90+ independent providers** |
| **Print quality consistency** | **More consistent** (one operator, one standard) | Varies by provider/routing; "Printify Choice" mitigates |
| Base cost | Higher (~$9–13 tee) | **Lower (~$8.70–11 tee)**; Premium adds 20–33% off |
| Monthly fee | Free to start | Free to start; **Premium ~$39/mo (or ~$25/mo annual)** for discounts |
| **Full-front print spec** | 3600×4800 px (12×16 in), ≤200 MB | **4500×5400 px (15×18 in)**, ≤100 MB; native SVG |
| Color / format | sRGB PNG/JPG/PDF | sRGB PNG/JPG/**SVG**; auto-enhance |
| Channels | Strong, slightly fewer | **More channels** (incl. TikTok Shop, Walmart, BigCommerce, PrestaShop) |
| API | Mature; ~120 calls/min; strong mockup pipeline | Capable; **600/min global**, 200 publish/30min; URL+base64 upload |
| **Content policy** | One explicit policy naming controlled substances; **predictable** | Catch-all "illegal content" + **per-provider refusal → less predictable** |
| IP/trademark | Enforced | Enforced |
| Branding | More options (inside labels etc.) | White-label outer pkg only; inserts ~$0.15 (from ~6 providers) |
| Fulfillment time | ~2–5 biz days | 2–7 biz days (US/CA 2–5) |
| Best at | **Quality + policy predictability + clean automation** | **Lower cost at scale + catalog breadth + more channels** |

### Recommendation for THIS brand
**Printful to launch; Printify to optimize at volume; both connect to Shopify.** Rationale:
1. **Launch on Printful** — for an edgy, content-risky niche you want **one predictable policy** and **consistent print quality** on a low-volume catalog. The slightly higher base cost is worth the operational certainty while you validate designs and confirm which tiles get accepted.
2. **Run everything through Shopify** (owns the customer + email list + supports the stack-builder API). Connect **both** Printful and Printify to it.
3. **Add Printify at volume** once you know which tiles sell and which the fulfiller accepts — pick a **specific high-rated US provider** (e.g., Monster Digital / SwiftPOD), **lock it** so routing doesn't shuffle you, **order samples**, and migrate the **safe, high-volume designs** (peptides/hormones/MYTHOS) there to capture the **~$1–3/unit + Premium 20–33%** savings. Keep the **riskiest steroid tiles on Printful** for predictability.
4. **Export both file sizes** from the builder (3600×4800 for Printful, 4500×5400 for Printify) so either fulfiller is one click away.

---

## 8. Niche Go-To-Market (Brief — Printify-specific deltas only)

Same playbook as the Printful doc — **gym (warm audience) → Instagram/TikTok Reels → email list → Pinterest/Reddit, using limited "stack drops."** Printify-specific notes:
- **TikTok Shop (US) integrates natively with Printify (2026)** — convenient for the meme-able aesthetic — but TikTok Shop moderation is strict on drug references; keep listings science/parody-framed and expect the steroid tiles to be the ones flagged.
- A **free Printify Pop-Up store** (`storename.printify.me`) is a viable zero-cost pilot, but its designs are screened by Printify directly and you can't brand the outer packaging — use Shopify for the real brand.
- Keep messaging **science/parody/community-identity** framed (protects you on Meta/TikTok ad policies, which are stricter than organic).
- **Avoid Amazon Merch, Etsy-as-primary, and marketplace channels** for the steroid tiles — too strict.

---

## Recommended Action Plan

1. **IP fix — confirmed done.** Brand-name steroids already renamed to generics (oxandrolone, drostanolone, methenolone, stanozolol). Optional 1-hour IP-attorney review of the final tile list. Never use GLP-1 *brands*.
2. **Add a second export size.** Configure the stack builder to emit **4500 × 5400 px transparent PNG, sRGB, 300 DPI** for Printify full-front (keep 3600×4800 for Printful). Files <100 MB. Avoid transparent-fade gradients on dark garments.
3. **Stand up Shopify as home base**; connect **both Printful and Printify**. Keep a free Printify Pop-Up store only as a throwaway pilot if desired.
4. **Launch on Printful** for the full catalog (predictable policy + consistent quality), per RESEARCH-POD.md.
5. **Vet Printify in parallel:** pick one high-rated US provider (Monster Digital / SwiftPOD), **lock the provider**, **order paid samples** (incl. a couple of steroid tiles to test acceptance) on dark and light tees. Confirm white-underbase output and that the provider accepts the designs.
6. **Decide Premium economics.** If monthly Printify volume clears ~15–20 units, **Premium (~$39/mo or ~$25/mo annual, 20–33% off)** pays for itself. **Re-verify the current price/discount live — it moved in 2026.**
7. **Migrate at volume:** move the safe, high-volume designs (peptides/hormones/MYTHOS) to the locked Printify provider for the ~$1–3/unit + Premium savings; keep the riskiest steroid tiles on Printful.
8. **Wire automation:** stack builder → Media Library upload (URL/base64) → product from blueprint+provider → mockup preview → submit order. Respect 200 publish/30-min and <5% error-rate limits.
9. **Go to market** via gym → IG/TikTok → email → Pinterest/Reddit, limited drops. Avoid Amazon/Etsy-primary for the steroid tiles.

---

## Sources

- Printify — Pricing (Free/Premium/Enterprise, discounts, stores): https://printify.com/pricing/
- Printify — How does Premium work (Help Center): https://help.printify.com/hc/en-us/articles/4483625875601-How-does-Printify-s-Premium-plan-work
- Printify — What type of print files does Printify require (Help Center): https://help.printify.com/hc/en-us/articles/4483617936657-What-type-of-print-files-does-Printify-require
- Printify — Which color profile should I use (Help Center): https://help.printify.com/hc/en-us/articles/4483625994513-Which-color-profile-should-I-use-for-my-files
- Printify — Must-read design guide (4500×5400, transparency/gradient warning): https://printify.com/guide/design-guide/
- Printify — How does sample ordering work (no free samples): https://help.printify.com/hc/en-us/articles/4483617804689-How-does-sample-ordering-work
- Printify — Printify Choice: https://help.printify.com/hc/en-us/articles/18287001523345-What-is-Printify-Choice-and-how-does-it-work
- Printify — Returns/refunds & reprint eligibility: https://help.printify.com/hc/en-us/articles/4483630299025-How-does-Printify-handle-refunds-and-returns ; https://help.printify.com/hc/en-us/articles/4483625769105-When-is-a-product-eligible-for-a-reprint
- Printify — Production times: https://help.printify.com/hc/en-us/articles/4483629751825-What-are-Printify-s-production-times-like
- Printify — Integrations (channels): https://printify.com/integrations/ ; https://help.printify.com/hc/en-us/articles/4483630572945-Which-sales-channels-does-Printify-integrate-with
- Printify — Print providers list: https://printify.com/app/print-providers ; Monster Digital: https://printify.com/shipping-rates/monster-digital/ ; SwiftPOD: https://printify.com/app/print-provider/39/swiftpod
- Printify — API Reference (capabilities, auth, rate limits): https://developers.printify.com/
- Printify — Terms of Service (prohibited content §H.8): https://printify.com/terms-of-service/
- Printify — Intellectual Property Policy: https://printify.com/intellectual-property-policy/
- Printify — Our Policies: https://printify.com/policies/
- Printify — Can any image be printed (provider cancellation of prohibited designs) [403 to fetcher; verify live]: https://help.printify.com/hc/en-us/articles/4483625985553-Can-any-image-be-printed
- Printify — Pop-Up Store design rules: https://help.printify.com/hc/en-us/articles/12051654564241-What-kind-of-designs-can-be-used-with-Printify-Pop-Up-Store
- PodVector — How much does Printify charge per shirt (base costs): https://podvector.ai/articles/how-much-does-printify-charge-per-shirt
- Style Factory — Printify Review 2026 (marketplace model, quality variance, white-label): https://www.stylefactoryproductions.com/blog/printify-review
- freeprinttools — Printify image requirements (DPI/format/size): https://freeprinttools.com/blog/printify-image-requirements/
- PodVector — Printify integrations guide: https://podvector.ai/articles/printify/integrations/the-complete-guide-to-printify-integrations-for-pod-sellers
- Companion: RESEARCH-POD.md (Printful) — base costs, specs, and policy used for side-by-side comparison.

*This document is operational/business research, not legal advice. Verify all pricing (especially Premium's $39/$24.99 price and discount %), provider base costs, and policy details against live Printify pages before launch, and consult an IP attorney on the final design/name list.*
