---
name: consolidate-notes
description: Consolidate session notes, update project status, and archive processed notes with AI-powered analysis
---

Consolidate all session notes from `sessions-history/`, remove redundancies, track to-do completion, generate comprehensive project status, and archive processed notes.

**Key Features:**
- AI-powered summarization of project progress
- Automatic tag extraction and categorization
- To-do tracking (completed vs pending)
- Redundancy removal
- Project improvement suggestions
- Milestone snapshots

**Supporting files** (full scripts and reference material):
- `consolidate-notes/analysis-script.md` - Step 3 Python analysis script
- `consolidate-notes/redundancy-and-ai-analysis.md` - Steps 4-5 redundancy removal and AI prompt
- `consolidate-notes/status-generation.md` - Step 6 project status generation script
- `consolidate-notes/reference.md` - Feature details and example AI output

## Your Task

### Step 1: Check for Obsidian Configuration

```bash
# Check for project configuration
PROJECT_CONFIG_FILE=".claude/project-config"

if [ ! -f "$PROJECT_CONFIG_FILE" ]; then
    echo "⚠️  No Obsidian configuration found"
    echo "Run /safe-exit or /safe-clear first to set up Obsidian integration"
    exit 1
fi

# Read configuration
PROJECT_NAME=$(grep "^obsidian_project=" "$PROJECT_CONFIG_FILE" | cut -d= -f2)
OBSIDIAN_PATH=$(grep "^obsidian_path=" "$PROJECT_CONFIG_FILE" | cut -d= -f2)
OBSIDIAN_PATH=${OBSIDIAN_PATH:-$PROJECT_NAME}

# Build paths
SESSIONS_DIR="$OBSIDIAN_VAULT/$OBSIDIAN_PATH/sessions-history"
ARCHIVED_DIR="$SESSIONS_DIR/archived"
STATUS_FILE="$OBSIDIAN_VAULT/$OBSIDIAN_PATH/project-status.md"

echo "📊 Consolidate Session Notes"
echo ""
echo "Project: $PROJECT_NAME"
echo "Location: $OBSIDIAN_PATH"
echo ""
```

---

### Step 2: Discover Session Notes

```bash
# Check if sessions-history directory exists
if [ ! -d "$SESSIONS_DIR" ]; then
    echo "📝 No session notes found in $OBSIDIAN_PATH/sessions-history/"
    echo "Nothing to consolidate"
    exit 0
fi

# Count session notes (exclude archived/)
NOTE_COUNT=$(find "$SESSIONS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | xargs)

if [ "$NOTE_COUNT" -eq 0 ]; then
    echo "📝 No unprocessed session notes found"
    echo "All notes have been consolidated or archived"
    exit 0
fi

echo "Found $NOTE_COUNT session notes to consolidate"
echo ""
```

---

### Step 3: Analyze Session Notes with AI

Use the Python script to read, parse, and extract structured data from all session notes.

> **Full script:** See `consolidate-notes/analysis-script.md`

The script extracts accomplishments, decisions, discoveries, to-dos, contexts, and tags from each session note, then saves the analysis to `/tmp/consolidate_analysis.json`.

---

### Step 4: Remove Redundancies

Use text similarity (85% threshold) to deduplicate accomplishments, decisions, and discoveries.

> **Full script:** See `consolidate-notes/redundancy-and-ai-analysis.md` (Step 4 section)

---

### Step 5: AI-Powered Analysis and Suggestions

Ask Claude to analyze the consolidated data and provide an executive summary, tag-based categorization, pattern recognition, and future improvement suggestions.

> **Full prompt template:** See `consolidate-notes/redundancy-and-ai-analysis.md` (Step 5 section)

Store Claude's response for inclusion in project-status.md.

---

### Step 6: Update or Create Project Status Note

Generate or update `project-status.md` with all consolidated data, AI analysis, to-do tracking, and consolidation history.

> **Full script:** See `consolidate-notes/status-generation.md`

---

### Step 7: Milestone Snapshot (Optional)

```bash
echo "📸 Create Milestone Snapshot?"
echo ""
echo "Save a permanent copy of the current project status"
echo "This is useful for:"
echo "  • End of sprint/iteration"
echo "  • Major feature completion"
echo "  • Before significant changes"
echo "  • Quarterly reviews"
echo ""
read -p "Create milestone? (y/n) [n]: " MILESTONE_CHOICE
MILESTONE_CHOICE=${MILESTONE_CHOICE:-n}

if [[ "$MILESTONE_CHOICE" =~ ^[Yy]$ ]]; then
    # Ask for milestone name
    echo ""
    DEFAULT_NAME="project-status-$(date +%Y-%m-%d)"
    read -p "Milestone filename (without .md) [$DEFAULT_NAME]: " MILESTONE_NAME
    MILESTONE_NAME=${MILESTONE_NAME:-$DEFAULT_NAME}

    # Ensure .md extension
    if [[ ! "$MILESTONE_NAME" =~ \.md$ ]]; then
        MILESTONE_NAME="${MILESTONE_NAME}.md"
    fi

    # Copy to main Obsidian directory (one level up from sessions-history)
    MILESTONE_PATH="$OBSIDIAN_VAULT/$OBSIDIAN_PATH/$MILESTONE_NAME"

    # Copy current project-status
    cp "$STATUS_FILE" "$MILESTONE_PATH"

    # Add milestone marker at the top
    TEMP_FILE=$(mktemp)
    cat > "$TEMP_FILE" << EOF
> [!NOTE] Milestone Snapshot
> This is a permanent snapshot of the project status as of $(date +"%Y-%m-%d %H:%M")
> Original file: project-status.md
> Future updates to project-status.md will not affect this milestone.

---

EOF
    cat "$MILESTONE_PATH" >> "$TEMP_FILE"
    mv "$TEMP_FILE" "$MILESTONE_PATH"

    echo "✅ Milestone saved: $OBSIDIAN_PATH/$MILESTONE_NAME"
    echo ""
fi
```

---

### Step 8: Archive Processed Notes

```bash
# Create archived directory if it doesn't exist
mkdir -p "$ARCHIVED_DIR"

echo "📦 Archive Processed Session Notes"
echo ""
echo "The following notes will be moved to sessions-history/archived/:"
ls -1 "$SESSIONS_DIR"/*.md 2>/dev/null
echo ""
echo "These notes have been consolidated into project-status.md"
echo ""
read -p "Move to archived/? (y/n) [y]: " ARCHIVE_CHOICE
ARCHIVE_CHOICE=${ARCHIVE_CHOICE:-y}

if [[ "$ARCHIVE_CHOICE" =~ ^[Yy]$ ]]; then
    # Count files
    FILE_COUNT=$(find "$SESSIONS_DIR" -maxdepth 1 -name "*.md" -type f | wc -l | xargs)

    # Move notes to archived
    mv "$SESSIONS_DIR"/*.md "$ARCHIVED_DIR/" 2>/dev/null

    # Create/update archive index
    ARCHIVE_README="$ARCHIVED_DIR/README.md"

    if [ -f "$ARCHIVE_README" ]; then
        # Append to existing README
        echo "" >> "$ARCHIVE_README"
        echo "## Archived $(date +%Y-%m-%d)" >> "$ARCHIVE_README"
        echo "" >> "$ARCHIVE_README"
        echo "Added $FILE_COUNT notes:" >> "$ARCHIVE_README"
    else
        # Create new README
        cat > "$ARCHIVE_README" << EOF
# Archived Session Notes

This folder contains session notes that have been consolidated into the main project-status note.

Each consolidation is documented below with the date and number of notes archived.

---

## Archived $(date +%Y-%m-%d)

Added $FILE_COUNT notes:
EOF
    fi

    # List archived files
    ls -1 "$ARCHIVED_DIR"/*.md 2>/dev/null | \
        grep -v "README.md" | \
        xargs -n1 basename | \
        sed 's/^/- /' >> "$ARCHIVE_README"

    echo "✅ Archived $FILE_COUNT notes"
    echo "   Location: $OBSIDIAN_PATH/sessions-history/archived/"
    echo ""
else
    echo "Skipping archival - notes remain in sessions-history/"
    echo ""
fi
```

---

### Step 9: Show Summary

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Consolidation Complete!"
echo ""
echo "📊 Summary:"
echo "  • Sessions analyzed: $NOTE_COUNT notes"
echo "  • Period: ${DATA_START} to ${DATA_END}"
echo "  • Redundancies removed: ${DUPLICATES_REMOVED} items"
echo "  • Pending to-dos: ${PENDING_COUNT} tasks"
echo "  • Completed to-dos: ${COMPLETED_COUNT} tasks"
echo "  • Tags extracted: ${TAG_COUNT} unique tags"
echo ""
echo "📝 Updated:"
echo "  • project-status.md (comprehensive overview with AI analysis)"
if [ -n "$MILESTONE_NAME" ]; then
    echo "  • $MILESTONE_NAME (milestone snapshot)"
fi
echo ""
echo "📦 Archived:"
echo "  • $NOTE_COUNT notes moved to sessions-history/archived/"
echo ""
echo "💡 Next Steps:"
echo "  1. Review project-status.md in Obsidian"
echo "  2. Address pending to-dos"
echo "  3. Consider implementing suggested improvements"
echo "  4. Run /consolidate-notes periodically (weekly/bi-weekly)"
echo ""
echo "📍 Quick Links:"
echo "  • Project status: $OBSIDIAN_PATH/project-status.md"
if [ -n "$MILESTONE_NAME" ]; then
    echo "  • Milestone: $OBSIDIAN_PATH/$MILESTONE_NAME"
fi
echo "  • Archived notes: $OBSIDIAN_PATH/sessions-history/archived/"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## Usage Frequency

**Recommended schedule:**
- **Weekly**: For active projects with daily work
- **Bi-weekly**: For moderate-pace projects
- **Monthly**: For long-term projects or maintenance mode
- **On-demand**: Before major milestones or reviews

---

## Related Commands

- `/safe-exit` - End session with note creation
- `/safe-clear` - Clear context with note creation
- `/backup` - Create project backups
- `/update-skills` - Update skills with learnings

---

## Notes

- Always review AI suggestions critically - they're starting points, not mandates
- Milestone snapshots are permanent - project-status.md continues to update
- Archived notes remain accessible for reference
- Tags work best when used consistently (#feature, #bug, #optimization, etc.)
- For feature details and example output, see `consolidate-notes/reference.md`
