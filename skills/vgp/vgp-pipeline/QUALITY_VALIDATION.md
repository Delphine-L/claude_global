# VGP Pipeline - Quality Validation & Curation

> Supporting file for [SKILL.md](SKILL.md)

## Curation Impact Analysis - Comparing Methods

### Data Filtering for Fair Comparison
When comparing Dual vs Pri/alt curation:

```python
def load_data():
    df = pd.read_csv(DATA_FILE)

    # Create curation type column
    df['curation_type'] = 'None'
    df.loc[df['Dual'] == 'Y', 'curation_type'] = 'Dual'
    df.loc[df['Pri/alt'] == 'Y', 'curation_type'] = 'Pri/alt'

    # Filter to assemblies with accessions only
    df = df[df['accession'].notna()].copy()

    # EXPLICITLY exclude uncurated assemblies
    df = df[df['curation_type'].isin(['Dual', 'Pri/alt'])].copy()

    # Verify no "None" remain
    none_count = (df['curation_type'] == 'None').sum()
    if none_count > 0:
        print(f"WARNING: {none_count} uncurated assemblies found!")

    return df
```

### Quality Metrics Focus
**Include**: Post-curation quality metrics
- Scaffold N50, L50, L90
- Gap percentage, scaffold count
- Chromosome-level status
- Assembly size accuracy
- Derived metrics (efficiency ratios, concentration scores)

**Exclude**: Genome characteristics
- Heterozygosity, repeat content (intrinsic properties)
- Contig-based metrics (pre-curation)

### Statistical Testing Pattern
Use non-parametric methods for non-normal distributions:
- **Continuous metrics**: Mann-Whitney U test
- **Categorical metrics**: Chi-square test (or Fisher's exact if n<5)
- **Handle failures gracefully**:
  ```python
  try:
      chi2, pval, dof, expected = stats.chi2_contingency(table)
      stats_text = f'p = {pval:.3e}'
  except ValueError:
      stats_text = 'N/A (insufficient variation)'
  ```

### Missing Data Handling
Always check for data availability before plotting:
```python
if len(data_dual) == 0 or len(data_prialt) == 0:
    ax.text(0.5, 0.5, 'Insufficient data available',
           transform=ax.transAxes, ha='center', va='center')
    return
```

This prevents crashes when metrics like QV are sparsely populated.

### Incremental Script Development

When building analysis scripts with many (10+) plotting functions:

1. **Start with core functions** (01-06): Basic metrics
2. **Add advanced functions** (07-11): Computed metrics
3. **Test incrementally** - Run after each batch
4. **Update main() function** to call new plots
5. **Update summary statistics** in output

**Critical**: Always update main() when adding new functions:
```python
def main():
    df = load_data()

    # Basic metrics (01-06)
    plot_metric_1(df)
    plot_metric_2(df)

    # NEW: Advanced metrics (07-08)  <- Add these
    plot_metric_7(df)
    plot_metric_8(df)

    # Update count in summary
    print(f"Generated {8} figures")  # <- Update count
```

Forgetting to call new functions means they're defined but never executed.

## Data Quality Validation and Filtering

### GenomeScope Data Validation

**Critical Issue**: VGP Phase 1 dataset contains placeholder values where `genome_size_genomescope == total_length` (assembly size copied into GenomeScope column).

**Detection and Filtering**:
```python
# Filter out fake GenomeScope values
df_filtered = df[(df['total_length'].notna()) &
                 (df['genome_size_genomescope'].notna()) &
                 (df['genome_size_genomescope'] != df['total_length'])].copy()

# Report filtering statistics
n_total = len(df[df['genome_size_genomescope'].notna()])
n_fake = len(df[(df['genome_size_genomescope'].notna()) &
                (df['genome_size_genomescope'] == df['total_length'])])
n_real = len(df_filtered)

print(f"Total with GenomeScope: {n_total}")
print(f"Fake (copied): {n_fake} ({n_fake/n_total*100:.1f}%)")
print(f"Real estimates: {n_real} ({n_real/n_total*100:.1f}%)")
```

**Impact**: In VGP Phase 1, 396/545 (72.7%) GenomeScope values were fake, leaving only 149 (27.3%) real independent estimates.

**Visual Detection**: Scatter plots showing all points on diagonal (assembly = expected) indicate circular data.

**Best Practice**: Always validate that "expected" genome size values are independent from assembly size before comparative analysis.

## Assembly Size vs Expected Genome Size Interpretation

### Common Pattern: Assemblies ~12% Larger Than Expected

**Typical Statistics** (from real VGP data, n=149):
- Mean ratio (assembly/expected): 1.116
- Median ratio: 1.077
- Within +/-10%: ~58%
- Within +/-20%: ~88%

**Why Assemblies Are Larger**:
1. **Incomplete haplotig purging**: Haplotype-specific sequences retained in primary
2. **GenomeScope underestimation**: High heterozygosity/repeats affect k-mer frequencies
3. **Organellar DNA**: Mitochondrial genomes (~15-20kb) assembled and included

**Interpretation**:
- Ratio 1.0-1.2: Normal, good assembly
- Ratio > 1.3: Possible retained duplications, check purge_dups metrics
- Ratio < 0.9: Possible missing sequence, check coverage

**Not a Quality Problem**: Moderate scatter (std dev ~30%) reflects biological variation and k-mer estimation limitations, not assembly quality issues.

## Communication Patterns

### File Path Confirmation

When modifying files, especially when multiple similar files exist:

1. **Always state the FULL path** when making edits:
   ```
   Bad: "Updating the notebook..."
   Good: "Updating /path/to/Stats_workflow_run/vgp_workflow_resource_analysis.ipynb"
   ```

2. **Ask for clarification** if multiple candidates exist:
   ```
   Found two notebooks:
   1. /path/to/Stats_workflow_run/vgp_workflow_resource_analysis.ipynb
   2. /path/to/Stats_workflow_run/sharing/vgp_workflow_resource_analysis.ipynb

   Which one are you running?
   ```

3. **After user correction**, explicitly confirm:
   ```
   Confirmed: Now modifying the correct file at /path/to/correct/file
   ```

### User Feedback Interpretation

When user says "the outlier is still there":
1. **Don't assume code is wrong** - may be running different file
2. **Don't assume user error** - may be our mistake
3. **Verify the file path** immediately
4. **Check if changes were applied** to the file user is actually running

This pattern prevents major errors where edits are applied to the wrong file for multiple iterations.
