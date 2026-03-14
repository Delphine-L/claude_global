# Token Efficiency - Project Patterns

This file contains project organization patterns, task management, background process management, MANIFEST system, and efficient file operations. See [SKILL.md](SKILL.md) for core rules.

---

## Analysis File Organization (Iteration 2)

### Problem
Large Jupyter notebooks (4+ MB) consume excessive tokens when loaded for context:
- Full notebook: ~1,135,000 tokens
- Even with selective reading, difficult to load just figure analysis

### Solution: Separate Analysis Files

Create `analysis_files/` directory with individual markdown files for each analysis component:

```
project/
├── analysis_files/
│   ├── MANIFEST.md
│   ├── Method.md
│   └── figures/
│       ├── 01_figure_name.md
│       ├── 02_figure_name.md
│       └── ...
├── notebooks/ (keep for code execution)
└── figures/ (actual PNG/PDF files)
```

**Token Savings**:
- Before: ~1,135,000 tokens (full notebooks)
- After: ~22,000 tokens (analysis files)
- **Savings: 98% reduction**

### What to Include in Analysis Files

Each figure analysis file should contain **only publication-ready text**:
- Figure description (formatted as figure legend)
- Analysis framework and interpretation
- Statistical methods and results
- Mechanistic explanations
- Context from other metrics
- Biological/technical considerations

**DO NOT include**:
- TODOs or placeholders
- Draft notes or scratch work
- Code or computational details
- Incomplete sections

### Managing TODOs Separately

Track analysis TODOs in your note-taking system (Obsidian, etc.), not in the analysis files:

**Obsidian TODO note example**:
```markdown
# Figure Analysis TODOs

## Figure 1: Scaffold N50
- [ ] Run Kruskal-Wallis test
- [ ] Get sample sizes for each category
- [ ] Fill in p-values
- [ ] Write interpretation

## Figure 2: Gap Density
- [ ] Calculate gap density metric
- [ ] Run statistical comparisons
...
```

**Analysis file stays clean**:
```markdown
# Figure 1: Scaffold N50 Analysis

## Figure Description
[Publication-ready description]

## Analysis
[Complete, polished analysis text]
```

### Benefits

1. **Modular loading**: Load only the figure(s) being worked on
2. **Publication-ready**: Text can go directly into manuscript
3. **Easy maintenance**: Update individual analyses without touching notebooks
4. **Collaborative**: Easier to review/edit specific sections
5. **Notebook simplification**: Final notebook becomes just TOC + links to analysis files

### Implementation Pattern

1. Read existing notebook and paper draft to understand style
2. Create clean analysis files matching that style
3. Track TODOs separately in Obsidian/notes
4. Link figures MANIFEST to analysis files
5. Update root MANIFEST to reference analysis_files/

### Usage in Claude Sessions

**Load specific analysis (~5-10 KB)**:
```bash
cat analysis_files/figures/02_scaffold_consolidation.md
```

**Instead of full notebook (~4,200 KB)**:
```bash
cat Curation_Analysis_3Categories.ipynb  # Avoid this!
```

### Integration with Notebooks

**Future workflow**: Create streamlined manuscript notebook that:
- Contains only TOC, intro, conclusions
- Displays figures: `![Figure 1](figures/01_name.png)`
- Links to analysis files for text content
- Executes minimal code for figure generation only

---

## Task Management Patterns

### TodoWrite for Sequential File Processing

When processing multiple files sequentially (e.g., populating analysis files, updating documentation):

**Efficient pattern**:
```
1. Create todos for all files at start
2. Mark ONLY ONE as in_progress at a time
3. Complete the file
4. Mark as completed IMMEDIATELY (don't batch)
5. Mark next file as in_progress
6. Repeat
```

**Example from analysis file population**:
```json
[
  {"content": "Fill in Figure 1 analysis", "status": "completed", "activeForm": "Filling in Figure 1 analysis"},
  {"content": "Fill in Figure 2 analysis", "status": "in_progress", "activeForm": "Filling in Figure 2 analysis"},
  {"content": "Fill in Figure 3 analysis", "status": "pending", "activeForm": "Filling in Figure 3 analysis"}
]
```

**Why this matters**:
- **Provides clear progress tracking** for multi-step tasks (7/7 files completed)
- **Prevents skipping files** or losing track of position
- **Shows user real-time progress** as files are completed
- **Maintains focus** on one file at a time
- **Creates completion satisfaction** as todos are checked off
- **Enables context resumption** if session is interrupted

**Token efficiency benefit**:
- Minimal token cost (~100-200 tokens per update)
- Massive value in maintaining task context and preventing rework
- User can see progress without asking "what's done?"
- Eliminates need for progress explanations in every response

**Anti-pattern**:
- Don't mark multiple todos as completed at once
- Don't skip updating todos between files
- Don't have multiple in_progress tasks simultaneously

**Best practices**:
- Create all todos upfront for visibility into total work
- Update status immediately after each completion
- Use descriptive `content` for what needs to be done
- Use present continuous `activeForm` for in-progress display

---

## Managing Long-Running Background Processes

### Best Practices for Background Tasks

When running scripts that take hours, properly manage background processes to prevent resource leaks and enable clean session transitions:

**1. Run in background** with Bash tool `run_in_background: true`

**2. Document the process** in status files:
```markdown
## Background Processes
- Script: comprehensive_search.py
- Process ID: Available via BashOutput tool
- Status: Running (~6% complete)
- How to check: BashOutput tool with bash_id
```

**3. Kill cleanly** before session end:
```python
# Before ending session:
# 1. Kill all background processes
KillShell(shell_id="abc123")

# 2. Create resume documentation (see claude-collaboration skill)
# 3. Document current progress (files, counts, status)
# 4. Save intermediate results
```

**4. Design scripts to be resumable** (see Python Environment Management skill):
- Check for existing output files (skip if present)
- Load existing results and append new ones
- Save progress incrementally (not just at end)
- Track completion status in structured format

### Avoiding Unnecessary Polling

**Problem**: Repeatedly checking background process output wastes tokens when results aren't ready yet.

**When to run in background**:
- Process will take >30 seconds (planemo test, long builds, large data downloads)
- User doesn't need immediate results
- Process can be checked asynchronously

**Token-efficient pattern**:
1. Start process in background, capture shell ID
2. Update todo list with shell ID for reference
3. Inform user once: "Running in background, shell ID: XXXXX"
4. Don't repeatedly check output unless user asks
5. User can interrupt and say "check later" - acknowledge and stop polling

**Example**:
```python
# Start background process
Bash(command="planemo test ...", run_in_background=true)
# Returns shell_id: "09584f"

# Update todos ONCE with reference
TodoWrite([{
  "content": "Check test results later (shell ID: 09584f)",
  "status": "pending"
}])

# Tell user ONCE
"Test running in background (ID: 09584f). Let me know when to check results."

# DON'T repeatedly poll BashOutput unless user asks
# AVOID: Multiple BashOutput calls every few seconds
```

**Token savings**: Avoiding 15-20 repeated BashOutput checks (200 tokens each) = ~3000-4000 tokens saved per long-running process.

### Pre-Interruption Checklist

Before ending a session with running processes:

1. Check background process status
2. Kill all background processes cleanly
3. Create resume documentation (RESUME_HERE.md)
4. Document current progress with metrics
5. Save intermediate results to disk
6. Verify resume commands in documentation

### Token Efficiency Benefit

Properly managing background processes:
- **Prevents context pollution** - Old process output doesn't leak into new sessions
- **Enables clean handoff** - Resume docs allow fresh session without re-explaining
- **Avoids redundant work** - Resumable scripts don't repeat completed tasks

---

## Repository Organization for Long Projects

### Problem
Data enrichment and analysis projects generate many intermediate files, scripts, and logs that clutter the root directory, making it hard to:
- Find the current working dataset
- Identify which scripts are actively used
- Navigate the project structure
- Maintain focus on important files

### Solution: Organize Early and Often

**Create dedicated subfolders at project start:**
```bash
mkdir -p python_scripts/ logs/ tables/
```

**Organization strategy:**
- `python_scripts/` - All analysis and processing scripts (16+ scripts in VGP project)
- `logs/` - All execution logs from script runs (38+ logs in VGP project)
- `tables/` - Intermediate results, old versions, and archived data
- Root directory - Only main working dataset and current outputs

**Benefits:**
- Reduces cognitive load when scanning directory
- Makes git status cleaner and more readable
- Easier to exclude intermediate files from version control
- Faster file navigation with autocomplete
- Professional project structure for collaboration

**When to organize:**
- At project start (ideal)
- After accumulating 5+ scripts or logs (acceptable)
- Before sharing project with collaborators (essential)

**Example cleanup script:**
```bash
# Move all Python scripts
mkdir -p python_scripts
mv *.py python_scripts/

# Move all logs
mkdir -p logs
mv *.log logs/

# Move intermediate tables (keep main dataset in root)
mkdir -p tables
mv *_intermediate.csv *_backup.csv *_old.csv tables/
```

**Token efficiency impact:**
- Cleaner `ls` outputs (fewer lines to process)
- Easier to target specific directories with Glob
- Reduced cognitive overhead when navigating
- Faster file location with autocomplete

---

## Project Navigation Patterns

### MANIFEST System for Large Projects

**Problem**: Large projects require reading many files (notebooks, data, scripts) for orientation, consuming 15,000-23,000 tokens per session startup.

**Solution**: Create MANIFEST.md files (lightweight project indexes) that provide complete context in 2,000-2,500 tokens.

#### Token Impact

- **Without MANIFESTs**: 15,000-23,000 tokens for project orientation
- **With MANIFESTs**: 2,000-2,500 tokens for complete context
- **Savings**: 85-90% reduction in session startup cost

#### Implementation

1. **Create MANIFEST.md in each major directory** (root, data/, figures/, scripts/, documentation/)
2. **Include essential sections**:
   - Quick Reference (entry points, key outputs, dependencies)
   - File Inventory (with descriptions, sizes, purposes)
   - Workflow Dependencies (how files relate)
   - Notes for Resuming Work (status, next steps, issues)
   - Metadata (tags, environment, Obsidian links)

3. **Use commands for maintenance**:
   - `/generate-manifest` - Create new MANIFESTs
   - `/update-manifest` - Quick updates after sessions

4. **Target token counts**:
   - Root MANIFEST: 1,000-2,000 tokens
   - Subdirectory MANIFEST: 500-1,000 tokens

#### Session Workflow

**Start session**:
```bash
# Read MANIFESTs for context (2,000 tokens vs 15,000)
cat MANIFEST.md                # Project overview
cat figures/MANIFEST.md        # If working on figures
```

**End session**:
```bash
# Capture session progress
/update-manifest
```

#### When to Use

- Projects with 3+ notebooks
- Multiple data files and directories
- Many generated figures (10+)
- Long-term research projects
- Team collaboration

#### Benefits

- **For Claude**: 85-90% fewer tokens for session startup
- **For Users**: Quick work resumption without reading files
- **For Teams**: Faster onboarding, shared understanding

See `folder-organization` skill for complete MANIFEST system documentation including templates, workflows, and best practices.

### Obsidian Link Verification

**Pattern:** Use Python script for vault-wide broken link detection

**Token Impact:**
- Manual verification: 500-1000 tokens per file x N files
- Automated script: ~100 tokens total
- **Savings: 98-99% for large vaults**

**When to use:**
- After vault reorganization
- Before project sharing
- After major file moves/renames
- Periodically for large vaults

**Implementation:** See obsidian skill "Link Management and Verification" section for full script

**Example:**
- 74 broken links across 15 files
- Manual: 7,500-15,000 tokens
- Script: 100 tokens
- Time: 2 seconds vs 20+ minutes

### Efficient Session Startup with MANIFEST System

**Pattern**: Use `/read-manifest` at session start instead of manually reading files

**Token Savings**:
- Traditional approach: Reading 3-4 large notebooks + data files = ~15,000-50,000 tokens
- MANIFEST approach: Root MANIFEST + 2-3 subdirectory MANIFESTs = ~2,500-5,000 tokens
- **Savings**: 70-90% token reduction while getting 80% of needed context

**Example from session** (2026-02-25):
```bash
# User started session with /read-manifest
# Loaded:
#   - Root MANIFEST.md (~500 tokens)
#   - clade_analyses/MANIFEST.md (~1,000 tokens)
#   - clade_analyses/ALL_CLADES_COMPLETE.md (~3,500 tokens)
#   - analysis_files/MANIFEST.md (~2,000 tokens)
# Total: ~7,000 tokens
#
# Alternative (reading actual files):
#   - Curation_Impact_Analysis.ipynb (4.2 MB = ~1,050,000 tokens)
#   - Curation_Analysis_3Categories.ipynb (338 KB = ~85,000 tokens)
#   - Multiple data files (500-1000 tokens each)
# Total: ~1,135,000+ tokens
#
# Savings: ~99% reduction (7K vs 1,135K tokens)
```

**Best Practice**:
1. Projects with MANIFESTs: **Always** start with `/read-manifest`
2. Let command present main document options
3. Load only relevant subdirectory MANIFESTs based on work focus
4. Read actual files only when editing them

**When to use**:
- Session startup in MANIFEST-enabled projects
- Switching between tasks in same project
- Returning to project after time away
- Don't use if MANIFEST doesn't exist (generate first with `/generate-manifest`)

---

## Efficient File Operations

### Moving Multiple Files Safely

When moving files where some might not exist, use loops with file existence checks to avoid errors and provide clean execution:

**Inefficient (fails on missing files):**
```bash
mv file1.py file2.py file3.py destination/  # Fails if any missing
```

**Efficient (handles missing files gracefully):**
```bash
for f in file1.py file2.py file3.py; do
  if [ -f "$f" ]; then
    mv "$f" destination/ && echo "Moved $f"
  fi
done
```

**For pattern-based moves:**
```bash
# Instead of: mv fix_*.py deprecated/  # Might error
for f in fix_*.py; do
  [ -f "$f" ] && mv "$f" deprecated/
done
```

**Benefits:**
- No errors from missing files
- Clean output showing what was actually moved
- Safe for batch operations with partial file lists
- Easy to adapt for copy, remove, or other operations

### File Reorganization

When reorganizing project files into directories, use direct mv commands with patterns instead of reading file contents:

**Efficient approach:**
```bash
# Create all directories first
mkdir -p figures data tests notebooks docs archives

# Move files by pattern (fast, no file reads needed)
mv fig*.png figures/
mv *.json *.tsv *.csv data/
mv test_*.py tests/
mv *.ipynb notebooks/
mv *.md docs/
```

**Avoid:**
- Reading each file to determine where it belongs
- One-by-one file moves with individual commands
- Checking file contents when filename pattern is clear

**Token savings**: For reorganizing 50+ files, this approach uses ~1K tokens vs. 5-10K tokens if reading files to determine categorization.

**Example verification:**
```bash
# Count moved files efficiently
for dir in figures data tests notebooks; do
  echo "$dir: $(ls $dir | wc -l) files"
done
```

### Validating Against Large Reference Files

**Pattern**: Need to validate data against large reference file (e.g., phylogenetic tree, genome assembly)

**Inefficient** (reading tree file repeatedly):
```python
# Costs ~500 tokens per read
tree_species = parse_tree('Tree_final.nwk')
# Then validate each config...
# Read again for next validation...
```

**Efficient** (one-time extraction, reuse):
```python
# Read once, extract species names, save to small file
import re
with open('Tree_final.nwk') as f:
    tree_content = f.read()
tree_species = set(re.findall(r'([A-Z][a-z]+_[a-z]+)', tree_content))

# Save for reuse (~50 tokens vs 500)
with open('tree_species_list.txt', 'w') as f:
    f.write('\n'.join(sorted(tree_species)))

# Future validations use the small file
tree_species = set(open('tree_species_list.txt').read().splitlines())
```

**Token savings**: 90% (500 -> 50 tokens per validation)

**When to use**:
- Iterative config file generation and testing
- Multiple datasets need to validate against same reference
- Reference file is large (>100KB) but extracted data is small

**Example use cases**:
- Phylogenetic tree species lists (multi-MB tree -> few KB species list)
- Genome feature annotations (large GFF -> gene name list)
- Reference genome sequences (FASTA -> sequence IDs)

### Safe Directory Removal

**Always use `rmdir` instead of `rm -rf` when removing directories you expect to be empty:**

```bash
# Good - safe, fails if directory not empty
rmdir old-folder/

# Avoid - dangerous, silently removes everything
rm -rf old-folder/
```

**Benefits:**
- Prevents accidental deletion of files
- Alerts you if directory unexpectedly contains files
- Forces you to handle hidden files (.DS_Store, etc.)

**Handling .DS_Store files:**
```bash
# Remove .DS_Store, then remove directory
rm Galaxy/.DS_Store && rmdir Galaxy/

# Or check first
ls -la Galaxy/  # Shows hidden files
```

**When to use rm -rf:**
- Only when explicitly removing directories with content
- With user confirmation first
- Never as default for cleanup
