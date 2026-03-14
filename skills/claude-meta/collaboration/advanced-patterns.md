# Advanced Patterns

## Pattern 1: Tiered Skills (Beginner -> Expert)

**Beginner skill:**
```markdown
# VGP Basics
- What VGP workflows are
- How to run simple commands
- Basic troubleshooting
```

**Expert skill:**
```markdown
# VGP Advanced
- Architecture internals
- Custom workflow modifications
- Performance tuning
```

**Usage:** Load appropriate tier based on user expertise

## Pattern 2: Conditional Skills (Environment-Specific)

**Development skill:**
```markdown
# Development Mode
- Use test datasets
- Enable verbose logging
- Skip certain validations
```

**Production skill:**
```markdown
# Production Mode
- Use --quiet mode
- Enable all validations
- Follow strict procedures
```

**Usage:** Swap skills based on environment

## Pattern 3: Role-Based Skills

**For users:**
```markdown
# User Guide
- How to run workflows
- Common commands
- Troubleshooting
```

**For developers:**
```markdown
# Developer Guide
- Code architecture
- How to add new workflows
- Testing patterns
```

**Usage:** Different skills for different team roles

---

## Documentation for Session Interruptions

### Creating Resume Documentation

When working on long-running tasks that may span multiple sessions, create comprehensive documentation to enable seamless resume:

**Three-tier documentation approach**:

1. **RESUME_HERE.md** - Quick start guide
   - 3-5 step quick start
   - Essential commands only
   - Clear current status
   - Visual indicators (emojis for status)

2. **PROJECT_STATUS.md** - Complete context
   - What has been done
   - What's in progress
   - What's next
   - All files created
   - Key findings
   - Sample of missing data points

3. **scripts/README.md** - Technical details
   - Script documentation
   - How to run each tool
   - Troubleshooting
   - Expected outputs

### Template: RESUME_HERE.md

```markdown
# Resume [Project Name]

## Current Status
Completed: [brief status with metrics]
In Progress: [what's running, % complete]
Interrupted at: [specific point with details]

## Resume in 3 Steps

### 1. Setup
\```bash
cd /path/to/project
conda activate env_name
\```

### 2. Continue work
\```bash
./script.py  # Brief explanation of what this does
\```

### 3. Check results
\```bash
# Quick validation command with expected output
\```

## Full Documentation
- **PROJECT_STATUS.md** - Complete context
- **scripts/README.md** - Technical details
```

### Best Practices

1. **Create early**: Don't wait until interruption is imminent
   - Create documentation as you work
   - Update it throughout the session

2. **Test commands**: Verify resume commands actually work
   - Don't assume paths or commands will work
   - Include absolute paths when needed

3. **Status tracking**: Include counts, percentages, specific progress points
   - "6% complete (31/518 species)" not just "in progress"
   - Show what's done vs. what remains

4. **Next actions**: Be explicit about what happens next
   - "Run script X, then merge with Y, then verify with Z"
   - Include expected runtime

5. **Background processes**: Document how to check/resume running processes
   - Process IDs if applicable
   - How to check status
   - How to restart if needed

### Example: Long-Running Data Fetch Project

```markdown
# Resume GenomeScope Data Retrieval

## Current Status
- **123 species** have GenomeScope data (17.2% of 716 total)
- **Comprehensive search was running** - searches all assembly folders
- **Interrupted at ~6% progress** (31/518 remaining species)

## Resume in 3 Steps

### 1. Navigate and activate environment
\```bash
cd /Users/user/project
conda activate curation_paper
\```

### 2. Resume comprehensive search
\```bash
# This will pick up where we left off (skips existing data automatically)
python scripts/03c_comprehensive_genomescope_search.py
# Expected runtime: ~2 hours
\```

### 3. Merge new data (after search completes)
\```bash
python scripts/04_merge_and_enrich.py
\```

## Files Already Created
- genomescope_data/ - 123 raw summary files
- genomescope_enrichment_data.csv - Parsed data
- VGPPhase1-freeze-1.0-ENRICHED.csv - Main dataset

## Full Documentation
- **GENOMESCOPE_DATA_RETRIEVAL_STATUS.md** - Complete status
- **scripts/README_GENOMESCOPE_SCRIPTS.md** - Script docs
```

### When to Create Resume Documentation

**Always create when:**
- Task will take hours to complete
- Running scripts that can be interrupted
- Multiple scripts need to be run in sequence
- Complex setup with multiple steps
- Work may span multiple days/sessions

**Pattern ensures:**
- Anyone (including you later) can resume work
- No mental overhead to remember state
- Clear next steps visible immediately
- All context preserved
