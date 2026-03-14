# Color Palettes for Scientific Figures

Reference for colorblind-safe, sequential, and diverging color schemes.

## Colorblind-Friendly Palettes

Standard palette for dual comparisons:
```python
COLORS = {
    'Group1': '#0173B2',  # Blue
    'Group2': '#DE8F05'   # Orange
}
```

Accessible to most common color vision deficiencies.

### Comprehensive Colorblind-Safe Color Palettes

**Problem: Poor Color Accessibility**

**Common issue**: Default color schemes often use green-blue or red-green combinations that are indistinguishable for colorblind viewers (~8% of population).

**Examples of problematic combinations**:
- Green + Blue (similar for deuteranopia/protanopia)
- Red + Green (classic colorblindness issue)
- Light blue + Dark blue (insufficient contrast)

### Okabe-Ito Palette (Recommended by Nature)

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

### Paul Tol's Bright Palette (Alternative)

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

### Implementation in Matplotlib/Seaborn

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

### Best Practices

1. **Avoid red-green combinations** - Most common colorblindness type
2. **Use patterns/markers too** - Combine color with shapes for redundancy
3. **Test your figures** - Use colorblindness simulators online
4. **Document your palette** - Add comment explaining choice
5. **Be consistent** - Use same colors for same categories across all figures

### Example: Complete Figure Setup

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

### When to Use Which Palette

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

### Resources

- **Okabe-Ito palette**: https://jfly.uni-koeln.de/color/
- **Paul Tol's schemes**: https://personal.sron.nl/~pault/
- **Colorblind simulator**: https://www.color-blindness.com/coblis-color-blindness-simulator/
- **Venngage guide**: https://venngage.com/blog/color-blind-friendly-palette/

### Real Example: VGP Assembly Analysis

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

## Sequential vs Diverging Palettes

**Use sequential palettes for**:
- Temporal progression (old to new)
- Intensity/magnitude (low to high)
- Single-direction trends

**Best practice for temporal data**:
- **YlOrRd** (Yellow-Orange-Red): Clear old to new progression
- Start: Light color (e.g., `#ffffcc` - light yellow)
- End: Dark color (e.g., `#b10026` - dark red)
- Users intuitively understand light to dark as past to present

**Avoid for temporal data**:
- Diverging palettes (RdYlBu): Implies a meaningful midpoint
- Blue to Red: No clear temporal association
- Rainbow: Color order not intuitive

**Example** (assembly release years 2019-2025):
```python
# Good: Sequential YlOrRd
gradient_colors = [
    '#ffffcc',  # 2019 - light yellow (oldest)
    '#ffeda0',  # 2020
    '#fed976',  # 2021
    '#feb24c',  # 2022
    '#fd8d3c',  # 2023
    '#fc4e2a',  # 2024
    '#b10026',  # 2025 - dark red (newest)
]

# Bad: Diverging RdYlBu (implies 2022 is special/central)
```

**ColorBrewer sequential palettes**:
- **YlOrRd**: Yellow-Orange-Red (temporal, intensity, heat)
- **YlGn**: Yellow-Green (growth, vegetation)
- **PuBuGn**: Purple-Blue-Green (water, depth)
- **OrRd**: Orange-Red (similar to YlOrRd, starts darker)

**ColorBrewer resources**:
- Website: https://colorbrewer2.org
- Python: `from palettable.colorbrewer import sequential`
- Matplotlib: `plt.cm.YlOrRd` or custom with hex codes
