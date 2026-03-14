---
name: gget
description: Fast CLI/Python queries to 20+ bioinformatics databases. Gene info, BLAST, AlphaFold structures, enrichment analysis, single-cell data, disease associations. Best for interactive exploration and quick lookups. For batch/multi-database Python workflows use bioservices.
version: 1.0.0
allowed-tools: Read, Grep, Glob, Bash
---

# gget

Unified CLI and Python access to 20+ genomic databases. All modules work as both command-line tools and Python functions.

## Installation

```bash
uv pip install --upgrade gget
```

Some modules require setup: `gget setup alphafold|cellxgene|elm|gpt`

## Quick Start

```bash
# CLI: gget <module> [arguments]
gget search -s human BRCA1
gget info ENSG00000012048
gget seq ENSG00000012048 -t   # protein sequence

# Python: gget.module(arguments)
import gget
gget.search(["BRCA1"], species="homo_sapiens")
gget.info(["ENSG00000012048"])
```

Common flags: `-o` (save to file), `-csv` (CSV output), `-q` (quiet)

## Supporting Files

- **[module_reference.md](references/module_reference.md)** - Complete parameter reference for all 20+ modules
- **[database_info.md](references/database_info.md)** - Database descriptions and update frequencies
- **[workflows.md](references/workflows.md)** - Extended workflow examples

## Scripts

- **`scripts/gene_analysis.py`** - Gene discovery to sequence analysis pipeline
- **`scripts/enrichment_pipeline.py`** - Gene list enrichment workflow
- **`scripts/batch_sequence_analysis.py`** - Batch BLAST/alignment processing

## Module Overview

### Reference & Gene Information

| Module | What it does | Example |
|--------|-------------|---------|
| `ref` | Download reference genomes (Ensembl) | `gget ref -w gtf -d human` |
| `search` | Find genes by name/description | `gget search -s human "GABA receptor"` |
| `info` | Gene/transcript metadata (Ensembl+UniProt+NCBI) | `gget info ENSG00000012048` |
| `seq` | Nucleotide/protein sequences | `gget seq -t ENSG00000012048` |

### Sequence Analysis

| Module | What it does | Example |
|--------|-------------|---------|
| `blast` | NCBI BLAST searches | `gget blast MKWMFK... -db swissprot` |
| `blat` | UCSC BLAT genomic mapping | `gget blat ATCGATCG -a human` |
| `muscle` | Multiple sequence alignment | `gget muscle sequences.fasta` |
| `diamond` | Fast local alignment | `gget diamond query.fa -ref ref.fa` |

### Structure & Protein

| Module | What it does | Example |
|--------|-------------|---------|
| `pdb` | Query Protein Data Bank | `gget pdb 7S7U` |
| `alphafold` | Predict 3D structure (setup required) | `gget alphafold MKWMFK...` |
| `elm` | Eukaryotic linear motifs (setup required) | `gget elm LIAQSIGQASFV` |

### Expression & Disease

| Module | What it does | Example |
|--------|-------------|---------|
| `archs4` | Correlated genes / tissue expression | `gget archs4 -w tissue ACE2` |
| `cellxgene` | Single-cell RNA-seq data (setup required) | `gget cellxgene --gene ACE2 --tissue lung` |
| `enrichr` | GO/pathway enrichment analysis | `gget enrichr -db ontology ACE2 AGT` |
| `bgee` | Orthologs / expression across species | `gget bgee ENSG00000169194` |
| `opentargets` | Disease & drug associations | `gget opentargets ENSG00000169194` |
| `cbio` | Cancer genomics (cBioPortal) | `gget cbio search breast` |
| `cosmic` | Somatic mutations (requires account) | `gget cosmic EGFR` |

### Other

| Module | What it does |
|--------|-------------|
| `mutate` | Generate mutated sequences from annotations |
| `setup` | Install module-specific dependencies |

## Key Workflows

### Gene Discovery → Sequence Analysis

```python
# Search → info → sequence → BLAST
results = gget.search(["GABA", "receptor"], species="homo_sapiens")
info = gget.info(results["ensembl_id"].tolist()[:5])
sequences = gget.seq(results["ensembl_id"].tolist()[:5], translate=True)
blast_hits = gget.blast(my_sequence, database="swissprot", limit=10)
```

### Expression & Enrichment

```python
# Tissue expression → correlated genes → enrichment
tissue_expr = gget.archs4("ACE2", which="tissue")
correlated = gget.archs4("ACE2", which="correlation")
enrichment = gget.enrichr(correlated["gene_symbol"].tolist()[:50], database="ontology", plot=True)
```

### Enrichr Database Shortcuts

| Shortcut | Database |
|----------|----------|
| `pathway` | KEGG_2021_Human |
| `transcription` | ChEA_2016 |
| `ontology` | GO_Biological_Process_2021 |
| `diseases_drugs` | GWAS_Catalog_2019 |
| `celltypes` | PanglaoDB_Augmented_2021 |

### Single-Cell Data

```python
# Gene symbols are case-sensitive: 'PAX7' (human), 'Pax7' (mouse)
adata = gget.cellxgene(gene=["ACE2", "ABCA1"], tissue="lung", cell_type="epithelial cell")
# Filters: disease, development_stage, sex, assay, donor_id, ethnicity
```

### Comparative Genomics

```python
orthologs = gget.bgee("ENSG00000169194", type="orthologs")
human_seq = gget.seq("ENSG00000169194", translate=True)
alignment = gget.muscle([human_seq, mouse_seq])
```

## Best Practices

- Use `--limit` to control result sizes
- Save results with `-o` for reproducibility
- Process max ~1000 Ensembl IDs at once with `gget info`
- Use `gget diamond` with `--threads` for faster local alignment; save DB with `--diamond_db`
- For `gget muscle`, use `-s5` (Super5) for large datasets
- AlphaFold multimer: use `-mr 20` for accuracy, `-r` for AMBER relaxation
- Update regularly: `uv pip install --upgrade gget` (databases change structure)

## Attribution

Adapted from [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills) (BSD-2-Clause).
Citation: Luebbert & Pachter (2023) Bioinformatics. https://doi.org/10.1093/bioinformatics/btac836
