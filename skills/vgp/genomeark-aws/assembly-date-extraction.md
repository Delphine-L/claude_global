# Assembly Date Extraction

**Location**: Assembly FASTA files with YYYYMMDD timestamps
**Purpose**: Extract accurate assembly completion dates (vs NCBI release dates)

## Why Important

- NCBI release dates may be 1-2 years after actual assembly completion
- Average delay: **1.1 years** (64% of assemblies have delayed release)
- Critical for temporal analyses and technology transition studies

## File Naming Pattern

```
{ToLID}.{type}.{haplotype}.YYYYMMDD.fasta.gz
```

**Examples**:
```
mLoxAfr1.HiC.hap1.20221209.fasta.gz         → 2022 (Released 2023)
mPanPan1.dip.20230906.fasta                 → 2023 (Verkko)
fAngAng1.standard.hap1.20190815.fasta.gz    → 2019 (Legacy 1.6)
```

**Assembly Types**:
- `HiC` - Hi-C phased assemblies
- `standard` - Standard assemblies
- `dip` - Diploid (Verkko assemblies)
- `hap1`, `hap2` - Haplotype-specific
- `pri`, `alt` - Primary/alternate haplotypes

## Extraction Strategy

**Algorithm**:
1. Find ALL valid assembly directories for a ToLID
2. Try each directory (prioritize recent versions first)
3. List files recursively, excluding `_curated` directories
4. Extract all 8-digit dates (YYYYMMDD) from filenames
5. Validate dates (2000-2030, valid month/day)
6. Return most recent year found

**Critical: Try ALL Paths**:
```python
def extract_assembly_year_comprehensive(tolid, scientific_name):
    """
    Extract assembly year using comprehensive pattern matching.

    Returns most recent assembly year from date-stamped files.
    Excludes _curated directories (post-curation dates).
    """
    species_parts = scientific_name.strip().split()
    species_name = f"{species_parts[0]}_{species_parts[1]}"  # Handle subspecies

    # Build comprehensive path list (30+ patterns)
    all_paths = []

    # Standard patterns (version 2.0)
    patterns_v2 = [
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_vgp_HiC_2.0/",
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_vgp_standard_2.0/",
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_vgp_hic_2.0/",
    ]

    # Legacy patterns (version 1.6, 1.0, 1.4)
    patterns_legacy = [
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_vgp_standard_1.6/",
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_vgp_standard_1.0/",
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_vgp_HiC_1.6/",
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_vgp_HiC_1.0/",
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_vgp_HiC_1.4/",
    ]

    # Without "assembly_" prefix
    patterns_no_prefix = [
        f"s3://genomeark/species/{species_name}/{tolid}/vgp_standard_1.6/",
        f"s3://genomeark/species/{species_name}/{tolid}/vgp_standard_1.0/",
        f"s3://genomeark/species/{species_name}/{tolid}/vgp_HiC_1.6/",
    ]

    # Institution-specific
    patterns_institution = [
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_rockefeller/",
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_cambridge/",
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_MT_rockefeller/",
        f"s3://genomeark/species/{species_name}/{tolid}/assembly_mt_milan/",
    ]

    # Try standard paths first
    all_paths.extend(patterns_v2 + patterns_legacy + patterns_no_prefix + patterns_institution)

    # Check which paths exist
    valid_paths = []
    for path in all_paths:
        result = subprocess.run(
            ['aws', 's3', 'ls', path, '--no-sign-request'],
            capture_output=True, timeout=10
        )
        if result.returncode == 0:
            valid_paths.append(path)

    # Dynamic discovery for verkko and clade-specific
    base_path = f"s3://genomeark/species/{species_name}/{tolid}/"
    list_result = subprocess.run(
        ['aws', 's3', 'ls', base_path, '--no-sign-request'],
        capture_output=True, text=True, timeout=10
    )

    if list_result.returncode == 0:
        for line in list_result.stdout.split('\n'):
            if 'PRE' in line and 'assembly' in line:
                dir_name = line.split('PRE')[1].strip().rstrip('/')
                dir_path = base_path + dir_name + '/'

                # Check for verkko or clade-specific
                if any(keyword in dir_name.lower() for keyword in ['verkko', 'primate', 'fish', 'bird']):
                    if dir_path not in valid_paths:
                        valid_paths.append(dir_path)

    # Add curated LAST (often lacks dates, but try if nothing else works)
    curated_path = f"s3://genomeark/species/{species_name}/{tolid}/assembly_curated/"
    if curated_path not in valid_paths:
        valid_paths.append(curated_path)

    # Try each path until we find dates
    for s3_path in valid_paths:
        # List files recursively
        result = subprocess.run(
            ['aws', 's3', 'ls', s3_path, '--recursive', '--no-sign-request'],
            capture_output=True, text=True, timeout=60
        )

        if result.returncode != 0:
            continue

        # Extract dates from filenames (exclude _curated in path)
        dates = []
        for line in result.stdout.split('\n'):
            if line.strip() and '_curated' not in line:
                # Find 8-digit dates
                matches = re.findall(r'(\d{8})', line)
                for date_str in matches:
                    year = int(date_str[:4])
                    month = int(date_str[4:6])
                    day = int(date_str[6:8])

                    # Validate
                    if 2000 <= year <= 2030 and 1 <= month <= 12 and 1 <= day <= 31:
                        dates.append(date_str)

        # If dates found, return most recent year
        if dates:
            most_recent = max(dates)
            return int(most_recent[:4])

    return None  # No dates found in any path
```

## Expected Coverage

- **Comprehensive approach** (30+ patterns): 47-62% of assemblies
- **Basic approach** (3 patterns): 24% of assemblies
- **Intermediate approach** (8 patterns): 27% of assemblies

**Assembly Type Differences**:
- **Phased assemblies**: 55% found (typically use version 2.0)
- **Pri/alt assemblies**: 43% found (often use legacy versions 1.6, 1.0)
- **Verkko assemblies**: Found with dynamic discovery

**Date Validation Results**:
- Average delay: 1.1 years between assembly and NCBI release
- 64% of assemblies released 1-2 years after completion
- 35% released same year as assembled
- Maximum observed delay: 2 years

## Critical Validation: assembly_year vs release_year

The extraction script can produce false positives by matching S3 **file sizes**
as YYYYMMDD patterns (e.g., a 2028-byte file -> year 2028). Always validate:

```python
# Invalidate assembly_year where it exceeds release_year (impossible)
bad = df[df['assembly_year'] > df['release_year']]
print(f"False positives: {len(bad)} assemblies")
df.loc[df['assembly_year'] > df['release_year'], 'assembly_year'] = float('nan')
```

**Known false positives found** (2026-03-11):
- bFalBia1 (Falco biarmicus): asm=2028 from 2028-byte BUSCO .gff file
- aRhiBiv1 (Rhinatrema bivittatum): asm=2026 from 202611172-byte .las file
- 6 additional off-by-one errors (asm=2023, rel=2022)

**Rule**: assembly_year must be <= release_year. Remove any that violate this.
