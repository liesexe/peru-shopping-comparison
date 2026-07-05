# Peru Shopping Comparison

Codex skill package for comparing grocery lists across Makro, Plaza Vea, and Tottus in Peru.

## Contents

- `SKILL.md`: the skill instructions Codex loads
- `make_styled_comparison.ps1`: the workbook generator used by the skill

## Repository layout

This repository is intentionally flat. Keep `SKILL.md` and `make_styled_comparison.ps1` at the repo root so the package is easy to publish, install, and sync.

## Local install

To use the skill locally, copy this repo into the Codex skill root:

`C:\Users\ferna\.codex\skills\peru-shopping-comparsion`

## Notes

- Keep `SKILL.md` and `make_styled_comparison.ps1` in sync.
- The generator preserves the styled workbook template and timestamped filenames.
- Only treat workbook outputs as reusable references when the success gate in the summary sheet says `successful`.
