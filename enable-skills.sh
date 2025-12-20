#!/bin/bash
# Enable global Claude Code skills in the current directory

set -e  # Exit on error

# Use CLAUDE_METADATA if set, otherwise fall back to default
if [ -z "$CLAUDE_METADATA" ]; then
    echo "ERROR: CLAUDE_METADATA environment variable is not set"
    echo "Please set it in your shell configuration:"
    echo "  export CLAUDE_METADATA=\"\$HOME/path/to/claude_data\""
    exit 1
fi

GLOBAL_SKILLS_DIR="$CLAUDE_METADATA/.claude/skills"
TARGET_DIR=".claude/skills"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=================================================="
echo "  Claude Code Global Skills Enabler"
echo "=================================================="
echo ""

# Check if we're in a valid directory
if [ "$PWD" = "$CLAUDE_METADATA" ]; then
    echo -e "${YELLOW}⚠  You're already in the global skills directory!${NC}"
    echo "   Skills are automatically available here."
    echo ""
    echo "   To use in another project, run this script from that directory:"
    echo "   cd /path/to/your/project"
    echo "   bash \$CLAUDE_METADATA/enable-skills.sh"
    exit 0
fi

# Check if global skills directory exists
if [ ! -d "$GLOBAL_SKILLS_DIR" ]; then
    echo -e "${RED}✗ Global skills directory not found!${NC}"
    echo "   Expected: $GLOBAL_SKILLS_DIR"
    exit 1
fi

echo "Current directory: $PWD"
echo "Global skills: $GLOBAL_SKILLS_DIR"
echo ""

# Create .claude/skills directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Check what skills are available
echo "Available global skills:"
for skill in "$GLOBAL_SKILLS_DIR"/*; do
    if [ -d "$skill" ]; then
        skill_name=$(basename "$skill")
        echo "  - $skill_name"
    fi
done
echo ""

# Ask user what to do
echo "How would you like to enable these skills?"
echo "  1) Symlink (recommended - stays updated with global changes)"
echo "  2) Copy (independent - won't update automatically)"
echo "  3) Cancel"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "Creating symlinks..."
        for skill in "$GLOBAL_SKILLS_DIR"/*; do
            if [ -d "$skill" ]; then
                skill_name=$(basename "$skill")
                target_link="$TARGET_DIR/$skill_name"

                # Remove existing symlink or directory if it exists
                if [ -L "$target_link" ]; then
                    echo "  Removing existing symlink: $skill_name"
                    rm "$target_link"
                elif [ -d "$target_link" ]; then
                    echo -e "${YELLOW}  Directory already exists: $skill_name (skipping)${NC}"
                    continue
                fi

                # Create symlink
                ln -s "$skill" "$target_link"
                echo -e "${GREEN}  ✓ Linked: $skill_name${NC}"
            fi
        done
        echo ""
        echo -e "${GREEN}✓ Skills enabled via symlink!${NC}"
        echo "  Skills will auto-update when global skills are updated."
        ;;

    2)
        echo ""
        echo "Copying skills..."
        for skill in "$GLOBAL_SKILLS_DIR"/*; do
            if [ -d "$skill" ]; then
                skill_name=$(basename "$skill")
                target_dir="$TARGET_DIR/$skill_name"

                if [ -d "$target_dir" ] && [ ! -L "$target_dir" ]; then
                    echo -e "${YELLOW}  Directory already exists: $skill_name (skipping)${NC}"
                    continue
                fi

                # Remove existing symlink if it exists
                if [ -L "$target_dir" ]; then
                    rm "$target_dir"
                fi

                # Copy directory
                cp -r "$skill" "$target_dir"
                echo -e "${GREEN}  ✓ Copied: $skill_name${NC}"
            fi
        done
        echo ""
        echo -e "${GREEN}✓ Skills copied!${NC}"
        echo "  Note: These are independent copies and won't auto-update."
        ;;

    3)
        echo ""
        echo "Cancelled."
        exit 0
        ;;

    *)
        echo ""
        echo -e "${RED}Invalid choice. Cancelled.${NC}"
        exit 1
        ;;
esac

echo ""
echo "=================================================="
echo "  Setup Complete!"
echo "=================================================="
echo ""
echo "Skills are now available in: $PWD"
echo ""
echo "To verify, open Claude Code in this directory and ask:"
echo '  "What skills are loaded?"'
echo ""
echo "To disable token optimization for a specific request:"
echo '  "Show me the full log file (don'\''t worry about tokens)"'
echo ""
