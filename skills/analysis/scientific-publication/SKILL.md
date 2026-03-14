---
name: scientific-publication
description: Best practices for iterative refinement of publication-quality scientific figures. Covers systematic improvement workflows, layout optimization, and ensuring all figure elements are publication-ready.
version: 1.0.0
context: fork
allowed-tools: Read, Grep, Glob, Bash
---

# Scientific Publication Figure Refinement

Expert guidance for systematically improving scientific figures through iterative refinement based on user feedback and publication requirements.

> **Supporting files in this directory:**
> - [publication-standards.md](publication-standards.md) - DPI, file formats, size specs, color accessibility
> - [multi-study-results.md](multi-study-results.md) - Writing integrated results from multi-study analyses and practical recommendations from complex trade-offs
> - [methodological-transparency.md](methodological-transparency.md) - Dual approach pattern for figures vs statistics, outlier handling
> - [overleaf-packages.md](overleaf-packages.md) - Creating production-ready Overleaf packages with templates and checklists

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
1. Reduce point size (60 -> 25)
2. Thin line widths (2.5 -> 1.5)
3. Increase transparency (alpha=0.8 -> 0.5)
4. Reduce font sizes (10 -> 8)
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

4. **V3 refinement**: Reduce point sizes (60->25), thin lines (2.5->1.5)
   - Less clutter

5. **V4 refinement**: Test vertical vs horizontal layout
   - Horizontal clearer for this case

6. **V5 refinement**: Fix p-value positioning (105%->92% of y_max)
   - All elements now visible

7. **Final**: Smaller text in statistics box (10->8)
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

Changes from v4 -> v5:
- P-value y-position: 1.05 * y_max -> 0.92 * y_max
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
# Applied violin->boxplot fix to Figures 2, 7, 10, 11
# Applied size reductions consistently across all figures
# Used same color scheme throughout
```

## Summary

**Systematic refinement workflow**:
1. Identify issue -> 2. Fix visualization -> 3. Improve clarity -> 4. Test layouts -> 5. Optimize positioning

**Key principles**:
- Iterate based on user feedback
- Test alternatives (show options)
- Document changes
- Apply lessons across figure set
- Meet publication standards

**Common adjustments**:
- Point sizes: 60 -> 25
- Line widths: 2.5 -> 1.5
- Font sizes: 10 -> 8
- Annotation positions: 105% -> 92% of max
- Always set explicit axis limits

**For additional guidance**, see the supporting files:
- Publication standards (DPI, formats, sizes): [publication-standards.md](publication-standards.md)
- Multi-study result writing: [multi-study-results.md](multi-study-results.md)
- Methodological transparency: [methodological-transparency.md](methodological-transparency.md)
- Overleaf package creation: [overleaf-packages.md](overleaf-packages.md)
