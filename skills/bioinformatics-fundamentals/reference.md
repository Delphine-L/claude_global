## Bioinformatics Fundamentals - Reference Documentation

Detailed technical specifications, complete tables, and reference material for bioinformatics file formats and tools.

---

## SAM/BAM Format Complete Reference

### Complete SAM Flag Table

| Dec | Hex  | Flag Name | Description |
|-----|------|-----------|-------------|
| 1 | 0x1 | PAIRED | Template having multiple segments in sequencing |
| 2 | 0x2 | PROPER_PAIR | Each segment properly aligned according to aligner |
| 4 | 0x4 | UNMAP | Segment unmapped |
| 8 | 0x8 | MUNMAP | Next segment in template unmapped |
| 16 | 0x10 | REVERSE | SEQ being reverse complemented |
| 32 | 0x20 | MREVERSE | SEQ of next segment being reverse complemented |
| 64 | 0x40 | READ1 | First segment in template |
| 128 | 0x80 | READ2 | Last segment in template |
| 256 | 0x100 | SECONDARY | Secondary alignment |
| 512 | 0x200 | QCFAIL | Not passing filters (platform/vendor quality controls) |
| 1024 | 0x400 | DUP | PCR or optical duplicate |
| 2048 | 0x800 | SUPPLEMENTARY | Supplementary alignment |

### Common Flag Combinations

| Flags | Decimal | Hex | Meaning |
|-------|---------|-----|---------|
| PAIRED + PROPER_PAIR + MREVERSE + READ1 | 99 | 0x63 | First read, properly paired, mate reverse |
| PAIRED + PROPER_PAIR + REVERSE + READ2 | 147 | 0x93 | Second read, properly paired, read reverse |
| PAIRED + UNMAP + MUNMAP | 13 | 0xd | Both reads unmapped |
| PAIRED + MUNMAP + READ1 | 73 | 0x49 | First read, mate unmapped |
| UNMAP | 4 | 0x4 | Single unmapped read |

### SAM Mandatory Fields

| Col | Field | Type | Description |
|-----|-------|------|-------------|
| 1 | QNAME | String | Query template name |
| 2 | FLAG | Int | Bitwise flags |
| 3 | RNAME | String | Reference sequence name |
| 4 | POS | Int | 1-based leftmost mapping position |
| 5 | MAPQ | Int | Mapping quality (0-255) |
| 6 | CIGAR | String | CIGAR string |
| 7 | RNEXT | String | Reference name of mate/next read |
| 8 | PNEXT | Int | Position of mate/next read |
| 9 | TLEN | Int | Observed template length |
| 10 | SEQ | String | Segment sequence |
| 11 | QUAL | String | ASCII Phred+33 quality scores |

### CIGAR Operations Complete Table

| Op | Code | Description | Consumes Query | Consumes Ref |
|----|------|-------------|----------------|--------------|
| M | 0 | Alignment match (can be match or mismatch) | Yes | Yes |
| I | 1 | Insertion to reference | Yes | No |
| D | 2 | Deletion from reference | No | Yes |
| N | 3 | Skipped region from reference | No | Yes |
| S | 4 | Soft clipping (present in SEQ) | Yes | No |
| H | 5 | Hard clipping (absent from SEQ) | No | No |
| P | 6 | Padding (silent deletion from padded reference) | No | No |
| = | 7 | Sequence match | Yes | Yes |
| X | 8 | Sequence mismatch | Yes | Yes |

### Optional Tags (Common)

| Tag | Type | Description |
|-----|------|-------------|
| NM | i | Edit distance to reference |
| MD | Z | String for mismatching positions |
| AS | i | Alignment score |
| XS | i | Suboptimal alignment score |
| RG | Z | Read group |
| NH | i | Number of reported alignments |
| HI | i | Hit index |
| IH | i | Total number of alignments |
| SA | Z | Chimeric alignments |

---

## FASTQ Format Specification

### Format Structure

```
@SEQ_ID
GATTTGGGGTTCAAAGCAGTATCGATCAAATAGTAAATCCATTTGTTCAACTCACAGTTT
+
!''*((((***+))%%%++)(%%%%).1***-+*''))**55CCF>>>>>>CCCCCCC65
```

**Line 1:** Sequence identifier (starts with `@`)
**Line 2:** Raw sequence
**Line 3:** Separator (starts with `+`, optionally repeats identifier)
**Line 4:** Quality scores (same length as sequence)

### Quality Score Encodings

#### Phred+33 (Sanger, Illumina 1.8+)

```
!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJ
|                                        |
0                                       41
```

**Formula:** Q = ASCII - 33
**Range:** 0-41 (sometimes extends to ~60)

#### Phred+64 (Illumina 1.3-1.7)

```
@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefgh
|                                        |
0                                       41
```

**Formula:** Q = ASCII - 64
**Range:** 0-41

### Quality Score Interpretation

| Q Score | Error Probability | Accuracy | ASCII (Phred+33) |
|---------|-------------------|----------|------------------|
| 10 | 1 in 10 | 90% | + |
| 20 | 1 in 100 | 99% | 5 |
| 30 | 1 in 1,000 | 99.9% | ? |
| 40 | 1 in 10,000 | 99.99% | I |
| 50 | 1 in 100,000 | 99.999% | S |
| 60 | 1 in 1,000,000 | 99.9999% | ] |

---

## Tool Command Reference

### samtools view

**Complete Syntax:**
```bash
samtools view [options] <in.bam>|<in.sam>|<in.cram> [region...]
```

**Common Options:**
```bash
-b          # Output BAM
-C          # Output CRAM
-h          # Include header
-H          # Header only
-c          # Count only
-o FILE     # Output file
-U FILE     # Output unselected reads
-f INT      # Required flags (include)
-F INT      # Filter flags (exclude)
-q INT      # Min MAPQ
-L FILE     # Regions from BED file
-r STR      # Read group
-R FILE     # Read group from file
-d TAG:VAL  # Tag filtering
-D TAG:FILE # Tag from file
-s FLOAT    # Subsample fraction
--threads N # Number of threads
```

**Examples:**

```bash
# Extract properly paired reads
samtools view -b -f 2 input.bam > proper_pairs.bam

# Exclude unmapped and secondary alignments
samtools view -b -F 4 -F 256 input.bam > mapped_primary.bam

# High quality mappings only
samtools view -b -q 30 input.bam > high_qual.bam

# Reads in specific region
samtools view -b input.bam chr1:1000-2000 > region.bam

# Subsample 10% of reads
samtools view -b -s 0.1 input.bam > subsample.bam

# Count mapped reads
samtools view -c -F 4 input.bam
```

### samtools flagstat

**Purpose:** Count reads by flag status

**Output Format:**
```
12345 + 0 in total (QC-passed reads + QC-failed reads)
0 + 0 secondary
0 + 0 supplementary
456 + 0 duplicates
11890 + 0 mapped (96.31% : N/A)
12345 + 0 paired in sequencing
6789 + 0 read1
5556 + 0 read2
11234 + 0 properly paired (90.99% : N/A)
11400 + 0 with itself and mate mapped
490 + 0 singletons (3.97% : N/A)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)
```

### samtools stats

**Purpose:** Comprehensive BAM statistics

**Usage:**
```bash
samtools stats [options] <in.bam>

# Common options
-r REF.fa   # Reference file
-c INT      # Coverage cap
-d INT      # Maximum coverage depth
--threads N # Threads
```

**Key Output Sections:**
- Summary numbers (SN)
- First fragment qualities (FFQ)
- Last fragment qualities (LFQ)
- GC content (GCC)
- Insert sizes (IS)
- Read lengths (RL)
- Indel distribution (ID)
- Coverage distribution (COV)

### bamtools filter

**Purpose:** Advanced filtering

**Usage:**
```bash
bamtools filter -in <input.bam> [filter options]

# Filter options
-mapQuality ">30"
-isPaired true
-isProperPair true
-isMapped true
-isDuplicate false
-isReverseStrand true
-tag "RG:sample1"
-insertSize ">=100"
```

**Filter File (JSON):**
```json
{
  "filters": [
    {
      "mapQuality": ">=30",
      "isPaired": true,
      "isProperPair": true
    }
  ]
}
```

```bash
bamtools filter -in input.bam -script filter.json -out output.bam
```

---

## Sequencing Technology Details

### PacBio HiFi Technical Specs

**Platform:** PacBio Sequel II, Sequel IIe, Revio

**Chemistry:**
- SMRTbell template preparation
- Circular Consensus Sequencing (CCS)
- Multiple passes over same molecule

**Read Characteristics:**
- Length: 10-25 kb (mode ~15 kb)
- Accuracy: >99.9% (Q20+), often Q30+
- Error mode: Random (not systematic)
- No GC bias
- Can sequence through modifications

**Recommended Coverage:**
- De novo assembly: 30-50x
- Variant calling: 20-30x
- Isoform sequencing: Depends on expression

**Quality Metrics:**
- Accuracy (CCS passes): More passes = higher quality
- Predicted accuracy in Phred scale (rq tag)
- Read length distribution

### Hi-C Technical Specs

**Protocol Steps:**
1. Crosslink chromatin with formaldehyde
2. Digest with restriction enzyme
3. Fill in and label ends with biotin
4. Ligate (creates chimeric molecules)
5. Shear DNA
6. Pull down biotinylated junctions
7. Paired-end sequencing

**Read Characteristics:**
- Paired-end: 100-150 bp each end
- R1 and R2 from same ligation product
- Can be on different chromosomes/scaffolds
- Many "invalid pairs" (self-ligations, etc.)

**Quality Metrics:**
- Valid pairs percentage
- Cis vs trans ratio (intra vs inter-chromosomal)
- Contact distance distribution
- Coverage uniformity

**Expected Pair Types:**
- Valid pairs (useful): ~40-70%
- Self-circles: ~10-20%
- Dangling ends: ~10-20%
- Other invalid: ~10-30%

### Illumina Technical Specs

**Platforms:** NovaSeq, NextSeq, HiSeq, MiSeq

**Chemistry:**
- Sequencing by synthesis (SBS)
- Clonal amplification (bridge PCR)
- Four-color imaging

**Read Characteristics:**
- Length: 50-300 bp (platform dependent)
- Paired-end or single-end
- Quality decreases toward 3' end
- Systematic errors possible (GGC motif)

**Quality Metrics:**
- Cluster density
- %PF (passing filter)
- Q30 percentage (% bases >Q30)
- Index balance (for multiplexing)

---

## Assembly Quality Metrics

### Contiguity Metrics

**N50:**
- Sort contigs by length (largest first)
- Sum lengths until reaching 50% of total assembly
- N50 = length of contig at 50% mark

**L50:**
- Number of contigs needed to reach N50

**N90:**
- Same as N50 but using 90% threshold
- More stringent

**NG50:**
- N50 relative to expected genome size
- Better for comparing assemblies

**auN:**
- Area under Nx curve
- Less sensitive to individual long contigs
- Better for comparing fragmented assemblies

### Completeness Metrics

**BUSCO (Benchmarking Universal Single-Copy Orthologs):**
```
Complete: 95.2% (C:95.2%[S:94.1%,D:1.1%],F:2.3%,M:2.5%,n:3950)
- Complete and single-copy (S): 94.1%
- Complete and duplicated (D): 1.1%
- Fragmented (F): 2.3%
- Missing (M): 2.5%
```

**Interpretation:**
- >95% complete: Excellent
- 90-95% complete: Good
- <90% complete: May have issues

**QV (Consensus Quality Value):**
- Phred-scaled accuracy of consensus sequence
- QV30 = 99.9% accurate (1 error per 1000 bp)
- QV40 = 99.99% accurate (1 error per 10,000 bp)
- QV50 = 99.999% accurate (1 error per 100,000 bp)

### Structural Metrics

**LAI (LTR Assembly Index):**
- For plant genomes with LTR retrotransposons
- Scale 0-100
- >20 = excellent continuity

**BUSCO Structural:**
- Checks for fragmentation of conserved genes
- High duplication may indicate haplotigs

---

## Coverage and Depth Calculations

### Theoretical Coverage

**Formula:**
```
Coverage (X) = (Number of reads × Read length) / Genome size
```

**Example:**
- 100 million reads
- 150 bp read length
- 3 Gb genome
```
Coverage = (100M × 150) / 3G = 15,000M / 3,000M = 5X
```

### Effective Coverage

Account for duplicates, unmapped, low quality:
```
Effective coverage = Theoretical coverage × (1 - duplicate rate) × mapping rate
```

### Recommended Coverage Levels

| Application | Technology | Recommended Depth |
|-------------|-----------|-------------------|
| Genome assembly | HiFi | 30-50x |
| Genome assembly | Illumina | 50-100x |
| SNV calling | Illumina | 30x |
| SV calling | HiFi | 20-30x |
| RNA-seq | Illumina | 20-40M reads |
| ChIP-seq | Illumina | 20-40M reads |
| ATAC-seq | Illumina | 50M reads |
| Hi-C scaffolding | Illumina | 50-100x genomic |

---

## Coordinate Systems

### 0-based vs 1-based

**1-based (SAM, VCF, GFF):**
```
Sequence: A T C G A T C G
Position: 1 2 3 4 5 6 7 8
```
- First base is position 1
- Interval [2,5] includes bases at positions 2,3,4,5

**0-based (BED, BAM binary):**
```
Sequence: A T C G A T C G
Position: 0 1 2 3 4 5 6 7
```
- First base is position 0
- Interval [2,5) includes bases at positions 2,3,4 (excludes 5)

**0-based half-open [start, end):**
- BED format
- start included, end excluded
- Length = end - start

**1-based closed [start, end]:**
- SAM format
- Both start and end included
- Length = end - start + 1

### Conversion

**BED to SAM:**
```
SAM_start = BED_start + 1
SAM_end = BED_end
```

**SAM to BED:**
```
BED_start = SAM_start - 1
BED_end = SAM_end
```

---

## Error Rates and Sequencing Technology

### Error Profiles

| Technology | Error Rate | Error Type | Homopolymer Issues |
|-----------|-----------|------------|-------------------|
| Illumina | 0.1-1% | Substitutions | Minimal |
| PacBio CLR | 10-15% | Indels | Yes (moderate) |
| PacBio HiFi | <0.1% | Random | Minimal |
| ONT (old) | 5-15% | Indels | Yes (significant) |
| ONT (Q20+) | ~1% | Indels | Moderate |

### Base Quality Distributions

**Illumina:**
- High quality at 5' end (Q35-40)
- Gradual decline toward 3' end
- Last 10-20 bases often Q20-30

**PacBio HiFi:**
- Consistent across read
- Q30+ typical
- Length-independent quality

**ONT:**
- Variable by position
- Homopolymers lower quality
- Improving with newer chemistry

---

## File Size Estimates

### Compression Ratios

| Format | Relative Size | Notes |
|--------|--------------|-------|
| SAM | 1.0x (baseline) | Text format |
| BAM | 0.2-0.3x | Binary compressed |
| CRAM | 0.1-0.2x | Reference-based |
| FASTQ | 1.0x | Text |
| FASTQ.gz | 0.2-0.3x | Gzipped |

### Example File Sizes (30x WGS, 3Gb genome)

| Data Type | Uncompressed | Compressed |
|-----------|--------------|------------|
| Raw FASTQ | ~300 GB | ~90 GB |
| Aligned BAM | ~90 GB | N/A (already compressed) |
| Aligned CRAM | ~30 GB | N/A |

---

## Useful Regular Expressions

### FASTQ Header Parsing

**Illumina:**
```
@INSTRUMENT:RUN:FLOWCELL:LANE:TILE:X:Y READ:FILTERED:CONTROL:BARCODE
```

**Regex:**
```regex
^@([^:]+):(\d+):([^:]+):(\d+):(\d+):(\d+):(\d+) ([12]):([YN]):(\d+):([ACTGN+]+)$
```

### FASTA Header Parsing

```regex
^>(\S+)\s*(.*)$
# Group 1: Sequence ID
# Group 2: Description
```

### CIGAR String Parsing

```regex
(\d+)([MIDNSHP=X])
# Group 1: Length
# Group 2: Operation
```

---

## Additional Resources

- **SAM Specification:** https://samtools.github.io/hts-specs/SAMv1.pdf
- **SAM Tags Specification:** https://samtools.github.io/hts-specs/SAMtags.pdf
- **VCF Specification:** https://samtools.github.io/hts-specs/VCFv4.3.pdf
- **FASTQ Format:** https://en.wikipedia.org/wiki/FASTQ_format
- **Phred Quality Scores:** https://www.drive5.com/usearch/manual/quality_score.html
- **BUSCO:** https://busco.ezlab.org/
- **samtools documentation:** http://www.htslib.org/doc/
