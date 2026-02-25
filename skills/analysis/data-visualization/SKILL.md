---
name: data-visualization
description: Best practices for creating clear, accurate scientific visualizations with matplotlib, seaborn, and other Python plotting libraries. Covers common pitfalls, optimization techniques, publication-quality figure generation, and Claude API image size constraints.
version: 1.1.0
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

## Common Pitfalls with Log-Scale Plots

### Violin Plots on Log Scales

**Problem**: Violin plots use Kernel Density Estimation (KDE) in linear space, then the axis is transformed to log scale. This causes severe visual distortion where the violin shape doesn't accurately represent the actual data distribution.

**Symptoms**:
- Smooth, blob-like violin shapes on log axes
- Visual representation suggests even distribution but histogram shows heavy clustering
- Particularly problematic with right-skewed data heavily concentrated in one region

**Example of the problem**:
```python
# ❌ BAD: Violin plot on log scale
import matplotlib.pyplot as plt
import numpy as np

data = np.random.exponential(10, 1000)  # Right-skewed data
fig, ax = plt.subplots()
ax.violinplot([data])
ax.set_yscale('log')  # Distorts the violin shape!
# Result: Smooth violin that doesn't show the true concentration at low values
```

**Solution 1: Use boxplots instead**
```python
# ✅ GOOD: Boxplot on log scale
ax.boxplot([data])
ax.set_yscale('log')  # Boxplot statistics remain meaningful
```

**Why boxplots work**: Boxplot statistics (median, quartiles, outliers) are calculated as specific values, not density estimates, so they remain meaningful on log scales.

**Solution 2: Log-transform data first**
```python
# ✅ ALTERNATIVE: Log-transform data first, then use violin on linear axis
log_data = np.log10(data[data > 0])
ax.violinplot([log_data])
ax.set_ylabel('log10(Value)')
# Keep linear axis - violin now accurately represents log-space distribution
```

**Solution 3: Use histograms with log axes**
```python
# ✅ GOOD: Histogram with log y-axis shows true frequency distribution
ax.hist(data, bins=30)
ax.set_xscale('log')  # Data axis
ax.set_yscale('log')  # Frequency axis - shows concentration clearly
```

### Impact
This pitfall can lead to misleading figures in publications where the visual representation contradicts the actual data distribution. In our VGP curation analysis, this affected 4 different figures before correction.

### Outlier Handling: Show First, Decide Later

**Default stance**: Show ALL data points in initial visualizations

```python
# CORRECT - show all data
plt.boxplot(data, showfliers=True)

# AVOID initially - hides potentially important data
plt.boxplot(data, showfliers=False)
```

**Rationale**:
- Outliers may be biologically meaningful
- Filtering decisions should be informed by seeing complete data
- Easy to filter later, hard to know what you missed
- Patterns in outliers can reveal data quality issues

**Workflow**:
1. Generate figures with all data (`showfliers=True`)
2. Review with domain expert
3. Decide case-by-case if outliers should be excluded
4. Document rationale for any exclusions

**Only filter outliers when**:
- Technical artifact confirmed (e.g., processing error)
- Prevents seeing relevant patterns in bulk of data
- Documented and justified in methods
- Alternative view with all data provided in supplement

**Example documentation**:
```python
# Remove known technical outlier
"""
Excluded assembly GCA_123456 from Figure 2 analysis:
- Scaffold N50 = 500 Gb (500× larger than genome size)
- Confirmed as assembly processing error in NCBI notes
- Other metrics for this assembly are valid and included in other figures
"""
```

## Publication Figure Refinement

### Element Sizing for Clarity

When figures are cluttered or elements overlap:

```python
# Point sizes: Reduce for dense data
ax.scatter(..., s=25, alpha=0.5)  # Down from s=60

# Line widths: Thinner lines reduce visual clutter
ax.plot(..., linewidth=1.5)  # Down from 2.5

# Text sizes: Prevent overlap
ax.text(..., fontsize=8)  # Down from 10

# Error bar cap sizes
ax.errorbar(..., capsize=5)  # Standard readable size
```

### P-value and Annotation Positioning

**Problem**: Statistical annotations (p-values, significance stars) often placed outside plot bounds

**Solution**: Position relative to data range with explicit limits
```python
# Calculate data range
y_max = max([d.max() for d in data_list])
y_min = min([d.min() for d in data_list])

# Position annotations within plot
y_pos = y_max * 0.92  # 92% of max, not 105% which goes outside

ax.text(x_pos, y_pos, 'p < 0.001***', ha='center', fontsize=9)

# Set explicit limits with headroom
ax.set_ylim(y_min * 0.95 if y_min > 0 else -5, y_max * 1.05)
```

### Panel Layout Testing

Test both orientations to find clearest presentation:

```python
# Side-by-side (good for comparing distributions)
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Stacked vertically (good for larger individual panels)
fig, axes = plt.subplots(2, 1, figsize=(10, 14))
```

**Decision criteria**:
- Side-by-side: Better for direct left-right comparison
- Stacked: Better when each panel needs more space
- Let user feedback guide the choice

### Adding Sample Sizes to Legends

**Why Sample Sizes Matter**: Readers need to assess statistical power at a glance. Include sample sizes directly in legend labels for scientific figures.

**Pattern 1: Simple Legend with Sample Sizes**

```python
# Calculate sample sizes once
category_sizes = df.groupby('category').size().to_dict()

# Use in scatter plot legend
for category in categories:
    data = df[df['category'] == category]
    ax.scatter(data['x'], data['y'],
              label=f"{category} (n={category_sizes[category]})")

ax.legend(loc='best')
```

**Pattern 2: Custom Legend for Complex Plots**

When you have multiple marker types (e.g., technology + category), create custom legend:

```python
from matplotlib.lines import Line2D

# Calculate sizes
category_sizes = df.groupby('category').size().to_dict()

# Create custom legend elements
custom_lines = [
    Line2D([0], [0], color=colors['Cat1'], marker='o', linestyle='', markersize=8),
    Line2D([0], [0], color=colors['Cat2'], marker='o', linestyle='', markersize=8),
]

custom_labels = [
    f"Category 1 (n={category_sizes['Cat1']})",
    f"Category 2 (n={category_sizes['Cat2']})",
]

ax.legend(custom_lines, custom_labels, loc='best', fontsize=9)
```

**Pattern 3: Multi-Panel Figures - Show Legend Once**

For 2×3 or similar grids, show legend only in first subplot:

```python
# Calculate once, use in all panels
category_sizes = df.groupby('category').size().to_dict()

for idx, metric in enumerate(metrics):
    ax = axes[idx]

    for category in categories:
        # Only add label for first subplot
        if idx == 0:
            label_text = f"{category} (n={category_sizes[category]})"
        else:
            label_text = ''

        ax.scatter(..., label=label_text)

    if idx == 0:
        ax.legend(loc='best')
```

**Best Practices**:
- Calculate sizes once at the top (efficient, avoids repeated computation)
- Use consistent format: `Category Name (n=123)`
- For small panels, use `fontsize=7-9`
- Consider `ncol=1` for vertical layout if space allows
- Place sample sizes in legend OR as text annotations, not both

**Publication Standards**:
- **Nature/Science**: Strongly recommended for all comparative figures
- **PLOS**: Required for sample size transparency
- **Cell**: Expected in methods or figure legends
- **General guideline**: Always include when comparing groups

**Example: Temporal Analysis with Categories**

```python
# Temporal trends by category
category_sizes = df.groupby('category').size().to_dict()

fig, ax = plt.subplots(figsize=(10, 6))

for category in ['Phased+Dual', 'Phased+Single', 'Pri/alt+Single']:
    data = df[df['category'] == category]
    ax.scatter(data['year'], data['quality_metric'],
              color=colors[category],
              label=f"{category} (n={category_sizes[category]})",
              alpha=0.6, s=40)

ax.set_xlabel('Year')
ax.set_ylabel('Assembly Quality')
ax.legend(loc='best', fontsize=9)
```

### Visualizing Category Proportions Over Time

**Use Case**: Show how the relative proportions of categories have changed over time.

**Dual-Panel Approach**: Proportions + Absolute Counts

Show both relative and absolute trends using side-by-side panels.

**Left Panel**: Stacked area chart (proportions sum to 100%)
**Right Panel**: Stacked bar chart (shows actual sample sizes)

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Calculate counts and proportions by year
year_category_counts = df.groupby(['year', 'category']).size().unstack(fill_value=0)
year_category_proportions = year_category_counts.div(
    year_category_counts.sum(axis=1), axis=0
) * 100

# Dual-panel figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# Panel 1: Stacked area (proportions)
years = year_category_proportions.index
categories = ['Cat1', 'Cat2', 'Cat3']

# Calculate total sizes for legend
total_counts = df.groupby('category').size().to_dict()

bottom = np.zeros(len(years))
for category in categories:
    values = year_category_proportions[category].values
    ax1.fill_between(years, bottom, bottom + values,
                     label=f"{category} (n={total_counts[category]})",
                     color=colors[category], alpha=0.7)
    bottom += values

ax1.set_xlabel('Year', fontsize=12)
ax1.set_ylabel('Proportion (%)', fontsize=12)
ax1.set_title('Category Proportions Over Time', fontsize=14, fontweight='bold')
ax1.set_ylim(0, 100)
ax1.legend(loc='best', fontsize=10)
ax1.grid(axis='y', alpha=0.3)
ax1.xaxis.set_major_locator(plt.MaxNLocator(integer=True))

# Panel 2: Stacked bar (absolute counts)
year_category_counts[categories].plot(
    kind='bar', stacked=True, ax=ax2,
    color=[colors[c] for c in categories],
    width=0.7, edgecolor='black', linewidth=0.5
)

ax2.set_xlabel('Year', fontsize=12)
ax2.set_ylabel('Number of Samples', fontsize=12)
ax2.set_title('Absolute Counts by Category', fontsize=14, fontweight='bold')
ax2.legend(title='Category',
          labels=[f"{c} (n={total_counts[c]})" for c in categories],
          loc='upper left', fontsize=9)
ax2.grid(axis='y', alpha=0.3)
ax2.set_xticklabels([int(y) for y in years], rotation=0)

# Add totals on top of bars
for i, year in enumerate(years):
    total = year_category_counts.loc[year].sum()
    ax2.text(i, total + 2, str(int(total)),
            ha='center', va='bottom', fontsize=9, fontweight='bold')

plt.tight_layout()
plt.savefig('category_proportions.png', dpi=150, bbox_inches='tight')
```

**Why Both Panels?**

**Proportions (Area Chart)**:
- Shows relative shifts in category usage
- Easy to see if one category is growing/declining
- Sums to 100% (intuitive interpretation)

**Absolute Counts (Bar Chart)**:
- Shows actual sample sizes (statistical power)
- Reveals total data volume changes
- Helps interpret proportion changes (growing proportion of shrinking pie?)

**Together**: Complete picture of temporal trends

**Styling Tips**:
- **Colors**: Use colorblind-safe palette consistently across both panels
- **Edge colors**: Black edges on bars improve readability (`linewidth=0.5`)
- **Totals**: Add count labels above stacked bars for context
- **X-axis**: Integer years, not decimals (use `MaxNLocator(integer=True)`)
- **Legend**: Include total sample sizes: `Category (n=123)`

**When to Use**:
- Tracking category adoption over time
- Showing methodology shifts in field
- Demonstrating changing experimental approaches
- Any temporal categorical composition analysis

## Color Schemes

### Colorblind-Friendly Palettes

Standard palette for dual comparisons:
```python
COLORS = {
    'Group1': '#0173B2',  # Blue
    'Group2': '#DE8F05'   # Orange
}
```

Accessible to most common color vision deficiencies.

### Comprehensive Colorblind-Safe Color Palettes for Scientific Figures

**Problem: Poor Color Accessibility**

**Common issue**: Default color schemes often use green-blue or red-green combinations that are indistinguishable for colorblind viewers (~8% of population).

**Examples of problematic combinations**:
- Green + Blue (similar for deuteranopia/protanopia)
- Red + Green (classic colorblindness issue)
- Light blue + Dark blue (insufficient contrast)

#### Okabe-Ito Palette (Recommended by Nature)

**The gold standard** for scientific figures, developed by Masataka Okabe and Kei Ito.

**Complete 8-color palette** (hex codes):
```python
okabe_ito = {
    'orange': '#E69F00',
    'sky_blue': '#56B4E9',
    'bluish_green': '#009E73',
    'yellow': '#F0E442',
    'blue': '#0072B2',
    'vermillion': '#D55E00',
    'reddish_purple': '#CC79A7',
    'black': '#000000'
}
```

**For 3 categories** (maximum distinction):
```python
# Best combination for 3 categories
category_colors = {
    'Category_A': '#0072B2',    # Blue
    'Category_B': '#E69F00',    # Orange
    'Category_C': '#CC79A7'     # Reddish Purple
}
```

**Why this combination**:
- Blue (cool) + Orange (warm) + Purple (neutral) = maximum perceptual separation
- Works for all types of colorblindness (deuteranopia, protanopia, tritanopia)
- Blue-orange is universally distinguishable
- No green-blue or red-green confusion

**For 5+ categories**, use additional colors from the palette:
```python
five_colors = {
    'Cat_1': '#0072B2',    # Blue
    'Cat_2': '#E69F00',    # Orange
    'Cat_3': '#CC79A7',    # Reddish Purple
    'Cat_4': '#D55E00',    # Vermillion
    'Cat_5': '#F0E442'     # Yellow
}
```

#### Paul Tol's Bright Palette (Alternative)

Another scientifically validated option:
```python
paul_tol_bright = {
    'blue': '#4477AA',
    'red': '#EE6677',
    'green': '#228833',
    'yellow': '#CCBB44',
    'cyan': '#66CCEE',
    'purple': '#AA3377',
    'grey': '#BBBBBB'
}
```

#### Implementation in Matplotlib/Seaborn

**Set up colorblind-safe palette**:
```python
import matplotlib.pyplot as plt
import seaborn as sns

# Okabe-Ito colors for 3 categories
colors = ['#0072B2', '#E69F00', '#CC79A7']

# Apply to matplotlib
plt.rcParams['axes.prop_cycle'] = plt.cycler(color=colors)

# Or use directly in plots
fig, ax = plt.subplots()
for i, category in enumerate(['A', 'B', 'C']):
    ax.plot(x, y[i], color=colors[i], label=category)
```

**For categorical plots (seaborn)**:
```python
# Define palette dictionary
palette = {
    'Phased+Dual': '#0072B2',
    'Phased+Single': '#E69F00',
    'Pri/alt+Single': '#CC79A7'
}

# Use in seaborn
sns.boxplot(data=df, x='category', y='value', palette=palette)
```

#### Best Practices

1. **Avoid red-green combinations** - Most common colorblindness type
2. **Use patterns/markers too** - Combine color with shapes for redundancy
3. **Test your figures** - Use colorblindness simulators online
4. **Document your palette** - Add comment explaining choice
5. **Be consistent** - Use same colors for same categories across all figures

#### Example: Complete Figure Setup

```python
# Okabe-Ito palette for 3 categories
category_colors = {
    'Method_A': '#0072B2',      # Blue (Okabe-Ito)
    'Method_B': '#E69F00',      # Orange (Okabe-Ito)
    'Method_C': '#CC79A7'       # Reddish Purple (Okabe-Ito)
}

# Also use different markers for redundancy
markers = {
    'Method_A': 'o',  # circle
    'Method_B': 's',  # square
    'Method_C': '^'   # triangle
}

# Plot with both color and marker distinction
for method in ['Method_A', 'Method_B', 'Method_C']:
    data = df[df['method'] == method]
    plt.scatter(data['x'], data['y'],
                color=category_colors[method],
                marker=markers[method],
                label=method, s=50, alpha=0.7)

plt.legend()
plt.title('Analysis Results (Colorblind-Safe)')
```

#### When to Use Which Palette

**Okabe-Ito**:
- Scientific publications (recommended by Nature)
- 3-8 categorical variables
- Need maximum accessibility
- Standard for academic figures

**Paul Tol**:
- Alternative when you want different aesthetics
- Good for presentations
- Widely used in Europe

**Seaborn 'colorblind'**:
- Quick matplotlib/seaborn integration
- Based on similar principles
- Built-in convenience

#### Resources

- **Okabe-Ito palette**: https://jfly.uni-koeln.de/color/
- **Paul Tol's schemes**: https://personal.sron.nl/~pault/
- **Colorblind simulator**: https://www.color-blindness.com/coblis-color-blindness-simulator/
- **Venngage guide**: https://venngage.com/blog/color-blind-friendly-palette/

#### Real Example: VGP Assembly Analysis

```python
# Before: Similar blues caused confusion
old_colors = {
    'Phased+Dual': '#1976D2',    # Dark blue
    'Phased+Single': '#4FC3F7',  # Light blue - TOO SIMILAR!
    'Pri/alt+Single': '#66BB6A'  # Green - confusing with blue
}

# After: Okabe-Ito palette with maximum distinction
new_colors = {
    'Phased+Dual': '#0072B2',      # Blue
    'Phased+Single': '#E69F00',    # Orange - DISTINCT!
    'Pri/alt+Single': '#CC79A7'    # Purple - DISTINCT!
}
```

This ensures all readers can distinguish categories regardless of color vision deficiency.

## Image Size Constraints for Claude API

**CRITICAL**: When generating images to share with Claude (for review, debugging, etc.), images must not exceed **8000 pixels** in either dimension.

### Check Image Size Before Opening

Always verify image dimensions before trying to display them in Claude:

```python
from PIL import Image

# Check dimensions
img = Image.open('figure.png')
print(f"Image size: {img.width}x{img.height}")

if img.width > 8000 or img.height > 8000:
    print(f"⚠️  WARNING: Image too large for Claude API!")
    print(f"   Claude limit: 8000px max dimension")
    print(f"   Your image: {img.width}x{img.height}")
```

### Set Size Constraints When Generating Figures

**For matplotlib/seaborn figures:**

```python
import matplotlib.pyplot as plt

# Set figure size to stay under Claude's limits
# Rule of thumb: Keep figsize under (80, 80) at 100 DPI
# Or under (26, 26) at 300 DPI
fig, ax = plt.subplots(figsize=(16, 12))  # Safe: 1600x1200 at 100 DPI

# When saving, control DPI to stay under limits
# 7999px / 300 DPI = 26.6 inches max
# 7999px / 100 DPI = 79.9 inches max
plt.savefig('figure.png', dpi=300, bbox_inches='tight')  # Max ~26x26 inches

# For very large figures, use lower DPI
plt.savefig('large_figure.png', dpi=100, bbox_inches='tight')  # Max ~80x80 inches
```

**Safe figure size presets:**

```python
# Publication quality (300 DPI) - fits Claude limit
FIG_SIZES = {
    'single_column': (3.5, 4),      # 1050x1200 px
    'double_column': (7, 5),        # 2100x1500 px
    'full_page': (7, 9),            # 2100x2700 px
    'poster': (20, 15),             # 6000x4500 px - safe for Claude
    'max_claude': (26, 26),         # 7800x7800 px - maximum safe size
}

fig, ax = plt.subplots(figsize=FIG_SIZES['double_column'])
plt.savefig('figure.png', dpi=300, bbox_inches='tight')
```

### Resize Oversized Images

If you have an existing image that's too large:

```python
from PIL import Image

def resize_for_claude(image_path, max_dim=7999, output_path=None):
    """
    Resize image to fit Claude's API constraints.

    Args:
        image_path: Path to input image
        max_dim: Maximum dimension (default 7999 for safety margin)
        output_path: Output path (default: adds '_resized' to filename)
    """
    img = Image.open(image_path)

    # Check if resize needed
    if img.width <= max_dim and img.height <= max_dim:
        print(f"✓ Image OK: {img.width}x{img.height}")
        return image_path

    # Calculate new size preserving aspect ratio
    img.thumbnail((max_dim, max_dim), Image.Resampling.LANCZOS)

    # Save
    if output_path is None:
        base = image_path.rsplit('.', 1)[0]
        ext = image_path.rsplit('.', 1)[1]
        output_path = f"{base}_resized.{ext}"

    img.save(output_path)
    print(f"✓ Resized: {image_path}")
    print(f"  Original: {Image.open(image_path).size}")
    print(f"  New: {img.size}")
    print(f"  Saved: {output_path}")

    return output_path

# Usage
resize_for_claude('large_figure.png')
```

### Quick Checks

**Bash one-liner to check size:**
```bash
# Using ImageMagick
identify figure.png | grep -o '[0-9]*x[0-9]*'

# Check if oversized
python3 -c "from PIL import Image; img=Image.open('figure.png'); print(f'{img.width}x{img.height}'); exit(0 if img.width<=7999 and img.height<=7999 else 1)" && echo "OK" || echo "TOO LARGE"
```

**Add to notebook imports:**
```python
# Standard imports for Claude-compatible figures
import matplotlib.pyplot as plt
import seaborn as sns
from PIL import Image

# Set global figure size limit
plt.rcParams['figure.max_open_warning'] = 50
MAX_CLAUDE_DIM = 7999  # Claude API limit: 8000px, use 7999 for safety

def save_figure(filename, dpi=300, **kwargs):
    """Save figure with Claude size constraint check."""
    plt.savefig(filename, dpi=dpi, bbox_inches='tight', **kwargs)

    # Verify size
    img = Image.open(filename)
    if img.width > MAX_CLAUDE_DIM or img.height > MAX_CLAUDE_DIM:
        print(f"⚠️  WARNING: {filename} exceeds Claude limit!")
        print(f"   Size: {img.width}x{img.height} (max: {MAX_CLAUDE_DIM})")
        print(f"   Resizing...")
        img.thumbnail((MAX_CLAUDE_DIM, MAX_CLAUDE_DIM), Image.Resampling.LANCZOS)
        img.save(filename)
        print(f"   ✓ Resized to: {img.width}x{img.height}")
    else:
        print(f"✓ Saved {filename}: {img.width}x{img.height}")
```

### Common Scenarios

**High-DPI screenshots from Retina displays:**
- Retina screenshots are 2x pixel density
- A full-screen 4K monitor screenshot can be 7680x4320 (OK)
- A 5K monitor screenshot is 10240x5760 (TOO LARGE!)
- Solution: Resize before sharing or take partial screenshots

**Multi-panel figures:**
```python
# Instead of one huge figure with many panels
fig, axes = plt.subplots(4, 4, figsize=(40, 40))  # Could be 12000x12000 px!

# Split into smaller figures
for i in range(4):
    fig, axes = plt.subplots(2, 2, figsize=(12, 12))  # 3600x3600 px - safe!
    # Plot subset of panels
    plt.savefig(f'figure_part{i}.png', dpi=300, bbox_inches='tight')
```

### Error Recovery

If you get the error:
```
API Error: 400 ... image dimensions exceed max allowed size: 8000 pixels
```

The error is stuck in conversation history. To recover:

1. **Skip the message**: "Please ignore the oversized image in the previous message"
2. **Resize and resend**: Use `resize_for_claude()` function above
3. **Use /safe-clear**: Save context and start fresh (if command available)

## Jupyter Notebook Image Size Issues

### Oversized Images from Combined Output

**Problem**: Jupyter notebook saves figures as extremely tall images (e.g., 1541 x 42,011 pixels) that exceed the 8000 pixel limit.

**Cause**: When a cell generates both a figure AND text output (print statements, statistical results), Jupyter captures both as a single tall image. The text output is rendered as image pixels below the figure, creating a massive combined image.

**Symptoms**:
- Image dimensions like 1541 x 42,011 pixels (height >> 8000)
- Figure displays fine in notebook but won't display in Claude or other tools
- Error: "image dimensions exceed max allowed size: 8000 pixels"

**Example of the problem**:
```python
# Cell that creates oversized image
fig, axes = plt.subplots(2, 3, figsize=(12, 8))

# ... plotting code ...

plt.tight_layout()
plt.savefig('figure.png', dpi=150, bbox_inches='tight')
plt.show()

# Text output after figure (PROBLEM!)
print("Statistical Results:")
print(f"Spearman correlation: rho={rho:.3f}, p={pval:.4f}")
# Multiple print statements create tall text output
# Jupyter combines this with figure into one 42K pixel tall image
```

**Solution 1: Split into multiple figures**

Instead of creating one large multi-panel figure, split into smaller figures:

```python
# ✅ GOOD: Split 2×3 grid into two 1×3 grids
# Figure 1: First 3 panels
fig1, axes1 = plt.subplots(1, 3, figsize=(10, 3.5))
# ... plot first 3 panels ...
plt.savefig('figure_part1.png', dpi=150, bbox_inches='tight')
plt.show()

# Figure 2: Second 3 panels
fig2, axes2 = plt.subplots(1, 3, figsize=(10, 3.5))
# ... plot second 3 panels ...
plt.savefig('figure_part2.png', dpi=150, bbox_inches='tight')
plt.show()
```

**Solution 2: Separate text output into different cell**

Move print statements to a separate cell after the figure:

```python
# Cell 1: Just the figure
fig, axes = plt.subplots(2, 3, figsize=(12, 8))
# ... plotting code ...
plt.savefig('figure.png', dpi=150, bbox_inches='tight')
plt.show()

# Cell 2: Text output (separate!)
print("Statistical Results:")
print(f"Spearman correlation: rho={rho:.3f}, p={pval:.4f}")
```

**Solution 3: Suppress text output in figure cell**

```python
# Capture results without printing
results = []
for category in categories:
    rho, pval = stats.spearmanr(x, y)
    results.append({'category': category, 'rho': rho, 'pval': pval})

# Create figure (no print statements!)
fig, axes = plt.subplots(2, 3, figsize=(12, 8))
# ... plotting code ...
plt.savefig('figure.png', dpi=150, bbox_inches='tight')
plt.show()

# Display results in separate cell or as DataFrame
results_df = pd.DataFrame(results)
```

**When to split figures**:
- Multi-panel figures with many subplots (3+ rows × 2+ columns)
- Any figure where dimensions approach 8000 pixels
- When cell has significant text output after figure
- When total cell output height feels very long in notebook

**Prevention**:
- Use the `save_figure()` helper from jupyter-notebook skill (auto-checks size)
- Keep figure cells focused on visualization only
- Save statistical results to CSV files instead of printing
- Use separate markdown cells for result interpretation

### Matplotlib Text Positioning Creates Empty Space

**Problem**: Saved figure has large area of empty white space above the actual plot, making the figure much taller than necessary.

**Cause**: Using `transform=ax.get_xaxis_transform()` with data coordinate y-values positions text far outside the plot bounds. The transform uses axis-relative coordinates (0-1) for x but data coordinates for y, so large y-values create huge positioning errors.

**Symptoms**:
- Empty white space at top (or bottom) of saved figure
- Text annotations not visible or way off the plot
- `tight_layout()` and `pad_inches` adjustments don't fix it
- Problem persists even after reducing figure size

**Example of the problem**:
```python
# ❌ BAD: Mixing coordinate systems
for category in categories:
    data = df[df['category'] == category]
    ax.scatter(data['x'], data['y'])

    # Add significance marker
    y_max = data['y'].max()  # e.g., y_max = 2000000000 (2 billion)

    # PROBLEM: y_max is in data coordinates, transform expects 0-1!
    ax.text(0.5, y_max * 0.95, '***',
           transform=ax.get_xaxis_transform(),  # x in 0-1, y in data coords
           ha='center', fontsize=12)
    # This positions text at y = 1.9 billion in the mixed coordinate system!

plt.savefig('figure.png', dpi=150, bbox_inches='tight')
# Result: Massive empty space with text way above visible plot
```

**Why this happens**:
- `ax.get_xaxis_transform()` uses axis coordinates (0-1) for x, data coordinates for y
- `y_max * 0.95` for scaffold N50 might be 1.9 billion (1.9e9)
- Transform interprets this as 1.9 billion axis units above the plot
- `bbox_inches='tight'` includes this invisible text, creating empty space

**Solution 1: Position within data range (RECOMMENDED)**

Calculate position within the actual data coordinate system:

```python
# ✅ GOOD: Position within plot bounds using pure data coordinates
for category in categories:
    data = df[df['category'] == category]
    ax.scatter(data['x'], data['y'])

    # Get actual data range
    y_min, y_max = ax.get_ylim()

    # Position at 90% of the visible range
    y_pos = y_min + (y_max - y_min) * 0.90

    # Use data coordinates (no transform needed)
    ax.text(0.5, y_pos, '***',
           ha='center', va='center', fontsize=12)
```

**Solution 2: Use axis transform correctly with 0-1 coordinates**

If you want to use the transform, use 0-1 range for y:

```python
# ✅ GOOD: Both x and y in 0-1 axis coordinates
ax.text(0.5, 0.90, '***',
       transform=ax.transAxes,  # Both x and y in 0-1 range
       ha='center', va='center', fontsize=12)
```

**Solution 3: Use annotate with xycoords**

```python
# ✅ GOOD: Explicit coordinate specification
ax.annotate('***',
           xy=(x_pos, y_pos),          # Data coordinates
           xycoords='data',
           ha='center', va='center', fontsize=12)
```

**Coordinate Transform Quick Reference**:

| Transform | X coordinate | Y coordinate | Use case |
|-----------|-------------|-------------|----------|
| `None` (default) | Data | Data | Normal plotting |
| `ax.transAxes` | 0-1 (axis) | 0-1 (axis) | Position relative to axes |
| `ax.get_xaxis_transform()` | 0-1 (axis) | Data | Span markers, axis labels |
| `ax.get_yaxis_transform()` | Data | 0-1 (axis) | Y-axis annotations |

**When to use each approach**:
- **Data coordinates** (no transform): Annotations tied to specific data points
- **Axis coordinates** (`transAxes`): Labels in fixed positions (e.g., panel letters)
- **Mixed transforms**: Advanced use only, requires careful coordinate scaling

**Debugging tips**:
- If empty space appears, check for text/annotation calls with large y-values
- Use `ax.get_ylim()` to verify reasonable y-coordinate range
- Temporarily comment out text/annotation calls to identify culprit
- Verify saved figure dimensions match expected size

**Prevention**:
- Prefer pure data coordinates for most annotations
- Only use transforms when specifically needed
- Always verify coordinate ranges match transform type
- Test saved figure size after adding annotations

## Common Matplotlib Issues and Fixes

### Float Year Labels on X-Axis

**Problem**: X-axis shows decimal years (2021.0, 2021.5, 2022.0) instead of clean integers (2021, 2022, 2023).

**Cause**: Matplotlib's default tick formatter displays float values with decimals when the data type is float.

**Solution**: Use `MaxNLocator` with `integer=True`

```python
import matplotlib.pyplot as plt

# After creating plot
ax.scatter(df['year'], df['value'])

# Fix x-axis to show only integer years
ax.xaxis.set_major_locator(plt.MaxNLocator(integer=True))
```

**Why This Works**:
- `MaxNLocator(integer=True)` constrains tick locations to integers
- Works even when underlying data is float (e.g., `release_year` column as float64)
- Automatically chooses appropriate spacing (won't show every year if range is large)

**Common Use Case**: Temporal analyses where year data is stored as float but should display as integer for readability.

**Example**:
```python
# Data with float years
df['release_year'] = [2021.0, 2022.0, 2023.0, 2024.0, 2025.0]

fig, ax = plt.subplots()
ax.scatter(df['release_year'], df['metric'])

# Without fix: x-axis shows 2021.0, 2021.5, 2022.0, 2022.5, ...
# With fix: x-axis shows 2021, 2022, 2023, 2024, 2025
ax.xaxis.set_major_locator(plt.MaxNLocator(integer=True))
```

## Best Practices

1. **Always check log-scale plots**: If using KDE-based plots (violin, ridge) on log axes, verify against histogram
2. **Test element sizes**: Regenerate figures with different sizes to find optimal clarity
3. **Explicit axis limits**: Don't rely on automatic limits when annotations are added
4. **Consistent styling**: Use seaborn context and style for publication consistency
5. **High DPI**: Save at 300 DPI minimum for publication (`dpi=300, bbox_inches='tight'`)
6. **Optimize axis ranges for data distribution**: When data is concentrated in narrow range, adjust axis limits to improve visibility
7. **Check image dimensions**: Verify size before sharing with Claude (max 7999x7999 pixels)
8. **Set size constraints in scripts**: Use safe figure sizes when generating images programmatically

### Axis Range Optimization for Compressed Distributions

When data is concentrated at one end of range:

**Problem**: Cumulative distributions all at 80-100% look compressed with 0-100% Y-axis

**Solution**: Adjust axis limits to focus on data range
```python
# For chromosome assignment cumulative distribution (mostly 80-100%)
ax.set_ylim(50, 100)  # Start at 50% instead of 0%

# For legend placement with adjusted range
ax.legend(loc='upper left')  # Prevents overlap with curves at top-right
```

**When to adjust axis ranges**:
- ✅ Data concentrated in narrow range (e.g., 80-100%)
- ✅ Improves visibility of differences
- ✅ All relevant data still visible
- ✅ Makes small differences more apparent

**When NOT to adjust**:
- ❌ Would hide meaningful outliers
- ❌ Creates misleading visual impression
- ❌ Data actually spans full range
- ❌ Standard in field to show full range (0-100%)

**Best practice**: Show both views if controversial
- Main figure: Zoomed range for clarity
- Supplementary: Full range for context

## Scientific Figure Descriptions for Publications

### Structure for Multi-Panel Figures

**Opening Sentence**: Overview + sample size + stratification
```markdown
**[Analysis type] of [N] [unit]** across [timeframe/condition], stratified by
[categories]: Category1 (n=X), Category2 (n=Y), Category3 (n=Z).
```

**Panel Descriptions**: For each panel:
```markdown
**[Metric Name]** (panel location): [Pattern observed]. [Statistical test]
(ρ=[value], p=[value]) shows [interpretation]. [Biological/technical context].
```

**Closing Interpretation**: Synthesize findings
```markdown
**Interpretation:** [Overall pattern]. [Comparison across categories].
[Methodological implications]. [Connection to study goals].
```

### Example: Temporal Trends Figure

```markdown
### Figure 4. Temporal trends in assembly quality metrics for HiFi-only assemblies (2021-2025)

**Temporal analysis of six assembly quality metrics across 268 HiFi assemblies**
spanning 2021-2025, stratified by assembly and curation method: Phased+Dual
(n=101, blue), Phased+Single (n=42, orange), and Pri/alt+Single (n=125, purple).
Each panel displays individual assembly measurements (points) with linear
regression trend lines (dashed) for each category. Trend significance was
assessed using Spearman correlation (α=0.05).

**Key Findings:**

**Scaffold N50** (upper left): Pri/alt+Single assemblies show significant
improvement over time (ρ=0.32, p=2.7×10⁻⁴), increasing from ~100 Mb to ~700 Mb,
while Phased assemblies remain stable at ~100-200 Mb. This suggests technological
improvements in single-assembly methods during the HiFi era.

**Gap Density** (upper middle): All HiFi assemblies collectively show decreasing
gap density over time (ρ=-0.17, p=0.0057), indicating improved sequence continuity.

[Additional panels...]

**Interpretation:** Temporal trends are category-specific and metric-dependent.
Pri/alt+Single assemblies show quality improvements (N50, gap density) consistent
with technological advancement during 2021-2025. Phased assemblies remain stable
across most metrics, suggesting their quality is primarily methodology-determined.
```

### Quantitative Details to Include

**Always include**:
- ✅ Sample sizes (n=X) for each group
- ✅ Statistical test used (Spearman, Mann-Whitney, etc.)
- ✅ Effect sizes (ρ, r², effect magnitude)
- ✅ p-values with scientific notation (p=2.7×10⁻⁴)
- ✅ Temporal/spatial ranges (2021-2025, 100-700 Mb)
- ✅ Significance threshold (α=0.05)

**Avoid**:
- ❌ Vague terms ("improved", "changed") without quantification
- ❌ p-values without effect sizes
- ❌ Missing sample sizes
- ❌ Unspecified statistical methods

### Adding to Jupyter Notebooks

```python
import json

fig_description = {
    "cell_type": "markdown",
    "metadata": {},
    "source": [
        "### Figure X. [Title]\n",
        "\n",
        "**[Opening with sample sizes]**\n",
        "\n",
        "**Key Findings:**\n",
        "\n",
        "**[Metric 1]**: [Statistical result]. [Interpretation].\n",
        "\n",
        "**Interpretation:** [Synthesis]."
    ]
}

# Insert after the plotting cell
nb['cells'].insert(plot_cell_idx + 1, fig_description)
```

## iTOL (Interactive Tree of Life) Dataset Creation

### Overview
iTOL is a web-based tool for phylogenetic tree visualization. Creating annotation datasets requires specific formats and understanding format differences between legacy and modern approaches.

### Key Format Types

#### 1. DATASET_STYLE (Modern Format for Branch/Node Coloring)
Use for coloring individual terminal branches or nodes.

**Critical requirements**:
- Use `SEPARATOR COMMA` (not TAB)
- Format: `species,branch,node,#color,width,style`
- The three fields (branch/node/style) are all required even though only one is used

```
DATASET_STYLE
SEPARATOR COMMA

DATASET_LABEL,Terminal Branch Colors by Taxonomy
COLOR,#ff0000

DATA
Homo_sapiens,branch,node,#C084C0,2,normal
Mus_musculus,branch,node,#C084C0,2,normal
```

**Common errors avoided**:
- ❌ Using TAB separator → causes "Invalid color definition" errors
- ❌ Using `clade` instead of individual species → all branches get same color
- ❌ Omitting required fields → format errors

#### 2. DATASET_BINARY (Presence/Absence Markers)
Use for adding symbols (checkmarks, stars, etc.) to specific species.

```
DATASET_BINARY
SEPARATOR TAB

DATASET_LABEL	Dual Curation

FIELD_SHAPES	6
FIELD_LABELS	Dual Curation
FIELD_COLORS	#FF0000

LEGEND_TITLE	Curation Status
LEGEND_SHAPES	6
LEGEND_COLORS	#FF0000
LEGEND_LABELS	Dual Curation

DATA
Homo_sapiens	1
Mus_musculus	1
```

**Symbol codes**:
- 1 = circle, 2 = square, 3 = diamond, 4 = triangle, 5 = filled square, 6 = checkmark

#### 3. DATASET_COLORSTRIP (Colored Rectangles)
```
DATASET_COLORSTRIP
SEPARATOR TAB

DATASET_LABEL	Taxonomic Lineage

DATA
Homo_sapiens	#C084C0	Mammals
Mus_musculus	#C084C0	Mammals
```

### Species Name Synchronization

**Problem**: Tree species names often differ from metadata due to:
1. TimeTree database replacements (standardization)
2. Spelling variants (e.g., `Chiropotes_utahickae` vs `Chiropotes_utahicki`)
3. Case differences (e.g., `Alca_torda` vs `Alca_Torda`)
4. Trailing spaces in CSV files

**Solution workflow**:
1. Export tree species list: `grep -oE "[A-Z][a-z]+_[a-z]+" Tree.nwk | sort -u`
2. Compare with metadata species list
3. Create replacement mapping JSON
4. Apply systematically to tree AND all annotation files
5. Document replacements for reproducibility

**Best practice**: Create separate versions:
- `*_corrected.*` - After TimeTree replacements
- `*_final.*` - After all name variant corrections

### Handling Reference Species Added by Tree Builders

TimeTree and similar tools may add reference species not in your original dataset for:
- Phylogenetic completeness
- Temporal calibration
- Topological constraints

**Document these additions**:
1. Identify species in tree but not in metadata
2. Research their phylogenetic role
3. Create separate iTOL dataset to highlight them
4. Document why they were added

Example:
```python
# Create dataset for reference species
timetree_additions = ["Species_one", "Species_two"]
# Use different symbol/color to distinguish from your species
```

### Color Schemes for Taxonomy

Standard color palette for major vertebrate groups:
```python
colors = {
    'Mammals': '#C084C0',       # Purple
    'Birds': '#FFD700',         # Gold
    'Reptiles': '#9370DB',      # Medium Purple
    'Amphibians': '#98D8C8',    # Turquoise
    'Fishes': '#87CEEB',        # Sky Blue
    'Invertebrates': '#8B4513'  # Brown
}
```

### Troubleshooting iTOL Errors

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Invalid color definition 'normal'" | Wrong field order in TREE_COLORS | Switch to DATASET_STYLE format |
| "Invalid color definition 'node'" | Using TAB separator with DATASET_STYLE | Change to `SEPARATOR COMMA` |
| "All branches same color" | Using clade-based coloring with overlapping definitions | Color individual terminal branches instead |
| Species missing from dataset | Name mismatch between tree and metadata | Create name mapping and apply to all files |
| "Other" lineage shown | New names from replacements lack lineage info | Map new names to lineages from original names |

### File Organization Best Practice

```
phylo/
├── Tree.nwk                              # Original
├── Tree_corrected.nwk                    # After TimeTree replacements
├── Tree_final.nwk                        # After all name corrections
├── itol_branch_colors_final.txt          # Terminal branch colors
├── itol_taxonomic_colorstrip_final.txt   # Colored strips
├── itol_dual_curation_binary_final.txt   # Binary markers
├── itol_timetree_additions_final.txt     # Reference species markers
├── species_replacements.json             # TimeTree replacements
├── name_variant_replacements.json        # Spelling/case fixes
└── SPECIES_CORRECTIONS_SUMMARY.md        # Full documentation
```

### Updating iTOL Config Color Schemes

When updating color schemes across multiple iTOL configuration files, colors appear in multiple locations with different syntax:

**Files requiring updates (for 3-category example):**

1. **Colorstrip configs** (`itol_3category_colorstrip_UPDATED.txt`):
   - `LEGEND_COLORS` line: tab-separated hex values
   - Individual species rows: `species_name<tab>category<tab>#HEXCODE`

2. **Label configs** (`itol_3category_labels_UPDATED.txt`):
   - `LEGEND_COLORS,` line: comma-separated hex values
   - DATA rows: `species,label,label,#HEXCODE,1,normal`

3. **Branch color configs** (`itol_3category_branch_colors_UPDATED.txt`):
   - DATA rows: `species<tab>branch<tab>#HEXCODE<tab>normal<tab>2`

4. **Binary highlight configs** (one per category):
   - `COLOR` line: single hex value
   - `LEGEND_COLORS` line: single hex value
   - `FIELD_COLORS` line: single hex value

**Efficient Update Strategy:**

Use Edit tool with `replace_all=true` for each old→new color mapping:
```python
# Update all instances of old color across file
Edit(
    file_path="itol_3category_colorstrip_UPDATED.txt",
    old_string="#3498db",
    new_string="#FF8C00",
    replace_all=True
)
```

**Typical color update sequence:**
1. Map old→new colors (e.g., blue→orange, orange→green, green→blue)
2. Update all files with first mapping (old blue→new orange)
3. Update all files with second mapping (old orange→new green)
4. Update all files with third mapping (old green→new blue)

**Files to update (for 3-category system):**
- `itol_3category_colorstrip_UPDATED.txt`
- `itol_3category_labels_UPDATED.txt`
- `itol_3category_branch_colors_UPDATED.txt`
- `itol_3category_phased_dual_binary_UPDATED.txt`
- `itol_3category_phased_single_binary_UPDATED.txt`
- `itol_3category_pri_alt_single_binary_UPDATED.txt`

**Verification:**
- Grep for old hex codes to confirm all replaced
- Check LEGEND_COLORS lines match DATA row colors
- Verify binary files use correct category color

**Common Color Scheme Examples:**

VGP Curation 3-Category System:
```python
COLORS = {
    'Phased+Dual': '#FF8C00',      # Dark orange
    'Phased+Single': '#50C878',    # Emerald green
    'Pri/alt+Single': '#4169E1'    # Royal blue
}
```

## References

- Matplotlib documentation: https://matplotlib.org/
- Seaborn visualization: https://seaborn.pydata.org/
- iTOL documentation: https://itol.embl.de/help.cgi
- VGP curation analysis: Real-world example of these patterns
