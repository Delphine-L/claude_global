---
name: vgp-pipeline
description: VGP assembly pipeline - Galaxy workflow selection, execution patterns, QC checkpoints, and batch orchestration
---

# VGP Assembly Pipeline Skill

## Overview
The Vertebrate Genome Project (VGP) assembly pipeline consists of Galaxy workflows for producing high-quality, phased, chromosome-level genome assemblies. This skill covers workflow selection, execution patterns, and quality control checkpoints.

**Supporting files** (detailed reference material):
- [RESOURCE_ANALYSIS.md](RESOURCE_ANALYSIS.md) - Workflow canonical names, official/non-official filtering, metric availability, tool-level resource optimization
- [DATA_INTEGRATION.md](DATA_INTEGRATION.md) - ToLID patterns, GenomeArk S3 integration, NCBI accession recovery, Meryl k-mer management, species-metrics merging
- [QUALITY_VALIDATION.md](QUALITY_VALIDATION.md) - Curation impact analysis, GenomeScope data validation, assembly size interpretation, communication patterns

## Trajectories (by frequency of use)

### Trajectory A: HiFi + Hi-C (Most Common)
- **Inputs**: HiFi Reads, Hi-C Reads
- **Path**: WF1 -> WF4 -> [WF6] -> WF8 -> WF9 -> PreCuration
- **Output**: HiC Phased assembly (hap1/hap2)
- **WF6**: Optional (can skip directly to WF8)

### Trajectory B: HiFi + Trio
- **Inputs**: HiFi Reads, Hi-C Reads, Parental Reads
- **Path**: WF2 -> WF5 -> [WF6] -> WF8 -> WF9 -> PreCuration
- **Output**: Trio Phased assembly (maternal/paternal)
- **WF6**: Optional (can skip directly to WF8)

### Trajectory C: HiFi Only (Least Common)
- **Inputs**: HiFi Reads only
- **Path**: WF1 -> WF3 -> WF6 -> WF9 -> PreCuration
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
VGP2 -> VGP5 workflows. For species without parental data (non-trio datasets),
we performed VGP1 -> VGP3 workflows."
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

## IWC Workflow Versions (as of March 2026)

| Workflow | IWC Repo | Latest Version | Dockstore ID |
|----------|----------|----------------|--------------|
| WF1 | kmer-profiling-hifi-VGP1 | v0.6 | github.com/iwc-workflows/kmer-profiling-hifi-VGP1/main |
| WF4 | Assembly-Hifi-HiC-phasing-VGP4 | v0.5 | github.com/iwc-workflows/Assembly-Hifi-HiC-phasing-VGP4/main |
| WF8 | Scaffolding-HiC-VGP8 | v3.3 | github.com/iwc-workflows/Scaffolding-HiC-VGP8/main |

### Recent Breaking Changes

**BUSCO -> Compleasm (WF4 v0.5, WF8 v3.3)**:
- Compleasm (`0.2.5+galaxy0`) replaced BUSCO for gene completeness assessment
- Uses miniprot for protein-to-genome alignment (faster than BUSCO's BLAST approach)
- Same output categories: Complete (Single-copy + Duplicated), Fragmented, Missing
- Input parameters still named "Database for Busco Lineage" and "Lineage" (backward compat)

**Hi-C reads format change (WF4 v0.5, WF8 v3.3)**:
- Changed from separate forward/reverse datasets to **list:paired collection**
- Users must build a list:paired collection before running these workflows

**New required inputs across all workflows**:
- Species Name (text) -- used for workflow reports
- Assembly Name (text) -- used for workflow reports

**WF4 additional new inputs**: Trim Hi-C reads? (boolean), Name for Haplotype 1/2 (defaults: Hap1/Hap2), Bits for bloom filter (default: 37)
**WF8 additional new inputs**: Haplotype (restricted: Haplotype 1/2, Maternal/Paternal, Primary/Alternate), Trim Hi-C Data? (boolean), Minimum Mapping Quality (default: 10)

### Verifying IWC Versions

Check latest versions via Dockstore API:
```
https://dockstore.org/api/ga4gh/trs/v2/tools/%23workflow%2Fgithub.com%2Fiwc-workflows%2F{REPO}%2Fmain/versions
```

Check workflow inputs by fetching the .ga file from GitHub:
```
https://raw.githubusercontent.com/iwc-workflows/{REPO}/main/{WORKFLOW_NAME}.ga
```

## Haplotype Execution Patterns

### Run Once (Both Haplotypes Together)
- WF1, WF2 (K-mer profiling)
- WF3, WF4, WF5 (Assembly)
- WF6 (Purge Duplicates) - *depends on trajectory*
- PreCuration

### Run Twice (x2 per Haplotype)
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
| HiFi | 30x | Diploid genome |
| Hi-C | 60x | Diploid genome |

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
- If both in main haplotype -> two separate scaffolds expected
- Example: Asian elephant 2n=56, n=28, has X+Y -> expect 29 scaffolds

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

**Wrong**: Compare diploid expected (2n) to haploid assembly
- Results in ~50% achievement rates
- Biologically incorrect

**Wrong**: Use haploid (n) when both sex chromosomes present
- Underestimates by 1
- Shows artificial "extra scaffold" problem

**Correct**: Use adjusted haploid (n or n+1 depending on sex chromosome configuration)

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
- Blue badge (`#e3f2fd`): "x2 per haplotype" - runs separately
- Green badge (`#e8f5e9`): "both haplotypes" - runs together

## Input Data Labels
- HiFi Reads: Blue (`#4285f4`)
- Hi-C Reads: Green (`#34a853`)
- Parental Reads: Red (`#ea4335`)

## Summary Table

| Trajectory | Inputs | K-mer | Assembly | Purge | Scaffold | Finish | Output |
|------------|--------|-------|----------|-------|----------|--------|--------|
| A | HiFi+HiC | WF1 | WF4 | [WF6] | WF8 | WF9->Pre | hap1/hap2 |
| B | HiFi+Trio | WF2 | WF5 | [WF6] | WF8 | WF9->Pre | mat/pat |
| C | HiFi only | WF1 | WF3 | WF6 | - | WF9->Pre | pri/alt |

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

## References
- [VGP Galaxy Workflows](https://github.com/galaxyproject/iwc) - VGP workflows
- [Vertebrate Genome Project](https://vertebrategenomesproject.org/)
