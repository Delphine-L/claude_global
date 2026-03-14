# Organizing Analysis Text for Token Efficiency

Patterns for separating computation from interpretation in scientific projects.

## Use Case
Scientific projects with:
- Large Jupyter notebooks containing analysis + interpretation
- Multiple figures requiring detailed analysis text
- Need to reference specific analyses without loading entire notebook

## The Problem
- Notebook: 4.2 MB with code + analysis text -> ~1,050,000 tokens
- Can't efficiently load just the analysis for one figure
- Difficult to maintain and update analysis text in notebook cells
- Hard to reuse analysis text in manuscript preparation

## The Solution: analysis_files/ Directory

Separate computation (notebooks) from interpretation (markdown files):

**Directory structure**:
```
project/
├── analysis_files/
│   ├── MANIFEST.md           # Guide to the analysis files
│   ├── Method.md             # Methods section
│   └── figures/
│       ├── 01_figure1.md     # Analysis for figure 1
│       ├── 02_figure2.md     # Analysis for figure 2
│       └── ...
├── notebooks/
│   └── Analysis.ipynb        # Code for computation & figures
├── figures/
│   └── output/
│       ├── 01_figure1.png
│       └── 02_figure2.png
└── data/
```

## What Goes in Each File

**analysis_files/figures/NN_name.md**:
- Figure description (figure legend format)
- Statistical methods used
- Analysis framework and interpretation
- Mechanistic explanations
- Context from other results
- Biological/technical considerations
- Publication-ready prose

**analysis_files/Method.md**:
- Complete methods section
- Dataset description
- Statistical approaches
- Data sources
- Limitations

**notebooks/*.ipynb**:
- Data loading and processing
- Statistical computations
- Figure generation code
- Minimal text (link to analysis files instead)

## Writing Style Guidelines

Base style on existing notebook/paper:
1. Read current notebook for analysis patterns
2. Read paper draft (if exists) for writing style
3. Match level of detail and technical depth
4. Include same types of explanations (statistical, mechanistic, biological)

**Common elements in scientific analysis files**:
- Clear figure descriptions with n values
- Statistical test details (test name, p-values, why chosen)
- Interpretation framework (what comparison shows)
- Mechanistic explanations (why differences occur)
- Context (how relates to other results)
- Practical implications
- Limitations and caveats

## Token Efficiency

**Example savings**:
- Full notebook: 1,135,000 tokens
- All analysis files: 22,000 tokens
- Single figure analysis: 5,000 tokens
- **Reduction: 98%**

**Practical benefit**: In 200K context window, can load all analyses + have 175K tokens for conversation.

## Integration with MANIFEST System

Update manifests to link figures to analyses:

**figures/MANIFEST.md**:
```markdown
**01_figure_name.png**
- **Description**: Brief description
- **Analysis file**: `../analysis_files/figures/01_figure_name.md`
```

**analysis_files/MANIFEST.md**:
- Document purpose and usage
- Explain token efficiency gains
- Provide usage examples
- Link to figure files

## Managing TODOs

**Critical**: Keep analysis files clean and publication-ready

**In analysis files** (DON'T):
```markdown
## Analysis
[TO BE COMPLETED - add results here]
- [ ] Run statistical test
- [ ] Fill in p-values
```

**In separate TODO note** (DO):
Create Obsidian note or similar tracking document:
```markdown
# Figure Analysis TODOs
## Figure 1
- [ ] Run Kruskal-Wallis test
- [ ] Get n for each category
- [ ] Fill in p-values in 01_figure1.md
```

## Workflow

1. **Setup**: Create directory structure
2. **Extract**: Pull analysis text from notebooks
3. **Clean**: Create publication-ready markdown files
4. **Track**: Move TODOs to separate tracking system
5. **Link**: Update MANIFESTs with cross-references
6. **Maintain**: Update analysis files, not notebooks

## When to Use This Pattern

**Good fit**:
- Multiple figures with detailed analyses
- Large notebooks (>1 MB)
- Preparing for publication
- Frequent reference to specific analyses
- Collaborative writing

**Overkill for**:
- Single figure projects
- Exploratory analysis (not publication-bound)
- Small notebooks (<500 KB)
- Code-heavy, minimal text notebooks

---

## Populating Analysis Files with Statistical Results

When framework analysis files have been created but need statistical results filled in:

**Workflow pattern**:
1. **Use TodoWrite to track progress** - Create todos for each file to fill in
2. **Work sequentially through files** - Complete one file before moving to next
3. **Read framework file** - Understand existing structure and placeholders
4. **Add Statistical Results section** with:
   - Sample sizes and descriptive statistics table
   - Statistical test results (with exact values)
   - Achievement thresholds or accuracy metrics (if applicable)
5. **Add Interpretation section** with:
   - Effect type analysis (isolating different experimental factors)
   - Mechanistic explanations
   - Practical implications
   - Context from other metrics
   - Limitations
   - Conclusion
6. **Mark todo completed immediately** - Don't batch completions

**Example structure for each analysis file**:
```markdown
## Statistical Results

### Sample Sizes and Descriptive Statistics
| Category | n | Median | Mean +/- SEM | Q1 - Q3 |
|----------|---|--------|------------|---------|
[data table]

### Statistical Tests
**Kruskal-Wallis test** (three-group comparison):
- H statistic = X.XX
- p-value = X.XXX
- **Result**: [HIGHLY significant/Significant/NO significant] differences

**Post-hoc pairwise tests**:
- Category A vs B: p = X.XXX (interpretation)
- Category A vs C: p = X.XXX (interpretation)
- Category B vs C: p = X.XXX (interpretation)

## Interpretation

### [Primary Finding Title]
[Statistical interpretation paragraph]

### Implications by Effect Type
**1. Factor 1 Effect**: [Analysis isolating first factor]
**2. Factor 2 Effect**: [Analysis isolating second factor]
**3. Combined Effect**: [Overall pattern]

### [Mechanistic Explanation Section]
[Why differences occur]

### [Context from Other Metrics]
[How this relates to other findings]

### Limitations
[Study-specific caveats]

## Conclusion
[Summary paragraph with key takeaways]
```

**Key practices**:
- **Maintain consistent formatting** across all analysis files
- **Include exact statistical values** (H statistic, p-values, sample sizes)
- **Provide mechanistic explanations** beyond just reporting significance
- **Cross-reference other findings** to build coherent narrative
- **Document data issues clearly** (e.g., implausible values, mismatched columns)
- **Use significance markers consistently**: *** p<0.001, ** p<0.01, * p<0.05, ns
