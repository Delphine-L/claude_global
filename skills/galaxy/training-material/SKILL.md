---
name: galaxy-training-material
description: Expert in Galaxy Training Network (GTN) tutorial development. GTN markdown syntax, special boxes, tool references, snippets, YAML front matter, and best practices for writing and updating training materials in the galaxyproject/training-material repository.
version: 1.0.0
allowed-tools: Read, Grep, Glob, Bash
---

# Galaxy Training Material Expert

Expert knowledge for writing and updating tutorials in the Galaxy Training Network (GTN) repository (github.com/galaxyproject/training-material). Covers the custom markdown syntax, file structure, and pedagogical conventions.

## When to Use This Skill

- Writing or editing GTN tutorial content (tutorial.md files)
- Creating new tutorials or topics
- Understanding GTN-specific markdown syntax (boxes, tool refs, snippets, icons)
- Reviewing or fixing tutorial formatting issues
- Adding slides, workflows, or data libraries to tutorials
- Updating YAML front matter metadata

## Supporting Files

For additional details, see the following files in this directory:

- **[WORKFLOW-VERIFICATION.md](WORKFLOW-VERIFICATION.md)** — Cross-checking tool versions between tutorials and workflows, updating IWC-based tutorials, GTA track update process, MCP fallbacks, adapting test files.
- **[BEST-PRACTICES.md](BEST-PRACTICES.md)** — Slides format, data library configuration, content structure and writing style best practices, learning design, common pitfalls, updating tutorials for new tool versions.

## Repository Structure

### Topic Layout

```
topics/{topic_name}/
├── metadata.yaml           # Topic config (name, type, editorial_board, subtopics)
├── images/                 # Shared images for all tutorials in this topic
├── faqs/                   # Topic-level FAQs
└── tutorials/
    └── {tutorial_name}/
        ├── tutorial.md         # Main tutorial content (required)
        ├── tutorial.bib        # BibTeX citations (optional)
        ├── slides.html         # Presentation slides (optional)
        ├── data-library.yaml   # Zenodo dataset definitions
        ├── workflows/
        │   ├── index.md        # layout: workflow-list
        │   ├── *.ga            # Galaxy workflow files (JSON)
        │   └── *-tests.yml     # Workflow test definitions
        └── faqs/               # Tutorial-specific FAQs
            └── index.md
```

### Topic metadata.yaml

```yaml
---
name: "assembly"
type: "use"                    # "use" or "admin"
topic_type: technology         # technology, science, instructors, basics
title: "Assembly"
summary: "Description of the topic"
docker_image: "quay.io/galaxy/assembly-training"
edam_ontology: ["topic_0196"]
requirements:
  - type: "internal"
    topic_name: introduction
  - type: "internal"
    topic_name: sequence-analysis
    tutorials:
      - quality-control
editorial_board:
  - github-username
subtopics:
  - id: subtopic_id
    title: "Subtopic Title"
    description: "Description"
```

## Tutorial YAML Front Matter

Every tutorial.md starts with YAML front matter between `---` delimiters:

```yaml
---
layout: tutorial_hands_on
title: "Tutorial Title"
zenodo_link: "https://zenodo.org/records/XXXXXXX"
questions:
  - "What biological question does this address?"
  - "How do we use tool X for task Y?"
objectives:
  - "Perform task X using Galaxy"
  - "Interpret output of tool Y"
time_estimation: "1H30M"
level: Introductory              # Introductory, Intermediate, Advanced
key_points:
  - "Take-home message 1"
  - "Take-home message 2"
contributions:
  authorship:
    - github-username
  editing:
    - github-username
  funding:
    - organization-id
  testing:
    - github-username
tags:
  - tag1
  - tag2
subtopic: subtopic_id           # Must match a subtopic id in topic metadata.yaml
edam_ontology:
  - topic_XXXX
requirements:
  - type: "internal"
    topic_name: introduction
    tutorials:
      - galaxy-intro-short
recordings:
  - youtube_id: VIDEO_ID
    length: 29M
    galaxy_version: "24.1"
    date: '2024-09-20'
follow_up_training:
  - type: "internal"
    topic_name: assembly
    tutorials:
      - assembly-decontamination
---
```

**Important notes:**
- Use `contributions:` with sub-fields (`authorship`, `editing`, `funding`, `testing`), NOT the older `contributors:` field
- `time_estimation` format: "30M", "1H", "1H30M", "2H"
- All usernames must exist in the root `CONTRIBUTORS.yaml`
- `level` determines visual badge (Introductory/Intermediate/Advanced)

## Special Markdown Syntax

### Box Types

All pedagogical boxes follow this pattern:

```markdown
> <type-title>Title Text</type-title>
>
> Content here
>
{: .class_name}
```

**Every line inside the box must start with `> `** (blockquote prefix).

#### Agenda (Table of Contents)

```markdown
> <agenda-title></agenda-title>
>
> In this tutorial, we will cover:
>
> 1. TOC
> {:toc}
>
{: .agenda}
```

Always placed after the introduction, before the first section. The `1. TOC` / `{:toc}` generates automatic table of contents from headings.

#### Hands-on (Step-by-Step Instructions)

```markdown
> <hands-on-title>Descriptive Step Title</hands-on-title>
>
> 1. {% tool [Tool Display Name](toolshed.g2.bx.psu.edu/repos/owner/repo/tool_id/version) %} with the following parameters:
>    - {% icon param-file %} *"Input file"*: `dataset_name`
>    - {% icon param-select %} *"Parameter name"*: `Option value`
>    - {% icon param-text %} *"Text parameter"*: `some text`
>    - {% icon param-check %} *"Checkbox param"*: `Yes`
>
> 2. Examine the output file by clicking {% icon galaxy-eye %} (eye icon)
>
{: .hands_on}
```

**Formatting rules for hands-on boxes:**
- Number each major step
- Tool name links use `{% tool [Name](id) %}` syntax
- Parameters are bulleted under the tool step, indented by 4 spaces from the `>`
- Parameter names are in *"quotes with italics"*
- Parameter values are in `` `backticks` ``
- Use the appropriate icon for each parameter type

#### Question + Solution

```markdown
> <question-title>Descriptive Question Title</question-title>
>
> 1. What is the N50 of the assembly?
> 2. How many contigs are there?
>
> > <solution-title></solution-title>
> >
> > 1. The N50 is 15 Mb
> > 2. There are 42 contigs
> >
> {: .solution}
>
{: .question}
```

Solutions are **nested** inside questions (double `> >` prefix). Solutions are collapsed by default.

#### Comment

```markdown
> <comment-title>Optional Title</comment-title>
>
> Additional context or explanation that's helpful but not critical.
>
{: .comment}
```

#### Tip

```markdown
> <tip-title>Helpful Tip Title</tip-title>
>
> A practical hint to help the learner.
>
{: .tip}
```

#### Warning

```markdown
> <warning-title>Important Warning</warning-title>
>
> Something that could cause problems if ignored.
>
{: .warning}
```

#### Details (Collapsible)

```markdown
> <details-title>Click to Expand</details-title>
>
> Extended information hidden by default. Good for background
> information that not all learners need.
>
{: .details}
```

#### Code Input/Output

```markdown
> <code-in-title>Bash</code-in-title>
> ```bash
> echo "Hello Galaxy"
> ```
{: .code-in}

> <code-out-title>Output</code-out-title>
> ```
> Hello Galaxy
> ```
{: .code-out}
```

For side-by-side display, wrap both in:
```markdown
> > <code-in-title>Bash</code-in-title>
> > ```bash
> > command
> > ```
> {: .code-in}
>
> > <code-out-title>Output</code-out-title>
> > ```
> > output
> > ```
> {: .code-out}
{: .code-2col}
```

### Tool References

```markdown
{% tool [Human-Readable Name](toolshed.g2.bx.psu.edu/repos/owner/repo/tool_id/version) %}
{% tool [Cut](Cut1) %}
{% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %}
```

- The text in `[]` is the display name
- The text in `()` is the full tool ID (ToolShed URL or short built-in ID)
- Version is included in the tool ID after the last `/`

#### Common VGP Assembly Tool IDs (current versions)

**Core pipeline tools (WF1–WF8):**

| Tool | Tool ID | Version |
|------|---------|---------|
| Cutadapt | `toolshed.g2.bx.psu.edu/repos/lparsons/cutadapt/cutadapt/5.2+galaxy1` | 5.2+galaxy1 |
| Meryl - count kmers | `toolshed.g2.bx.psu.edu/repos/iuc/meryl_count_kmers/meryl_count_kmers/1.4.1+galaxy0` | 1.4.1+galaxy0 |
| Meryl - groups of kmers | `toolshed.g2.bx.psu.edu/repos/iuc/meryl_groups_kmers/meryl_groups_kmers/1.4.1+galaxy0` | 1.4.1+galaxy0 |
| Meryl - histogram | `toolshed.g2.bx.psu.edu/repos/iuc/meryl_histogram_kmers/meryl_histogram_kmers/1.4.1+galaxy0` | 1.4.1+galaxy0 |
| GenomeScope | `toolshed.g2.bx.psu.edu/repos/iuc/genomescope/genomescope/2.1.0+galaxy0` | 2.1.0+galaxy0 |
| Hifiasm | `toolshed.g2.bx.psu.edu/repos/bgruening/hifiasm/hifiasm/0.25.0+galaxy3` | 0.25.0+galaxy3 |
| gfastats | `toolshed.g2.bx.psu.edu/repos/bgruening/gfastats/gfastats/1.3.11+galaxy1` | 1.3.11+galaxy1 |
| Compleasm | `toolshed.g2.bx.psu.edu/repos/iuc/compleasm/compleasm/0.2.6+galaxy3` | 0.2.6+galaxy3 |
| Merqury | `toolshed.g2.bx.psu.edu/repos/iuc/merqury/merqury/1.3+galaxy4` | 1.3+galaxy4 |
| minimap2 | `toolshed.g2.bx.psu.edu/repos/iuc/minimap2/minimap2/2.28+galaxy2` | 2.28+galaxy2 |
| purge_dups | `toolshed.g2.bx.psu.edu/repos/iuc/purge_dups/purge_dups/1.2.6+galaxy1` | 1.2.6+galaxy1 |
| BWA-MEM2 | `toolshed.g2.bx.psu.edu/repos/iuc/bwa_mem2/bwa_mem2/2.3+galaxy0` | 2.3+galaxy0 |
| PretextMap | `toolshed.g2.bx.psu.edu/repos/iuc/pretext_map/pretext_map/0.2.3+galaxy0` | 0.2.3+galaxy0 |
| Pretext Snapshot | `toolshed.g2.bx.psu.edu/repos/iuc/pretext_snapshot/pretext_snapshot/0.0.5+galaxy1` | 0.0.5+galaxy1 |
| YaHS | `toolshed.g2.bx.psu.edu/repos/iuc/yahs/yahs/1.2a.2+galaxy3` | 1.2a.2+galaxy3 |

**Decontamination tools (WF9):**

| Tool | Tool ID | Version |
|------|---------|---------|
| FCS Adaptor | `toolshed.g2.bx.psu.edu/repos/richard-burhans/ncbi_fcs_adaptor/ncbi_fcs_adaptor/0.5.0+galaxy0` | 0.5.0+galaxy0 |
| FCS GX | `toolshed.g2.bx.psu.edu/repos/iuc/ncbi_fcs_gx/ncbi_fcs_gx/0.5.5+galaxy2` | 0.5.5+galaxy2 |
| DustMasker | `toolshed.g2.bx.psu.edu/repos/devteam/ncbi_blast_plus/ncbi_dustmasker_wrapper/2.16.0+galaxy0` | 2.16.0+galaxy0 |
| blastn | `toolshed.g2.bx.psu.edu/repos/devteam/ncbi_blast_plus/ncbi_blastn_wrapper/2.16.0+galaxy0` | 2.16.0+galaxy0 |
| parse_mito_blast | `toolshed.g2.bx.psu.edu/repos/iuc/parse_mito_blast/parse_mito_blast/1.0.2+galaxy0` | 1.0.2+galaxy0 |
| Filter by length | `toolshed.g2.bx.psu.edu/repos/devteam/fasta_filter_by_length/fasta_filter_by_length/1.2` | 1.2 |

**Text processing tools (shared across workflows):**

| Tool | Tool ID | Version |
|------|---------|---------|
| sed (Text transformation) | `toolshed.g2.bx.psu.edu/repos/bgruening/text_processing/tp_sed_tool/9.5+galaxy2` | 9.5+galaxy2 |
| Replace Text | `toolshed.g2.bx.psu.edu/repos/bgruening/text_processing/tp_replace_in_line/9.5+galaxy2` | 9.5+galaxy2 |
| Concatenate | `toolshed.g2.bx.psu.edu/repos/bgruening/text_processing/tp_cat/9.5+galaxy2` | 9.5+galaxy2 |

### Parameter Icons

Use these icons before parameter names in hands-on boxes:

| Icon | Syntax | Use For |
|------|--------|---------|
| File input | `{% icon param-file %}` | Single file parameter |
| Multiple files | `{% icon param-files %}` | Multi-file input |
| Collection | `{% icon param-collection %}` | Dataset collection |
| Text | `{% icon param-text %}` | Free text input |
| Select | `{% icon param-select %}` | Dropdown selection |
| Checkbox | `{% icon param-check %}` | Yes/No checkbox |
| Toggle | `{% icon param-toggle %}` | Toggle switch |
| Repeat | `{% icon param-repeat %}` | Repeat/add section |

### Other Useful Icons

```markdown
{% icon galaxy-eye %}          # View/eye icon (inspect dataset)
{% icon galaxy-pencil %}       # Edit icon (edit attributes)
{% icon galaxy-delete %}       # Delete icon
{% icon galaxy-history %}      # History icon
{% icon tool %}                # Tool icon
{% icon question %}            # Question mark
{% icon congratulations %}     # Celebration
```

### Snippets (Reusable Content)

Include shared FAQ content:

```markdown
{% snippet faqs/galaxy/datasets_import_via_link.md %}
{% snippet faqs/galaxy/histories_create_new.md %}
{% snippet faqs/galaxy/datasets_rename.md %}
{% snippet faqs/galaxy/datasets_change_datatype.md datatype="fasta" %}
{% snippet faqs/galaxy/collections_build_list_paired.md %}
```

Snippets accept optional parameters (key="value"). Common snippets:
- `datasets_import_via_link.md` — Import data from URL
- `datasets_import_from_data_library.md` — Import from data library
- `histories_create_new.md` — Create new history
- `datasets_rename.md` — Rename dataset
- `datasets_change_datatype.md` — Change datatype (pass `datatype="..."`)
- `collections_build_list.md` — Build dataset list
- `collections_build_list_paired.md` — Build paired list

Collection snippets accept customization parameters:
```markdown
{% snippet faqs/galaxy/collections_build_list_paired.md datasets_description="the two Hi-C datasets (SRR7126301_1 and SRR7126301_2)" n="2" %}
```
- `datasets_description`: overrides the default "all datasets" text
- `n`: sets the number shown in "n of N selected" prompt

You can change the box type of a snippet:
```markdown
{% snippet faqs/galaxy/histories_create_new.md box_type="hands_on" %}
```

### Workflow Snippets

To let users import a workflow bundled in the tutorial's `workflows/` directory:

```markdown
{% snippet faqs/galaxy/workflows_run_trs.md path="topics/assembly/tutorials/my-tutorial/workflows/main_workflow.ga" title="My Workflow" %}
```

For tutorials that import workflows from Dockstore (e.g., IWC workflows):

```markdown
{% snippet faqs/galaxy/workflows_run_ds.md title="Genome profile analysis (WF1)" dockstore_id="github.com/iwc-workflows/kmer-profiling-hifi-VGP1/main" version="v0.6" %}
```

Use `workflows_run_ds.md` (Dockstore) when the tutorial references external IWC workflows.
Use `workflows_run_trs.md` (TRS) when the workflow .ga file is bundled in the tutorial's `workflows/` directory.

### Images

```markdown
![Alt text for accessibility](../../images/image_name.png "Caption shown below figure")
```

- Images go in `topics/{topic}/images/`
- Path from tutorial.md is `../../images/`
- Alt text is required for accessibility
- Caption in quotes is optional but recommended

### Citations

Define in `tutorial.bib` (BibTeX format):
```bibtex
@article{key2024,
  title={Article Title},
  author={Last, First and Other, Author},
  journal={Journal Name},
  year={2024},
  doi={10.xxxx/xxxxx}
}
```

Reference in tutorial:
```markdown
{% cite key2024 %}
```

### Internal Links

```markdown
[Link text]({% link topics/topic_name/tutorials/tutorial_name/tutorial.md %})
```

### Math (LaTeX)

```markdown
Inline: $$ x^2 + y^2 = z^2 $$
Block (on its own line): $$ \sum_{i=1}^{n} x_i $$
```

### Tables

Standard markdown tables:
```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| data     | data     | data     |
```
