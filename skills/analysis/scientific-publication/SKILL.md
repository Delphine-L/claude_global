---
name: scientific-publication
description: Best practices for iterative refinement of publication-quality scientific figures. Covers systematic improvement workflows, layout optimization, and ensuring all figure elements are publication-ready.
version: 1.0.0
---

# Scientific Publication Figure Refinement

Expert guidance for systematically improving scientific figures through iterative refinement based on user feedback and publication requirements.

## When to Use This Skill

- Improving figures based on reviewer or collaborator feedback
- Optimizing figure clarity and readability
- Ensuring all figure elements fit within bounds
- Deciding between layout alternatives (horizontal vs vertical panels)
- Preparing figures for high-impact publications

## Iterative Figure Refinement Workflow

### Standard Refinement Sequence

When improving a publication figure, follow this systematic approach:

**1. Identify the Core Issue**
```
Examples:
- "Violin plots look distorted on log scale"
- "P-values are cut off at the top"
- "Too much visual clutter, hard to see the data"
- "Text overlaps with data points"
```

**2. Fix the Visualization Type/Method**
```python
# Example: Replace inappropriate plot type
# Before: Violin plot on log scale (distorted)
ax.violinplot(data)
ax.set_yscale('log')

# After: Boxplot on log scale (accurate)
ax.boxplot(data)
ax.set_yscale('log')
```

**3. Improve Visual Clarity**
Systematically adjust element sizes:

```python
# Point sizes: Reduce for dense data
# Start: s=60 (exploratory)
# End: s=25 (publication)
ax.scatter(..., s=25, alpha=0.5)

# Line widths: Thinner reduces clutter
# Start: linewidth=2.5
# End: linewidth=1.5
ax.plot(..., linewidth=1.5)

# Text sizes: Prevent overlap
# Start: fontsize=10-12
# End: fontsize=8-9
ax.text(..., fontsize=8)

# Error bar caps: Keep readable
ax.errorbar(..., capsize=5)
```

**4. Test Layout Alternatives**
```python
# Option A: Side-by-side panels
fig, axes = plt.subplots(1, 2, figsize=(16, 7))
# Pros: Direct left-right comparison
# Cons: Smaller individual panels

# Option B: Stacked vertically
fig, axes = plt.subplots(2, 1, figsize=(10, 14))
# Pros: Larger individual panels, easier to read details
# Cons: Harder to compare across panels

# Decision: Let user feedback guide choice
# Generate both, ask which is clearer
```

**5. Optimize Element Positioning**
Ensure all annotations fit within plot bounds:

```python
# Calculate safe positioning
y_max = max([d.max() for d in data_list])
y_min = min([d.min() for d in data_list])

# Position annotations WITHIN bounds
y_pos = y_max * 0.92  # 92%, not 105% (which goes outside)

# Set explicit limits with headroom
ax.set_ylim(y_min * 0.95 if y_min > 0 else y_min - 5,
            y_max * 1.05)
```

### Checklist for Publication Figures

Use this checklist before finalizing figures:

- [ ] **Plot type appropriate** for data distribution (no violin on log scale)
- [ ] **All text readable** at publication size (8-10 pt minimum)
- [ ] **Statistical annotations visible** and within plot bounds
- [ ] **Legend clear** and doesn't obscure data
- [ ] **Axis labels** descriptive with units
- [ ] **Color scheme** colorblind-friendly
- [ ] **Line weights balanced** (not too thick or thin)
- [ ] **Point sizes optimized** (visible but not overlapping)
- [ ] **DPI adequate** for publication (300 minimum)
- [ ] **Layout tested** (try both horizontal and vertical if applicable)
- [ ] **File format** publication-ready (PNG, PDF, or SVG)

## Common Refinement Patterns

### Pattern 1: Decluttering Dense Plots

**Problem**: Too many visual elements competing for attention

**Solution sequence**:
1. Reduce point size (60 → 25)
2. Thin line widths (2.5 → 1.5)
3. Increase transparency (alpha=0.8 → 0.5)
4. Reduce font sizes (10 → 8)
5. Remove grid or make it lighter (alpha=0.3)

**Before/After test**: Generate both versions, compare

### Pattern 2: Fixing Overflow Issues

**Problem**: Annotations, legends, or labels cut off

**Solutions**:
```python
# 1. Adjust annotation positions
y_pos = y_max * 0.92  # Within bounds

# 2. Use bbox_inches='tight' when saving
plt.savefig('figure.png', dpi=300, bbox_inches='tight')

# 3. Explicitly set limits
ax.set_ylim(min_val * 0.95, max_val * 1.05)

# 4. Move legend outside plot area
ax.legend(bbox_to_anchor=(1.05, 1), loc='upper left')

# 5. Reduce text size
ax.text(..., fontsize=8)  # Down from 10
```

### Pattern 3: Multi-Panel Layout Optimization

**Try both orientations**:

```python
# Version 1: Horizontal (side-by-side)
fig, axes = plt.subplots(1, 2, figsize=(16, 7))
plt.savefig('fig_horizontal.png', dpi=300, bbox_inches='tight')

# Version 2: Vertical (stacked)
fig, axes = plt.subplots(2, 1, figsize=(10, 14))
plt.savefig('fig_vertical.png', dpi=300, bbox_inches='tight')

# Present both to user, ask which is clearer
```

**Decision criteria**:
- **Horizontal**: Better for direct comparison between panels
- **Vertical**: Better when each panel needs more space
- **User context**: Journal column width, presentation slides, etc.

### Pattern 4: Iterative Statistical Annotation

**Common issue**: P-values positioned outside plot or overlapping with data

**Solution**:
```python
# Calculate data range first
all_data = [data_dual, data_prialt]  # All datasets in plot
y_max = max([d.max() for d in all_data if len(d) > 0])

# Position relative to actual data, not theoretical maximum
for i, (x_pos, comparison) in enumerate(comparisons):
    stat, pval = stats.mannwhitneyu(...)

    # Safe positioning
    y_annotation = y_max * 0.92  # Below the top

    # Format text
    if pval < 0.001:
        text = 'p < 0.001***'
    elif pval < 0.01:
        text = 'p < 0.01**'
    elif pval < 0.05:
        text = 'p < 0.05*'
    else:
        text = f'p = {pval:.3f} ns'

    ax.text(x_pos, y_annotation, text, ha='center', fontsize=9)

# Set explicit limits to ensure annotations fit
ax.set_ylim(0, y_max * 1.05)
```

## Refinement Workflow Example

**Real case: VGP Figure 5 improvement sequence**

1. **Initial version**: 4 categories, violin plots on log scale
   - Issue: Violin distortion, too complex

2. **V1 refinement**: Remove violin plots, keep boxplots
   - Better, but still issues

3. **V2 refinement**: Simplify to 3 categories
   - Clearer interpretation

4. **V3 refinement**: Reduce point sizes (60→25), thin lines (2.5→1.5)
   - Less clutter

5. **V4 refinement**: Test vertical vs horizontal layout
   - Horizontal clearer for this case

6. **V5 refinement**: Fix p-value positioning (105%→92% of y_max)
   - All elements now visible

7. **Final**: Smaller text in statistics box (10→8)
   - Publication ready

**Total iterations**: 7 versions over refinement process
**Result**: Clear, accurate, publication-quality figure

## Best Practices

### 1. Version Your Refinements

Keep working versions during major changes:
```bash
scripts/
  plot_figure.py          # Original
  plot_figure_v2.py       # After major change (layout)
  plot_figure_final.py    # Publication version
```

### 2. Generate Alternatives in Parallel

When testing layout options:
```python
# Save both versions
layouts = [
    ((1, 2), (16, 7), 'horizontal'),
    ((2, 1), (10, 14), 'vertical')
]

for (nrows, ncols), figsize, name in layouts:
    fig, axes = plt.subplots(nrows, ncols, figsize=figsize)
    # ... plot data ...
    plt.savefig(f'figure_{name}.png', dpi=300, bbox_inches='tight')
```

### 3. Document Each Refinement

```python
"""
Figure 5 - Terminal Telomere Presence

Version history:
- v1: Initial 4-category version with violin plots
- v2: Removed violin plots (distortion on log scale)
- v3: Simplified to 3 categories (terminal only)
- v4: Reduced point/line sizes for clarity
- v5: Fixed p-value positioning
- final: Publication ready

Changes from v4 → v5:
- P-value y-position: 1.05 * y_max → 0.92 * y_max
- Added explicit y-axis limits: (y_min*0.95, y_max*1.05)
- Ensures all annotations visible within plot bounds
"""
```

### 4. Get Feedback at Key Milestones

Don't over-iterate without input:
- After fixing major issues (wrong plot type): **Show user**
- After layout changes (horizontal vs vertical): **Show user**
- After final polish: **Show user**

### 5. Maintain Consistency Across Figure Set

If refining one figure, check if same improvements apply to others:
```python
# Applied violin→boxplot fix to Figures 2, 7, 10, 11
# Applied size reductions consistently across all figures
# Used same color scheme throughout
```

## Publication Standards

### DPI Requirements
- **Screen/web**: 150 DPI
- **Print (standard)**: 300 DPI
- **High-quality print**: 600 DPI

### File Formats
- **Raster**: PNG at 300 DPI (most journals accept)
- **Vector**: PDF or SVG (preferred for line plots, smaller file size, infinite zoom)
- **Avoid**: JPG (lossy compression, poor for scientific data)

### Size Specifications
Check journal requirements:
- **Single column**: Usually 3.5 inches (89 mm) wide
- **Double column**: Usually 7 inches (178 mm) wide
- **Height**: Typically max 9-10 inches

Plan figsize accordingly:
```python
# Single column figure
fig, ax = plt.subplots(figsize=(3.5, 4))

# Double column figure
fig, axes = plt.subplots(1, 2, figsize=(7, 3.5))
```

### Color Accessibility Requirements

**Many journals now require** accessibility statements for figures, including:
- Confirmation that color schemes are colorblind-safe
- Use of validated palettes (Okabe-Ito, Paul Tol)
- Alternative distinguishing features (patterns, shapes, labels)

**Nature journals specifically recommend**:
- Okabe-Ito palette for categorical data
- Avoiding red-green combinations
- Testing figures with colorblindness simulators

**In Methods section**, document your color choices:
> "All figures use the Okabe-Ito colorblind-safe palette (Okabe & Ito, 2008) to ensure accessibility for readers with color vision deficiencies."

**Reference**: Okabe, M. and Ito, K. (2008) Color Universal Design (CUD): How to make figures and presentations that are friendly to colorblind people. https://jfly.uni-koeln.de/color/

## Writing Integrated Results from Multi-Study Analyses

**Challenge**: When you have multiple parallel analyses (e.g., same metrics across 5 different populations/clades/conditions), how to present findings coherently without overwhelming readers.

**Solution**: Organize by pattern type first, then by study

### Structure Pattern

**1. Universal Patterns Section**
- Present findings consistent across ALL studies first
- This establishes the "baseline truth" readers can rely on
- Use strong language: "consistently," "across all," "universal"
- Provide statistical evidence from multiple studies

**2. Study-Specific Patterns Section**
- Present deviations and unique findings by study
- Explicitly contrast with universal patterns
- Explain why this study differs (biological/technical context)

**3. Cross-Study Comparisons Section**
- Tables comparing effect sizes across studies
- Discussion of what drives variation
- Statistical power considerations

**Example Structure** (from clade-specific genome analysis):
```markdown
## Universal Patterns Across All Vertebrates

### Gap Density: Architecture Dominates Curation
- Finding: [Universal pattern]
- Evidence: [Stats from all 5 clades]
- Interpretation: [Why this is universal]

### Telomere Detection: Technology-Limited
- [Similar structure]

## Clade-Specific Patterns

### Mammals: Dual Curation Provides Benefits
- Finding: [Unique to this clade]
- Contrast: [How this differs from universal]
- Interpretation: [Biological context]

### Birds: No N50 Benefit from Dual Curation
- [Unique pattern and explanation]

## Cross-Clade Comparisons
- [Table of effect sizes]
- [Discussion of variation]
```

### Benefits of This Structure

1. **Readers get reliable findings first**: Universal patterns are established before introducing complexity
2. **Reduces cognitive load**: Don't jump between studies repeatedly
3. **Highlights what's generalizable**: Universal section shows what works everywhere
4. **Explains variation**: Study-specific section explains why some results differ
5. **Facilitates recommendations**: Can give universal advice plus context-specific guidance

### Writing Tips

**For Universal Patterns**:
- Lead with the finding, then provide evidence from multiple studies
- Use consistent statistical reporting across all supporting evidence
- Emphasize the consistency: "across all," "in every," "universal"

**For Study-Specific Patterns**:
- Explicitly state how this differs from universal patterns
- Provide biological/technical context for why this study is unique
- Don't just report statistics - explain the mechanism

**For Statistical Power**:
- Be explicit about which studies have sufficient power
- Note limitations in smaller studies
- Don't over-interpret null results from underpowered studies

### Common Pitfalls to Avoid

❌ **Don't**: Report each study sequentially (Study 1 all results, Study 2 all results...)
✅ **Do**: Report by finding type (Finding A across all studies, Finding B across all studies...)

❌ **Don't**: Hide that some patterns aren't universal
✅ **Do**: Explicitly highlight when a pattern is study-specific and explain why

❌ **Don't**: Give equal weight to all findings
✅ **Do**: Emphasize universal patterns; note study-specific as "interesting variations"

### Application Beyond Clade Analysis

This pattern works for any multi-study synthesis:
- Clinical trials across different populations
- Experimental treatments across multiple cell lines
- Algorithm performance across different datasets
- Policy interventions across different regions

**Key principle**: Organize by what readers need to know (universal vs specific) rather than by how you conducted the studies (study-by-study).

---

## Providing Practical Recommendations from Complex Trade-offs

**Challenge**: When different methods excel at different outcomes, how to give clear guidance?

**Pattern**: "Depends on priority" recommendations with decision tree

**Structure**:
```markdown
### For [Population/Context]

**Recommended**: [Method A]
- [Metric 1]: [Performance with stats]
- [Metric 2]: [Performance with stats]
- Use when: [Priority/constraint]

**Alternative**: [Method B]
- [Metric 1]: [Performance with stats]
- [Metric 2]: [Performance with stats]
- Use when: [Different priority/constraint]

**Note**: [Important caveat or key difference from other contexts]
```

**Example** (from avian genome assemblies):
```markdown
### For Avian Genomes
**Depends on priority**:

**For gap density minimization**: Phased assembly (dual or single curation)
- Dramatic 75-100× reduction in gaps vs Pri/alt
- Strong significance (p=1.87×10⁻¹⁰)

**For chromosome assignment**: Pri/alt + Single curation
- Best assignment (98.93% median)
- Significantly better than phased approaches (p<0.001)

**Note**: Dual curation does NOT improve scaffold N50 in birds (p=0.378),
unlike mammals. Initial assemblies are already near-optimal due to
favorable genome characteristics.
```

**Benefits**:
- Acknowledges trade-offs honestly
- Provides clear decision criteria
- Gives actionable guidance despite complexity
- Explains when different approaches are optimal

---

## Summary

**Systematic refinement workflow**:
1. Identify issue → 2. Fix visualization → 3. Improve clarity → 4. Test layouts → 5. Optimize positioning

**Key principles**:
- Iterate based on user feedback
- Test alternatives (show options)
- Document changes
- Apply lessons across figure set
- Meet publication standards

**Common adjustments**:
- Point sizes: 60 → 25
- Line widths: 2.5 → 1.5
- Font sizes: 10 → 8
- Annotation positions: 105% → 92% of max
- Always set explicit axis limits
