# Species Name Reconciliation and Phylogenetic Coverage

Patterns for reconciling species names across data sources and analyzing phylogenetic tree coverage.

## Species Name Reconciliation Across Data Sources

### Problem
When using external phylogenetic tree services (TimeTree, NCBI Taxonomy, etc.), species names often don't match your metadata due to:
- Database standardization
- Taxonomic updates
- Spelling variants
- OCR/data entry errors
- Trailing whitespace

### Three-Category Classification

Analyze mismatches by categorizing into:

1. **Exact matches** (already synchronized)
2. **Systematic replacements** (database standardization)
   - Example: TimeTree replacing subspecies with species names
   - Document in `species_replacements.json`
3. **Name variants** (spelling/case/whitespace)
   - Example: `Alca_torda` vs `Alca_Torda`
   - Document in `name_variant_replacements.json`

### Reconciliation Workflow

```python
# Step 1: Extract all species from tree
tree_species = set(re.findall(r'[A-Z][a-z]+_[a-z]+', tree_content))

# Step 2: Load metadata species
metadata_species = set(df['Species'].str.replace(' ', '_'))

# Step 3: Identify categories
exact_matches = tree_species & metadata_species
in_tree_only = tree_species - metadata_species
in_metadata_only = metadata_species - tree_species

# Step 4: Fuzzy match for variants
from difflib import get_close_matches
variants = {}
for tree_sp in in_tree_only:
    matches = get_close_matches(tree_sp, in_metadata_only, n=1, cutoff=0.8)
    if matches:
        variants[tree_sp] = matches[0]
```

### Critical Decision: Which Version to Keep?

**Rule of thumb**:
- Use **metadata version** when it's your authoritative source
- Exception: Remove trailing whitespace (causes file format issues)
- Document the choice in README

### Propagating Corrections

Once replacements are defined, apply to ALL related files:
```python
replacements = json.load('name_replacements.json')

files_to_update = [
    'tree.nwk',
    'annotation_dataset1.txt',
    'annotation_dataset2.txt',
    # ... all files referencing species names
]

for filepath in files_to_update:
    content = read_file(filepath)
    for old, new in replacements.items():
        content = content.replace(old, new)
    write_file(filepath.replace('.txt', '_corrected.txt'), content)
```

### Versioning Strategy

Use suffixes to track correction stages:
- `_original` - Untouched file from external source
- `_corrected` - After first round of replacements
- `_final` - After all corrections applied

This enables:
- Reproducibility
- Easy rollback if errors found
- Clear audit trail

---

## Phylogenetic Tree Coverage Analysis

### Coverage Metric Definition

When reconciling phylogenetic trees with species datasets, track coverage:

```
Coverage = (Species in both tree AND dataset) / (Total species in tree) x 100%
```

This metric indicates what percentage of the phylogenetic tree has data available for analysis.

### Identifying Missing Species

**Workflow:**

1. **Extract species from tree** (Newick format):
```python
import re
with open('Tree_final.nwk', 'r') as f:
    tree_content = f.read()
# Extract species names (underscored format)
tree_species = set(re.findall(r'([A-Z][a-z]+_[a-z]+)', tree_content))
```

2. **Extract species from dataset**:
```python
import pandas as pd
df = pd.read_csv('species_methods.csv')
dataset_species = set(df['Species'].str.replace(' ', '_'))
```

3. **Calculate coverage**:
```python
matched_species = tree_species & dataset_species
missing_from_dataset = tree_species - dataset_species
coverage_pct = (len(matched_species) / len(tree_species)) * 100

print(f"Coverage: {len(matched_species)}/{len(tree_species)} ({coverage_pct:.1f}%)")
print(f"Missing: {len(missing_from_dataset)} species")
```

### Categorizing Missing Species

Not all missing species are equal. Categorize them:

1. **Recoverable from data**:
   - Time Tree replacements (proxy species used)
   - Species in deprecated datasets
   - Species with different naming conventions

2. **Phylogenetic context only**:
   - Species added by tree builder for phylogenetic completeness
   - Reference species for temporal calibration
   - Not in your study scope

3. **Unknown/Uncategorizable**:
   - Species in dataset but cannot classify with current criteria
   - May need different analysis approach

### Recovery Workflow for Time Tree Replacements

**Problem**: Time Tree uses proxy species when exact species lacks data.

**Example**:
- Tree contains: `Anniella_pulchra` (proxy with available phylogenetic data)
- Dataset contains: `Anniella_stebbinsi` (actual species being studied)

**Solution**:

1. **Document replacements** in `species_replacements.json`:
```json
{
  "actual_species_name": "tree_proxy_name",
  "Anniella_stebbinsi": "Anniella_pulchra",
  "Pelomedusa_somalica": "Pelomedusa_subrufa"
}
```

2. **Check for actual species** in deprecated datasets:
```python
import json
replacements = json.load(open('species_replacements.json'))

for actual_sp, tree_sp in replacements.items():
    if tree_sp in missing_from_dataset:
        # Check deprecated datasets for actual_sp
        matches = df_deprecated[df_deprecated['Species'] == actual_sp.replace('_', ' ')]
        if not matches.empty:
            print(f"Found {actual_sp} in deprecated data - can recover!")
```

3. **Update tree to use actual names**:
```python
# Replace proxy names with actual species names in tree file
tree_content_updated = tree_content
for actual_sp, tree_sp in replacements.items():
    tree_content_updated = tree_content_updated.replace(tree_sp, actual_sp)

with open('Tree_final.nwk', 'w') as f:
    f.write(tree_content_updated)
```

4. **Synchronize all annotation files** with the updated names.

### Acceptable Coverage Levels

**Guidelines for phylogenetic analysis:**
- **100%**: Ideal, all tree species have data
- **99%+**: Excellent, few phylogenetic context species only
- **95-99%**: Good, some context species expected
- **<95%**: Investigate for recovery opportunities

**Interpretation:**
- Missing 1-3 species at 99%+ often represents phylogenetic context species
- These are acceptable and expected when tree includes reference taxa
- Focus recovery efforts on species that should have data

### Example Recovery Impact

**Case study from VGP analysis:**
- Initial coverage: 506/511 species (99.0%)
- Identified 2 Time Tree replacement species
- Recovered from deprecated datasets
- Updated tree with actual VGP species names
- Final coverage: 508/511 (99.4%)
- Remaining 3: Phylogenetic context species (acceptable)

**Outcome**: Improved coverage by identifying and correcting Time Tree proxy usage.

### Best Practices

1. **Always check for Time Tree replacements** when coverage < 100%
2. **Document all replacements** in JSON for reproducibility
3. **Update tree file** to match dataset (not the reverse)
4. **Synchronize ALL config files** after tree updates
5. **Accept phylogenetic context species** as valid missing data
6. **Track coverage metrics** throughout analysis

### Integration with Species Name Reconciliation

This coverage analysis complements the species name reconciliation section above:
- Reconciliation fixes name variants and spellings
- Coverage analysis identifies true missing species vs naming issues
- Together they ensure maximal tree-dataset alignment

### Handling Expected Missing Data in Phylogenetic Context

**Critical distinction**: Not all tree species should have data - phylogenetic context species are expected and acceptable.

**Expected missing data (OK)**:
- Species included in tree for phylogenetic structure
- No experimental/assembly data available
- Typically 5-15% of tree species
- **Action**: Document clearly, mention in figure captions

**Unexpected missing data (Investigate)**:
- Species should have data but field is empty
- Case sensitivity mismatches
- Data format incompatibilities
- **Action**: Debug and fix

**Example: VGP Tree Coverage**

**Setup**:
- Tree: 508 species total
- VGP assemblies: 446 species (87.8%)
- Phylogenetic context: 62 species (12.2%)

**Validation pattern**:
```python
# Merge tree species with dataset
merged = tree_species.merge(dataset, on='species_tree', how='left')

# Classify missing data
with_data = merged['assembly_id'].notna().sum()
phylo_context = merged['assembly_id'].isna().sum()

print(f"Species with data: {with_data} ({100*with_data/len(merged):.1f}%)")
print(f"Phylogenetic context: {phylo_context} ({100*phylo_context/len(merged):.1f}%)")

# List context species for documentation
context_species = merged[merged['assembly_id'].isna()]['species_tree'].tolist()
```

**Documentation template**:
```markdown
## Data Coverage

Total species in phylogenetic tree: 508
- With VGP assembly data: 446 (87.8%)
- Phylogenetic context only: 62 (12.2%)

Phylogenetic context species include: [list 3-5 examples], and 57 others.
These species provide phylogenetic structure but lack VGP assemblies.
```

**Figure caption note**:
> "Tree shows 508 vertebrate species; 446 (87.8%) have VGP assembly data.
> Species without annotations represent phylogenetic context."

**Why this matters**:
- Prevents unnecessary debugging of "missing" data that should be missing
- Clarifies data completeness expectations in manuscripts
- Distinguishes data quality issues from study design choices
