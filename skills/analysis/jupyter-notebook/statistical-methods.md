# Statistical Methods: Outlier Handling, Rigor, and Verification

## Outlier Handling Best Practices

### Two-Stage Outlier Removal

For analyses correlating characteristics across aggregated entities (e.g., species-level summaries):

1. **Stage 1: Count-based outliers (IQR method)**
   - Remove entities with abnormally high sample counts
   - Prevents over-represented entities from skewing correlations
   - Apply BEFORE other analyses

   ```python
   import numpy as np
   workflow_counts = [entity_data[id]['workflow_count'] for id in entity_data.keys()]
   q1 = np.percentile(workflow_counts, 25)
   q3 = np.percentile(workflow_counts, 75)
   iqr = q3 - q1
   upper_bound = q3 + 1.5 * iqr

   outliers = [id for id in entity_data.keys()
               if entity_data[id]['workflow_count'] > upper_bound]
   for id in outliers:
       del entity_data[id]
   ```

2. **Stage 2: Value-based outliers (percentile)**
   - Remove extreme values for visualization clarity
   - Apply ONLY to visualization data, not statistics
   - Typically top 5% for highly skewed distributions

   ```python
   values = [entity_data[id]['metric'] for id in entity_data.keys()]
   threshold = np.percentile(values, 95)
   viz_entities = [id for id in entity_data.keys()
                   if entity_data[id]['metric'] <= threshold]

   # Use viz_entities for plotting
   # Use full entity_data.keys() for statistics
   ```

### Characteristic-Specific Outlier Removal

When analyzing genome characteristics vs metrics, remove outliers for the characteristic being analyzed:

```python
# After removing workflow count outliers, also remove heterozygosity outliers
heterozygosity_values = [species_data[sp]['heterozygosity'] for sp in species_data.keys()]

het_q1 = np.percentile(heterozygosity_values, 25)
het_q3 = np.percentile(heterozygosity_values, 75)
het_iqr = het_q3 - het_q1
het_upper_bound = het_q3 + 1.5 * het_iqr

het_outliers = [sp for sp in species_data.keys()
                if species_data[sp]['heterozygosity'] > het_upper_bound]

for sp in het_outliers:
    del species_data[sp]

print(f'Removed {len(het_outliers)} heterozygosity outliers (>{het_upper_bound:.2f}%)')
print(f'New heterozygosity range: {min(vals):.2f}% - {max(vals):.2f}%')
```

**Apply separately for each characteristic**:
- Genome size outliers for genome size analysis
- Heterozygosity outliers for heterozygosity analysis
- Repeat content outliers for repeat content analysis

### When to Skip Outlier Removal

- Memory usage plots when investigating over-allocation patterns
- Comparison plots (allocated vs used) where outliers reveal problems
- User explicitly requests to see all data
- Data is already limited (< 10 points)

**Document clearly** in plot titles and code comments which outlier removal is applied.


### IQR-Based Outlier Removal for Visualization

**Standard Method**: 1.5xIQR (Interquartile Range)

**Implementation**:
```python
# Calculate IQR
Q1 = data.quantile(0.25)
Q3 = data.quantile(0.75)
IQR = Q3 - Q1

# Define outlier boundaries (standard: 1.5xIQR)
lower_bound = Q1 - 1.5*IQR
upper_bound = Q3 + 1.5*IQR

# Filter outliers
outlier_mask = (data >= lower_bound) & (data <= upper_bound)
data_filtered = data[outlier_mask]
n_outliers = (~outlier_mask).sum()

# IMPORTANT: Report outliers removed
print(f"Removed {n_outliers} outliers for visualization")
# Add to figure: f"({n_outliers} outliers removed)"
```

**Multi-dimensional Outlier Removal**:
```python
# For scatter plots with two dimensions (e.g., size ratio AND absolute size)
outlier_mask = (
    (ratio >= Q1_ratio - 1.5*IQR_ratio) &
    (ratio <= Q3_ratio + 1.5*IQR_ratio) &
    (size >= Q1_size - 1.5*IQR_size) &
    (size <= Q3_size + 1.5*IQR_size)
)
```

**Best Practice**: Always report number of outliers removed in figure statistics or caption.

**When to Use**: For visualization clarity when extreme values compress the main distribution. Not for removing "bad" data - use for display only.

## Statistical Rigor

### Required for Correlation Analyses

1. **Pearson correlation with p-values**:
   ```python
   from scipy import stats
   correlation, p_value = stats.pearsonr(x_values, y_values)
   sig_text = 'significant' if p_value < 0.05 else 'not significant'
   ```

2. **Report both metrics**:
   - Correlation coefficient (r) - strength and direction
   - P-value - statistical significance (alpha=0.05)
   - Sample size (n)

3. **Display on plots**:
   ```python
   ax.text(0.98, 0.02,
           f'r = {correlation:.3f}\np = {p_value:.2e}\n({sig_text})\nn = {len(data)} species',
           transform=ax.transAxes, ...)
   ```


### Adding Mann-Whitney U Tests to Figures

**When to Use**: Comparing continuous metrics between two groups (e.g., Dual vs Pri/alt curation)

**Standard Implementation**:
```python
from scipy import stats

# Calculate test
data_group1 = df[df['group'] == 'Group1']['metric']
data_group2 = df[df['group'] == 'Group2']['metric']

if len(data_group1) > 0 and len(data_group2) > 0:
    stat, pval = stats.mannwhitneyu(data_group1, data_group2, alternative='two-sided')
else:
    pval = np.nan

# Add to stats text
if not np.isnan(pval):
    stats_text += f"\nMann-Whitney p: {pval:.2e}"
```

**Display in Figures**: Include p-value in statistics box with format `Mann-Whitney p: 1.23e-04`

**Consistency**: Ensure all quantitative comparison figures include this test for statistical rigor.

## CRITICAL: Statistical Claim Verification

### The Problem
Notebook analysis text can contain claims based on:
- Preliminary results that changed
- Copy-paste errors from similar analyses
- Expectations that weren't verified
- Old results before data/code updates

**Real example from production notebook:**
- **Text claimed**: "significantly higher N50 values (p < 0.001)"
- **Actual result**: p = 0.28 (NOT significant)
- **Impact**: Would have published false conclusion

### Mandatory Verification Workflow

**BEFORE finalizing any analysis notebook:**

#### 1. Extract All Statistical Claims
Search for keywords:
- p-values: `p <`, `p =`, `p-value`
- Significance: `significant`, `significantly`, `difference`
- Comparisons: `higher`, `lower`, `greater`, `increased`, `decreased`

#### 2. Run Actual Statistical Tests
Don't trust existing text. Rerun the tests:

```python
from scipy import stats
import pandas as pd

# Load actual data
df = pd.read_csv('data.csv')

# Run test (example: Mann-Whitney U)
group1 = df[df['type']=='A']['metric']
group2 = df[df['type']=='B']['metric']
stat, p = stats.mannwhitneyu(group1, group2, alternative='two-sided')

print(f"Actual p-value: {p:.6f}")
print(f"Significant (p<0.05): {p < 0.05}")
```

#### 3. Document Actual Results
Create verification table:

| Figure | Metric | Text Claims | Actual p-value | Match? |
|--------|--------|-------------|----------------|--------|
| Fig 1 | N50 | "p<0.001 significant" | **0.28** | FALSE |
| Fig 2 | Gaps | "p=0.002 significant" | 0.0023 | TRUE |

#### 4. Common Discrepancy Patterns

**False Positive (Type I error in text):**
- Text claims significance when p > 0.05
- **Fix**: Rewrite to state "no significant difference"

**Missed Significance:**
- Text implies no difference when p < 0.05
- **Fix**: Add statistical evidence and effect interpretation

**Wrong Direction:**
- Text claims "Group A > Group B" when opposite is true
- **Fix**: Reverse comparison direction

**Outdated Organization:**
- Figures organized by old results
- **Fix**: Reorganize sections based on actual significance

#### 5. Correction Protocol

When errors found:
1. **Document the error** (create CORRECTIONS.md)
2. **Run verification script** on ALL claims
3. **Reorganize notebook** if section classification wrong
4. **Rewrite analysis text** to match actual results
5. **Update table of contents** with correct annotations
6. **Create milestone backup** documenting corrections

### Prevention

**For new analyses:**
```python
# Write analysis text AFTER running test, not before
stat, p = stats.mannwhitneyu(group1, group2)

# Generate text from actual results
if p < 0.05:
    text = f"significant difference (p={p:.4f})"
else:
    text = f"no significant difference (p={p:.2f})"
```

**Before any publication/sharing:**
1. Run verification on ALL statistical claims
2. Cross-check figure captions with actual p-values
3. Verify section organization matches significance
4. Get second person to spot-check key claims

### Why This Is Critical
- **Scientific integrity**: False claims damage credibility
- **Reproducibility**: Others can't reproduce wrong results
- **Peer review**: Reviewers will catch errors, causing rejection
- **Career impact**: Publishing false statistics has serious consequences

## Control Analyses: Checking for Confounding

When comparing methods (e.g., Method A vs Method B), always check if observed differences could be explained by characteristics of the samples rather than the methods themselves.

**Critical control analysis**:
```python
import pandas as pd
from scipy import stats

def check_confounding(df, method_col, characteristics):
    """
    Compare sample characteristics between methods to check for confounding.

    Args:
        df: DataFrame with samples
        method_col: Column indicating method ('Method_A', 'Method_B')
        characteristics: List of column names to compare

    Returns:
        DataFrame with statistical comparison
    """
    results = []

    for char in characteristics:
        # Get data for each method
        method_a = df[df[method_col] == 'Method_A'][char].dropna()
        method_b = df[df[method_col] == 'Method_B'][char].dropna()

        if len(method_a) < 5 or len(method_b) < 5:
            continue

        # Statistical test
        stat, pval = stats.mannwhitneyu(method_a, method_b, alternative='two-sided')

        # Calculate effect size (% difference in medians)
        pooled_median = pd.concat([method_a, method_b]).median()
        effect_pct = (method_a.median() - method_b.median()) / pooled_median * 100

        results.append({
            'Characteristic': char,
            'Method_A_median': method_a.median(),
            'Method_A_n': len(method_a),
            'Method_B_median': method_b.median(),
            'Method_B_n': len(method_b),
            'p_value': pval,
            'effect_pct': effect_pct,
            'significant': pval < 0.05
        })

    return pd.DataFrame(results)

# Example usage
characteristics = ['genome_size', 'gc_content', 'heterozygosity',
                  'repeat_content', 'sequencing_coverage']

confounding_check = check_confounding(df, 'curation_method', characteristics)
print(confounding_check)
```

**Interpretation guide**:
- **No significant differences**: Methods compared equivalent samples -> valid comparison
- **Method A has "easier" samples** (smaller genomes, lower complexity): Quality differences may be due to sample properties, not method
- **Method A has "harder" samples** (larger genomes, higher complexity): Strengthens conclusion that Method A is better despite challenges
- **Limited data** (n<10): Cannot rule out confounding, note as limitation

**Present in notebook**:
```markdown
## Genome Characteristics Comparison

**Control Analysis**: Are quality differences due to method or sample properties?

[Table comparing characteristics]

**Conclusion**:
- If no differences -> Valid method comparison
- If Method A works with harder samples -> Strengthens conclusions
- If Method A works with easier samples -> Potential confounding
```

**Why critical**: Reviewers will ask this question. Preemptive control analysis demonstrates scientific rigor and prevents major revisions.
