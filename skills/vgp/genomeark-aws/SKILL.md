---
name: genomeark-aws
description: Access and navigate GenomeArk AWS S3 bucket - VGP assemblies, QC data, and species directory structure
allowed-tools: Read, Grep, Glob, Bash
---

# GenomeArk AWS S3 Data Repository

Comprehensive guide for accessing and navigating the GenomeArk AWS S3 public bucket containing Vertebrate Genomes Project (VGP) assemblies and quality control data.

**Supporting files** (read as needed for detailed code and strategies):
- [assembly-date-extraction.md](./assembly-date-extraction.md) - Extract assembly dates from FASTA filenames, validation rules
- [qc-data-fetching.md](./qc-data-fetching.md) - GenomeScope, BUSCO, Merqury, Meryl fetching code and parsing
- [best-practices.md](./best-practices.md) - AWS CLI patterns, batch processing, common pitfalls, testing examples, version history

## When to Use This Skill

Use this skill when:
- Accessing VGP genome assemblies from GenomeArk AWS S3
- Fetching QC metrics (GenomeScope, BUSCO, Merqury) for genomic analyses
- Downloading genome evaluation data for comparative studies
- Accessing meryl k-mer histograms for GenomeScope analysis
- Building automated pipelines that fetch VGP data
- Troubleshooting S3 path issues or missing data
- Working with species-specific genome data from VGP

## Repository Overview

**GenomeArk** is a public AWS S3 bucket (`s3://genomeark/`) hosting:
- VGP genome assemblies (primary, alternate, trio)
- Quality control metrics (GenomeScope, BUSCO, Merqury)
- Intermediate files (meryl databases, k-mer histograms)
- Assembly evaluation reports
- Haplotype-resolved assemblies

**Access Method**: Public bucket requiring **no AWS credentials** when using `--no-sign-request`

**Critical Discovery**: GenomeArk structure has evolved over time (2022 -> 2024+). Always implement fallback path patterns for reliability.

## Directory Structure

### Base Structure

```
s3://genomeark/
└── species/
    └── {Genus_species}/          # e.g., Rhinolophus_ferrumequinum
        └── {ToLID}/               # e.g., mRhiFer1 (VGP specimen ID)
            ├── assembly_vgp_{type}_{version}/
            │   ├── evaluation/     # QC metrics (MAIN ACCESS POINT)
            │   │   ├── genomescope/
            │   │   ├── busco/
            │   │   ├── merqury/
            │   │   └── ...
            │   └── intermediates/  # K-mer databases, temp files
            │       └── meryl/
            └── genomic_data/      # Raw sequencing data folders
```

### Assembly Directory Variations

**assembly_vgp_{type}_{version}** - Standard VGP Patterns:
- `assembly_vgp_HiC_2.0` - Hi-C phased assembly (case-sensitive!)
- `assembly_vgp_standard_2.0` - Standard assembly without Hi-C
- `assembly_vgp_hic_2.0` - Alternative Hi-C naming
- `assembly_vgp_trio_2.0` - Trio-binned assembly

**Legacy Versions** (2019-2021 assemblies):
- `assembly_vgp_standard_1.6` - Version 1.6 (common in fish, birds)
- `assembly_vgp_standard_1.0` - Version 1.0 (early assemblies)
- `assembly_vgp_HiC_1.6` - Hi-C version 1.6
- `assembly_vgp_HiC_1.0` - Hi-C version 1.0
- `assembly_vgp_HiC_1.4` - Hi-C version 1.4

**Verkko Assemblies** (diploid assemblies):
- `assembly_verkko_1.4/` - Verkko version 1.4
- `assembly_verkko_1.1-0.1/` - Verkko version 1.1-0.1
- `assembly_verkko_1.1-0.1-freeze/` - Frozen version
- `assembly_verkko_1.1-0.2/` - Version 1.1-0.2
- `assembly_verkko_1.4.1r/` - Revised version 1.4.1

**Clade-Specific Directories** (2023+ specialized assemblies):
- `assembly_primate_v1.4.2/` - Primate-specific pipeline
- `assembly_fish_*` - Fish-specific (potential)
- `assembly_bird_*` - Bird-specific (potential)

**Institution-Specific Directories**:
- `assembly_rockefeller/` - Rockefeller University assemblies
- `assembly_cambridge/` - Cambridge assemblies
- `assembly_MT_rockefeller/` - Case variation
- `assembly_mt_rockefeller/` - Lowercase variation
- `assembly_mt_milan/` - Milan institute

**Directories Without "assembly_" Prefix** (rare):
- `vgp_standard_1.6/` - Standard v1.6 without prefix
- `vgp_standard_1.0/` - Standard v1.0 without prefix
- `vgp_HiC_1.6/` - Hi-C v1.6 without prefix

**Curated Assemblies** (post-manual curation):
- `assembly_curated/` - **Exclude for date extraction** (post-curation dates)

**CRITICAL CASE SENSITIVITY**:
- Metadata may store: `assembly_vgp_hic_2.0` (lowercase)
- S3 requires: `assembly_vgp_HiC_2.0` (mixed case!)
- **Always normalize** before fetching

**COMPREHENSIVE PATTERN MATCHING**:
- **Don't stop at first match**: Try ALL valid paths
- **Pri/alt assemblies** often use legacy versions (1.6, 1.0)
- **Phased assemblies** typically use version 2.0
- **Verkko assemblies** are diploid, use different naming
- **Coverage improvement**: Using all patterns -> 47-62% vs 27% with basic patterns

## Data Access Summary

For detailed fetching code and parsing logic, see [qc-data-fetching.md](./qc-data-fetching.md).

| Data Type | Location | Key Notes |
|-----------|----------|-----------|
| **GenomeScope** | `evaluation/genomescope/` | 3 filename patterns (double/single/no underscore); validate heterozygosity ranges |
| **BUSCO** | `evaluation/busco/{subdir}/` | Dynamic subdir search (c/, p/, c1/, p1/); parse `C:XX.X%` |
| **Merqury** | `evaluation/merqury/` | Two path layouts (direct vs nested); QV in column 4 |
| **Meryl hist** | `intermediates/meryl/` | Use `.hist` file only (~700KB), not full database (~10GB) |
| **Assembly dates** | FASTA filenames | YYYYMMDD stamps; see [assembly-date-extraction.md](./assembly-date-extraction.md) |
| **Technology** | `genomic_data/` subfolders | `pacbio_hifi/` -> HiFi, `ont/` -> ONT, etc. |

### Path Normalization (used by all fetching functions)

```python
def normalize_s3_path(s3_path):
    """Normalize path for GenomeArk (case sensitivity!)"""
    if not s3_path:
        return None
    s3_path = s3_path.replace('/assembly_vgp_hic_2.0/', '/assembly_vgp_HiC_2.0/')
    if not s3_path.endswith('/'):
        s3_path += '/'
    return s3_path
```

### GenomeScope Filename Patterns (TRY ALL THREE!)

- Pattern A: `{ToLID}_genomescope__Summary.txt` (double underscore, most common)
- Pattern C: `{ToLID}_genomescope_Summary.txt` (single underscore, easily missed)
- Pattern B: `{ToLID}_Summary.txt` (no prefix, older assemblies)

Checking only A and B causes ~30-40% of data to be missed.

### GenomeScope Validation

Reject failed runs where heterozygosity range > 50% or max > 95%. A range of 0%-100% indicates complete model failure.

### Meryl Histograms - Direct HTTPS URLs (for Galaxy import)

```
https://genomeark.s3.amazonaws.com/species/{species}/{tolid}/assembly_vgp_standard_1.0/intermediates/meryl/{tolid}.cut.meryl.hist
```

## Quick Reference

**AWS CLI pattern** (prefer over boto3 for public buckets):
```python
cmd = ['aws', 's3', 'cp', s3_path, '-', '--no-sign-request']
result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
```

**Rate limiting**: 0.2s delay between requests.

**Common pitfalls**: Case sensitivity (`hic` vs `HiC`), directory evolution (2022 vs 2024 layouts), downloading full meryl databases instead of `.hist` files. See [best-practices.md](./best-practices.md) for full list.
