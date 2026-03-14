# Visualization Guide: Publication-Quality Figures

## Publication-Quality Figures

Standard settings:
- DPI: 300
- Figure size: (12, 8) for single plots, (16, 7) for side-by-side
- Grid: `alpha=0.3, linestyle='--'`
- Point size: Proportional to sample count (`s=[50 + count*20 for count in counts]`)
- Colormap: 'viridis' for workflow counts


### Publication-Ready Font Sizes

**Problem**: Default matplotlib fonts are designed for screen viewing, not print publication.

**Solution**: Use larger, bold fonts for print readability.

**Recommended sizes** (for standard 10-12 cm wide figures):

| Element | Default | Publication | Code |
|---------|---------|-------------|------|
| **Title** | 11-12pt | **18pt** (bold) | `fontsize=18, fontweight='bold'` |
| **Axis labels** | 10-11pt | **16pt** (bold) | `fontsize=16, fontweight='bold'` |
| **Tick labels** | 9-10pt | **14pt** | `tick_params(labelsize=14)` |
| **Legend** | 8-10pt | **12pt** | `legend(fontsize=12)` |
| **Annotations** | 8-10pt | **11-13pt** | `fontsize=12` |
| **Data points** | 20-36 | **60-100** | `s=80` (scatter) |

**Implementation example**:
```python
fig, ax = plt.subplots(figsize=(10, 8))

# Plot data
ax.scatter(x, y, s=80, alpha=0.6)  # Larger points

# Titles and labels - BOLD
ax.set_title('Your Title Here', fontsize=18, fontweight='bold')
ax.set_xlabel('X Axis Label', fontsize=16, fontweight='bold')
ax.set_ylabel('Y Axis Label', fontsize=16, fontweight='bold')

# Tick labels
ax.tick_params(axis='both', which='major', labelsize=14)

# Legend
ax.legend(fontsize=12, loc='best')

# Stats box
stats_text = "Statistics:\nMean: 42.5"
ax.text(0.02, 0.98, stats_text, transform=ax.transAxes,
       fontsize=13, family='monospace',
       bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.3))

# Reference lines - thicker
ax.axhline(y=1.0, linewidth=2.5, linestyle='--', alpha=0.6)
```

**Quick check**: If you have to squint to read the figure on screen at 100% zoom, fonts are too small for print.

**Special cases**:
- Multi-panel figures: Increase 10-15% more
- Posters: Increase 50-100% more
- Presentations: Increase 30-50% more

### Accessibility: Colorblind-Safe Palettes

**Problem**: Standard color schemes (green vs blue, red vs green) are difficult or impossible to distinguish for people with color vision deficiencies, affecting ~8% of males and ~0.5% of females.

**Solution**: Use colorblind-safe palettes from validated sources.

**IBM Color Blind Safe Palette (Recommended)**:
```python
# For comparing two groups/conditions
colors = {
    'Group_A': '#0173B2',  # Blue
    'Group_B': '#DE8F05'   # Orange
}
```

**Why this works**:
- Maximum contrast for all color vision types (deuteranopia, protanopia, tritanopia, achromatopsia)
- Professional appearance for scientific publications
- Clear distinction even in grayscale printing
- Cultural neutrality (no red/green traffic light associations)

**Other colorblind-safe combinations**:
- Blue + Orange (best overall)
- Blue + Red (good for most types)
- Blue + Yellow (good but lower contrast)

**Avoid**:
- Green + Red (most common color blindness)
- Green + Blue (confusing for many)
- Blue + Purple (too similar)

**Implementation in matplotlib**:
```python
import matplotlib.pyplot as plt

# Define colorblind-safe palette
CB_COLORS = {
    'blue': '#0173B2',
    'orange': '#DE8F05',
    'green': '#029E73',
    'red': '#D55E00',
    'purple': '#CC78BC',
    'brown': '#CA9161'
}

# Use in plots
plt.scatter(x, y, color=CB_COLORS['blue'], label='Treatment')
plt.scatter(x2, y2, color=CB_COLORS['orange'], label='Control')
```

**Testing your colors**:
- Use online simulators: https://www.color-blindness.com/coblis-color-blindness-simulator/
- Check in grayscale: Convert figure to grayscale to ensure distinguishability

### Handling Severe Data Imbalance in Comparisons

**Problem**: Comparing groups with very different sample sizes (e.g., 84 vs 10) can lead to misleading conclusions.

**Solution**: Add prominent warnings both visually and in documentation.

**Visual warning on figure**:
```python
import matplotlib.pyplot as plt

# After creating your plot
n_group_a = len(df[df['group'] == 'A'])
n_group_b = len(df[df['group'] == 'B'])
total_a = 200
total_b = 350

warning_text = f"DATA LIMITATION\n"
warning_text += f"Data availability:\n"
warning_text += f"  Group A: {n_group_a}/{total_a} ({n_group_a/total_a*100:.1f}%)\n"
warning_text += f"  Group B: {n_group_b}/{total_b} ({n_group_b/total_b*100:.1f}%)\n"
warning_text += f"Severe imbalance limits\nstatistical comparability"

ax.text(0.98, 0.02, warning_text, transform=ax.transAxes,
       fontsize=11, verticalalignment='bottom', horizontalalignment='right',
       bbox=dict(boxstyle='round', facecolor='red', alpha=0.2,
                edgecolor='red', linewidth=2),
       family='monospace', color='darkred', fontweight='bold')

# Update title to indicate limitation
ax.set_title('Your Title\n(SUPPLEMENTARY - Limited Data Availability)',
            fontsize=14, fontweight='bold')
```

**Text warning in notebook/paper**:
```markdown
**CRITICAL DATA LIMITATION**: This figure suffers from severe data availability bias:
- Group A: 84/200 (42%)
- Group B: 10/350 (3%)

This **8-fold imbalance** severely limits statistical comparability. The 10 Group B
samples are unlikely to be representative of all 350.

**Interpretation**: Comparisons should be interpreted with extreme caution. This
figure is provided for completeness but should be considered **supplementary**.
```

**Guidelines for sample size imbalance**:
- **< 2x imbalance**: Generally acceptable, note in caption
- **2-5x imbalance**: Add note about limitations
- **> 5x imbalance**: Add prominent warnings (visual + text)
- **> 10x imbalance**: Consider excluding figure or supplementary-only

**Alternative**: If possible, subset the larger group to match sample size:
```python
# Random subset to balance groups
if n_group_a > n_group_b * 2:
    group_a_subset = df[df['group'] == 'A'].sample(n=n_group_b * 2, random_state=42)
    # Use subset for balanced comparison
```

## Image Display and Responsive Scaling

### Problem: Fixed-size images don't scale with notebook viewer window

When adding images to Jupyter notebooks, you often want them to scale responsively with the viewing window size rather than display at a fixed size.

### Solution Comparison

**SVG with IPython.display.SVG():**
- Displays at native SVG size (fixed)
- Cannot specify width parameter (raises ValueError)
- Does not scale with window resizing
```python
from IPython.display import SVG, display
display(SVG(filename='image.svg'))  # Fixed size, no scaling
```

**PNG conversion attempts:**
- ImageMagick may fail on complex SVG files with rendering errors
- Example error: `non-conforming drawing primitive definition 'stroke-linecap'`
- Conversion process adds complexity

**HTML img tag in markdown cell (RECOMMENDED):**
```markdown
<img src="path/to/image.svg" width="100%" style="max-width: 1200px; height: auto;" alt="Description">
```

Benefits:
- Scales responsively to 100% of container width
- `max-width` prevents oversized display on large screens
- `height: auto` maintains aspect ratio
- Works with both SVG and PNG formats
- Browser handles rendering natively

### Implementation Pattern

Replace code cells using `display(Image(...))` or `display(SVG(...))` with markdown cells containing HTML:

**Before (code cell):**
```python
from IPython.display import SVG, display
display(SVG(filename='phylo/tree.svg'))
```

**After (markdown cell):**
```markdown
<img src="phylo/tree.svg" width="100%" style="max-width: 1200px; height: auto;" alt="Phylogenetic tree">
```

### When to Use Each Approach

- **Markdown + HTML img**: Publication notebooks, figures that need responsive sizing
- **IPython.display.Image()**: Quick exploration, when fixed PNG size is acceptable
- **IPython.display.SVG()**: When you want maximum quality at native size and don't need scaling

## SVG Manipulation

### Cropping SVG Files Without External Tools

SVG files can be cropped by modifying the `viewBox` and `width` attributes directly, avoiding ImageMagick or other conversion tools.

**Use case**: Remove empty space from generated figures (e.g., iTOL phylogenetic trees with excess whitespace)

**Method - Crop from right side:**
```python
import re

# Read original SVG
with open('original.svg', 'r') as f:
    svg_content = f.read()

# Calculate new dimensions (e.g., 30% width reduction)
original_width = 2560
crop_percentage = 30
new_width = int(original_width * (100 - crop_percentage) / 100)  # 1792
original_height = 1352  # Unchanged

# Update width and viewBox attributes
svg_content = re.sub(r'width="2560"', f'width="{new_width}"', svg_content)
svg_content = re.sub(
    r'viewBox="0,0,2560,1352"',
    f'viewBox="0,0,{new_width},{original_height}"',
    svg_content
)

# Save cropped version
with open('original_cropped.svg', 'w') as f:
    f.write(svg_content)
```

**How it works:**
- `viewBox="x,y,width,height"` defines the coordinate system for SVG content
- Reducing viewBox width crops from the right side (keeps left portion)
- Updating `width` attribute ensures proper rendering size
- Height remains unchanged to preserve vertical content

**Alternative crops:**
- **Left side**: `viewBox="crop_amount,0,new_width,height"`
- **Both sides**: Center the viewBox `viewBox="left_crop,0,new_width,height"`

**Advantages over ImageMagick:**
- No external dependencies or conversion errors
- Preserves vector quality (no rasterization)
- Fast and lightweight
- Works on any SVG file
- Easy to iterate (try 20%, 30%, 40% crops)

**Limitations:**
- Only crops to rectangular regions
- Doesn't handle complex transformations
- May cut off content if not careful (iterate and check visually)

## Managing Large Image Outputs in Notebooks

### Problem: Image Loading Errors

**Symptom**: Notebook displays "Output too large" or fails to load images when opening
**Cause**: High-DPI figures (300 DPI) combined with large figure sizes generate massive image outputs

### Solution: Optimize Figure DPI and Sizes

**For matplotlib/seaborn notebooks:**

```python
# In setup cell - set global defaults
plt.rcParams['figure.dpi'] = 150      # Reduced from 300
plt.rcParams['savefig.dpi'] = 150     # Reduced from 300
```

**In individual savefig calls:**
```python
# Also reduce figure dimensions
fig, axes = plt.subplots(2, 3, figsize=(12, 8))  # Was (15, 10)
# ... plotting code ...
plt.savefig('output.png', dpi=150, bbox_inches='tight')  # Was dpi=300
```

**Expected results:**
- File size reduction: ~75% (combination of DPI and size reduction)
- Still publication-quality: 150 DPI is sufficient for digital viewing and most journals
- Notebook remains viewable: Images load without errors

### When to Use Different DPI Settings

- **150 DPI**: Digital viewing, manuscript review, most online journals (recommended default)
- **300 DPI**: Print publication requirements, final submission only
- **72-96 DPI**: Presentations, slides, web display only

### Pattern: Update Existing High-DPI Notebooks

If you have a notebook with loading errors:

1. **Identify figure generation cells** (look for `plt.savefig`)
2. **Update setup cell** with reduced DPI settings
3. **Update figure sizes** in `plt.subplots(figsize=...)` calls
4. **Update savefig DPI** parameters
5. **Re-run cells** to regenerate optimized figures

**Example transformation:**
```python
# Before (causes loading errors)
plt.rcParams['savefig.dpi'] = 300
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
plt.savefig('figure.png', dpi=300, bbox_inches='tight')

# After (loads correctly)
plt.rcParams['savefig.dpi'] = 150
fig, axes = plt.subplots(2, 3, figsize=(12, 8))
plt.savefig('figure.png', dpi=150, bbox_inches='tight')
```

**Token efficiency note**: Use `jupyter nbconvert --to python` to extract code and identify all figure-generating cells quickly without reading full notebook.

### Updating Color Palettes Across Multiple Cells

**Pattern**: When changing visualization colors throughout a notebook:

1. **Identify palette definition cells** - Usually early in notebook (setup or prep cells)
2. **Update centralized color dictionary** - Change palette in one location
3. **Check for hardcoded colors** - Some cells may override the palette
4. **Update all override locations** - Use NotebookEdit for each cell

**Example: Updating from default to colorblind-safe palette**

```python
# Cell 1: Main palette definition
category_colors = {
    'Cat_A': '#0072B2',    # Blue (Okabe-Ito)
    'Cat_B': '#E69F00',    # Orange (Okabe-Ito)
    'Cat_C': '#CC79A7'     # Reddish Purple (Okabe-Ito)
}
```

```python
# Cell 2: Technology-specific palette (may need separate update)
tech_palette = {
    'Cat_A+Tech1': '#0072B2',
    'Cat_A+Tech2': '#56B4E9',
    'Cat_B+Tech1': '#E69F00',
    'Cat_C+Tech1': '#CC79A7',
    'Cat_C+Tech2': '#F0E442'
}
```

**Systematic update process**:
1. Update main `category_colors` dict
2. Update any `palette` or `tech_palette` dicts
3. Check for cells with hardcoded `color='#...'` parameters
4. Re-run affected visualization cells

**Token-efficient approach**: Use `jupyter nbconvert --to python | grep -n "color"` to find all color references before updating.

## Removing Panels from Multi-Panel Figures

**Scenario**: Convert 2-panel figure to 1-panel after removing unavailable data.

**Steps**:
1. **Update subplot layout**:
   ```python
   # Before: 2 panels
   fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

   # After: 1 panel
   fig, ax = plt.subplots(1, 1, figsize=(10, 6))
   ```

2. **Remove panel code**: Delete all code for removed panel (ax2)

3. **Update figure filename**:
   ```python
   # Before
   plt.savefig('06_scaffold_l50_l90_comparison.png')

   # After
   plt.savefig('06_scaffold_l50_comparison.png')
   ```

4. **Update notebook references**:
   - Image display: `display(Image(...'06_scaffold_l50_comparison.png'))`
   - Title: Remove references to removed data
   - Description: Add note about why panel is excluded

5. **Clean up old files**:
   ```bash
   rm figures/*_l50_l90_*.png
   ```
