# VGP Pipeline - Data Integration

> Supporting file for [SKILL.md](SKILL.md)

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
- `Genome size` - Estimated genome size (bp)
- `Heterozygosity` - Heterozygosity percentage
- `Sequencing depth` - Coverage depth
- `Repeat content` - Repeat percentage
- `Assembly version` - hap1/hap2 designation

**Usage for resource analysis**:
```python
# Correlate memory usage with genome size
# Correlate runtime with heterozygosity
# Compare resource efficiency across clades
```

### Merging Species IDs with Metrics Data

**Challenge**: Galaxy API data comes from separate endpoints:
- `/api/invocations/{id}` + `/api/histories/{history_id}` -> Species IDs, history names, inputs
- `/api/invocations/{id}/metrics` + `/api/jobs/{id}/metrics` -> Resource usage metrics

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

## Finding Missing VGP Accessions

### Problem
Some curated VGP species have no accession numbers in the enriched dataset and aren't found in GenomeArk AWS. They may have been submitted directly to NCBI or are in external collaborating projects.

### Solution: Search NCBI with VGP-specific Filtering

**Search NCBI Assembly database:**
```python
import requests
from urllib.parse import quote

def search_ncbi_assemblies(species_name):
    """Search NCBI for assemblies by species name"""
    base_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"

    # Search for assembly IDs
    search_url = f"{base_url}esearch.fcgi"
    search_params = {
        'db': 'assembly',
        'term': f'"{species_name}"[Organism]',
        'retmode': 'json',
        'retmax': 100
    }
    search_response = requests.get(search_url, params=search_params)
    assembly_ids = search_response.json()['esearchresult']['idlist']

    # Fetch assembly details
    fetch_url = f"{base_url}esummary.fcgi"
    fetch_params = {
        'db': 'assembly',
        'id': ','.join(assembly_ids),
        'retmode': 'json'
    }
    fetch_response = requests.get(fetch_url, params=fetch_params)

    # Extract submitter information
    results = []
    for assembly_id, data in fetch_response.json()['result'].items():
        if assembly_id == 'uids':
            continue
        results.append({
            'accession': data.get('assemblyaccession'),
            'submitter': data.get('submitter'),
            'name': data.get('assemblyname')
        })

    return results
```

**CRITICAL: Filter for VGP-only submissions:**
```python
# Only keep VGP-submitted assemblies
vgp_assemblies = [
    r for r in results
    if r['submitter'] == 'Vertebrate Genomes Project'
]
```

**Why this matters:**
- Non-VGP assemblies may have different quality standards
- Other projects (Bat1K, Ocean Genomes) may use different assembly methods
- VGP-specific filtering ensures data consistency
- Prevents mixing different curation standards

**Example results from VGP Phase 1 enrichment:**
- Searched: 17 species missing accessions
- Found: 24 assemblies total from NCBI
- VGP-only: 5 accessions recovered
  - mTenEca1 (Tenrec ecaudatus): GCF_050624435.1
  - mNeoFlo1 (Neotoma floridana): GCA_050000055.1
  - rHydTec1 (Hydromedusa tectifera): GCA_049999965.1
  - rPelSom1 (Pelomedusa somalica): GCA_051311615.1
  - rPodUni1 (Podocnemis unifilis): GCA_050000005.1

**Store recovered data separately:**
```python
# Add new columns instead of overwriting existing data
df['accession_recovered'] = None  # Primary accession
df['accession_recovered_all'] = None  # All accessions (pipe-separated)

# Fill in recovered accessions
for tolid, accs in recovered_accessions.items():
    mask = df['tolid'] == tolid
    df.loc[mask, 'accession_recovered'] = accs['primary']
    df.loc[mask, 'accession_recovered_all'] = accs['all']
```

This preserves data provenance and makes it clear which accessions were found later.

**Species not in GenomeArk:**
If species have accessions but no tolids and aren't found in AWS:
- These are likely direct NCBI submissions
- May be from collaborating projects (not in GenomeArk)
- May be pre-VGP naming convention
- Document separately for tracking purposes

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
