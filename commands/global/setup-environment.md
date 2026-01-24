---
name: setup-environment
description: Plan and set up the best Python environment type (venv or conda) for the current project
---

Help the user plan and set up the appropriate Python environment (venv or conda) for their project.

## Your Task

### Step 1: Understand Project Requirements

Ask the user about their project:

```
Let me help you choose the best environment type for this project.

What type of project are you working on?

1. Pure Python project (web dev, scripting, APIs, etc.)
2. Data science / Machine learning
3. Bioinformatics / Genomics
4. Scientific computing (numpy, scipy, etc.)
5. Mixed (Python + other languages/tools)
6. Other (please describe)
```

Wait for user response.

### Step 2: Gather Package Requirements

Ask follow-up questions based on project type:

```
What packages/tools do you need? (can be approximate or specific)

For example:
- Django, Flask, requests
- pandas, numpy, scikit-learn
- biopython, pysam, samtools
- tensorflow, pytorch
- etc.
```

### Step 3: Analyze and Recommend

Based on the responses, apply this decision logic:

**Recommend Python venv if:**
- Pure Python project
- Simple web development (Django, Flask, FastAPI)
- All packages available on PyPI
- No compiled extensions or system libraries needed
- Fast environment creation is important

**Recommend Conda if:**
- Data science / machine learning packages (numpy, scipy, pandas, scikit-learn)
- Bioinformatics tools (many available via bioconda)
- Scientific computing with compiled libraries
- Need to manage Python version
- Cross-language dependencies (R, C++, Fortran libraries)
- GPU computing (CUDA, cuDNN)
- Need reproducible binary environments

**Present recommendation:**

```
Based on your project requirements, I recommend: [venv/conda]

Reasons:
- [List specific reasons based on their needs]
- [Mention key advantages]
- [Note any potential issues avoided]

Would you like to proceed with setting up a [venv/conda] environment?
```

### Step 4: Set Up Environment (After Confirmation)

#### If Python venv:

```bash
# Check if .venv already exists
if [ -d ".venv" ]; then
    echo "A .venv directory already exists. Options:"
    echo "1. Use existing environment"
    echo "2. Remove and recreate"
    echo "3. Cancel"
    read -p "Choose (1-3): "
fi

# Create new venv
echo "Creating Python virtual environment..."
python -m venv .venv

# Activate instructions
echo ""
echo "Environment created successfully!"
echo ""
echo "To activate:"
echo "  source .venv/bin/activate    # Linux/Mac"
echo "  .venv\\Scripts\\activate      # Windows"
echo ""
echo "After activation, install packages:"
echo "  pip install package-name"
```

**Then offer to:**
1. Create `.gitignore` entry if needed
2. Create `requirements.txt` template
3. Show next steps

#### If Conda:

```bash
# Check current directory name for environment naming
PROJECT_NAME=$(basename "$PWD")

echo "I'll create a conda environment named: $PROJECT_NAME"
echo ""
read -p "Press Enter to use this name, or type a different name: " CUSTOM_NAME

if [ -n "$CUSTOM_NAME" ]; then
    ENV_NAME="$CUSTOM_NAME"
else
    ENV_NAME="$PROJECT_NAME"
fi

# Detect Python version preference
echo ""
echo "Which Python version would you like?"
echo "1. Python 3.11 (latest stable, recommended)"
echo "2. Python 3.10"
echo "3. Python 3.9"
echo "4. Other (specify)"
read -p "Choose (1-4): " PY_VERSION_CHOICE

case $PY_VERSION_CHOICE in
    1) PY_VERSION="3.11" ;;
    2) PY_VERSION="3.10" ;;
    3) PY_VERSION="3.9" ;;
    4) read -p "Enter Python version: " PY_VERSION ;;
    *) PY_VERSION="3.11" ;;
esac

# Create conda environment
echo ""
echo "Creating conda environment: $ENV_NAME with Python $PY_VERSION"
conda create -n "$ENV_NAME" python="$PY_VERSION" -y

echo ""
echo "Environment created successfully!"
echo ""
echo "To activate:"
echo "  conda activate $ENV_NAME"
echo ""
echo "After activation, install packages:"
echo "  conda install -c conda-forge package-name    # For most packages"
echo "  conda install -c bioconda package-name       # For bioinformatics tools"
echo "  pip install package-name                     # If not in conda"
```

**Then offer to:**
1. Create `environment.yml` template
2. Add environment name to `.gitignore`
3. Show recommended channels for their project type
4. Show next steps

### Step 5: Create Supporting Files

#### For venv projects:

**Create `.gitignore` entry (if not exists):**
```bash
# Check if .gitignore exists and already has venv entries
if ! grep -q "\.venv" .gitignore 2>/dev/null; then
    cat >> .gitignore << 'EOF'

# Python virtual environment
.venv/
venv/
env/
ENV/
EOF
    echo "✓ Added .venv to .gitignore"
fi
```

**Create `requirements.txt` template:**
```bash
cat > requirements.txt << 'EOF'
# Add your project dependencies here
# Example:
# requests>=2.28.0
# pandas>=2.0.0

EOF
echo "✓ Created requirements.txt template"
```

**Create README section:**
```markdown
## Setup

1. Create virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # Linux/Mac
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
```

#### For conda projects:

**Create `environment.yml` template:**
```yaml
name: project-name
channels:
  - conda-forge      # For most packages
  - bioconda         # For bioinformatics tools (if needed)
  - defaults
dependencies:
  - python=3.11
  # Add conda packages here
  # Example:
  # - pandas>=2.0
  # - numpy>=1.24
  # - scikit-learn>=1.3
  - pip
  - pip:
    # Add pip-only packages here
    # Example:
    # - some-pip-package>=1.0
```

**Adapt channels based on project type:**
- Data science: `conda-forge`
- Bioinformatics: `conda-forge`, `bioconda`
- General: `conda-forge`, `defaults`

**Create `.gitignore` entry:**
```bash
if ! grep -q "\.conda" .gitignore 2>/dev/null; then
    cat >> .gitignore << 'EOF'

# Conda
.conda/
*.egg-info/
EOF
    echo "✓ Added conda directories to .gitignore"
fi
```

**Create README section:**
```markdown
## Setup

1. Create conda environment:
   ```bash
   conda env create -f environment.yml
   ```

2. Activate environment:
   ```bash
   conda activate project-name
   ```

3. Or create manually:
   ```bash
   conda create -n project-name python=3.11
   conda activate project-name
   conda install -c conda-forge package-name
   ```
```

### Step 6: Provide Next Steps

Show user what to do next:

```
✅ Environment setup complete!

Next steps:
1. Activate your environment:
   [show activation command based on type]

2. Install packages as needed:
   [show install commands based on type]

3. Verify installation:
   which python
   python --version
   pip list    # or: conda list

4. Start coding! Your environment is isolated and ready.

Tips:
- [Type-specific tips]
- Use `/list-skills` to see other available skills
- I'll automatically check your environment before any package installations
```

---

## Decision Logic Examples

### Example 1: Web Development Project

**User input:**
- Project type: Pure Python
- Packages: Django, requests, celery, redis

**Recommendation:**
```
I recommend: Python venv

Reasons:
- All packages (Django, requests, celery, redis) available on PyPI
- Pure Python project with no compiled dependencies
- Faster environment creation and activation
- Standard Python tooling, no extra installation needed

Python venv is perfect for web development projects like this.
```

### Example 2: Data Science Project

**User input:**
- Project type: Data science
- Packages: pandas, numpy, scikit-learn, matplotlib, jupyter

**Recommendation:**
```
I recommend: Conda

Reasons:
- Scientific packages (numpy, pandas, scikit-learn) have complex binary dependencies
- Conda manages these dependencies better than pip
- Ensures compatible BLAS/LAPACK libraries
- Better reproducibility across different systems
- Jupyter works well in conda environments

Conda is ideal for data science work with these packages.
```

### Example 3: Bioinformatics Project

**User input:**
- Project type: Bioinformatics
- Packages: biopython, pysam, samtools, bedtools, bwa

**Recommendation:**
```
I recommend: Conda (with bioconda channel)

Reasons:
- Most bioinformatics tools (samtools, bedtools, bwa) available via bioconda
- These tools have complex C/C++ dependencies
- Bioconda provides pre-compiled binaries
- Ensures compatible versions across the toolkit
- Many bio packages not available on PyPI

Conda with bioconda is the standard for bioinformatics workflows.

I'll set this up with conda-forge and bioconda channels enabled.
```

### Example 4: Simple Script Project

**User input:**
- Project type: Scripting
- Packages: requests, click, pyyaml

**Recommendation:**
```
I recommend: Python venv

Reasons:
- Lightweight dependencies, all pure Python
- Quick setup for scripting work
- No compiled extensions needed
- Easy to share as requirements.txt
- Standard Python tooling sufficient

Python venv is perfect for simple scripting projects.
```

---

## Special Considerations

### If User Already Has Environment

```
I notice there's already an environment in this directory:
- [Details about existing environment]

Options:
1. Use the existing environment (check what's installed)
2. Create a new environment (will need different name/location)
3. Remove and recreate (fresh start)
4. Cancel

What would you like to do?
```

### If Multiple Projects in Directory

```
⚠️ I notice this directory contains multiple projects or subdirectories.

Best practice: Create one environment per project root.

Recommendation:
- Navigate to specific project directory first
- Then run /setup-environment
- Or create one shared environment if projects truly share dependencies

Would you like to:
1. Continue in current directory
2. Cancel and let you navigate to specific project
```

### If Conda Not Installed

```
I would recommend conda for this project, but conda doesn't appear to be installed.

Options:
1. Install conda (I can guide you through this)
2. Use Python venv instead (good alternative)
3. Cancel and install conda yourself

Conda installation options:
- Miniconda (minimal, recommended): https://docs.conda.io/en/latest/miniconda.html
- Anaconda (full distribution): https://www.anaconda.com/download

What would you like to do?
```

---

## Summary

This command provides:
1. **Interactive planning** - Helps user choose best environment type
2. **Guided setup** - Creates environment with appropriate settings
3. **Supporting files** - Generates .gitignore, requirements/environment files
4. **Documentation** - Provides README snippets
5. **Next steps** - Clear instructions on what to do next

The command works together with the `python-environment-management` skill to ensure:
- Proper environment selection upfront
- Safe package installations later
- Consistent environment management workflow
