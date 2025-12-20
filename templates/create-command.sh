#!/bin/bash
#
# create-command.sh - Helper script to create new Claude Code commands from template
#
# Usage:
#   ./create-command.sh category command-name "Brief description"
#
# Arguments:
#   category       : Command category (e.g., vgp-pipeline, git-workflows)
#   command-name   : Name of the command (kebab-case, e.g., check-status)
#   description    : Brief description shown in /help
#
# Examples:
#   ./create-command.sh vgp-pipeline check-status "Check status of all VGP workflows"
#   ./create-command.sh testing run-tests "Run all tests and report results"
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
Usage: $0 category command-name "Brief description"

Creates a new Claude Code slash command from template.

Arguments:
  category       Category/group for the command (kebab-case)
  command-name   Name of the command (kebab-case)
  description    Brief description shown in /help

Examples:
  $0 vgp-pipeline check-status "Check status of all workflows"
  $0 git-workflows review-commits "Review recent commits with AI"
  $0 testing run-all-tests "Run complete test suite"

The command will be created at:
  \$CLAUDE_METADATA/commands/category/command-name.md

Users can then run it with:
  /command-name

After creation:
  1. Edit the generated command file
  2. Write clear instructions for Claude
  3. Specify expected output format
  4. Test by symlinking to a project
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
if [ $# -ne 3 ]; then
    usage
fi

CATEGORY="$1"
COMMAND_NAME="$2"
DESCRIPTION="$3"

# Validate category (kebab-case)
if ! echo "$CATEGORY" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    print_error "Invalid category: $CATEGORY"
    echo "Category must be kebab-case (lowercase with hyphens)"
    echo "Examples: vgp-pipeline, git-workflows, testing"
    exit 1
fi

# Validate command name (kebab-case)
if ! echo "$COMMAND_NAME" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    print_error "Invalid command name: $COMMAND_NAME"
    echo "Command name must be kebab-case (lowercase with hyphens)"
    echo "Examples: check-status, run-tests, deploy-prod"
    exit 1
fi

# Set paths
COMMANDS_DIR="$CLAUDE_METADATA/commands"
CATEGORY_DIR="$COMMANDS_DIR/$CATEGORY"
COMMAND_FILE="$CATEGORY_DIR/$COMMAND_NAME.md"
TEMPLATE_FILE="$CLAUDE_METADATA/templates/command.md"

# Check if command already exists
if [ -f "$COMMAND_FILE" ]; then
    print_error "Command already exists: $COMMAND_FILE"
    echo "Choose a different name or remove the existing command first"
    exit 1
fi

# Check if template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    print_error "Template not found: $TEMPLATE_FILE"
    echo "Make sure templates are installed in $CLAUDE_METADATA/templates/"
    exit 1
fi

# Convert command-name to Title Case for display
COMMAND_TITLE=$(echo "$COMMAND_NAME" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

print_info "Creating new command: /$COMMAND_NAME"
echo "  Category: $CATEGORY"
echo "  Title: $COMMAND_TITLE"
echo "  Description: $DESCRIPTION"
echo "  File: $COMMAND_FILE"
echo ""

# Create category directory if doesn't exist
if [ ! -d "$CATEGORY_DIR" ]; then
    mkdir -p "$CATEGORY_DIR"
    print_success "Created category directory: $CATEGORY_DIR"
fi

# Copy template
cp "$TEMPLATE_FILE" "$COMMAND_FILE"
print_success "Created $COMMAND_NAME.md from template"

# Replace placeholders
print_info "Replacing placeholders..."

sed -i.bak "s/command-name/$COMMAND_NAME/g" "$COMMAND_FILE"
sed -i.bak "s/Brief description of what this command does (shown in \/help)/$DESCRIPTION/g" "$COMMAND_FILE"

# Remove backup file
rm -f "$COMMAND_FILE.bak"

print_success "Placeholders replaced"

# Create a quick reference
cat > "$CATEGORY_DIR/.command-checklist-$COMMAND_NAME.md" << 'EOF'
# Command Creation Checklist

Use this checklist to ensure your command is complete:

## Frontmatter
- [ ] Command name matches filename (without .md)
- [ ] Description is clear and concise (< 80 chars)

## Instructions
- [ ] Clear task description for Claude
- [ ] Step-by-step instructions if multi-step
- [ ] Context about what files to check
- [ ] Token efficiency considerations noted

## Output Format
- [ ] Specified expected output format
- [ ] Used clear status indicators (✅ ⚠️ ❌)
- [ ] Format is easy to read and scannable

## Parameters (if applicable)
- [ ] Documented parameter format
- [ ] Provided usage examples
- [ ] Showed how to handle spaces/special chars

## Testing
- [ ] Symlinked command to test project
- [ ] Tested command execution
- [ ] Verified output format is correct
- [ ] Checked that Claude follows instructions

## Ready to Use
- [ ] Command is complete and tested
- [ ] Delete this checklist file
- [ ] Symlink to projects that need it

---

When complete, delete this file:
  rm .command-checklist-*.md
EOF

print_success "Created checklist file"

# Print summary
echo ""
print_success "Command created successfully!"
echo ""
print_info "Next steps:"
echo "  1. Edit the command file:"
echo "     \$EDITOR $COMMAND_FILE"
echo ""
echo "  2. Follow the checklist:"
echo "     cat $CATEGORY_DIR/.command-checklist-$COMMAND_NAME.md"
echo ""
echo "  3. Test the command:"
echo "     mkdir -p /tmp/test-cmd/.claude/commands"
echo "     ln -s $COMMAND_FILE /tmp/test-cmd/.claude/commands/"
echo "     cd /tmp/test-cmd"
echo "     # Start Claude Code and run: /$COMMAND_NAME"
echo ""
echo "  4. When ready, symlink to your projects:"
echo "     ln -s $COMMAND_FILE /path/to/project/.claude/commands/"
echo ""
echo "  5. After testing, delete the checklist:"
echo "     rm $CATEGORY_DIR/.command-checklist-$COMMAND_NAME.md"
echo ""

# List other commands in same category
COMMANDS_IN_CATEGORY=$(find "$CATEGORY_DIR" -name "*.md" -not -name ".command-checklist-*" | wc -l | tr -d ' ')
if [ "$COMMANDS_IN_CATEGORY" -gt 1 ]; then
    print_info "Other commands in $CATEGORY category:"
    find "$CATEGORY_DIR" -name "*.md" -not -name ".command-checklist-*" -exec basename {} .md \; | sed 's/^/  \//'
    echo ""
fi

# Optionally open in editor
if [ -n "$EDITOR" ]; then
    print_info "Open in editor now? (y/n)"
    read -r response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        $EDITOR "$COMMAND_FILE"
    fi
else
    print_warning "EDITOR not set. Set it to auto-open files:"
    echo "  export EDITOR=vim  # or nano, code, etc."
fi
