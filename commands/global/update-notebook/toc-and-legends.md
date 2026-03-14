# TOC and Figure Legends

Supporting file for the `update-notebook` command. Contains Steps 5-6: table of contents update and figure legend validation.

## Step 5: Update Table of Contents

Compare current TOC with actual structure:

```python
# Extract actual section structure
sections = []
for i, cell in enumerate(markdown_cells):
    source = ''.join(cell['source'])
    lines = source.split('\n')

    for line in lines:
        # Match headers
        match = re.match(r'^(#{1,6})\s+(.+)$', line)
        if match:
            level = len(match.group(1))
            title = match.group(2).strip()

            # Skip if it's the TOC header itself
            if 'Table of Contents' in title or 'Contents' in title:
                continue

            # Create anchor
            anchor = title.lower()
            anchor = re.sub(r'[^\w\s-]', '', anchor)
            anchor = re.sub(r'[\s]+', '-', anchor)

            sections.append({
                'level': level,
                'title': title,
                'anchor': anchor,
                'cell': i
            })

# Find TOC cell
toc_cell_idx = None
for i, cell in enumerate(markdown_cells):
    source = ''.join(cell['source'])
    if 'Table of Contents' in source or (source.startswith('##') and 'Contents' in source):
        toc_cell_idx = i
        break

# Generate new TOC
def generate_toc(sections, max_level=3):
    toc_lines = ['## Table of Contents\n', '\n']

    for section in sections:
        if section['level'] <= max_level:
            indent = '  ' * (section['level'] - 1)
            link = f"[{section['title']}](#{section['anchor']})"
            toc_lines.append(f"{indent}- {link}\n")

    return ''.join(toc_lines)

new_toc = generate_toc(sections)

if toc_cell_idx is not None:
    old_toc = ''.join(markdown_cells[toc_cell_idx]['source'])

    if old_toc.strip() != new_toc.strip():
        print("Table of Contents needs updating")
        print("\n--- Current TOC ---")
        print(old_toc[:200] + "..." if len(old_toc) > 200 else old_toc)
        print("\n--- Proposed TOC ---")
        print(new_toc[:200] + "..." if len(new_toc) > 200 else new_toc)

        needs_toc_update = True
    else:
        print("Table of Contents is up to date")
        needs_toc_update = False
else:
    print("No Table of Contents found")
    print("Should I add one at the beginning? (y/n)")
    needs_toc_update = True
```

## Step 6: Validate Figure Legends and Descriptions

Check that all figures have proper descriptions:

```python
# For each figure, check description quality
legend_issues = []

for fig_num in sorted(all_fig_nums):
    if fig_num in figure_descriptions:
        desc_cells = figure_descriptions[fig_num]

        for cell_idx in desc_cells:
            source = ''.join(markdown_cells[cell_idx]['source'])

            # Extract the figure description
            match = re.search(r'\*\*Figure \d+\.([^*]+)\*\*', source)
            if match:
                desc_text = match.group(1).strip()

                # Check description quality
                if len(desc_text) < 50:
                    legend_issues.append({
                        'figure': fig_num,
                        'issue': 'too_short',
                        'length': len(desc_text),
                        'cell': cell_idx
                    })

                # Check for key components
                has_methods = any(word in desc_text.lower() for word in
                                ['violin', 'plot', 'scatter', 'histogram', 'panel', 'comparison'])
                has_data_info = any(word in desc_text.lower() for word in
                                  ['n=', 'dual', 'pri/alt', 'assemblies', 'species'])
                has_stats = any(word in desc_text.lower() for word in
                              ['mann-whitney', 'p <', 'statistical', 'test', 'chi-square'])

                if not has_methods:
                    legend_issues.append({
                        'figure': fig_num,
                        'issue': 'missing_methods',
                        'cell': cell_idx
                    })

                if not has_data_info:
                    legend_issues.append({
                        'figure': fig_num,
                        'issue': 'missing_data_info',
                        'cell': cell_idx
                    })

if legend_issues:
    print("Figure legend issues found:")
    for issue in legend_issues:
        print(f"  Figure {issue['figure']}: {issue['issue']}")
else:
    print("All figure legends are comprehensive")
```
