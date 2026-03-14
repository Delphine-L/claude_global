---
name: bioinformatics-visualization
description: Publication-quality bioinformatics figures - phylogenetic trees, genome browsers, iTOL datasets, and data presentation
allowed-tools: Read, Grep, Glob, Bash
---

# Bioinformatics Visualization

---

## iTOL Dataset Formats and Troubleshooting

### Choosing the Right Dataset Type

**DATASET_BINARY** (Recommended for markers/symbols):
- More reliable than DATASET_SYMBOL
- All species must be listed with binary values (0 or 1)
- Simpler format, better iTOL compatibility
- Use for: presence/absence markers, technology indicators, categorical highlights

**Format example**:
```
DATASET_BINARY
SEPARATOR TAB

DATASET_LABEL	CLR Technology
COLOR	#ff0000

LEGEND_TITLE	Sequencing Technology
LEGEND_SHAPES	2
LEGEND_COLORS	#ff0000
LEGEND_LABELS	CLR (PacBio)

FIELD_SHAPES	2
FIELD_COLORS	#ff0000
FIELD_LABELS	CLR

DATA
Species_name_1	1
Species_name_2	0
Species_name_3	1
```

**DATASET_SYMBOL** (Less reliable):
- Can be finicky about format
- Per-species shape/size/color specifications complex
- May not display correctly even with valid format
- **Avoid unless BINARY doesn't meet needs**

**DATASET_COLORSTRIP** (Good for gradients):
- Reliable for color gradients (e.g., temporal data, continuous values)
- Only species with data need to be listed
- Good for non-binary categorical or continuous data

### Common iTOL Errors and Fixes

**Error: "Unknown variable 'SYMBOL_SHAPE'"**
- **Cause**: Mixing global symbol settings with per-species data
- **Fix**: Switch to DATASET_BINARY format

**Error: "Invalid color '1' for node X"**
- **Cause**: DATASET_SYMBOL data format mismatch
- **Fix**: Use DATASET_BINARY instead, format: `species<tab>0_or_1`

**Symbols not appearing on tree**:
- **Likely cause**: DATASET_SYMBOL format issues
- **Fix**: Convert to DATASET_BINARY
- **Verify**: Check that all species in config exist in tree file

### Species Name Compatibility

**Critical**: Species names must match exactly between tree and annotation files

**Common issues**:
1. **Case sensitivity**: "Alca Torda" vs "Alca_torda"
2. **Spaces vs underscores**: Always use underscores in tree format
3. **Subspecies names**: Handle three-part names carefully

**Fix for case sensitivity**:
```python
# Convert scientific names to tree format with case normalization
df['species_tree'] = df['scientific_name'].str.replace(' ', '_')
# Fix uppercase after underscore (Alca_Torda -> Alca_torda)
df['species_tree'] = df['species_tree'].str.replace(
    r'_([A-Z])',
    lambda m: '_' + m.group(1).lower(),
    regex=True
)
```

**Validation pattern**:
```python
# Always validate species compatibility
import re

# Extract species from tree
with open('tree.nwk') as f:
    tree_content = f.read()
tree_species = set(re.findall(r'([A-Z][a-z]+_[a-z]+)', tree_content))

# Check config species
config_species = set(df['species_tree'])
missing = config_species - tree_species

if missing:
    print(f"Species in config but not in tree: {missing}")
```

### Color Gradients for Temporal Data

**Effective color schemes**:

**Temporal progression** (old → new):
- Light Yellow → Dark Red (ColorBrewer YlOrRd)
- Clearly shows progression from past to present
- Example: `#ffffcc` (2019) → `#b10026` (2025)

**Avoid**:
- Blue → Yellow → Red (confusing middle point)
- Diverging palettes for sequential data

**ColorBrewer palettes for sequential data**:
- YlOrRd: Yellow-Orange-Red (temporal, intensity)
- YlGn: Yellow-Green (growth, vegetation)
- PuBuGn: Purple-Blue-Green (water, depth)

### Debugging Workflow

1. **Generate config file**
2. **Upload to iTOL** (https://itol.embl.de)
3. **If errors**: Save error messages to file
4. **Check format**: BINARY vs SYMBOL vs COLORSTRIP
5. **Validate species names**: Match against tree file
6. **Test with minimal dataset**: 5-10 species first
7. **Switch formats if needed**: SYMBOL → BINARY usually works

---

## Related Skills

- **data-visualization**: General visualization best practices
- **bioinformatics/fundamentals**: Core bioinformatics concepts
- **bioinformatics/phylogenetics**: Phylogenetic analysis workflows
