# Phylogenetics Skills

Expert knowledge for phylogenetic tree analysis, visualization, and annotation management.

## ITOL Annotation File Troubleshooting

### Common Issue: Species Name Mismatches

**Problem**: Species in tree file don't match annotation files, causing missing data in ITOL visualization.

**Root Causes**:
1. Tree processing tools (e.g., TimeTree) may abbreviate species names
2. Capitalization inconsistencies (e.g., `Alca_Torda` vs `Alca_torda`)
3. Genus-only names replacing full binomial nomenclature

**Solution Workflow**:

1. **Compare tree versions**:
   ```bash
   # Find species that exist in original but are different in processed tree
   grep -o "[A-Z][a-z]*_[a-z]*" Tree.nwk | sort -u > original_names.txt
   grep -o "[A-Z][a-z]*_[a-z]*" Tree_final.nwk | sort -u > processed_names.txt
   comm -3 original_names.txt processed_names.txt
   ```

2. **Identify incomplete names**:
   ```python
   # Species with genus only (no underscore after first word)
   with open('Tree_final.nwk', 'r') as f:
       tree = f.read()
   # Look for patterns like "Myxine:" instead of "Myxine_glutinosa:"
   ```

3. **Fix systematically**:
   - Update tree file with complete names
   - Update CSV data source
   - Update all ITOL annotation files (colorstrip, labels, branch colors)
   - Verify counts match across all files

4. **Verification checklist**:
   - [ ] All files have same species count
   - [ ] No "Other" or unknown categories remain
   - [ ] Legend counts match actual data counts
   - [ ] Test species display correctly

### ITOL File Synchronization

**Critical**: When adding/removing species, update ALL annotation files:
- Tree file (`.nwk`)
- Data source (`.csv`)
- `itol_*_colorstrip_final.txt`
- `itol_*_labels_final.txt`
- `itol_branch_colors_final.txt`

**Verification script**:
```python
def verify_itol_sync():
    files = [
        'Tree_final.nwk',
        'itol_taxonomic_colorstrip_final.txt',
        'itol_taxonomic_labels_final.txt',
        'itol_branch_colors_final.txt'
    ]

    counts = {}
    for f in files:
        # Extract species list from each file
        species = extract_species(f)
        counts[f] = len(species)

    if len(set(counts.values())) == 1:
        print(f"✓ All files synchronized: {counts[files[0]]} species")
    else:
        print("✗ Files out of sync:")
        for f, count in counts.items():
            print(f"  {f}: {count}")
```

## Fish Taxonomy Simplification for Visualization

### User Preference vs Scientific Detail

**Scientific accuracy** often requires detailed fish categories:
- Jawless fishes (Agnatha) - hagfish, lampreys
- Cartilaginous fishes (Chondrichthyes) - sharks, rays
- Lobe-finned fishes (Sarcopterygii) - coelacanths, lungfishes
- Ray-finned fishes (Actinopterygii) - most bony fishes

**For visualization clarity**, users may prefer simplified categories:
- Cartilaginous fishes (includes jawless)
- Bony fishes (includes lobe-finned)

**Implementation approach**:
1. Start with scientifically accurate categories
2. Present to user for feedback
3. Be ready to simplify based on user preference
4. Document the choice made

**Key insight**: Users may prioritize:
- Visual simplicity over taxonomic precision
- Fewer categories for cleaner figures
- Practical grouping for their specific use case

**Always confirm categorization preferences** when creating phylogenetic visualizations, especially for:
- Fish classifications
- Bacterial/archaeal groups
- Plant lineages
- Any domain with complex subdivisions

## Bulk Editing ITOL Annotation Files

### Safe Update Pattern

When updating ITOL annotation files, use this pattern to avoid data corruption:

```python
def update_itol_file(input_file, species_updates):
    """
    Safely update ITOL annotation file.

    Args:
        input_file: Path to ITOL file
        species_updates: Dict mapping species -> (category, color)
    """
    with open(input_file, 'r') as f:
        lines = f.readlines()

    # Find critical line indices
    data_start = None
    legend_labels_idx = None
    legend_colors_idx = None

    for i, line in enumerate(lines):
        if line.strip() == 'DATA':
            data_start = i
        if line.startswith('LEGEND_LABELS'):
            legend_labels_idx = i
        if line.startswith('LEGEND_COLORS'):
            legend_colors_idx = i

    # Update data section
    for i in range(data_start + 1, len(lines)):
        if not lines[i].strip():
            continue
        parts = lines[i].strip().split('\t')
        if len(parts) >= 3:
            species = parts[0]
            if species in species_updates:
                new_cat, new_color = species_updates[species]
                lines[i] = f"{species}\t{new_color}\t{new_cat}\n"

    # Recalculate category counts
    category_counts = {}
    for i in range(data_start + 1, len(lines)):
        if not lines[i].strip():
            continue
        parts = lines[i].strip().split('\t')
        if len(parts) >= 3:
            category = parts[2]
            category_counts[category] = category_counts.get(category, 0) + 1

    # Update legend with accurate counts
    # [Build new legend line with actual counts]

    # Write atomically
    with open(input_file, 'w') as f:
        f.writelines(lines)

    return category_counts
```

**Key principles**:
1. Always recalculate counts after changes
2. Update legend to match actual data
3. Handle all three file types (colorstrip, labels, branch colors)
4. Verify changes with separate verification script

## Related Skills

- **Analysis/Visualization**: Color selection strategies for phylogenetic trees
- **VGP Pipeline**: Species list management and quality control
