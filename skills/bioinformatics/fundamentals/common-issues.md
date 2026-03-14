# Common Bioinformatics Issues and Solutions

Troubleshooting guide for frequent problems in bioinformatics workflows, organized by symptom and data type.

---

## Table of Contents

1. [Empty or Missing Output Files](#empty-or-missing-output-files)
2. [Paired-End Data Issues](#paired-end-data-issues)
3. [Quality and Mapping Issues](#quality-and-mapping-issues)
4. [Format and Conversion Issues](#format-and-conversion-issues)
5. [Hi-C Specific Issues](#hi-c-specific-issues)
6. [HiFi/Long-Read Specific Issues](#hifilong-read-specific-issues)

---

## Empty or Missing Output Files

### Issue: Empty BAM After Region Filtering (Paired-End Data)

**Symptom:**
- Input BAM has reads
- After filtering by regions, output is empty
- Happens with paired-end data (especially Hi-C)

**Root Cause:**
Region filtering (`samtools view -L`) operates on each read independently:
1. R1 maps to selected region → kept
2. R2 maps outside selected region → discarded
3. R1 loses "proper pair" flag (0x2) because mate is missing
4. Subsequent filtering for proper pairs removes all remaining reads
5. Result: Empty file

**Solution:**

**Option A: Filter for proper pairs BEFORE region filtering**
```bash
# Correct order: proper pair flag first, then region filtering
samtools view -b -f 2 -L regions.bed input.bam > output.bam
```

This ensures flag filtering happens before region filtering can break pairs.

**Option B: Accept that one mate may be outside regions**
```bash
# Keep pairs where at least one mate is in regions
# (mate may be anywhere in genome)
samtools view -b -L regions.bed input.bam > output.bam
# Don't filter for proper pairs afterward
```

**Option C: Keep only pairs where BOTH mates are in regions** (custom solution)
```bash
# Extract pairs in regions
samtools view -b -L regions.bed input.bam | \
# Filter for properly paired
bamtools filter -isPaired -isProperPair -out temp.bam

# Check if both mates are in selected regions (requires custom script)
```

**When This Happens:**
- Hi-C data (read pairs map to different scaffolds)
- Large-scale structural variation data
- Subsampling by genomic region
- Creating test datasets from larger assemblies

**Prevention:**
Always think about **filter order** for paired-end data:
1. Pair-based filters first (proper pair, both mapped)
2. Region-based filters second
3. Quality filters can go either before or after

---

### Issue: Empty FASTQ After BAM Conversion

**Symptom:**
- BAM file has reads (verified with `samtools flagstat`)
- `samtools fastx` produces empty FASTQ files
- Or R1 and R2 have different numbers of reads

**Possible Causes:**

**Cause 1: Filtering Too Strict**
```bash
# This might filter out ALL reads if none meet criteria
samtools fastx -1 R1.fq -2 R2.fq \
  --i1-flags 2,64 \  # Requires BOTH proper pair AND read1
  --i2-flags 2,128   # Requires BOTH proper pair AND read2
  input.bam
```

**Solution:** Relax filters or check that reads actually have these flags
```bash
# Check what flags are present
samtools flagstat input.bam

# Extract without strict filtering
samtools fastx -1 R1.fq -2 R2.fq input.bam
```

**Cause 2: Single-End Data with Paired-End Extraction**
```bash
# Wrong: trying to extract R1/R2 from single-end data
samtools fastx -1 R1.fq -2 R2.fq single_end.bam  # Empty output
```

**Solution:** Use correct extraction mode
```bash
# For single-end data
samtools fastx -0 output.fq single_end.bam

# Check if data is paired first
samtools flagstat input.bam | grep "paired in sequencing"
```

**Cause 3: All Reads Are Unmapped**
```bash
# Flags require mapped reads, but all are unmapped
samtools fastx --i1-flags 2 unmapped.bam  # Empty because flag 2 requires mapping
```

**Solution:**
```bash
# Check mapping rate
samtools flagstat input.bam

# Extract unmapped reads if needed
samtools fastx -f 4 -0 unmapped.fq input.bam
```

---

## Paired-End Data Issues

### Issue: R1 and R2 Files Have Different Read Counts

**Symptom:**
```bash
wc -l R1.fastq  # 1000000 lines (250000 reads)
wc -l R2.fastq  # 800000 lines (200000 reads)
```

**Root Cause:**
Reads were filtered in a way that kept one mate but not the other.

**Diagnosis:**
```bash
# Check BAM for orphaned reads (mate unmapped)
samtools view -c -f 8 input.bam  # Count reads with unmapped mate

# Check for proper pairs
samtools view -c -f 2 input.bam  # Count proper pairs
```

**Solution:**

**Option A: Filter BAM for proper pairs before extraction**
```bash
# Only keep properly paired reads
samtools view -b -f 2 -F 12 input.bam | \
samtools fastx -1 R1.fq -2 R2.fq
```

**Option B: Use paired-aware extraction**
```bash
# samtools fastx with strict pairing
samtools fastx -1 R1.fq -2 R2.fq \
  --i1-flags 2 \  # Require proper pair
  input.bam
```

**Option C: Repair pairs using external tools**
```bash
# Use BBTools repair.sh
repair.sh in1=R1.fq in2=R2.fq out1=R1_fixed.fq out2=R2_fixed.fq outs=singletons.fq
```

---

### Issue: Proper Pair Flag Missing After Alignment

**Symptom:**
```bash
samtools flagstat aligned.bam
# Shows:
# 1000000 paired in sequencing
# 0 properly paired (0.00%)  # <- Problem!
```

**Possible Causes:**

**Cause 1: Insert Size Distribution Mismatch**
Aligner expected insert size 300-500 bp, but actual library is 100-200 bp.

**Solution:**
```bash
# Check actual insert size
samtools stats aligned.bam | grep "insert size average"

# Re-align with correct insert size expectations
bwa mem -I 200,50 ref.fa R1.fq R2.fq  # Mean 200, StdDev 50
```

**Cause 2: Wrong Reference Genome**
Reads are from different assembly/species than reference.

**Solution:**
```bash
# Check mapping rate
samtools flagstat aligned.bam
# If very low (<50%), likely wrong reference
```

**Cause 3: Reads Are Actually Properly Paired (Hi-C)**
For Hi-C data, distant pairs are EXPECTED and may not be marked as "proper pairs" by standard aligners.

**Solution:**
- This is normal for Hi-C
- Use Hi-C-specific pipelines (HiC-Pro, Juicer)
- Don't rely on "proper pair" flag for Hi-C
- Filter by MAPQ and mapping status instead

**Cause 4: Incorrect Orientation Flags**
```bash
# Check read orientation distribution
samtools view aligned.bam | awk '{print and($2,16), and($2,32)}' | sort | uniq -c

# Should see expected patterns for paired-end:
# Many reads: 0 32 (R1 forward, R2 reverse)
# Many reads: 16 0 (R1 reverse, R2 forward)
```

---

### Issue: Lost Reads During Merging or Filtering

**Symptom:**
Start with 10M reads, end with 100K after filtering pipeline.

**Diagnosis Strategy:**

**Step 1: Count reads at each step**
```bash
samtools view -c step1.bam  # 10000000
samtools view -c step2.bam  # 5000000  <- lost 50% here
samtools view -c step3.bam  # 100000   <- lost 98% here!
```

**Step 2: Identify the problem step**
```bash
# For step that lost reads, check why
samtools flagstat problem_step.bam
samtools stats problem_step.bam
```

**Step 3: Check filter parameters**
```bash
# Was MAPQ too stringent?
samtools view problem_step.bam | awk '{print $5}' | sort -n | uniq -c

# Were flag filters too strict?
samtools flagstat input_to_problem_step.bam
```

**Common Culprits:**
- MAPQ > 30 on Hi-C data (too strict)
- Proper pair requirement on scaffolded/fragmented assemblies
- Region filtering on paired-end data
- Duplicate marking removing too many reads

---

## Quality and Mapping Issues

### Issue: Low Mapping Rate

**Symptom:**
```bash
samtools flagstat aligned.bam
# 1000000 reads
# 100000 mapped (10.00%)  # <- Very low!
```

**Possible Causes:**

**Cause 1: Wrong Reference**
Most common cause.

**Solution:**
```bash
# Verify reference
head -1 reference.fa  # Check sequence ID matches expectations
samtools view aligned.bam | head  # Check RNAME column matches reference
```

**Cause 2: Adapter Contamination**
Reads still contain sequencing adapters.

**Solution:**
```bash
# Check for adapters
fastqc reads.fq  # Look for adapter content

# Trim adapters
cutadapt -a AGATCGGAAGAGC -o trimmed.fq reads.fq

# Re-align
bwa mem ref.fa trimmed.fq > aligned.sam
```

**Cause 3: Low Quality Reads**
```bash
# Check quality distribution
fastqc reads.fq
# Look for quality drop-off

# Filter low quality
fastp -i reads.fq -o filtered.fq -q 20
```

**Cause 4: Contamination**
Reads from different organism.

**Solution:**
```bash
# Align to suspected contaminant reference
bwa mem contaminant.fa reads.fq > contam_check.sam
samtools flagstat contam_check.sam  # High mapping? Contamination!
```

**Expected Mapping Rates:**
- DNA-seq to same species: >95%
- DNA-seq to closely related species: 70-90%
- RNA-seq (with introns): 70-85%
- Hi-C: 60-80% (lower is normal due to chimeric reads)
- Metagenomics: Highly variable

---

### Issue: Many Secondary/Supplementary Alignments

**Symptom:**
```bash
samtools flagstat aligned.bam
# 1000000 total reads
# 500000 secondary  # <- Very high!
# 300000 supplementary
```

**Meaning:**
- **Secondary (flag 256):** Alternative mapping locations (multi-mappers)
- **Supplementary (flag 2048):** Chimeric alignment (read maps to multiple locations)

**When This Is Normal:**
- Repetitive regions (expect high secondary)
- Structural variants (expect high supplementary)
- Long reads spanning multiple regions (supplementary normal for PacBio)

**When This Is a Problem:**
- Fragmented assembly (reads mapping everywhere)
- Wrong reference
- Poor quality reads

**Solution:**

For most analyses, exclude secondary and supplementary:
```bash
samtools view -b -F 2304 aligned.bam > primary_only.bam
# -F 2304 = exclude 256 (secondary) + 2048 (supplementary)
```

---

## Format and Conversion Issues

### Issue: BAM to FASTQ Loses Read Names

**Symptom:**
Original FASTQ has read names like `@INSTRUMENT:RUN:FLOWCELL...`
After BAM→FASTQ, names are truncated or modified.

**Cause:**
SAM specification only stores first field of read name (up to first space).

**Solution:**

**Preserve names during alignment:**
```bash
# bwa mem preserves full names with -C flag
bwa mem -C ref.fa R1.fq R2.fq > aligned.sam
```

**Or accept that descriptions are lost** (usually fine for most analyses).

---

### Issue: CRAM Conversion Fails

**Symptom:**
```bash
samtools view -C -T ref.fa input.bam > output.cram
# Error: [main_samview] failed to read the header
```

**Cause:**
CRAM requires reference genome for compression.

**Solutions:**

**Provide reference:**
```bash
samtools view -C -T reference.fa -o output.cram input.bam
```

**Check reference matches:**
```bash
# Reference sequence names must match BAM @SQ headers
samtools view -H input.bam | grep "^@SQ"
grep "^>" reference.fa
```

**Embed reference in CRAM:**
```bash
samtools view -C --output-fmt-option embed_ref=1 -o output.cram input.bam
```

---

## Hi-C Specific Issues

### Issue: Very Low Valid Pairs Percentage

**Symptom:**
Hi-C analysis shows <20% valid pairs (expected: 40-70%).

**Diagnosis:**

**Check pair types:**
- Self-circles: Ligation of same fragment
- Dangling ends: No ligation occurred
- Re-ligation: Fragments from same restriction site

**Common Causes:**

**Cause 1: Restriction Enzyme Problem**
Wrong enzyme used in analysis vs library prep.

**Solution:**
```bash
# Verify restriction enzyme
# Common enzymes: MboI (GATC), DpnII (GATC), HindIII (AAGCTT)

# Check if cut sites are where expected
grep "GATC" assembly.fa | head  # For MboI/DpnII
```

**Cause 2: Poor Library Quality**
Ligation step failed, over-digestion, etc.

**Solution:**
This is a wet-lab issue - library needs to be re-made.

**Cause 3: Mapping Issues**
Reference genome fragmented or incorrect.

**Solution:**
```bash
# Check reference contiguity
assembly-stats assembly.fa
# Many small contigs = will have low valid pairs

# Use more contiguous assembly if available
```

---

### Issue: Hi-C Reads Not Properly Paired After Filtering

**Symptom:**
After region filtering to create test data, Hi-C reads are empty or unpaired.

**Root Cause:**
Hi-C pairs span different regions - region filtering breaks them. (See "Empty BAM After Region Filtering" above).

**Solution:**
See detailed solution in main issues section above.

---

## HiFi/Long-Read Specific Issues

### Issue: Low HiFi Mapping Rate Despite High Quality

**Symptom:**
- HiFi reads have Q20+
- But <80% mapping rate to reference

**Possible Causes:**

**Cause 1: Wrong Mapper Preset**
```bash
# Wrong: using short-read aligner
bwa mem ref.fa hifi.fq  # Designed for short reads!

# Wrong: using CLR preset
minimap2 -ax map-pb ref.fa hifi.fq  # For older PacBio

# Correct: use HiFi preset
minimap2 -ax map-hifi ref.fa hifi.fq
# Or
minimap2 -ax map-pb -k 19 ref.fa hifi.fq  # Explicit HiFi params
```

**Cause 2: Structural Differences**
Reference is from different haplotype/individual.

**Solution:**
This may be expected - HiFi reveals real structural variation.

**Cause 3: Low Complexity or Repetitive Reads**
```bash
# Check for low-complexity sequences
seqtk comp hifi.fq | awk '$2 < 50 || $3/$2 > 0.4'  # Potential low-complexity
```

---

### Issue: HiFi Reads Marked as Duplicates

**Symptom:**
Many HiFi reads flagged as duplicates (flag 1024).

**Cause:**
Duplicate marking tools designed for short reads don't work well with long reads.

**Solution:**

**Don't mark duplicates on HiFi:**
```bash
# Skip duplicate marking
# Or use long-read aware duplicate removal

# Remove duplicate flags if already marked
samtools view -b -F 1024 marked.bam > no_dups.bam
```

**For long reads:** True PCR duplicates are rare (each molecule is unique due to length).

---

## Diagnostic Commands

### Quick BAM Inspection

```bash
# Overall statistics
samtools flagstat file.bam

# Detailed statistics
samtools stats file.bam | less

# Check first few alignments
samtools view file.bam | head

# Check header
samtools view -H file.bam

# Count by flag
samtools view file.bam | awk '{print $2}' | sort | uniq -c | sort -rn

# MAPQ distribution
samtools view file.bam | awk '{print $5}' | sort -n | uniq -c

# Insert size distribution (paired-end)
samtools stats file.bam | grep "^IS" | head -20

# Coverage per chromosome
samtools idxstats file.bam
```

### Quick FASTQ Inspection

```bash
# Count reads
echo $(cat file.fq | wc -l)/4 | bc

# For gzipped
echo $(zcat file.fq.gz | wc -l)/4 | bc

# Read length distribution
awk 'NR%4==2 {print length($0)}' file.fq | sort -n | uniq -c

# Quality score distribution
awk 'NR%4==0' file.fq | perl -ne 'chomp; @q=split(//); foreach(@q){print ord($_)-33, "\n";}' | sort -n | uniq -c

# Check for adapters (simple check)
grep "AGATCGGAAGAGC" file.fq | wc -l
```

### Comparing BAM Files

```bash
# Compare read counts
samtools view -c file1.bam
samtools view -c file2.bam

# Compare flagstats
diff <(samtools flagstat file1.bam) <(samtools flagstat file2.bam)

# Check if same reads
samtools view file1.bam | cut -f1 | sort > reads1.txt
samtools view file2.bam | cut -f1 | sort > reads2.txt
diff reads1.txt reads2.txt
```

---

## Prevention Checklist

Before running a complex filtering pipeline:

- [ ] Understand input data type (paired-end vs single-end)
- [ ] Know sequencing technology (Hi-C, HiFi, Illumina)
- [ ] Plan filter order (pairs first, then regions)
- [ ] Set reasonable MAPQ thresholds for data type
- [ ] Validate each step with flagstat/stats
- [ ] Check output file sizes (empty = problem)
- [ ] Verify read counts match expectations
- [ ] Test on small subset first

---

## AGP Processing Issues

### Issue: Incorrect Object Coordinates When Creating Unlocs

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
agp_df.loc[index, 'chr_end'] = agp_df.loc[index, 'scaff_end']  # WRONG
```

**Correct Approach:**
```python
# Calculate actual length from component coordinates
agp_df.loc[index, 'chr_end'] = int(agp_df.loc[index, 'scaff_end']) - int(agp_df.loc[index, 'scaff_start']) + 1  # CORRECT
```

---

### Issue: Component Numbering Not Reset for New Objects

**Symptom:**
Unloc scaffolds have component numbers > 1 when they should start at 1.

**Cause:**
When creating a new object (unloc scaffold), component numbering wasn't reset.

**Solution:**
```python
# When creating unlocs, reset component number
agp_df.loc[index, '#_scaffs'] = 1  # Column 4: component number
```

---

### Issue: AGPcorrect Accumulating Coordinates

**Symptom:**
Unloc sequences inherit cumulative coordinates from parent scaffolds.

**Cause:**
AGPcorrect adjusts coordinates based on sequence length corrections. When scaffolds are later split into unlocs, the accumulated corrections need to be recalculated based on actual component spans.

**Solution:**
Always recalculate object coordinates from component spans when creating new objects (unlocs).

---

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

### AGP Processing Best Practices

#### Creating Unlocalized Sequences (Unlocs)

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

#### Validating AGP Files

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

#### Handling Haplotype-Split Assemblies

When splitting diploid assemblies into haplotypes:
1. Identify haplotype markers in sequence names (H1/hap1, H2/hap2)
2. Maintain proper pairing information
3. Process unlocs separately per haplotype
4. Remove haplotig duplications
5. Track gaps appropriately (especially proximity ligation gaps)

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

---

## Getting Help

When asking for help with bioinformatics issues, include:

1. **Data type:** Paired-end? Single-end? Hi-C? HiFi?
2. **Commands used:** Exact command lines
3. **Input stats:** `samtools flagstat input.bam`
4. **Output stats:** `samtools flagstat output.bam`
5. **Expected vs actual:** What did you expect? What happened?
6. **File sizes:** Are outputs unexpectedly small/large?

This helps diagnose issues quickly!
