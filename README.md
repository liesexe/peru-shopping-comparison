# Peru Shopping Comparison

Skill for comparing grocery prices across Peru's major supermarkets: Makro, Plaza Vea, and Tottus.

Works with **Claude Code** and **OpenAI Codex**.

## What it does

Prices an entire shopping list against all three stores and recommends **the single cheapest store for the full trip** — because splitting one shopping run across multiple stores costs more time than it saves in money.

**Key features:**
- ✅ Searches all 3 stores simultaneously using web_search + web_fetch
- ✅ Handles 404 errors with smart fallback workflows (brand pages, category pages)
- ✅ Supports both multipacks and individual units
- ✅ Generates styled Excel comparison with direct product links
- ✅ Works in Claude Code, OpenAI Codex, Claude Chat, and any Claude environment with web access

## Installation

### Claude Desktop Upload

Upload directly to Claude Desktop via Settings:

1. **Package the skill:**
   ```powershell
   .\package.ps1
   ```
   Creates `peru-shopping-comparison.zip`

2. **Upload:**
   - Claude Desktop → Settings → Customize → Skills
   - Upload `peru-shopping-comparison.zip`

### One Command (CLI Installation)

**Windows (PowerShell 5.1+):**
```powershell
irm https://raw.githubusercontent.com/liesexe/peru-shopping-comparison/main/install.ps1 | iex
```

**macOS / Linux / WSL / Git Bash:**
```bash
curl -fsSL https://raw.githubusercontent.com/liesexe/peru-shopping-comparison/main/install.sh | bash
```

Detects and installs to:
- Claude Code: `~/.claude/skills/`
- OpenAI Codex: `~/.codex/skills/`

### Local Install

Run the install script from this repository:

```powershell
.\install.ps1
```

### Manual

1. Create skill directory:
   ```powershell
   mkdir $env:USERPROFILE\.claude\skills\peru-shopping-comparison
   ```

2. Copy `SKILL.md` to the directory:
   ```powershell
   copy SKILL.md $env:USERPROFILE\.claude\skills\peru-shopping-comparison\
   ```

3. Restart Claude Code

## Usage

Invoke the skill with either trigger:

```
/peru-shopping
/compare-prices
```

Then provide your shopping list:
```
Atún en lata - 6 latas
Yogur griego - 1000 g
Palta - 700 g
Tomate - 880 g
```

The skill will:
1. Search all 3 stores for each item
2. Extract exact prices
3. Calculate total cost per store
4. Recommend cheapest option
5. Generate Excel spreadsheet with all data

## How it works

### Store-specific workflows

**Tottus** (most reliable):
- Direct category page fetching
- URLs from search work immediately
- High success rate

**Makro & Plaza Vea** (requires brand-page workflow):
- Many `/p` URLs from search return 404
- Working URLs have numeric product IDs (e.g., `-20502734`)
- Falls back to brand/category pages to extract valid URLs
- Singles multiplication when multipacks unavailable

### Fallback logic

When product not found:
1. Try direct product URL from search
2. If 404 → fetch brand/category page
3. Extract URLs with numeric SKUs
4. Fetch product pages with IDs
5. If only singles exist → multiply by quantity needed
6. If still not found → mark "No disponible"

## Repository structure

```
peru-shopping-comparison/
├── SKILL.md                    # Main skill definition (required)
├── make_styled_comparison.ps1  # Excel generator (optional, enhances output)
├── xlsx-guidelines.md          # Spreadsheet formatting rules
├── install.ps1                 # Automated CLI installer
├── install.sh                  # Automated CLI installer (Unix)
├── package.ps1                 # Creates .zip for Claude Desktop upload
└── README.md                   # This file
```

**Layout notes:**
- Flat structure for easy distribution
- Runtime files packaged together: `SKILL.md`, `make_styled_comparison.ps1`, `xlsx-guidelines.md`
- Install scripts (`install.ps1`, `install.sh`) only needed for CLI installation
- Package script (`package.ps1`) only needed for creating upload .zip

## Requirements

- **Claude Code**, **OpenAI Codex**, or **Claude Chat** with web_search + web_fetch enabled
- Internet connection (fetches live prices from store websites)
- PowerShell (for Excel generation, optional)

## Files

| File | Purpose | Required |
|------|---------|----------|
| `SKILL.md` | Core skill instructions | ✅ Yes |
| `make_styled_comparison.ps1` | Generates styled Excel workbook | ✅ Yes (runtime) |
| `xlsx-guidelines.md` | Spreadsheet formatting reference | ✅ Yes (runtime) |
| `install.ps1` | Automated CLI installer (Windows) | ⚪ No (install only) |
| `install.sh` | Automated CLI installer (Unix) | ⚪ No (install only) |
| `package.ps1` | Creates .zip for Claude Desktop upload | ⚪ No (packaging only) |

## Troubleshooting

**Skill not showing up:**
- Restart Claude Code after installation
- Check file is at `~/.claude/skills/peru-shopping-comparison/SKILL.md`
- Verify SKILL.md has proper frontmatter (lines 1-7)

**Prices not found:**
- Some products may be out of stock or discontinued
- Skill will mark "No disponible" and continue
- Try alternative product names or brands

**404 errors on Makro/Plaza Vea:**
- Expected behavior - skill handles via brand-page fallback
- Working URLs extracted automatically from category pages

## Notes

- Prices are live from store websites (may change)
- Stock status unreliable (treat as informational only)
- Excel output only generated if PowerShell script available
- Skill prioritizes Tottus for efficiency (highest success rate)

## License

MIT
