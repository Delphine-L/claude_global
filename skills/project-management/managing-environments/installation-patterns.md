# Installation Patterns by Environment Type

## For Python venv

```bash
# Activate (if needed)
source .venv/bin/activate  # Linux/Mac
# or
.venv\Scripts\activate  # Windows

# Install packages
pip install package-name

# Install with specific version
pip install package-name==1.2.3

# Install from requirements
pip install -r requirements.txt

# Install development dependencies
pip install -e ".[dev]"
```

## For Conda Environment

```bash
# Activate (if needed)
conda activate environment-name

# Install from conda-forge (preferred for scientific packages)
conda install -c conda-forge package-name

# Install with pip (if not available in conda)
pip install package-name

# Install from environment file
conda env update -f environment.yml

# Install specific version
conda install package-name=1.2.3
```

## Critical: Channel Priority for Conda

For bioinformatics/scientific packages:
1. Try `conda-forge` first: `conda install -c conda-forge package`
2. Try `bioconda` for bio tools: `conda install -c bioconda package`
3. Fall back to pip only if not available: `pip install package`

**Why:** Conda manages binary dependencies better than pip for scientific packages.

## Handling Conda TOS Acceptance Errors

If conda installation fails with:
```
CondaToSNonInteractiveError: Terms of Service have not been accepted
```

**Solution**: Use pip instead (installed packages work identically):
```bash
/path/to/envs/ENV_NAME/bin/pip install PACKAGE_NAME
```

**Example** - Installing JupyterLab:
```bash
# This fails with TOS error
conda install -n curation_paper -c conda-forge jupyterlab -y

# Use pip instead
$HOME/miniconda3/envs/curation_paper/bin/pip install jupyterlab
```

Packages installed via pip integrate seamlessly with conda environments.
