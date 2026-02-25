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
ESSENTIAL_SKILLS=(
    "claude-meta/token-efficiency"
    "claude-meta/collaboration"
    "project-management/folder-organization"
    "project-management/managing-environments"
    "project-management/obsidian"
    "project-management/data-backup"
    "collaboration/hackmd"
    "collaboration/project-sharing"
)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to set up Obsidian integration
setup_obsidian() {
    echo ""
    echo -e "${BLUE}Obsidian Integration Setup${NC}"
    echo ""
    echo "Would you like to set up an Obsidian folder for this project?"
    echo "This will store session notes, decisions, and project documentation."
    echo ""
    read -p "Set up Obsidian folder? (y/n/skip) [n]: " obsidian_choice
    obsidian_choice=${obsidian_choice:-n}

    if [[ "$obsidian_choice" =~ ^[Yy]$ ]]; then
        # Check if OBSIDIAN_VAULT is set
        if [ -z "$OBSIDIAN_VAULT" ]; then
            echo -e "${YELLOW}⚠  OBSIDIAN_VAULT environment variable not set${NC}"
            echo "Please set OBSIDIAN_VAULT to your Obsidian vault path in your shell config"
            echo "Example: export OBSIDIAN_VAULT=\"\$HOME/Documents/ObsidianVault\""
            echo ""
            read -p "Enter Obsidian vault path (or press Enter to skip): " VAULT_PATH

            if [ -z "$VAULT_PATH" ]; then
                echo "Skipping Obsidian setup"
                return
            else
                export OBSIDIAN_VAULT="$VAULT_PATH"
            fi
        fi

        if [ -n "$OBSIDIAN_VAULT" ]; then
            # Show vault structure
            echo ""
            echo "📁 Current vault structure:"
            if [ -d "$OBSIDIAN_VAULT" ]; then
                echo "   $(basename "$OBSIDIAN_VAULT")/"
                for dir in "$OBSIDIAN_VAULT"/*; do
                    if [ -d "$dir" ] && [[ "$(basename "$dir")" != .* ]]; then
                        echo "   ├── $(basename "$dir")/"
                    fi
                done | head -10
            else
                echo "   (Vault not found)"
            fi

            echo ""
            echo "Project folder name for Obsidian:"
            echo "  Suggested: $(basename "$PWD")"
            echo ""
            read -p "Enter project name [$(basename "$PWD")]: " PROJECT_NAME
            PROJECT_NAME=${PROJECT_NAME:-$(basename "$PWD")}

            echo ""
            echo "Where should this project's notes be stored?"
            echo ""
            echo "Options:"
            echo "  1. Root level (vault/$PROJECT_NAME/)"
            echo "  2. Custom path (e.g., vault/Work/$PROJECT_NAME/)"
            echo ""
            read -p "Enter choice [1-2] [1]: " DIR_CHOICE
            DIR_CHOICE=${DIR_CHOICE:-1}

            if [ "$DIR_CHOICE" = "2" ]; then
                echo ""
                echo "Enter parent directory path (relative to vault root)."
                echo "Examples: Work, Projects/Active, Personal/Research"
                echo ""
                read -p "Parent directory: " PARENT_DIR
                PARENT_DIR=$(echo "$PARENT_DIR" | sed 's:^/::; s:/$::')
                OBSIDIAN_PATH="$PARENT_DIR/$PROJECT_NAME"
            else
                OBSIDIAN_PATH="$PROJECT_NAME"
            fi

            # Save configuration
            mkdir -p .claude
            cat > .claude/project-config << EOF
obsidian_project=$PROJECT_NAME
obsidian_path=$OBSIDIAN_PATH
EOF

            echo ""
            echo -e "${GREEN}✓ Obsidian configuration saved${NC}"
            echo "  Project name: $PROJECT_NAME"
            echo "  Vault path: $OBSIDIAN_PATH"
            echo "  Notes will be saved to: \$OBSIDIAN_VAULT/$OBSIDIAN_PATH/"
        fi
    else
        echo "Skipping Obsidian setup (can be configured later with /safe-exit or /safe-clear)"
    fi
}

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

# Detect project type
echo -e "${BLUE}Project Type Detection${NC}"
echo ""
echo "What type of project is this?"
echo "  1) Analysis/Research (Jupyter notebooks, data analysis)"
echo "  2) Development (Software/library development)"
echo "  3) Bioinformatics (Galaxy, VGP, genomics workflows)"
echo "  4) Other/Mixed (I'll choose skills manually)"
echo ""
read -p "Enter project type [1-4] [4]: " project_type
project_type=${project_type:-4}

# Set additional suggested skills based on project type
SUGGESTED_SKILLS=()
case $project_type in
    1)
        echo ""
        echo -e "${YELLOW}Analysis/Research project detected${NC}"
        echo "Suggested additional skills:"
        echo "  - analysis/jupyter-notebook (notebook best practices)"
        echo "  - analysis/data-analysis-patterns (data handling patterns)"
        echo "  - analysis/data-visualization (publication figures)"
        echo "  - analysis/scientific-publication (figure refinement)"
        echo "  - analysis/documentation-organization (organize project docs)"
        echo ""
        SUGGESTED_SKILLS=(
            "analysis/jupyter-notebook"
            "analysis/data-analysis-patterns"
            "analysis/data-visualization"
            "analysis/scientific-publication"
            "analysis/documentation-organization"
        )
        ;;
    2)
        echo ""
        echo -e "${YELLOW}Development project detected${NC}"
        echo "Suggested additional skills:"
        echo "  - packaging/conda-recipe (if building conda packages)"
        echo ""
        SUGGESTED_SKILLS=(
            "packaging/conda-recipe"
        )
        ;;
    3)
        echo ""
        echo -e "${YELLOW}Bioinformatics project detected${NC}"
        echo "Suggested additional skills:"
        echo "  - bioinformatics/fundamentals (SAM/BAM, AGP, sequencing)"
        echo "  - bioinformatics/vgp-pipeline (VGP genome assembly)"
        echo "  - galaxy/tool-wrapping (Galaxy tool development)"
        echo "  - galaxy/workflow-development (Galaxy workflows)"
        echo "  - galaxy/automation (BioBlend, Planemo)"
        echo ""
        SUGGESTED_SKILLS=(
            "bioinformatics/fundamentals"
            "galaxy/tool-wrapping"
            "galaxy/workflow-development"
            "galaxy/automation"
        )
        ;;
    4)
        echo ""
        echo -e "${YELLOW}You'll be able to choose specific skills in the next step${NC}"
        echo ""
        ;;
esac

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
echo "  2) Essential only (8 essential skills: claude-meta, project-management, collaboration + all global commands)"
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

        # Symlink global settings
        echo ""
        echo -e "${BLUE}Setting up global settings...${NC}"
        GLOBAL_SETTINGS="$CLAUDE_METADATA/.claude/settings.local.json"
        TARGET_SETTINGS=".claude/settings.local.json"

        if [ -f "$GLOBAL_SETTINGS" ]; then
            if [ -f "$TARGET_SETTINGS" ] && [ ! -L "$TARGET_SETTINGS" ]; then
                echo -e "${YELLOW}  ⚠ Backing up existing settings.local.json${NC}"
                mv "$TARGET_SETTINGS" "$TARGET_SETTINGS.backup"
            fi

            if [ -L "$TARGET_SETTINGS" ]; then
                echo "  Already linked: settings.local.json"
            elif [ -f "$TARGET_SETTINGS" ]; then
                echo -e "${RED}  ✗ File exists (not a symlink): settings.local.json${NC}"
            else
                ln -s "$GLOBAL_SETTINGS" "$TARGET_SETTINGS"
                echo -e "${GREEN}  ✓ Linked: settings.local.json (permissions will sync)${NC}"
            fi
        else
            echo -e "${YELLOW}  ⚠ Global settings not found (skipping)${NC}"
        fi

        # Set up Obsidian integration
        setup_obsidian

        # Link suggested skills based on project type
        if [ ${#SUGGESTED_SKILLS[@]} -gt 0 ]; then
            echo ""
            read -p "Link suggested skills for this project type? (y/n) [y]: " link_suggested
            link_suggested=${link_suggested:-y}

            if [[ "$link_suggested" =~ ^[Yy]$ ]]; then
                echo ""
                echo -e "${BLUE}Linking suggested skills...${NC}"
                for skill_path in "${SUGGESTED_SKILLS[@]}"; do
                    skill_name=$(basename "$skill_path")
                    target_link="$TARGET_SKILLS_DIR/$skill_name"
                    source_skill="$GLOBAL_SKILLS_DIR/$skill_path"

                    if [ ! -d "$source_skill" ]; then
                        echo -e "${YELLOW}  ⚠ Suggested skill not found: $skill_path (skipping)${NC}"
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

        # Ask about additional skills
        echo ""
        echo -e "${BLUE}Additional skills available:${NC}"
        ADDITIONAL_SKILLS=()
        for skill_name in "${AVAILABLE_SKILLS[@]}"; do
            is_essential=false
            is_suggested=false

            for essential in "${ESSENTIAL_SKILLS[@]}"; do
                if [ "$skill_name" = "$essential" ]; then
                    is_essential=true
                    break
                fi
            done

            for suggested in "${SUGGESTED_SKILLS[@]}"; do
                if [ "$skill_name" = "$suggested" ]; then
                    is_suggested=true
                    break
                fi
            done

            if [ "$is_essential" = false ] && [ "$is_suggested" = false ]; then
                ADDITIONAL_SKILLS+=("$skill_name")
                echo "  - $skill_name"
            fi
        done

        if [ ${#ADDITIONAL_SKILLS[@]} -gt 0 ]; then
            echo ""
            read -p "Link other skills? (y/n): " link_more

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

        # Symlink global settings
        echo ""
        echo -e "${BLUE}Setting up global settings...${NC}"
        GLOBAL_SETTINGS="$CLAUDE_METADATA/.claude/settings.local.json"
        TARGET_SETTINGS=".claude/settings.local.json"

        if [ -f "$GLOBAL_SETTINGS" ]; then
            if [ -f "$TARGET_SETTINGS" ] && [ ! -L "$TARGET_SETTINGS" ]; then
                echo -e "${YELLOW}  ⚠ Backing up existing settings.local.json${NC}"
                mv "$TARGET_SETTINGS" "$TARGET_SETTINGS.backup"
            fi

            if [ -L "$TARGET_SETTINGS" ]; then
                echo "  Already linked: settings.local.json"
            elif [ -f "$TARGET_SETTINGS" ]; then
                echo -e "${RED}  ✗ File exists (not a symlink): settings.local.json${NC}"
            else
                ln -s "$GLOBAL_SETTINGS" "$TARGET_SETTINGS"
                echo -e "${GREEN}  ✓ Linked: settings.local.json (permissions will sync)${NC}"
            fi
        else
            echo -e "${YELLOW}  ⚠ Global settings not found (skipping)${NC}"
        fi

        # Set up Obsidian integration
        setup_obsidian
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

        # Symlink global settings
        echo ""
        echo -e "${BLUE}Setting up global settings...${NC}"
        GLOBAL_SETTINGS="$CLAUDE_METADATA/.claude/settings.local.json"
        TARGET_SETTINGS=".claude/settings.local.json"

        if [ -f "$GLOBAL_SETTINGS" ]; then
            if [ -f "$TARGET_SETTINGS" ] && [ ! -L "$TARGET_SETTINGS" ]; then
                echo -e "${YELLOW}  ⚠ Backing up existing settings.local.json${NC}"
                mv "$TARGET_SETTINGS" "$TARGET_SETTINGS.backup"
            fi

            if [ -L "$TARGET_SETTINGS" ]; then
                echo "  Already linked: settings.local.json"
            elif [ -f "$TARGET_SETTINGS" ]; then
                echo -e "${RED}  ✗ File exists (not a symlink): settings.local.json${NC}"
            else
                ln -s "$GLOBAL_SETTINGS" "$TARGET_SETTINGS"
                echo -e "${GREEN}  ✓ Linked: settings.local.json (permissions will sync)${NC}"
            fi
        else
            echo -e "${YELLOW}  ⚠ Global settings not found (skipping)${NC}"
        fi

        # Set up Obsidian integration
        setup_obsidian
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

# Check if project-config exists
if [ -f ".claude/project-config" ]; then
    echo -e "${GREEN}Obsidian integration configured${NC}"
    if [ -f ".claude/project-config" ]; then
        PROJECT_NAME=$(grep "^obsidian_project=" .claude/project-config | cut -d= -f2)
        OBSIDIAN_PATH=$(grep "^obsidian_path=" .claude/project-config | cut -d= -f2)
        echo "  Project: $PROJECT_NAME"
        echo "  Location: \$OBSIDIAN_VAULT/$OBSIDIAN_PATH/"
    fi
    echo ""
fi

echo -e "${BLUE}Next steps:${NC}"
echo "  1. Open Claude Code in this directory"
echo "  2. Start working on your project"
echo "  3. End sessions with /safe-exit (saves notes + optional backup)"
echo ""
echo -e "${BLUE}Essential commands:${NC}"
echo "  • /command-help - Show help for any command"
echo "  • /safe-exit - End session with notes & backup"
echo "  • /safe-clear - Clear context while preserving knowledge"
echo "  • /consolidate-notes - Weekly consolidation with AI analysis"
echo "  • /backup - Create project backups"
echo ""
echo -e "${BLUE}Other useful commands:${NC}"
echo "  • /list-skills - See all available skills"
echo "  • /sync-skills - Sync with global metadata"
echo "  • /share-project - Prepare packages for sharing"

if [ -f ".claude/project-config" ]; then
    echo ""
    echo -e "${YELLOW}Git configuration:${NC}"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "  Add .claude/ to .gitignore (symlinks shouldn't be committed)"
        echo "  But DO commit .claude/project-config (project-specific settings)"
        echo ""
        echo "  Suggested commands:"
        echo "    echo '.claude/' >> .gitignore"
        echo "    echo '!.claude/project-config' >> .gitignore"
        echo "    git add .gitignore .claude/project-config"
        echo "    git commit -m 'Configure Claude Code with Obsidian integration'"
    fi
fi

echo ""
echo -e "${YELLOW}Remember:${NC} All skills are symlinked from \$CLAUDE_METADATA"
echo "  - They auto-update when global skills are updated"
echo "  - Never create local skill files (always use symlinks)"
echo ""
