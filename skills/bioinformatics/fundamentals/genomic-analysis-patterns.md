# Genomic Analysis Patterns

Domain-specific patterns for karyotype data curation, chromosome count analysis, phylogenetic tree mapping, telomere classification, and NCBI data integration.

---

## Karyotype Data Curation and Literature Search

### Overview

Karyotype data (diploid 2n and haploid n chromosome numbers) is critical for genome assembly validation but rarely available via APIs. Manual literature curation is required.

### Search Strategy

#### Effective Search Terms
```
"{species_name} karyotype chromosome 2n"
"{species_name} diploid number karyotype"
"{genus} karyotype evolution"
"cytogenetic analysis {family_name}"
"{species_name} chromosome number diploid"
```

#### Best Reference Sources
1. **PubMed/PMC**: Primary cytogenetic studies
2. **ResearchGate**: Karyotype descriptions and figures
3. **Specialized databases**:
   - Bird Chromosome Database: https://sites.unipampa.edu.br/birdchromosomedatabase/
   - Animal Genome Size Database: http://www.genomesize.com/
4. **Genome assembly papers**: Often mention expected karyotype
5. **Comparative cytogenetic studies**: Family-level analyses

#### Search Time Estimates
- **Model organisms, domestic species**: 2-3 minutes
- **Well-studied taxonomic groups**: 5-10 minutes
- **Rare/uncommon species**: 10-20 minutes or not found

### Taxonomic Conservation Patterns

#### Mammals
- **Cetaceans**: Highly conserved 2n = 44, n = 22 (exceptions: pygmy sperm whale, right whale, beaked whales = 2n = 42)
- **Felidae**: Conserved 2n = 38, n = 19
- **Canidae**: Conserved 2n = 78, n = 39
- **Primates**: Variable (great apes 2n = 48, macaques 2n = 42, marmosets 2n = 46)

#### Birds
- **Anatidae (waterfowl)**: Highly conserved 2n = 80, n = 40 across ducks, geese, swans
- **Galliformes (game birds)**: Typically 2n = 78, n = 39 (chicken, quail, grouse)
- **Passerines**: Variable 2n = 78-82, most common 2n = 80
- **Ancestral avian karyotype**: Putative 2n = 80
- **General pattern**: 50.7% of birds have 2n = 78-82; 21.7% have exactly 2n = 80

#### Reptiles
- **Lacertidae (wall lizards)**: Often 2n = 38, n = 19

### Genome Assembly Interpretation

**Warning**: Chromosome-level assemblies often report fewer chromosomes than actual diploid number.

**Why**: Assemblies typically capture only:
- Macrochromosomes (large chromosomes)
- Larger microchromosomes
- Small microchromosomes remain unassembled

**Example**: Waterfowl with 2n = 80 often have genome assemblies with 34-42 "chromosomes"
- True karyotype: 10 macro pairs + 30 micro pairs = 80
- Assembly: ~34-42 scaffolds (only macro + larger micros)

### Using Conservation for Inference

When specific karyotype data is unavailable but genus/family patterns are strong:

1. **High confidence inference** (acceptable for publication):
   - Multiple congeneric species confirmed
   - Family-level conservation documented
   - No known exceptions in genus

2. **Document inference clearly**:
   ```csv
   accession,taxid,species,2n,n,notes,reference
   GCA_XXX,123,Species name,80,40,Inferred from Anatidae conservation,https://family-level-study.url
   ```

3. **Priority for direct confirmation**:
   - Species with conservation exceptions
   - Type specimens or reference species
   - Phylogenetically divergent lineages

### VGP-Specific: Sex Chromosome Adjustment

When both sex chromosomes are in main haplotype (common in VGP assemblies):
- **Expected scaffolds = n + 1** (not n)
- **Reason**: X+Y or Z+W = two distinct chromosomes
- **Check**: VGP metadata column "Sex chromosomes main haplotype"
- **Patterns**: "Has X and Y", "Has Z and W", "Has X1, X2, and Y"

### Data Recording Format

**CSV Structure**:
```csv
accession,taxid,species_name,diploid_2n,haploid_n,notes,reference
GCA_XXXXXX,12345,Species name,80,40,Brief description,https://doi.org/...
```

**Notes field examples**:
- "Standard {family} karyotype"
- "Conserved {genus} karyotype"
- "Inferred from {family} conservation"
- "Unusual karyotype for family"
- "Geographic variation reported"

### Prioritization for Literature Searches

**TIER 1** (>90% success rate):
- Model organisms (zebrafish, mouse, medaka)
- Domestic species (chicken, goat, sheep)
- Game animals (waterfowl, deer)
- Laboratory species (fruit fly, nematode)

**TIER 2** (70-90% success rate):
- Well-studied taxonomic groups (Podarcis lizards, corvids)
- Conservation focus species (raptors, large mammals)
- Commercial species (salmonids, oysters)

**TIER 3** (50-70% success rate):
- Common but not economically important
- Widespread distribution
- Recent phylogenetic interest

**Low priority** (<50% success rate):
- Deep-sea species
- Rare/endangered without conservation genetics
- Recently described species
- Cryptic species complexes

---

## Haploid vs Diploid Chromosome Counts in Assembly Analysis

### The Critical Distinction

Genome assembly metadata typically includes **both** haploid and diploid chromosome counts:

- **Haploid count (n)**: Number of chromosomes in a single genome copy
  - Example: Human n=23 (22 autosomes + X or Y)
  - Represents unique chromosome types
- **Diploid count (2n)**: Number of chromosomes in diploid organism
  - Example: Human 2n=46 (23 pairs)
  - Represents total chromosomes in a diploid cell

### Common Dataset Column Names

```python
# Typical column names (exact names vary by dataset):
df['num_chromosomes']               # Often diploid (2n)
df['total_number_of_chromosomes']   # Often haploid (n)
df['karyotype']                     # Usually haploid (n)
df['num_chromosomes_haploid_adjusted']  # Haploid with sex chr adjustment
```

**WARNING**: Column names are NOT standardized across datasets - always verify which is which!

### Which Count to Use When

**Use HAPLOID (n) for:**
- Per-assembly comparisons (scaffolds per assembly)
- Chromosome assignment ratios
- Expected vs observed chromosome counts
- Telomere counts (2 per chromosome x n chromosomes)
- Scaffold-to-chromosome mapping

**Use DIPLOID (2n) for:**
- Cell-level comparisons
- Comparing to diploid karyotypes
- Ploidy analyses
- Cytogenetic studies

### Real-World Example: VGP Assembly Analysis

**Problem**: Used `num_chromosomes` (diploid) for per-assembly comparison

**Result**: All assemblies appeared to have 2x expected chromosomes

**Fix**: Changed to `total_number_of_chromosomes` (haploid)

**Validation**: Ratio now ~1.0 instead of ~2.0

```python
# WRONG - uses diploid count
fig, ax = plt.subplots()
ax.scatter(df['num_chromosomes'], df['num_scaffolds_assigned'])
# Result: Everything appears at 2x diagonal

# CORRECT - uses haploid count
fig, ax = plt.subplots()
ax.scatter(df['total_number_of_chromosomes'], df['num_scaffolds_assigned'])
# Result: Expected 1:1 diagonal relationship
```

### Sex Chromosome Adjustments

Some species have different haploid counts by sex:

- **Male XY systems**: n = autosomes + 2 (X and Y count separately)
- **Female XX systems**: n = autosomes + 1 (both X chromosomes count as one type)
- **For telomere counts**: Male XY may need +1 adjustment (X and Y both have telomeres)

**Check for adjusted counts:**
```python
# Some datasets provide sex-adjusted haploid counts
# Example: Human male
# Karyotype n = 23 (22 autosomes + X or Y)
# But for telomere counting: 24 (22 autosomes + X + Y both have telomeres)

df['num_chromosomes_haploid_adjusted']  # May add +1 for male XY
```

### Validation Checks

```python
# Check if counts are haploid or diploid by testing known species
human_samples = df[df['species'] == 'Homo sapiens']
median_count = human_samples['column_name'].median()

if median_count > 40:
    print("Likely diploid (2n) - expect ~46 for humans")
elif median_count > 20:
    print("Likely haploid (n) - expect ~23 for humans")
else:
    print("Check data - values unexpectedly low")

# Verify ratios make biological sense
df['ratio'] = df['scaffolds_assigned'] / df['haploid_count']
assert 0.5 < df['ratio'].median() < 2.0, "Ratio should be near 1.0 for good assemblies"

# Check for systematic doubling
if df['ratio'].median() > 1.8:
    print("WARNING: May be using diploid count - ratios systematically doubled")
```

### Common Pitfalls

1. **Assuming column names are accurate**
   - `num_chromosomes` could be either n or 2n
   - Always validate with known species

2. **Not accounting for sex chromosomes**
   - Male XY vs Female XX can have different expected counts
   - Telomere analyses need special handling

3. **Mixing haploid and diploid across analyses**
   - Be consistent within each analysis
   - Document which count you're using

4. **Forgetting about polyploids**
   - Some species are naturally 3n, 4n, 6n, 8n
   - Check literature for ploidy level

### Key Takeaways

1. **Always verify** which count (n or 2n) a column contains
2. **Don't trust column names** - validate with known species
3. **Use haploid (n)** for per-assembly metrics
4. **Add validation checks** to catch errors early
5. **Document which count** you're using in code comments
6. **Account for sex chromosomes** when relevant

---

## Phylogenetic Tree Species Mapping

### Time Tree Species Replacement

Time Tree databases sometimes use proxy/replacement species when they don't have phylogenetic data for the exact species needed. This creates a mismatch between tree species names and dataset species names.

**Pattern:**
- Tree contains: Anniella_pulchra (proxy species with available data)
- Dataset contains: Anniella_stebbinsi (actual species being studied)
- Time Tree selected Anniella_pulchra as closest relative with data

**Solution Workflow:**

1. **Document replacements** in `species_replacements.json`:
```json
{
  "actual_species_name": "tree_proxy_name",
  "Anniella_stebbinsi": "Anniella_pulchra",
  "Pelomedusa_somalica": "Pelomedusa_subrufa"
}
```

2. **Update tree file** to use actual dataset names:
   - Read Newick tree file
   - Replace proxy names with actual species names
   - Ensures tree matches dataset exactly

3. **Synchronize all config files** using actual names:
   - iTOL colorstrip configs
   - Label configs
   - Any taxonomic annotation files

4. **Recover missing data** if needed:
   - Check deprecated datasets for actual species
   - Proxy species indicates actual species likely exists in data
   - Add to current dataset after recovery

**Why This Matters:**
- Prevents "missing species" that actually exist in dataset
- Ensures tree and dataset species names match exactly
- Required for iTOL visualization configs to work correctly
- Improves tree coverage metrics (e.g., 506->508 species)

**Common Files Needing Synchronization:**
- `Tree_final.nwk` - Main phylogenetic tree
- `itol_taxonomic_colorstrip_final.txt` - Taxonomic annotations
- `species_*_methods.csv` - Species classification configs
- All iTOL visualization config files

### Tree Coverage Analysis Pattern

When reconciling phylogenetic trees with species datasets:

**Coverage Metric:**
```
Coverage = (Species in both tree AND dataset) / (Total species in tree) x 100%
```

**Identifying Missing Species:**

1. **Extract species from tree** (Newick format):
```python
with open('Tree_final.nwk', 'r') as f:
    tree_content = f.read()
# Extract species names (underscored format)
tree_species = set(re.findall(r'([A-Z][a-z]+_[a-z]+)', tree_content))
```

2. **Extract species from dataset**:
```python
df = pd.read_csv('species_methods.csv')
dataset_species = set(df['Species'].str.replace(' ', '_'))
```

3. **Find missing species**:
```python
missing = tree_species - dataset_species
```

4. **Categorize missing species**:
   - **Recoverable**: Time Tree replacements or in deprecated datasets
   - **Phylogenetic context**: Tree-only species for evolutionary context
   - **Unknown curation**: In dataset but cannot classify

**Recovery Workflow:**

```python
# Check if missing species are Time Tree replacements
replacements = json.load(open('species_replacements.json'))
for species in missing:
    tree_name = species.replace('_', ' ')
    if tree_name in replacements.values():
        actual_name = [k for k,v in replacements.items() if v==tree_name][0]
        # Search deprecated datasets for actual_name
        # Recover and add to current dataset
```

**Acceptable Coverage Levels:**
- **100%**: Ideal, all tree species have data
- **99%+**: Excellent, few phylogenetic context species
- **95-99%**: Good, some context species expected
- **<95%**: Investigate missing species for recovery opportunities

**Example Results:**
- Initial: 506/511 species (99.0%)
- After Time Tree mapping: 508/511 (99.4%)
- Remaining 3: Phylogenetic context only (acceptable)

---

## BED File Processing and Telomere Analysis

### Pattern: Classifying Scaffolds by Telomere Types

When analyzing telomere data from BED files to classify scaffolds:

**File Structure**:
- Terminal telomeres BED: columns include scaffold, start, end, orientation (p/q), accession
- Interstitial telomeres BED: similar structure with position markers (p/q/u for internal)

**Best Practice - Use Python CSV Module**:
```python
import csv
from collections import defaultdict

# Use defaultdict for automatic initialization
telomere_counts = defaultdict(lambda: {'terminal': 0, 'interstitial': 0})

# Process with csv.reader (more portable than pandas)
with open('telomeres.bed', 'r') as f:
    reader = csv.reader(f, delimiter='\t')
    for row in reader:
        scaffold = row[0]
        accession = row[10]  # GCA accession
        key = (accession, scaffold)
        telomere_counts[key]['terminal'] += 1
```

**Why CSV over pandas**:
- No external dependencies (pandas may not be installed)
- Faster for simple tabular operations
- Lower memory footprint for large files
- Better portability across environments

**Classification Categories**:
1. Category 1: 2 terminal telomeres, 0 interstitial (complete chromosomes)
2. Category 2: 1 terminal telomere, 0 interstitial (partial)
3. Category 3: Has interstitial telomeres (likely assembly issues)

---

## NCBI Data Integration Strategies

### Check Existing Data Sources Before API Calls

**Problem**: Need chromosome counts for 400+ assemblies from NCBI.

**Anti-pattern**: Query NCBI datasets API for each accession
```python
# DON'T: Query 400+ times
for accession in missing_data:
    result = subprocess.run(['datasets', 'summary', 'genome', 'accession', accession])
    # Takes 10+ minutes, hits API rate limits
```

**Better Pattern**: Check if data already exists in compiled tables
```python
# DO: Look for existing compiled data first
# VGP table has multiple chromosome count columns:
# - num_chromosomes (column 54)
# - total_number_of_chromosomes (column 106)
# - num_chromosomes_haploid (column 122)

# Read from existing comprehensive table
with open('VGP-table.csv') as f:
    reader = csv.reader(f)
    header = next(reader)
    for row in reader:
        num_chr = row[53] if row[53] else row[105]  # Fallback strategy
```

**Results**: Filled 392/417 missing values instantly vs 10+ minutes of API calls.

**Fallback Strategy for Multiple Columns**:
```python
# Try multiple sources in order of preference
num_chromosomes = row[53] if (len(row) > 53 and row[53]) else ''
if not num_chromosomes and len(row) > 105:
    num_chromosomes = row[105]  # Alternative column
```

**When to use NCBI API**:
- Data not in existing tables
- Need real-time/latest data
- Fetching assembly reports or sequence data
- Small number of queries (<20)

**API Best Practices** (when necessary):
- Use full path to datasets command (may be aliased)
- Add delays between calls (`time.sleep(0.5)`)
- Set reasonable timeouts
- Handle errors gracefully
