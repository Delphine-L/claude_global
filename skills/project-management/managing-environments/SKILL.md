---
name: managing-environments
description: Best practices for managing development environments including Python venv and conda. Always check environment status before installations and confirm with user before proceeding.
version: 1.1.0
allowed-tools: Read, Grep, Glob, Bash
---

# Managing Development Environments

Guidelines for working with Python virtual environments (venv) and conda environments. This skill ensures safe, organized package installations by always checking and confirming the active environment before proceeding.

**Supporting files in this directory:**
- `installation-patterns.md` - Installation commands for venv and conda, channel priority, TOS error handling
- `best-practices-and-scenarios.md` - Common scenarios, best practices, resumable data fetch patterns
- `troubleshooting-and-examples.md` - Troubleshooting common issues and worked examples

## When to Use This Skill

Activate this skill whenever:
- Installing Python packages or tools
- User requests to install dependencies
- Setting up a new Python project
- Debugging import or package issues
- Working with any Python development

## Core Principles

1. **Always check environment status** before any installation
2. **Always confirm with user** which environment to use
3. **Never install without environment confirmation**
4. **Warn if no environment is active**
5. **Help user choose appropriate environment type**

---

## Environment Detection Workflow

### Step 1: Check Environment Status

**Before ANY installation command**, run these checks:

```bash
# Check for active venv
echo "Python executable: $(which python)"
echo "Virtual environment: $VIRTUAL_ENV"

# Check for conda environment
echo "Conda environment: $CONDA_DEFAULT_ENV"
conda info --envs 2>/dev/null || echo "Conda not available"
```

### Step 2: Interpret Results

**Scenario A: venv is active**
```
Python executable: /path/to/project/.venv/bin/python
Virtual environment: /path/to/project/.venv
Conda environment:
```
-> Python venv is active

**Scenario B: conda environment is active**
```
Python executable: /path/to/miniconda3/envs/myenv/bin/python
Virtual environment:
Conda environment: myenv
```
-> Conda environment is active

**Scenario C: No environment (system Python)**
```
Python executable: /usr/bin/python
Virtual environment:
Conda environment:
```
-> No environment active! Warn user.

**Scenario D: Both detected (rare)**
```
Virtual environment: /path/to/.venv
Conda environment: base
```
-> Both active, prioritize what `which python` shows, but confirm with user

### Step 3: Confirm with User

**Always ask before proceeding:**

```
I've detected the following environment:
- Environment type: [venv/conda/none]
- Location: [path]
- Python version: [version]

Is this the environment you want me to use for installing [package/tool]?
```

**Wait for user confirmation before proceeding.**

For installation commands by environment type, see `installation-patterns.md`.

---

## No Environment Active - Warning & Planning

If no environment is detected, **DO NOT PROCEED with installation**. Instead:

### Step 1: Warn User

```
WARNING: No Python environment detected!

You're currently using system Python:
- Location: [path to python]
- Version: [version]

Installing packages to system Python can:
- Cause conflicts with system packages
- Require sudo/admin privileges
- Make projects difficult to reproduce
- Break system tools that depend on specific versions

I recommend creating a virtual environment first.
```

### Step 2: Help Choose Environment Type

**Decision Tree:**

```
Question: What type of project are you working on?

A. Pure Python project (web dev, scripting, etc.)
   -> Recommend: Python venv
   -> Fast, lightweight, standard Python tool

B. Data science / Scientific computing
   -> Ask: Do you need non-Python dependencies? (R, C libraries, etc.)

   B1. Yes (or using packages like numpy, scipy, pandas, etc.)
       -> Recommend: Conda
       -> Better binary dependency management

   B2. No, only Python packages
       -> Recommend: Python venv
       -> Simpler and faster

C. Bioinformatics / Genomics
   -> Recommend: Conda (with bioconda channel)
   -> Most tools available via bioconda
   -> Manages complex dependencies well

D. Galaxy tool development
   -> Recommend: Conda
   -> Galaxy uses conda for tool dependencies
   -> Direct compatibility
```

### Step 3: Offer to Create Environment

**For venv:**
```bash
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
which python
```

**For conda:**
```bash
conda create -n project-name python=3.11
conda activate project-name
conda info --envs
which python
```

---

## Environment Selection Guidelines

### Use Python venv When:
- Pure Python project
- Simple dependencies (all available on PyPI)
- Standard web development (Django, Flask, FastAPI)
- No compiled extensions or C libraries
- Want fastest environment creation
- Working with Python 3.3+

**Advantages:** Lightweight, fast, built into Python, works on all platforms.
**Disadvantages:** Harder to manage non-Python dependencies, binary packages may need system libraries.

### Use Conda Environment When:
- Data science / machine learning
- Scientific computing (numpy, scipy, pandas)
- Bioinformatics / genomics
- Need specific Python versions
- Cross-language dependencies (R, C++, etc.)
- Galaxy tool development
- Complex binary dependencies

**Advantages:** Manages binary dependencies, cross-language support, better for scientific packages, can manage Python version.
**Disadvantages:** Slower than venv, larger disk space, requires conda installation.

---

## Quick Reference

### Environment Detection Commands

```bash
# Check what's active
which python
echo $VIRTUAL_ENV
echo $CONDA_DEFAULT_ENV

# Python version
python --version

# Installed packages
pip list          # for pip
conda list        # for conda

# Environment location
pip show package-name  # shows where package is installed
```

### Activation Commands

```bash
# venv
source .venv/bin/activate                    # Linux/Mac
.venv\Scripts\activate                       # Windows

# conda
conda activate environment-name

# Deactivation
deactivate                                   # venv
conda deactivate                             # conda
```

For common scenarios, best practices, troubleshooting, and worked examples, see the supporting files in this directory.

---

## Summary

**Always remember:**

1. **Check environment before any installation**
2. **Show user what environment is active**
3. **Confirm with user before proceeding**
4. **Warn if no environment is active**
5. **Help choose appropriate environment type**
6. **Document environment setup for reproducibility**

**Never:**
- Install without checking environment
- Assume user wants to use system Python
- Install without user confirmation
- Skip warning about base conda environment

This skill ensures clean, reproducible, conflict-free Python environments across all projects.
