---
name: cleanup-project
description: End-of-project cleanup - removes working documentation and condenses verbose READMEs for files changed in current git branch
disable-model-invocation: true
---

Perform end-of-project documentation cleanup, analyzing only files changed in the current git branch.

## Your Task

### Step 1: Detect Git Repository & Branch Context

```bash
# Check if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "⚠️  Not a git repository. This command only works in git repos."
  echo "Use git init if you want to use this command."
  exit 1
fi

# Get current branch
current_branch=$(git branch --show-current)

# Detect base branch (main, master, or develop)
if git rev-parse --verify main >/dev/null 2>&1; then
  base_branch="main"
elif git rev-parse --verify master >/dev/null 2>&1; then
  base_branch="master"
elif git rev-parse --verify develop >/dev/null 2>&1; then
  base_branch="develop"
else
  echo "⚠️  Cannot find base branch (main, master, or develop)"
  echo "Current branch: $current_branch"
  read -p "Enter base branch name to compare against: " base_branch
fi

echo "📋 Analyzing files changed in: $current_branch vs $base_branch"
echo ""
```

### Step 2: Get Files Changed in Current Branch

```bash
# Get all files changed in current branch vs base
# Format: A (added), M (modified), D (deleted)
changed_files=$(git diff --name-status $base_branch...HEAD)

# Get list of file paths only
changed_paths=$(git diff --name-only $base_branch...HEAD)

# If no changes, exit
if [ -z "$changed_paths" ]; then
  echo "✅ No files changed in this branch. Nothing to clean up!"
  exit 0
fi

echo "Files changed in this branch: $(echo "$changed_paths" | wc -l | tr -d ' ')"
echo ""
```

### Step 3: Categorize Documentation Files

Identify documentation files from the changed set:

```bash
# Working documentation patterns (likely temporary)
working_doc_patterns=(
  "TODO.md"
  "NOTES.md"
  "PLAN.md"
  "DESIGN.md"
  "DEBUG.md"
  "SCRATCH.md"
  "WIP.md"
  "draft-*"
  "wip-*"
  "*-notes.md"
  "*-todo.md"
)

# Test/sample data patterns
test_data_patterns=(
  "test-data/"
  "sample-data/"
  "examples/test-"
  "debug-logs/"
  "*.log"
  "*.tmp"
)

# Find working docs in changed files
working_docs_untracked=()
working_docs_tracked=()
readmes_to_review=()
test_data_untracked=()

# Check git status for each changed file
for file in $changed_paths; do
  # Skip if file was deleted
  if [ ! -f "$file" ]; then
    continue
  fi

  # Check if file is tracked
  if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    is_tracked=true
  else
    is_tracked=false
  fi

  # Categorize file
  case "$file" in
    TODO.md|NOTES.md|PLAN.md|DESIGN.md|DEBUG.md|SCRATCH.md|WIP.md)
      if [ "$is_tracked" = false ]; then
        working_docs_untracked+=("$file")
      else
        working_docs_tracked+=("$file")
      fi
      ;;
    draft-*|wip-*|*-notes.md|*-todo.md)
      if [ "$is_tracked" = false ]; then
        working_docs_untracked+=("$file")
      else
        working_docs_tracked+=("$file")
      fi
      ;;
    test-data/*|sample-data/*|debug-logs/*|*.log|*.tmp)
      if [ "$is_tracked" = false ]; then
        test_data_untracked+=("$file")
      fi
      ;;
    *README.md|*CONTRIBUTING.md|*CHANGELOG.md)
      # Check if README is long (> 200 lines)
      line_count=$(wc -l < "$file")
      if [ "$line_count" -gt 200 ]; then
        readmes_to_review+=("$file")
      fi
      ;;
  esac
done
```

### Step 4: Present Interactive Report

Show user what was found:

```markdown
📋 Project Cleanup Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Branch:** {current_branch} vs {base_branch}
**Files changed:** {total_count}

---

## 🗑️  Working Documentation - Untracked (Safe to Remove)

These files are not in git and appear to be working notes:

{for each in working_docs_untracked}
  □ {filename} ({line_count} lines)
    Purpose: {infer from filename/first lines}
    Created: {git log for when added to branch}
{end}

{if empty}
  ✅ No untracked working documentation found
{end}

---

## ⚠️  Working Documentation - Tracked (Review Needed)

These files are committed to git but look like working docs:

{for each in working_docs_tracked}
  □ {filename} ({line_count} lines, committed)
    Last modified: {git log -1 --format="%ar"}
    Consider: Was this meant to be permanent documentation?
{end}

{if empty}
  ✅ No tracked working documentation found
{end}

---

## 🧪 Test/Sample Data - Untracked (Safe to Remove)

{for each in test_data_untracked}
  □ {filename} ({size})
    Type: {test data / debug logs / temporary files}
{end}

{if empty}
  ✅ No untracked test data found
{end}

---

## 📝 READMEs to Condense (Modified in Branch)

These READMEs are verbose and could be condensed:

{for each in readmes_to_review}
  □ {filename} ({line_count} lines)
    Suggested target: ~{line_count / 2} lines
    Current sections: {extract ## headings}
    Keep: Purpose, Installation, Usage, Key Examples
    Remove: Verbose explanations, development history, redundant examples
{end}

{if empty}
  ✅ All READMEs are concise
{end}
```

### Step 5: Get User Approval

Ask user which items to clean up:

```
What would you like to clean up?

1. Remove all untracked working docs (recommended)
2. Remove specific untracked files (select)
3. Review tracked working docs (one by one)
4. Condense READMEs (with preview)
5. Skip cleanup
```

For each category user selects, show details and confirm.

### Step 6: README Condensing Strategy

**For each README to condense:**

1. **Analyze structure** - Extract current sections
2. **Identify essential content:**
   - Purpose/Description (keep concise version)
   - Installation (keep, simplify if possible)
   - Quick Start / Usage (keep core examples)
   - Key Features (keep bulleted list)
   - API Reference (keep if essential, otherwise link to docs/)
3. **Remove verbose content:**
   - Detailed explanations that duplicate code comments
   - Development history (move to CHANGELOG.md or remove)
   - Redundant examples (keep 1-2 representative ones)
   - Verbose troubleshooting (link to docs/ or issues)
   - Step-by-step tutorials (move to docs/ or link to training)
4. **Show preview:**
   ```
   Current: {current_line_count} lines
   Proposed: {new_line_count} lines

   Sections removed:
   - Development History (50 lines) → Move to CHANGELOG.md?
   - Detailed Examples (80 lines) → Keep 2 key examples
   - Troubleshooting (40 lines) → Link to docs/troubleshooting.md

   Preview first 20 lines:
   {show condensed version}

   Approve this condensing? (y/n)
   ```

### Step 7: Execute Cleanup (with Backup)

**Before making ANY changes:**

```bash
# Create backup directory with timestamp
backup_dir=".cleanup-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

echo "Creating backup in $backup_dir..."

# Backup all files that will be modified/deleted
for file in "${files_to_cleanup[@]}"; do
  cp --parents "$file" "$backup_dir/"
done

echo "✅ Backup created: $backup_dir"
```

**For approved deletions:**

```bash
# Remove untracked files
for file in "${approved_removals[@]}"; do
  echo "Removing: $file"
  rm "$file"
done
```

**For approved README condensing:**

```bash
# Replace with condensed version
# (Claude generates condensed content based on analysis)
```

### Step 8: Generate Summary Report

```markdown
✅ Cleanup Complete!

**Changes Made:**
- Removed {count} working documentation files
- Removed {count} test data files
- Condensed {count} READMEs ({total_lines} → {new_lines} lines)

**Backup Location:** {backup_dir}
  (You can restore with: cp -r {backup_dir}/* .)

**Next Steps:**
1. Review condensed READMEs to ensure quality
2. Commit cleanup: git add . && git commit -m "docs: cleanup working documentation and condense READMEs"
3. Archive backup if satisfied: tar -czf cleanup-backup.tar.gz {backup_dir} && rm -rf {backup_dir}

**Files Removed:**
{list each removed file}

**READMEs Condensed:**
{list each README with before/after line counts}
```

---

## Token Efficiency Notes

- Use `wc -l`, `git diff --name-only`, `head -20` instead of reading full files
- Only read README content when showing previews
- Use grep to extract section headings: `grep "^##" README.md`
- Summarize findings instead of showing full file contents

## Example Usage

```bash
# In your project directory (on feature branch)
/cleanup-project

# Command will:
# 1. Detect you're on feature/new-feature vs main
# 2. Find 15 files changed in this branch
# 3. Identify TODO.md, NOTES.md (untracked) and README.md (340 lines)
# 4. Show interactive report
# 5. You approve removing working docs and condensing README
# 6. Creates backup, executes changes
# 7. Shows summary
```

## Safety Features

1. **Branch-aware** - Only touches files YOU worked on in this branch
2. **Git-aware** - Conservative with tracked files, more aggressive with untracked
3. **Interactive** - No automatic deletions, always ask for approval
4. **Backup first** - All changes backed up before execution
5. **Detailed reporting** - Clear summary of what was changed

## When to Use

- End of feature development (before merging PR)
- After completing a project milestone
- Before archiving/releasing a project
- When cleaning up a messy working branch
