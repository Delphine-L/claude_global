# GenomeArk AWS S3 Data Access

Patterns and strategies for accessing VGP genome assembly data and QC metrics from GenomeArk public S3 buckets.

---

## Overview

GenomeArk (s3://genomeark/) is a public AWS S3 bucket containing VGP genome assemblies and QC data. Access requires no credentials using `--no-sign-request`.

**Critical Discovery**: GenomeArk S3 structure has evolved over time (2022 -> 2024). Always try multiple path patterns for reliability.

## Directory Structure Evolution

**Base structure**:
```
s3://genomeark/species/{Species_name}/{ToLID}/assembly_vgp_{type}_2.0/evaluation/
```

**Key variations**:

1. **Case sensitivity**:
   - Table may store: `assembly_vgp_hic_2.0`
   - S3 requires: `assembly_vgp_HiC_2.0` (case-sensitive!)
   - **Always normalize**: Replace `hic` -> `HiC` before fetching

2. **Subspecies handling** (CRITICAL, discovered Feb 2026):
   - Dataset may contain trinomial names: "Elephas maximus indicus"
   - GenomeArk uses only binomial: `Elephas_maximus`
   - **Always use only first two words** (Genus + species) for S3 paths
   - Example: "Elephas maximus indicus" -> `s3://genomeark/species/Elephas_maximus/...`

3. **Assembly directory patterns** (multiple generations exist):

   **Try in this order for maximum coverage** (Feb 2026 - 8 patterns):

   ```python
   path_patterns = [
       # Version 2.0 paths (original, most common)
       f"assembly_vgp_HiC_2.0/",
       f"assembly_vgp_standard_2.0/",
       f"assembly_vgp_hic_2.0/",

       # Without version suffix (newer assemblies)
       f"assembly_vgp_HiC/",
       f"assembly_vgp_standard/",

       # Alternative assembly types
       f"assembly_curated/",
       f"assembly_cambridge/",
       f"assembly_rockefeller/",
   ]
   ```

   **Coverage impact**:
   - 3 patterns (original): ~24% assembly coverage
   - 8 patterns (expanded): ~35-45% assembly coverage
   - **Always try multiple patterns** - don't assume structure

4. **Species name construction**:
   ```python
   # Handle subspecies correctly
   species_parts = scientific_name.strip().split()
   if len(species_parts) >= 2:
       species_name = f"{species_parts[0]}_{species_parts[1]}"
   else:
       species_name = scientific_name.strip().replace(' ', '_')

   # Full path example
   s3_path = f"s3://genomeark/species/{species_name}/{tolid}/{assembly_type}/"
   ```

## QC Data Locations and Formats

### 1. GenomeScope (Genome Size, Heterozygosity, Repeat Content)

**Path**: `{assembly}/evaluation/genomescope/`

**Filename patterns** (try in order):
1. `{ToLID}_genomescope__Summary.txt` (Pattern A: double underscore - most common)
2. `{ToLID}_genomescope_Summary.txt` (Pattern C: single underscore - EASILY MISSED)
3. `{ToLID}_Summary.txt` (Pattern B: no prefix - older assemblies)

**CRITICAL**: ALL THREE patterns must be checked! Pattern C (single underscore) was discovered in Feb 2026 during debugging - checking only patterns A and B causes ~30-40% of data to be missed!

**Example of Pattern C**:
- Missing: `rPlaMeg1_genomescope__Summary.txt` (not found)
- Found: `rPlaMeg1_genomescope_Summary.txt` (exists)

**CRITICAL: Validate Data Quality**

Failed GenomeScope runs show unrealistic ranges:
```
Heterozygous (ab)    0%    100%     <- FAILED RUN - DO NOT USE
```

Good runs show narrow ranges:
```
Heterozygous (ab)    0.49%    0.54%  <- VALID - use max value
```

**Validation logic**:
```python
# Extract min and max percentages
percentages = [0.49, 0.54]  # Example from parsing
min_val, max_val = percentages[0], percentages[-1]
range_width = max_val - min_val

# Validate before using
if range_width <= 50.0 and max_val <= 95.0:
    heterozygosity = max_val  # ACCEPT
else:
    heterozygosity = None  # REJECT - failed run
```

**Skip values if**:
- Range width > 50% (indicates model failure)
- Max value > 95% (unrealistic for most genomes)
- Range is exactly 0%-100% (complete failure)

**Summary.txt format**:
```
GenomeScope version 2.0
...
property                      min               max
Genome Haploid Length         4,077,481,159 bp  4,095,803,536 bp
Heterozygous (ab)             1.43264%          1.47696%
Genome Repeat Length          2,528,408,288 bp  2,539,769,824 bp
```

**Parsing**:
- Genome size: Take max value (second number), remove commas
- Heterozygosity: Take max percentage (validate range first!)
- Repeat content: Calculate `(repeat_length / genome_size) * 100`

### 2. BUSCO (Assembly Completeness)

**Path**: `{assembly}/evaluation/busco/{subdir}/`

**Subdirectories vary**:
- `c/`, `c1/` - primary results
- `p/`, `p1/` - alternate results
- Search dynamically, don't hardcode

**Files**: `*short_summary*.txt` (case-insensitive search)

**Filename patterns**:
- HiC assemblies: `{ToLID}_HiC__busco_hap1_busco_short_summary.txt`
- Standard assemblies: `{ToLID}_busco_short_summary.txt`

**Format**:
```
# BUSCO version is: 5.2.2
# The lineage dataset is: vertebrata_odb10
...
	C:94.0%[S:92.4%,D:1.6%],F:2.7%,M:3.3%,n:3354
```

**Parse line starting with `C:`**: Extract `94.0` from `C:94.0%`

**Expected coverage**: ~20-30% of VGP assemblies have BUSCO data

### 3. Merqury (Assembly QV Scores)

**TWO PATH PATTERNS** (structure changed 2022 -> 2024):

**Pattern A (Newer - Direct, 2024+)**:
```
{assembly}/evaluation/merqury/{ToLID}_qv/output_merqury.tabular
```

**Pattern B (Older - Nested, 2022)**:
```
{assembly}/evaluation/merqury/{c,p}/{ToLID}_qv/output_merqury.tabular
```

**Strategy**: Try direct path first, then search for nested subdirectories

**File format** (tab-separated, may have header):
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

## Complete Fetching Strategy

```python
def normalize_s3_path(s3_path):
    """Normalize path for GenomeArk (case sensitivity!)"""
    if not s3_path:
        return None
    # Critical: HiC capitalization
    s3_path = s3_path.replace('/assembly_vgp_hic_2.0/', '/assembly_vgp_HiC_2.0/')
    if not s3_path.endswith('/'):
        s3_path += '/'
    return s3_path

def fetch_genomescope_data(s3_path):
    """Fetch with validation"""
    s3_path = normalize_s3_path(s3_path)
    tolid = s3_path.rstrip('/').split('/')[-2]

    # Try ALL THREE filename patterns
    for filename in [
        f'{tolid}_genomescope__Summary.txt',   # Pattern A: double underscore
        f'{tolid}_genomescope_Summary.txt',    # Pattern C: single underscore
        f'{tolid}_Summary.txt'                  # Pattern B: no prefix
    ]:
        file_path = f"{s3_path}evaluation/genomescope/{filename}"
        result = subprocess.run(['aws', 's3', 'cp', file_path, '-', '--no-sign-request'],
                               capture_output=True, text=True, timeout=30)

        if result.returncode == 0 and result.stdout:
            # Parse and validate
            data = parse_genomescope(result.stdout)

            # Validate heterozygosity range
            if 'heterozygosity' in data:
                # Check if range is reasonable
                if heterozygosity_range > 50.0 or max_het > 95.0:
                    del data['heterozygosity']  # Skip invalid value

            if data:
                return data
    return None

def fetch_merqury_data(s3_path):
    """Fetch from direct or nested paths"""
    s3_path = normalize_s3_path(s3_path)
    tolid = s3_path.rstrip('/').split('/')[-2]

    # Try direct path first (newer structure)
    direct_path = f"{s3_path}evaluation/merqury/{tolid}_qv/output_merqury.tabular"
    result = subprocess.run(['aws', 's3', 'cp', direct_path, '-', '--no-sign-request'],
                           capture_output=True, text=True, timeout=30)

    if result.returncode == 0 and result.stdout:
        # Parse QV from column 4
        for line in result.stdout.split('\n'):
            if line.strip() and not line.startswith('assembly\t'):
                parts = line.split('\t')
                if len(parts) >= 4:
                    return {'qv': float(parts[3]), 'path_type': 'direct'}

    # Fallback: search nested subdirectories (older structure)
    # List subdirectories, try c/, p/, etc.
    ...

def fetch_busco_data(s3_path):
    """Search dynamic subdirectories"""
    s3_path = normalize_s3_path(s3_path)

    # List busco/ subdirectories
    list_result = subprocess.run(['aws', 's3', 'ls', f"{s3_path}evaluation/busco/", '--no-sign-request'],
                                capture_output=True, text=True, timeout=10)

    # Find subdirectories (lines with 'PRE')
    subdirs = [line.split('PRE')[1].strip().rstrip('/')
               for line in list_result.stdout.split('\n') if 'PRE' in line]

    # Try each subdirectory for short_summary files
    ...
```

## Extracting Assembly Completion Dates

**Problem**: NCBI `release_date` doesn't reflect actual assembly completion due to curation/submission delays.

**Solution**: GenomeArk filenames contain YYYYMMDD timestamps showing actual assembly completion dates.

**Filename pattern**:
```
mLoxAfr1.HiC.hap1.20221209.fasta.gz
                  ^^^^^^^^
                  YYYYMMDD = Dec 9, 2022
```

**Strategy**:
```python
import re
from datetime import datetime

def extract_assembly_year(tolid, scientific_name):
    """Extract assembly year from GenomeArk filenames"""

    # 1. Construct S3 path (try multiple patterns)
    species_name = '_'.join(scientific_name.split()[:2])  # Handle subspecies!

    for assembly_type in ['assembly_vgp_HiC_2.0', 'assembly_vgp_standard_2.0',
                          'assembly_vgp_HiC', 'assembly_curated', ...]:
        s3_path = f"s3://genomeark/species/{species_name}/{tolid}/{assembly_type}/"

        # 2. List files recursively (exclude _curated subdirs)
        cmd = ['aws', 's3', 'ls', s3_path, '--recursive', '--no-sign-request']
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            continue  # Try next pattern

        # 3. Extract YYYYMMDD dates from filenames
        date_pattern = r'(\d{8})'
        dates = []

        for line in result.stdout.split('\n'):
            if '_curated' in line:  # Exclude curated versions (later dates)
                continue

            matches = re.findall(date_pattern, line)
            for date_str in matches:
                year = int(date_str[:4])
                month = int(date_str[4:6])
                day = int(date_str[6:8])

                # 4. Validate date (2000-2030, valid month/day)
                if 2000 <= year <= 2030 and 1 <= month <= 12 and 1 <= day <= 31:
                    dates.append(date_str)

        # 5. Return most recent year found
        if dates:
            most_recent = max(dates)
            return int(most_recent[:4])

    return None  # No dates found in any path
```

**Coverage expectations**:
- Newer assemblies (2020+): 80-90%
- Older assemblies (pre-2020): 50-60%
- Overall: 60-80%

**Real examples of delays**:
- mLoxAfr1: Assembly 2022, NCBI release 2023 (1-year delay)
- mLemCat1: Assembly 2021, NCBI release 2021 (same year)
- mEleMax1: Assembly 2022, NCBI release 2022 (same year)

**Use case**: Temporal trend analysis where accurate assembly dates are critical for identifying methodology vs. technology effects.

## S3 Path Normalization

Always normalize paths:
```python
def normalize_s3_path(s3_path):
    s3_path = s3_path.strip()
    s3_path = s3_path.replace('/assembly_vgp_hic_2.0/', '/assembly_vgp_HiC_2.0/')
    if not s3_path.endswith('/'):
        s3_path += '/'
    return s3_path
```

## AWS CLI Usage

**Public access** (no credentials):
```bash
aws s3 ls s3://genomeark/... --no-sign-request
aws s3 cp s3://genomeark/.../file.txt - --no-sign-request
```

**Prefer** `subprocess` + `aws s3` CLI with `--no-sign-request` over `boto3` (which requires credential config even for public access).

```python
# Simple and works
cmd = ['aws', 's3', 'cp', s3_path, '-', '--no-sign-request']
result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
```

**Timeouts**: Use 10-30s timeouts for robustness

## Expected Performance

- S3 path inference: ~5-10 seconds per ToLID
- QC data fetching: ~1-2 minutes per assembly
- Full dataset (700+ assemblies): 2-3 hours total

## Common Pitfalls

1. **Case sensitivity**: `assembly_vgp_hic_2.0` in table -> `assembly_vgp_HiC_2.0` in S3
2. **Subspecies names**: "Elephas maximus indicus" -> use only "Elephas_maximus" (CRITICAL)
3. **Limited path patterns**: Only trying `_2.0` paths misses ~40% of assemblies - always try 8+ patterns
4. **Directory evolution**: Merqury moved from nested to direct structure
5. **Failed QC runs**: Always validate genomescope ranges before use
6. **Subdirectory variations**: BUSCO/Merqury use different subdir names (c vs c1 vs p)
7. **File format variations**: Merqury may/may not have header line
8. **Haplotype-specific files**: HiC assemblies have separate hap1/hap2 BUSCO results
9. **Excluding `_curated` directories**: These have later curation dates, not original assembly dates

## Best Practices

1. **Path normalization**: Always fix case sensitivity
2. **Handle subspecies**: Extract only Genus + species (first 2 words)
3. **Try multiple patterns**: 8 assembly type patterns for maximum coverage
4. **Validate data**: Check ranges, detect failed analyses
5. **Exclude curated versions**: When extracting dates, skip `_curated` subdirectories
6. **Dynamic discovery**: List subdirectories, don't hardcode
7. **Error handling**: Continue on failures, report what succeeded
8. **Timeouts**: 10-30s per fetch, don't hang indefinitely
9. **Rate limiting**: 0.2s delay between fetches (respectful to AWS)

## Testing Examples

Confirmed working paths:
```bash
# GenomeScope - Pattern A (double underscore)
aws s3 cp s3://genomeark/species/Gastrophryne_carolinensis/aGasCar1/assembly_vgp_HiC_2.0/evaluation/genomescope/aGasCar1_genomescope__Summary.txt - --no-sign-request

# GenomeScope - Pattern C (single underscore)
aws s3 cp s3://genomeark/species/Platysternon_megacephalum/rPlaMeg1/assembly_vgp_HiC_2.0/evaluation/genomescope/rPlaMeg1_genomescope_Summary.txt - --no-sign-request

# GenomeScope - Pattern B (no prefix - older)
aws s3 cp s3://genomeark/species/Spea_bombifrons/aSpeBom1/assembly_vgp_standard_2.0/evaluation/genomescope/aSpeBom1_Summary.txt - --no-sign-request

# BUSCO
aws s3 cp s3://genomeark/species/Gastrophryne_carolinensis/aGasCar1/assembly_vgp_HiC_2.0/evaluation/busco/c/aGasCar1_HiC__busco_hap1_busco_short_summary.txt - --no-sign-request

# Merqury - Direct path (2024+)
aws s3 cp s3://genomeark/species/Ia_io/mIaxIox2/assembly_vgp_HiC_2.0/evaluation/merqury/mIaxIox2_qv/output_merqury.tabular - --no-sign-request

# Merqury - Nested path (2022)
aws s3 cp s3://genomeark/species/Gastrophryne_carolinensis/aGasCar1/assembly_vgp_HiC_2.0/evaluation/merqury/aGasCar1_qv/output_merqury.tabular - --no-sign-request
```
