# Token Efficiency - Examples and Cost Calculations

This file contains extensive token savings examples with before/after comparisons and targeted learning examples. See [SKILL.md](SKILL.md) for core rules.

---

## Token Savings Examples for Bash Commands

### Example 1: Update 10 config files

Wasteful approach:
```bash
Read: config1.yaml  # 5K tokens
Edit: config1.yaml
Read: config2.yaml  # 5K tokens
Edit: config2.yaml
# ... repeat 10 times = 50K tokens
```

Efficient approach:
```bash
Bash: for f in config*.yaml; do sed -i '' 's/old/new/g' "$f"; done
# Token cost: ~100 tokens for command, 0 for file content
```

**Savings: 49,900 tokens (99.8%)**

### Example 2: Copy configuration

Wasteful approach:
```bash
Read: template_config.yaml  # 10K tokens
Write: project_config.yaml  # 10K tokens
# Total: 20K tokens
```

Efficient approach:
```bash
Bash: cp template_config.yaml project_config.yaml
# Token cost: ~50 tokens
```

**Savings: 19,950 tokens (99.75%)**

### Example 3: Append log entry

Wasteful approach:
```bash
Read: application.log  # 50K tokens (large file)
Write: application.log  # 50K tokens
# Total: 100K tokens
```

Efficient approach:
```bash
Bash: echo "[$(date)] Log entry" >> application.log
# Token cost: ~50 tokens
```

**Savings: 99,950 tokens (99.95%)**

---

## High-Level Token Savings Examples

### Example 1: Status Check
**Scenario:** User asks "What's the status of my application?"

**Wasteful approach (50K tokens):**
```bash
Read: /var/log/app.log  # 40K tokens
Bash: systemctl status myapp  # 10K tokens
```

**Efficient approach (3K tokens):**
```bash
Bash: systemctl status myapp --no-pager | head -20  # 1K tokens
Bash: tail -50 /var/log/app.log  # 2K tokens
```
**Savings: 94%**

---

### Example 2: Debugging Errors
**Scenario:** User says "My script is failing, help debug"

**Wasteful approach (200K tokens):**
```bash
Read: debug.log  # 150K tokens
Read: script.py  # 30K tokens
Read: config.json  # 20K tokens
```

**Efficient approach (8K tokens):**
```bash
Bash: tail -100 debug.log  # 3K tokens
Bash: grep -i "error\|traceback" debug.log | tail -50  # 2K tokens
Grep: "def main" script.py  # 1K tokens
Read: script.py (offset: 120, limit: 50)  # 2K tokens (just the failing function)
```
**Savings: 96%**

---

### Example 3: Code Review
**Scenario:** User asks "Review this codebase"

**Wasteful approach (500K tokens):**
```bash
Read: file1.py
Read: file2.py
Read: file3.py
Read: file4.py
# ... reads 20+ files
```

**Efficient approach (20K tokens):**
```bash
Bash: find . -name "*.py" | head -30  # 1K
Bash: cloc .  # Lines of code summary - 1K
Bash: grep -r "^class " --include="*.py" | head -20  # 2K
Bash: grep -r "^def " --include="*.py" | wc -l  # 1K
Read: main.py (limit: 100)  # 3K
Read: README.md  # 5K
Grep: "TODO\|FIXME\|XXX" -r .  # 2K
# Then ask user what specific areas to review
```
**Savings: 96%**

---

## Targeted Learning Examples

### Example 1: Variable Number of Outputs in Galaxy Wrappers

**User query:** "How do variable number of outputs work in Galaxy wrappers?"

**Execution:**
```bash
# Step 1: Identify concept
# Concept: dynamic outputs, discover_datasets
# File type: Galaxy XML wrappers (*.xml)

# Step 2: Search for examples
grep -r "discover_datasets" --include="*.xml" -l
# Output: tools/samtools/samtools_merge.xml, tools/kraken2/kraken2.xml, ...

# Step 3: Rank examples
ls -lt tools/*/samtools_merge.xml tools/*/kraken2.xml
# Pick: samtools_merge.xml (recent, well-maintained)

# Step 4: Read example fully
Read: tools/samtools/samtools_merge.xml

# Step 5: Find another variation
grep -r "collection_type.*list" --include="*.xml" -l | head -1
Read: tools/example/collection_output.xml
```

**Explanation provided:**
```
I found two main approaches for variable outputs in Galaxy:

1. **discover_datasets pattern** (samtools_merge.xml:45-52):
   - Use <discover_datasets> in output section
   - Specify pattern and format
   - Galaxy auto-detects files matching pattern

2. **output_collection pattern** (collection_output.xml:78-85):
   - Define collection type (list, paired, etc.)
   - Use discover_datasets within collection
   - For grouped/structured outputs

Key requirements:
- Set discover_datasets pattern attribute
- Specify format for discovered files
- Optional: Use directory attribute for subdirectories

Would you like me to show a specific implementation for your use case?
```

---

### Example 2: Fetching Invocation Data from Galaxy API

**User query:** "How do I fetch invocation data using the Galaxy API?"

**Execution:**
```bash
# Step 1: Identify concept
# Concept: fetch invocation, show_invocation, invocation data
# Context: Galaxy API, bioblend usage
# File type: Python files with bioblend/API calls

# Step 2: Search for examples
grep -r "show_invocation\|get_invocation" --include="*.py" -l
# Output: galaxy_client.py, orchestrator.py, check_status.py

grep -r "invocations.show\|\.show_invocation" --include="*.py" -B 3 -A 8
# Shows actual usage patterns

# Step 3: Rank examples
# galaxy_client.py - likely has core API wrapper functions
# orchestrator.py - shows usage in context
# Pick both for different perspectives

# Step 4: Read examples
Read: batch_vgp_run/galaxy_client.py
# Focus on invocation-related functions

grep -n "def.*invocation" batch_vgp_run/galaxy_client.py
# Shows: check_invocation_complete (line 250), rerun_failed_invocation (line 847)

Read: batch_vgp_run/galaxy_client.py (offset: 245, limit: 60)
Read: batch_vgp_run/galaxy_client.py (offset: 840, limit: 70)
```

**Explanation provided:**
```
I found the pattern for fetching invocation data (galaxy_client.py:250-285):

**Basic invocation fetch:**
invocation = gi.invocations.show_invocation(invocation_id)
state = invocation['state']  # 'ok', 'running', 'failed', 'cancelled'

**Detailed invocation with steps:**
invocation = gi.invocations.show_invocation(invocation_id, include_workflow_steps=True)
steps = invocation.get('steps', {})

**Key fields available:**
- invocation['state'] - Overall invocation status
- invocation['steps'] - Individual step details
- invocation['workflow_id'] - Associated workflow
- invocation['history_id'] - Target history
- invocation['update_time'] - Last update timestamp

**Common patterns:**
1. Poll for completion (galaxy_client.py:250-285)
2. Get failed step details (galaxy_client.py:320-340)
3. Rerun with modifications (galaxy_client.py:847-899)
```

---

### Example 3: Conditional Parameters in Galaxy Tools

**User query:** "How do conditional parameters work in Galaxy tool wrappers?"

**Execution:**
```bash
# Step 1: Identify concept
# Concept: conditional parameters, when expression
# File type: Galaxy XML wrappers

# Step 2: Search
grep -r "<conditional" --include="*.xml" -l | head -10
grep -r "<conditional" --include="*.xml" -A 15 | head -50

# Step 3: Find simple example first
grep -rl "<conditional" --include="*.xml" | xargs wc -l | sort -n | head -3
# Pick shortest file with conditionals

# Step 4: Read examples
Read: tools/simple-tool/simple_conditional.xml  # Simple case
Read: tools/complex-tool/advanced_conditional.xml  # Nested case
```

**Explanation provided:**
```
Conditional parameters in Galaxy (simple_conditional.xml:34-58):

**Basic structure:**
<conditional name="output_choice">
    <param name="output_type" type="select" label="Output type">
        <option value="single">Single file</option>
        <option value="collection">Collection</option>
    </param>

    <when value="single">
        <param name="format" type="select" label="Format">
            <option value="txt">Text</option>
            <option value="csv">CSV</option>
        </param>
    </when>

    <when value="collection">
        <param name="collection_type" type="select" label="Collection type">
            <option value="list">List</option>
            <option value="paired">Paired</option>
        </param>
    </when>
</conditional>

**In command block (Cheetah syntax):**
#if $output_choice.output_type == "single":
    --format ${output_choice.format}
#else:
    --collection-type ${output_choice.collection_type}
#end if

**Advanced: Nested conditionals** (advanced_conditional.xml:67-120):
- Conditionals can contain other conditionals
- Each <when> is independent
- Access nested values: ${outer.inner.value}
```

---

## Practical Learning Mode Examples

### Example 1: Learning bioconda recipe patterns
```bash
# Step 1: Identify type
ls recipes/ | wc -l
# Output: 3000+ -> Tool library

# Step 2: Check guidelines
Read: CONTRIBUTING.md  # Learn structure requirements

# Step 3: Find representative recipes
ls -lt recipes/ | head -5  # Get recent ones
# Pick one that was updated recently (current practices)
Read: recipes/recent-tool/meta.yaml

# Pick one established recipe for comparison
Read: recipes/established-tool/meta.yaml

# Step 4: Summarize pattern
"I see bioconda recipes follow this structure:
- Jinja2 variables at top
- package/source/build/requirements/test/about sections
- Current practice: use pip install for Python packages
- sha256 checksums required
Should I look at any specific type of recipe (Python/R/compiled)?"
```

### Example 2: Learning VGP pipeline orchestration
```bash
# Step 1: Identify type
ls *.py
# Output: run_all.py, orchestrator.py -> Monolithic application

# Step 2: Read entry point
Read: run_all.py

# Step 3: Find core components
grep "^from batch_vgp_run import" run_all.py
# Shows: orchestrator, galaxy_client, workflow_manager

# Step 4: Read core orchestrator
Read: batch_vgp_run/orchestrator.py  # Full file to understand flow

# Step 5: Read supporting modules selectively
grep "def run_species_workflows" batch_vgp_run/orchestrator.py -A 5
Read: batch_vgp_run/galaxy_client.py  # Key helper functions
```

### Example 3: Learning Galaxy workflow patterns
```bash
# Step 1: Identify type
ls -d */  # Shows category directories
# Output: transcriptomics/, genome-assembly/, etc. -> Example collection

# Step 2: Read guidelines
Read: .github/CONTRIBUTING.md

# Step 3: Pick representative workflows
ls -lt transcriptomics/  # Recent workflows
Read: transcriptomics/recent-workflow/workflow.ga
Read: transcriptomics/recent-workflow/README.md

# Step 4: Compare with another category
Read: genome-assembly/example-workflow/workflow.ga

# Step 5: Extract common patterns
grep -r "\"format-version\"" . | head -5
grep -r "\"creator\"" . | head -5
```

---

## Task Tool Token Savings

**Inefficient approach (many tool calls, large context)**:
```python
# Direct grep through many files
Grep(pattern="some_pattern", path=".", output_mode="content")
# Followed by multiple Read calls to understand context
Read("file1.py")
Read("file2.py")
# Followed by more Grep calls for related patterns
Grep(pattern="related_pattern", path=".", output_mode="content")
# Results in dozens of tool calls and accumulating context
```

**Efficient approach (single consolidated response)**:
```python
# Use Task tool with Explore subagent
Task(
    subagent_type="Explore",
    description="Research how Galaxy API works",
    prompt="""Explore the codebase to understand how Galaxy API calls are made.
    I need to know:
    - Which files contain API call patterns
    - How authentication is handled
    - Common error handling patterns
    Return a summary with file locations and key patterns."""
)
```

**Token savings**:
- Task tool: ~5-10K tokens for consolidated response
- Direct exploration: ~30-50K tokens (many tool calls + context accumulation)
- **Savings: 70-80%** for exploratory searches

**Example comparison**:

```python
# Inefficient: Exploring workflow patterns manually
Grep("workflow", output_mode="content")  # 15K tokens
Read("workflow1.py")  # 20K tokens
Read("workflow2.py")  # 18K tokens
Grep("error handling", output_mode="content")  # 12K tokens
# Total: ~65K tokens

# Efficient: Using Task tool
Task(
    subagent_type="Explore",
    description="Understand workflow error handling",
    prompt="Explore how workflows handle errors. Return patterns and file locations."
)
# Total: ~8K tokens (single consolidated response)
# Savings: 88%
```
