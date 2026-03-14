---
name: galaxy-workflow-development
description: Expert in Galaxy workflow development, testing, and IWC best practices. Create, validate, and optimize .ga workflows following Intergalactic Workflow Commission standards.
version: 1.0.0
---

# Galaxy Workflow Development Expert

You are an expert in Galaxy workflow development, testing, and best practices based on the Intergalactic Workflow Commission (IWC) standards.

## Core Knowledge

### Galaxy Workflow Format (.ga files)

Galaxy workflows are JSON files with `.ga` extension containing:

#### Required Top-Level Metadata
```json
{
    "a_galaxy_workflow": "true",
    "annotation": "Detailed description of workflow purpose and functionality",
    "creator": [
        {
            "class": "Person",
            "identifier": "https://orcid.org/0000-0002-xxxx-xxxx",
            "name": "Author Name"
        },
        {
            "class": "Organization",
            "name": "IWC",
            "url": "https://github.com/galaxyproject/iwc"
        }
    ],
    "format-version": "0.1",
    "license": "MIT",
    "release": "0.1.1",
    "name": "Human-Readable Workflow Name",
    "tags": ["domain-tag", "method-tag"],
    "uuid": "unique-identifier",
    "version": 1
}
```

#### Workflow Steps Structure

Steps are numbered sequentially and define:

1. **Input Datasets**
   - `type: "data_input"` - Single file input
   - `type: "data_collection_input"` - Collection of files
   - Must have descriptive `annotation` and `label`

2. **Input Parameters**
   - `type: "parameter_input"`
   - Types: text, boolean, integer, float, color
   - Used for user-configurable settings

3. **Tool Steps**
   - `type: "tool"`
   - `tool_id` and `content_id` reference Galaxy ToolShed
   - `tool_shed_repository` includes owner, name, changeset_revision
   - `input_connections` link to previous step outputs
   - `tool_state` contains parameter values (JSON-encoded)

4. **Workflow Outputs**
   - Marked with `workflow_outputs` array
   - Each output has a `label` (human-readable name)
   - Can hide intermediate outputs with `hide: true`

#### Advanced Features

- **Comments**: `type: "text"` steps for documentation
- **Frames**: Visual grouping with color-coded boxes
- **Reports**: Embedded Markdown templates using Galaxy report syntax
- **Post-job actions**: Rename, tag, or hide outputs
- **Conditional execution**: `when` field for conditional steps

### Key Rules

#### Naming Conventions (STRICT)

- **Folder/file names**: lowercase, dashes only (no underscores, no spaces)
- **Workflow name** (in .ga): Human-readable, can use spaces and capitalization
- **Input/output labels**: Human-readable, descriptive, no technical abbreviations
- **Compound adjectives**: Use singular form (e.g., "short-read sequencing", not "short-reads sequencing")

#### Workflow Design Principles

1. **Generic Workflows**: No hardcoded sample names; use parameter inputs for user-configurable values
2. **Clear Naming**: Descriptive labels; explain expected format in annotation
3. **Rich Annotations**: Detailed workflow/step/parameter annotations
4. **Complete Metadata**: Creator with ORCID, IWC organization, MIT license, semantic versioning
5. **Pinned Tool Versions**: Exact version + `changeset_revision`; document in CHANGELOG

#### Testing Essentials

- Test file naming: `workflow-name.ga` -> `workflow-name-tests.yml`
- Minimum one test case per workflow
- Files < 100KB in `test-data/`; files >= 100KB on Zenodo with SHA-1 hash
- Use strictest possible assertions; prefer exact file comparison
- Always use `workflow_lint` for `.ga` files (not `lint`, which is for tool XML)

#### Planemo Commands (Quick Reference)

```bash
# Lint workflow
planemo workflow_lint --iwc workflow.ga

# Test on live instance (PREFERRED)
planemo test --fail_fast \
  --galaxy_url https://usegalaxy.org \
  --galaxy_user_key "$API_KEY" \
  workflow.ga

# Test locally (slower, use only when needed)
planemo test workflow.ga
```

**IMPORTANT**: Always prefer testing against live Galaxy instances over local Galaxy.

#### Common Issues (Quick Reference)

| Issue | Solution |
|-------|----------|
| Test "output not found" | Check output label matches exactly (case-sensitive) |
| Large test files in repo | Upload to Zenodo, reference by URL with hash |
| Workflow not generic | Replace hardcoded values with parameter inputs |
| Tool update breaks workflow | Pin exact version in changeset_revision |
| Tests pass locally, fail in CI | Check reference data availability on CVMFS |
| Lint warnings | Run `planemo workflow_lint --iwc` and address each |
| Cannot push to planemo-autoupdate branches | Edit via GitHub web UI, or push to own fork |
| Tool version revert no effect | Disable `use_cached_job` in Galaxy preferences |

### Version Bumping

When updating a workflow:
1. Update `release` field in .ga file
2. Add entry to CHANGELOG.md
3. Update tests if needed
4. Commit with descriptive message

### Deployment Pipeline

After PR merge: Tests pass -> RO-Crate metadata generated -> Deployed to iwc-workflows -> Registered on Dockstore -> Registered on WorkflowHub -> Auto-installed on usegalaxy.* servers

---

## Supporting References

Detailed guidance is split into the following files in this directory:

- **[iwc-standards.md](./iwc-standards.md)** - IWC repository structure, required files (.dockstore.yml, README, CHANGELOG), workflow categories, review checklist, IWC submission preparation (release numbers, runtime parameter cleanup)
- **[testing-guide.md](./testing-guide.md)** - Complete testing reference: test file structure, assertion types/syntax, Planemo lint errors, remote testing, test data organization, synthetic data generation, troubleshooting tool failures, adjusting assertions
- **[workflow-patterns.md](./workflow-patterns.md)** - Common workflow patterns, tool version migration in .ga files, ToolShed API for version discovery, tool update verification, writing methods sections for publications

---

## Related Skills

- **galaxy-tool-wrapping** - Creating Galaxy tools that can be used in workflows
- **galaxy-automation** - BioBlend & Planemo foundation for workflow testing
- **conda-recipe** - Building conda packages for workflow tool dependencies

---

## Applying This Knowledge

When helping with Galaxy workflow development:

1. **Creating new workflows**: Follow IWC structure and naming conventions
2. **Writing tests**: Use appropriate assertions and test data management
3. **Reviewing workflows**: Apply the review checklist systematically
4. **Debugging**: Check lint output and test logs carefully
5. **Updating workflows**: Maintain CHANGELOG and version properly
6. **Documentation**: Write clear, detailed annotations and READMEs

Always prioritize:
- **Reproducibility**: Pin versions, hash test data
- **Usability**: Human-readable names, clear documentation
- **Quality**: Comprehensive tests, generic design
- **Standards**: Follow IWC conventions strictly
