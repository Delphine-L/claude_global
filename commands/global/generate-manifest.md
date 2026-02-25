# Generate MANIFEST Command

Generate or update a MANIFEST.md file for the current directory or specified subdirectory. This command helps maintain project navigation and context efficiency by creating comprehensive file inventories.

## Instructions

You are tasked with generating a MANIFEST.md file based on the MANIFEST_TEMPLATE.md. Follow these steps:

### 1. Determine Target Directory

**Determine generation scope**:

If user specifies a directory:
- Generate MANIFEST only for that directory

If user specifies `--all` or `--recursive`:
- **RECURSIVE MODE**: Generate MANIFESTs for ALL directories and subdirectories
- Exclude `deprecated/` and its subdirectories
- Exclude hidden directories (., .git, .claude, etc.)
- Process from deepest subdirectories first, then work up to root
- Skip directories that already have MANIFEST.md (unless `--force` specified)

If no arguments specified:
- Ask user: Single directory or recursive generation?
- Use AskUserQuestion to clarify

**Finding directories for recursive generation**:
```bash
# Find all directories (excluding deprecated and hidden)
find . -type d -not -path "*/deprecated/*" -not -path "*/.*" | sort -r

# Check which ones already have MANIFEST.md
find . -name "MANIFEST.md" -not -path "*/deprecated/*"
```

### 2. Check for Template

Look for `MANIFEST_TEMPLATE.md` in:
1. Current project root
2. $CLAUDE_METADATA/templates/
3. Use built-in template structure if none found

### 3. Analyze Directory Contents

**Gather information about the target directory**:

For ALL directories:
- List all files with sizes (`ls -lh`)
- Get directory size (`du -sh`)
- Check last modification dates
- Identify file types and patterns

For ROOT directories specifically, also check for:
- Notebooks (.ipynb files): Get sizes, check first/last cells for descriptions
- Key documentation (README, data dictionaries, etc.)
- Main subdirectories and their purposes
- Overall project structure

For DATA directories specifically, also check for:
- CSV/TSV files: row counts, column counts (`wc -l`, `head -1`)
- Data provenance files (README, data dictionaries)
- Original vs processed data distinctions
- Check deprecated/ folder for original versions

For FIGURES directories specifically, also check for:
- Image files (PNG, PDF, SVG): sizes, naming patterns
- Which notebooks/scripts generate them (search for filename in code)
- Subdirectory organization
- Figure numbering/naming conventions

For SCRIPTS directories specifically, also check for:
- Python/R/shell scripts
- Script purposes (check docstrings, comments)
- Execution order hints (numbered files, imports)
- Required dependencies (import statements)
- Input/output patterns (argparse, file I/O)

For DOCUMENTATION directories specifically, also check for:
- Subdirectory structure and purposes
- Document types and dates
- Active vs archive status

### 4. Extract Key Information

**Use efficient methods to gather details**:

For notebooks:
- Read first markdown cell for purpose/description
- Check for section headers (look for # headers)
- Identify key imports (pandas, matplotlib, etc.) to understand dependencies
- Look for figure save commands to identify outputs
- DO NOT read entire large notebooks - use targeted searches

For scripts:
- Read docstrings and header comments
- Check argparse/main function for usage
- Look for input/output file patterns
- Identify key dependencies from imports

For data files:
- Get row/column counts for CSV/TSV files
- Read README or data dictionary files
- Check for companion metadata files
- Look for date stamps in filenames

### 5. Identify Dependencies

**Map relationships between files**:
- Which notebooks depend on which data files?
- Which scripts generate which data files?
- Which notebooks generate which figures?
- Which scripts generate which figures?
- Are there sequential dependencies? (script A output → script B input)

Use grep/search to find:
- `pd.read_csv("filename")` → notebook depends on data
- `plt.savefig("filename")` → notebook generates figure
- Script imports or calls → script dependencies
- File paths in code → file usage

### 6. Generate MANIFEST Content

**Follow the template structure**:

#### Required Sections (all directory types):
- Header with directory name, last updated, purpose, status
- Quick Reference (entry points, key outputs, dependencies)
- Files section (organized by type)
- Directory Structure (visual tree)
- Notes for Resuming Work (current status, next steps)
- Metadata (creator, project, tags, environment, Obsidian path)

#### For Root MANIFEST specifically:
- Focus on high-level overview
- Describe main notebooks with priority classification
- List key subdirectories with brief descriptions
- Include workflow dependencies section
- Add "For Claude Code Sessions" section with usage instructions

#### For Subdirectory MANIFESTs:
- Focus on files in THIS directory only
- Reference parent/sibling directories when showing dependencies
- Be specific about file purposes
- Keep descriptions concise

#### File Entry Format:
```markdown
#### `filename.ext`
- **Purpose/Description**: [What is this file? What does it do?]
- **Depends on**: [Input files, required data]
- **Generates**: [Output files, results]
- **Key findings/notes**: [Important information]
- **Last modified**: YYYY-MM-DD
- **[Other relevant fields from template]**
```

### 7. Handle User Input Fields

**Some fields require user knowledge** - mark these clearly:
- [USER TO FILL - description of what's needed]
- Priority classifications (ask user if uncertain)
- Key findings summaries (can infer from notebook, but ask user to confirm)
- Environment names (can detect active environment)
- Obsidian notes paths (ask user)

**Ask user questions when needed** using AskUserQuestion for:
- Priority classification of notebooks (main vs complementary)
- Confirmation of key findings interpretation
- Clarification of deprecated vs active files
- Purpose of undocumented files

### 8. Token Efficiency Considerations

**Keep the MANIFEST concise but informative**:
- Target 1000-2000 tokens for root MANIFEST
- Target 500-1000 tokens for subdirectory MANIFESTs
- Be specific but not verbose
- Use bullet points, not paragraphs
- Front-load important information
- Think: "What minimum context does Claude need to resume work?"

### 9. Update Existing MANIFESTs

**If MANIFEST.md already exists**:
- Ask user if they want to update or regenerate
- Preserve user-filled content (key findings, priorities, notes)
- Update file lists, sizes, and dates
- Merge new files with existing descriptions
- Update "Last Updated" date and "Current Status"

### 10. Finalize

**After generating**:
1. Show the user a preview of key sections
2. Write the MANIFEST.md file
3. Inform user about:
   - Fields that need user input
   - Files that may need clarification
   - Suggested next steps (creating subdirectory MANIFESTs)
4. Update parent MANIFEST if this is a subdirectory

## Usage Examples

```
/generate-manifest
# Asks which directory, then generates MANIFEST

/generate-manifest data
# Generates MANIFEST for data/ subdirectory

/generate-manifest --all
# RECURSIVE MODE: Generate MANIFESTs for ALL directories (exclude deprecated/)
# Skips directories that already have MANIFEST.md

/generate-manifest --recursive --force
# Generate/regenerate MANIFESTs for ALL directories, overwriting existing ones

/generate-manifest --update
# Updates existing MANIFEST with current file information (use /update-manifest instead)
```

## Recursive Generation Protocol

### When Generating Multiple MANIFESTs:

**1. Discovery Phase**:
```bash
# Find all directories (exclude deprecated, hidden, and common build dirs)
find . -type d \
    -not -path "*/deprecated/*" \
    -not -path "*/.*" \
    -not -path "*/node_modules/*" \
    -not -path "*/venv/*" \
    -not -path "*/__pycache__/*" \
    | sort -r  # Reverse sort: deepest first
```

**2. Filtering Phase**:
- Check each directory for existing MANIFEST.md
- Skip if MANIFEST exists (unless --force)
- Exclude directories with only hidden files or empty directories
- Prioritize directories with meaningful content (scripts, data, figures, notebooks)

**3. Generation Order**:
- Process deepest subdirectories first
- Work up to parent directories
- This allows parent MANIFESTs to reference child MANIFESTs

**4. Smart Directory Selection**:
Only create MANIFESTs for directories that contain:
- Python/R/shell scripts (5+ files or complex scripts)
- Data files (CSV, TSV, JSON, etc.)
- Notebooks (.ipynb files)
- Figures/visualizations (PNG, PDF, SVG)
- Documentation (MD, TXT, PDF files)

Skip MANIFEST creation for:
- Nearly empty directories (< 3 files)
- Directories with only generated files (__pycache__, .pyc)
- Temporary directories
- Build artifacts

**5. Batch Processing**:
- Show user list of directories that will get MANIFESTs
- Ask for confirmation before generating all
- Generate in batches, showing progress

**6. Consolidated Summary**:
```markdown
## MANIFEST Generation Summary - Recursive

**Date**: YYYY-MM-DD
**Directories Processed**: X

### MANIFESTs Created:
1. ✅ data/MANIFEST.md (15 files)
2. ✅ scripts/MANIFEST.md (23 files)
3. ✅ figures/MANIFEST.md (7 subdirectories)
4. ✅ clade_analyses/mammals/MANIFEST.md (8 files)
5. ✅ clade_analyses/birds/MANIFEST.md (8 files)
... [continue]

### Directories Skipped:
- deprecated/ - Excluded by filter
- .git/ - Hidden directory
- __pycache__/ - Generated files only
- temp/ - Empty directory

### Next Steps:
- Review generated MANIFESTs and fill in user-specific fields
- Update root MANIFEST.md to reference new subdirectory MANIFESTs
```

## Best Practices

1. **Be thorough but efficient** - Don't read entire large files, use targeted searches
2. **Ask questions** - Use AskUserQuestion when information is ambiguous
3. **Maintain consistency** - Follow the template structure closely
4. **Recursive generation** - Use for initial project setup or major reorganization
5. **Incremental updates** - Use /update-manifest for ongoing maintenance
4. **Think about resumption** - What would you need to know in 6 months?
5. **Update regularly** - MANIFESTs should be living documents
6. **Cross-reference** - Link related files and directories
7. **Date everything** - Timestamps provide important context
8. **Tag appropriately** - Use searchable tags for different file types/purposes

## Integration with Other Commands

- Use with `/update-skills` to capture MANIFEST patterns in skills
- Use with `/safe-exit` to update MANIFESTs before ending session
- Use with `/share-project` to include MANIFESTs in shared packages
- Use with `/cleanup-project` to update MANIFESTs after cleanup

---

**Remember**: The goal is to create a concise, informative index that allows Claude Code to understand the project structure in ~500-2000 tokens instead of reading thousands of tokens of actual files.
