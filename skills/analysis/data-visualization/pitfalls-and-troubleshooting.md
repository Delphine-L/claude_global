# Data Visualization Pitfalls and Troubleshooting

Reference material for common visualization mistakes, coordinate system issues, and debugging techniques.

## Common Pitfalls with Log-Scale Plots

### Violin Plots on Log Scales

**Problem**: Violin plots use Kernel Density Estimation (KDE) in linear space, then the axis is transformed to log scale. This causes severe visual distortion where the violin shape doesn't accurately represent the actual data distribution.

**Symptoms**:
- Smooth, blob-like violin shapes on log axes
- Visual representation suggests even distribution but histogram shows heavy clustering
- Particularly problematic with right-skewed data heavily concentrated in one region

**Example of the problem**:
```python
# BAD: Violin plot on log scale
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
# GOOD: Boxplot on log scale
ax.boxplot([data])
ax.set_yscale('log')  # Boxplot statistics remain meaningful
```

**Why boxplots work**: Boxplot statistics (median, quartiles, outliers) are calculated as specific values, not density estimates, so they remain meaningful on log scales.

**Solution 2: Log-transform data first**
```python
# ALTERNATIVE: Log-transform data first, then use violin on linear axis
log_data = np.log10(data[data > 0])
ax.violinplot([log_data])
ax.set_ylabel('log10(Value)')
# Keep linear axis - violin now accurately represents log-space distribution
```

**Solution 3: Use histograms with log axes**
```python
# GOOD: Histogram with log y-axis shows true frequency distribution
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
- Scaffold N50 = 500 Gb (500x larger than genome size)
- Confirmed as assembly processing error in NCBI notes
- Other metrics for this assembly are valid and included in other figures
"""
```

## Matplotlib Text Positioning Creates Empty Space

**Problem**: Saved figure has large area of empty white space above the actual plot, making the figure much taller than necessary.

**Cause**: Using `transform=ax.get_xaxis_transform()` with data coordinate y-values positions text far outside the plot bounds. The transform uses axis-relative coordinates (0-1) for x but data coordinates for y, so large y-values create huge positioning errors.

**Symptoms**:
- Empty white space at top (or bottom) of saved figure
- Text annotations not visible or way off the plot
- `tight_layout()` and `pad_inches` adjustments don't fix it
- Problem persists even after reducing figure size

**Example of the problem**:
```python
# BAD: Mixing coordinate systems
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
# GOOD: Position within plot bounds using pure data coordinates
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
# GOOD: Both x and y in 0-1 axis coordinates
ax.text(0.5, 0.90, '***',
       transform=ax.transAxes,  # Both x and y in 0-1 range
       ha='center', va='center', fontsize=12)
```

**Solution 3: Use annotate with xycoords**

```python
# GOOD: Explicit coordinate specification
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

## Float Year Labels on X-Axis

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

## Axis Range Optimization for Compressed Distributions

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
- Data concentrated in narrow range (e.g., 80-100%)
- Improves visibility of differences
- All relevant data still visible
- Makes small differences more apparent

**When NOT to adjust**:
- Would hide meaningful outliers
- Creates misleading visual impression
- Data actually spans full range
- Standard in field to show full range (0-100%)

**Best practice**: Show both views if controversial
- Main figure: Zoomed range for clarity
- Supplementary: Full range for context
