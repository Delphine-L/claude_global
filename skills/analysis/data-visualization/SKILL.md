---
name: data-visualization
description: Best practices for creating clear, accurate scientific visualizations with matplotlib, seaborn, and other Python plotting libraries. Covers common pitfalls, optimization techniques, publication-quality figure generation, and Claude API image size constraints.
version: 1.2.0
context: fork
allowed-tools: Read, Grep, Glob, Bash
---

# Data Visualization Best Practices

Expert guidance for creating publication-quality scientific visualizations, avoiding common pitfalls, and optimizing figure clarity.

## When to Use This Skill

- Creating figures for scientific publications
- Debugging misleading or distorted visualizations
- Optimizing figure layouts and element sizes
- Choosing appropriate plot types for data characteristics
- Ensuring statistical annotations fit properly
- Generating images for sharing with Claude or other AI tools

## Supporting Files

This skill is organized into focused reference files. Load them as needed:

- **[pitfalls-and-troubleshooting.md](pitfalls-and-troubleshooting.md)** - Log-scale distortion, coordinate transform bugs, outlier handling philosophy, axis range optimization, float year labels
- **[chart-recipes.md](chart-recipes.md)** - Code recipes for temporal trends, boxplots, scatter plots, category proportions, stacked area charts, sample size legends, the dual-approach for outlier handling in publication figures
- **[color-palettes.md](color-palettes.md)** - Okabe-Ito palette, Paul Tol palette, sequential/diverging schemes, colorblind-safe implementation in matplotlib/seaborn
- **[claude-image-constraints.md](claude-image-constraints.md)** - Claude API 8000px limit, safe figure size presets, resize helpers, Jupyter notebook oversized image fixes
- **[figure-descriptions.md](figure-descriptions.md)** - Templates for writing publication-quality figure descriptions with proper statistical reporting
- **[itol-reference.md](itol-reference.md)** - iTOL dataset formats (DATASET_STYLE, DATASET_BINARY, DATASET_COLORSTRIP), species name synchronization, troubleshooting
- **[journal-requirements.md](journal-requirements.md)** - Journal-specific figure specs (Nature, Science, Cell, PLOS, ACS, IEEE, Elsevier, BMC): dimensions, DPI, formats, panel labeling, file naming

## Assets (importable in notebooks/scripts)

- **`assets/publication.mplstyle`** - General publication style: `plt.style.use('path/to/publication.mplstyle')`
- **`assets/nature.mplstyle`** - Nature journal style (89mm single column, 7pt fonts, 600 DPI)
- **`assets/presentation.mplstyle`** - Larger fonts/lines for posters and slides
- **`assets/color_palettes.py`** - Importable palette definitions (Okabe-Ito, Wong, Paul Tol), `apply_palette()` helper, DNA base colors

## Scripts (helper utilities)

- **`scripts/figure_export.py`** - `save_publication_figure()`, `save_for_journal()`, `check_figure_size()` - export in multiple formats with journal-specific DPI/format settings
- **`scripts/style_presets.py`** - `apply_publication_style()`, `configure_for_journal()`, `set_color_palette()` - one-command journal configuration

## Core Principles

### 1. Always Check Log-Scale Plots

KDE-based plots (violin, ridge) on log axes produce distorted shapes. Use boxplots or log-transform data first, then plot on linear axes. See [pitfalls-and-troubleshooting.md](pitfalls-and-troubleshooting.md) for details.

### 2. Show All Data First, Filter Later

Default to showing ALL data points in initial visualizations (`showfliers=True`). Outliers may be biologically meaningful. Only filter after review with domain expert, and always document exclusions.

### 3. Use Colorblind-Safe Palettes

Use Okabe-Ito palette (recommended by Nature) for categorical data. Combine color with marker shapes for redundancy. Never use red-green combinations. See [color-palettes.md](color-palettes.md) for hex codes and implementation.

### 4. Respect Claude's Image Size Limit

Images shared with Claude must not exceed **8000 pixels** in either dimension. Use safe figure size presets and the `save_figure()` helper. See [claude-image-constraints.md](claude-image-constraints.md).

### 5. Position Annotations Carefully

Use pure data coordinates or `ax.transAxes` (0-1 range) for text positioning. Never mix coordinate systems (e.g., `ax.get_xaxis_transform()` with data-scale y-values). See [pitfalls-and-troubleshooting.md](pitfalls-and-troubleshooting.md).

## Chart Selection Quick Guide

| Data Type | Recommended Chart | When to Use |
|-----------|------------------|-------------|
| Distribution comparison | Boxplot | Large datasets, log scales, multiple groups |
| Distribution shape | Histogram | Always works on log scales, shows true frequency |
| Temporal trends (few points) | Scatter + regression | < 50 points per timepoint, continuous time |
| Temporal trends (many points) | Boxplots by year | Overlapping points, discrete timepoints |
| Category proportions over time | Stacked area + stacked bar (dual panel) | Showing both relative and absolute trends |
| Categorical comparison | Bar chart, violin (linear scale only) | Group means or distributions |
| Phylogenetic annotation | iTOL datasets | Tree visualization with metadata |

## Publication Figure Checklist

### Before Creating

- [ ] Choose colorblind-safe palette (Okabe-Ito recommended)
- [ ] Plan figure dimensions within Claude's 8000px limit
- [ ] Decide on panel layout (side-by-side vs stacked)

### During Creation

- [ ] Include sample sizes in legends: `Category (n=123)`
- [ ] Use integer year labels: `ax.xaxis.set_major_locator(plt.MaxNLocator(integer=True))`
- [ ] Set explicit axis limits when adding annotations
- [ ] Reduce element sizes for dense data (s=25, alpha=0.5)
- [ ] Use `bbox_inches='tight'` when saving

### After Creation

- [ ] Verify image dimensions (max 7999x7999 for Claude)
- [ ] Check annotations are within plot bounds
- [ ] Test colorblind accessibility
- [ ] Save at 300 DPI minimum for publication

### For Temporal Analyses

- [ ] Create both all-data and cleaned versions
- [ ] Calculate statistics on FULL dataset (not cleaned)
- [ ] Document outlier removal method and retention rate
- [ ] Use clear file naming: `figure.png` vs `figure_clean.png`

## Quick Reference: Safe Figure Sizes (300 DPI)

```python
FIG_SIZES = {
    'single_column': (3.5, 4),      # 1050x1200 px
    'double_column': (7, 5),        # 2100x1500 px
    'full_page': (7, 9),            # 2100x2700 px
    'poster': (20, 15),             # 6000x4500 px
    'max_claude': (26, 26),         # 7800x7800 px
}
```

## Quick Reference: Okabe-Ito Colors (3 Categories)

```python
colors = {
    'Category_A': '#0072B2',    # Blue
    'Category_B': '#E69F00',    # Orange
    'Category_C': '#CC79A7'     # Reddish Purple
}
```

## Best Practices Summary

1. **Always check log-scale plots** - Verify KDE-based plots against histograms
2. **Test element sizes** - Regenerate with different sizes for optimal clarity
3. **Explicit axis limits** - Don't rely on auto-limits when annotations are added
4. **Consistent styling** - Use seaborn context and style for publication consistency
5. **High DPI** - Save at 300 DPI minimum (`dpi=300, bbox_inches='tight'`)
6. **Optimize axis ranges** - Zoom to data range when distributions are compressed
7. **Check image dimensions** - Verify size before sharing with Claude (max 7999x7999)
8. **Set size constraints** - Use safe figure sizes when generating images programmatically
9. **Temporal trends with outliers** - Create both cleaned (publication) and full (verification) versions
10. **Include sample sizes** - Always show n= in legends for comparative figures

## References

- Matplotlib documentation: https://matplotlib.org/
- Seaborn visualization: https://seaborn.pydata.org/
- iTOL documentation: https://itol.embl.de/help.cgi
- Okabe-Ito palette: https://jfly.uni-koeln.de/color/
- ColorBrewer: https://colorbrewer2.org
