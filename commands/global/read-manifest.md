---
name: read-manifest
description: Smart session startup - read MANIFEST, identify main documents, load relevant context for current work
allowed-tools: Read, Grep, Glob, Bash
---

# Read MANIFEST Command

## Instructions

You are helping the user start a work session with optimal context loading using the MANIFEST system.

### Step 1: Read Root MANIFEST

**Read the root MANIFEST.md**:
```bash
cat MANIFEST.md
```

If MANIFEST.md doesn't exist:
- Inform user: "No MANIFEST.md found in this directory. Would you like to generate one with `/generate-manifest`?"
- Exit command

### Step 2: Parse Root MANIFEST

From the root MANIFEST, extract:

1. **Main Documents** (notebooks, primary scripts, key files with Priority field):
   - Look in "Files" → "Notebooks" section
   - Look for files marked with `**Priority**: Main` or similar
   - Typically .ipynb files or primary analysis files

2. **For each main document, identify dependencies**:
   - Look at `**Depends on**:` field
   - Note which subdirectories are referenced (data/, figures/, scripts/, etc.)
   - Note any specific files mentioned

3. **Available subdirectory MANIFESTs**:
   - Check "Key Directories" section
   - Note which subdirectories have MANIFEST.md files

### Step 3: Present Options to User

Use AskUserQuestion to present main documents and general option:

**Question format**:
```
"What would you like to work on in this session?"
```

**Options** (dynamically built from MANIFEST):
1. For each main document found:
   - **Label**: Document name (e.g., "Curation_Impact_Analysis.ipynb")
   - **Description**: Purpose from MANIFEST (1-2 sentences)

2. Always include:
   - **Label**: "Something else / general exploration"
   - **Description**: "Browse the project without loading specific document context"

**Example**:
```
Question: "What would you like to work on in this session?"
Options:
1. Curation_Impact_Analysis.ipynb - Comprehensive analysis of genome assembly quality differences between different methods of manual curation
2. Curation_Analysis_3Categories.ipynb - Focused analysis comparing three assembly/curation methods
3. Haplotype_Comparison_Analysis.ipynb - Detailed analysis of assembly quality between main and alternate haplotype
4. Something else / general exploration - Browse the project without loading specific document context
```

### Step 4: Load Context Based on Selection

#### If user selects a main document:

1. **Identify document dependencies** from MANIFEST:
   - Which data files/directories does it use?
   - Which figure directories does it write to?
   - Which scripts does it call?

2. **Read relevant subdirectory MANIFESTs**:
   ```bash
   # If document depends on data/
   cat data/MANIFEST.md

   # If document generates figures/
   cat figures/MANIFEST.md

   # If document uses scripts/
   cat scripts/MANIFEST.md
   ```

3. **Provide focused summary**:
   ```
   📖 Context loaded for [document name]:

   **Main Document**:
   - Purpose: [from MANIFEST]
   - Priority: [from MANIFEST]
   - Key findings: [from MANIFEST if available]

   **Dependencies loaded**:
   ✓ data/MANIFEST.md - [brief summary]
   ✓ figures/MANIFEST.md - [brief summary]
   ✓ scripts/MANIFEST.md - [brief summary]

   **Ready to work on**: [document name]

   You now have complete context (~X tokens) for working on this document.
   ```

#### If user selects "Something else":

1. **Ask follow-up question**:
   ```
   "Which area of the project would you like to explore?"

   Options:
   - Data files and processing
   - Generated figures and visualizations
   - Scripts and automation
   - Documentation and notes
   - General project overview (already loaded)
   ```

2. **Read relevant subdirectory MANIFEST** based on selection:
   ```bash
   cat [selected-directory]/MANIFEST.md
   ```

3. **Provide summary**:
   ```
   📖 Context loaded for [selected area]:

   **Overview**: [Quick summary from MANIFEST]
   **Key files**: [List from MANIFEST]

   You now have context for the [area] area of the project.
   ```

### Step 5: Offer Next Steps

After loading context, suggest next actions:

**If main document selected**:
```
**Suggested next steps**:
- Read the document: `cat [document-name]` (if you need to edit it)
- Check recent changes: `git log --oneline [document-name] | head -5`
- Review figures: `ls -lh figures/[relevant-subdirectory]/`
- Update MANIFEST: `/update-manifest` (at end of session)

What would you like to do?
```

**If exploration selected**:
```
**Suggested next steps**:
- List files in this area: `ls -lh [directory]/`
- Read specific file: Let me know which file to examine
- Generate/update MANIFEST: `/generate-manifest [directory]`

What would you like to explore?
```

## Command Behavior

### Token Efficiency

**Typical token usage**:
- Root MANIFEST: ~1,500 tokens
- 2-3 subdirectory MANIFESTs: ~1,000-2,000 tokens
- **Total**: ~2,500-3,500 tokens for complete focused context

Compare to traditional approach:
- Reading actual notebook: ~5,000-10,000 tokens
- Exploring data files: ~2,000-3,000 tokens
- Checking scripts: ~1,000-2,000 tokens
- **Total**: ~8,000-15,000 tokens

**Savings**: ~70-80% token reduction

### Smart Dependency Detection

**Identify dependencies by parsing MANIFEST**:

Look for these patterns in the document's entry:
```markdown
#### `notebook_name.ipynb`
- **Depends on**:
  - data/vgp_assemblies_unified_corrected.csv
  - scripts/build_unified_dataset.py
- **Generates**:
  - figures/curation_impact_3cat/01-06*.png
```

**From this, load**:
- `data/MANIFEST.md` (document reads from data/)
- `figures/MANIFEST.md` (document writes to figures/)
- `scripts/MANIFEST.md` (document depends on scripts/)

### Handling Missing MANIFESTs

**If subdirectory MANIFEST doesn't exist**:
```
⚠️ Note: [directory]/MANIFEST.md not found
   - Dependency: [document] uses files from [directory]/
   - Suggestion: Generate with `/generate-manifest [directory]`
   - For now: I can list files with `ls -lh [directory]/`

Would you like me to:
1. Generate the MANIFEST now
2. List files in the directory
3. Continue without it
```

### Multiple Main Documents

**If project has 3+ main documents**:
- Show all in the selection menu
- Include brief description for each
- Use Priority field to order (Main priority first)

**If project has 1 main document**:
- Still ask (user might want to explore instead)
- Make main document the default/first option

**If project has no clear main documents**:
- Fall back to directory exploration
- Suggest organizing with Priority field in MANIFEST

## Usage Examples

### Example 1: Focus on Main Notebook

```
User: /read-manifest

Claude:
[Reads MANIFEST.md]

"What would you like to work on in this session?"
1. Curation_Impact_Analysis.ipynb - Comprehensive analysis (MAIN)
2. Exploration notebook - Quick data checks
3. Something else / general exploration

User: 1

Claude:
[Reads data/MANIFEST.md, figures/MANIFEST.md, scripts/MANIFEST.md]

📖 Context loaded for Curation_Impact_Analysis.ipynb:

**Main Document**:
- Purpose: Comprehensive analysis of genome assembly quality differences
- Priority: Main analysis document - START HERE
- Last modified: 2026-02-05

**Dependencies loaded**:
✓ data/MANIFEST.md - 4 datasets, 717 assemblies
✓ figures/MANIFEST.md - 18 figures across 3 categories
✓ scripts/MANIFEST.md - 12 processing scripts

**Ready to work on**: Curation_Impact_Analysis.ipynb

Suggested next steps:
- Read notebook: If you need to edit
- Check recent figures: ls -lh figures/curation_impact_3cat/
- Review data: Files in data/ are documented in loaded MANIFEST

What would you like to do?
```

### Example 2: General Exploration

```
User: /read-manifest

Claude:
[Reads MANIFEST.md]

"What would you like to work on in this session?"
1. Main_Analysis.ipynb - Primary analysis
2. Something else / general exploration

User: 2

Claude:
"Which area of the project would you like to explore?"
1. Data files and processing
2. Generated figures and visualizations
3. Scripts and automation
4. Documentation and notes
5. General project overview (already loaded)

User: 2

Claude:
[Reads figures/MANIFEST.md]

📖 Context loaded for figures/:

**Overview**: 18 publication-quality figures across 3 analysis categories
**Key subdirectories**:
- curation_impact_3cat/ - 7 manuscript figures (PRIMARY)
- corrected_analysis/ - 3 supplementary figures
- curation_impact/ - 8 legacy figures

Suggested next steps:
- List figures: ls -lh figures/curation_impact_3cat/
- View specific MANIFEST section for figure details
- Regenerate figures: python scripts/generate_3category_figures.py

What would you like to explore?
```

## Integration with Other Commands

**Workflow patterns**:

**Session start**:
```bash
/read-manifest              # Smart context loading
# Work on project
/update-manifest            # Capture progress
```

**First time in project**:
```bash
/read-manifest              # May prompt to generate MANIFESTs
/generate-manifest          # If needed
/read-manifest              # Reload with new context
```

**Focused work session**:
```bash
/read-manifest              # Select main document
# Edit document, run analyses
/update-manifest            # Update relevant MANIFESTs
```

## Best Practices

1. **Use at session start**: Replace manual file exploration
2. **Respect user choice**: If they select "something else", don't force main document context
3. **Load only relevant MANIFESTs**: Don't load all subdirectories unless needed
4. **Provide clear summaries**: User should understand what context was loaded
5. **Suggest next steps**: Help user transition from context loading to work

## Error Handling

**No MANIFEST.md**:
- Suggest `/generate-manifest`
- Offer to create basic structure

**Malformed MANIFEST**:
- Read what's available
- Note sections that are missing
- Suggest regenerating with `/generate-manifest --update`

**Missing dependencies**:
- Note which subdirectory MANIFESTs are missing
- Offer to generate them
- Continue with available context

**No main documents identified**:
- Fall back to directory exploration
- Suggest adding Priority field to MANIFEST

---

**Remember**: The goal is to provide 80% of needed context in ~2,500-3,500 tokens instead of 8,000-15,000 tokens. Focus on loading what the user actually needs for their work.
