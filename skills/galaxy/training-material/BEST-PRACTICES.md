# Slides, Data Library, and Best Practices

## Slides Format

Slides use `slides.html` with Remark.js:

```yaml
---
layout: tutorial_slides
logo: "GTN"
title: "Slide Deck Title"
questions:
  - "Question?"
objectives:
  - "Learning objective"
key_points:
  - "Key point"
contributions:
  authorship:
    - username
---

# First Slide Title

Content for first slide

---

# Second Slide Title

.pull-left[
Left column content
]

.pull-right[
Right column content
]

???

Presenter notes go here (after ???)
```

Key rules:
- `---` separates slides
- `.pull-left[]` / `.pull-right[]` for two-column layout
- `???` starts presenter notes
- Keep text minimal, use images
- Standard markdown formatting within slides

## Data Library Configuration

`data-library.yaml` defines datasets importable into Galaxy:

```yaml
---
destination:
  type: library
  name: GTN - Material
  description: Galaxy Training Network Material
  synopsis: Galaxy Training Network Material. See https://training.galaxyproject.org
items:
- name: "Topic Title"
  items:
  - name: "Tutorial Title"
    items:
    - name: 'DOI: 10.5281/zenodo.XXXXXXX'
      description: 'latest'
      items:
      - info: https://doi.org/10.5281/zenodo.XXXXXXX
        url: https://zenodo.org/records/XXXXXXX/files/file1.fasta
        ext: fasta
        src: url
      - url: https://zenodo.org/records/XXXXXXX/files/file2.fastqsanger.gz
        ext: fastqsanger.gz
        src: url
```

## Best Practices

### Content Structure
1. **Introduction** — Brief context, biological motivation, what the tutorial covers
2. **Agenda box** — Auto-generated TOC
3. **Sections with hands-on steps** — Alternate theory and practice
4. **Questions after hands-on boxes** — Self-assessment for learners
5. **Conclusion** — Summary, link to key points

### Writing Style
- Use **imperative sentences** in hands-on steps ("Click", "Select", "Run")
- Keep tool parameter lists complete — include ALL parameters the user needs to change from defaults
- Use snippets for common Galaxy operations (data import, rename, etc.)
- Include screenshots for complex Galaxy UI interactions
- Explain the "why" alongside the "how"

### Learning Design
- Define clear `questions` and `objectives` in front matter (use Bloom's taxonomy verbs)
- `key_points` should directly answer the `questions`
- Place `question` boxes after major steps for formative assessment
- Use `details` boxes for optional deep-dive content
- Use `tip` boxes for shortcuts and alternative approaches
- Use `comment` boxes for important context
- Use `warning` boxes sparingly for critical pitfalls

### Data and Workflows
- Keep toy datasets small (tool runs under 10-15 minutes)
- Upload datasets to Zenodo with a DOI
- Include Galaxy workflow (.ga) files in `workflows/` directory
- Add workflow tests (`-tests.yml`) when possible
- Use `data-library.yaml` for easy data import

### Common Pitfalls
- **Missing `>` prefix** — Every line inside a box must start with `> `
- **Wrong class name** — Note: `{: .hands_on}` uses underscore, not hyphen
- **Broken nesting** — Solutions need double `> >` prefix inside questions
- **Old `contributors:` field** — Use `contributions:` with sub-fields instead
- **Forgetting blank lines** — Blank `>` lines needed between elements inside boxes
- **Relative image paths** — Always use `../../images/` from tutorial.md

### Updating Tutorials for New Tool Versions

When tools are updated in a tutorial's workflow, the tutorial.md must also be updated:

1. **Tool version references**: Grep for old version strings and update:
   ```
   # Find all tool references with old version
   grep -n 'toolshed.*tool_name.*old_version' tutorial.md

   # Update to new version
   # Old: {% tool [MitoHiFi](toolshed.g2.bx.psu.edu/repos/bgruening/mitohifi/mitohifi/3+galaxy0) %}
   # New: {% tool [MitoHiFi](toolshed.g2.bx.psu.edu/repos/bgruening/mitohifi/mitohifi/3.2.3+galaxy0) %}
   ```

2. **Parameter names in hands-on boxes**: If a tool parameter was renamed (e.g., `"Assembler"` → `"Assembler type"`), update the `*"Parameter Name"*` text in hands-on steps.

3. **Expected outputs**: If tool outputs changed (e.g., NanoPlot 1.46 removed standalone PNG histogram outputs), update references to those outputs in the tutorial text and any screenshot descriptions.

4. **Screenshots**: Flag for updating when the tool UI changed. Common triggers:
   - Flat dropdown → conditional selector
   - New required parameters added
   - Output datasets changed names or types

### Common Tool Replacements in VGP Tutorials

Some tool updates are full replacements (different tool, not just a version bump). These require updating surrounding text, image captions, question blocks, and abbreviations — not just the tool tag.

**BUSCO → Compleasm** (as of IWC WF4 v0.5, WF8 v3.3):
- Tool: `{% tool [Compleasm](...compleasm/0.2.6+galaxy3) %}`
- Compleasm has simpler parameters: just genome input + lineage (no Mode, Augustus/Metaeuk, output selection)
- Update: intro text, hands-on params, image captions, question blocks, abbreviations YAML
- Citation: `{% cite Huang2023 %}`

**Monolithic Meryl → Split Meryl tools** (as of IWC WF1 v0.6):
- `meryl/1.3+galaxy6` → `meryl_count_kmers`, `meryl_groups_kmers`, `meryl_histogram_kmers` (all 1.4.1+galaxy0)
- No more "Operation type selector" dropdown — each tool does one thing
- Parameter names change accordingly

**Bellerophon → samtools merge** (as of IWC WF8 v3.3):
- Chimeric Hi-C read filtering removed from pipeline
- Replace `{% tool [Filter and merge](...bellerophon...) %}` with `{% tool [Merge BAM Files](...samtools_merge...) %}`

**Bionano scaffolding removed** (no longer in VGP standard pipeline):
- Remove entire Bionano sections, update scaffolding inputs to point directly to contigs
- Remove bionano.cmap from data-library.yaml
