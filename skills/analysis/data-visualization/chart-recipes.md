# Chart Recipes

Code recipes for common scientific visualization patterns.

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

## Adding Sample Sizes to Legends

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

For 2x3 or similar grids, show legend only in first subplot:

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

## Visualizing Category Proportions Over Time

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

## Temporal Trends with Boxplots vs Scatter Plots

**Challenge**: Visualizing temporal trends with multiple categories and overlapping data points

**Solution Progression**:
1. **Scatter plots** - Initial approach, but overlapping points obscure distributions
2. **Boxplots grouped by year** - Better visibility of distributions, clear quartiles
3. **Boxplots with outlier removal** - Cleaner visualization for identifying trends

### Why Boxplots for Temporal Analysis?

**Advantages over scatter plots**:
- Shows distribution at each timepoint (median, quartiles, outliers)
- Groups by year and category simultaneously
- Better visibility than overlapping scatter points
- Easier to spot temporal trends in median values
- Quantifies variability within each year

**Example: Boxplots Grouped by Year and Category**

```python
import matplotlib.pyplot as plt
import numpy as np

# Prepare data grouped by year and category
years = df['year'].unique()
categories = ['Cat_A', 'Cat_B', 'Cat_C']

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
metrics = ['metric1', 'metric2', 'metric3', 'metric4', 'metric5', 'metric6']

for idx, metric in enumerate(metrics):
    ax = axes.flatten()[idx]

    # Prepare boxplot data
    boxplot_data = []
    boxplot_positions = []
    boxplot_colors = []

    for year_idx, year in enumerate(years):
        for cat_idx, category in enumerate(categories):
            data = df[(df['year'] == year) & (df['category'] == category)][metric]
            if len(data) > 0:
                boxplot_data.append(data.values)
                # Position: year_idx * 4 + cat_idx (spacing between years)
                boxplot_positions.append(year_idx * 4 + cat_idx)
                boxplot_colors.append(colors[category])

    # Create boxplots
    bp = ax.boxplot(boxplot_data, positions=boxplot_positions, widths=0.6,
                   patch_artist=True, showfliers=True,
                   boxprops=dict(linewidth=1.5),
                   medianprops=dict(color='black', linewidth=2))

    # Color boxes by category
    for patch, color in zip(bp['boxes'], boxplot_colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)

    # Format x-axis with years
    ax.set_xticks([i * 4 + 1 for i in range(len(years))])
    ax.set_xticklabels(years)
    ax.set_xlabel('Year')
    ax.set_ylabel(metric)

plt.tight_layout()
```

**Positioning logic**: `year_idx * 4 + cat_idx` creates groups of 3 categories per year with spacing between years.

### Outlier Removal for Cleaner Visualization

**When to remove outliers**: When extreme values obscure trends in the bulk of the data.

**IQR Method (1.5x multiplier)**:

```python
# Remove outliers using IQR method
def remove_outliers_iqr(data, metric):
    """Remove outliers using IQR method (1.5x multiplier)"""
    q1 = data[metric].quantile(0.25)
    q3 = data[metric].quantile(0.75)
    iqr = q3 - q1
    upper_threshold = q3 + 1.5 * iqr
    lower_threshold = q1 - 1.5 * iqr

    clean_data = data[
        (data[metric] >= lower_threshold) &
        (data[metric] <= upper_threshold)
    ]

    # Document retention rate
    retention = len(clean_data) / len(data) * 100
    print(f"{metric}: Retained {len(clean_data)}/{len(data)} ({retention:.1f}%)")

    return clean_data

# Apply to all metrics
df_clean = df.copy()
for metric in metrics:
    df_clean = remove_outliers_iqr(df_clean, metric)
```

**Generate Both Versions**:

1. **Figure with all data** (outliers included) - Shows full distribution
2. **Figure with clean data** (outliers removed) - Better for trend visualization

```python
# Figure 1: All data
plt.savefig('temporal_trends_all_data.png', dpi=150, bbox_inches='tight')

# Figure 2: Clean data (outliers removed)
# Use df_clean instead of df
plt.savefig('temporal_trends_clean.png', dpi=150, bbox_inches='tight')
```

### Adding Regression Statistics

For the outlier-removed version, calculate R-squared for linear trends:

```python
from scipy.stats import linregress

# Calculate R-squared for each metric x category combination
regression_stats = []

for metric in metrics:
    for category in categories:
        # Get data for this metric and category
        data = df_clean[df_clean['category'] == category]
        x = data['year'].values
        y = data[metric].values

        if len(x) > 2:  # Need at least 3 points for regression
            slope, intercept, r_value, p_value, std_err = linregress(x, y)
            r_squared = r_value ** 2

            regression_stats.append({
                'metric': metric,
                'category': category,
                'r_squared': r_squared,
                'p_value': p_value,
                'slope': slope,
                'n_points': len(x),
                'significant': p_value < 0.05
            })

# Save to CSV
import pandas as pd
stats_df = pd.DataFrame(regression_stats)
stats_df.to_csv('regression_statistics_clean.csv', index=False)

# Report significant trends
sig_trends = stats_df[stats_df['significant']]
print(f"\nSignificant temporal trends: {len(sig_trends)}/{len(regression_stats)}")
```

**Interpretation Example**:

From real temporal analysis (HiFi assemblies, 2021-2025):
- 18 metric x category combinations tested
- Only 1 showed strong significant trend: Pri/alt+Single Scaffold N50 (R-squared=0.937, p=0.007)
- **Conclusion**: Quality is methodology-determined, not temporally-dependent
- **Validation**: Pooling assemblies across years is valid for comparative analysis

### Chart Type Selection Guide

**When to use scatter plots**:
- Small datasets (< 50 points per year)
- Want to show individual data points
- Continuous time variable (not discrete years)

**When to use boxplots**:
- Large datasets (overlapping points)
- Discrete timepoints (years, quarters)
- Want to emphasize distributions and quartiles
- Multiple categories to compare

**When to remove outliers**:
- For visualization clarity (generate both versions)
- For regression analysis (outliers distort trends)
- Don't remove for reporting distributions
- Don't remove without documenting retention rate

**Documentation**:
- Always report retention rate after outlier removal
- Generate both versions (all data + clean data)
- Document IQR multiplier used (1.5x is standard)
- Include R-squared statistics for clean data version

## Temporal Trend Figures: The Dual Approach

### The Challenge

Scatter plots showing temporal trends often have outliers that:
- Obscure the overall pattern
- Make regression lines hard to interpret
- Reduce visual clarity for reviewers

But removing outliers raises concerns about cherry-picking data.

### The Dual Approach Solution

**Create TWO versions for different purposes:**

1. **Figure with all data**: For initial analysis and verification
2. **Figure with cleaned data**: For publication and presentation

**Key requirement**: Use different approaches for visualization vs. statistics

### Implementation Pattern

```python
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import spearmanr

def plot_temporal_trends(df, remove_outliers=False, output_suffix=''):
    """
    Plot temporal trends with optional outlier removal

    Parameters:
    -----------
    df : DataFrame with year and metric columns
    remove_outliers : bool, if True removes points beyond 1.5x IQR
    output_suffix : str, added to filename (e.g., '_clean')
    """

    if remove_outliers:
        # Define outliers by metric
        for metric in ['scaffold_n50', 'gap_density']:
            Q1 = df[metric].quantile(0.25)
            Q3 = df[metric].quantile(0.75)
            IQR = Q3 - Q1

            # Keep only points within 1.5x IQR
            df = df[
                (df[metric] >= Q1 - 1.5 * IQR) &
                (df[metric] <= Q3 + 1.5 * IQR)
            ]

    # Create scatter plot with regression line
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))

    for ax, metric in zip(axes.flat, metrics):
        # Scatter plot by category
        for category in categories:
            subset = df[df['category'] == category]
            ax.scatter(subset['year'], subset[metric],
                      label=category, alpha=0.6)

            # Add regression line
            z = np.polyfit(subset['year'], subset[metric], 1)
            p = np.poly1d(z)
            ax.plot(subset['year'], p(subset['year']), '--')

            # Add statistics (calculated on FULL dataset elsewhere)
            rho, pval = spearmanr(subset['year'], subset[metric])
            ax.text(0.05, 0.95, f'rho={rho:.2f}, p={pval:.3f}',
                   transform=ax.transAxes, va='top')

        ax.set_xlabel('Year')
        ax.set_ylabel(metric)
        ax.legend()

    plt.tight_layout()
    plt.savefig(f'temporal_trends{output_suffix}.png', dpi=300)
    plt.close()

# Create both versions
plot_temporal_trends(df_full, remove_outliers=False, output_suffix='')
plot_temporal_trends(df_full, remove_outliers=True, output_suffix='_clean')
```

### Calculate Statistics Separately

**CRITICAL**: Statistics should ALWAYS use the full dataset, even if figures show cleaned data.

```python
# Statistics on FULL dataset (no outlier removal)
def calculate_temporal_statistics(df_full):
    """Calculate Spearman correlations on complete dataset"""
    results = []

    for category in categories:
        subset = df_full[df_full['category'] == category]
        for metric in metrics:
            rho, pval = spearmanr(subset['year'], subset[metric])
            results.append({
                'category': category,
                'metric': metric,
                'rho': rho,
                'p_value': pval,
                'n': len(subset)
            })

    return pd.DataFrame(results)

# Use FULL dataset
stats_df = calculate_temporal_statistics(df_full)
stats_df.to_csv('temporal_statistics_full_dataset.csv')
```

### File Naming Convention

Use clear naming to distinguish versions:

```
temporal_trends.png              # All data (for analysis)
temporal_trends_clean.png        # Cleaned (for publication)
temporal_statistics.csv          # Stats from FULL dataset
regression_statistics_clean.csv  # Regression from cleaned figure
```

### Documentation Requirements

If using cleaned figures with full-dataset statistics:

**In figure caption**:
```latex
Outliers removed for clarity (points beyond 1.5x IQR from quartiles).
\textbf{Note}: Statistical tests use Spearman correlation (rho) on the
full dataset (n=XXX) for conservative assessment; this figure shows
cleaned data for visual clarity only.
```

**In Methods section**:
```latex
\textbf{Visualization}: Scatter plots show cleaned data (outliers
beyond 1.5x IQR removed). Statistical tests use Spearman correlation
on complete dataset for conservative assessment.
```

### When to Use This Approach

**Use cleaned figures when**:
- Many outliers obscure the main pattern
- Target audience needs quick visual interpretation (papers, talks)
- Statistics are robust to outliers (Spearman, Kendall)
- You document the dual approach explicitly

**Keep all points when**:
- Few outliers (< 5% of data)
- Outliers are scientifically interesting
- Sample size is small (n < 50)
- Using parametric statistics sensitive to outliers

### Quality Check

Before finalizing:

```python
# Verify outlier counts
n_total = len(df_full)
n_clean = len(df_clean)
n_removed = n_total - n_clean
pct_removed = 100 * n_removed / n_total

print(f"Total points: {n_total}")
print(f"Removed: {n_removed} ({pct_removed:.1f}%)")
print(f"Retained: {n_clean} ({100-pct_removed:.1f}%)")

# Should typically remove < 10% of points
assert pct_removed < 10, "Too many outliers removed!"
```
