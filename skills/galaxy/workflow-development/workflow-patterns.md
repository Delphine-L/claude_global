# Workflow Patterns and Tool Management

Common workflow patterns, tool version migration, ToolShed API usage, and writing methods sections for publications.

## Common Workflow Patterns

### Pattern 1: Data Fetching
```
Input: Accession list
|
Tool: Fetch data (e.g., fasterq-dump)
|
Tool: Quality control (e.g., FastQC)
|
Output: Raw reads + QC report
```

### Pattern 2: Read Processing
```
Input: FASTQ files
|
Tool: Quality trimming
|
Tool: Alignment/Mapping
|
Tool: Post-processing
|
Output: Processed data + statistics
```

### Pattern 3: Analysis Pipeline
```
Input: Processed data + reference
|
Tool: Primary analysis (e.g., variant calling, quantification)
|
Tool: Filtering/Normalization
|
Tool: Visualization
|
Output: Results + plots + reports
```

---

## Tool Version Migration in .ga Files

When updating a tool to a newer version in an existing .ga workflow, ALL of these fields must be updated for each affected step:

1. **`content_id`**: Full toolshed path including version (e.g., `toolshed.g2.bx.psu.edu/repos/owner/tool/tool_id/1.4.2+galaxy0`)
2. **`tool_id`**: Same as content_id for toolshed tools
3. **`tool_version`**: Version string (e.g., `1.4.2+galaxy0`)
4. **`tool_shed_repository.changeset_revision`**: Galaxy wrapper revision hash -- look up via `get_tool_details(tool_id)` on the Galaxy MCP
5. **`tool_state`**: JSON dict of parameters -- MUST match the new tool's parameter schema exactly

Use `replace_all` when a field (e.g., `changeset_revision`) appears identically in multiple steps using the same tool.

**Always validate JSON after editing:**
```bash
python3 -c "import json; json.load(open('workflow.ga'))"
```

### Common tool_state Migration Patterns

**Flat parameter -> Conditional:**
```json
// Old: flat dropdown
"assembler": "spades"

// New: conditional with sub-options
"assembler_type": {"assembler": "spades", "__current_case__": 3, "plasmid": false}
```

**Removed parameters:** Delete from tool_state entirely. Do NOT leave old keys.

**New parameters:** Add with their default values. Check defaults via `get_tool_details(tool_id, io_details=True)`.

**Changed output types:** Update the step's `outputs` list (e.g., `"type": "txt"` -> `"type": "gfa1"` for Flye's assembly graph).

**Removed outputs:** Remove from both `outputs` and `workflow_outputs` arrays.

**Input type changes** (e.g., `data_collection` -> `data` with `multiple:true`): Collections still work as input at runtime but the schema is different in tool_state.

### Parameter Location Changes Between Wrapper Versions

When a wrapper update moves a parameter from one level to another in the tool XML, the `tool_state` in the .ga file retains the old location. Reverting the tool version then causes "No value found" warnings because the parameter is in a location the older wrapper doesn't expect.

**Example**: gfastats `1.3.11+galaxy1` moved `discover_paths` from `mode_condition` (top-level) into `output_condition` (GFA-only conditional). Reverting to `galaxy0` requires manually moving the parameter back:

```json
// galaxy1 format (wrong for galaxy0):
"output_condition": {"out_format": "gfa", "discover_paths": false}

// galaxy0 format (correct):
"mode_condition": {"discover_paths": true, "output_condition": {"out_format": "gfa"}}
```

**Always check**: After reverting a tool version, compare `tool_state` against the older wrapper's XML schema. Parameters may need to be relocated or added.

### When NOT to Update In-Place

Do NOT attempt in-place .ga file edits when:
- The tool has been **replaced by a completely different tool** (e.g., JBrowse 1.x -> JBrowse2 has different owner, ID, and interface)
- The tool has been **split into multiple tools** (e.g., monolithic Meryl -> 7 separate Meryl tools)

These require rebuilding the affected workflow steps from scratch.

---

## Galaxy Tool Version Audit with MCP

To check whether a workflow's tools are up to date on a Galaxy server:

1. **Extract tool IDs** from the .ga file (look for `tool_id` fields in each step)
2. **Search for current versions**: `search_tools_by_name("tool_name")` returns the latest installed version
3. **Compare versions**: Classify as same / wrapper-only / minor / major
4. **For major changes**: `get_tool_details(tool_id, io_details=True)` returns the full parameter schema. Compare against the `tool_state` in the .ga file to identify:
   - Parameters renamed or restructured
   - New required parameters
   - Removed outputs
   - Changed default values
5. **Get changeset_revision**: The `tool_shed_repository` section in `get_tool_details()` output provides the exact `changeset_revision` hash needed for the .ga file

---

## ToolShed API for Tool Version Discovery

To find the latest version of a tool directly on the ToolShed (without needing a Galaxy server):

### 1. Get repository ID
```bash
curl -s "https://toolshed.g2.bx.psu.edu/api/repositories?name={tool_name}&owner={owner}"
# Returns JSON array, use [0]["id"] for the repo ID
```

### 2. Get all revisions with tool versions
```bash
curl -s "https://toolshed.g2.bx.psu.edu/api/repositories/{repo_id}/metadata"
# Keys are "N:changeset_hash" (e.g., "0:5799092ffdff", "1:2b8b4cacb83d")
# The LAST entry contains the latest version
# Each entry has: tools[].version, changeset_revision
```

### 3. Extract latest version info
```python
keys = list(metadata.keys())
latest = metadata[keys[-1]]
tool_version = latest["tools"][0]["version"]  # e.g., "1.3.11+galaxy1"
changeset = latest["changeset_revision"]       # e.g., "0fe699ced54f"
```

**Note**: The ToolShed metadata endpoint does NOT include tool input definitions. Use Galaxy MCP `get_tool_details(tool_id, io_details=True)` to compare inputs between versions.

---

## Tool Update Verification Checklist

After updating tool versions in a workflow, verify these potential issues:

1. **Default value contradictions**: New defaults may override explicit workflow settings (boolean flips, changed numeric values)
2. **Lost text/value inputs**: Enum options may have been removed; check `tool_state` values against new schema
3. **New required params without defaults**: Will cause tool failure if not configured
4. **Removed params still referenced**: Check both `tool_state` and `input_connections`
5. **Conditional/section restructuring**: Parameter paths may change (e.g., `param` -> `section|param`)
6. **Output changes**: Removed/renamed outputs break downstream step connections and `post_job_actions`

Use Galaxy MCP `get_tool_details(tool_id, io_details=True)` for both old and new versions to compare schemas systematically.

---

## Writing Methods Sections for Publications

When helping users write methods sections for scientific papers based on Galaxy workflows:

### 1. Workflow Analysis Strategy

**Examine workflow metadata first:**
```bash
# Get workflow name and description
head -30 workflow.ga | grep -E '"name"|"annotation"'

# Extract tool names and versions
grep -o '"tool_id": "[^"]*"' workflow.ga | sort -u

# Find specific tools (e.g., assemblers)
grep -o '"tool_id": "[^"]*hifiasm[^"]*"' workflow.ga
```

**For large workflows (>25000 tokens):**
- Don't read entire files - they'll exceed token limits
- Use grep to extract specific information
- Read only first 100 lines for metadata: `head -100 workflow.ga`
- Search for tool patterns rather than reading everything

### 2. VGP Workflow Documentation Pattern

For VGP pipeline workflows, document in this order:

1. **Platform and pipeline**: "implemented in Galaxy (cite) using VGP workflows (cite)"
2. **Data-specific approach**: Distinguish trio vs non-trio methods
3. **Sequential workflow steps**:
   - K-mer profiling (Meryl, GenomeScope2)
   - Assembly (HiFiasm with appropriate mode)
   - Scaffolding (RagTag with reference)
   - Quality assessment (BUSCO/Compleasm, Merqury, gfastats)
4. **Tool versions**: Always include version numbers
5. **Specific parameters**: Reference genomes, accessions used

### 3. Methods Section Template

```markdown
Genome assemblies were generated using the [Pipeline Name] workflows (Citation)
implemented in Galaxy (Galaxy Community, 2024). For [condition A], we employed
[approach A]: first, [step 1] using [Tool v.X] (Citation), followed by [step 2]
using [Tool v.Y] (Citation). For [condition B], we performed [approach B]
using [Tool v.Z] (Citation). All assemblies were [post-processing step] using
[Tool] with [specific parameter/reference]. Assembly quality was assessed using
multiple metrics including [Tool A] for [metric type], [Tool B] for [metric type],
and [Tool C] for [metric type]. [Annotation or downstream analysis] was performed
using [Tool/Pipeline] (Citation), which [brief description]. [Specific data sources
with accessions].
```

### 4. Common VGP Workflow Tool Citations Needed

**Core tools to cite:**
- Galaxy platform: The Galaxy Community (2024)
- VGP workflows: Lariviere et al. (2024) Nature Biotechnology
- HiFiasm: Cheng et al. (2021) Nature Methods
- Meryl: Rhie et al. (2020) Genome Biology
- GenomeScope2: Ranallo-Benavidez et al. (2020) Nature Communications
- Merqury: Rhie et al. (2020) Genome Biology
- BUSCO: Manni et al. (2021) MBE
- Compleasm: Huang & Li (2023) Bioinformatics
- RagTag: Alonge et al. (2022) Genome Biology
- gfastats: Formenti et al. (2022) Bioinformatics
- EGApX: Thibaud-Nissen et al. (2013) NCBI Handbook

### 5. Key Information to Extract from Workflows

**From workflow annotation field:**
- Purpose and description
- Pipeline position (e.g., "Part of VGP suite, run after VGP1")

**From tool_id fields:**
- Primary assembler (hifiasm, flye, etc.)
- Scaffolding tool (ragtag, yahs, etc.)
- QC tools (busco, merqury, etc.)

**From inputs:**
- Data types required (HiFi, Hi-C, Illumina, trio data)
- Reference genome requirements
- RNA-seq accessions for annotation

**From parameters:**
- K-mer lengths
- Ploidy settings
- BUSCO lineages
- Coverage thresholds

### 6. Workflow File Size Considerations

**Token-efficient workflow analysis:**
```bash
# Get file size first
ls -lh workflow.ga

# For large files (>100K):
# - Extract metadata only (first 100 lines)
# - Use grep for specific tools
# - Read tool documentation instead of entire workflow

# For small files (<100K):
# - Can read with limit parameter
# - Still prefer targeted grep when possible
```
