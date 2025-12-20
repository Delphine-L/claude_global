---
name: bioinformatics-fundamentals
description: Core bioinformatics concepts including SAM/BAM format, sequencing technologies (Hi-C, HiFi, Illumina), quality metrics, and common data processing patterns. Essential for debugging alignment, filtering, and pairing issues.
version: 1.0.0
---

# Bioinformatics Fundamentals

Foundation knowledge for genomics and bioinformatics workflows. Provides essential understanding of file formats, sequencing technologies, and common data processing patterns.

## When to Use This Skill

- Working with sequencing data (PacBio HiFi, Hi-C, Illumina)
- Debugging SAM/BAM alignment or filtering issues
- Understanding paired-end vs single-end data
- Interpreting quality metrics (MAPQ, PHRED scores)
- Troubleshooting empty outputs or broken read pairs
- General bioinformatics data analysis

## SAM/BAM Format Essentials

### SAM Flags (Bitwise)

Flags are **additive** - a read can have multiple flags set simultaneously.

**Common Flags:**
- `0x0001` (1): Read is paired in sequencing
- `0x0002` (2): **Each segment properly aligned** (proper pair)
- `0x0004` (4): Read unmapped
- `0x0008` (8): Mate unmapped
- `0x0010` (16): Read mapped to reverse strand
- `0x0020` (32): Mate mapped to reverse strand
- `0x0040` (64): First in pair (R1/forward)
- `0x0080` (128): Second in pair (R2/reverse)
- `0x0100` (256): Secondary alignment
- `0x0400` (1024): PCR or optical duplicate
- `0x0800` (2048): Supplementary alignment

**Flag Combinations:**
- Properly paired R1: `99` (0x63 = 1 + 2 + 32 + 64)
- Properly paired R2: `147` (0x93 = 1 + 2 + 16 + 128)
- Unmapped read: `4`
- Mate unmapped: `8`

### Proper Pair Flag (0x0002)

**What "proper pair" means:**
- Both R1 and R2 are mapped
- Mapping orientations are correct (typically R1 forward, R2 reverse)
- Insert size is reasonable for the library
- Pair conforms to aligner's expectations

**Important:** Different aligners have different criteria for proper pairs!

### MAPQ (Mapping Quality)

**Formula:** `MAPQ = -10 * log10(P(mapping is wrong))`

**Common Thresholds:**
- `MAPQ >= 60`: High confidence (error probability < 0.0001%)
- `MAPQ >= 30`: Good quality (error probability < 0.1%)
- `MAPQ >= 20`: Acceptable (error probability < 1%)
- `MAPQ >= 10`: Low confidence (error probability < 10%)
- `MAPQ = 0`: Multi-mapper or unmapped

**Note:** MAPQ=0 can mean either unmapped OR equally good multiple mappings.

### CIGAR String

Represents alignment between read and reference:
- `M`: Match or mismatch (alignment match)
- `I`: Insertion in read vs reference
- `D`: Deletion in read vs reference
- `S`: Soft clipping (bases in read not aligned)
- `H`: Hard clipping (bases not in read sequence)
- `N`: Skipped region (for RNA-seq splicing)

**Example:** `100M` = perfect 100bp match
**Example:** `50M5I45M` = 50bp match, 5bp insertion, 45bp match

## Sequencing Technologies

### PacBio HiFi (High Fidelity)

**Characteristics:**
- Long reads: 10-25 kb typical
- High accuracy: >99.9% (Q20+)
- Circular Consensus Sequencing (CCS)
- Single-end data (though from circular molecules)
- Excellent for de novo assembly

**Best Mappers:**
- minimap2 presets: `map-pb`, `map-hifi`
- BWA-MEM2 can work but optimized for short reads

**Typical Use Cases:**
- De novo genome assembly
- Structural variant detection
- Isoform sequencing (Iso-Seq)
- Haplotype phasing

### Hi-C (Chromatin Conformation Capture)

**Characteristics:**
- Paired-end short reads (typically 100-150 bp)
- Read pairs capture chromatin interactions
- **R1 and R2 often map to different scaffolds/chromosomes**
- Requires careful proper pair handling
- Used for scaffolding and 3D genome structure

**Best Mappers:**
- BWA-MEM2 (paired-end mode)
- BWA-MEM (paired-end mode)

**Critical Concept:** Hi-C read pairs **intentionally** map to distant loci. Region filtering can easily break pairs!

**Typical Use Cases:**
- Genome scaffolding (connecting contigs)
- 3D chromatin structure analysis
- Haplotype phasing
- Assembly quality assessment

### Illumina Short Reads

**Characteristics:**
- Short reads: 50-300 bp
- Paired-end or single-end
- High throughput
- Well-established quality scores

**Best Mappers:**
- BWA-MEM2, BWA-MEM (general purpose)
- Bowtie2 (fast, local alignment)
- STAR (RNA-seq spliced alignment)

## Common Tools and Their Behaviors

### samtools view

**Purpose:** Filter, convert, and view SAM/BAM files

**Key Flags:**
- `-b`: Output BAM format
- `-h`: Include header
- `-f INT`: Require flags (keep reads WITH these flags)
- `-F INT`: Filter flags (remove reads WITH these flags)
- `-q INT`: Minimum MAPQ threshold
- `-L FILE`: Keep reads overlapping regions in BED file

**Important Behavior:**
- `-L` (region filtering) checks **each read individually**, not pairs
- Can break read pairs if mates map to different regions
- Flag filters (`-f`, `-F`) are applied **before** region filters (`-L`)

**Example - Filter for proper pairs:**
```bash
samtools view -b -f 2 input.bam > proper_pairs.bam
```

**Example - Filter by region (may break pairs):**
```bash
samtools view -b -L regions.bed input.bam > filtered.bam
```

**Example - Proper pairs in regions (correct order):**
```bash
samtools view -b -f 2 -L regions.bed input.bam > proper_pairs_in_regions.bam
```

### bamtools filter

**Purpose:** Advanced filtering with complex criteria

**Key Features:**
- Can filter on multiple properties simultaneously
- More strict about pair validation than samtools
- Supports JSON filter rules

**Common Filters:**
- `isPaired: true` - Read is from paired-end sequencing
- `isProperPair: true` - Read is part of proper pair
- `isMapped: true` - Read is mapped
- `mapQuality: >=30` - Mapping quality threshold

**Important Difference from samtools:**
- `isProperPair` is more strict than samtools `-f 2`
- Checks pair validity more thoroughly
- Better for ensuring R1/R2 match correctly

### samtools fastx

**Purpose:** Convert SAM/BAM to FASTQ/FASTA

**Output Modes:**
- `outputs: ["r1", "r2"]` - Separate forward and reverse for paired-end
- `outputs: ["other"]` - Single output for single-end data
- `outputs: ["r0"]` - All reads (mixed paired/unpaired)

**Filtering Options:**
- `inclusive_filter: ["2"]` - Require proper pair flag
- `exclusive_filter: ["4", "8"]` - Exclude unmapped or mate unmapped
- `exclusive_filter_all: ["8"]` - Exclude if mate unmapped

**Critical:** Use appropriate filters to ensure R1/R2 files match!

## Common Patterns and Best Practices

### Pattern 1: Filtering Paired-End Data by Regions

**WRONG WAY (breaks pairs):**
```bash
# Region filter first → breaks pairs when mates are in different regions
samtools view -b -L regions.bed input.bam | bamtools filter -isPaired -isProperPair
# Result: Empty output (all pairs broken)
```

**RIGHT WAY (preserves pairs):**
```bash
# Proper pair filter FIRST, then region filter
samtools view -b -f 2 -L regions.bed input.bam > output.bam
# Result: Pairs where both mates are in regions (or one mate in region, other anywhere)
```

**BEST WAY (both mates in regions):**
```bash
# Filter for proper pairs, then use paired-aware region filtering
samtools view -b -f 2 input.bam | \
  # Custom script to keep pairs where both mates in regions
```

### Pattern 2: Extracting FASTQ from Filtered BAM

**For Paired-End:**
```bash
# Ensure proper pairs before extraction
samtools fastx -1 R1.fq.gz -2 R2.fq.gz \
  --i1-flags 2 \  # Require proper pair
  --i2-flags 64,128 \  # Separate R1/R2
  input.bam
```

**For Single-End:**
```bash
# Simple extraction
samtools fastx -0 output.fq.gz input.bam
```

### Pattern 3: Quality Filtering

**Conservative (high quality):**
```bash
samtools view -b -q 30 -f 2 -F 256 -F 2048 input.bam
# MAPQ >= 30, proper pairs, no secondary/supplementary
```

**Permissive (for low-coverage data):**
```bash
samtools view -b -q 10 -F 4 input.bam
# MAPQ >= 10, mapped reads
```

## Common Issues and Solutions

### Issue 1: Empty Output After Region Filtering (Hi-C Data)

**Symptom:**
- BAM file non-empty before filtering
- Empty after region filtering + proper pair filtering
- Happens with paired-end data (especially Hi-C)

**Cause:**
- Region filter (`samtools view -L`) breaks read pairs
- One mate in region, other mate outside region
- Proper pair flag (0x2) is lost
- Subsequent `isProperPair` filter removes all reads

**Solution:**
```bash
# Apply proper pair filter BEFORE region filtering
samtools view -b -f 2 -L regions.bed input.bam > output.bam
```

**See Also:** `common-issues.md` for detailed troubleshooting

### Issue 2: R1 and R2 Files Have Different Read Counts

**Symptom:**
- Forward and reverse FASTQ files have different numbers of reads
- Downstream tools fail expecting matched pairs

**Cause:**
- Improper filtering broke some pairs
- One mate filtered out, other kept
- Extraction didn't require proper pairing

**Solution:**
```bash
# Require proper pairs during extraction
samtools fastx -1 R1.fq -2 R2.fq --i1-flags 2 input.bam
```

### Issue 3: Low Mapping Rate for Hi-C Data

**Symptom:**
- Many Hi-C reads unmapped or low MAPQ
- Expected for Hi-C due to chimeric reads

**Not Actually a Problem:**
- Hi-C involves ligation of distant DNA fragments
- Creates chimeric molecules
- Mappers may mark these as low quality or unmapped
- This is **normal** for Hi-C data

**Solution:**
- Use Hi-C-specific pipelines (e.g., HiC-Pro, Juicer)
- Don't filter too aggressively on MAPQ
- Accept lower mapping rates than DNA-seq

### Issue 4: Proper Pairs Lost After Mapping

**Symptom:**
- Few reads marked as proper pairs (flag 0x2)
- Expected paired-end data

**Possible Causes:**
1. Insert size distribution wrong (check aligner parameters)
2. Reference mismatch (reads from different assembly)
3. Poor library quality
4. Incorrect orientation flags passed to aligner

**Solution:**
```bash
# Check insert size distribution
samtools stats input.bam | grep "insert size"

# Check pairing flags
samtools flagstat input.bam
```

## Quality Metrics

### N50 and Related Metrics

**N50:** Length of the shortest contig at which 50% of total assembly is contained in contigs of that length or longer

**How to interpret:**
- Higher N50 = better contiguity
- Compare to expected chromosome/scaffold sizes
- Use with caution - can be misleading for fragmented assemblies

**Related Metrics:**
- **L50:** Number of contigs needed to reach N50
- **N90:** More stringent than N50 (90% coverage)
- **NG50:** N50 relative to genome size (better for comparisons)

### Coverage and Depth

**Coverage:** Percentage of reference bases covered by at least one read
**Depth:** Average number of reads covering each base

**Recommended Depths:**
- Genome assembly (HiFi): 30-50x
- Variant calling: 30x minimum
- RNA-seq: 20-40 million reads
- Hi-C scaffolding: 50-100x genomic coverage

## File Format Quick Reference

### FASTA
```
>sequence_id description
ATCGATCGATCG
ATCGATCG
```
- Header line starts with `>`
- Can span multiple lines
- No quality scores

### FASTQ
```
@read_id
ATCGATCGATCG
+
IIIIIIIIIIII
```
- Four lines per read
- Quality scores (Phred+33 encoding typical)
- Can be gzipped (.fastq.gz)

### BED
```
chr1    1000    2000    feature_name    score    +
```
- 0-based coordinates
- Used for regions, features, intervals
- Minimum 3 columns (chrom, start, end)

## Best Practices

### General

1. **Always check data type:** Paired-end vs single-end determines filtering strategy
2. **Understand your sequencing technology:** Hi-C behaves differently than HiFi
3. **Filter in the right order:** Proper pairs BEFORE region filtering
4. **Validate outputs:** Check file sizes, read counts, flagstat
5. **Use appropriate MAPQ thresholds:** Too stringent = lost data, too permissive = noise

### For Hi-C Data

1. **Expect distant read pairs:** Don't be surprised by different scaffolds
2. **Preserve proper pairs:** Critical for downstream scaffolding
3. **Use paired-aware tools:** Standard filters may break pairs
4. **Don't over-filter on MAPQ:** Hi-C often has lower MAPQ than DNA-seq

### For HiFi Data

1. **Single-end processing:** No pair concerns
2. **High quality expected:** Can use strict filters
3. **Use appropriate presets:** minimap2 `map-hifi` or `map-pb`
4. **Consider read length distribution:** HiFi reads vary in length

### For Tool Testing

1. **Create self-contained datasets:** Both mates in selected region
2. **Maintain proper pairs:** Essential for realistic testing
3. **Use representative data:** Subsample proportionally, not randomly
4. **Verify file sizes:** Too small = overly filtered

## Related Skills

- **vgp-pipeline** - VGP workflows process Hi-C and HiFi data
- **galaxy-tool-wrapping** - Galaxy tools work with SAM/BAM and sequencing data formats
- **galaxy-workflow-development** - Workflows process sequencing data

## Supporting Documentation

- **reference.md:** Detailed format specifications and tool documentation
- **common-issues.md:** Comprehensive troubleshooting guide with examples

## Version History

- **v1.0.0:** Initial release with SAM/BAM, Hi-C, HiFi, common filtering patterns
