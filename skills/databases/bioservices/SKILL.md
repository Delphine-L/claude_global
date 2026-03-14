---
name: bioservices
description: Unified Python interface to 40+ bioinformatics services (UniProt, KEGG, ChEMBL, Reactome, PSICQUIC). Best for cross-database analysis, ID mapping, and multi-service workflows. For quick single-database lookups use gget.
version: 1.0.0
allowed-tools: Read, Grep, Glob, Bash
---

# BioServices

Python package providing programmatic access to ~40 bioinformatics web services. Handles REST and SOAP protocols transparently.

## Installation

```bash
uv pip install bioservices
```

## When to Use

- Querying multiple databases in a single workflow (UniProt + KEGG + ChEMBL)
- ID mapping across databases (UniProt ↔ KEGG ↔ Ensembl ↔ PDB)
- Pathway analysis (KEGG, Reactome)
- Protein-protein interaction queries (PSICQUIC: MINT, IntAct, BioGRID, 30+ others)
- Gene ontology lookups (QuickGO)

For quick single-database lookups, prefer `gget`.

## Supporting Files

- **[services_reference.md](references/services_reference.md)** - All 40+ services with methods
- **[workflow_patterns.md](references/workflow_patterns.md)** - Multi-step analysis workflows
- **[identifier_mapping.md](references/identifier_mapping.md)** - Cross-database ID conversion guide

## Scripts

- **`scripts/protein_analysis_workflow.py`** - End-to-end protein characterization
- **`scripts/pathway_analysis.py`** - KEGG pathway network extraction
- **`scripts/compound_cross_reference.py`** - Multi-database compound search
- **`scripts/batch_id_converter.py`** - Bulk identifier mapping

## Core Capabilities

### 1. Protein Analysis (UniProt)

```python
from bioservices import UniProt

u = UniProt(verbose=False)

# Search by name
results = u.search("ZAP70_HUMAN", frmt="tab", columns="id,genes,organism")

# Retrieve FASTA
sequence = u.retrieve("P43403", "fasta")

# Map identifiers
kegg_ids = u.mapping(fr="UniProtKB_AC-ID", to="KEGG", query="P43403")
```

**Supported mappings:** UniProtKB ↔ KEGG, Ensembl, PDB, RefSeq, and many more.

### 2. Pathway Analysis (KEGG)

```python
from bioservices import KEGG

k = KEGG()
k.organism = "hsa"

# Find pathways containing a gene
pathways = k.get_pathway_by_gene("7535", "hsa")  # ZAP70

# Parse pathway data
data = k.get("hsa04660")
parsed = k.parse(data)

# Extract interactions
interactions = k.parse_kgml_pathway("hsa04660")
sif_data = k.pathway2sif("hsa04660")  # Simple Interaction Format
```

### 3. Compound Cross-Referencing

```python
from bioservices import KEGG, UniChem

k = KEGG()
results = k.find("compound", "Geldanamycin")  # → cpd:C11222

# KEGG → ChEMBL via UniChem
u = UniChem()
chembl_id = u.get_compound_id_from_kegg("C11222")
```

### 4. Sequence Analysis (BLAST)

```python
from bioservices import NCBIblast

s = NCBIblast(verbose=False)
jobid = s.run(program="blastp", sequence=protein_sequence,
              stype="protein", database="uniprotkb",
              email="your.email@example.com")
s.getStatus(jobid)  # Async - check status first
results = s.getResult(jobid, "out")
```

### 5. Gene Ontology (QuickGO)

```python
from bioservices import QuickGO

g = QuickGO(verbose=False)
term_info = g.Term("GO:0003824", frmt="obo")
annotations = g.Annotation(protein="P43403", format="tsv")
```

### 6. Protein-Protein Interactions (PSICQUIC)

```python
from bioservices import PSICQUIC

s = PSICQUIC(verbose=False)
interactions = s.query("mint", "ZAP70 AND species:9606")
databases = s.activeDBs  # 30+ databases
```

## Best Practices

- Set `verbose=False` to suppress HTTP request details
- Adjust timeout for slow connections: `k.TIMEOUT = 30`
- Wrap service calls in try-except (APIs can be flaky)
- **Organism codes:** `hsa` (human), `mmu` (mouse), `dme` (fly), `sce` (yeast). List all: `k.list("organism")`
- Works well with BioPython (sequences), Pandas (tabular data), NetworkX (pathway networks)

## Attribution

Adapted from [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills) (GPLv3).
Docs: https://bioservices.readthedocs.io/ | Source: https://github.com/cokelaer/bioservices
