#!/bin/bash
#
# create-skill.sh - Helper script to create new Claude Code skills from templates
#
# Usage:
#   ./create-skill.sh skill-name "Brief description" [type]
#
# Arguments:
#   skill-name     : Name of the skill (kebab-case, e.g., my-new-skill)
#   description    : Brief one-sentence description
#   type          : Template type (basic|advanced), default: basic
#
# Examples:
#   ./create-skill.sh my-skill "Expert in doing X"
#   ./create-skill.sh advanced-skill "Complex topic" advanced
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

usage() {
    cat << EOF
Usage: $0 skill-name "Brief description" [type]

Creates a new Claude Code skill from templates.

Arguments:
  skill-name     Name of the skill (kebab-case)
  description    Brief one-sentence description
  type          Template type: basic (default) or advanced

Examples:
  $0 python-testing "Expert in Python testing patterns"
  $0 k8s-deployment "Kubernetes deployment and orchestration" advanced

Template Types:
  basic     - Single SKILL.md file (200-400 lines)
  advanced  - SKILL.md + reference.md + troubleshooting.md

After creation:
  1. Edit the generated SKILL.md file
  2. Fill in all sections with your content
  3. Remove sections you don't need
  4. Test the skill by symlinking to a project
EOF
    exit 1
}

# Validate CLAUDE_METADATA is set
if [ -z "$CLAUDE_METADATA" ]; then
    print_error "CLAUDE_METADATA environment variable is not set"
    echo "Please set it in your shell configuration:"
    echo "  export CLAUDE_METADATA=\"\$HOME/path/to/claude_data\""
    exit 1
fi

# Parse arguments
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    usage
fi

SKILL_NAME="$1"
DESCRIPTION="$2"
TEMPLATE_TYPE="${3:-basic}"

# Validate skill name (kebab-case)
if ! echo "$SKILL_NAME" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    print_error "Invalid skill name: $SKILL_NAME"
    echo "Skill name must be kebab-case (lowercase with hyphens)"
    echo "Examples: my-skill, python-testing, vgp-pipeline"
    exit 1
fi

# Validate template type
if [ "$TEMPLATE_TYPE" != "basic" ] && [ "$TEMPLATE_TYPE" != "advanced" ]; then
    print_error "Invalid template type: $TEMPLATE_TYPE"
    echo "Must be 'basic' or 'advanced'"
    exit 1
fi

# Set paths
SKILLS_DIR="$CLAUDE_METADATA/skills"
TEMPLATES_DIR="$CLAUDE_METADATA/templates"
SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

# Check if skill already exists
if [ -d "$SKILL_DIR" ]; then
    print_error "Skill already exists: $SKILL_DIR"
    echo "Choose a different name or remove the existing skill first"
    exit 1
fi

# Check if templates directory exists
if [ ! -d "$TEMPLATES_DIR" ]; then
    print_error "Templates directory not found: $TEMPLATES_DIR"
    echo "Make sure templates are installed in $CLAUDE_METADATA/templates/"
    exit 1
fi

# Convert skill-name to Title Case for display
SKILL_TITLE=$(echo "$SKILL_NAME" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

print_info "Creating new skill: $SKILL_NAME"
echo "  Type: $TEMPLATE_TYPE"
echo "  Title: $SKILL_TITLE"
echo "  Description: $DESCRIPTION"
echo "  Location: $SKILL_DIR"
echo ""

# Create skill directory
mkdir -p "$SKILL_DIR"
print_success "Created directory: $SKILL_DIR"

# Copy appropriate template
if [ "$TEMPLATE_TYPE" = "basic" ]; then
    TEMPLATE_FILE="$TEMPLATES_DIR/skill-basic.md"

    if [ ! -f "$TEMPLATE_FILE" ]; then
        print_error "Template not found: $TEMPLATE_FILE"
        exit 1
    fi

    cp "$TEMPLATE_FILE" "$SKILL_DIR/SKILL.md"
    print_success "Created SKILL.md from basic template"

elif [ "$TEMPLATE_TYPE" = "advanced" ]; then
    MAIN_TEMPLATE="$TEMPLATES_DIR/skill-with-references.md"
    REF_TEMPLATE="$TEMPLATES_DIR/reference.md"
    TROUBLE_TEMPLATE="$TEMPLATES_DIR/troubleshooting.md"

    # Check all templates exist
    for template in "$MAIN_TEMPLATE" "$REF_TEMPLATE" "$TROUBLE_TEMPLATE"; do
        if [ ! -f "$template" ]; then
            print_error "Template not found: $template"
            exit 1
        fi
    done

    cp "$MAIN_TEMPLATE" "$SKILL_DIR/SKILL.md"
    cp "$REF_TEMPLATE" "$SKILL_DIR/reference.md"
    cp "$TROUBLE_TEMPLATE" "$SKILL_DIR/troubleshooting.md"

    print_success "Created SKILL.md from advanced template"
    print_success "Created reference.md"
    print_success "Created troubleshooting.md"

    # Create examples directory
    mkdir -p "$SKILL_DIR/examples"
    print_success "Created examples/ directory"
fi

# Replace placeholders in all created files
print_info "Replacing placeholders..."

for file in "$SKILL_DIR"/*.md; do
    # Replace skill name
    sed -i.bak "s/SKILL-NAME-HERE/$SKILL_NAME/g" "$file"
    sed -i.bak "s/skill-name/$SKILL_NAME/g" "$file"

    # Replace skill title
    sed -i.bak "s/Skill Title/$SKILL_TITLE/g" "$file"

    # Replace description
    sed -i.bak "s/Brief one-sentence description that helps Claude decide when to activate this skill (1-2 sentences max)/$DESCRIPTION/g" "$file"

    # Remove backup files
    rm -f "$file.bak"
done

print_success "Placeholders replaced"

# Create a checklist file
cat > "$SKILL_DIR/CHECKLIST.md" << 'EOF'
# Skill Creation Checklist

Use this checklist to ensure your skill is complete:

## Initial Setup
- [ ] Skill name is descriptive and follows kebab-case
- [ ] Description clearly states when to use the skill
- [ ] Version is set to 1.0.0

## Content
- [ ] "When to Use This Skill" section lists specific scenarios
- [ ] At least 2-3 core concepts explained with examples
- [ ] Best practices include rationale (why, not just what)
- [ ] At least 2 realistic examples provided
- [ ] Examples use actual commands/code that work

## Quality
- [ ] All placeholder text replaced with real content
- [ ] Code examples are tested and work
- [ ] Commands shown are accurate
- [ ] No template artifacts left (e.g., "Replace this", "TODO")
- [ ] Removed sections you don't need

## Optional Enhancements
- [ ] Added quick reference section
- [ ] Included common issues and solutions
- [ ] Added references to related skills
- [ ] Created supporting documentation (if advanced)

## Testing
- [ ] Symlinked skill to test project
- [ ] Tested skill activation with Claude
- [ ] Verified examples work in practice
- [ ] Description triggers activation appropriately

## Documentation (if advanced template)
- [ ] reference.md has complete API/option details
- [ ] troubleshooting.md covers common errors
- [ ] examples/ directory has working examples
- [ ] Cross-references between files are correct

## Ready to Use
- [ ] Skill is complete and tested
- [ ] Delete this CHECKLIST.md file
- [ ] Symlink to projects that need it
- [ ] Add to version control if using git

---

When complete, delete this file:
  rm CHECKLIST.md
EOF

print_success "Created CHECKLIST.md"

# Print summary
echo ""
print_success "Skill created successfully!"
echo ""
print_info "Next steps:"
echo "  1. Edit the skill file(s):"
echo "     \$EDITOR $SKILL_DIR/SKILL.md"
echo ""
echo "  2. Follow the checklist:"
echo "     cat $SKILL_DIR/CHECKLIST.md"
echo ""
echo "  3. Test the skill:"
echo "     mkdir -p /tmp/test-skill/.claude/skills"
echo "     ln -s $SKILL_DIR /tmp/test-skill/.claude/skills/"
echo "     cd /tmp/test-skill"
echo "     # Start Claude Code and test"
echo ""
echo "  4. When ready, symlink to your projects:"
echo "     ln -s $SKILL_DIR /path/to/project/.claude/skills/"
echo ""

# Optionally open in editor
if [ -n "$EDITOR" ]; then
    print_info "Open in editor now? (y/n)"
    read -r response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        $EDITOR "$SKILL_DIR/SKILL.md"
    fi
else
    print_warning "EDITOR not set. Set it to auto-open files:"
    echo "  export EDITOR=vim  # or nano, code, etc."
fi
