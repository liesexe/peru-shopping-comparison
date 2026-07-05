#!/usr/bin/env bash
# Install peru-shopping-comparison skill to Claude Code

set -e

SKILL_NAME="peru-shopping-comparison"
SKILLS_DIR="$HOME/.claude/skills"
TARGET_DIR="$SKILLS_DIR/$SKILL_NAME"
TARGET_FILE="$TARGET_DIR/SKILL.md"

# Check if Claude Code is installed
if [ ! -d "$HOME/.claude" ]; then
    echo "✗ Claude Code not found"
    echo "  Install Claude Code first: https://claude.ai/download"
    exit 1
fi

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

# Create skills directory if doesn't exist
mkdir -p "$SKILLS_DIR"

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
    echo "✓ Updated peru-shopping-comparison"
else
    echo "✓ Installed peru-shopping-comparison to $TARGET_DIR"
fi

echo ""
echo "Usage:"
echo "  /peru-shopping"
echo "  /compare-prices"
echo ""
echo "Restart Claude Code to load skill"

# Cleanup temp file if remote install
if [ -n "$TEMP_FILE" ] && [ -f "$TEMP_FILE" ]; then
    rm -f "$TEMP_FILE"
fi
