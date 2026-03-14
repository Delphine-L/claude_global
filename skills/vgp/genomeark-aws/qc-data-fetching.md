# QC Data Fetching from GenomeArk

Detailed fetching strategies for GenomeScope, BUSCO, Merqury, and Meryl data.

## 1. GenomeScope Data (Genome Characteristics)

**Location**: `{assembly}/evaluation/genomescope/`

**Metrics Available**:
- Genome haploid length (genome size estimate)
- Heterozygosity percentage
- Repeat content percentage
- Unique sequence length

### Filename Patterns (TRY ALL THREE!)

**Pattern A - Double Underscore** (most common):
```
{ToLID}_genomescope__Summary.txt
```
Example: `aGasCar1_genomescope__Summary.txt`

**Pattern C - Single Underscore** (easily missed, discovered 2026):
```
{ToLID}_genomescope_Summary.txt
```
Example: `rPlaMeg1_genomescope_Summary.txt`

**Pattern B - No Prefix** (older assemblies):
```
{ToLID}_Summary.txt
```
Example: `aSpeBom1_Summary.txt`

**CRITICAL**: Checking only patterns A and B causes ~30-40% of data to be missed! Pattern C (single underscore) is common but was only discovered during Feb 2026 debugging.

### File Format

```
GenomeScope version 2.0
...
property                      min               max
Genome Haploid Length         4,077,481,159 bp  4,095,803,536 bp
Heterozygous (ab)             1.43264%          1.47696%
Genome Repeat Length          2,528,408,288 bp  2,539,769,824 bp
Genome Unique Length          1,567,234,248 bp  1,556,033,712 bp
```

**Parsing Rules**:
- Always use **max value** (second column) for measurements
- Genome size: Take max haploid length, remove commas
- Heterozygosity: Take max percentage (validate first!)
- Repeat content: Calculate `(repeat_length / genome_size) * 100`

### Data Validation - CRITICAL!

Failed GenomeScope runs produce unrealistic ranges that MUST be filtered:

**Failed Run** (DO NOT USE):
```
Heterozygous (ab)    0%    100%
```

**Valid Run** (ACCEPT):
```
Heterozygous (ab)    0.49%    0.54%
```

**Validation Logic**:
```python
def validate_genomescope(min_het, max_het):
    """Validate GenomeScope heterozygosity estimates"""
    range_width = max_het - min_het

    # Reject if:
    if range_width > 50.0:        # Range too wide = model failure
        return False
    if max_het > 95.0:            # Unrealistic for diploid genomes
        return False
    if min_het == 0 and max_het == 100:  # Complete failure
        return False

    return True  # ACCEPT
```

**Skip values if**:
- Range width > 50% (indicates model failure)
- Max value > 95% (unrealistic for most genomes)
- Range is exactly 0%-100% (complete model failure)

### Fetching Strategy

```python
import subprocess
import re
import time

def normalize_s3_path(s3_path):
    """Normalize path for GenomeArk (case sensitivity!)"""
    if not s3_path:
        return None
    # Critical: HiC capitalization
    s3_path = s3_path.replace('/assembly_vgp_hic_2.0/', '/assembly_vgp_HiC_2.0/')
    if not s3_path.endswith('/'):
        s3_path += '/'
    return s3_path

def fetch_genomescope_data(species_name, tolid, assembly_type='HiC_2.0'):
    """Fetch GenomeScope summary with all pattern attempts"""
    species_s3 = species_name.replace(' ', '_')
    base_path = f"s3://genomeark/species/{species_s3}/{tolid}/assembly_vgp_{assembly_type}/"
    base_path = normalize_s3_path(base_path)

    # Try ALL THREE filename patterns in order
    patterns = [
        f'{tolid}_genomescope__Summary.txt',   # Pattern A: double underscore
        f'{tolid}_genomescope_Summary.txt',    # Pattern C: single underscore
        f'{tolid}_Summary.txt'                  # Pattern B: no prefix
    ]

    for pattern in patterns:
        file_path = f"{base_path}evaluation/genomescope/{pattern}"

        try:
            result = subprocess.run(
                ['aws', 's3', 'cp', file_path, '-', '--no-sign-request'],
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0 and result.stdout:
                data = parse_genomescope_summary(result.stdout)
                if data:
                    return data
        except subprocess.TimeoutExpired:
            continue

        time.sleep(0.2)  # Rate limiting

    return None

def parse_genomescope_summary(content):
    """Extract and validate genome characteristics"""
    data = {}

    # Genome Haploid Length (max value - second column)
    match = re.search(r'Genome Haploid Length\s+[\d,]+\s*bp\s+([\d,]+)\s*bp', content)
    if match:
        data['genome_size'] = int(match.group(1).replace(',', ''))

    # Heterozygosity percentage (extract both min and max)
    match = re.search(r'Heterozygous \(ab\)\s+([\d.]+)%\s+([\d.]+)%', content)
    if match:
        min_het = float(match.group(1))
        max_het = float(match.group(2))

        # VALIDATE before accepting
        if validate_genomescope(min_het, max_het):
            data['heterozygosity'] = max_het
        # Otherwise skip - don't include invalid value

    # Repeat content calculation
    repeat_match = re.search(r'Genome Repeat Length\s+[\d,]+\s*bp\s+([\d,]+)\s*bp', content)
    unique_match = re.search(r'Genome Unique Length\s+[\d,]+\s*bp\s+([\d,]+)\s*bp', content)

    if repeat_match and unique_match:
        repeat_length = float(repeat_match.group(1).replace(',', ''))
        unique_length = float(unique_match.group(1).replace(',', ''))
        total_length = repeat_length + unique_length
        if total_length > 0:
            repeat_percent = (repeat_length / total_length) * 100
            data['repeat_content'] = round(repeat_percent, 2)

    return data if data else None
```

**Expected Success Rate**: ~80-90% for VGP species

## 2. BUSCO Data (Assembly Completeness)

**Location**: `{assembly}/evaluation/busco/{subdir}/`

**Subdirectory Variations**:
- `c/`, `c1/` - primary chromosome results
- `p/`, `p1/` - primary scaffold results
- Search dynamically, don't hardcode

**Files**: `*short_summary*.txt` (case-insensitive)

### Filename Patterns

**HiC assemblies**:
```
{ToLID}_HiC__busco_hap1_busco_short_summary.txt
{ToLID}_HiC__busco_hap2_busco_short_summary.txt
```

**Standard assemblies**:
```
{ToLID}_busco_short_summary.txt
```

### File Format

```
# BUSCO version is: 5.2.2
# The lineage dataset is: vertebrata_odb10
# Summarized benchmarking in BUSCO notation for file primary.fa
...
	C:94.0%[S:92.4%,D:1.6%],F:2.7%,M:3.3%,n:3354
	3152	Complete BUSCOs (C)
	3099	Complete and single-copy BUSCOs (S)
	53	Complete and duplicated BUSCOs (D)
	91	Fragmented BUSCOs (F)
	111	Missing BUSCOs (M)
	3354	Total BUSCO groups searched
```

**Parsing**: Extract completeness from line starting with `C:` -> `94.0` from `C:94.0%`

### Fetching Strategy

```python
def fetch_busco_data(base_path, tolid):
    """Fetch BUSCO completeness with dynamic subdir search"""
    base_path = normalize_s3_path(base_path)

    # List busco subdirectories
    list_cmd = ['aws', 's3', 'ls', f"{base_path}evaluation/busco/", '--no-sign-request']
    result = subprocess.run(list_cmd, capture_output=True, text=True, timeout=10)

    if result.returncode != 0:
        return None

    # Find subdirectories (lines with 'PRE')
    subdirs = [line.split('PRE')[1].strip().rstrip('/')
               for line in result.stdout.split('\n') if 'PRE' in line]

    # Try each subdirectory
    for subdir in subdirs:
        # List files in subdirectory
        files_cmd = ['aws', 's3', 'ls', f"{base_path}evaluation/busco/{subdir}/", '--no-sign-request']
        files_result = subprocess.run(files_cmd, capture_output=True, text=True, timeout=10)

        # Find short_summary files
        for line in files_result.stdout.split('\n'):
            if 'short_summary' in line.lower():
                filename = line.split()[-1]
                file_path = f"{base_path}evaluation/busco/{subdir}/{filename}"

                # Fetch and parse
                content_result = subprocess.run(
                    ['aws', 's3', 'cp', file_path, '-', '--no-sign-request'],
                    capture_output=True, text=True, timeout=30
                )

                if content_result.returncode == 0:
                    completeness = parse_busco_completeness(content_result.stdout)
                    if completeness:
                        return {'completeness': completeness, 'subdir': subdir}

        time.sleep(0.2)  # Rate limiting

    return None

def parse_busco_completeness(content):
    """Extract completeness percentage"""
    for line in content.split('\n'):
        if line.strip().startswith('C:'):
            match = re.search(r'C:([\d.]+)%', line)
            if match:
                return float(match.group(1))
    return None
```

## 3. Merqury Data (Assembly QV Scores)

**Location**: Two path patterns (structure changed 2022 -> 2024)

**Pattern A - Direct** (2024+, newer):
```
{assembly}/evaluation/merqury/{ToLID}_qv/output_merqury.tabular
```

**Pattern B - Nested** (2022, older):
```
{assembly}/evaluation/merqury/{c,p}/{ToLID}_qv/output_merqury.tabular
```

**Strategy**: Try direct path first, then search nested subdirectories

### File Format

Tab-separated, may have header:
```
assembly	unique k-mers	common k-mers	QV	error rate
assembly_01	20197	2133011206	63.4592	4.50896e-07
assembly_02	19654	2304717679	63.9138	4.06084e-07
Both	39851	4437728885	63.6894	4.27623e-07
```

**Parsing**:
- Skip header line if starts with `assembly\t`
- QV is always column 4 (index 3)
- Take first data line (usually assembly_01 or Both)

### Fetching Strategy

```python
def fetch_merqury_data(base_path, tolid):
    """Fetch Merqury QV with fallback patterns"""
    base_path = normalize_s3_path(base_path)

    # Try direct path first (newer structure)
    direct_path = f"{base_path}evaluation/merqury/{tolid}_qv/output_merqury.tabular"
    result = subprocess.run(
        ['aws', 's3', 'cp', direct_path, '-', '--no-sign-request'],
        capture_output=True, text=True, timeout=30
    )

    if result.returncode == 0 and result.stdout:
        qv = parse_merqury_qv(result.stdout)
        if qv:
            return {'qv': qv, 'path_type': 'direct'}

    # Fallback: search nested subdirectories (older structure)
    list_result = subprocess.run(
        ['aws', 's3', 'ls', f"{base_path}evaluation/merqury/", '--no-sign-request'],
        capture_output=True, text=True, timeout=10
    )

    if list_result.returncode == 0:
        subdirs = [line.split('PRE')[1].strip().rstrip('/')
                   for line in list_result.stdout.split('\n') if 'PRE' in line]

        for subdir in subdirs:
            nested_path = f"{base_path}evaluation/merqury/{subdir}/{tolid}_qv/output_merqury.tabular"
            result = subprocess.run(
                ['aws', 's3', 'cp', nested_path, '-', '--no-sign-request'],
                capture_output=True, text=True, timeout=30
            )

            if result.returncode == 0 and result.stdout:
                qv = parse_merqury_qv(result.stdout)
                if qv:
                    return {'qv': qv, 'path_type': 'nested', 'subdir': subdir}

            time.sleep(0.2)

    return None

def parse_merqury_qv(content):
    """Extract QV score from merqury output"""
    for line in content.split('\n'):
        line = line.strip()
        if not line or line.startswith('assembly\t'):
            continue  # Skip header

        parts = line.split('\t')
        if len(parts) >= 4:
            try:
                return float(parts[3])  # QV is column 4
            except ValueError:
                continue
    return None
```

## 4. Meryl K-mer Histograms

**Location**: `{assembly}/intermediates/meryl/`

**Key Insight**: GenomeScope only needs `.hist` files, not full meryl databases!

**File Structure**:
```
s3://genomeark/species/{species}/{tolid}/assembly_*/intermediates/meryl/
├── {tolid}.cut.meryl.hist          # ~700KB - DOWNLOAD THIS
└── {tolid}.cut.meryl/              # Many GB - full database (DON'T DOWNLOAD)
    ├── 0x000000.merylData
    ├── 0x000000.merylIndex
    └── ...
```

**Direct HTTPS URLs** (for Galaxy import):
```
https://genomeark.s3.amazonaws.com/species/{species}/{tolid}/assembly_vgp_standard_1.0/intermediates/meryl/{tolid}.cut.meryl.hist
```

Example:
```
https://genomeark.s3.amazonaws.com/species/Rhinolophus_ferrumequinum/mRhiFer1/assembly_vgp_standard_1.0/intermediates/meryl/mRhiFer1.cut.meryl.hist
```

**Benefits**:
- 1000x smaller download (~700KB vs ~10GB)
- Can import directly into Galaxy via URL
- No need to download full meryl database
- Much faster for batch GenomeScope analysis

**Common Mistake**: Downloading entire meryl directory when only `.hist` file is needed

### Fetching Strategy

```python
def fetch_meryl_histogram(species_name, tolid, assembly_type='standard_1.0'):
    """Fetch meryl histogram file (not full database)"""
    species_s3 = species_name.replace(' ', '_')
    file_path = (
        f"s3://genomeark/species/{species_s3}/{tolid}/"
        f"assembly_vgp_{assembly_type}/intermediates/meryl/{tolid}.cut.meryl.hist"
    )

    result = subprocess.run(
        ['aws', 's3', 'cp', file_path, f'./{tolid}.cut.meryl.hist', '--no-sign-request'],
        capture_output=True, text=True, timeout=60
    )

    return result.returncode == 0

def get_histogram_url(species_name, tolid, assembly_type='standard_1.0'):
    """Get direct HTTPS URL for Galaxy import"""
    species_s3 = species_name.replace(' ', '_')
    return (
        f"https://genomeark.s3.amazonaws.com/species/{species_s3}/{tolid}/"
        f"assembly_vgp_{assembly_type}/intermediates/meryl/{tolid}.cut.meryl.hist"
    )
```

## 5. Technology Verification from genomic_data/

When `Assembly tech` is missing, check GenomeArk `genomic_data/` subfolders:

```bash
aws s3 ls --no-sign-request \
  s3://genomeark/species/Genus_species/tolid/genomic_data/
```

**Folder to Technology mapping**:
| Folder | Technology |
|--------|-----------|
| `pacbio_hifi/` | HiFi |
| `ont/` or `nanopore/` | ONT |
| `pacbio_hifi/` + `ont/` | HiFi+ONT |
| `arima/`, `dovetail/` | Hi-C (scaffolding, not sequencing tech) |
| `bionano/` | BioNano (optical mapping) |
| `illumina/` | Illumina (short reads) |

**Fallback**: If not in GenomeArk, check `sequencing_tech` column:
- "PacBio Sequel" or "PacBio Sequel I/II CLR" -> CLR
- "PacBio Sequel II HiFi" or "PacBio Revio HiFi" -> HiFi
- "PacBio" + "Oxford Nanopore" -> check for `pacbio_hifi/` to distinguish CLR+ONT vs HiFi+ONT
