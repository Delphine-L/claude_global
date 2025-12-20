# Beautify Export Workflow Layout

You are helping to reorganize a Galaxy export workflow to make it more visually clear and user-friendly.

## Standard Layout Structure

Export workflows follow a **5-column base layout**:

### Fixed Columns (Always the same)

**Column 1 (X=0):** Input Parameters
- Species Name
- Assembly ID
- Date
- Root Directory for Export
- Any other workflow parameters
- Vertically stacked starting at Y=670, spaced 100px apart

**Column 2 (X=751):** Path Creation Subworkflow
- Single step: "Curated Paths Creation" or similar
- Positioned at Y=186
- This subworkflow generates all directory paths

**Column 5 (X=2400):** Export Steps
- One export step per haplotype/category
- First export at Y=870
- Additional exports spaced 300px apart vertically

### Variable Middle Columns (Columns 3-4, or more)

These columns contain the processing logic and vary based on:
- Number of haplotypes (hap1, hap2, etc.)
- Types of analyses (different data types)
- Workflow complexity

**Standard spacing:**
- Column 3 starts at X=1573
- Each additional column is +440px to the right
- Within each column: paired pattern of (naming step → dataset input)
- Vertical spacing: ~400px between different data type groups

## Intelligent Label Grouping

**IMPORTANT:** The command should analyze step labels to find similar themes and group them together vertically.

### Label Analysis Strategy

1. **Extract base names and variants:**
   - "Gaps Bigwig Hap1 (frac)" → base: "gaps frac", variant: "hap1"
   - "Gaps Bigwig Hap2 (frac)" → base: "gaps frac", variant: "hap2"
   - "Hap1 Coverage Name" → base: "coverage name", variant: "hap1"
   - "Hap2 Coverage Name" → base: "coverage name", variant: "hap2"

2. **Common patterns to detect:**
   - Haplotype indicators: "hap1", "hap2", "hap3", etc.
   - Data types: "gaps", "coverage", "telomeres", "pretext", "HiC", "HiFi", "alignment"
   - Processing stages: "name", "path", "input", "output"
   - Qualifiers: "frac", "count", "s1", "s2", "primary", "alternate"

3. **Grouping logic:**
   ```python
   # Example pseudo-code for grouping
   def extract_theme(label):
       """Extract the theme/data type from a label"""
       label_lower = label.lower()

       # Remove haplotype indicators
       for hap in ['hap1', 'hap2', 'hap3']:
           label_lower = label_lower.replace(hap, '')

       # Extract keywords
       themes = []
       if 'gaps' in label_lower and 'frac' in label_lower:
           themes.append('gaps_frac')
       elif 'gaps' in label_lower and 'count' in label_lower:
           themes.append('gaps_count')
       elif 'coverage' in label_lower:
           themes.append('coverage')
       elif 'telomere' in label_lower:
           themes.append('telomeres')
       elif 'pretext' in label_lower:
           themes.append('pretext')
       elif 'hic' in label_lower:
           themes.append('hic')
       elif 'hifi' in label_lower:
           themes.append('hifi')

       # Determine if it's a naming step or data input
       if 'name' in label_lower and 'compose' in step_type:
           stage = 'naming'
       elif step_type == 'data_input':
           stage = 'input'

       return {'theme': themes[0] if themes else 'other', 'stage': stage}
   ```

4. **Vertical alignment across columns:**
   - Steps with the same theme should be at the same Y position across different columns
   - Example:
     ```
     Y=0:    Hap1 Gaps Frac Name    |  Hap2 Gaps Frac Name
     Y=340:  Gaps Bigwig Hap1 (frac)|  Gaps Bigwig Hap2 (frac)
     Y=430:  Hap1 Gaps Count Name   |  Hap2 Gaps Count Name
     Y=740:  Gaps Bigwig Hap1 (count)| Gaps Bigwig Hap2 (count)
     ```

## Your Task

1. **Ask the user for the workflow file path**
   - Example: "Please provide the path to the workflow .ga file"
   - If not provided, ask explicitly

2. **Analyze the workflow structure**
   - Read the workflow JSON file
   - Identify:
     - Input parameters (type: parameter_input)
     - Dataset inputs (type: data_input)
     - Subworkflow steps (type: subworkflow)
     - File naming steps (tool: compose_text_param)
     - Export steps (tool_id: export_remote)
   - **Analyze labels to detect themes:**
     - Group steps by base theme (gaps_frac, gaps_count, coverage, etc.)
     - Identify variants (hap1, hap2, etc.)
     - Match naming steps with their corresponding data inputs

3. **Present the structure to the user**

   Show a detailed analysis:
   ```
   Found 35 steps:
   - 4 input parameters
   - 14 dataset inputs (7 for hap1, 7 for hap2)
   - 1 subworkflow (Curated Paths Creation)
   - 14 file naming steps
   - 2 export steps

   Detected variants: hap1, hap2

   Detected data type themes (with counts):
   - gaps_frac: 2 naming steps, 2 inputs (hap1, hap2)
   - gaps_count: 2 naming steps, 2 inputs (hap1, hap2)
   - coverage: 2 naming steps, 2 inputs (hap1, hap2)
   - telomeres: 2 naming steps, 2 inputs (hap1, hap2)
   - pretext: 2 naming steps, 2 inputs (hap1, hap2)
   - hic: 2 naming steps, 2 inputs (hap1, hap2)
   - hifi: 2 naming steps, 2 inputs (hap1, hap2)

   Current organization: [describe current layout]
   ```

4. **Ask clarifying questions**

   Ask the user:

   a) **"How should the middle columns be organized?"**
      - Option 1: "By haplotype (one column per haplotype)" - DEFAULT for curated exports
      - Option 2: "By data type (one column per analysis type)"
      - Option 3: "Custom grouping (you'll specify)"

   b) **"Should similar themes be vertically aligned across columns?"**
      - Option 1: "Yes, align same data types at same Y position" - DEFAULT
      - Option 2: "No, pack each column independently"

   c) **"What grouping/pairing pattern should be used within each column?"**
      - Option 1: "Paired: naming step → dataset input" - DEFAULT, best for user clarity
      - Option 2: "Grouped: all naming steps, then all inputs"
      - Option 3: "Custom vertical arrangement"

   d) **"How should data types be ordered vertically?"**
      - Option 1: "By data category (tracks, pretext, alignments)" - DEFAULT
        - Tracks: gaps_frac, gaps_count, coverage, telomeres
        - Pretext: pretext maps
        - Alignments: HiC, HiFi
      - Option 2: "Alphabetically by theme name"
      - Option 3: "As currently arranged"
      - Option 4: "Custom order (you'll specify)"

5. **Calculate new positions with theme-based grouping**

   **Column 1 (Parameters):**
   ```python
   x = 0
   y_start = 670
   y_spacing = 100
   for i, param in enumerate(parameters):
       position = {"left": 0, "top": y_start + (i * y_spacing)}
   ```

   **Column 2 (Subworkflow):**
   ```python
   position = {"left": 751, "top": 186}
   ```

   **Middle Columns (Variable) - Theme-based:**
   ```python
   # Define theme order
   theme_order = ['gaps_frac', 'gaps_count', 'coverage', 'telomeres',
                  'pretext', 'hic', 'hifi']

   # Calculate Y positions for each theme (shared across columns)
   theme_y_positions = {}
   y = 0
   for theme in theme_order:
       theme_y_positions[theme + '_naming'] = y
       y += 340  # Space between naming and input
       theme_y_positions[theme + '_input'] = y
       y += 430  # Space to next theme (larger gap between groups)

   # Apply to each column
   column_x_start = 1573
   column_spacing = 440

   for col_index, variant in enumerate(variants):  # e.g., 'hap1', 'hap2'
       x = column_x_start + (col_index * column_spacing)

       for theme in theme_order:
           # Find steps for this theme and variant
           naming_step = find_step(theme, variant, 'naming')
           input_step = find_step(theme, variant, 'input')

           if naming_step:
               positions[naming_step.id] = {
                   "left": x,
                   "top": theme_y_positions[theme + '_naming']
               }

           if input_step:
               positions[input_step.id] = {
                   "left": x,
                   "top": theme_y_positions[theme + '_input']
               }
   ```

   **Column 5 (Export):**
   ```python
   x = 2400
   y_start = 870
   y_spacing = 300

   for i, export in enumerate(exports):
       position = {"left": x, "top": y_start + (i * y_spacing)}
   ```

6. **Apply the reorganization**

   - Create a new workflow dictionary with updated positions
   - Preserve all other workflow data (connections, tool_state, UUIDs, etc.)
   - Only modify the "position" field for each step
   - **Ensure theme-based vertical alignment is maintained**

7. **Save the beautified workflow**

   - Ask user: "Save as new file or overwrite?"
   - Default filename: `{original_name}_beautified.ga`
   - Create backup: `{original_name}_backup.ga`
   - Save the JSON with proper formatting (indent=4)

8. **Create a summary visualization**

   Show the user a text representation showing theme alignment:
   ```
   Column 1 (X=0):     Column 2 (X=751):    Column 3 (X=1573):          Column 4 (X=2014):          Column 5 (X=2400):
   Parameters          Paths Subworkflow    Hap1 Processing             Hap2 Processing             Export
   ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   Y=670:
   - Species Name
   Y=770:
   - Assembly ID
   Y=870:
   - Date
   Y=970:
   - Root Dir

   Y=186:
                       - Curated Paths
                         Creation

   Y=0:                                     - Hap1 Gaps Frac Name       - Hap2 Gaps Frac Name
   Y=340:                                   - Gaps Bigwig Hap1 (frac)   - Gaps Bigwig Hap2 (frac)
   Y=428:                                   - Hap1 Gaps Count Name      - Hap2 Gaps Count Name
   Y=740:                                   - Gaps Bigwig Hap1 (count)  - Gaps Bigwig Hap2 (count)
   Y=840:                                   - Hap1 Coverage Name        - Hap2 Coverage Name
   Y=1149:                                  - Genome Coverage Hap1      - Genome Coverage Hap2
   Y=870:                                                                                           - Export Hap1
   Y=1170:                                                                                          - Export Hap2
   ...
   ```

## Implementation Notes

- **Read the entire workflow file** first before making changes
- **Use fuzzy matching** for theme detection (case-insensitive, handle variations)
- **Validate JSON** before and after modifications
- **Preserve all workflow metadata**: connections, tool_state, UUIDs, etc.
- **Only modify positions** - do not change workflow logic
- **Create automatic backup** of original file
- **Be explicit** with user about what changes will be made
- **Handle edge cases:**
  - Steps that don't match any theme
  - Workflows with more than 2 variants
  - Missing or incomplete pairings

## Example Label Matching Patterns

**Common patterns to recognize:**

```python
patterns = {
    'gaps_frac': ['gaps.*frac', 'gap.*fraction'],
    'gaps_count': ['gaps.*count', 'gap.*count'],
    'coverage': ['coverage', 'genome.*coverage', 'cov(?!er)'],
    'telomeres': ['telomere', 'telo'],
    'pretext': ['pretext', 'contact.*map'],
    'hic': ['hic', 'hi-c', 'hi_c'],
    'hifi': ['hifi', 'hi-fi', 'hi_fi', 'pacbio'],
    'alignment': ['alignment', 'bam', 'mapped'],
}

variants = {
    'hap1': ['hap1', 'haplotype.*1', 'h1'],
    'hap2': ['hap2', 'haplotype.*2', 'h2'],
    'primary': ['primary', 'p', 'pri'],
    'alternate': ['alternate', 'alt', 'a'],
}
```

## Success Criteria

The beautified workflow should:
1. ✅ Have all parameters in Column 1
2. ✅ Have path subworkflow in Column 2
3. ✅ Have variants in separate middle columns
4. ✅ Have export steps in Column 5
5. ✅ **Have matching themes vertically aligned across columns**
6. ✅ Follow paired pattern (naming → input) within columns
7. ✅ Be visually clear and easy to understand
8. ✅ Preserve all workflow functionality
