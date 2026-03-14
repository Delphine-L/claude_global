# Analysis Interpretation Patterns

Frameworks for interpreting multi-factor designs, paradoxical results, power limitations, and technology confounding.

## Multi-Factor Experimental Design Analysis

### Analyzing Multi-Factor Experimental Designs

When experimental design has multiple factors (e.g., assembly architecture x curation method):

**Three-category design pattern**:
- **Category 1**: Factor A + Factor B (e.g., Phased + Dual)
- **Category 2**: Factor A + ~B (e.g., Phased + Single)
- **Category 3**: ~A + ~B (e.g., Pri/alt + Single)

**Enables isolation of effects**:
1. **Factor B effect**: Compare Category 1 vs Category 2 (controls Factor A)
2. **Factor A effect**: Compare Category 2 vs Category 3 (controls Factor B)
3. **Combined effect**: Compare Category 1 vs Category 3 (both factors)

**Interpretation framework**:
```markdown
### Implications by Effect Type

**1. [Factor B] Effect (Category1 vs Category2):**
- Comparison: [values]
- p-value: [X.XXX]
- **Finding**: [significant/not significant]
- **Interpretation**: [what this means for Factor B in isolation]

**2. [Factor A] Effect (Category2 vs Category3):**
- Comparison: [values]
- p-value: [X.XXX]
- **Finding**: [significant/not significant]
- **Interpretation**: [what this means for Factor A in isolation]

**3. Combined Effect:**
- If Category1 vs Category3 shows larger difference than either individual factor -> synergistic
- If similar to one factor -> that factor dominates
- If no difference despite individual effects -> antagonistic
```

**Example from VGP analysis**:
- **Curation effect** (Dual vs Single): Compare Phased+Dual vs Phased+Single
- **Assembly effect** (Phased vs Pri/alt): Compare Phased+Single vs Pri/alt+Single
- **Result**: Assembly architecture dominates (8x gap density difference), curation has no effect

**Benefits**:
- Cleanly separates confounded effects
- Identifies which factor drives observed differences
- Enables mechanistic interpretation

---

## Interpreting Paradoxical or Contradictory Results

### Recognizing Paradoxes

**Pattern**: When one category performs BETTER on metric X but WORSE on related metrics Y and Z:

**Example from VGP analysis**:
- Pri/alt: HIGHER chromosome assignment (98.7%)
- Pri/alt: 8x MORE gaps, 2-3x FEWER telomeres
- **Paradox**: Higher assignment despite worse quality

### Trade-off Hypothesis Framework

When contradictory patterns emerge, consider **quality trade-offs**:

```markdown
### The Trade-off Hypothesis

The contrasting patterns suggest a fundamental **[dimension 1] vs [dimension 2] trade-off**:

**Maximize [dimension 1] ([approach A])**:
- Better on metric X
- Worse on metric Y
- Worse on metric Z
- Equivalent on metric W

**Maximize [dimension 2] ([approach B])**:
- Worse on metric X
- Better on metric Y
- Better on metric Z
- Equivalent on metric W

**Interpretation**: [Approach A] prioritizes [goal 1], while [Approach B] prioritizes [goal 2]. Neither approach is universally superior - the optimal choice depends on [application requirements].
```

**Example application**:
```markdown
**Pri/alt: Maximize chromosome assignment**
- Liberal assignment criteria
- More sequence on chromosomes
- Result: High assignment%, but chromosomes have gaps/incomplete ends

**Phased: Maximize chromosome accuracy**
- Conservative assignment criteria
- Only high-confidence sequences on chromosomes
- Result: Lower assignment%, but chromosomes are higher quality
```

**Benefits of trade-off framing**:
- Resolves apparent contradictions
- Identifies different optimization strategies
- Guides methodology selection based on priorities
- Prevents oversimplified "best method" conclusions

### Documenting Counter-Intuitive Results

When results contradict initial hypotheses:

**Documentation pattern**:
1. **State the expectation clearly**: "Dual curation was expected to improve telomere detection"
2. **Present the contradictory finding**: "Phased+Single median 34.5% vs Phased+Dual 19.5%"
3. **Acknowledge the surprise**: "Counter-intuitive finding", "Opposite to expectation"
4. **Explore mechanistic explanations**: Why might the opposite be true?
   - Reduced complexity in single curation
   - Clearer Hi-C signals
   - More focused curation effort
5. **Consider confounds**: Temporal factors, sample composition
6. **State statistical significance clearly**: p=0.213 (not significant, but trend exists)

**Example**:
```markdown
**1. Curation Method Effect (Dual vs Single): Marginal, OPPOSITE Direction**

The comparison shows **no statistically significant difference** (p = 0.213), but reveals a **surprising trend favoring single curation**:

- **Phased+Single performs better**: Median 34.5% vs 19.5% (1.8x higher)
- **Counter-intuitive finding**: This is **opposite** to the expectation that dual curation would improve telomere detection

**Mechanistic interpretation**: Why might single curation perform better?
- Reduced complexity: Curators make more conservative, accurate decisions
- Clearer Hi-C signal: Single haplotype maps show clearer terminus signals
- Temporal factors: May benefit from more recent algorithms
```

**Benefits**:
- Transparent about unexpected results
- Stimulates mechanistic thinking
- Prevents confirmation bias
- Guides future experimental design

---

## Distinguishing True Variation from Power Limitations

**Challenge**: When analyzing multiple groups (clades, populations, cohorts), how to determine if lack of effect is real or just insufficient power?

**Key Indicators of Power Limitations** (not true null effects):

1. **Sample size much smaller** than groups showing effects
   - Example: Amphibians n=28 vs Mammals n=160
   - Effect could exist but be undetectable

2. **Trend in same direction** but non-significant
   - Medians show similar pattern
   - p-value >0.05 but effect direction matches larger groups
   - Suggests real effect masked by noise

3. **Category imbalance within group**
   - One category has only 2-5 samples
   - Can't perform robust pairwise comparisons
   - Example: Amphibians Phased+Single n=2 (only 7% of clade)

4. **Wider confidence intervals** than other groups
   - Large IQR or SD relative to median
   - Indicates high variance from small sample

**Key Indicators of True Null Effect**:

1. **Large sample** with p>0.05 and narrow confidence intervals
   - Sufficient power to detect effect if present
   - Tight distribution suggests true lack of difference

2. **Opposite direction** from other groups
   - Not just non-significant, but reversed
   - Suggests biological difference is real

3. **Significant in some metrics** but not others within same group
   - Group has power (shown by significant effects elsewhere)
   - Null result more likely to be real

**Reporting Recommendations**:

For power-limited groups:
```markdown
"No significant effects detected (all p>0.13), likely reflecting
insufficient statistical power (n=55) rather than true absence of
effects. The modest sample size and relatively balanced category
distribution reduce power to detect effects observed in larger clades."
```

For true null effects:
```markdown
"Despite excellent statistical power (n=124), dual curation showed
no improvement in scaffold N50 (p=0.378), in marked contrast to
mammals (p=0.037). This suggests fundamental differences in how avian
genomes respond to curation intensity."
```

**Example from Session** (Reptiles vs Birds):
- **Reptiles** (n=55): No significant effects -> Power limitation
  - Small sample, balanced categories, trends in expected direction

- **Birds** (n=124): No N50 curation effect -> True null
  - Large sample, significant effects in OTHER metrics (gap density)
  - Biological explanation: genomes already near-optimal for N50

---

## Confounding Analysis: Technology and Temporal Effects

### Pattern: Technology Confounding in Temporal Analysis

**Problem**: Temporal trends may reflect technology adoption rather than methodology improvements

**Example from VGP assemblies:**
- Gap density shows strong improvement over time (rho = -0.54, p < 1e-40)
- But is this better assembly methods or just CLR->HiFi technology shift?

### Solution: Technology-Stratified Temporal Analysis

**Three-stage approach:**

#### Stage 1: Mixed-Technology Analysis (Baseline)
```python
# All assemblies, mixed technologies
temporal_results_mixed = []
for category in ['Method_A', 'Method_B', 'All']:
    data = df[df['category'] == category][['metric', 'year']].dropna()
    rho, pvalue = stats.spearmanr(data['year'], data['metric'])
    temporal_results_mixed.append({
        'category': category,
        'rho': rho,
        'p_value': pvalue
    })
```

#### Stage 2: Technology-Only Subset Analysis
```python
# Filter to single technology (e.g., HiFi only)
df_single_tech = df[df['technology'] == 'HiFi'].copy()

temporal_results_controlled = []
for category in ['Method_A', 'Method_B', 'All HiFi']:
    data = df_single_tech[df_single_tech['category'] == category][['metric', 'year']].dropna()
    rho, pvalue = stats.spearmanr(data['year'], data['metric'])
    temporal_results_controlled.append({
        'category': category,
        'rho': rho,
        'p_value': pvalue
    })
```

#### Stage 3: Compare Mixed vs Controlled
```python
# Identify technology artifacts vs real trends
for metric in metrics:
    mixed_row = mixed_df[mixed_df['metric'] == metric]
    controlled_row = controlled_df[controlled_df['metric'] == metric]

    delta_rho = controlled_row['rho'] - mixed_row['rho']

    # Technology artifact: significant in mixed, not in controlled
    if mixed_row['p_value'] < 0.05 and controlled_row['p_value'] >= 0.05:
        print(f"TECHNOLOGY ARTIFACT: {metric}")
        print(f"    Mixed: rho={mixed_row['rho']:.3f} (p={mixed_row['p_value']:.4e}) SIGNIFICANT")
        print(f"    Controlled: rho={controlled_row['rho']:.3f} (p={controlled_row['p_value']:.4e}) NOT SIG")

    # Real trend: significant in both or only in controlled
    elif controlled_row['p_value'] < 0.05:
        print(f"REAL TEMPORAL TREND: {metric}")
```

### Interpretation Guidelines

**Technology Artifact Indicators:**
- Trend disappears when technology is held constant
- |delta rho| > 0.15 (large change in correlation strength)
- Timeline coincides with technology adoption (e.g., 2021 CLR->HiFi shift)

**Real Temporal Trend Indicators:**
- Trend persists or strengthens in technology-controlled analysis
- Consistent direction across different technology subsets
- Gradual change rather than step-function at technology transition

### Visualization: Side-by-Side Temporal Plots

```python
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Mixed technology (with technology markers)
for tech, marker in [('HiFi', 'o'), ('CLR', 's')]:
    tech_data = df[df['technology'] == tech]
    ax1.scatter(tech_data['year'], tech_data['metric'],
                marker=marker, label=tech, alpha=0.6)
ax1.set_title('Mixed Technology (Confounded)')

# Single technology only
ax2.scatter(df_single_tech['year'], df_single_tech['metric'],
            marker='o', alpha=0.6)
ax2.set_title('HiFi Only (Controlled)')
```

### Real Example: VGP Assembly Quality (2019-2025)

**Gap Density:**
- Mixed: rho = -0.54 (p < 1e-40) - strong improvement
- HiFi-only: rho = -0.35 (p < 0.001) - weaker but still significant
- **Interpretation**: Some improvement is technology shift, but real temporal improvement exists within HiFi

**Scaffold N50:**
- Mixed: rho = +0.15 (p < 0.001)
- HiFi-only: rho = +0.18 (p < 0.01)
- **Interpretation**: Real temporal trend, not technology artifact

---

## Testing for Technology Confounding

### The Problem

In genomics and other fields where technology evolves rapidly, you may want to compare biological categories but worry that technology differences confound your comparisons.

**Example**: Comparing genome assembly curation approaches (Pri/alt+Single vs Phased+Dual), but some assemblies use HiFi sequencing (better) while others use CLR (older technology).

### Systematic Testing Approach

Use three complementary analyses to determine if pooling across technologies is justified:

#### 1. Orthogonality Test

**Question**: Does technology affect the SAME metrics as your biological variable, or different ones?

**Method**:
- Compare technologies within one biological category
- Test multiple quality metrics
- Look for selective effects

**Example**:
```python
# Within Pri/alt+Single category only
hifi_assemblies = df[(df['category'] == 'Pri/alt+Single') & (df['tech'] == 'HiFi')]
clr_assemblies = df[(df['category'] == 'Pri/alt+Single') & (df['tech'] == 'CLR')]

# Test multiple metrics
metrics = ['scaffold_n50', 'contig_n50', 'gap_density', 'gap_count']
for metric in metrics:
    result = mannwhitneyu(hifi_assemblies[metric], clr_assemblies[metric])
    print(f"{metric}: p={result.pvalue:.3e}, effect={rank_biserial(result):.2f}")
```

**Interpretation**:
- **Orthogonal**: Technology affects metric A (p<0.05), but NOT metric B (p>0.05)
  - **Conclusion**: Independent effects - can pool for analyses focused on metric B
- **Confounded**: Technology affects ALL metrics (all p<0.05)
  - **Conclusion**: Must control for technology or analyze separately

#### 2. Persistence Test (Technology-Controlled)

**Question**: Do biological category differences persist when you control for technology?

**Method**:
- Subset to single technology (e.g., HiFi-only)
- Re-test category comparisons
- Check if effects remain significant

**Example**:
```python
# HiFi-only subset
hifi_only = df[df['technology'] == 'HiFi']

# Test category differences within HiFi
from scipy.stats import kruskal
categories = ['Pri/alt+Single', 'Phased+Single', 'Phased+Dual']
groups = [hifi_only[hifi_only['category'] == cat]['contig_n50']
          for cat in categories]
result = kruskal(*groups)
print(f"Category effect in HiFi-only: H={result.statistic:.2f}, p={result.pvalue:.3e}")
```

**Interpretation**:
- **Persistent**: Category differences remain significant (p<0.05) in technology-controlled subset
  - **Conclusion**: Real biological effect, not technology artifact
- **Technology-driven**: Category differences disappear (p>0.05) when technology controlled
  - **Conclusion**: Must analyze technologies separately

#### 3. Temporal Trend Analysis

**Question**: Are temporal trends universal (suggesting technology confounding) or category-specific?

**Method**:
- Test temporal trends separately for each category
- Look for category-specific vs universal patterns

**Example**:
```python
from scipy.stats import spearmanr

for category in categories:
    subset = df[df['category'] == category]
    rho, pval = spearmanr(subset['year'], subset['quality_metric'])
    print(f"{category}: rho={rho:.2f}, p={pval:.3f}")
```

**Interpretation**:
- **Category-specific**: Only some categories show temporal trends
  - **Conclusion**: Pooling justified - trends don't confound category comparisons
- **Universal trends**: All categories improve over time
  - **Conclusion**: Must use year as covariate or analyze time periods separately

### Decision Matrix

| Orthogonality | Persistence | Temporal | Decision |
|---------------|-------------|----------|----------|
| Independent effects | Persists | Category-specific | **Pool across technologies** |
| Independent effects | Persists | Universal | Pool but use year covariate |
| Same metrics | Disappears | Universal | **Analyze technologies separately** |
| Independent effects | Disappears | - | Technology is the real driver |

### Technology Classification from Free-Text Fields

When technology is stored as free-text (e.g., "HiFi, Hifiasm Hi-C phasing"),
classify with keyword matching. Handle hybrid technologies (HiFi+ONT):

```python
def classify_tech(val):
    """Classify sequencing technology from free-text Assembly tech field."""
    if pd.isna(val) or str(val).strip() == '':
        return np.nan
    v = val.upper()
    if any(x in v for x in ['CLR', 'RSII', 'MECAT']):
        if 'ONT' in v or 'VERKKO' in v: return 'CLR+ONT'
        return 'CLR'
    elif any(x in v for x in ['HIFI', 'HIFIASM']):
        if 'ONT' in v or 'VERKKO' in v: return 'HiFi+ONT'
        return 'HiFi'
    elif 'ONT' in v or 'VERKKO' in v: return 'ONT'
    else: return 'Other: ' + val
```

**VGP dataset results** (541 assemblies): HiFi=378, CLR=141, HiFi+ONT=21, CLR+ONT=1.

**Key insight**: CLR maps almost exclusively to Pri/alt+Single (98.6%) because
CLR technology predated phased assembly methods. This is a biological constraint,
not a confounding variable.

### Reporting in Supplementary Materials

If pooling is justified, document all three analyses:

**Supplementary Figure 1**: Technology effects (orthogonality test)
**Supplementary Figure 2**: Category effects in technology-controlled subset
**Supplementary Figure 3**: Temporal trends by category
**Supplementary Discussion**: Explicitly justify pooling with three lines of evidence

### Statistical Power Consideration

Even when technology affects some metrics, pooling may be justified for statistical power:

```python
from statsmodels.stats.power import tt_ind_solve_power

# Compare power: pooled vs split
n_pooled = len(df[df['category'] == 'A'])  # e.g., 344
n_split = len(df[(df['category'] == 'A') & (df['tech'] == 'HiFi')])  # e.g., 125

effect_pooled = tt_ind_solve_power(nobs1=n_pooled, alpha=0.05, power=0.8)
effect_split = tt_ind_solve_power(nobs1=n_split, alpha=0.05, power=0.8)

print(f"Pooled (n={n_pooled}): Can detect effect size d={effect_pooled:.2f}")
print(f"Split (n={n_split}): Can detect effect size d={effect_split:.2f}")
```

If orthogonality and persistence tests pass, higher power from pooling may outweigh technology noise.
