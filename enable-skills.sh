#!/bin/bash
# Enable global Claude Code skills and commands in the current directory

set -e  # Exit on error

# Use CLAUDE_METADATA if set, otherwise fall back to default
if [ -z "$CLAUDE_METADATA" ]; then
    echo "ERROR: CLAUDE_METADATA environment variable is not set"
    echo "Please set it in your shell configuration:"
    echo "  export CLAUDE_METADATA=\"\$HOME/path/to/claude_data\""
    exit 1
fi

GLOBAL_SKILLS_DIR="$CLAUDE_METADATA/skills"
GLOBAL_COMMANDS_DIR="$CLAUDE_METADATA/commands/global"
TARGET_SKILLS_DIR=".claude/skills"
TARGET_COMMANDS_DIR=".claude/commands"

# Essential skills that should always be included
ESSENTIAL_SKILLS=("claude-meta/token-efficiency" "claude-meta/collaboration" "project-management/managing-environments" "project-management/folder-organization")

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=================================================="
echo "  Claude Code Project Setup"
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

# Check if global commands directory exists
if [ ! -d "$GLOBAL_COMMANDS_DIR" ]; then
    echo -e "${YELLOW}⚠  Global commands directory not found: $GLOBAL_COMMANDS_DIR${NC}"
    echo "   Continuing with skills only..."
    COMMANDS_AVAILABLE=false
else
    COMMANDS_AVAILABLE=true
fi

echo "Current directory: $PWD"
echo "Global skills: $GLOBAL_SKILLS_DIR"
if [ "$COMMANDS_AVAILABLE" = true ]; then
    echo "Global commands: $GLOBAL_COMMANDS_DIR"
fi
echo ""

# Create directories if they don't exist
mkdir -p "$TARGET_SKILLS_DIR"
if [ "$COMMANDS_AVAILABLE" = true ]; then
    mkdir -p "$TARGET_COMMANDS_DIR"
fi

# Show available skills
echo -e "${BLUE}Available skills in \$CLAUDE_METADATA:${NC}"
AVAILABLE_SKILLS=()
for category in "$GLOBAL_SKILLS_DIR"/*; do
    if [ -d "$category" ]; then
        category_name=$(basename "$category")

        # Skip INDEX.md if it's picked up
        if [ "$category_name" = "INDEX.md" ]; then
            continue
        fi

        # List skills in this category
        for skill in "$category"/*; do
            if [ -d "$skill" ]; then
                skill_name="$category_name/$(basename "$skill")"
                AVAILABLE_SKILLS+=("$skill_name")

                # Mark essential skills
                is_essential=false
                for essential in "${ESSENTIAL_SKILLS[@]}"; do
                    if [ "$skill_name" = "$essential" ]; then
                        echo -e "  ${GREEN}✓${NC} $skill_name ${YELLOW}(essential)${NC}"
                        is_essential=true
                        break
                    fi
                done

                if [ "$is_essential" = false ]; then
                    echo "    $skill_name"
                fi
            fi
        done
    fi
done
echo ""

# Show available commands
if [ "$COMMANDS_AVAILABLE" = true ]; then
    echo -e "${BLUE}Global commands available:${NC}"
    COMMAND_COUNT=0
    for cmd in "$GLOBAL_COMMANDS_DIR"/*.md; do
        if [ -f "$cmd" ]; then
            cmd_name=$(basename "$cmd" .md)
            echo "  - /$cmd_name"
            ((COMMAND_COUNT++))
        fi
    done
    echo ""
fi

# Ask user what to do
echo "Setup options:"
echo "  1) Full setup (essential skills + all global commands + choose additional skills)"
echo "  2) Essential only (token-efficiency, collaboration, managing-environments, folder-organization + all global commands)"
echo "  3) Custom selection (choose specific skills + all global commands)"
echo "  4) Cancel"
echo ""
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}Setting up essential skills...${NC}"

        # Symlink essential skills
        for skill_path in "${ESSENTIAL_SKILLS[@]}"; do
            skill_name=$(basename "$skill_path")
            target_link="$TARGET_SKILLS_DIR/$skill_name"
            source_skill="$GLOBAL_SKILLS_DIR/$skill_path"

            if [ ! -d "$source_skill" ]; then
                echo -e "${YELLOW}  ⚠ Essential skill not found: $skill_path (skipping)${NC}"
                continue
            fi

            if [ -L "$target_link" ]; then
                echo "  Already linked: $skill_name"
            elif [ -d "$target_link" ]; then
                echo -e "${RED}  ✗ Directory exists (not a symlink): $skill_name${NC}"
                echo "    Remove it manually or it won't auto-update!"
            else
                ln -s "$source_skill" "$target_link"
                echo -e "${GREEN}  ✓ Linked: $skill_name (from $skill_path)${NC}"
            fi
        done

        # Symlink global commands
        if [ "$COMMANDS_AVAILABLE" = true ]; then
            echo ""
            echo -e "${BLUE}Setting up global commands...${NC}"
            for cmd in "$GLOBAL_COMMANDS_DIR"/*.md; do
                if [ -f "$cmd" ]; then
                    cmd_name=$(basename "$cmd")
                    target_link="$TARGET_COMMANDS_DIR/$cmd_name"

                    if [ -L "$target_link" ]; then
                        echo "  Already linked: $cmd_name"
                    elif [ -f "$target_link" ]; then
                        echo -e "${RED}  ✗ File exists (not a symlink): $cmd_name${NC}"
                    else
                        ln -s "$cmd" "$target_link"
                        echo -e "${GREEN}  ✓ Linked: /$cmd_name${NC}"
                    fi
                fi
            done
        fi

        # Ask about additional skills
        echo ""
        echo -e "${BLUE}Additional skills available:${NC}"
        ADDITIONAL_SKILLS=()
        for skill_name in "${AVAILABLE_SKILLS[@]}"; do
            is_essential=false
            for essential in "${ESSENTIAL_SKILLS[@]}"; do
                if [ "$skill_name" = "$essential" ]; then
                    is_essential=true
                    break
                fi
            done

            if [ "$is_essential" = false ]; then
                ADDITIONAL_SKILLS+=("$skill_name")
                echo "  - $skill_name"
            fi
        done

        if [ ${#ADDITIONAL_SKILLS[@]} -gt 0 ]; then
            echo ""
            read -p "Link additional skills? (y/n): " link_more

            if [[ "$link_more" =~ ^[Yy]$ ]]; then
                echo ""
                echo "Enter skill names (space-separated) or 'all' for all skills:"
                read -p "> " selected_skills

                if [ "$selected_skills" = "all" ]; then
                    for skill_path in "${ADDITIONAL_SKILLS[@]}"; do
                        skill_name=$(basename "$skill_path")
                        target_link="$TARGET_SKILLS_DIR/$skill_name"
                        source_skill="$GLOBAL_SKILLS_DIR/$skill_path"

                        if [ -L "$target_link" ]; then
                            echo "  Already linked: $skill_name"
                        elif [ -d "$target_link" ]; then
                            echo -e "${RED}  ✗ Directory exists: $skill_name${NC}"
                        else
                            ln -s "$source_skill" "$target_link"
                            echo -e "${GREEN}  ✓ Linked: $skill_name (from $skill_path)${NC}"
                        fi
                    done
                else
                    for skill_input in $selected_skills; do
                        # Support both "category/skill" and "skill" formats
                        if [[ "$skill_input" == *"/"* ]]; then
                            skill_path="$skill_input"
                            skill_name=$(basename "$skill_path")
                        else
                            # Try to find the skill in any category
                            skill_name="$skill_input"
                            skill_path=""
                            for avail_skill in "${AVAILABLE_SKILLS[@]}"; do
                                if [ "$(basename "$avail_skill")" = "$skill_name" ]; then
                                    skill_path="$avail_skill"
                                    break
                                fi
                            done

                            if [ -z "$skill_path" ]; then
                                echo -e "${RED}  ✗ Skill not found: $skill_name${NC}"
                                continue
                            fi
                        fi

                        target_link="$TARGET_SKILLS_DIR/$skill_name"
                        source_skill="$GLOBAL_SKILLS_DIR/$skill_path"

                        if [ ! -d "$source_skill" ]; then
                            echo -e "${RED}  ✗ Skill not found: $skill_path${NC}"
                            continue
                        fi

                        if [ -L "$target_link" ]; then
                            echo "  Already linked: $skill_name"
                        elif [ -d "$target_link" ]; then
                            echo -e "${RED}  ✗ Directory exists: $skill_name${NC}"
                        else
                            ln -s "$source_skill" "$target_link"
                            echo -e "${GREEN}  ✓ Linked: $skill_name (from $skill_path)${NC}"
                        fi
                    done
                fi
            fi
        fi
        ;;

    2)
        echo ""
        echo -e "${BLUE}Setting up essential skills...${NC}"

        # Symlink essential skills
        for skill_path in "${ESSENTIAL_SKILLS[@]}"; do
            skill_name=$(basename "$skill_path")
            target_link="$TARGET_SKILLS_DIR/$skill_name"
            source_skill="$GLOBAL_SKILLS_DIR/$skill_path"

            if [ ! -d "$source_skill" ]; then
                echo -e "${YELLOW}  ⚠ Essential skill not found: $skill_path (skipping)${NC}"
                continue
            fi

            if [ -L "$target_link" ]; then
                echo "  Already linked: $skill_name"
            elif [ -d "$target_link" ]; then
                echo -e "${RED}  ✗ Directory exists (not a symlink): $skill_name${NC}"
            else
                ln -s "$source_skill" "$target_link"
                echo -e "${GREEN}  ✓ Linked: $skill_name (from $skill_path)${NC}"
            fi
        done

        # Symlink global commands
        if [ "$COMMANDS_AVAILABLE" = true ]; then
            echo ""
            echo -e "${BLUE}Setting up global commands...${NC}"
            for cmd in "$GLOBAL_COMMANDS_DIR"/*.md; do
                if [ -f "$cmd" ]; then
                    cmd_name=$(basename "$cmd")
                    target_link="$TARGET_COMMANDS_DIR/$cmd_name"

                    if [ -L "$target_link" ]; then
                        echo "  Already linked: $cmd_name"
                    elif [ -f "$target_link" ]; then
                        echo -e "${RED}  ✗ File exists (not a symlink): $cmd_name${NC}"
                    else
                        ln -s "$cmd" "$target_link"
                        echo -e "${GREEN}  ✓ Linked: /$cmd_name${NC}"
                    fi
                fi
            done
        fi
        ;;

    3)
        echo ""
        echo "Enter skill names (space-separated, can use 'category/skill' or just 'skill') or 'all' for all skills:"
        read -p "> " selected_skills

        echo ""
        echo -e "${BLUE}Setting up selected skills...${NC}"

        if [ "$selected_skills" = "all" ]; then
            for skill_path in "${AVAILABLE_SKILLS[@]}"; do
                skill_name=$(basename "$skill_path")
                target_link="$TARGET_SKILLS_DIR/$skill_name"
                source_skill="$GLOBAL_SKILLS_DIR/$skill_path"

                if [ -L "$target_link" ]; then
                    echo "  Already linked: $skill_name"
                elif [ -d "$target_link" ]; then
                    echo -e "${RED}  ✗ Directory exists: $skill_name${NC}"
                else
                    ln -s "$source_skill" "$target_link"
                    echo -e "${GREEN}  ✓ Linked: $skill_name (from $skill_path)${NC}"
                fi
            done
        else
            for skill_input in $selected_skills; do
                # Support both "category/skill" and "skill" formats
                if [[ "$skill_input" == *"/"* ]]; then
                    skill_path="$skill_input"
                    skill_name=$(basename "$skill_path")
                else
                    # Try to find the skill in any category
                    skill_name="$skill_input"
                    skill_path=""
                    for avail_skill in "${AVAILABLE_SKILLS[@]}"; do
                        if [ "$(basename "$avail_skill")" = "$skill_name" ]; then
                            skill_path="$avail_skill"
                            break
                        fi
                    done

                    if [ -z "$skill_path" ]; then
                        echo -e "${RED}  ✗ Skill not found: $skill_name${NC}"
                        continue
                    fi
                fi

                target_link="$TARGET_SKILLS_DIR/$skill_name"
                source_skill="$GLOBAL_SKILLS_DIR/$skill_path"

                if [ ! -d "$source_skill" ]; then
                    echo -e "${RED}  ✗ Skill not found: $skill_path${NC}"
                    continue
                fi

                if [ -L "$target_link" ]; then
                    echo "  Already linked: $skill_name"
                elif [ -d "$target_link" ]; then
                    echo -e "${RED}  ✗ Directory exists: $skill_name${NC}"
                else
                    ln -s "$source_skill" "$target_link"
                    echo -e "${GREEN}  ✓ Linked: $skill_name (from $skill_path)${NC}"
                fi
            done
        fi

        # Symlink global commands
        if [ "$COMMANDS_AVAILABLE" = true ]; then
            echo ""
            echo -e "${BLUE}Setting up global commands...${NC}"
            for cmd in "$GLOBAL_COMMANDS_DIR"/*.md; do
                if [ -f "$cmd" ]; then
                    cmd_name=$(basename "$cmd")
                    target_link="$TARGET_COMMANDS_DIR/$cmd_name"

                    if [ -L "$target_link" ]; then
                        echo "  Already linked: $cmd_name"
                    elif [ -f "$target_link" ]; then
                        echo -e "${RED}  ✗ File exists (not a symlink): $cmd_name${NC}"
                    else
                        ln -s "$cmd" "$target_link"
                        echo -e "${GREEN}  ✓ Linked: /$cmd_name${NC}"
                    fi
                fi
            done
        fi
        ;;

    4)
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

# Show what was set up
LINKED_SKILLS=$(find "$TARGET_SKILLS_DIR" -maxdepth 1 -type l 2>/dev/null | wc -l | xargs)
echo -e "Skills linked: ${GREEN}$LINKED_SKILLS${NC}"

if [ "$COMMANDS_AVAILABLE" = true ]; then
    LINKED_COMMANDS=$(find "$TARGET_COMMANDS_DIR" -maxdepth 1 -type l -name "*.md" 2>/dev/null | wc -l | xargs)
    echo -e "Commands linked: ${GREEN}$LINKED_COMMANDS${NC}"
    echo ""
    echo "Available commands:"
    for cmd in "$TARGET_COMMANDS_DIR"/*.md; do
        if [ -L "$cmd" ]; then
            cmd_name=$(basename "$cmd" .md)
            echo "  - /$cmd_name"
        fi
    done
fi

echo ""
echo "Location: $PWD/.claude/"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Open Claude Code in this directory"
echo "  2. Use /list-skills to see all available skills"
echo "  3. Use /sync-skills to add more skills later"
echo ""
echo -e "${YELLOW}Remember:${NC} All skills are symlinked from \$CLAUDE_METADATA"
echo "  - They auto-update when global skills are updated"
echo "  - Never create local skill files (always use symlinks)"
echo ""
