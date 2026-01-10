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

### After WF9 (Decontamination)
- Review contamination reports
- Check for unexpected removals

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

## References
- [VGP Galaxy Workflows](https://github.com/Delphine-L/iwc/tree/VGP)
- [Vertebrate Genome Project](https://vertebrategenomesproject.org/)
