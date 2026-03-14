# Standard Project Structures

Detailed directory structure templates for different project types.

## Research/Analysis Projects

```
project-name/
├── README.md                 # Project overview and getting started
├── .gitignore               # Exclude data, outputs, env files
├── environment.yml          # Conda environment (or requirements.txt)
├── data/                    # Input data (often gitignored)
│   ├── raw/                # Original, immutable data
│   ├── processed/          # Cleaned, transformed data
│   └── external/           # Third-party data
├── notebooks/               # Jupyter notebooks for exploration
│   ├── 01-exploration.ipynb
│   ├── 02-analysis.ipynb
│   └── figures/            # Notebook-generated figures
├── src/                     # Source code (reusable modules)
│   ├── __init__.py
│   ├── data_processing.py
│   ├── analysis.py
│   └── visualization.py
├── scripts/                 # Standalone scripts and workflows
│   ├── download_data.sh
│   └── run_pipeline.py
├── tests/                   # Unit tests
│   └── test_analysis.py
├── docs/                    # Documentation
│   ├── methods.md
│   └── references.md
├── results/                 # Analysis outputs (gitignored)
│   ├── figures/
│   ├── tables/
│   └── models/
└── config/                  # Configuration files
    └── analysis_config.yaml
```

## Development Projects

```
project-name/
├── README.md
├── .gitignore
├── setup.py                 # Package configuration
├── requirements.txt         # or pyproject.toml
├── src/
│   └── package_name/
│       ├── __init__.py
│       ├── core.py
│       └── utils.py
├── tests/
│   ├── test_core.py
│   └── test_utils.py
├── docs/
│   ├── api.md
│   └── usage.md
├── examples/                # Example usage
│   └── example_workflow.py
└── .github/                 # CI/CD workflows
    └── workflows/
        └── tests.yml
```

## Bioinformatics/Workflow Projects

```
project-name/
├── README.md
├── data/
│   ├── raw/                # Raw sequencing data
│   ├── reference/          # Reference genomes, annotations
│   └── processed/          # Workflow outputs
├── workflows/               # Galaxy .ga or Snakemake files
│   ├── preprocessing.ga
│   └── assembly.ga
├── config/
│   ├── workflow_params.yaml
│   └── sample_sheet.tsv
├── scripts/                # Helper scripts
│   ├── submit_workflow.py
│   └── quality_check.py
├── results/                # Final outputs
│   ├── figures/
│   ├── tables/
│   └── reports/
└── logs/                   # Workflow execution logs
```

## Data Analysis Projects with Notebooks

For projects involving Jupyter notebooks, data analysis, and visualization with many generated figures:

```
project-name/
├── README.md                # Project overview
├── .gitignore
├── notebooks/               # Jupyter notebooks (analysis, exploration)
│   ├── 01-data-loading.ipynb
│   ├── 02-exploratory-analysis.ipynb
│   └── 03-final-analysis.ipynb
├── figures/                 # ALL generated visualizations (PNG, PDF, SVG)
│   ├── fig1_distribution.png
│   ├── fig2_correlation.png
│   └── supplementary_*.png
├── data/                    # Data files (JSON, CSV, TSV, Excel)
│   ├── raw/                # (optional) Original, unprocessed data
│   ├── processed/          # (optional) Cleaned, processed data
│   ├── input_data.json
│   └── metadata.tsv
├── tests/                   # Test scripts (test_*.py, pytest)
│   ├── test_processing.py
│   └── test_analysis.py
├── scripts/                 # Standalone Python/R scripts
│   ├── data_fetch.py
│   └── preprocessing.py
├── docs/                    # Documentation (MD, RST files)
│   ├── methods.md
│   └── analysis_notes.md
└── archives/                # Compressed archives, old versions
    └── backup_YYYYMMDD.tar.gz
```

**Benefits of This Structure**:
- **Clear separation** of concerns (code vs. data vs. outputs)
- **Easy navigation**: Find all figures in one place
- **Scalability**: Handles 50+ figures without cluttering root
- **Git-friendly**: Easy to .gitignore large data/figures
- **Collaboration**: Standard structure reduces onboarding time

**When to Use This Structure**:
- Projects with multiple notebooks
- Analysis generating many visualizations (10+ figures)
- Multiple data sources/formats
- Team collaboration
- Long-term research projects

## MANIFEST Integration

For enhanced navigation and token efficiency, add MANIFEST.md files:

```
project-name/
├── MANIFEST.md                  # Root project index (~1,500 tokens)
├── MANIFEST_TEMPLATE.md         # Template for creating new MANIFESTs
├── notebooks/
│   ├── MANIFEST.md             # (optional) Notebook catalog
│   └── [notebook files]
├── figures/
│   ├── MANIFEST.md             # Figure catalog (~500-1,000 tokens)
│   └── [figure files]
├── data/
│   ├── MANIFEST.md             # Data inventory (~500-1,000 tokens)
│   └── [data files]
├── scripts/
│   ├── MANIFEST.md             # Script documentation (~500-1,000 tokens)
│   └── [script files]
└── documentation/
    ├── MANIFEST.md             # Doc organization (~500-1,000 tokens)
    └── [doc files]
```

Benefits:
- 85-90% token reduction for session startup
- Complete project context in ~2,000 tokens (vs 15,000+)
- Quick work resumption without reading files
- Clear workflow documentation

See `manifest-system.md` for complete MANIFEST documentation.
