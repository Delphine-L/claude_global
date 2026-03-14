# iTOL (Interactive Tree of Life) Dataset Creation

Reference for creating annotation datasets for phylogenetic tree visualization in iTOL.

## Overview
iTOL is a web-based tool for phylogenetic tree visualization. Creating annotation datasets requires specific formats and understanding format differences between legacy and modern approaches.

## Key Format Types

### 1. DATASET_STYLE (Modern Format for Branch/Node Coloring)
Use for coloring individual terminal branches or nodes.

**Critical requirements**:
- Use `SEPARATOR COMMA` (not TAB)
- Format: `species,branch,node,#color,width,style`
- The three fields (branch/node/style) are all required even though only one is used

```
DATASET_STYLE
SEPARATOR COMMA

DATASET_LABEL,Terminal Branch Colors by Taxonomy
COLOR,#ff0000

DATA
Homo_sapiens,branch,node,#C084C0,2,normal
Mus_musculus,branch,node,#C084C0,2,normal
```

**Common errors avoided**:
- Using TAB separator causes "Invalid color definition" errors
- Using `clade` instead of individual species causes all branches to get same color
- Omitting required fields causes format errors

### 2. DATASET_BINARY (Presence/Absence Markers)
Use for adding symbols (checkmarks, stars, etc.) to specific species.

```
DATASET_BINARY
SEPARATOR TAB

DATASET_LABEL	Dual Curation

FIELD_SHAPES	6
FIELD_LABELS	Dual Curation
FIELD_COLORS	#FF0000

LEGEND_TITLE	Curation Status
LEGEND_SHAPES	6
LEGEND_COLORS	#FF0000
LEGEND_LABELS	Dual Curation

DATA
Homo_sapiens	1
Mus_musculus	1
```

**Symbol codes**:
- 1 = circle, 2 = square, 3 = diamond, 4 = triangle, 5 = filled square, 6 = checkmark

### 3. DATASET_COLORSTRIP (Colored Rectangles)
```
DATASET_COLORSTRIP
SEPARATOR TAB

DATASET_LABEL	Taxonomic Lineage

DATA
Homo_sapiens	#C084C0	Mammals
Mus_musculus	#C084C0	Mammals
```

## Species Name Synchronization

**Problem**: Tree species names often differ from metadata due to:
1. TimeTree database replacements (standardization)
2. Spelling variants (e.g., `Chiropotes_utahickae` vs `Chiropotes_utahicki`)
3. Case differences (e.g., `Alca_torda` vs `Alca_Torda`)
4. Trailing spaces in CSV files

**Solution workflow**:
1. Export tree species list: `grep -oE "[A-Z][a-z]+_[a-z]+" Tree.nwk | sort -u`
2. Compare with metadata species list
3. Create replacement mapping JSON
4. Apply systematically to tree AND all annotation files
5. Document replacements for reproducibility

**Best practice**: Create separate versions:
- `*_corrected.*` - After TimeTree replacements
- `*_final.*` - After all name variant corrections

## Handling Reference Species Added by Tree Builders

TimeTree and similar tools may add reference species not in your original dataset for:
- Phylogenetic completeness
- Temporal calibration
- Topological constraints

**Document these additions**:
1. Identify species in tree but not in metadata
2. Research their phylogenetic role
3. Create separate iTOL dataset to highlight them
4. Document why they were added

Example:
```python
# Create dataset for reference species
timetree_additions = ["Species_one", "Species_two"]
# Use different symbol/color to distinguish from your species
```

## Color Schemes for Taxonomy

Standard color palette for major vertebrate groups:
```python
colors = {
    'Mammals': '#C084C0',       # Purple
    'Birds': '#FFD700',         # Gold
    'Reptiles': '#9370DB',      # Medium Purple
    'Amphibians': '#98D8C8',    # Turquoise
    'Fishes': '#87CEEB',        # Sky Blue
    'Invertebrates': '#8B4513'  # Brown
}
```

## Troubleshooting iTOL Errors

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Invalid color definition 'normal'" | Wrong field order in TREE_COLORS | Switch to DATASET_STYLE format |
| "Invalid color definition 'node'" | Using TAB separator with DATASET_STYLE | Change to `SEPARATOR COMMA` |
| "All branches same color" | Using clade-based coloring with overlapping definitions | Color individual terminal branches instead |
| Species missing from dataset | Name mismatch between tree and metadata | Create name mapping and apply to all files |
| "Other" lineage shown | New names from replacements lack lineage info | Map new names to lineages from original names |

## File Organization Best Practice

```
phylo/
├── Tree.nwk                              # Original
├── Tree_corrected.nwk                    # After TimeTree replacements
├── Tree_final.nwk                        # After all name corrections
├── itol_branch_colors_final.txt          # Terminal branch colors
├── itol_taxonomic_colorstrip_final.txt   # Colored strips
├── itol_dual_curation_binary_final.txt   # Binary markers
├── itol_timetree_additions_final.txt     # Reference species markers
├── species_replacements.json             # TimeTree replacements
├── name_variant_replacements.json        # Spelling/case fixes
└── SPECIES_CORRECTIONS_SUMMARY.md        # Full documentation
```

## Updating iTOL Config Color Schemes

When updating color schemes across multiple iTOL configuration files, colors appear in multiple locations with different syntax:

**Files requiring updates (for 3-category example):**

1. **Colorstrip configs** (`itol_3category_colorstrip_UPDATED.txt`):
   - `LEGEND_COLORS` line: tab-separated hex values
   - Individual species rows: `species_name<tab>category<tab>#HEXCODE`

2. **Label configs** (`itol_3category_labels_UPDATED.txt`):
   - `LEGEND_COLORS,` line: comma-separated hex values
   - DATA rows: `species,label,label,#HEXCODE,1,normal`

3. **Branch color configs** (`itol_3category_branch_colors_UPDATED.txt`):
   - DATA rows: `species<tab>branch<tab>#HEXCODE<tab>normal<tab>2`

4. **Binary highlight configs** (one per category):
   - `COLOR` line: single hex value
   - `LEGEND_COLORS` line: single hex value
   - `FIELD_COLORS` line: single hex value

**Efficient Update Strategy:**

Use Edit tool with `replace_all=true` for each old to new color mapping:
```python
# Update all instances of old color across file
Edit(
    file_path="itol_3category_colorstrip_UPDATED.txt",
    old_string="#3498db",
    new_string="#FF8C00",
    replace_all=True
)
```

**Typical color update sequence:**
1. Map old to new colors (e.g., blue to orange, orange to green, green to blue)
2. Update all files with first mapping (old blue to new orange)
3. Update all files with second mapping (old orange to new green)
4. Update all files with third mapping (old green to new blue)

**Files to update (for 3-category system):**
- `itol_3category_colorstrip_UPDATED.txt`
- `itol_3category_labels_UPDATED.txt`
- `itol_3category_branch_colors_UPDATED.txt`
- `itol_3category_phased_dual_binary_UPDATED.txt`
- `itol_3category_phased_single_binary_UPDATED.txt`
- `itol_3category_pri_alt_single_binary_UPDATED.txt`

**Verification:**
- Grep for old hex codes to confirm all replaced
- Check LEGEND_COLORS lines match DATA row colors
- Verify binary files use correct category color

**Common Color Scheme Examples:**

VGP Curation 3-Category System:
```python
COLORS = {
    'Phased+Dual': '#FF8C00',      # Dark orange
    'Phased+Single': '#50C878',    # Emerald green
    'Pri/alt+Single': '#4169E1'    # Royal blue
}
```

## References

- iTOL documentation: https://itol.embl.de/help.cgi
