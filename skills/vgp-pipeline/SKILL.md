---
name: vgp-pipeline
description: Expert knowledge for VGP genome assembly PIPELINE CODEBASE development - orchestrator.py, galaxy_client.py, workflow_manager.py. For modifying the batch execution system, debugging pipeline orchestration, or implementing error handling. NOT for general Galaxy tool/workflow development.
version: 2.0.0
dependencies: galaxy-automation, python>=3.8, pandas, pyyaml
---

# VGP Pipeline Development Skill

## Purpose

This skill provides expert knowledge of the **VGP (Vertebrate Genomes Project) pipeline codebase** - specifically the Python orchestration system (`batch_vgp_run/`) that automates genome assembly workflow execution through Galaxy.

**Prerequisites:** This skill depends on the `galaxy-automation` global skill, which provides foundational BioBlend and Planemo knowledge. This skill focuses exclusively on VGP-specific orchestration logic, workflow sequences, metadata structures, and the batch_vgp_run codebase.

## When to Use This Skill

**Use this skill when working on:**
- ✅ The VGP pipeline **orchestration codebase** (`run_all.py`, `orchestrator.py`, `galaxy_client.py`, `workflow_manager.py`)
- ✅ VGP-specific batch execution system for running multiple species
- ✅ VGP workflow sequence logic (WF1 → WF4 → WF0/WF8 → WF9 → PreCuration)
- ✅ VGP metadata collection, GenomeArk integration, and results tracking
- ✅ VGP-specific error handling (e.g., expected mitochondrial failures)
- ✅ VGP assembly ID handling and directory structure
- ✅ Debugging failed VGP workflow invocations in the orchestration system
- ✅ Understanding the VGP pipeline architecture and codebase structure

## When NOT to Use This Skill

**Do NOT use this skill for:**
- ❌ General BioBlend or Planemo usage (use `galaxy-automation` skill instead)
- ❌ Creating new Galaxy tool wrappers (use `galaxy-tool-wrapping` skill instead)
- ❌ Developing Galaxy workflows in general (use `galaxy-workflow-development` skill instead)
- ❌ Building conda/bioconda recipes (use `conda-recipe` skill instead)
- ❌ General Galaxy usage or administration
- ❌ Analyzing genome assembly results (this is about the orchestration code, not the biology)
- ❌ Working on individual VGP workflows (WF1, WF4, etc.) unless integrating them into the orchestration system

**In other words:** This skill is for the **VGP pipeline automation codebase**, not for general Galaxy automation, VGP workflows themselves, or general Galaxy development. For foundational Galaxy automation patterns, see the `galaxy-automation` skill.

## Project Setup

VGP projects should use the centralized skill repository for consistency across species runs.

### Quick Setup for New VGP Projects

Tell Claude:
```
Set up Claude Code for a VGP pipeline project. Symlink the vgp-pipeline skill and all VGP commands from $CLAUDE_METADATA.
```

This will create symlinks to:
- **VGP pipeline skill**: Expert knowledge of workflow orchestration
- **VGP commands**: `/check-status`, `/debug-failed`, `/setup-cron`, etc.

### Why This Matters

- **Consistent VGP knowledge** across all species runs
- **Easy updates** to pipeline procedures (update once, all projects benefit)
- **Shared commands** for status checking, debugging, cron setup
- **Team alignment** everyone uses same skills and commands

### What Gets Symlinked

```bash
.claude/
├── skills/
│   ├── galaxy-automation -> $CLAUDE_METADATA/.claude/skills/galaxy-automation (dependency)
│   └── vgp-pipeline -> $CLAUDE_METADATA/skills/vgp-pipeline
└── commands/
    ├── check-status.md -> $CLAUDE_METADATA/commands/vgp-pipeline/check-status.md
    ├── debug-failed.md -> $CLAUDE_METADATA/commands/vgp-pipeline/debug-failed.md
    ├── setup-cron.md -> $CLAUDE_METADATA/commands/vgp-pipeline/setup-cron.md
    └── update-skills.md -> $CLAUDE_METADATA/commands/vgp-pipeline/update-skills.md
```

**Note:** The `galaxy-automation` global skill is automatically loaded as a dependency and provides BioBlend/Planemo knowledge.

## Architecture Overview

### Core Components

**`batch_vgp_run/orchestrator.py`** - Main workflow orchestration
- `run_species_workflows()`: Primary function coordinating all workflows for a species
- `process_species_wrapper()`: Thread wrapper for parallel species processing
- Returns: `{'status': 'success/error', 'metadata': {assembly_id: metadata_dict}}`

**`batch_vgp_run/galaxy_client.py`** - Galaxy API interactions
- `get_or_find_history_id()`: History management
- `check_invocation_complete()`: Poll invocation status
- `rerun_failed_invocation()`: Retry failed workflows with parameter updates
- `build_replacement_params_from_yaml()`: Detect parameter changes for reruns

**`batch_vgp_run/workflow_manager.py`** - Workflow version/ID handling
- `resolve_workflow()`: Auto-detects IDs (16-char hex) vs versions (X.Y format)
- `is_workflow_id()`: Pattern matching for workflow identifiers
- Downloads from GitHub, uploads to Galaxy for version numbers

**`batch_vgp_run/utils.py`** - Shared utilities
- `get_working_assembly()`: Extract working assembly IDs (handles suffixes)
- `normalize_suffix()`: Handle NaN/NA values in suffixes
- `fix_parameters()`: Normalize URLs and suffixes

**`scripts/run_all.py`** - Batch execution orchestrator
- Thread-based parallel species processing
- Metadata synchronization with locks
- Resume capability with state tracking

### Workflow Dependencies

```
WF1 (kmer profiling)
  ├─→ WF4 (assembly + phasing)
  │     ├─→ WF0 (mitochondrial) [launched in background]
  │     └─→ WF8 (haplotype scaffolding)
  │           └─→ WF9 (decontamination)
  │                 └─→ PreCuration (optional, Pretext maps)
```

**Critical Rules:**
- WF4 requires WF1 **complete**
- WF0 requires WF4 **launched** (doesn't wait for completion)
- WF8 requires WF4 **complete**
- WF9 requires WF8 **complete**
- PreCuration requires WF9 **complete**

### Directory Structure Per Species

```
{assembly_id}/
├── job_files/          # YAML job definitions
├── invocations_json/   # Planemo output with invocation IDs
├── reports/            # PDF workflow reports
└── planemo_log/        # Planemo execution logs
```

## Key Implementation Patterns

### 1. Error Handling for Planemo Failures

**Critical Pattern:** When planemo command fails (return code != 0), **DO NOT** mark invocations as failed in metadata.

```python
return_code = os.system(command_lines['Workflow_1'])
if return_code != 0:
    print(f"ERROR: Workflow 1 for {assembly_id} failed with return code {return_code}")
    print(f"Check log file: {log_file}")
    print(f"Planemo command failed - workflow was not launched. Metadata not modified.")
    return {'status': 'error', 'metadata': {assembly_id: list_metadata[assembly_id]}}
```

**Why:** Planemo errors mean the workflow was never launched in Galaxy (no invocation created). Only mark invocations as failed when Galaxy reports failure via API.

### 2. Status Return Format

All workflow functions return structured status:

```python
# Success
return {'status': 'success', 'metadata': {assembly_id: list_metadata[assembly_id]}}

# Error (planemo failed, no invocation)
return {'status': 'error', 'metadata': {assembly_id: list_metadata[assembly_id]}}
```

Consumer checks status:
```python
result = run_species_workflows(...)
if result.get('status') == 'success':
    print("✓ Successfully completed")
else:
    print("✗ Completed with errors")
```

### 3. Thread-Safe Metadata Updates

**Pattern:** VGP uses thread-safe metadata updates for parallel species processing. See `galaxy-automation` skill for general thread-safety patterns.

```python
results_lock = threading.Lock()

with results_lock:
    list_metadata[species_id] = result['metadata'][species_id]
    results_status[species_id] = "completed"
```

**VGP-specific:** Metadata dictionary structure includes assembly_id, invocation tracking, and workflow-specific output dataset IDs.

### 4. Workflow Auto-Detection

```python
# Profile can contain either:
# - IDs: "a1b2c3d4e5f67890" (16-char hex)
# - Versions: "0.5" or "3.1.2"

workflow_id, release_number, workflow_path = workflow_manager.resolve_workflow(
    gi,
    profile_data['Workflow_1'],  # Could be ID or version
    'kmer-profiling-hifi-VGP1',  # Workflow name for version download
    workflows_dir
)
```

### 5. Planemo Command Line Generation

**Pattern:** VGP uses Planemo for workflow execution. See `galaxy-automation` skill for general Planemo usage.

```python
command_lines[key] = (
    f'planemo run "{workflow_path}" "{job_yaml}" '
    f'--engine external_galaxy '
    f'--galaxy_url "{galaxy_instance}" '
    f'--simultaneous_uploads '
    f'--check_uploads_ok '
    f'--galaxy_user_key "{galaxy_key}" '
    f'--history_name "{history_name}" '
    f'--test_output_json "{res_file}" '
    f'> "{log_file}" 2>&1'
)
```

**VGP-specific:**
- Job YAML files stored in `{assembly_id}/job_files/`
- Output JSON stored in `{assembly_id}/invocations_json/`
- Logs stored in `{assembly_id}/planemo_log/`
- History names follow pattern: `VGP_{workflow_name}_{assembly_id}_{suffix}`

## Common Development Tasks

### Adding a New Workflow

1. **Update workflow dictionary** in `run_all.py`:
   ```python
   dico_workflows["Workflow_X"] = {
       'Name': 'workflow-name-from-iwc',
       'Path': 'NA',
       'version': 'NA'
   }
   ```

2. **Create template** in `batch_vgp_run/templates/`:
   - Name: `wfX_{assembly_id}.yml`
   - Use placeholders: `["field_name"]`

3. **Add preparation function** in `orchestrator.py`:
   - Extract dataset IDs from prerequisites
   - Populate YAML template
   - Generate planemo command

4. **Update workflow dependencies** in orchestration logic

### Debugging Failed Workflows

**General debugging:** See `galaxy-automation` skill for BioBlend debugging patterns.

**VGP-specific debugging locations:**

1. **Check planemo log**:
   ```
   {assembly_id}/planemo_log/{assembly_id}_Workflow_{N}.log
   ```

2. **Check invocation JSON** (if workflow launched):
   ```
   {assembly_id}/invocations_json/{assembly_id}_Workflow_{N}.json
   ```

3. **VGP-specific failure patterns**:
   - `return code 256`: Planemo failure (upload error, parameter error)
   - Expected mitochondrial failures (Workflow_0): Check with `check_mitohifi_failure()`
   - GenomeArk URL fetch failures: Check `batch_vgp_run/get_urls.py` logs
   - Template placeholder errors: Verify all `["field_name"]` replaced in job YAML

### Modifying Retry Logic

**Location:** `scripts/run_all.py` lines ~355-437

**General retry patterns:** See `galaxy-automation` skill for BioBlend invocation rerun patterns.

**VGP-specific retry features:**
- Separates **expected failures** (e.g., no mitochondrial reads in WF0) from retriable failures
- Uses `check_mitohifi_failure()` to identify biological failures that shouldn't be retried
- Supports parameter modifications via `build_replacement_params_from_yaml()`
- Optional job result caching with `use_cached_job` parameter

```python
# VGP-specific: Check for expected failures before retrying
if workflow == "Workflow_0":
    failure_reason = check_mitohifi_failure(gi, invocation_id)
    if "no mitochondrial reads" in failure_reason:
        invocation_dict['is_expected'] = True
        # Don't retry expected biological failures
        continue

# Detect parameter changes from updated YAML
replacement_params = build_replacement_params_from_yaml(
    gi, invocation_id, job_yaml_path
)

# Rerun with optional caching
new_invocation_id = rerun_failed_invocation(
    gi, invocation_id,
    use_cached_job=not args.no_cache,
    job_yaml_path=job_yaml_path
)
```

## Template System

### Location
`batch_vgp_run/templates/`

### Placeholder Syntax
```yaml
["field_name"]  # Replaced by script with actual values
```

### Common Placeholders
- `["Pacbio"]`: HiFi reads collection YAML
- `["hic"]`: Hi-C paired reads collection YAML
- `["species_name"]`, `["assembly_name"]`: Metadata
- `["dataset_id_field"]`: Dataset IDs from previous workflows

### Replacement Pattern
```python
with open(template_file, 'r') as f:
    template = f.read()

template = template.replace('["species_name"]', species_name)
template = template.replace('["Pacbio"]', pacbio_yaml)
# ... more replacements

with open(output_file, 'w') as f:
    f.write(template)
```

## Testing Considerations

### SLURM Execution
- Scripts run via `sbatch` execute on compute nodes
- All `os.system()` calls inherit compute node environment
- No need for `srun` prefix within script

### Parallel Execution
- Default: 3 concurrent species (`-c 3`)
- Each species runs in separate thread
- Upload conflicts possible with high concurrency

### Expected Failures
Some failures are biological/expected:
```python
if workflow == "Workflow_0":
    failure_reason = check_mitohifi_failure(gi, invocation_id)
    if "no mitochondrial reads" in failure_reason:
        invocation_dict['is_expected'] = True
```

Don't retry expected failures.

## Code Navigation Reference

### Finding Functionality

**Galaxy API calls:** `batch_vgp_run/galaxy_client.py`
- History operations: Lines ~40-150
- Invocation operations: Lines ~200-400
- Rerun logic: Lines ~847-899

**Workflow orchestration:** `batch_vgp_run/orchestrator.py`
- WF1 launch: Lines ~130-200
- WF4 launch: Lines ~280-360
- WF8 launch (haplotypes): Lines ~520-680
- WF9 launch (decontamination): Lines ~880-1100

**Batch execution:** `scripts/run_all.py`
- Workflow resolution: Lines ~500-585
- Thread management: Lines ~700-750
- Retry logic: Lines ~355-437

**URL fetching:** `batch_vgp_run/get_urls.py`
- GenomeArk S3 queries: Lines ~100-250
- HiC type detection: Lines ~150-200

### File Extension Patterns

```python
r'\.f(ast)?q(sanger)?\.gz$'  # Matches .fq.gz, .fastq.gz, .fqsanger.gz, .fastqsanger.gz
r'R1'  # Forward Hi-C reads
r'R2'  # Reverse Hi-C reads
```

## Best Practices

**General practices:** See `galaxy-automation` skill for BioBlend/Planemo best practices.

**VGP-specific best practices:**
1. **Validate workflow IDs** before using (16-char hex check via `workflow_manager.is_workflow_id()`)
2. **Handle NaN/NA values** in pandas DataFrames explicitly (VGP metadata uses pandas)
3. **Check VGP workflow dependencies** before launching (WF1 complete before WF4, etc.)
4. **Update VGP tracking tables** after each workflow preparation
5. **Save VGP metadata frequently** (after each successful operation to CSV/JSON)
6. **Don't modify metadata** on planemo launch failures (no invocation created)
7. **Use assembly_id consistently** - extract with `utils.get_working_assembly()` to handle suffixes
8. **Validate GenomeArk URLs** before workflow launch (check with `get_urls.py`)
9. **Check for expected failures** before retrying (e.g., mitochondrial assembly failures)
10. **Use unique history names** per species run to avoid conflicts

## Common Pitfalls

**General pitfalls:** See `galaxy-automation` skill for common BioBlend/Planemo issues.

**VGP-specific pitfalls:**
1. **Missing invocation IDs**: Use VGP's `fetch_invocation_numbers.py` to recover from planemo interruptions
2. **History name conflicts**: VGP runs multiple workflows per species - use unique suffixes
3. **Concurrent uploads**: VGP processes multiple species in parallel - limit concurrency to avoid Galaxy upload conflicts
4. **VGP workflow version compatibility**: Changing workflow versions may break VGP template compatibility
5. **Assembly ID suffixes**: VGP uses suffixes (e.g., "v2", "retry1") - use `utils.get_working_assembly()` to extract correctly
6. **GenomeArk URL changes**: VGP fetches from GenomeArk S3 - URLs may change, always validate before launch
7. **Expected biological failures**: Don't retry mitochondrial failures marked as expected by `check_mitohifi_failure()`
8. **Workflow dependency violations**: VGP has strict dependency order - don't launch WF4 before WF1 completes

## Related Skills

- **galaxy-automation** - BioBlend & Planemo foundation (dependency)
- **bioinformatics-fundamentals** - SAM/BAM format, sequencing technologies (Hi-C, HiFi)
- **galaxy-workflow-development** - IWC workflow standards for VGP workflows
- **conda-recipe** - Building conda packages for VGP tool dependencies

## Maintenance Notes

**General workflow management:** See `galaxy-automation` skill for BioBlend workflow upload/download patterns.

**VGP-specific maintenance:**
- **VGP profile.yaml**: Stores workflow IDs or versions for WF0-WF9, PreCuration
- **Profile backups**: VGP creates `profile.yaml.bak` before auto-updates
- **VGP workflow versions**: Can use Galaxy IDs (16-char hex) or version numbers (X.Y format)
- **Auto-detection**: `workflow_manager.resolve_workflow()` auto-detects ID vs version and downloads if needed
- **Template versioning**: Keep templates in `batch_vgp_run/templates/` synchronized with workflow versions
- **Metadata schema**: VGP metadata structure evolves - maintain backward compatibility when adding fields
