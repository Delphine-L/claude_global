---
name: gnomad-database
description: Query gnomAD (Genome Aggregation Database) for population allele frequencies, variant constraint scores (pLI, LOEUF), and loss-of-function intolerance via GraphQL API. Essential for variant pathogenicity interpretation, rare disease genetics, and identifying loss-of-function intolerant genes.
version: 1.0.0
allowed-tools: Read, Grep, Glob, Bash
---

# gnomAD Database

## Overview

gnomAD is the largest publicly available collection of human genetic variation. gnomAD v4 contains exome sequences from 730,947 individuals and genome sequences from 76,215 individuals across diverse ancestries.

**Key resources:**
- Browser: https://gnomad.broadinstitute.org/
- GraphQL API: https://gnomad.broadinstitute.org/api
- Downloads: https://gnomad.broadinstitute.org/downloads

## When to Use This Skill

- **Variant frequency lookup**: Checking if a variant is rare, common, or absent
- **Pathogenicity assessment**: Filtering benign common variants (ACMG BA1/BS1/PM2)
- **Loss-of-function intolerance**: pLI and LOEUF scores for gene constraint
- **Population-stratified frequencies**: Comparing allele frequencies across ancestries
- **Constraint analysis**: Identifying genes depleted of missense or LoF variation

## Supporting Files

- **[graphql_queries.md](references/graphql_queries.md)** - Complete GraphQL query templates, population IDs, LoF annotation fields, in silico predictor IDs, Python helper with retry logic
- **[variant_interpretation.md](references/variant_interpretation.md)** - ACMG/AMP criteria thresholds, LoF assessment (LOFTEE), homozygous observations, in silico predictor score ranges, ancestry-specific considerations

## GraphQL API

Endpoint: `POST https://gnomad.broadinstitute.org/api`

**Datasets:** `gnomad_r4` (v4 exomes, GRCh38), `gnomad_r4_genomes`, `gnomad_r3` (GRCh38), `gnomad_r2_1` (GRCh37)

### Query Variants by Gene

```python
import requests

def query_gnomad_gene(gene_symbol, dataset="gnomad_r4", reference_genome="GRCh38"):
    """Fetch variants in a gene from gnomAD."""
    url = "https://gnomad.broadinstitute.org/api"
    query = """
    query GeneVariants($gene_symbol: String!, $dataset: DatasetId!, $reference_genome: ReferenceGenomeId!) {
      gene(gene_symbol: $gene_symbol, reference_genome: $reference_genome) {
        gene_id
        gene_symbol
        variants(dataset: $dataset) {
          variant_id
          pos
          ref
          alt
          consequence
          genome { af ac an ac_hom populations { id ac an af } }
          exome { af ac an ac_hom }
          lof
          lof_flags
          lof_filter
        }
      }
    }
    """
    variables = {"gene_symbol": gene_symbol, "dataset": dataset, "reference_genome": reference_genome}
    response = requests.post(url, json={"query": query, "variables": variables})
    return response.json()

# Filter to rare PTVs
result = query_gnomad_gene("BRCA1")
variants = result["data"]["gene"]["variants"]
rare_ptvs = [v for v in variants
    if v.get("lof") == "HC"
    and v.get("genome", {}).get("af", 1) < 0.001]
```

### Query a Specific Variant

```python
def query_gnomad_variant(variant_id, dataset="gnomad_r4"):
    """Fetch details for a variant (e.g., '17-43094692-G-A')."""
    url = "https://gnomad.broadinstitute.org/api"
    query = """
    query VariantDetails($variantId: String!, $dataset: DatasetId!) {
      variant(variantId: $variantId, dataset: $dataset) {
        variant_id
        chrom pos ref alt consequence lof rsids
        genome { af ac an ac_hom populations { id ac an af } }
        exome { af ac an ac_hom populations { id ac an af } }
        in_silico_predictors { id value flags }
        clinvar_variation_id
      }
    }
    """
    response = requests.post(url, json={"query": query, "variables": {"variantId": variant_id, "dataset": dataset}})
    return response.json()
```

### Gene Constraint Scores

```python
def query_gnomad_constraint(gene_symbol, reference_genome="GRCh38"):
    """Fetch constraint scores for a gene."""
    url = "https://gnomad.broadinstitute.org/api"
    query = """
    query GeneConstraint($gene_symbol: String!, $reference_genome: ReferenceGenomeId!) {
      gene(gene_symbol: $gene_symbol, reference_genome: $reference_genome) {
        gene_id gene_symbol
        gnomad_constraint {
          exp_lof exp_mis exp_syn obs_lof obs_mis obs_syn
          oe_lof oe_mis oe_syn oe_lof_lower oe_lof_upper
          lof_z mis_z syn_z pLI
        }
      }
    }
    """
    response = requests.post(url, json={"query": query, "variables": {"gene_symbol": gene_symbol, "reference_genome": reference_genome}})
    return response.json()
```

**Constraint score interpretation:**

| Score | Range | Meaning |
|-------|-------|---------|
| `pLI` | 0-1 | Probability of LoF intolerance; >0.9 = highly intolerant |
| `LOEUF` | 0-inf | LoF observed/expected upper bound; <0.35 = constrained |
| `oe_lof` | 0-inf | Observed/expected ratio for LoF variants |
| `mis_z` | -inf to inf | Missense constraint z-score; >3.09 = constrained |
| `syn_z` | -inf to inf | Synonymous z-score (control; should be near 0) |

LOEUF is preferred over pLI (less sensitive to sample size).

### Population Frequency Analysis

```python
import pandas as pd

def get_population_frequencies(variant_id, dataset="gnomad_r4"):
    """Extract per-population allele frequencies."""
    url = "https://gnomad.broadinstitute.org/api"
    query = """
    query PopFreqs($variantId: String!, $dataset: DatasetId!) {
      variant(variantId: $variantId, dataset: $dataset) {
        variant_id
        genome { populations { id ac an af ac_hom } }
      }
    }
    """
    response = requests.post(url, json={"query": query, "variables": {"variantId": variant_id, "dataset": dataset}})
    populations = response.json()["data"]["variant"]["genome"]["populations"]
    df = pd.DataFrame(populations)
    return df[df["an"] > 0].sort_values("af", ascending=False)
```

**Population IDs:** `afr` (African), `ami` (Amish), `amr` (Admixed American), `asj` (Ashkenazi Jewish), `eas` (East Asian), `fin` (Finnish), `mid` (Middle Eastern), `nfe` (Non-Finnish European), `sas` (South Asian)

## Key Workflows

### Variant Pathogenicity Assessment

1. Check population frequency (AF < 1% recessive, < 0.1% dominant)
2. Check ancestry-specific frequencies (variant rare overall may be common in one population)
3. Assess LoF confidence: `lof` field `HC` = high-confidence, `LC` = low-confidence
4. Apply ACMG: BA1 (AF > 5%), BS1 (AF > prevalence), PM2 (absent/very rare)

### Gene Prioritization in Rare Disease

1. Query constraint scores for candidate genes
2. Filter pLI > 0.9 or LOEUF < 0.35
3. Cross-reference with observed LoF variants
4. Integrate with ClinVar

## Best Practices

- Use gnomAD v4 (`gnomad_r4`) by default; v2 only for GRCh37 compatibility
- Handle null responses: absence in gnomAD is informative but not conclusive
- Distinguish exome vs genome data: genome has more uniform coverage
- Rate limit GraphQL queries: add delays between requests
- Check `ac_hom` for recessive disease analysis

## Attribution

Adapted from [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills) (CC0-1.0). Original skill by Kuan-lin Huang.
