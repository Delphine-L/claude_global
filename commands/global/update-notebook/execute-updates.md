# Execute Updates

Supporting file for the `update-notebook` command. Contains Steps 7-9: interactive update menu, executing updates, and post-update validation.

## Step 7: Interactive Update Menu

Present options to user:

```markdown
## Update Options

Based on the analysis, here are recommended updates:

1. **Fix figure numbering** {if non-sequential}
   - Renumber figures to be sequential
   - Update all references

2. **Update Table of Contents** {if needs update}
   - {X} sections added since last update
   - {Y} sections renamed

3. **Fix figure adjacency** {if non-adjacent issues}
   - Move figure descriptions next to images

4. **Add missing figure descriptions** {if missing}
   - {count} figures need descriptions

5. **Update data references** {if inconsistencies}
   - Fix inconsistent sample sizes
   - Update file paths

6. **Verify all and update** (recommended)
   - Performs all necessary updates

Select option (1-6) or 'skip' to cancel:
```

## Step 8: Execute Updates

For each selected update:

### 8.1 Fix Figure Numbering

```python
# Create mapping from old to new numbers
renumbering_map = {}
for i, old_num in enumerate(sorted(actual_sequence), start=1):
    if old_num != i:
        renumbering_map[old_num] = i

if renumbering_map:
    print(f"Renumbering {len(renumbering_map)} figures...")

    # Update all cells
    for cell in nb['cells']:
        if cell['cell_type'] in ['markdown', 'code']:
            source = ''.join(cell['source'])

            # Replace in reverse order to avoid double-replacement
            for old_num in sorted(renumbering_map.keys(), reverse=True):
                new_num = renumbering_map[old_num]

                # Update markdown figures
                source = re.sub(
                    rf'\*\*Figure {old_num}\.',
                    f'**Figure {new_num}.',
                    source
                )
                source = re.sub(
                    rf'Figure {old_num}:',
                    f'Figure {new_num}:',
                    source
                )

                # Update image filenames if they contain figure numbers
                source = re.sub(
                    rf'{old_num:02d}_',
                    f'{new_num:02d}_',
                    source
                )

            cell['source'] = [source]
```

### 8.2 Update Table of Contents

```python
if needs_toc_update:
    if toc_cell_idx is not None:
        # Update existing TOC
        nb['cells'][toc_cell_idx]['source'] = [new_toc]
        print(f"Updated Table of Contents at cell {toc_cell_idx}")
    else:
        # Insert new TOC after title
        toc_cell = {
            'cell_type': 'markdown',
            'metadata': {},
            'source': [new_toc]
        }
        nb['cells'].insert(1, toc_cell)  # After title cell
        print("Added new Table of Contents")
```

### 8.3 Fix Figure Adjacency

```python
# Move descriptions to be adjacent to images
for fig_num, issue in non_adjacent_issues.items():
    desc_cell = issue['description_cell']
    img_cell = issue['image_cell']

    # Move description cell to be right before or after image
    if desc_cell < img_cell:
        target_pos = img_cell - 1
    else:
        target_pos = img_cell + 1

    # Extract and move cell
    cell = nb['cells'].pop(desc_cell)
    nb['cells'].insert(target_pos, cell)
    print(f"Moved Figure {fig_num} description to be adjacent to image")
```

## Step 9: Validation After Updates

Run validation checks again to ensure all issues resolved:

```python
# Re-run all validation checks
print("\nRe-validating notebook...")

# Quick validation
new_issues = validate_notebook(nb)

if not new_issues:
    print("All issues resolved!")
else:
    print(f"{len(new_issues)} issues remaining:")
    for issue in new_issues:
        print(f"  - {issue}")
```
