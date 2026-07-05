#!/usr/bin/env bash
# Install peru-shopping-comparison skill to Claude Code and/or Codex

set -e

SKILL_NAME="peru-shopping-comparison"
INSTALLATIONS=()

# Detect Claude Code
if [ -d "$HOME/.claude" ]; then
    INSTALLATIONS+=("Claude Code|$HOME/.claude/skills")
fi

# Detect Codex
if [ -d "$HOME/.codex" ]; then
    INSTALLATIONS+=("OpenAI Codex|$HOME/.codex/skills")
fi

if [ ${#INSTALLATIONS[@]} -eq 0 ]; then
    echo "✗ No installations found"
    echo "  Install Claude Code or Codex first"
    exit 1
fi

echo "Found ${#INSTALLATIONS[@]} installation(s):"
for install in "${INSTALLATIONS[@]}"; do
    IFS='|' read -r name path <<< "$install"
    echo "  - $name"
done
echo ""

# Fetch SKILL.md from GitHub (if piped) or use local
if [ -n "${BASH_SOURCE[0]}" ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/SKILL.md" ]; then
    # Local execution
    SOURCE_FILE="$(dirname "${BASH_SOURCE[0]}")/SKILL.md"
else
    # Remote execution (piped from web)
    echo "→ Downloading SKILL.md from GitHub..."
    TEMP_FILE="/tmp/peru-shopping-comparison-SKILL.md"
    if ! curl -fsSL "https://raw.githubusercontent.com/liesexe/peru-shopping-comparison/main/SKILL.md" -o "$TEMP_FILE"; then
        echo "✗ Failed to download SKILL.md"
        exit 1
    fi
    SOURCE_FILE="$TEMP_FILE"
fi

# Install to each detected installation
INSTALLED_COUNT=0
for install in "${INSTALLATIONS[@]}"; do
    IFS='|' read -r name path <<< "$install"
    TARGET_DIR="$path/$SKILL_NAME"
    TARGET_FILE="$TARGET_DIR/SKILL.md"

    # Create skills directory if doesn't exist
    mkdir -p "$path"

    # Check if updating existing installation
    if [ -f "$TARGET_FILE" ]; then
        IS_UPDATE=true
    else
        IS_UPDATE=false
        mkdir -p "$TARGET_DIR"
    fi

    # Copy SKILL.md
    cp "$SOURCE_FILE" "$TARGET_FILE"

    if [ "$IS_UPDATE" = true ]; then
        echo "✓ Updated in $name"
    else
        echo "✓ Installed to $name"
    fi

    ((INSTALLED_COUNT++))
done

echo ""
echo "Installed to $INSTALLED_COUNT installation(s)"
echo ""
echo "Usage:"
echo "  /peru-shopping"
echo "  /compare-prices"
echo ""
echo "Restart Claude Code or Codex to load skill"

# Cleanup temp file if remote install
if [ -n "$TEMP_FILE" ] && [ -f "$TEMP_FILE" ]; then
    rm -f "$TEMP_FILE"
fi
