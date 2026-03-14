# Common Scenarios and Example Scripts

Supporting reference for the **project-sharing** skill. See [SKILL.md](SKILL.md) for the main skill document.

---

## Common Scenarios

### Scenario 1: Sharing with Lab Collaborators

**Level:** Reproducible

**Include:**
- Cleaned analysis notebooks
- Processed data
- Figure generation scripts
- environment.yml
- README with reproduction steps

**Don't include:**
- Exploratory notebooks
- Failed analysis attempts
- Debug outputs
- Personal notes

### Scenario 2: Manuscript Supplementary Material

**Level:** Reproducible or Full (depending on journal)

**Include:**
- All notebooks used for figures in paper
- Scripts for each figure panel
- Processed data (or instructions to obtain)
- Complete environment specification
- Detailed methods document

**Best practices:**
- Number notebooks to match paper sections
- Export key figures in publication formats (PDF, high-res PNG)
- Include data dictionary for all variables
- Test reproduction on clean environment

### Scenario 3: Project Archival

**Level:** Full Traceability

**Include:**
- Complete data pipeline from raw to processed
- All versions of analysis
- Meeting notes or decision logs
- External tool versions
- System information

**Organization tips:**
- Use dates in directory names
- Keep chronological changelog
- Document all external dependencies
- Include contact info for questions

### Scenario 4: Data Repository Submission (Zenodo, Figshare)

**Level:** Full Traceability

**Additional considerations:**
- Add LICENSE file (CC BY 4.0, MIT, etc.)
- Include CITATION.cff or CITATION.txt
- Comprehensive metadata
- README with DOI/reference instructions
- Consider maximum file sizes
- Review repository-specific guidelines

---

## Example Scripts

### Create Sharing Package Script

```python
#!/usr/bin/env python3
"""Create sharing package for project."""

import shutil
from pathlib import Path
from datetime import date
import nbformat
from nbconvert.preprocessors import ClearOutputPreprocessor

def create_sharing_package(level='reproducible', output_dir=None):
    """
    Create sharing package.

    Args:
        level: 'summary', 'reproducible', or 'full'
        output_dir: Output directory name (auto-generated if None)
    """

    # Create output directory
    if output_dir is None:
        output_dir = f"shared-{date.today():%Y%m%d}-{level}"

    share_path = Path(output_dir)
    share_path.mkdir(exist_ok=True)

    print(f"Creating {level} sharing package in {share_path}")

    # Create structure based on level
    if level == 'summary':
        create_summary_package(share_path)
    elif level == 'reproducible':
        create_reproducible_package(share_path)
    elif level == 'full':
        create_full_package(share_path)

    print(f"Package created: {share_path}")
    print(f"  Review and compress: tar -czf {share_path}.tar.gz {share_path}")

def clean_notebook(input_path, output_path):
    """Clean notebook outputs and debug cells."""
    with open(input_path) as f:
        nb = nbformat.read(f, as_version=4)

    # Clear outputs
    clear = ClearOutputPreprocessor()
    nb, _ = clear.preprocess(nb, {})

    # Remove debug cells
    nb.cells = [c for c in nb.cells
                if 'debug' not in c.metadata.get('tags', [])]

    with open(output_path, 'w') as f:
        nbformat.write(nb, f)

# ... implement level-specific functions ...

if __name__ == '__main__':
    import sys
    level = sys.argv[1] if len(sys.argv) > 1 else 'reproducible'
    create_sharing_package(level)
```
