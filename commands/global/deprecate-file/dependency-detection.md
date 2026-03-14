# Dependency Detection

Python code for detecting file dependencies during deprecation. This module identifies files that were used to create the target file, organized by file type.

## Full Detection Module

```python
import os
import re
import json
from pathlib import Path
from datetime import datetime

def detect_dependencies(file_path):
    """
    Detect files that were used to create the target file.
    Returns list of dependency file paths.
    """
    dependencies = set()
    file_path = Path(file_path)

    suffix = file_path.suffix.lower()

    if suffix == '.ipynb':
        dependencies.update(detect_notebook_dependencies(file_path))
    elif suffix == '.py':
        dependencies.update(detect_python_dependencies(file_path))
    elif suffix in ['.png', '.pdf', '.svg', '.jpg']:
        dependencies.update(detect_figure_dependencies(file_path))
    elif suffix in ['.csv', '.tsv', '.txt', '.json']:
        dependencies.update(detect_data_dependencies(file_path))

    dependencies.discard(str(file_path))
    return sorted(dependencies)


def detect_notebook_dependencies(notebook_path):
    """Find files read or used by a notebook."""
    dependencies = set()

    try:
        with open(notebook_path, 'r') as f:
            nb = json.load(f)

        for cell in nb.get('cells', []):
            if cell.get('cell_type') == 'code':
                source = ''.join(cell.get('source', []))

                # pd.read_csv('file.csv'), etc.
                for match in re.finditer(r'read_\w+\([\'"]([^\'"]+)[\'"]', source):
                    dep_path = Path(match.group(1))
                    if dep_path.exists():
                        dependencies.add(str(dep_path.resolve()))

                # open() calls (read mode)
                for match in re.finditer(r'open\([\'"]([^\'"]+)[\'"]', source):
                    dep_path = Path(match.group(1))
                    if dep_path.exists() and not match.group(0).endswith("'w'"):
                        dependencies.add(str(dep_path.resolve()))

                # File paths referencing data/*, figures/*, scripts/*
                for match in re.finditer(r'[\'"]([^\'"]*(data|figures|scripts)/[^\'"]+)[\'"]', source):
                    dep_path = Path(match.group(1))
                    if dep_path.exists():
                        dependencies.add(str(dep_path.resolve()))

    except Exception as e:
        print(f"Warning: Could not parse {notebook_path}: {e}")

    return dependencies


def detect_python_dependencies(script_path):
    """Find files read or used by a Python script."""
    dependencies = set()

    try:
        with open(script_path, 'r') as f:
            content = f.read()

        for match in re.finditer(r'read_\w+\([\'"]([^\'"]+)[\'"]', content):
            dep_path = Path(match.group(1))
            if dep_path.exists():
                dependencies.add(str(dep_path.resolve()))

        for match in re.finditer(r'open\([\'"]([^\'"]+)[\'"].*[\'"]r[\'"]', content):
            dep_path = Path(match.group(1))
            if dep_path.exists():
                dependencies.add(str(dep_path.resolve()))

        # argparse defaults referencing data/figures paths
        for match in re.finditer(r'default=[\'"]([^\'"]*(data|figures)/[^\'"]+)[\'"]', content):
            dep_path = Path(match.group(1))
            if dep_path.exists():
                dependencies.add(str(dep_path.resolve()))

    except Exception as e:
        print(f"Warning: Could not parse {script_path}: {e}")

    return dependencies


def detect_figure_dependencies(figure_path):
    """Find code that generated this figure."""
    dependencies = set()
    figure_name = Path(figure_path).name
    project_root = Path.cwd()

    # Search notebooks
    for nb_file in project_root.rglob('*.ipynb'):
        if 'deprecated' in str(nb_file):
            continue
        try:
            with open(nb_file, 'r') as f:
                content = f.read()
            if figure_name in content and ('savefig' in content or 'to_file' in content):
                dependencies.add(str(nb_file.resolve()))
        except:
            pass

    # Search Python scripts
    for py_file in project_root.rglob('*.py'):
        if 'deprecated' in str(py_file):
            continue
        try:
            with open(py_file, 'r') as f:
                content = f.read()
            if figure_name in content and 'savefig' in content:
                dependencies.add(str(py_file.resolve()))
        except:
            pass

    return dependencies


def detect_data_dependencies(data_path):
    """Find code that generated this data file."""
    dependencies = set()
    data_name = Path(data_path).name
    project_root = Path.cwd()

    # Search notebooks
    for nb_file in project_root.rglob('*.ipynb'):
        if 'deprecated' in str(nb_file):
            continue
        try:
            with open(nb_file, 'r') as f:
                content = f.read()
            if data_name in content and ('to_csv' in content or 'to_json' in content or 'dump' in content):
                dependencies.add(str(nb_file.resolve()))
        except:
            pass

    # Search Python scripts
    for py_file in project_root.rglob('*.py'):
        if 'deprecated' in str(py_file):
            continue
        try:
            with open(py_file, 'r') as f:
                content = f.read()
            if data_name in content and ('write' in content or 'dump' in content):
                dependencies.add(str(py_file.resolve()))
        except:
            pass

    return dependencies


# CLI entry point
if __name__ == '__main__':
    import sys
    file_path = sys.argv[1]
    deps = detect_dependencies(file_path)

    if deps:
        print("DEPENDENCIES:")
        for dep in deps:
            print(dep)
    else:
        print("NO_DEPENDENCIES")
```
