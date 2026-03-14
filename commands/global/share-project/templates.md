# Templates (Steps 6-7)

## README Template (Step 6)

```python
readme_content = f"""# {project_name}

## Description
{user_description}

## Contents

{'### Notebooks' if level >= 2 else '### Analysis'}
{list_files_in_section}

{'### Data' if level >= 2 else ''}
{data_description if level >= 2 else ''}

{'### Scripts' if level >= 2 else ''}
{script_description if level >= 2 else ''}

## Reproduction Instructions

{'### Requirements' if level >= 2 else ''}
{'Install dependencies:' if level >= 2 else ''}
{'```bash' if level >= 2 else ''}
{'conda env create -f environment.yml' if level >= 2 else ''}
{'# or' if level >= 2 else ''}
{'pip install -r requirements.txt' if level >= 2 else ''}
{'```' if level >= 2 else ''}

{'### Running the Analysis' if level >= 2 else ''}
{'1. Activate environment' if level >= 2 else ''}
{'2. Run notebooks in order (01, 02, 03...)' if level >= 2 else ''}
{'3. Figures will be generated in figures/' if level >= 2 else ''}

## Contact
[Add your contact information]

## Date Prepared
{datetime.now().strftime('%Y-%m-%d')}

---
Package prepared with [Claude Code](https://claude.com/claude-code)
"""

with open(f"{share_dir}/README.md", "w") as f:
    f.write(readme_content)

print("Created README.md")
```

---

## MANIFEST Template (for Level 2-3)

```python
# Generate file listing with descriptions
manifest = "# Project Manifest\n\n"
manifest += "## File Structure\n\n"

for root, dirs, files in os.walk(share_dir):
    level = root.replace(share_dir, '').count(os.sep)
    indent = ' ' * 2 * level
    manifest += f"{indent}{os.path.basename(root)}/\n"
    subindent = ' ' * 2 * (level + 1)
    for file in files:
        manifest += f"{subindent}{file}\n"

with open(f"{share_dir}/MANIFEST.md", "w") as f:
    f.write(manifest)

print("Created MANIFEST.md")
```

---

## Final Checks (Step 7)

```bash
# Show what was created
echo ""
echo "Sharing package created!"
echo ""
echo "Location: $SHARE_DIR"
echo "Size:"
du -sh "$SHARE_DIR"
echo ""
echo "Contents:"
ls -lh "$SHARE_DIR" | tail -n +2
echo ""

# Verify key files present
echo "Verification:"
[ -f "$SHARE_DIR/README.md" ] && echo "  README.md present" || echo "  README.md missing"
[ -f "$SHARE_DIR/MANIFEST.md" ] && echo "  MANIFEST.md present" || true

# Count files
FILE_COUNT=$(find "$SHARE_DIR" -type f | wc -l)
echo "  $FILE_COUNT files total"
```

---

## Legacy: Traditional Sharing Levels Directory Structures

If you prefer the traditional Level 1/2/3 approach instead of the new file-selection workflow:

**Level 1 - Summary:**
```bash
SHARE_DIR="shared-$(date +%Y%m%d)-summary"
mkdir -p "$SHARE_DIR"/{results/{figures,tables}}
```

**Level 2 - Reproducible:**
```bash
SHARE_DIR="shared-$(date +%Y%m%d)-reproducible"
mkdir -p "$SHARE_DIR"/{notebooks,scripts,data/processed,figures}
```

**Level 3 - Full Archive:**
```bash
SHARE_DIR="shared-$(date +%Y%m%d)-full"
mkdir -p "$SHARE_DIR"/{data/{raw,intermediate,processed},scripts,notebooks/{exploratory,final},results/{figures,tables,supplementary},documentation}
```
