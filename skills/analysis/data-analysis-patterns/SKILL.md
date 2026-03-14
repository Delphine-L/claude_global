---
name: data-analysis-patterns
description: Best practices for data aggregation, recalculation, and category management in scientific analyses. Covers when to recalculate vs reuse aggregated data, handling category changes, and ensuring analytical accuracy.
version: 1.0.0
context: fork
allowed-tools: Read, Grep, Glob, Bash
---

# Data Analysis Patterns

Expert guidance for making critical decisions in data analysis workflows, particularly around aggregation, recalculation, and maintaining analytical integrity.

## When to Use This Skill

- Deciding whether to recalculate from raw data vs reuse aggregated data
- Changing category definitions in existing analyses
- Ensuring accuracy in publication-quality analyses
- Handling conflated features that need separation
- Optimizing analysis pipelines without sacrificing correctness
- Merging multi-source datasets with composite keys
- Handling DataFrame type conversion issues during enrichment

## Core Patterns

### 1. Recalculating vs Reusing Aggregated Data

When you have pre-aggregated data but need different categories or groupings:
- **Recalculate from raw data** when category definitions fundamentally change, previously conflated features need separation, aggregation criteria change, or publication accuracy is critical
- **Approximation may be acceptable** for exploratory analysis, when categories align closely, or when raw data is unavailable
- **Rule**: If you can't confidently map old to new without information loss, recalculate

> For detailed patterns and code examples, see [data-manipulation-recipes.md](data-manipulation-recipes.md)

### 2. Composite Keys for Multi-Source Data Merging

When merging datasets from multiple sources, a single identifier often isn't unique enough:
- Create composite keys by concatenating multiple fields with a delimiter (`|` or `::`)
- Always verify uniqueness after creating the composite key
- Handle duplicates explicitly before merging (latest date, then most complete record)
- Remove composite key before final save (temporary working column)

> For implementation details, see [data-manipulation-recipes.md](data-manipulation-recipes.md#composite-keys-for-multi-source-data-merging)

### 3. Separating Conflated Features

When one metric combines multiple independent features, separate into independent analyses:
- Identify which features are mixed in each category
- Create separate category systems for each independent feature
- Enables clear interpretation and future independent analysis

> For examples, see [data-manipulation-recipes.md](data-manipulation-recipes.md#separating-conflated-features)

### 4. DataFrame Type Conversion During Enrichment

Type mismatches are common when enriching DataFrames from external sources:
- Check target column dtype before assignment
- Convert values to match target dtype (easier than converting whole column)
- Use helper functions to encapsulate type checking logic
- Handle NaN explicitly with `pd.notna()` checks

> For the type-safe assignment pattern and examples, see [data-manipulation-recipes.md](data-manipulation-recipes.md#dataframe-type-conversion-during-enrichment)

### 5. AWS Data Enrichment Patterns

When enriching tabular data from AWS S3 or external repositories:
- Use multi-source path resolution (direct lookup + path inference)
- Auto-detect most complete input file for idempotent re-runs
- Add columns idempotently (check before adding)
- Use TEST_MODE for initial validation before full enrichment

> For implementation patterns, see [enrichment-patterns.md](enrichment-patterns.md)

### 6. Critical Data Validation

Column names don't always match their content. Always verify against source code before using categorical columns:
- Locate source script and verify assignment logic
- Add assertions for biological plausibility
- Test with known control samples
- Document and fix any mismatches found

> For the full verification workflow and prevention checklist, see [validation-patterns.md](validation-patterns.md)

### 7. Data Provenance Verification

Derived columns may use inferior sources, causing silent data loss:
- Compare derived column coverage against likely source columns
- Cross-tabulate to verify mapping consistency
- Prefer reclassifying from rich source columns over merging sparse external files

> For diagnostic patterns, see [validation-patterns.md](validation-patterns.md#data-provenance-verifying-derived-vs-source-columns)

### 8. Organizing Analysis Text for Token Efficiency

Separate computation (notebooks) from interpretation (markdown files):
- Create `analysis_files/` directory with per-figure markdown files
- Keep notebooks for code, analysis files for interpretation
- Token reduction: 98% (1.1M tokens notebook vs 22K tokens analysis files)

> For directory structure and writing guidelines, see [analysis-organization.md](analysis-organization.md)

### 9. Multi-Factor Experimental Design Analysis

When experimental design has multiple factors:
- Use three-category design to isolate individual factor effects
- Compare pairs controlling for one factor at a time
- Identify synergistic, dominant, or antagonistic interactions

> For interpretation framework and examples, see [analysis-interpretation.md](analysis-interpretation.md)

### 10. Interpreting Paradoxical Results

When one category performs better on metric X but worse on related metrics Y and Z:
- Apply the trade-off hypothesis framework
- Document counter-intuitive results transparently
- Explore mechanistic explanations rather than dismissing findings

> For documentation patterns, see [analysis-interpretation.md](analysis-interpretation.md#interpreting-paradoxical-or-contradictory-results)

### 11. Species Name Reconciliation

When external services use different species names than your metadata:
- Classify mismatches into systematic replacements vs name variants
- Use fuzzy matching for variant detection
- Propagate corrections to ALL related files
- Version files to track correction stages

> For reconciliation workflow and code, see [species-reconciliation.md](species-reconciliation.md)

### 12. Phylogenetic Tree Coverage Analysis

Track what percentage of your phylogenetic tree has data available:
- Calculate coverage metric and identify missing species
- Categorize missing as recoverable, phylogenetic context, or unknown
- Recover Time Tree proxy replacements from deprecated datasets
- Document expected vs unexpected missing data

> For coverage analysis workflow, see [species-reconciliation.md](species-reconciliation.md#phylogenetic-tree-coverage-analysis)

### 13. Distinguishing True Variation from Power Limitations

When analyzing multiple groups, determine if lack of effect is real or insufficient power:
- **Power limitation indicators**: Small sample, trend in expected direction, category imbalance, wide CIs
- **True null indicators**: Large sample with narrow CIs, opposite direction from other groups, significant in some metrics but not others
- Report appropriately: "insufficient power" vs "no effect despite adequate power"

> For reporting recommendations and examples, see [analysis-interpretation.md](analysis-interpretation.md#distinguishing-true-variation-from-power-limitations)

### 14. Technology Confounding Analysis

Temporal trends may reflect technology adoption rather than methodology improvements:
- Use three-stage approach: mixed-technology baseline, technology-controlled subset, comparison
- Test orthogonality, persistence, and temporal patterns
- Decision matrix for whether to pool across technologies

> For the systematic testing approach, see [analysis-interpretation.md](analysis-interpretation.md#confounding-analysis-technology-and-temporal-effects)

### 15. Data Consolidation and Enrichment Workflows

When working with multiple intermediate dataset versions:
- Follow Consolidate -> Enrich -> Verify pattern
- Always rebuild filtered subsets from enriched master (don't manually merge)
- Extract accurate dates from repository filenames when release dates are unreliable

> For workflow details, see [enrichment-patterns.md](enrichment-patterns.md#data-consolidation-and-enrichment-workflows)

### 16. Data File Compression Strategies

For large data files, compress instead of delete:
- Decision tree: active (keep) / regenerable (delete) / archive (compress)
- BED/VCF/FASTA compress 70-90% with gzip
- Update scripts to read compressed files directly
- Document compression in READMEs

> For compression benchmarks and workflows, see [compression-strategies.md](compression-strategies.md)

## Key Principles

1. **Default to recalculation** when category definitions change, features were conflated, or publication accuracy is needed
2. **Document approximations** when used, and validate against subsets of recalculated data
3. **Separate conflated features** into independent analyses for clarity
4. **Always verify column names** against source code before analysis
5. **Check dtype before assignment** when enriching DataFrames
6. **Rebuild filtered subsets from master** rather than manually merging new columns
7. **Test for technology confounding** before pooling across technology generations
8. **Compress rather than delete** data files that may be needed later

## Best Practices

### Assess Information Loss
Before deciding to reuse aggregated data, check: Can you perfectly reconstruct raw data from aggregates? If NO, recalculate.

### Document Your Decision
```python
"""
Data source: scaffold_telomere_data.csv (n=6,356 scaffolds)
Recalculated: 2026-01-29
Reason: Previous aggregation conflated terminal and interstitial presence
Method: [describe categorization logic]
"""
```

### Validate Against Original if Possible
```python
original_total = df['cat1'] + df['cat2'] + df['cat3'] + df['cat4']
new_total = df['new_cat1'] + df['new_cat2'] + df['new_cat3']
assert (original_total == new_total).all(), "Category totals don't match!"
```

### Time vs Accuracy Trade-off
- **Exploration phase**: Approximations okay, clearly documented
- **Publication phase**: Always recalculate for accuracy
- **Intermediate**: Recalculate once, save results, reuse those

### Performance Considerations
Recalculation is often faster than you think:
```python
# Modern pandas on 10,000+ rows
df['new_cat'] = df.apply(categorize_func, axis=1)
result = df.groupby('species').agg({'new_cat': 'value_counts'})
# Often < 1 second
```

Optimize: use vectorized operations, filter to relevant columns, cache intermediate results.

## Supporting Files

| File | Content |
|------|---------|
| [data-manipulation-recipes.md](data-manipulation-recipes.md) | Recalculation patterns, composite keys, conflated features, type conversion |
| [enrichment-patterns.md](enrichment-patterns.md) | AWS enrichment, data consolidation, date extraction, filtered dataset rebuilding |
| [validation-patterns.md](validation-patterns.md) | Column name verification, data quality checks, data provenance |
| [analysis-interpretation.md](analysis-interpretation.md) | Multi-factor design, paradoxical results, power limitations, technology confounding |
| [species-reconciliation.md](species-reconciliation.md) | Species name reconciliation, phylogenetic tree coverage |
| [analysis-organization.md](analysis-organization.md) | Token-efficient analysis text organization, statistical results population |
| [compression-strategies.md](compression-strategies.md) | File compression decision tree, benchmarks, script updates |
