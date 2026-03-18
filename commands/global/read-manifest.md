---
name: read-manifest
description: Smart session startup - read MANIFEST, select a task, load relevant context for current work
allowed-tools: Read, Grep, Glob, Bash
---

# Read MANIFEST Command

## Instructions

You are helping the user start a work session with task-focused context loading using the MANIFEST system.

### Step 1: Read Root MANIFEST

Read the root `MANIFEST.md`:
```bash
cat MANIFEST.md
```

If MANIFEST.md doesn't exist:
- Inform user: "No MANIFEST.md found. Would you like to generate one with `/generate-manifest`?"
- Exit command

### Step 2: Parse Active Tasks

From the root MANIFEST, extract the `## Active Tasks` section:

1. **For each task**, identify:
   - Task name (from `### Task: ...`)
   - Status (from `**Status**: ...`)
   - Active files list (from `**Active files**:`)
   - TODO items (from `**TODO**:`)
   - Notes (from `**Notes**:`)

2. Count pending TODOs per task (lines matching `- [ ]`).

**If no Active Tasks section exists**: Fall back to directory exploration (Step 2b).

### Step 2b: Fallback — No Active Tasks

If MANIFEST has no `## Active Tasks` section (old format):

```
This MANIFEST uses the legacy format without Active Tasks.

Options:
1. Explore by directory (data/, figures/, scripts/, etc.)
2. Regenerate MANIFEST with tasks: /generate-manifest
```

If user selects directory exploration, use the `## Directory Contents` or `## Key Directories` sections to present options, then read the selected subdirectory MANIFEST.

### Step 3: Present Tasks to User

Use AskUserQuestion to present tasks:

**Question**: "What task are you working on?"

**Options** (dynamically built):
- For each non-Complete task:
  - **Label**: Task name
  - **Description**: Status — N active files, M pending TODOs

- Always include:
  - **Label**: "Something else / general exploration"
  - **Description**: "Browse the project without loading specific task context"

**Example**:
```
What task are you working on?

1. Building phylogenetic tree — In progress — 4 files, 2 TODOs
2. Writing curation paper — Active — 3 files, 2 TODOs
3. Data enrichment from GenomeArk — Paused — 2 files, 1 TODO
4. Something else / general exploration
```

### Step 4: Load Context Based on Selection

#### If user selects a task:

1. **Identify which subdirectory MANIFESTs are needed**:
   - For each active file, determine its parent directory
   - Deduplicate directories
   - Read those subdirectory MANIFESTs (if they exist)

2. **Read relevant subdirectory MANIFESTs**:
   ```bash
   # For each unique directory in the task's active files
   cat data/MANIFEST.md       # if task has files in data/
   cat figures/MANIFEST.md    # if task has files in figures/
   ```

3. **Present focused summary**:
   ```
   Context loaded for: [task name]

   Active files:
   - `path/file1` — description (from MANIFEST)
   - `path/file2` — description (from MANIFEST)
   - `directory/` — summary (from subdirectory MANIFEST)

   Pending TODOs:
   - [ ] First TODO item
   - [ ] Second TODO item

   Task notes: [from MANIFEST Notes field]

   Subdirectory context loaded:
   ✓ data/MANIFEST.md — [brief summary]
   ✓ figures/MANIFEST.md — [brief summary]

   Ready to work on: [task name]
   ```

#### If user selects "Something else":

1. **Present directory options** from MANIFEST:
   ```
   Which area would you like to explore?

   1. Data files and processing
   2. Generated figures and visualizations
   3. Scripts and automation
   4. Documentation and notes
   5. General project overview (already loaded)
   ```

2. Read the selected subdirectory MANIFEST.

3. Present summary of that area.

### Step 5: Offer Next Steps

**If task selected**:
```
Suggested next steps:
- Start with first TODO: [first pending item]
- Read active file: [main file for this task]
- Check recent changes: git log --oneline [active files] | head -5
- Update task progress: /update-manifest (at end of session)

What would you like to do?
```

**If exploration selected**:
```
Suggested next steps:
- List files: ls -lh [directory]/
- Read specific file: Let me know which to examine
- Generate MANIFEST: /generate-manifest [directory]

What would you like to explore?
```

---

## Token Efficiency

**Typical token usage**:
- Root MANIFEST: ~800 tokens
- 2-3 subdirectory MANIFESTs: ~500-1000 tokens each
- **Total**: ~2,000-3,000 tokens for complete task context

Compare to manual exploration: ~8,000-15,000 tokens
**Savings**: ~70-80% token reduction with better task relevance.

---

## Error Handling

**No MANIFEST.md**: Suggest `/generate-manifest`

**No Active Tasks section**: Fall back to directory exploration (Step 2b)

**Missing subdirectory MANIFEST**:
```
Note: [directory]/MANIFEST.md not found
- Suggestion: Generate with /generate-manifest [directory]
- For now: I can list files with ls -lh [directory]/

Would you like me to:
1. Generate the MANIFEST now
2. List files in the directory
3. Continue without it
```

**No pending TODOs in selected task**: Note this and suggest the user add TODOs via `/update-manifest`.

---

## Integration

**Session start pattern**:
```bash
/read-manifest              # Load task context
# Work on project...
/update-manifest            # Capture progress
/safe-exit                  # or /safe-clear
```

**After interrupted session**:
```bash
/resume-interrupted         # Recover from transcript backup
/read-manifest              # Load task context
```
