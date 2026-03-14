# File Naming Conventions

Detailed naming rules and patterns for project files.

## General Rules

1. **Use lowercase** with hyphens or underscores
   - Good: `data-analysis.py` or `data_analysis.py`
   - Bad: `DataAnalysis.py` or `data analysis.py`

2. **Be descriptive but concise**
   - Good: `process-telomere-data.py`
   - Bad: `script.py` or `process_all_the_telomere_sequencing_data_from_experiments.py`

3. **Use consistent separators**
   - Choose either hyphens or underscores and stick with it
   - Convention: hyphens for file names, underscores for Python modules

4. **Include version/date for important outputs**
   - Good: `report-2026-01-23.pdf` or `model-v2.pkl`
   - Bad: `report-final-final-v3.pdf`

## Numbered Sequences

For sequential files (notebooks, scripts), use zero-padded numbers:

```
notebooks/
├── 01-data-exploration.ipynb
├── 02-quality-control.ipynb
├── 03-statistical-analysis.ipynb
└── 04-visualization.ipynb
```

## Data Files

Include metadata in filename when possible:

```
data/raw/
├── sample-A_hifi_reads_2026-01-15.fastq.gz
├── sample-B_hifi_reads_2026-01-15.fastq.gz
└── reference_genome_v3.fasta
```

## Deprecated File Naming

Use descriptive names that indicate origin:

Good:
- `data-processing/telomeres_versions` - Shows it's from telomeres
- `data-processing/phylo_pre_feb20` - Shows origin and date
- `notebooks_20260226` - Shows category and date

Avoid:
- `old_stuff` - Too vague
- `backup1`, `backup2` - Not descriptive
- `deprecated` - Too generic (what is deprecated?)

## Session Notes Storage

**Standardize on `session-saves/`** (not `sessions-history/`, `Archive/`, or other variants)

Benefits:
- Consistent with standard naming pattern (noun + plural)
- Matches `archived/` pattern
- Works across all projects
- Prevents confusion when writing automation scripts

When reorganizing:
```bash
mv sessions-history/ session-saves/
mv Archive/ session-saves/  # if used for session notes
```

**Project folder template (with session notes):**
```
project-name/
├── TO-DOS.md                # Project-specific tasks
├── session-saves/           # Working session notes (tagged with #dump)
├── archived/                # Processed/consolidated notes
│   ├── daily/              # Daily consolidations
│   └── monthly/            # Monthly summaries
├── Planning/               # Planning documents
├── Development/            # Development notes
└── [other content folders]
```

**Integration with Obsidian:**
- Session notes should have `dump` tag in frontmatter for easy filtering
- See the **obsidian** skill for complete details on the dump tag requirement and frontmatter schema
- Archiving workflow: move from `session-saves/` to `archived/daily/` or `archived/monthly/`
