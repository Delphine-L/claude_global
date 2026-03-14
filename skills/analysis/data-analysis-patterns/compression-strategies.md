# Data File Compression Strategies

For large data files, **compress instead of delete** to save space while preserving data accessibility.

## Decision Tree: Delete, Compress, or Keep?

```
Is the file used by active analyses?
├─ Yes: Keep uncompressed (fast access)
└─ No: Is the file easily regenerated?
   ├─ Yes: Delete (can recreate if needed)
   └─ No: Compress with gzip (preserve but save space)
```

## Example: BED File Compression

**Before cleanup:**
```bash
$ ls -lh telomeres/
25.12.05_terminal_telomeres.bed           5.0M
26.01.14_interstitial_telomeres_long.bed 12.0M
26.01.14_interstitial_telomeres_short.bed 274M  # Unused, large
```

**Analysis:**
1. Check usage: `grep -r "interstitial_telomeres_short" scripts/` -> No results
2. Decision: Delete unused 274 MB file, compress active files

**After cleanup:**
```bash
$ gzip telomeres/*.bed
$ ls -lh telomeres/
25.12.05_terminal_telomeres.bed.gz        1.2M  # 76% reduction
26.01.14_interstitial_telomeres_long.bed.gz 2.8M  # 77% reduction
```

**Total savings**: 23 MB -> 4 MB (83% reduction)

## Update Scripts to Read Compressed Files

Python scripts can read gzipped files directly:

```python
import gzip
import csv

# Old: Read uncompressed
with open('data.bed') as f:
    reader = csv.reader(f, delimiter='\t')
    for row in reader:
        process(row)

# New: Read compressed (no decompression needed)
with gzip.open('data.bed.gz', 'rt') as f:  # 'rt' = read text mode
    reader = csv.reader(f, delimiter='\t')
    for row in reader:
        process(row)
```

**Bash scripts:**
```bash
# Old: cat uncompressed
cat data.bed | process

# New: zcat/gzip -dc compressed
zcat data.bed.gz | process
# OR
gzip -dc data.bed.gz | process
```

## When to Compress

**Good candidates:**
- Large data files (>10 MB)
- Infrequently accessed reference data
- Archived analysis results
- BED/VCF/SAM files (compress well, 70-90% reduction)

**Don't compress:**
- Files accessed frequently in analyses
- Files that don't compress well (already compressed formats: .gz, .bam, .bcf)
- Small files (<1 MB) - overhead not worth it

## Benchmark: Compression Ratios

| File Type | Typical Reduction | Example |
|-----------|------------------|---------|
| BED files | 75-85% | 23 MB -> 4 MB |
| VCF files | 80-90% | 100 MB -> 15 MB |
| FASTA files | 70-80% | 50 MB -> 12 MB |
| CSV files | 60-70% | 10 MB -> 3.5 MB |
| BAM files | Already compressed | No benefit |

## Update Documentation

After compressing, update any READMEs:

```markdown
## Files

- `data.bed.gz` - BED file (gzipped, 1.2 MB)
  - Original uncompressed size: 5.0 MB
  - Compression: 76% reduction
  - Read with: `gzip.open('data.bed.gz', 'rt')` in Python

**Note**: Scripts updated to read compressed files directly.
```

## Integration with Deprecation

When compressing files during cleanup:

1. **Compress active files** that will still be used
2. **Delete or deprecate** files no longer needed
3. **Update scripts** to read compressed formats
4. **Document changes** in README or CHANGELOG
5. **Verify scripts still work** with compressed input

**Example workflow:**
```bash
# 1. Identify large files
du -sh data/*.bed | sort -h

# 2. Check usage
for file in data/*.bed; do
    echo "=== $file ==="
    grep -r "$(basename $file)" scripts/
done

# 3. Compress active, delete unused
gzip data/active_file.bed  # Still needed
rm data/unused_file.bed     # Not referenced anywhere

# 4. Update Python script
sed -i 's/open(.*\.bed/gzip.open(&.gz, "rt"/g' scripts/process.py

# 5. Test
python scripts/process.py
```
