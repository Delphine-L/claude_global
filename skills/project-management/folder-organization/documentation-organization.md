# Documentation Standards and Organization

Best practices for project documentation, change summaries, and documentation directory organization.

## README.md Essentials

Every project should have a README with:

```markdown
# Project Name

Brief description

## Installation

How to set up the environment

## Usage

How to run the analysis/code

## Project Structure

Brief overview of directories

## Data

Where data lives and how to access it

## Results

Where to find outputs
```

## Code Documentation

- **Docstrings** for all functions/classes
- **Comments** for complex logic
- **CHANGELOG.md** for tracking changes
- **TODO.md** for tracking work (gitignored or removed before merge)

## Change Documentation Best Practices

After major changes (cleanup, deprecation, restoration), create summary documents:

1. **Create a dated summary document**:
   ```
   OPERATION_SUMMARY_YYYY-MM-DD.md
   ```

2. **Essential sections**:
   - **Overview**: What was done and why
   - **Problem**: What issue was being addressed
   - **Solution**: Actions taken
   - **Result**: Current state after changes
   - **Files affected**: What was moved/changed/restored
   - **Restoration**: How to undo if needed

3. **Examples of good summary docs**:
   - `FIGURE_RESTORATION_SUMMARY.md` - Documents restored files
   - `DEPRECATION_SUMMARY.md` - Documents deprecated notebooks
   - `RECENT_CHANGES_SUMMARY.md` - High-level overview

### Template for Change Summaries

```markdown
# [Operation] Summary - [Date]

## Problem
[Brief description of the issue]

## Solution
[What was done to address it]

### Files Changed
- **Moved**: [list]
- **Restored**: [list]
- **Updated**: [list]

## Current State
- **Active files**: [count and list]
- **Deprecated files**: [count and list]
- **Status**: [Ready/In Progress/etc.]

## Restoration Instructions
```bash
# Commands to undo changes if needed
```

## Documentation Updated
- [List of docs that were updated]

---
**Date**: YYYY-MM-DD
**Status**: [Complete/Partial/etc.]
```

**Why This Matters**:
- Future users (including yourself) understand what changed
- Provides restoration instructions if needed
- Creates audit trail for project history
- Helps collaborators understand project evolution

## Documentation Organization Strategy

Projects accumulate documentation files (.md, .log, .txt) in the root directory. Consolidate them effectively:

### Structure

```
documentation/
├── README.md                    # Index to all documentation
├── logs/                        # Log files from processes
├── working_files/               # Temporary/working files
└── [organized .md files]
```

### Implementation

```bash
# 1. Create structure
mkdir -p documentation/{logs,working_files}

# 2. Move documentation
mv *.md documentation/
mv *.log documentation/logs/
mv *.txt documentation/working_files/  # or keep essential ones in root

# 3. Create index (documentation/README.md)
cat > documentation/README.md << 'EOF'
# Project Documentation

## Quick Start
- ESSENTIAL_FILE.md - Start here
- RECENT_CHANGES.md - Latest updates

## By Category
### Analysis
- analysis_summary.md
- results.md

### Methods
- methods.md
- protocols.md

[etc...]
EOF
```

### Documentation README Template

Include in `documentation/README.md`:
- **Quick start section** - Most important docs
- **Categorical organization** - Group by purpose
- **File descriptions** - One-line summaries
- **File counts** - Show organization scale
- **Archive policy** - Which docs are historical
- **Access instructions** - How to find specific info

### What to Keep in Root

**Keep in project root:**
- `README.md` - Project overview
- `LICENSE`, `CONTRIBUTING.md` - Standard files
- `.gitignore`, config files

**Move to documentation/:**
- Analysis summaries
- Session notes
- Method descriptions
- Update logs
- All other markdown files

### Benefits

- **Clean root directory**: Only essential project files visible
- **Organized docs**: Easy to find specific documentation
- **Categorized**: Logs separate from summaries separate from methods
- **Indexed**: README provides roadmap
- **Scalable**: Clear place for new documentation

### Common Mistake

Do not delete old documentation - move it to `documentation/archive/`. Preserve history but organize it clearly.
