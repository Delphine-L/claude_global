---
name: command-help
description: Show help and documentation for Claude Code commands. Usage: /command-help [command-name]
---

Display documentation and usage information for Claude Code slash commands.

## Usage

```bash
# Show help for a specific command
/command-help share-project

# List all available commands
/command-help

# Show help with full details
/command-help share-project --full
```

## Your Task

### Step 1: Parse Command Name (if provided)

Check if user provided a command name:

```bash
# This will be provided by user after /command-help
COMMAND_NAME="$1"  # e.g., "share-project"
SHOW_FULL="$2"     # Optional: "--full"

if [ -z "$COMMAND_NAME" ]; then
    # No command specified - show list of all commands
    ACTION="list"
else
    # Command specified - show help for that command
    ACTION="show"
fi
```

### Step 2: Find Command Files

```bash
# Locations to search
PROJECT_COMMANDS=".claude/commands"
GLOBAL_COMMANDS="$CLAUDE_METADATA/commands/global"

# Find the command file
find_command() {
    local cmd_name="$1"

    # Try project commands first
    if [ -f "$PROJECT_COMMANDS/${cmd_name}.md" ]; then
        echo "$PROJECT_COMMANDS/${cmd_name}.md"
        return 0
    fi

    # Try global commands
    if [ -f "$GLOBAL_COMMANDS/${cmd_name}.md" ]; then
        echo "$GLOBAL_COMMANDS/${cmd_name}.md"
        return 0
    fi

    return 1
}
```

### Step 3: Display Command List (if ACTION="list")

```bash
if [ "$ACTION" = "list" ]; then
    echo "╔════════════════════════════════════════════════════════════════════"
    echo "║ Available Claude Code Commands"
    echo "╚════════════════════════════════════════════════════════════════════"
    echo ""

    # List global commands
    if [ -d "$GLOBAL_COMMANDS" ]; then
        echo "📍 Global Commands (available in all projects):"
        echo ""

        for cmd_file in "$GLOBAL_COMMANDS"/*.md; do
            if [ -f "$cmd_file" ]; then
                cmd_name=$(basename "$cmd_file" .md)

                # Extract description from frontmatter
                description=$(sed -n '/^description:/p' "$cmd_file" | sed 's/description: *//')

                printf "  %-25s %s\n" "/$cmd_name" "$description"
            fi
        done
        echo ""
    fi

    # List project commands
    if [ -d "$PROJECT_COMMANDS" ]; then
        echo "📁 Project Commands (specific to this project):"
        echo ""

        for cmd_file in "$PROJECT_COMMANDS"/*.md; do
            if [ -f "$cmd_file" ]; then
                cmd_name=$(basename "$cmd_file" .md)

                # Skip if it's a symlink to global (already listed above)
                if [ -L "$cmd_file" ]; then
                    continue
                fi

                # Extract description from frontmatter
                description=$(sed -n '/^description:/p' "$cmd_file" | sed 's/description: *//')

                printf "  %-25s %s\n" "/$cmd_name" "$description"
            fi
        done
        echo ""
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💡 Usage: /command-help <command-name> for detailed help"
    echo "   Example: /command-help share-project"
    echo ""

    exit 0
fi
```

### Step 4: Display Command Help (if ACTION="show")

```bash
if [ "$ACTION" = "show" ]; then
    # Find the command file
    COMMAND_FILE=$(find_command "$COMMAND_NAME")

    if [ -z "$COMMAND_FILE" ]; then
        echo "❌ Command not found: /$COMMAND_NAME"
        echo ""
        echo "Available commands:"
        echo "  Run: /command-help (without arguments) to see all commands"
        exit 1
    fi

    # Extract command information
    echo "╔════════════════════════════════════════════════════════════════════"
    echo "║ Command: /$COMMAND_NAME"
    echo "╚════════════════════════════════════════════════════════════════════"
    echo ""

    # Extract frontmatter metadata
    NAME=$(sed -n '/^name:/p' "$COMMAND_FILE" | sed 's/name: *//')
    DESCRIPTION=$(sed -n '/^description:/p' "$COMMAND_FILE" | sed 's/description: *//')

    echo "📝 Description:"
    echo "   $DESCRIPTION"
    echo ""

    # Show location
    if [[ "$COMMAND_FILE" == *"$CLAUDE_METADATA"* ]]; then
        echo "📍 Location: Global (available in all projects)"
    else
        echo "📍 Location: Project-specific"
    fi
    echo "   File: $COMMAND_FILE"
    echo ""

    # Extract usage examples from the file
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📖 Quick Overview:"
    echo ""

    # Show content after frontmatter but before first major section
    # This typically contains the usage summary
    awk '
        BEGIN { in_frontmatter=0; after_frontmatter=0; line_count=0 }
        /^---$/ {
            if (in_frontmatter == 0) {
                in_frontmatter=1; next
            } else {
                after_frontmatter=1; next
            }
        }
        after_frontmatter == 1 && /^##/ { exit }
        after_frontmatter == 1 {
            if (line_count < 15) {
                print "   " $0
                line_count++
            }
        }
    ' "$COMMAND_FILE"

    echo ""

    # Extract steps/sections
    if [ "$SHOW_FULL" = "--full" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📚 Detailed Steps:"
        echo ""

        # Extract step headers
        grep -E "^### Step [0-9]" "$COMMAND_FILE" | sed 's/^###/  /' || echo "   (See full file for detailed steps)"
        echo ""
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💡 Tips:"
    echo "   • Run /$COMMAND_NAME to execute the command"
    echo "   • View full file: cat $COMMAND_FILE"
    if [ "$SHOW_FULL" != "--full" ]; then
        echo "   • See all steps: /command-help $COMMAND_NAME --full"
    fi
    echo ""

    exit 0
fi
```

### Step 5: Handle Edge Cases

```bash
# If somehow we got here without action being set
echo "❌ Error: Invalid usage"
echo "Usage: /command-help [command-name]"
exit 1
```

## Examples

### List All Commands

```bash
/command-help
```

Output:
```
╔════════════════════════════════════════════════════════════════════
║ Available Claude Code Commands
╚════════════════════════════════════════════════════════════════════

📍 Global Commands (available in all projects):

  /share-project            Prepare organized project package for sharing...
  /update-skills            Review session and suggest skill updates...
  /list-skills              List all available skills with descriptions
  /cleanup-project          End-of-project cleanup - removes working docs...

💡 Usage: /command-help <command-name> for detailed help
```

### Show Specific Command Help

```bash
/command-help share-project
```

Output:
```
╔════════════════════════════════════════════════════════════════════
║ Command: /share-project
╚════════════════════════════════════════════════════════════════════

📝 Description:
   Prepare organized project package for sharing with collaborators...

📍 Location: Global (available in all projects)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 Quick Overview:

   Prepare a shareable version of your current project, with cleaned
   notebooks, proper documentation, and appropriate file selection...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 Tips:
   • Run /share-project to execute the command
   • View full file: cat /path/to/share-project.md
   • See all steps: /command-help share-project --full
```

### Show Full Details

```bash
/command-help share-project --full
```

Shows complete step-by-step breakdown.

## Notes

- Commands are searched in this order:
  1. Project commands (.claude/commands/)
  2. Global commands ($CLAUDE_METADATA/commands/global/)

- Symlinked commands are only listed once (in global section)

- Use `--full` flag to see detailed step breakdown

- To edit a command: `cat <command-file-path>` then edit the markdown

## Related Commands

- `/list-skills` - List available skills
- `/help` - General Claude Code help
- `/sync-skills` - Sync skills between global and project
