# VGP Assembly Pipeline Skill

## Overview
The Vertebrate Genome Project (VGP) assembly pipeline consists of Galaxy workflows for producing high-quality, phased, chromosome-level genome assemblies. This skill covers workflow selection, execution patterns, and quality control checkpoints.

## Trajectories (by frequency of use)

### Trajectory A: HiFi + Hi-C (Most Common)
- **Inputs**: HiFi Reads, Hi-C Reads
- **Path**: WF1 → WF4 → [WF6] → WF8 → WF9 → PreCuration
- **Output**: HiC Phased assembly (hap1/hap2)
- **WF6**: Optional (can skip directly to WF8)

### Trajectory B: HiFi + Trio
- **Inputs**: HiFi Reads, Hi-C Reads, Parental Reads
- **Path**: WF2 → WF5 → [WF6] → WF8 → WF9 → PreCuration
- **Output**: Trio Phased assembly (maternal/paternal)
- **WF6**: Optional (can skip directly to WF8)

### Trajectory C: HiFi Only (Least Common)
- **Inputs**: HiFi Reads only
- **Path**: WF1 → WF3 → WF6 → WF9 → PreCuration
- **Output**: Pseudohaplotype assembly (primary/alternate)
- **WF6**: **Required** (no Hi-C scaffolding step)
- **Note**: Skips WF8 entirely

## Workflow Selection by Data Availability

### Non-trio workflows (HiFi reads only)
- **VGP1 (WF1)**: K-mer profiling with HiFi reads alone
- **VGP3 (WF3)**: HiFi-only assembly with HiFiasm

### Trio workflows (HiFi + Parental Illumina)
- **VGP2 (WF2)**: Trio k-mer profiling (HiFi child + Illumina parents)
- **VGP5 (WF5)**: Trio-phased assembly with HiFiasm

### Universal scaffolding workflows
- **RagTag scaffolding**: Used for both trio and non-trio assemblies
- Requires reference genome specification

### Methods language pattern
When documenting workflow selection in publications:
```
"For species with available parental data (trio datasets), we employed
VGP2 → VGP5 workflows. For species without parental data (non-trio datasets),
we performed VGP1 → VGP3 workflows."
```

## Workflow Descriptions

| Workflow | Name | Description |
|----------|------|-------------|
| WF0 | Mitochondrial Assembly | MitoHiFi assembly (runs in parallel, may fail if no mito reads) |
| WF1 | K-mer Profiling | Genome size, heterozygosity estimation (HiFi) |
| WF2 | Trio K-mer Profiling | K-mer profiling with parental data |
| WF3 | Hifiasm | HiFi-only assembly |
| WF4 | Hifiasm + HiC | HiC-phased assembly |
| WF5 | Hifiasm Trio | Trio-phased assembly |
| WF6 | Purge Duplicates | Remove haplotypic duplications |
| ~~WF7~~ | ~~Bionano~~ | **Deprecated - no longer used** |
| WF8 | Hi-C Scaffolding | YAHS chromosome scaffolding |
| WF9 | Decontamination | Remove contaminants |
| PreCuration | Pretext Snapshot | Prepare files for manual curation |

## Haplotype Execution Patterns

### Run Once (Both Haplotypes Together)
- WF1, WF2 (K-mer profiling)
- WF3, WF4, WF5 (Assembly)
- WF6 (Purge Duplicates) - *depends on trajectory*
- PreCuration

### Run Twice (×2 per Haplotype)
- WF8 (Hi-C Scaffolding)
- WF9 (Decontamination)

## WF6 (Purge Duplicates) Decision Logic

```
if trajectory == "C" (HiFi only):
    WF6 is REQUIRED
    WF6 border: solid
else:  # Trajectory A or B
    WF6 is OPTIONAL
    WF6 border: dashed
    Can skip directly to WF8
```

**When to skip WF6 (Trajectories A/B):**
- Merqury k-mer spectra shows clean haplotype separation
- Assembly QV is already high
- No significant duplication detected

**When to run WF6 (Trajectories A/B):**
- K-mer spectra shows residual duplications
- Higher heterozygosity samples
- Conservative approach preferred

## Coverage Requirements

| Data Type | Minimum Coverage | Notes |
|-----------|------------------|-------|
| HiFi | 30× | Diploid genome |
| Hi-C | 60× | Diploid genome |

## QC Checkpoints

### After WF1/WF2 (K-mer Profiling)
- Verify GenomeScope2 model fit
- Check estimated genome size
- Review heterozygosity estimate

### After WF4/WF5 (Assembly)
- Inspect Merqury k-mer spectra
- Decide whether to run WF6 based on duplication levels

### After WF8 (Hi-C Scaffolding)
- Check Pretext Hi-C contact maps
- Verify chromosome-level scaffolding
- **Validate against expected karyotype** (see Karyotype Validation below)

### After WF9 (Decontamination)
- Review contamination reports
- Check for unexpected removals

## Karyotype-Based Scaffold Validation

### Sex Chromosome Adjustment

**Problem**: VGP assemblies often place both sex chromosomes (X+Y or Z+W) in the main haplotype, requiring adjustment to expected chromosome counts.

**Solution**: When both sex chromosomes present, expected = n + 1 (not n)

**Implementation**:
```python
# Adjust haploid expected when BOTH sex chromosomes in main haplotype
df['num_chromosomes_haploid_adjusted'] = df['num_chromosomes_haploid'].copy()

both_sex_chr_patterns = [
    'Has X and Y',
    'Has Z and W',
    'has Z and W',
    'Has X1, X2, and Y',
    'Has Z1, Z2, and W',
    'Has 5X and 5Y'
]

if 'Sex chromosomes main haploptype' in df.columns:
    has_both_sex = df['Sex chromosomes main haploptype'].isin(both_sex_chr_patterns)
    df.loc[has_both_sex & df['num_chromosomes_haploid'].notna(),
           'num_chromosomes_haploid_adjusted'] = \
        df.loc[has_both_sex & df['num_chromosomes_haploid'].notna(),
              'num_chromosomes_haploid'] + 1
```

**Biological Reasoning**:
- Diploid organisms have two sex chromosomes (XX, XY, ZZ, ZW)
- X and Y (or Z and W) are distinct chromosomes
- If both in main haplotype → two separate scaffolds expected
- Example: Asian elephant 2n=56, n=28, has X+Y → expect 29 scaffolds

**Impact**: Improved perfect match rate from 0% to ~90% in validation analyses

**Validation Metrics**:
```python
# Use adjusted counts for validation
achieved = df['total_number_of_chromosomes']
expected = df['num_chromosomes_haploid_adjusted']

perfect_matches = (achieved == expected).sum()
within_1 = ((achieved - expected).abs() <= 1).sum()
ratio = achieved / expected
```

### Common Pitfalls

**❌ Wrong**: Compare diploid expected (2n) to haploid assembly
- Results in ~50% achievement rates
- Biologically incorrect

**❌ Wrong**: Use haploid (n) when both sex chromosomes present
- Underestimates by 1
- Shows artificial "extra scaffold" problem

**✅ Correct**: Use adjusted haploid (n or n+1 depending on sex chromosome configuration)

## WF0 (Mitochondrial) Handling

WF0 runs in parallel with the main pipeline and may fail if:
- No mitochondrial reads present in HiFi data
- This is a **biological** failure, not technical

```python
def check_mitohifi_failure(wf0_result):
    """Distinguish biological vs technical failure"""
    if "no_mito_reads" in wf0_result.log:
        return "biological"  # Expected for some samples
    else:
        return "technical"   # Investigate further
```

## Visual Diagram Elements

When creating workflow diagrams:

### Color Coding (Suggested)
- K-mer Profiling section: Orange (`#fff3e0`)
- Assembly section: Green (`#e8f5e9`)
- Purging section: Purple (`#f3e5f5`)
- Scaffolding section: Blue (`#e3f2fd`)
- Finishing section: Green (`#e8f5e9`)
- WF0 (Mitochondrial): Pink (`#fce4ec`)

### Visual Indicators
- **Solid lines**: Required workflow connections
- **Dashed lines**: Optional skip paths
- **Dashed box border**: Optional workflow (WF6 in trajectories A/B)
- **Solid box border**: Required workflow
- **Dimmed elements**: Workflows not used in current trajectory

### Haplotype Badges
- Blue badge (`#e3f2fd`): "×2 per haplotype" - runs separately
- Green badge (`#e8f5e9`): "both haplotypes" - runs together

## Input Data Labels
- HiFi Reads: Blue (`#4285f4`)
- Hi-C Reads: Green (`#34a853`)
- Parental Reads: Red (`#ea4335`)

## Summary Table

| Trajectory | Inputs | K-mer | Assembly | Purge | Scaffold | Finish | Output |
|------------|--------|-------|----------|-------|----------|--------|--------|
| A | HiFi+HiC | WF1 | WF4 | [WF6] | WF8 | WF9→Pre | hap1/hap2 |
| B | HiFi+Trio | WF2 | WF5 | [WF6] | WF8 | WF9→Pre | mat/pat |
| C | HiFi only | WF1 | WF3 | WF6 | - | WF9→Pre | pri/alt |

`[WF6]` = optional, `WF6` = required, `-` = skipped

## Reference Genomes for Scaffolding

### Common Reference Genome

**GCA_011100685.1** - Frequently used reference genome for RagTag scaffolding in canid genome assemblies.

When documenting scaffolding in methods sections:
- Always specify the reference genome accession
- Include version number if applicable
- Example: "scaffolded using RagTag v2.1.0 with the reference genome GCA_011100685.1"

### Best Practices

**For reproducibility:**
- Document exact accession used
- Specify if custom modifications were made to reference
- Note if different references used for different species/assemblies

## Resource Analysis Insights

### VGP Workflow Canonical Names

Official VGP workflows normalized to canonical names for analysis:

| ID | Canonical Name | Description |
|----|----------------|-------------|
| VGP0 | Mitogenome Assembly (VGP0) | Mitochondrial genome assembly |
| VGP1/WF1 | K-mer Profiling (VGP1) | K-mer profiling for genome size estimation (HiFi) |
| VGP2 | K-mer Profiling Trio (VGP2) | Trio k-mer profiling |
| VGP3 | HiFi-only Assembly (VGP3) | HiFi-only assembly |
| VGP4 | HiFi-HiC Phased Assembly (VGP4) | HiFi-HiC phased assembly |
| VGP5 | HiFi-Trio Phased Assembly (VGP5) | HiFi-Trio phased assembly |
| VGP6 | Purge Duplicates (VGP6) | Purge duplicate contigs |
| VGP6b | Purge Duplicates One Haplotype (VGP6b) | Purge duplicates (haploid mode) |
| VGP7 | BioNano Scaffolding (VGP7) | BioNano optical mapping scaffolding |
| VGP8 | Hi-C Scaffolding (VGP8) | Hi-C scaffolding |
| VGP9 | Assembly Decontamination (VGP9) | Assembly decontamination |

**Note**: WF1-9 are aliases for VGP1-9 (same workflows, different naming convention).

### Official vs Non-Official Workflow Identification

When analyzing VGP workflow metrics, filter for official workflows only:

**Official workflows** (include):
- Core VGP workflows: VGP0-VGP9, WF0-WF9
- PretextMap/PreCuration workflows
- Workflows with version info (e.g., "v0.1.8", "release v0.3")
- Workflows imported from uploaded files or URLs (official sources)
- "WORKFLOW REPORT TEST" workflows (testing report generation, not execution)

**Non-official workflows** (exclude):
- Export workflows (utility workflows, e.g., "Export PretextMap Workflow")
- test1, test2, etc. (debug/retry runs with lowercase test + number)
- Attempt1, Attempt2, Fix_Attempt (retry/debug runs)
- "Copy of" workflows (user copies)
- Numbered prefixes: "1. ", "2. ", "3. " (custom project markers)
- Custom project annotations (e.g., "Used for other Columbiformes")
- Typos (e.g., "Gnome Assembly" instead of "Genome")
- "training workflow" (tutorial workflows)
- Experimental integrations (e.g., "ONT-INTEGRATED")

**Impact**: Filtering typically removes ~20-25% of data, leaving ~80% official workflow executions for accurate analysis.

## Species ID (ToLID) Patterns

### VGP ToLID Format

VGP uses Tree of Life IDs (ToLIDs) to uniquely identify species:

**Pattern**: `[clade][Genus][Species][Version]`

**Regex**: `[a-z][A-Z][a-z]{2}[A-Z][a-z]{2,3}\d+`

**Components**:
- `[a-z]` - Clade prefix (lowercase)
  - `a` = Amphibian
  - `b` = Bird
  - `f` = Fish
  - `m` = Mammal
  - `i` = Invertebrate
  - `r` = Reptile
- `[A-Z][a-z]{2}` - Genus (3 letters, capitalized first)
- `[A-Z][a-z]{2,3}` - Species (2-3 letters, capitalized first)
- `\d+` - Version number

**Examples**:
- `aGasCar1` - Gastrophryne carolinensis (Eastern narrowmouth toad)
- `bAcrTri1` - Acridotheres tristis (Common myna)
- `fHopMal1` - Hoplias malabaricus (Trahira)
- `mBalRic1` - Balaenoptera ricei (Rice's whale)

### ToLID Locations in Galaxy

When analyzing VGP workflows in Galaxy, ToLIDs appear in:

1. **History names** (most common) - e.g., "aGasCar1 - HiFi Assembly"
2. **Workflow inputs** - Input dataset names or labels
3. **Dataset names** - Input files named with ToLID prefix

### Extracting ToLIDs for Resource Analysis

To link workflow resource usage with genome metadata:

```python
import re

tolid_pattern = r'\b([a-z][A-Z][a-z]{2}[A-Z][a-z]{2,3}\d+)\b'

# From Galaxy history name
history_name = "aGasCar1 - VGP Assembly HiFi-HiC"
match = re.search(tolid_pattern, history_name)
species_id = match.group(1)  # "aGasCar1"

# Link with VGP genome metadata
# Match species_id with ToLID column in genome tables
```

### Linking ToLIDs with Genome Characteristics

VGP genome metadata tables use ToLID as primary key:

**Common columns**:
- `ToLID` - Species identifier
- `Species` - Scientific name
- `Common name` - Vernacular name
- `Genome size¹` - Estimated genome size (bp)
- `Heterozygosity¹` - Heterozygosity percentage
- `Sequencing depth` - Coverage depth
- `Repeat content¹` - Repeat percentage
- `Assembly version` - hap1/hap2 designation

**Usage for resource analysis**:
```python
# Correlate memory usage with genome size
# Correlate runtime with heterozygosity
# Compare resource efficiency across clades
```

### Merging Species IDs with Metrics Data

**Challenge**: Galaxy API data comes from separate endpoints:
- `/api/invocations/{id}` + `/api/histories/{history_id}` → Species IDs, history names, inputs
- `/api/invocations/{id}/metrics` + `/api/jobs/{id}/metrics` → Resource usage metrics

**Result**: Two complementary files:
1. **Enriched file**: Has species_id, history_name, inputs (NO metrics)
2. **Metrics file**: Has memory, CPU, runtime (NO species_id)

**Solution Pattern**:
```python
# Load both data sources
with open('vgp_assembly_enriched_YYYYMMDD.json') as f:
    enriched_data = json.load(f)

with open('vgp_workflows_assembly_runs_metrics.json') as f:
    metrics_data = json.load(f)

# Create lookup dictionary keyed by invocation ID
enriched_dict = {inv['id']: inv for inv in enriched_data}

# Merge: Add species data to metrics
merged_data = []
for inv in metrics_data:
    inv_id = inv['id']
    if inv_id in enriched_dict:
        enriched_inv = enriched_dict[inv_id]
        inv['species_id'] = enriched_inv.get('species_id')
        inv['history_name'] = enriched_inv.get('history_name')
        inv['inputs'] = enriched_inv.get('inputs', {})
        merged_data.append(inv)

# Save complete dataset
with open('vgp_workflows_assembly_runs_metrics_enriched_YYYYMMDD.json', 'w') as f:
    json.dump(merged_data, f, indent=2)

# Report statistics
total = len(merged_data)
with_species = sum(1 for inv in merged_data if inv.get('species_id'))
unique_species = len(set(inv['species_id'] for inv in merged_data if inv.get('species_id')))

print(f'Total invocations: {total}')
print(f'With species_id: {with_species} ({with_species/total*100:.1f}%)')
print(f'Unique species: {unique_species}')
```

**Expected Results** (VGP assembly workflows):
- ~1,630 invocations total
- ~45% with species_id (not all histories follow naming convention)
- ~129 unique species

**Pipeline Integration**:
- Add as Step 2.6 in fetch notebook
- Run AFTER both enrichment (Step 2.5) AND metrics (Step 4)
- Output file used by resource analysis notebook
- Fast execution (<1 min, no API calls)

**Enables Analysis**:
- Memory usage vs genome size
- Runtime vs heterozygosity
- Resource efficiency by species/clade
- Workflow performance across genome characteristics

## Data Analysis Troubleshooting

### Metric Availability Issues

When analyzing VGP workflow resource usage, be aware of metric availability:

**Memory Metrics**:
- `memory.max_usage_in_bytes` / `memory.limit_in_bytes` - **Only ~7% of invocations**
  - These are cgroup-based metrics from Docker/container systems
  - Only available for newer workflow runs or specific Galaxy configurations
  - Most reliable for actual memory usage data

- `galaxy_memory_mb` - **~98% of invocations**
  - Represents memory allocation/request, not actual usage
  - Much better coverage for correlation analyses
  - Use when cgroup metrics unavailable

**Runtime Metrics**:
- `runtime_seconds` - Available for most invocations
- Use sum of (cores × runtime) for "True CPU Hours" to reflect actual computational resources

**Common Data Issues**:

1. **Enrichment appears empty**: If genome characteristics show 0 species after enrichment:
   - Check if enrichment cell has been run (data only enriched in memory during notebook execution)
   - Verify species ToLIDs match between workflow data and genome metadata TSV
   - Check if genome metadata fields are populated (species may be in TSV with empty values)

2. **Limited correlation data**: When combining metrics with genome characteristics:
   - Species with rare metrics (like cgroup memory) may not overlap with species having genome data
   - Check actual overlap: how many species have BOTH the metric AND genome characteristics
   - Consider using more widely available metrics (galaxy_memory_mb, runtime_seconds)

3. **Debugging data availability**:
   ```python
   # Check metric availability
   species_with_metric = set()
   for inv in data_with_species:
       metrics = inv.get('metrics', [])
       for metric in metrics:
           if metric.get('name') == 'target_metric_name':
               if metric.get('raw_value'):
                   species_with_metric.add(inv.get('species_id'))

   # Check genome data availability
   species_with_genome = set()
   for inv in data_with_species:
       if inv.get('genome_size'):  # or other characteristic
           species_with_genome.add(inv.get('species_id'))

   # Find overlap
   overlap = species_with_metric.intersection(species_with_genome)
   print(f"Species with both: {len(overlap)}")
   ```

## GenomeArk S3 Data Integration

### Fetching GenomeScope2 Summaries

GenomeScope2 summary files contain genome characteristics needed for workflow analysis.

**S3 Path Pattern**:
```
s3://genomeark/species/{Genus}_{species}/{ToLID}/assembly_vgp_HiC_2.0/evaluation/genomescope/{ToLID}_genomescope__Summary.txt
```

**Fetch Example**:
```python
import subprocess
import re

def fetch_genomescope_summary(species_name, tolid):
    """Fetch genomescope summary from GenomeArk S3."""
    species_name_s3 = species_name.replace(' ', '_')
    path = f"s3://genomeark/species/{species_name_s3}/{tolid}/assembly_vgp_HiC_2.0/evaluation/genomescope/{tolid}_genomescope__Summary.txt"

    result = subprocess.run(
        ['aws', 's3', 'cp', path, '-', '--no-sign-request'],
        capture_output=True,
        text=True,
        timeout=10
    )

    return result.stdout if result.returncode == 0 else None

def parse_genomescope_summary(content):
    """Extract genome characteristics from summary."""
    data = {}

    # Genome Haploid Length (use max value - second column)
    match = re.search(r'Genome Haploid Length\s+[\d,]+\s*bp\s+([\d,]+)\s*bp', content)
    if match:
        data['genome_size'] = match.group(1).replace(',', '')

    # Heterozygosity percentage (max value)
    match = re.search(r'Heterozygous \(ab\)\s+[\d.]+%\s+([\d.]+)%', content)
    if match:
        data['heterozygosity'] = match.group(1)

    # Calculate repeat content from repeat and unique lengths
    repeat_match = re.search(r'Genome Repeat Length\s+[\d,]+\s*bp\s+([\d,]+)\s*bp', content)
    unique_match = re.search(r'Genome Unique Length\s+[\d,]+\s*bp\s+([\d,]+)\s*bp', content)

    if repeat_match and unique_match:
        repeat_length = float(repeat_match.group(1).replace(',', ''))
        unique_length = float(unique_match.group(1).replace(',', ''))
        total_length = repeat_length + unique_length
        if total_length > 0:
            repeat_percent = (repeat_length / total_length) * 100
            data['repeat_content'] = f"{repeat_percent:.1f}"

    return data if data else None
```

**Key Points**:
- Use `--no-sign-request` for public bucket access
- GenomeScope2 format has min/max columns - use max (second) values
- Species names use underscores in S3 paths
- Not all species have GenomeScope data available
- Add timeout protection for batch processing

**Workflow Integration**:
```python
# Enrich workflow invocations with genome characteristics
for inv in workflow_invocations:
    species_id = inv.get('species_id')
    if species_id:
        content = fetch_genomescope_summary(species_name, species_id)
        if content:
            genome_data = parse_genomescope_summary(content)
            inv.update(genome_data)
```

**Success Rate**: Expect ~80-90% success rate for VGP species in GenomeArk.

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

## Tool-Level Resource Optimization

### Identifying Top Resource Offender Tools

To prioritize optimization efforts, identify tools consuming most resources:

```python
# From df_jobs DataFrame (job-level metrics)
tool_cpu = df_jobs.groupby('tool_name').agg({
    'cpu_hours': ['sum', 'count', 'mean']
}).reset_index()
tool_cpu.columns = ['tool_name', 'total_cpu_hours', 'job_count', 'avg_cpu_hours']

top_cpu_tools = tool_cpu.sort_values('total_cpu_hours', ascending=False).head(3)

tool_memory = df_jobs.groupby('tool_name').agg({
    'peak_memory_gb': ['sum', 'count', 'mean', 'max']
}).reset_index()
top_memory_tools = tool_memory.sort_values('total_memory_gb', ascending=False).head(3)
```

### Correlating Tool Usage with Genome Characteristics

For each top tool, analyze how genome characteristics affect resource usage:

```python
from scipy import stats

for tool_name in top_cpu_tools['tool_name']:
    tool_jobs = df_jobs[df_jobs['tool_name'] == tool_name]

    # Aggregate by species
    species_data = {}
    for _, job in tool_jobs.iterrows():
        workflow_id = job['workflow_id']
        # Match with workflow invocation to get genome characteristics
        for inv in invocations:
            if inv['id'] == workflow_id and inv.get('species_id'):
                species_id = inv['species_id']
                genome_size = inv.get('genome_size')
                cpu_hours = job['cpu_hours']

                if species_id not in species_data:
                    species_data[species_id] = {
                        'genome_size': genome_size,
                        'cpu_hours': 0
                    }
                species_data[species_id]['cpu_hours'] += cpu_hours

    # Calculate correlation
    x = [d['genome_size'] for d in species_data.values()]
    y = [d['cpu_hours'] for d in species_data.values()]

    if len(x) >= 3:
        corr, pval = stats.pearsonr(x, y)
        sig = '***' if pval < 0.001 else '**' if pval < 0.01 else '*' if pval < 0.05 else 'ns'
        print(f'{tool_name}: r={corr:.3f}, p={pval:.2e} ({sig})')
```

### Interpretation

**High correlation + high p-value significance** → Tool resource usage scales with genome characteristic
- **Actionable**: Optimize tool for this characteristic
- **Example**: Tool uses 2x CPU per 1 Gb genome size increase

**Low/no correlation** → Resource usage independent of genome characteristics
- **Actionable**: Look for algorithmic inefficiencies
- **Example**: Tool has fixed overhead or inefficient implementation

**Significance levels**:
- *** (p < 0.001): Highly significant correlation
- ** (p < 0.01): Very significant
- * (p < 0.05): Significant
- ns: Not significant

### Visualization

Create separate plot for each tool showing all 5 genome characteristics:
- Genome Size, Heterozygosity, Repeat Content, Contig N50, GC Content
- Include trend line, correlation coefficient, and p-value on each subplot
- Point size proportional to number of jobs

## Communication Patterns

### File Path Confirmation

When modifying files, especially when multiple similar files exist:

1. **Always state the FULL path** when making edits:
   ```
   ❌ Bad: "Updating the notebook..."
   ✅ Good: "Updating /Users/delphine/Workdir/Stats_workflow_run/vgp_workflow_resource_analysis.ipynb"
   ```

2. **Ask for clarification** if multiple candidates exist:
   ```
   Found two notebooks:
   1. /Users/delphine/Workdir/Stats_workflow_run/vgp_workflow_resource_analysis.ipynb
   2. /Users/delphine/Workdir/Stats_workflow_run/sharing/vgp_workflow_resource_analysis.ipynb

   Which one are you running?
   ```

3. **After user correction**, explicitly confirm:
   ```
   ✅ Confirmed: Now modifying the correct file at /path/to/correct/file
   ```

### User Feedback Interpretation

When user says "the outlier is still there":
1. **Don't assume code is wrong** - may be running different file
2. **Don't assume user error** - may be our mistake
3. **Verify the file path** immediately
4. **Check if changes were applied** to the file user is actually running

This pattern prevents major errors where edits are applied to the wrong file for multiple iterations.


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

## Meryl K-mer Database Management

### Accessing Meryl Histograms for GenomeScope

**Key Insight**: GenomeScope only needs histogram files (`.hist`), not full meryl databases.

**File Structure on GenomeArk S3**:
```
s3://genomeark/species/{species}/{tolid}/assembly_*/intermediates/meryl/
├── {tolid}.cut.meryl.hist          # ~700KB - THIS IS WHAT YOU NEED
└── {tolid}.cut.meryl/              # Many GB - full database
    ├── 0x000000.merylData
    ├── 0x000000.merylIndex
    └── ...
```

**Direct Histogram URLs** (for Galaxy import):
```bash
# Pattern:
https://genomeark.s3.amazonaws.com/species/{species}/{tolid}/path/to/meryl/{tolid}.cut.meryl.hist

# Example:
https://genomeark.s3.amazonaws.com/species/Rhinolophus_ferrumequinum/mRhiFer1/assembly_vgp_standard_1.0/intermediates/meryl/mRhiFer1.cut.meryl.hist
```

**Benefits**:
- 1000x smaller download (~700KB vs ~10GB)
- Can import directly into Galaxy via URL
- No need to download full meryl database
- Much faster for batch GenomeScope analysis

**Common Mistake**: Downloading entire meryl directory when only `.hist` file is needed.

## Assembly Size vs Expected Genome Size Interpretation

### Common Pattern: Assemblies ~12% Larger Than Expected

**Typical Statistics** (from real VGP data, n=149):
- Mean ratio (assembly/expected): 1.116  
- Median ratio: 1.077
- Within ±10%: ~58%
- Within ±20%: ~88%

**Why Assemblies Are Larger**:
1. **Incomplete haplotig purging**: Haplotype-specific sequences retained in primary
2. **GenomeScope underestimation**: High heterozygosity/repeats affect k-mer frequencies
3. **Organellar DNA**: Mitochondrial genomes (~15-20kb) assembled and included

**Interpretation**:
- Ratio 1.0-1.2: Normal, good assembly
- Ratio > 1.3: Possible retained duplications, check purge_dups metrics
- Ratio < 0.9: Possible missing sequence, check coverage

**Not a Quality Problem**: Moderate scatter (std dev ~30%) reflects biological variation and k-mer estimation limitations, not assembly quality issues.

## References
- [VGP Galaxy Workflows](https://github.com/Delphine-L/iwc/tree/VGP)
- [Vertebrate Genome Project](https://vertebrategenomesproject.org/)
