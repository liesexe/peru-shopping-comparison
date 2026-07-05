---
name: peru-shopping-comparison
description: Prices shopping lists at Makro Peru, Plaza Vea, and Tottus, then recommends the cheapest single-store full-trip option. Uses cut/bulk season, asks about ambiguous beef cuts and product variants, prefers exact product links, and keeps pack-size/unit-price logic. Outputs a spreadsheet with all three stores, direct product links, and no blank cells. Use web_search + web_fetch only.
triggers:
  - /peru-shopping
  - /compare-prices
---

# Peru Grocery Price Comparison (Makro / Plaza Vea / Tottus)

Prices an entire shopping list against three Peruvian retailers and recommends the single cheapest one to buy everything from — because splitting one shopping trip across multiple stores costs more time than it saves in money.

## Why "one store for everything," not per-item cheapest

The user shops at these three stores and explicitly wants **one full trip to the cheapest single store**, not a per-item cherry-picked list that would require visiting all three. Every output from this skill must be built around that goal: compare the total cost of the *entire list* at each store, then recommend one winner.

## Execution workflow

**CRITICAL: Run to completion without intermediate updates.**

1. **Ask clarifying questions ONLY about products** (if needed):
   - Ambiguous items (e.g., "pollo" → need cut specification)
   - Product variants (e.g., brand preference, flavor)
   - Pack size clarification
   - **DO NOT ask**: permission to continue, execution confirmations, "should I proceed?", time warnings

2. **Once clarifications done, execute fully**:
   - Search all 3 stores for all products
   - No status updates during execution
   - No "working on it..." messages
   - No progress reports
   - Run to completion even if takes 5+ minutes

3. **Present final result only**:
   - Complete comparison table with all prices
   - Total per store
   - Recommended cheapest store
   - Direct product links

**Do not stop mid-execution. Do not ask if you should continue. Finish the entire report.**

## The three sites and how to actually reach them

**Do not use bash/curl/requests against any of these domains.** None are in the sandbox's allowed network list, and even if they were, all three gate most category browsing behind a delivery-address session that a stateless script can't set. Use `web_search` + `web_fetch` only.

Important background: **Makro (`makro.plazavea.com.pe`) and Plaza Vea (`plazavea.com.pe`) share the same backend/catalog** — same SKUs, same product pages, often the same or very similar prices, since both are run by the same retail group. Makro sometimes shows exclusive/wholesale pricing on top of this shared catalog (per its own tagline, "precios exclusivos" for bulk buyers), so prices *can* differ between the two even on an identical SKU — always check both, don't assume they're identical. **Tottus (`tottus.com.pe`) is a fully separate platform** (Falabella group) with its own catalog and pricing.

**CRITICAL DOMAIN RULE:** Makro and Plaza Vea are physically different stores with different locations. **NEVER mix domains:**
- **Makro column** → ONLY `makro.plazavea.com.pe` URLs
- **Plaza Vea column** → ONLY `plazavea.com.pe` URLs (NOT `makro.plazavea.com.pe`)
- Search each store on its own domain
- Extract URLs matching the target domain only
- If searching Makro brand page, use only Makro URLs for Makro column
- If searching Plaza Vea, use only Plaza Vea URLs for Plaza Vea column
- Same product? Search both domains separately and use matching domain URL per column

### Makro & Plaza Vea (same VTEX platform - requires brand-page workflow)

**IMPORTANT: Numeric SKU pattern applies ONLY to Makro & Plaza Vea URLs, NOT Tottus.**

**Many `/p` product URLs return 404 even when search finds them.** Working Makro/Plaza Vea URLs have numeric product IDs at the end (e.g., `product-name-20502734/p`). Brand/category pages contain these working URLs.

**Store base URLs**
- Makro: `https://www.makro.plazavea.com.pe/`
- Plaza Vea: `https://www.plazavea.com.pe/`
- Tottus: `https://www.tottus.com.pe/tottus-pe/`

**Optimized workflow for Makro & Plaza Vea ONLY:**

**When pricing Makro:**
1. `web_search` with `site:makro.plazavea.com.pe <item in Spanish>` to discover candidate URLs
2. **Never trust prices in search snippets.** Search snippets only for finding URLs, never for reading prices.
3. Try `web_fetch` on `/p` URL from search (must be `makro.plazavea.com.pe` domain)
   - **If succeeds:** extract price, use this URL for Makro column
   - **If 404:** proceed to step 4
4. **Fallback to Makro brand/category page**:
   - `web_search` for brand/category page: `site:makro.plazavea.com.pe <brand category>`
   - `web_fetch` brand/category page
   - Extract product URLs **with numeric IDs at the end** from `makro.plazavea.com.pe` domain only
   - Format: `product-name-NNNNNNNN/p` where N is 8-digit SKU
5. `web_fetch` the Makro product URL with numeric SKU → extract price, use for Makro column

**When pricing Plaza Vea:**
1. `web_search` with `site:plazavea.com.pe <item in Spanish>` (NOT `site:makro.plazavea.com.pe`)
2. Try `web_fetch` on `/p` URL from search (must be `plazavea.com.pe` domain)
   - **If succeeds:** extract price, use this URL for Plaza Vea column
   - **If 404:** proceed to fallback
3. **Fallback to Plaza Vea brand/category page**:
   - `web_search` for brand/category page: `site:plazavea.com.pe <brand category>`
   - `web_fetch` brand/category page
   - Extract product URLs **with numeric IDs** from `plazavea.com.pe` domain only
4. `web_fetch` the Plaza Vea product URL → extract price, use for Plaza Vea column

**Domain enforcement:** Each store column gets URLs from its own domain only. Never use a `makro.plazavea.com.pe` URL in Plaza Vea column or vice versa.
**Common steps (both stores):**

6. **If only singles found but need multiple units:** multiply single price by quantity needed.
   - Example: need 6 units, single = S/4.99 → total = 6 × S/4.99 = S/29.94
   - Note in spreadsheet "Cantidad a comprar": "6 unidades individuales"
   - Multipacks are helpful but not required — singles work fine
7. **If still not found after fallback:** mark "No disponible" for that specific store
8. **Stock status unreliable** — pages show "AGOTADO" and "X unidades disponibles" simultaneously (site-wide template quirk). Treat as informational only, not disqualifying.

**Domain verification before adding to spreadsheet:**
- Makro row URL starts with `https://www.makro.plazavea.com.pe/` → ✅
- Plaza Vea row URL starts with `https://www.plazavea.com.pe/` → ✅
- Makro row with `plazavea.com.pe` (not makro subdomain) → ❌ ERROR - search Plaza Vea domain instead
- Plaza Vea row with `makro.plazavea.com.pe` → ❌ ERROR - search plazavea.com.pe domain instead


**Makro/Plaza Vea direct-path rule:** for these stores, do not rely on generic web search alone when the first pass misses. Move straight to the store's own category or brand page and search inside it. This is especially important for:
- `pepino` and `pepinillo` and other loose produce, which live in category pages like Verduras or Frutas
- `gloria pro` and similar brand families, which are often easiest to reach from the brand page or product family page
- `galleta de arroz costeno` and other packaged snacks, which may be indexed under the brand or with accent-free naming

If a broad item has a known store family or category, search that family first on Makro/Plaza Vea before trying more general web queries. Examples:
- `pepino` -> `pepinillo` -> Verduras / Pepinos-pepinillos
- `gloria pro` -> brand page or L?cteos / Desayunos family
- `galleta de arroz costeno` -> Galletas y Golosinas / Galletas Saladas or the COSTENO product page

**Exact title / slug rule for Makro and Plaza Vea:** if the page title or URL slug already shows the exact product family, use that exact spelling as the search anchor. Do not stop at the generic family name.
- Search the full title both with spaces and as the compact slug-like form if the first query misses.
- For example, `Bebida Lactea Gloria Pro Power Caramel Macchiato Botella 320ml` should be tried as the exact title, then as the compact query `gloria pro power caramel macchiato botella 320ml`, then with the SKU/slug pattern if visible.
- If a product page is already found, treat the exact `/p` URL and SKU as the canonical match and use that to infer sibling variants on the same store.
- Prefer exact title matching over broad family matching when the item is a branded pack, bottle, or tray with a unique SKU.

**Direct page canonical rule:** when you find a valid Makro or Plaza Vea `/p` page for the requested product or exact variant, stop searching and use that page as the canonical match. Do not downgrade it to a generic family result just because the brand page is broader.
- If the user has already named the exact variant, search that exact variant first.
- If the direct page exists, use its title, SKU, and price over any category result.
- Only fall back to category/brand pages when the exact page does not exist or clearly belongs to a different variant.

**Pepino alias rule:** for Makro and Plaza Vea, search `pepinillo` whenever the user asks for `pepino`. Treat `pepinillo` as the store-side translation, not a separate fallback.

**Performance optimization:** When pricing 10+ items, fetch Tottus category pages first (bulk data, high success rate). Makro/Plaza Vea require brand-page workflow (slower but works). Always price all three stores for comparison unless user specifies otherwise.

### Tottus (PREFERRED - most reliable)

**Start here for efficiency.** Tottus `/lista/CATG.../` category pages return clean bulk product data (name, brand, size, price, discount) with high fetch success rate.

**IMPORTANT: Tottus URLs work differently than Makro/Plaza Vea:**
- Tottus `/articulo/...` and `/p/` URLs from search work directly — NO numeric SKU extraction needed
- Example valid Tottus URL: `tottus-pe/articulo/113927515/Yogurt-Griego-Natural-1-kg/113927517`
- DO NOT apply Makro/Plaza Vea's numeric SKU pattern to Tottus URLs

**Direct category search workflow:** search for category URLs first, then fetch them for bulk product data.

1. `web_search` with `site:tottus.com.pe lista <category>` to find category URLs (e.g., `lista/CATG16680/Verduras`, `lista/CATG16919/Carne-de-Pollo`).
2. `web_fetch` the category/listing page — returns 20-30 products per page with full pricing. Extract all relevant items at once.
3. For individual products needing stock confirmation: `web_fetch` the specific `/articulo/...` or `/p/` URL directly from search results. **"Agregar al Carro"** = in stock; **"Producto sin stock :("** = out of stock. These pages sometimes 503 — retry once before giving up.
4. If category not found, retry search with more general term or search for the exact product title.
5. Match products from category page prices to specific `/articulo/...` URLs from search results. Category pages show prices but may not show individual product URLs in the fetched HTML (client-side rendering). Use search to find the specific product URLs, then match by product name.

For Makro/Plaza Vea, if step 1 or 2 fails, prefer the store's own category/brand navigation over another generic search query. This avoids missing SKUs that are present on the site but weakly indexed by external search.
**Fallback ladder for blanks:** if a search does not produce a usable match, retry in this order before giving up:
1. category page
2. exact product name
3. natural Spanish grocery term
4. brand + category
5. nearest practical substitute from the same store
6. search by split tokens from the item name, not the full phrase only
7. search by pack-size phrase if the item is commonly sold in fixed packs
8. search one level broader, then narrow by brand or size

If the exact requested variant is out of stock or not found, keep searching sibling variants from the same brand/family before giving up. If you choose a different variant, label it clearly as a substitution, for example:
- `Different variant: Power Dark Chocolate`
- `Different flavor: Day Vainilla`
- `Different pack: sixpack instead of single bottle`

Never leave a price or link cell empty. If no viable match exists after the fallback ladder, write `No disponible` in the product, price, and link fields for that store so the final table stays complete.

Exact product URL is mandatory for a priced row. A row is not finished until the link cell contains a concrete product page such as `/articulo/...` or `/p/`.

If the page title, price, or product card looks correct but the URL is still a category, brand, or listing page, that is not a success. Keep searching, inspect candidate pages, and try alternative search terms until you recover the exact product page.

Do not use category, brand, or listing pages as the final answer for a priced item. If the exact product page truly cannot be recovered after the full fallback ladder, mark the row `No disponible` instead of pretending the category page is good enough.

**Key category URLs for common items:**
- Huevos: `/lista/CATG50924/HUEVOS`
- Pollo: `/lista/CATG16919/Carne-de-Pollo`
- Pescado: `/lista/CATG10138/Filetes-y-Porciones`
- Carne res: `/lista/CATG16918/Carne-de-Res`
- Yogurt griego: `/lista/CATG35334/Yogurt-Griego`
- Verduras: `/lista/CATG16680/Verduras`
- Frutas: `/lista/CATG16986/Platanos--Papayas--Pinas-y-Tropicales`, `/lista/CATG16993/Fresas-y-Arandanos`, `/lista/CATG16991/Paltas-y-Frutas-Nativas`
- Almendras: `/lista/CATG17172/Almendras`

## Workflow

### 1. Get the shopping list and the user's season

The list may come from earlier in the conversation (e.g. a shopping list already built from a meal plan), an uploaded file, or the user typing/pasting items directly. Each line item needs a name and target quantity (e.g. "Huevos — 12 unidades"). If quantities are missing, ask the user or proceed with a per-item search and note quantity math wasn't possible for that row.

**Also determine whether the user is in a cut (fat loss) or bulk (muscle gain) season** — this changes product selection, not just the shopping list contents. If it's already clear from context (an existing meal plan in the conversation, an explicit mention), use that. Otherwise ask directly before searching, since it materially changes which products get picked. This is a standing setting for the person, not a one-off — if they've stated it earlier in the conversation, don't re-ask.

### 2. Translate ingredient names to natural Spanish grocery terms

Adapt each item to the term a Peruvian shopper would actually search for, not a literal translation (e.g. "chicken breast" → "pechuga de pollo", "sweet potato" → "camote", "rice cakes" → "galletas de arroz", "almond" → "almendras").

**For items that come in packages (nuts, seeds, dried goods):** Always search for packaged products. "Almond" or "almonds" means search for "almendras" and find bagged/packaged almonds (200g, 500g, 1kg packs etc.), not loose bulk bins — these stores sell packaged nuts, not loose-weight.

**Search language rule:** use the same language and spelling the page uses, but type search queries in plain ASCII first when possible. For these stores, that means:
- `pepino`, not `pepinó`
- `galleta de arroz costeno`, not `costeño`
- `gloria pro caramel macchiato`, not accented variants

If the first query misses, retry with the accented Spanish spelling. Do both, but default to the ASCII version because it is more reliable with search tooling and page indexing.

### 2.1 Ask a clarification when the product is ambiguous

Pause and ask the user before searching when the item name is broad enough that the store could return materially different products.

- **Specific beef cuts:** ask which cut they want when the user says only `bistec` or another broad beef term. Beef cut choice changes the product and the price enough that guessing is not acceptable.
- **Products with variants:** ask which variant they prefer when the item can map to multiple real products, such as flavor, sugar level, fat level, or format. Examples: yogurt flavors, protein drink variants, bread variants, or branded packaged items with several SKUs.
- **Always include `No preference (any variant)`:** if the user does not care which variant is used, they can pick that and the skill should then choose the best match by season, availability, and price.
- **Do not ask when the product is already unambiguous:** loose produce, a single obvious packaged item, or a specific cut already named can go straight to search.

When you do ask, keep it short and specific: name the ambiguous item, show the main variant choices, and include `No preference (any variant)` as the final option.

### 3. Apply nutritional filtering by season — BEFORE picking the cheapest option

This applies whenever an item has multiple real formulation choices at a store — different flavors, sugar levels, sodium levels, or fat profiles of essentially the same product (e.g. plain vs. flavored yogurt, regular vs. light bread, salted vs. unsalted nuts). It generally does **not** apply to unformulated basics with no such variation (plain fresh produce, a single cut of raw meat with no flavor variants, plain eggs) — those just get priced normally.

**Cut (fat loss) season — prefer, in this order of importance:**
1. No added sugar / sin azúcar añadida over sweetened variants
2. Lower calories per 100g among otherwise-equivalent products
3. Lower carbohydrates for processed/packaged items specifically (not fresh produce — a potato is a potato regardless of season)
4. Lower sodium
5. Lower saturated and trans fat

**Bulk (muscle gain) season:**
- Calorie count is not a filtering criterion — don't penalize a calorie-dense option for being calorie-dense, that may be exactly what's useful.
- Still exercise basic health judgment: don't default to products that are gratuitously high in trans fat, ultra-processed with minimal nutritional value, or excessively high sodium just because they're calorie-dense. "Less calorie-restricted" is not "ignore health entirely" — a peanut butter or whole-milk yogurt over a candy-coated cereal, for the same purpose.

**How this interacts with price:** find the cheapest option *among the products that fit the season's profile*, not the cheapest option regardless of fit. If the literal cheapest SKU for an item doesn't fit (e.g. a sugary flavored yogurt is cheapest but the user is cutting), skip it and price the next-best fitting option instead — note in "Alternativas" that a cheaper but not-fitting option exists, so the user can see the tradeoff, but don't use it as the primary pick.

If a store's only available option for an item doesn't fit the season's criteria at all (e.g. only sweetened yogurt exists at Tottus that day), use it anyway rather than marking the item unavailable, but flag it explicitly in the output (e.g. "única opción disponible tenía azúcar añadida").

### 4. Search and price each item at all three stores

For every item, search and fetch at Makro, Plaza Vea, and Tottus per the site-specific steps above. For each store, identify:
- The best-matching product available (closest match to what's needed; prefer the smallest pack that still covers the needed quantity, since these are wholesale/bulk-leaning retailers with large pack sizes).
- Its pack size and price.
- Note 1-2 runner-up alternatives found at that same store, if relevant.

**Store-page bias:** for generic produce and store-brand families, use the store's own category or brand page first before relying on external web search snippets. This is especially important for:
- `pepino` and other loose produce
- `gloria pro` and other brand families with many variants
- `galleta de arroz costeno` and similar packaged snacks where the product page title may omit accents or use a shorthand family name

**Pack-size rule:** choose the pack that is both the closest practical match and the best value. Compare effective unit price before locking in the package size. If a slightly larger pack has a lower unit price and the extra quantity is reasonable, prefer that over a smaller pack with worse value. Example: if the request is for 12 units and a 15-unit pack has a lower unit price than the 12-unit pack, the 15-unit pack can win if the extra 3 units are a reasonable overbuy. 

**Multipacks vs singles:** If multipacks (sixpack, paquete 6) exist, use them. If only singles exist, buy multiple singles — works perfectly fine. Never mark as "No disponible" just because no multipack exists when singles are available. Calculate total: quantity needed × single price.

**Accent-insensitive product matching:** when a query fails, strip accents and special characters before retrying. Try both forms of the same name, for example `costeño` and `costeno`, or `plátano` and `platano`. Keep the ASCII query as the default search string.

When a page returns nothing useful, do not stop at one query. The goal is to fill as many fields as possible with real matches, not to give up early. Category pages, brand pages, and search results are only waypoints; keep searching until you have a specific product page or you have exhausted the ladder. Re-run search with singular/plural forms, common Spanish retail name, brand-only query, category-only query, category plus pack size, and item name split into tokens. Then open the top candidate pages and compare the product title, pack size, and price before deciding the row is missing.

If an item genuinely isn't available at one of the three stores after a retry, mark that cell "No disponible" for that store rather than leaving it blank or guessing — this still lets the per-store total be computed honestly (excluding that item for that store, and flagging it in the summary so the user knows that store's total is incomplete for that item).

### 5. Compute cost per item per store — whole packages only, EXCEPT genuine loose-weight produce

**Core rule: you can only buy whole packages, never a fraction of one — unless the item is fresh produce genuinely sold by loose weight.**

- **Packaged goods (meat, dairy, eggs, pantry items, anything in a bag/box/tray/pote):** even when the site shows a "Precio x kg" figure, that's almost always a *reference/comparison price* for a product sold as a fixed pack. Treat these as fixed packages: packs needed = `ceil(cantidad necesaria / tamaño del paquete)`, rounded UP, never fractional. Cost = packs needed × pack price. Note surplus (e.g. "compra 1kg, sobran 250g").
- **Small-shortfall exception:** if a single pack is within ~10% of the quantity needed (e.g. a 960g pack against a 1000g requirement), treat 1 pack as sufficient rather than mechanically rounding up to 2 — buying double to cover a 40g gap doesn't reflect how anyone actually shops. State the minor shortfall plainly (e.g. "1 pote de 960g — 40g menos de lo pedido, diferencia despreciable") instead of forcing another whole pack.
- **Fresh produce (frutas y verduras — loose vegetables, fruit, tubers sold "x kg" with no bag/tray/box in the name):** these can genuinely be bought in the exact quantity needed, like a scale-weighed item. When a loose-weight option exists alongside a pre-bagged option (both were seen for camote: a 2kg mesh bag AND a genuine "x kg" loose option), prefer pricing it as `cantidad necesaria × precio por kg` instead of forcing a whole fixed pack — this is usually cheaper and more accurate to what the person will actually pay. Still note the fixed-pack alternative in "Alternativas" in case loose isn't actually available at checkout.
- When genuinely unsure whether an "x kg" item is loose-weight or a disguised fixed pack, default to treating it as a fixed pack (the safer/more conservative assumption) and say so.

Sum all item costs (each already whole-package or correctly-prorated loose-weight cost) into a total estimated cost (soles, S/) at the end of the list.

### 6. Total each store and recommend the winner

Sum every item's cost at each store to get three grand totals (Makro total, Plaza Vea total, Tottus total). The store with the lowest total is the recommendation — call this out clearly and explicitly in both the spreadsheet and the chat response (e.g. "Plaza Vea sale más barato esta semana: S/XXX.XX frente a S/XXX.XX en Makro y S/XXX.XX en Tottus").

If an item was unavailable at the winning store, flag it explicitly: the user will need to get that one item elsewhere or substitute it, even though that store wins overall.

If some rows in a store end up as `No disponible`, still summarize that store with a normal total so the user can compare the priced rows. Mention the unavailable items separately, but do not downgrade the whole store summary to `parcial` unless the store is missing so many rows that the total would be misleading.

### 7. Build the output spreadsheet

Read the repo-local spreadsheet guide in `xlsx-guidelines.md` before creating the file — follow its formatting guidance.

**Tool availability note:** This skill uses `web_search` + `web_fetch` only. Works in all Claude environments (Claude Code CLI/VS Code/Desktop, Claude Chat). No browser agent or computer use required.

Build one sheet with these columns:

| Columna | Contenido |
|---|---|
| Ingrediente | Original ingredient name from the shopping list |
| Cantidad necesaria | Quantity needed |
| Makro — Producto | Matched product name at Makro |
| Makro — Cantidad a comprar | How many packs/units to buy at Makro (e.g. "1 paquete (30un)", "2 empaques (600g c/u)", "0.6kg suelto") — always its own column, never buried only in the Producto text |
| Makro — Precio | Whole-package cost at Makro (S/) |
| Makro — Enlace | Direct URL to the specific Makro product page |
| Plaza Vea — Producto | Matched product name at Plaza Vea |
| Plaza Vea — Cantidad a comprar | Same as above, for Plaza Vea |
| Plaza Vea — Precio | Whole-package cost at Plaza Vea (S/) |
| Plaza Vea — Enlace | Direct URL to the specific Plaza Vea product page |
| Tottus — Producto | Matched product name at Tottus |
| Tottus — Cantidad a comprar | Same as above, for Tottus |
| Tottus — Precio | Whole-package cost at Tottus (S/) |
| Tottus — Enlace | Direct URL to the specific Tottus product page |

**Every priced item must include its link, and that link must be the specific product page — never a category/listing page URL, even if the price was read from a category page.** For Makro/Plaza Vea this is the `/p` URL fetched directly. For Tottus this is the `/articulo/...` or `/p/` URL found via search (matched to the category-page price by product name), even though it wasn''t fetched directly. If no specific product URL can be found for an otherwise-matched item, keep searching before giving up; treat the row as incomplete only after the fallback ladder has been exhausted.

State the season (cut/bulk) somewhere visible in the file — e.g. in the title/first row — since it explains why certain products were picked over cheaper alternatives. In the "Producto" cell, append a short flag when a nutritional compromise was made per step 3 (e.g. "— única opción, con azúcar añadida"), so the user can see it without cross-referencing notes elsewhere.

**When a price is derived from a per-kg rate times a package/multi-pack quantity (not simply the sticker price), make that math visible, not just the final number.** State the per-kg rate and pack size in the "Producto" cell (e.g. "S/14.50/kg, Empaque 600g Aprox"), and put the actual calculation in the "Precio" cell in a way the spreadsheet shows immediately. If the workbook uses a formula, it must also include the computed numeric result so the value is visible without manual recalc. A bare formula with a blank displayed value is not acceptable.

If the store/product was found, the price cell must visibly contain a number. Do not leave a blank price cell just because the workbook formula engine did not recalculate yet.

Add a final total row summing each store's column, and highlight (e.g. bold or colored fill) whichever store total is lowest. Save the file with a timestamped name that includes the full date and time, using 24-hour `HHmmss` format, for example `Comparacion_Precios_Cut_2026-07-04_183022.xlsx`. Do not omit the hour or minute. Present the file with `present_files`.

**Local workbook generator rule:** if the workspace contains a working workbook generator script such as `make_styled_comparison.ps1`, use that script as the primary output path for generating the spreadsheet. Keep its template, styling, summary cells, and timestamp naming pattern unless the user explicitly asks for a different workbook format. Only fall back to manual workbook assembly if the script is missing or broken.

**Reference outputs rule:** if earlier successful `.xlsx` outputs from this skill exist in the workspace, use them as a reference before generating a new one. Preserve their workbook structure, styling, column ordering, and link patterns unless the user explicitly asks for a different format. Treat prior working spreadsheets as the template for what "correct" looks like in future runs.

**Success gate for reference outputs:** only treat a workbook as a successful reference if it meets both of these thresholds:
- at least 90% of the shopping-list rows were retrieved with prices across the three stores
- at least 90% of the populated store links are direct product pages, not category or brand pages

Store the run status in the summary sheet at `B9` with the label in `A9`:
- `A9 = Run status`
- `B9 = successful` or `partial`

Also store the measured rates nearby so future runs can inspect them:
- `A10 = Retrieval rate`
- `B10 = percentage`
- `A11 = Direct link rate`
- `B11 = percentage`

Only workbooks with `B9 = successful` should be used as reference outputs for future runs.

### 8. Present final results — no process explanation

**When presenting final output:**

- Show the comparison table with all prices
- State the recommended store and total costs
- Present the Excel file
- **DO NOT explain the search process**
- **DO NOT describe what you did** ("I searched X", "I found Y")
- **DO NOT narrate challenges** ("some products were hard to find")
- **DO NOT provide status updates** ("working on Makro now...")

**Just show results.** User wants final report, not implementation details.

### 8. Summarize in chat

In the chat response (not just the spreadsheet), state plainly: which store wins overall, the three totals, and any items that were unavailable at the winning store and need a workaround.

## Notes

- Prices change frequently — treat results as a snapshot at search time and say so, so the user doesn't treat the total as guaranteed at checkout.
- Don't fabricate prices, products, or links. Every row must trace back to something actually seen in a `web_search`/`web_fetch` result. If unsure, mark as not found rather than guessing.
- This skill is Peru-specific to these three retailers. A request naming a different store or country is a new, unrelated search task.

