---
name: bioinformatics-fundamentals
description: Core bioinformatics concepts including SAM/BAM format, AGP genome assembly format, sequencing technologies (Hi-C, HiFi, Illumina), quality metrics, and common data processing patterns. Essential for debugging alignment, filtering, pairing issues, and AGP coordinate validation.
version: 1.1.0
---

# Bioinformatics Fundamentals

Foundation knowledge for genomics and bioinformatics workflows. Provides essential understanding of file formats, sequencing technologies, and common data processing patterns.

## When to Use This Skill

- Working with sequencing data (PacBio HiFi, Hi-C, Illumina)
- Debugging SAM/BAM alignment or filtering issues
- Processing AGP files for genome assembly curation
- Validating AGP coordinate systems and unloc assignments
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

### AGP
```
chr1    1    5000    1    W    contig_1    1    5000    +
chr1    5001 5100    2    U    100    scaffold    yes    proximity_ligation
```
- Tab-delimited genome assembly format
- 1-based closed coordinates [start, end]
- Describes construction of objects from components
- Object and component lengths must match
- See AGP Format section for complete specification

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

## GenomeArk AWS S3 Data Access

### Overview
GenomeArk (s3://genomeark/) is a public AWS S3 bucket containing VGP genome assemblies and QC data. Access requires no credentials using `--no-sign-request`.

**Critical Discovery**: GenomeArk S3 structure has evolved over time (2022 → 2024). Always try multiple path patterns for reliability.

### Directory Structure Evolution

**Base structure**:
```
s3://genomeark/species/{Species_name}/{ToLID}/assembly_vgp_{type}_2.0/evaluation/
```

**Key variation**:
- Table may store: `assembly_vgp_hic_2.0`
- S3 requires: `assembly_vgp_HiC_2.0` (case-sensitive!)
- **Always normalize**: Replace `hic` → `HiC` before fetching

### QC Data Locations and Formats

#### 1. GenomeScope (Genome Size, Heterozygosity, Repeat Content)

**Path**: `{assembly}/evaluation/genomescope/`

**Filename patterns** (try in order):
1. `{ToLID}_genomescope__Summary.txt` (Pattern A: double underscore - most common)
2. `{ToLID}_genomescope_Summary.txt` (Pattern C: single underscore ⭐ EASILY MISSED)
3. `{ToLID}_Summary.txt` (Pattern B: no prefix - older assemblies)

**⚠️ CRITICAL**: ALL THREE patterns must be checked! Pattern C (single underscore) was discovered in Feb 2026 during debugging - checking only patterns A and B causes ~30-40% of data to be missed!

**Example of Pattern C**:
- Missing: `rPlaMeg1_genomescope__Summary.txt` ✗
- Found: `rPlaMeg1_genomescope_Summary.txt` ✓

**⚠️ CRITICAL: Validate Data Quality**

Failed GenomeScope runs show unrealistic ranges:
```
Heterozygous (ab)    0%    100%     ← FAILED RUN - DO NOT USE
```

Good runs show narrow ranges:
```
Heterozygous (ab)    0.49%    0.54%  ← VALID - use max value
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

#### 2. BUSCO (Assembly Completeness)

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

#### 3. Merqury (Assembly QV Scores)

**⚠️ TWO PATH PATTERNS** (structure changed 2022 → 2024):

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

### Complete Fetching Strategy

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

### Common Pitfalls

1. **Case sensitivity**: `assembly_vgp_hic_2.0` in table → `assembly_vgp_HiC_2.0` in S3
2. **Directory evolution**: Merqury moved from nested to direct structure
3. **Failed QC runs**: Always validate genomescope ranges before use
4. **Subdirectory variations**: BUSCO/Merqury use different subdir names (c vs c1 vs p)
5. **File format variations**: Merqury may/may not have header line
6. **Haplotype-specific files**: HiC assemblies have separate hap1/hap2 BUSCO results

### Best Practices

1. **Path normalization**: Always fix case sensitivity
2. **Try multiple patterns**: Newer → older structure
3. **Validate data**: Check ranges, detect failed analyses
4. **Dynamic discovery**: List subdirectories, don't hardcode
5. **Error handling**: Continue on failures, report what succeeded
6. **Timeouts**: 10-30s per fetch, don't hang indefinitely
7. **Rate limiting**: 0.2s delay between fetches (respectful to AWS)

### AWS CLI vs boto3

For **public buckets** like GenomeArk:
- **Prefer**: `subprocess` + `aws s3` CLI with `--no-sign-request`
- **Avoid**: `boto3` (requires credential config even for public access)

```python
# Simple and works
cmd = ['aws', 's3', 'cp', s3_path, '-', '--no-sign-request']
result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
```

### Testing Examples

Confirmed working paths:
```bash
# GenomeScope - Pattern A (double underscore)
aws s3 cp s3://genomeark/species/Gastrophryne_carolinensis/aGasCar1/assembly_vgp_HiC_2.0/evaluation/genomescope/aGasCar1_genomescope__Summary.txt - --no-sign-request

# GenomeScope - Pattern C (single underscore) ⭐ NEW PATTERN
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

⚠️ **Warning**: Chromosome-level assemblies often report fewer chromosomes than actual diploid number

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

**⚠️ WARNING**: Column names are NOT standardized across datasets - always verify which is which!

### Which Count to Use When

**Use HAPLOID (n) for:**
- ✅ Per-assembly comparisons (scaffolds per assembly)
- ✅ Chromosome assignment ratios
- ✅ Expected vs observed chromosome counts
- ✅ Telomere counts (2 per chromosome × n chromosomes)
- ✅ Scaffold-to-chromosome mapping

**Use DIPLOID (2n) for:**
- ✅ Cell-level comparisons
- ✅ Comparing to diploid karyotypes
- ✅ Ploidy analyses
- ✅ Cytogenetic studies

### Real-World Example: VGP Assembly Analysis

**Problem**: Used `num_chromosomes` (diploid) for per-assembly comparison

**Result**: All assemblies appeared to have 2× expected chromosomes

**Fix**: Changed to `total_number_of_chromosomes` (haploid)

**Validation**: Ratio now ~1.0 instead of ~2.0

```python
# WRONG - uses diploid count
fig, ax = plt.subplots()
ax.scatter(df['num_chromosomes'], df['num_scaffolds_assigned'])
# Result: Everything appears at 2× diagonal

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
- Improves tree coverage metrics (e.g., 506→508 species)

**Common Files Needing Synchronization:**
- `Tree_final.nwk` - Main phylogenetic tree
- `itol_taxonomic_colorstrip_final.txt` - Taxonomic annotations
- `species_*_methods.csv` - Species classification configs
- All iTOL visualization config files

### Tree Coverage Analysis Pattern

When reconciling phylogenetic trees with species datasets:

**Coverage Metric:**
```
Coverage = (Species in both tree AND dataset) / (Total species in tree) × 100%
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

## AGP Format (A Golden Path)

### Overview
AGP (A Golden Path) format describes how assembled sequences (chromosomes, scaffolds) are constructed from component sequences (contigs, scaffolds) and gaps. Critical for genome assembly curation and submission to NCBI/EBI.

### When to Use This Knowledge

- Processing genome assemblies for submission to databases
- Curating chromosome-level assemblies
- Splitting haplotype assemblies
- Assigning unlocalized scaffolds (unlocs)
- Debugging AGP validation errors
- Converting between assembly representations

### AGP Format Structure

**Tab-delimited format with 9 columns for sequence lines (type W) or 8+ columns for gap lines (type U/N)**

**Sequence Lines (Column 5 = 'W'):**
```
object  obj_beg  obj_end  part_num  W  component_id  comp_beg  comp_end  orientation
```

**Gap Lines (Column 5 = 'U' or 'N'):**
```
object  obj_beg  obj_end  part_num  gap_type  gap_length  gap_type  linkage  linkage_evidence
```

### Critical Coordinate Rules

**Rule 1: Object and Component Lengths MUST Match**

For sequence lines, the span in the object MUST equal the span in the component:
```
(obj_end - obj_beg + 1) == (comp_end - comp_beg + 1)
```

**Example - CORRECT:**
```
Scaffold_47_unloc_1  1  54360  1  W  scaffold_23.hap1  19274039  19328398  -
# Object length: 54360 - 1 + 1 = 54,360 bp
# Component length: 19328398 - 19274039 + 1 = 54,360 bp ✓
```

**Example - INCORRECT:**
```
Scaffold_47_unloc_1  1  19328398  1  W  scaffold_23.hap1  19274039  19328398  -
# Object length: 19328398 - 1 + 1 = 19,328,398 bp
# Component length: 19328398 - 19274039 + 1 = 54,360 bp ✗
# ERROR: Lengths don't match!
```

**Rule 2: Component Numbering Restarts for New Objects**

Each object (column 1) has its own component numbering (column 4) starting at 1:
```
Scaffold_10         1  30578279  1  W  scaffold_4.hap2   1  30578279  -
Scaffold_10_unloc_1 1  65764     1  W  scaffold_74.hap2  1  65764     +  # ← Starts at 1, not 3!
```

**Rule 3: Sequential Component Numbering Within Objects**

Component numbers increment sequentially (gaps and sequences both count):
```
Scaffold_2  1        1731008   1  W  scaffold_25.hap1  1  1731008  -
Scaffold_2  1731009  1731108   2  U  100  scaffold  yes  proximity_ligation
Scaffold_2  1731109  1956041   3  W  scaffold_70.hap1  1  224933   -
```

### Common AGP Processing Issues

#### Issue 1: Incorrect Object Coordinates When Creating Unlocs

**Symptom:**
```
ERROR: object coordinates (1, 19328398) and component coordinates (19274039, 19328398)
do not have the same length
```

**Cause:**
When converting a region of a scaffold into an unlocalized sequence (unloc), the object coordinates must represent the **length** of the extracted region, not the original component end coordinate.

**Wrong Approach:**
```python
# Setting object end to component end coordinate
agp_df.loc[index, 'chr_end'] = agp_df.loc[index, 'scaff_end']  # ✗ WRONG
```

**Correct Approach:**
```python
# Calculate actual length from component coordinates
agp_df.loc[index, 'chr_end'] = int(agp_df.loc[index, 'scaff_end']) - int(agp_df.loc[index, 'scaff_start']) + 1  # ✓ CORRECT
```

#### Issue 2: Component Numbering Not Reset for New Objects

**Symptom:**
Unloc scaffolds have component numbers > 1 when they should start at 1.

**Cause:**
When creating a new object (unloc scaffold), component numbering wasn't reset.

**Solution:**
```python
# When creating unlocs, reset component number
agp_df.loc[index, '#_scaffs'] = 1  # Column 4: component number
```

#### Issue 3: AGPcorrect Accumulating Coordinates

**Symptom:**
Unloc sequences inherit cumulative coordinates from parent scaffolds.

**Cause:**
AGPcorrect adjusts coordinates based on sequence length corrections. When scaffolds are later split into unlocs, the accumulated corrections need to be recalculated based on actual component spans.

**Solution:**
Always recalculate object coordinates from component spans when creating new objects (unlocs).

### AGP Processing Best Practices

#### 1. Coordinate System Understanding

- **Object coordinates (columns 2-3):** Position within the assembled object (1-based, inclusive)
- **Component coordinates (columns 7-8):** Position within the source sequence (1-based, inclusive)
- Both use **1-based closed intervals** [start, end]
- Length calculation: `end - start + 1`

#### 2. Creating Unlocalized Sequences (Unlocs)

```python
# When extracting a region to create an unloc:
# 1. Calculate the actual length of the region
length = int(comp_end) - int(comp_start) + 1

# 2. Set object coordinates for the new unloc
obj_start = 1  # Always starts at 1
obj_end = length  # Equals the length

# 3. Reset component number
component_num = 1  # New object, new numbering

# 4. Rename the object
new_object_name = f"{parent_scaffold}_unloc_{unloc_number}"
```

#### 3. Validating AGP Files

**Use NCBI's AGP validator:**
```bash
agp_validate assembly.agp
```

**Common validation checks:**
- Object/component length match
- Sequential component numbering
- No coordinate overlaps
- Gap specifications valid
- Orientation values (+, -, ?, 0, na)

#### 4. Handling Haplotype-Split Assemblies

When splitting diploid assemblies into haplotypes:
1. Identify haplotype markers in sequence names (H1/hap1, H2/hap2)
2. Maintain proper pairing information
3. Process unlocs separately per haplotype
4. Remove haplotig duplications
5. Track gaps appropriately (especially proximity ligation gaps)

### AGP Coordinate Debugging Pattern

When encountering coordinate errors:

```python
# For each AGP line, verify:
obj_length = int(obj_end) - int(obj_beg) + 1
comp_length = int(comp_end) - int(comp_beg) + 1

assert obj_length == comp_length, f"Length mismatch: obj={obj_length}, comp={comp_length}"

# For sequential component numbers:
assert comp_num == expected_num, f"Component number gap: got {comp_num}, expected {expected_num}"
```

### AGP File Structure by Assembly Stage

**1. Raw Assembly AGP:**
- Direct representation from assembler
- May have incorrect sequence lengths
- Needs coordinate correction (AGPcorrect)

**2. Corrected AGP:**
- Sequence lengths match actual FASTA
- Coordinates adjusted for length discrepancies
- Ready for haplotype splitting

**3. Haplotype-Split AGP:**
- Separate files per haplotype
- Unlocs identified but not separated
- Haplotigs marked but not removed

**4. Final Curated AGP:**
- Unlocs separated into individual objects
- Haplotigs removed to separate file
- Proximity ligation gaps cleaned
- Ready for database submission

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

## GenomeArk S3 Data Access Patterns

### VGP GenomeArk Structure

GenomeArk uses public S3 buckets (no credentials needed):
```
s3://genomeark/species/{Species_name}/{ToLID}/assembly_vgp_{type}_2.0/
                                                        ↑
                                        HiC (most common), standard, hic (legacy)
```

**Key Challenges**:
1. **Case sensitivity**: `hic` vs `HiC` in paths
2. **Multiple filename patterns**: 3+ variations for GenomeScope files
3. **Nested subdirectories**: BUSCO/Merqury use variable subdirectory structures
4. **Missing data**: Not all assemblies have all QC data types

### BUSCO Data Fetching

**Path structure**: `{assembly}/evaluation/busco/{subdir}/short_summary*.txt`

**Strategy**:
1. List subdirectories in `busco/`
2. For each subdir, list files looking for `short_summary*.txt`
3. Parse for completeness percentage and lineage

**Expected coverage**: ~20-30% of VGP assemblies have BUSCO data

### Merqury QV Fetching

**Path patterns** (try in order):
1. Direct: `{assembly}/evaluation/merqury/{ToLID}_qv/output_merqury.tabular`
2. Nested: `{assembly}/evaluation/merqury/{subdir}/{ToLID}_qv/output_merqury.tabular`

**Nested subdirs**: Usually 1-2 character names (c, p, c1, p1)

**Output format**: Tab-separated, QV is column 4 (index 3)

### GenomeScope Data Fetching

**Three filename patterns to try**:
```python
filenames = [
    f'{tolid}_genomescope__Summary.txt',   # Double underscore
    f'{tolid}_genomescope_Summary.txt',    # Single underscore
    f'{tolid}_Summary.txt',                # No prefix
]
```

**Validation**: Skip heterozygosity if range > 50% or max > 95% (indicates failed run)

### S3 Path Normalization

Always normalize paths:
```python
def normalize_s3_path(s3_path):
    s3_path = s3_path.strip()
    s3_path = s3_path.replace('/assembly_vgp_hic_2.0/', '/assembly_vgp_HiC_2.0/')
    if not s3_path.endswith('/'):
        s3_path += '/'
    return s3_path
```

### AWS CLI Usage

**Public access** (no credentials):
```bash
aws s3 ls s3://genomeark/... --no-sign-request
aws s3 cp s3://genomeark/.../file.txt - --no-sign-request
```

**Timeouts**: Use 10-30s timeouts for robustness

### Expected Performance

- S3 path inference: ~5-10 seconds per ToLID
- QC data fetching: ~1-2 minutes per assembly
- Full dataset (700+ assemblies): 2-3 hours total

## Related Skills

- **vgp-pipeline** - VGP workflows process Hi-C and HiFi data
- **galaxy-tool-wrapping** - Galaxy tools work with SAM/BAM and sequencing data formats
- **galaxy-workflow-development** - Workflows process sequencing data

## Supporting Documentation

- **reference.md:** Detailed format specifications and tool documentation
- **common-issues.md:** Comprehensive troubleshooting guide with examples

## Version History

- **v1.1.1:** Added BED file processing patterns for telomere analysis and NCBI data integration strategies
- **v1.1.0:** Added comprehensive AGP format documentation including coordinate validation, unloc processing, and common error patterns
- **v1.0.0:** Initial release with SAM/BAM, Hi-C, HiFi, common filtering patterns
