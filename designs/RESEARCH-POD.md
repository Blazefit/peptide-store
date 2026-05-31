# Print-on-Demand Research: Selling "Periodic Table of Enhancement" Apparel via Printful

**Prepared for:** Jason (CrossFit Blaze) — peptide/hormone/steroid-themed apparel line
**Date:** 2026-05-31
**Scope:** Printful POD mechanics, print-file specs, costs/margins, sales channels, API/automation, content & IP risk, competitor comparison, and niche go-to-market.

> **Verification note:** Specs and policy language below are drawn from Printful's own help/policy/developer pages plus corroborating sources, cited inline and in the Sources section. Base prices and policy wording change frequently — anything marked **(verify live)** should be re-checked against the live Printful catalog or policy page before you commit, because POD platforms update pricing and acceptable-content rules without notice.

---

## Executive Summary

- **Printful is free to start** — no monthly fee, no minimums, no inventory. You pay Printful's base price + shipping only when a customer orders; the difference between your retail price and that base is your margin. White-label by default (no Printful branding on the package). [Printful pricing](https://www.printful.com/custom/t-shirts)
- **Exact export spec for a front DTG print on a standard unisex tee:** export a **PNG with a transparent background, sRGB color, at 300 DPI, sized to the full print area. For the standard ~12 in × 16 in DTG area that is 3600 × 4800 px** (150 DPI / 1800 × 2400 px is the bare minimum). Keep files under ~200 MB. Your vector "stack builder" should rasterize to this. [Printful design requirements](https://www.printful.com/design-requirements)
- **Margins are healthy:** a Bella+Canvas 3001 tee runs roughly **$9–13 base**; sold at **$28–32** that's **~$15–20 gross profit** before shipping/fees. Hoodies ~$22–35 base → $50–65 retail; long-sleeves ~$16–22 base → $38–45 retail. **(verify live)**
- **Sales channel:** For a gym with an existing audience and a custom "stack builder" web app, **Shopify + Printful** is the best fit (full control, API access, owns the customer). Printful also offers a **free hosted/quick store** if you want zero-cost launch, and **Etsy** is good for cold discovery traffic.
- **The API does everything you need.** Printful's API can create products, upload print files, generate mockups (Mockup Generator API), and submit/confirm orders — so your stack builder *can* hand a customer's chosen design + size straight into Printful fulfillment. [Printful Developers](https://developers.printful.com)
- **CONTENT-POLICY VERDICT (real risk — closer to "no" than to "yes"):** Printful's official Acceptable Content Guidelines **explicitly list "illegal drugs" and "controlled substances" as prohibited categories** (confirmed in Printful's own policy PDF). Anabolic steroids are Schedule III controlled substances in the US; several peptides (BPC-157, etc.) are not FDA-approved. Designs that name/reference these compounds are at **material risk of rejection or account suspension**, decided per-design by Printful's review team. A purely scientific/"periodic-table" framing *may* pass where overt promotion would not, but there is **no guarantee** — do not build the business assuming Printful will print every tile. [Acceptable Content Guidelines](https://www.printful.com/policies/content-guidelines)
- **TRADEMARK VERDICT (this is the bigger legal risk):** Several tile names are **registered drug brand names** — **Anavar, Masteron, Primobolan, Winstrol** are trademarks (generic equivalents: oxandrolone, drostanolone, methenolone, stanozolol). Putting those *brand* words on merch is potential trademark infringement **independent of Printful's policy**. By contrast **BPC-157, TB-500, NAD+, Testosterone, HGH/Somatropin, Retatrutide** are generic/INN/research names and are far safer. **Recommendation: rename brand-name tiles to their generic/chemical names.**
- **Stricter platforms:** Amazon Merch on Demand and Redbubble are notably more restrictive on drug references than Printful — assume those marketplaces will reject this line.

---

## 1. How Printful POD Works End-to-End

| Step | What happens |
|------|--------------|
| Setup | Create a free Printful account, connect a store (or use Printful's hosted store). No inventory, no upfront purchase, **no monthly fee**. |
| Listing | You upload artwork onto blank products and set your retail price. |
| Order | Customer buys on your store → order is auto-routed to Printful. |
| Charge | Printful charges *you* the base product cost + fulfillment + shipping; you keep retail − that cost. |
| Production | Printful prints **per order, on demand** (DTG, embroidery, AOP, etc.) in their own facilities. |
| Shipping | **White-label / blind shipping by default** — no Printful logo or marketing on the package; can add your own branding inserts/labels (some at extra cost). |
| Fulfillment time | Typically **~2–5 business days to fulfill** before handing to the carrier, plus shipping transit. (verify live) |
| Returns | Printful only accepts returns for **damaged/defective/misprinted items or its own errors**, not for buyer's remorse/wrong size — you set your own customer-facing return policy and eat or pass on the cost of reprints. |

Sources: [Printful custom t-shirts / pricing](https://www.printful.com/custom/t-shirts), [ecommerce-platforms Printful pricing 2025](https://ecommerce-platforms.com/articles/printful-pricing).

---

## 2. Print File Specifications (Exact Export Spec)

This is the most important practical section. **Export your stack-builder artwork as follows for a front DTG print on a standard unisex tee:**

| Setting | Value | Notes |
|---------|-------|-------|
| **File format** | **PNG** (with transparent background) | PNG preferred for transparency; JPG accepted (no transparency); PDF mainly for embroidery/vector. |
| **Resolution** | **300 DPI recommended** (150 DPI absolute minimum) | DPI is meaningless without the matching pixel size — set DPI *at the final print dimensions*. |
| **Standard DTG print area** | **~12 in × 16 in** front (some products/sizes allow up to ~15 in × 18 in) | "Maximum print area" varies per product/size — always check the per-product template. |
| **Pixel dimensions @ 300 DPI** | **3600 × 4800 px** (for 12 × 16 in) | This is the target export size for full-area front prints. |
| **Pixel dimensions @ 150 DPI** | 1800 × 2400 px | Minimum acceptable; will look softer on detailed graphics. |
| **Color profile** | **sRGB** | RGB workflow; Printful converts for print. Expect slight color shift vs. screen. |
| **Max file size** | ~**200 MB** (web upload) | Detailed periodic-table art well under this. |
| **Transparent background** | Fully supported and recommended | Transparent areas = unprinted garment. Use it so only the design prints, not a box. |

Sources: [Printful design requirements](https://www.printful.com/design-requirements), [Image and File Requirements help article](https://help.printful.com/hc/en-us/articles/4419648102545-Image-and-File-Requirements), corroborated by community/blog reports of 12×16 in → 3600×4800 px.

### Practical export recommendation for the "stack builder"
Since your app already produces print-ready **vector** artwork, rasterize the front graphic to a **3600 × 4800 px transparent PNG, sRGB, 300 DPI**, centered within a 12×16-in canvas. That single file is upload-ready for DTG via UI or API on virtually every standard tee, long-sleeve, and hoodie front. For chest-only or pocket-size prints, export a smaller transparent PNG sized to that area at 300 DPI.

### White ink on dark garments
DTG on dark garments requires a **white underbase** layer that Printful's printers lay down automatically beneath your colors so the design stays vivid. Implications for a periodic-table aesthetic:
- Use **transparent backgrounds** (not a black box) so the white underbase only goes where your design is.
- Pure-white or near-white elements print as white ink; thin light lines on dark fabric can lose crispness — keep tile borders/text reasonably thick.
- Expect slightly muted/softer output vs. on white garments; consider offering the design primarily on dark **and** light colorways and previewing both.

### DTG vs. All-Over Print vs. Embroidery (for a detailed graphic)
| Technique | Fit for your detailed periodic-table art | Notes |
|-----------|------------------------------------------|-------|
| **DTG (direct-to-garment)** | **Best choice.** Handles fine detail, gradients, many colors, small text. | Use transparent PNG @ 300 DPI as above. The default for detailed graphics. |
| **All-Over Print (AOP / cut-&-sew)** | Good only if you want the design to bleed edge-to-edge across the whole garment. | Requires much larger, full-template files per product; more expensive; overkill for a centered chest graphic. |
| **Embroidery** | **Avoid for detailed art.** Limited colors, no gradients, no small text/fine lines. | Fine for a simple logo/wordmark only. |

---

## 3. Product Base Costs & Margins (USD)

**Approximate** base/fulfillment costs — **(verify live in your Printful catalog; prices vary by color/size/region and change often).**

| Product (typical blank) | Approx. Printful base cost | Suggested retail | Example gross margin* |
|--------------------------|---------------------------|------------------|------------------------|
| **Unisex t-shirt** (Bella+Canvas 3001) | ~$9–13 | $28–32 | **~$15–20** |
| **Hoodie** (e.g., Gildan 18500 / premium) | ~$22–35 | $50–65 | **~$25–30** |
| **Long-sleeve tee** | ~$16–22 | $38–45 | **~$20–23** |

\*Gross margin = retail − base cost, **before** shipping, payment-processing fees (~2.9% + $0.30), and any platform fees. Printful generally suggests at least a **2× markup** on base cost.

**Worked example (tee):** base $12 → retail $30 → gross $18. Subtract ~$1.17 payment fee and a shipping shortfall if you offer "free shipping," and net is roughly **$13–16/shirt**. Bundling shipping into the price or charging it separately materially changes net margin, so model both.

Sources: [Printful t-shirt cost blog](https://www.printful.com/blog/how-much-does-it-cost-to-make-a-shirt), [Printful hoodie cost blog](https://www.printful.com/blog/how-much-does-it-cost-to-make-a-hoodie), [ecommerce-platforms pricing](https://ecommerce-platforms.com/articles/printful-pricing).

---

## 4. Selling Channels & Integrations

| Channel | Pros | Cons | Best for |
|---------|------|------|----------|
| **Shopify + Printful** | Full brand control, owns customer data/email, deep Printful integration, API access, scales well | ~$29+/mo Shopify fee, you must drive your own traffic | **Recommended** — gym already has an audience; integrates with your stack builder |
| **Etsy + Printful** | Built-in shopper traffic / discovery, low setup | Listing/transaction fees, less brand control, **stricter on edgy/drug content** | Cold discovery, casual buyers |
| **WooCommerce + Printful** | Free/open-source, full control, WordPress flexibility | You self-host & maintain; more technical | Tech-comfortable owners wanting no platform fee |
| **Printful-hosted / Quick Store** | **Free**, fastest zero-cost launch, no separate website needed | Limited customization/branding, fewer marketing tools | MVP / testing demand before committing to Shopify |

**Does Printful offer its own storefront?** Yes — Printful provides a **free hosted store / "Quick Store"** option, so you can sell without building or paying for a separate platform. Good for a no-cost pilot; graduate to Shopify once you're validating sales. **(verify current feature name/limits live.)**

For your situation (existing gym audience + custom stack-builder app + desire to automate design→fulfillment), **Shopify + Printful API** is the strongest long-term setup; a Printful Quick Store is a fine free pilot.

Sources: [ecommerce-platforms Printful pricing/integrations](https://ecommerce-platforms.com/articles/printful-pricing), [Printful custom t-shirts](https://www.printful.com/custom/t-shirts).

---

## 5. Printful API & Automation

**Yes — your stack builder can hand a customer's chosen design + size straight into Printful fulfillment via the API.** Printful's developer API supports the full pipeline:

| Capability | API support |
|------------|-------------|
| **Create products / variants** | Sync Products API — create and manage products and variants programmatically. |
| **Upload print files** | Files API — upload print files (commonly by hosting the PNG at a URL Printful fetches). |
| **Generate mockups** | **Mockup Generator API** — submit a print file + product, get back rendered product mockups (task-based/async). |
| **Submit & fulfill orders** | Orders API — create draft orders, confirm them, and track fulfillment/shipping status. |
| **Auth** | Token/OAuth via the Printful Developers portal (Bearer token). |
| **Limits** | General rate limit ~**120 API calls/min**; mockup generation and some endpoints are stricter and **asynchronous** (create a task, then poll for the result); unauthenticated catalog access ~30 req/60s. **(verify current limits in docs.)** |

**Architecture for your stack builder:** customer designs in your app → app rasterizes to a 3600×4800 transparent PNG → upload via Files API → call Mockup Generator API to show the customer a realistic preview → on checkout, create + confirm an Order with the chosen variant (size/color) and print file. No manual step required.

**Approval/limits to note:** API access requires a Printful account and generated token; no special approval gate for standard use, but you must still comply with the content/IP policy — the API does **not** bypass content review, and flagged orders can still be cancelled.

Source: [Printful Developers documentation](https://developers.printful.com).

---

## 6. Content Policy & Legal Risk (Read Carefully)

### 6a. Printful Acceptable-Content policy — drugs/steroids/peptides
**Primary-source finding:** Printful's official **Acceptable Content Guidelines** document explicitly enumerates **"illegal drugs"** and **"controlled substances"** as prohibited content categories (alongside hate, violence, weapons, sexually explicit material, counterfeit/IP infringement, and alcohol-related restrictions). Printful's Warehousing & Fulfillment terms separately bar shipping "drugs ... contraband or illegal substances." Key interpretation:

- **Anabolic steroids (Anavar/oxandrolone, Masteron/drostanolone, Primobolan/methenolone, Winstrol/stanozolol, etc.) are Schedule III controlled substances in the US.** Naming them on merch directly touches the prohibited "controlled substances" category. This is the highest-risk part of the line.
- **Peptides/hormones (BPC-157, TB-500, Testosterone/TRT, HGH/Somatropin, NAD+, Retatrutide)** are not generally scheduled the same way, but several are not FDA-approved and some sit in a gray zone; risk is lower but non-zero.
- **Enforcement is per-design and human-reviewed.** A clean **scientific/"periodic-table"** treatment (element-tile styling, chemical names, molecular motifs, no promotion) has a better chance of passing than overt promotion, but **acceptance is not guaranteed** and Printful can cancel orders or suspend the account at any time.
- **Mitigations (reduce, don't eliminate, risk):** avoid imperatives ("Take X," "Stack Y," "Cycle Z"), dosing protocols, buy/sell language, needles or drug-use imagery, and medical/efficacy claims; favor generic chemical names over street/brand names; add a novelty/parody, "not medical advice" disclaimer on listings. **Test a few designs through Printful before scaling**, and have a backup fulfiller plan.

**Verdict:** *High-risk / not assured.* This is **not** a clean "permitted" — drugs and controlled substances are named prohibited categories. The steroid tiles in particular may be rejected; the peptide/hormone tiles are lower risk. Build with the assumption that some designs will be refused, and **re-read the live policy + confirm with Printful support before launch.**

Sources: [Printful Acceptable content policy](https://www.printful.com/policies/acceptable-content), [Content guidelines & IP rights](https://help.printful.com/hc/en-us/articles/360014252919-Content-guidelines-and-intellectual-property-rights).

### 6b. Trademark / IP risk (the bigger, independent risk)
**This risk exists regardless of POD policy.** Drug **brand names** are registered trademarks owned by pharma companies; printing them on merch can be trademark infringement even if Printful never flags it. Status of your proposed tile names:

| Tile name | Type | Generic / safer equivalent | Risk |
|-----------|------|----------------------------|------|
| **Anavar** | **Brand name (trademark)** | oxandrolone | **High — rename** |
| **Masteron** | **Brand name (trademark)** | drostanolone | **High — rename** |
| **Primobolan** | **Brand name (trademark)** | methenolone / metenolone | **High — rename** |
| **Winstrol** (if used) | **Brand name (trademark)** | stanozolol | **High — rename** |
| **Testosterone / TRT** | Generic hormone term | — | Low |
| **HGH / Somatropin** | Generic / INN term (brands exist: Genotropin, Norditropin) | — | Low (use "HGH"/"Somatropin," not brand) |
| **BPC-157** | Research-peptide designation | — | Low |
| **TB-500** | Research-peptide designation | — | Low |
| **NAD+** | Chemical/coenzyme name | — | Low |
| **Retatrutide** | **INN / generic name** (Lilly dev code LY-3437943; *not* a brand) | — | Low (but note Lilly's adjacent brands like Mounjaro/Zepbound/Ozempic ARE trademarks — never use those) |

**Key takeaways:**
- **Rename Anavar, Masteron, Primobolan, Winstrol** to their generic chemical names (oxandrolone, drostanolone, methenolone, stanozolol). Generic/INN/research names are not trademarked and are dramatically lower risk.
- **Retatrutide is the generic name, not a brand** — safe to use; just never substitute a GLP-1 *brand* (Ozempic/Wegovy = semaglutide; Mounjaro/Zepbound = tirzepatide) — those are trademarks.
- Avoid copying any pharma company's **logos, packaging trade dress, or fonts**.
- This is general research, **not legal advice** — for a commercial product line, a quick consult with an IP attorney on the final tile list is worth the small cost.

Sources: [Printful IP/trademark guidance](https://www.printful.com/blog/intellectual-property-rights-and-you-how-to-avoid-trademark-and-copyright-troubles), Wikipedia entries for oxandrolone/drostanolone/methenolone/stanozolol, INN records for retatrutide.

### 6c. Compared to Amazon Merch on Demand & Redbubble
Both are **stricter** than Printful on drug references:
- **Amazon Merch on Demand** prohibits illegal drugs, drug paraphernalia, and content promoting drug use/controlled substances — assume this line gets **rejected**.
- **Redbubble** prohibits content promoting illegal drug use/paraphernalia and dangerous/illegal activity — also **high rejection risk** for steroid/peptide tiles.

**Implication:** Do not anchor the business on Amazon/Redbubble. Sell through **your own Shopify/Printful store** (and cautiously Etsy), where you control listings and Printful is the most permissive of the major fulfillers.

Sources: search corroboration of Amazon Merch and Redbubble content policies (drug prohibitions).

---

## 7. Printful vs. Printify vs. Gelato

**Printful** — Vertically integrated (prints in its own facilities), so **most consistent print quality and the most coherent, centrally-enforced content policy**. Slightly higher base costs than Printify. **Best-in-class API** (products, files, mockups, orders) and white-label shipping. Free to start. Best fit when quality consistency and a clean automation pipeline matter.

**Printify** — A **marketplace of third-party print providers**, so **base costs are often lower** but **print quality and content enforcement vary by provider** (each provider can add its own restrictions). Solid API. Good for cost optimization and product variety, but quality/policy consistency is the trade-off — risky when you want uniform output and predictable content decisions for an edgy niche.

**Gelato** — Global distributed network optimized for **local production / fast international shipping** and sustainability. Good quality and a capable API; catalog historically narrower for some apparel and pricing competitive regionally. Strong if you expect significant international (esp. EU) demand.

**Recommendation:** **Start with Printful** — best quality consistency, strongest API for wiring your stack builder into fulfillment, white-label shipping, and the most workable (though still cautious) stance for this niche. Revisit Printify for cost optimization or Gelato for international scaling only after you've validated demand.

---

## 8. Selling to a Fitness / Biohacking Niche (Practical)

You have unusually good built-in distribution. Priorities:

1. **Your gym (highest-converting channel).** Warm audience that already trusts you — soft-launch in-house (samples on staff, a QR code/poster to the store, member-only first drop). This validates designs cheaply.
2. **Instagram + TikTok (Reels/short video).** This aesthetic is visual and meme-able. Show the periodic-table tiles, "which tile are you" content, before/after gym humor. Link in bio → store. Highest reach for cold audience.
3. **Pinterest.** Strong for evergreen apparel/aesthetic discovery; pin each colorway/design with keyword-rich descriptions — long-tail traffic.
4. **Reddit communities** (fitness/biohacking/peptide/CrossFit subs) — **participate authentically**, don't spam; these communities punish overt selling but love insider/parody humor. Great for taste-testing names and memes.
5. **Email list.** Convert gym members + site visitors; announce drops, limited colorways. Owned audience = best ROI; tie into Shopify.
6. **Limited drops / scarcity.** Niche-identity apparel sells on belonging and timing — periodic "stack drops" beat an always-on catalog.

Keep messaging **science/parody/community-identity** framed (consistent with the content-policy mitigations in §6) — avoid anything reading as encouraging illegal use, which also protects you on the ad platforms (Meta/TikTok ad policies are stricter than organic).

---

## Recommended Action Plan

1. **Fix the IP risk first.** Rename **Anavar → Oxandrolone, Masteron → Drostanolone, Primobolan → Methenolone, (Winstrol → Stanozolol)**. Keep generic/research names (BPC-157, TB-500, NAD+, Testosterone/TRT, HGH/Somatropin, Retatrutide). Optional: 1-hour IP-attorney review of the final tile list.
2. **Lock the export spec.** Configure the stack builder to output **3600 × 4800 px transparent PNG, sRGB, 300 DPI** for full-front DTG (smaller transparent PNGs at 300 DPI for chest/pocket prints).
3. **Pilot free.** Open a **free Printful account + Printful Quick Store** (or Shopify if ready). Order **physical samples** of the top 3 designs on both a dark and a light tee to check white-underbase output before selling.
4. **Validate content compliance.** Submit a couple of sample designs and confirm Printful doesn't flag them; keep designs scientific/parody (no dosing, no "buy," no needles). Re-read the live Acceptable Content policy.
5. **Wire automation (phase 2).** Move to **Shopify + Printful API**: Files API (upload PNG) → Mockup Generator API (live preview in stack builder) → Orders API (checkout → fulfillment). No manual steps.
6. **Set pricing.** Tee $28–32, long-sleeve $38–45, hoodie $50–65 (≥2× base). Model "free shipping" vs. separate shipping for true net margin. **Verify live base costs first.**
7. **Go to market** via gym → IG/TikTok → email → Pinterest/Reddit, using limited drops. Avoid Amazon Merch & Redbubble for this line (too strict).

---

## Sources

- Printful — Design Requirements: https://www.printful.com/design-requirements
- Printful — Image and File Requirements (Help Center): https://help.printful.com/hc/en-us/articles/4419648102545-Image-and-File-Requirements
- Printful — Custom T-shirts / pricing & no-minimum: https://www.printful.com/custom/t-shirts
- Printful — Cost to make a shirt (blog): https://www.printful.com/blog/how-much-does-it-cost-to-make-a-shirt
- Printful — Cost to make a hoodie (blog): https://www.printful.com/blog/how-much-does-it-cost-to-make-a-hoodie
- Printful — Acceptable content policy: https://www.printful.com/policies/acceptable-content
- Printful — Acceptable Use Policy: https://www.printful.com/legal/acceptable-use-policy
- Printful — Content guidelines & IP rights (Help Center): https://help.printful.com/hc/en-us/articles/360014252919-Content-guidelines-and-intellectual-property-rights
- Printful — IP/trademark guidance (blog): https://www.printful.com/blog/intellectual-property-rights-and-you-how-to-avoid-trademark-and-copyright-troubles
- Printful — Developer documentation (API, Mockup Generator, Orders): https://developers.printful.com
- ecommerce-platforms — Printful Pricing 2025 guide: https://ecommerce-platforms.com/articles/printful-pricing
- Drug name/trademark status — Wikipedia: Oxandrolone (Anavar), Drostanolone (Masteron), Methenolone (Primobolan), Stanozolol (Winstrol); INN record for Retatrutide (Lilly LY-3437943).
- Amazon Merch on Demand & Redbubble content policies (drug prohibitions) — platform policy pages (search-corroborated).

*This document is operational/business research, not legal advice. Verify all pricing and policy details against live Printful pages before launch, and consult an IP attorney on the final design/name list.*
