# Troubleshooting and Examples

## Troubleshooting

### Issue 1: "pip: command not found" in venv

**Problem:** venv created but pip not available

**Solution:**
```bash
python -m ensurepip
python -m pip install --upgrade pip
```

### Issue 2: Conda environment activation fails

**Problem:** `conda activate` doesn't work

**Solution:**
```bash
# Initialize conda for shell
conda init bash  # or zsh, fish, etc.

# Restart shell or source
source ~/.bashrc
```

### Issue 3: Wrong Python version in environment

**For venv:**
```bash
# Specify Python version when creating
python3.11 -m venv .venv
```

**For conda:**
```bash
# Specify version explicitly
conda create -n myenv python=3.11
```

### Issue 4: Package conflicts

**For venv:**
```bash
# Start fresh
rm -rf .venv
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**For conda:**
```bash
# Try updating resolver
conda update -n base conda
conda install -c conda-forge mamba  # Faster solver
mamba install package-name
```

---

## Examples

### Example 1: Safe Installation Flow

**User:** "Install requests"

**Claude:**
```
Let me check your environment first...

[Checks environment]

I see you're in a Python venv at: /home/user/project/.venv
Python version: 3.11.5

Is this the correct environment for installing requests?
```

**User:** "Yes"

**Claude:**
```bash
pip install requests
```

### Example 2: No Environment Warning

**User:** "Install scikit-learn"

**Claude:**
```
WARNING: No virtual environment detected!

You're using system Python at: /usr/bin/python3
Installing to system Python is not recommended.

This is a data science package. I suggest creating a conda environment:

conda create -n ml-project python=3.11
conda activate ml-project
conda install -c conda-forge scikit-learn

Would you like me to help set this up?
```

### Example 3: Environment Type Suggestion

**User:** "I need to install biopython, numpy, and pandas"

**Claude:**
```
I notice you need scientific and bioinformatics packages.

Currently: No environment active

I recommend creating a conda environment because:
- Better binary dependency management for numpy/pandas
- Bioconda channel has biopython
- Manages versions more reliably

Suggested setup:
conda create -n bio-project python=3.11
conda activate bio-project
conda install -c conda-forge pandas numpy
conda install -c bioconda biopython

Would you like to proceed with this?
```
