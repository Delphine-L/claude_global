---
name: token-efficiency
description: Token optimization best practices for cost-effective Claude Code usage. Automatically applies efficient file reading, command execution, and output handling strategies. Includes model selection guidance (Opus for learning, Sonnet for development/debugging). Prefers bash commands over reading files.
version: 1.4.0
---

# Token Efficiency Expert

This skill provides token optimization strategies for cost-effective Claude Code usage across all projects. These guidelines help minimize token consumption while maintaining high-quality assistance.

## Core Principle

**ALWAYS follow these optimization guidelines by default unless the user explicitly requests verbose output or full file contents.**

Default assumption: **Users prefer efficient, cost-effective assistance.**

---

## Model Selection Strategy

**Use the right model for the task to optimize cost and performance:**

### Opus - For Learning and Deep Understanding

**Use Opus when:**
- 🎓 **Learning new codebases** - Understanding architecture, code structure, design patterns
- 📚 **Broad exploration** - Identifying key files, understanding repository organization
- 🔍 **Deep analysis** - Analyzing complex algorithms, performance optimization
- 📖 **Reading and understanding** - When you need to comprehend existing code before making changes
- 🧠 **Very complex debugging** - Only when Sonnet can't solve it or issue is architectural

**Why Opus:** More powerful reasoning for understanding complex systems and relationships

**Example prompts:**
```
"Use Opus to understand the architecture of this codebase"
"Switch to Opus - I need help understanding how this component works"
"Use Opus for this deep dive into the authentication system"
```

### Sonnet - For Regular Development Tasks (DEFAULT)

**Use Sonnet (default) for:**
- ✏️ **Writing code** - Creating new files, implementing features
- 🔧 **Editing and fixing** - Updating configurations, fixing bugs
- 🐛 **Debugging** - Standard debugging, error analysis, troubleshooting (use Sonnet unless very complex)
- 🧪 **Testing** - Writing tests, running test suites
- 📝 **Documentation** - Writing READMEs, comments, docstrings
- 🚀 **Deployment tasks** - Running builds, deploying code
- 💬 **General questions** - Quick clarifications, simple explanations

**Why Sonnet:** Faster and more cost-effective for straightforward tasks, handles most debugging well

**Example workflow:**
```
1. [Opus] Learn codebase structure and identify key components (one-time)
2. [Sonnet] Implement the feature based on understanding
3. [Sonnet] Debug and fix issues as they arise
4. [Sonnet] Write tests and documentation
5. [Opus] Only if stuck on architectural or very complex issues
6. [Sonnet] Final cleanup and deployment
```

### Cost Optimization Strategy

**Typical session pattern:**
1. **Start with Opus** - Spend 10-15 minutes understanding the codebase (one-time investment)
2. **Switch to Sonnet** - Use for ALL implementation, debugging, and routine work
3. **Return to Opus** - Only when explicitly needed for deep architectural understanding

**Savings example:**
- 2 hours of work = 120 minutes
- Opus for learning: 15 minutes (~5K tokens)
- Sonnet for everything else: 105 minutes (~15K tokens)
- **vs all Opus: ~40K tokens**
- **Savings: ~50% token cost**

**Remember:** Sonnet is very capable - use it by default, including for debugging. Only escalate to Opus when the problem requires deep architectural insight.

---

## Skills and Token Efficiency

### Common Misconception

**Myth:** Having many skills in `.claude/skills/` increases token usage.

**Reality:** Skills use **progressive disclosure** - Claude loads them intelligently:

1. **At session start**: Claude sees only skill **descriptions** (minimal tokens)
2. **When activated**: Full skill content loaded only for skills being used
3. **Unused skills**: Consume almost no tokens (just the description line)

### Example Token Usage

```
.claude/skills/
├── vgp-pipeline/          # ~50 tokens (description only)
├── galaxy-tool-wrapping/  # ~40 tokens (description only)
├── token-efficiency/      # ~30 tokens (description only)
└── python-testing/        # ~35 tokens (description only)
```

**Total overhead**: ~155 tokens for 4 skills (just descriptions)

**When skill activated**: Additional 2,000-5,000 tokens loaded for that specific skill

### Implication for Centralized Skills

**It's safe to symlink multiple skills to a project!**

- Link 10+ skills from `$CLAUDE_METADATA` → only ~500 tokens overhead
- Only activate skills you need by mentioning them by name
- Example: "Use the vgp-pipeline skill to check status" → loads only that skill

**Best practice:**
```bash
# Link all potentially useful skills
ln -s $CLAUDE_METADATA/skills/vgp-pipeline .claude/skills/vgp-pipeline
ln -s $CLAUDE_METADATA/skills/galaxy-tool-wrapping .claude/skills/galaxy-tool-wrapping
ln -s $CLAUDE_METADATA/skills/python-testing .claude/skills/python-testing

# Activate selectively during session
"Use the vgp-pipeline skill to debug this workflow"  # Only VGP skill fully loaded
```

**Token waste comes from:**
- ❌ Reading large log files unnecessarily
- ❌ Running verbose commands
- ❌ Reading unchanged files multiple times

**NOT from:**
- ✅ Having many skills available
- ✅ Well-organized skill directories
- ✅ Using centralized skill repositories

---

## Token Optimization Rules

### 1. Use Quiet/Minimal Output Modes

**For commands with `--quiet`, `--silent`, or `-q` flags:**

```bash
# ❌ DON'T: Use verbose mode by default
command --verbose

# ✅ DO: Use quiet mode by default
command --quiet
command -q
command --silent
```

**Common commands with quiet modes:**
- `grep -q` (quiet, exit status only)
- `git --quiet` or `git -q`
- `curl -s` or `curl --silent`
- `wget -q`
- `make -s` (silent)
- Custom scripts with `--quiet` flags

**When to use verbose:** Only when user explicitly asks for detailed output.

---

### 2. NEVER Read Entire Log Files

**Log files can be 50-200K tokens. ALWAYS filter before reading.**

```bash
# ❌ NEVER DO THIS:
Read: /var/log/application.log
Read: debug.log
Read: error.log

# ✅ ALWAYS DO ONE OF THESE:

# Option 1: Read only the end (most recent)
Bash: tail -100 /var/log/application.log

# Option 2: Filter for errors/warnings
Bash: grep -A 10 -i "error\|fail\|warning" /var/log/application.log | head -100

# Option 3: Specific time range (if timestamps present)
Bash: grep "2025-01-15" /var/log/application.log | tail -50

# Option 4: Count occurrences first
Bash: grep -c "ERROR" /var/log/application.log  # See if there are many errors
Bash: grep "ERROR" /var/log/application.log | tail -20  # Then read recent ones
```

**Exceptions:** Only read full log if:
- User explicitly says "read the full log"
- Filtered output lacks necessary context
- Log is known to be small (<1000 lines)

---

### 3. Check Lightweight Sources First

**Before reading large files, check if info is available in smaller sources:**

**For Git repositories:**
```bash
# ✅ Check status first (small output)
Bash: git status --short
Bash: git log --oneline -10

# ❌ Don't immediately read
Read: .git/logs/HEAD  # Can be large
```

**For Python/Node projects:**
```bash
# ✅ Check package info (small files)
Bash: cat package.json | jq '.dependencies'
Bash: cat requirements.txt | head -20

# ❌ Don't immediately read
Read: node_modules/  # Huge directory
Read: venv/  # Large virtual environment
```

**For long-running processes:**
```bash
# ✅ Check process status
Bash: ps aux | grep python
Bash: top -b -n 1 | head -20

# ❌ Don't read full logs immediately
Read: /var/log/syslog
```

---

### 4. Use Grep Instead of Reading Files

**When searching for specific content:**

```bash
# ❌ DON'T: Read file then manually search
Read: large_file.py  # 30K tokens
# Then manually look for "def my_function"

# ✅ DO: Use Grep to find it
Grep: "def my_function" large_file.py
# Then only read relevant sections if needed
```

**Advanced grep usage:**
```bash
# Find with context
Bash: grep -A 5 -B 5 "pattern" file.py  # 5 lines before/after

# Case-insensitive search
Bash: grep -i "error" logfile.txt

# Recursive search in directory
Bash: grep -r "TODO" src/ | head -20

# Count matches
Bash: grep -c "import" *.py
```

---

### 4.5. Safe Glob Patterns (Avoiding Syntax Errors)

**Problem**: This pattern fails when no files match:
```bash
# ❌ WRONG - causes syntax error if no *.md files
for file in *.md 2>/dev/null; do
    cp "$file" backup/
done
```

**Error**: `syntax error near unexpected token '2'`

**Solution**: Use `nullglob` shell option:
```bash
# ✅ CORRECT - safely handles no matches
shopt -s nullglob
for pattern in "*.md" "*.sh" "*.txt"; do
    for file in $pattern; do
        cp "$file" backup/
    done
done
shopt -u nullglob  # Restore default behavior
```

**Why This Works**:
- `nullglob`: If glob pattern matches nothing, expand to empty string (no error)
- `shopt -u nullglob`: Turn it back off after use (prevent side effects)

**Alternative - Explicit Check**:
```bash
if ls *.md 1> /dev/null 2>&1; then
    for file in *.md; do
        cp "$file" backup/
    done
fi
```

**When to Use Each**:
- **nullglob**: Multiple patterns in loop
- **Explicit check**: Single pattern, need confirmation files exist

---

### 5. Read Files with Limits

**If you must read a file, use offset and limit parameters:**

```bash
# ✅ Read first 100 lines to understand structure
Read: large_file.py (limit: 100)

# ✅ Read specific section
Read: large_file.py (offset: 500, limit: 100)

# ✅ Read just the imports/header
Read: script.py (limit: 50)
```

**For very large files:**
```bash
# Check file size first
Bash: wc -l large_file.txt
# Output: 50000 lines

# Then read strategically
Bash: head -100 large_file.txt  # Beginning
Bash: tail -100 large_file.txt  # End
Bash: sed -n '1000,1100p' large_file.txt  # Specific middle section
```

**Reading Large Test Output Files:**

For Galaxy `tool_test_output.json` files (can be 30K+ lines):

```python
# Read summary first (top of file)
Read(file_path, limit=10)  # Just get summary section

# Then read specific test results
Read(file_path, offset=140, limit=120)  # Target specific test

# Search for patterns
Bash("grep -n 'test_index' tool_test_output.json")  # Find test boundaries
```

**Token savings:**
- Full file: ~60K tokens
- Targeted reads: ~5K tokens
- **Savings: 55K tokens (92%)**

---

### 6. Use Bash Commands Instead of Reading Files

**CRITICAL OPTIMIZATION:** For file operations, use bash commands directly instead of reading files into Claude's context.

**Reading files costs tokens. Bash commands don't.**

#### Copy File Contents

```bash
# ❌ DON'T: Read and write (costs tokens for file content)
Read: source_file.txt
Write: destination_file.txt (with content from source_file.txt)

# ✅ DO: Use cp command (zero token cost for file content)
Bash: cp source_file.txt destination_file.txt
```

**Token savings: 100% of file content**

#### Replace Text in Files

```bash
# ❌ DON'T: Read, edit, write (costs tokens for entire file)
Read: config.yaml
Edit: config.yaml (old_string: "old_value", new_string: "new_value")

# ✅ DO: Use sed in-place (zero token cost for file content)
Bash: sed -i '' 's/old_value/new_value/g' config.yaml
# or
Bash: sed -i.bak 's/old_value/new_value/g' config.yaml  # with backup

# For literal strings with special characters
Bash: sed -i '' 's|old/path|new/path|g' config.yaml  # Use | as delimiter
```

**Token savings: 100% of file content**

**macOS vs Linux compatibility:**
```bash
# macOS (BSD sed) - requires empty string after -i
sed -i '' 's/old/new/g' file.txt

# Linux (GNU sed) - no argument needed
sed -i 's/old/new/g' file.txt

# Cross-platform solution (works everywhere):
sed -i.bak 's/old/new/g' file.txt && rm file.txt.bak
# OR detect OS:
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/old/new/g' file.txt
else
    sed -i 's/old/new/g' file.txt
fi

# Portable alternative (no -i flag):
sed 's/old/new/g' file.txt > file.tmp && mv file.tmp file.txt
```

**Why this matters:** Scripts using `sed -i` will fail on macOS with cryptic errors like "can't read /pattern/..." if the empty string is omitted. Always use `sed -i ''` for macOS compatibility or `sed -i.bak` for cross-platform safety.

#### Append to Files

```bash
# ❌ DON'T: Read and write entire file
Read: log.txt
Write: log.txt (with existing content + new line)

# ✅ DO: Use echo or append
Bash: echo "New log entry" >> log.txt
Bash: cat >> log.txt << 'EOF'
Multiple lines
of content
EOF
```

**Token savings: 100% of existing file content**

#### Delete Lines from Files

```bash
# ❌ DON'T: Read, filter, write
Read: data.txt
Write: data.txt (without lines containing "DELETE")

# ✅ DO: Use sed or grep
Bash: sed -i '' '/DELETE/d' data.txt
# or
Bash: grep -v "DELETE" data.txt > data_temp.txt && mv data_temp.txt data.txt
```

#### Extract Specific Lines

```bash
# ❌ DON'T: Read entire file to get a few lines
Read: large_file.txt (find lines 100-110)

# ✅ DO: Use sed or awk
Bash: sed -n '100,110p' large_file.txt
Bash: awk 'NR>=100 && NR<=110' large_file.txt
Bash: head -110 large_file.txt | tail -11
```

#### Rename Files in Bulk

```bash
# ❌ DON'T: Read directory, loop in Claude, execute renames
Read directory listing...
For each file: mv old_name new_name

# ✅ DO: Use bash loop or rename command
Bash: for f in *.txt; do mv "$f" "${f%.txt}.md"; done
Bash: rename 's/\.txt$/.md/' *.txt  # if rename command available
```

#### Merge Files

```bash
# ❌ DON'T: Read multiple files and write combined
Read: file1.txt
Read: file2.txt
Write: combined.txt

# ✅ DO: Use cat
Bash: cat file1.txt file2.txt > combined.txt
# or append
Bash: cat file2.txt >> file1.txt
```

#### Count Lines/Words/Characters

```bash
# ❌ DON'T: Read file to count
Read: document.txt
# Then count lines manually

# ✅ DO: Use wc
Bash: wc -l document.txt  # Lines
Bash: wc -w document.txt  # Words
Bash: wc -c document.txt  # Characters
```

#### Check if File Contains Text

```bash
# ❌ DON'T: Read file to search
Read: config.yaml
# Then search for text

# ✅ DO: Use grep with exit code
Bash: grep -q "search_term" config.yaml && echo "Found" || echo "Not found"
# or just check exit code
Bash: grep -q "search_term" config.yaml  # Exit 0 if found, 1 if not
```

#### Sort File Contents

```bash
# ❌ DON'T: Read, sort in memory, write
Read: unsorted.txt
Write: sorted.txt (with sorted content)

# ✅ DO: Use sort command
Bash: sort unsorted.txt > sorted.txt
Bash: sort -u unsorted.txt > sorted_unique.txt  # Unique sorted
Bash: sort -n numbers.txt > sorted_numbers.txt  # Numeric sort
```

#### Remove Duplicate Lines

```bash
# ❌ DON'T: Read and deduplicate manually
Read: file_with_dupes.txt
Write: file_no_dupes.txt

# ✅ DO: Use sort -u or uniq
Bash: sort -u file_with_dupes.txt > file_no_dupes.txt
# or preserve order
Bash: awk '!seen[$0]++' file_with_dupes.txt > file_no_dupes.txt
```

#### Find and Replace Across Multiple Files

```bash
# ❌ DON'T: Read each file, edit, write back
Read: file1.py
Edit: file1.py (replace text)
Read: file2.py
Edit: file2.py (replace text)
# ... repeat for many files

# ✅ DO: Use sed with find or loop
Bash: find . -name "*.py" -exec sed -i '' 's/old_text/new_text/g' {} +
# or
Bash: for f in *.py; do sed -i '' 's/old_text/new_text/g' "$f"; done
```

#### Create File with Template Content

```bash
# ❌ DON'T: Use Write tool for static content
Write: template.txt (with multi-line template)

# ✅ DO: Use heredoc or echo
Bash: cat > template.txt << 'EOF'
Multi-line
template
content
EOF

# or for simple content
Bash: echo "Single line content" > file.txt
```

#### When to Break These Rules

**Still use Read/Edit/Write when:**
1. **Complex logic required**: Conditional edits based on file structure
2. **Code-aware changes**: Editing within functions, preserving indentation
3. **Validation needed**: Need to verify content before changing
4. **Interactive review**: User needs to see content before approving changes
5. **Multi-step analysis**: Need to understand code structure first
6. **Creating new content**: Use Write tool directly for new files with known content
7. **Low-cost operations**: Directory listings, small file reads (< 100 lines)

**Use Write tool directly (not bash scripts) when:**
```python
# ✅ CORRECT: Creating new file with structured content
Write: /path/to/new-file.md
# Content here...

# ❌ OVER-ENGINEERED: Wrapping in Python/bash for no reason
Bash: python3 << 'EOF'
with open('/path/to/new-file.md', 'w') as f:
    f.write('Content here...')
EOF
```

**Use Claude's context for low-cost operations:**
```bash
# ✅ FINE: Simple directory listing (10-20 lines)
ls -la

# ✅ FINE: Read and edit small files (< 100 lines)
Read: config.yaml  # 50 lines
Edit: config.yaml  # Changes are clear and visible

# ❌ WASTEFUL: Large log files, huge directories
Read: /var/log/app.log  # 50K lines
ls -laR /  # Entire filesystem
```

**Use bash + logging for critical data files:**
```bash
# ✅ CORRECT: Modifying genome statistics table
LOG_FILE="genome_stats_modifications.log"
echo "sed -i '' 's/NA/0/g' genome_stats.csv" >> "$LOG_FILE"
sed -i '' 's/NA/0/g' genome_stats.csv

# The log file tracks all operations for reproducibility
# genome_stats_modifications.log:
# sed -i '' 's/NA/0/g' genome_stats.csv
# awk '{if ($5 != "") print}' genome_stats.csv > genome_stats_filtered.csv
```

**Example where Read/Edit is better:**
```python
# Code files: Always use Read/Edit to understand context
Read: module.py
Edit: module.py (update specific function while preserving structure)

# Small data files: Changes are visible
Read: config.yaml
Edit: config.yaml (update configuration value)
```

**Example where bash is better:**
```bash
# Large data files: Efficient text replacement
Bash: sed -i '' 's/old_value/new_value/g' large_dataset.csv

# Critical data files: Log operations for auditability
Bash: echo "sed -i '' 's/NA/0/g' genome_stats.csv" >> data_modifications.log
Bash: sed -i '' 's/NA/0/g' genome_stats.csv
```

**Example where Write is better:**
```python
# Creating new documentation file
Write: docs/new-guide.md
# Full content...
# (Not wrapped in bash/Python script)
```

#### Jupyter Notebook Manipulation Without nbformat

**Problem**: nbformat may not be available in all environments, requiring conda/pip install

**Solution**: Use Python's built-in json module for notebook manipulation

```python
# ✅ EFFICIENT: Use json module (no dependencies)
import json

# Read notebook
with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)

# Manipulate cells
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        source = ''.join(cell['source'])
        # Modify source (e.g., fix paths)
        source = source.replace('old/path/', 'new/path/')
        cell['source'] = source.split('\n')

# Write back
with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=1)
```

```python
# ❌ WASTEFUL: Requires nbformat installation and dependencies
import nbformat

nb = nbformat.read('notebook.ipynb', as_version=4)
# Manipulate...
nbformat.write(nb, 'notebook.ipynb')
```

**When to use each approach:**

| Task | json module | nbformat |
|------|-------------|----------|
| Path verification | ✅ Preferred | ❌ Overkill |
| Source code modifications | ✅ Preferred | ❌ Overkill |
| Simple cell edits | ✅ Preferred | ❌ Overkill |
| Cell execution | ❌ Can't do | ✅ Required |
| Format migration (v3→v4) | ❌ Can't do | ✅ Required |
| Metadata validation | ❌ Limited | ✅ Better |

**Benefits of json approach:**
- No external dependencies
- More portable across environments
- Faster (no parsing overhead)
- Direct access to notebook structure
- Fewer tokens (no module import errors)

**Example: Path verification in notebooks**
```python
import json
import os

with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)

for cell_idx, cell in enumerate(nb['cells']):
    if cell['cell_type'] == 'code':
        source = ''.join(cell['source'])
        # Check for broken paths
        if 'read_csv(' in source:
            print(f"Cell {cell_idx}: Found data loading")
```

**Token savings**: Avoids "ModuleNotFoundError" and environment setup discussions

#### Token Savings Examples

**Example 1: Update 10 config files**

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

**Example 2: Copy configuration**

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

**Example 3: Append log entry**

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

#### Find CSV Column Indices

```bash
# ❌ DON'T: Read entire CSV file to find column numbers
Read: large_table.csv (100+ columns, thousands of rows)
# Then manually count columns

# ✅ DO: Extract and number header row
Bash: head -1 file.csv | tr ',' '\n' | nl

# ✅ DO: Find specific columns by pattern
Bash: head -1 VGP-table.csv | tr ',' '\n' | nl | grep -i "chrom"
# Output shows column numbers and names:
#  54 num_chromosomes
# 106 total_number_of_chromosomes
# 122 num_chromosomes_haploid
```

**How it works:**
- `head -1`: Get header row only
- `tr ',' '\n'`: Convert comma-separated to newlines
- `nl`: Number the lines (gives column index)
- `grep -i`: Filter by pattern (case-insensitive)

**Use case**: Quickly identify which columns contain needed data in wide tables (100+ columns).

**Token savings: 100% of file content** - Only see column headers, not data rows.

#### Python Data Filtering Pattern

```bash
# ✅ Create separate filtered files rather than overwriting
# Read original
species_data = []
with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        if row['accession'] and row['chromosome_count']:  # Filter criteria
            species_data.append(row)

# Write to NEW file with descriptive suffix
output_file = 'data_filtered.csv'  # Not 'data.csv'
with open(output_file, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=reader.fieldnames)
    writer.writeheader()
    writer.writerows(species_data)
```

**Benefits:**
- Preserves original data for comparison
- Clear naming indicates filtering applied
- Can generate multiple filtered versions
- Easier to debug and verify filtering logic

#### Handling Shell Aliases in Python Scripts

**Problem**: Python's `subprocess.run()` doesn't expand shell aliases.

```python
# ❌ FAILS if 'datasets' is an alias
subprocess.run(['datasets', 'summary', ...])
# Error: [Errno 2] No such file or directory: 'datasets'
```

**Solution**: Use full path to executable

```bash
# Find full path
type -a datasets
# Output: datasets is an alias for ~/Workdir/ncbi_tests/datasets

echo ~/Workdir/ncbi_tests/datasets  # Expand ~
# Output: /path/to/ncbi_tests/datasets
```

```python
# Use full path in script
datasets_cmd = '/path/to/ncbi_tests/datasets'
subprocess.run([datasets_cmd, 'summary', ...])
```

**Alternative**: Use `shell=True` (but avoid for security reasons with user input)

---

### Key Principle for File Operations

**The Right Tool for the Job:**

**For creating NEW files with known content:**
- ✅ Use **Write tool** directly
- ❌ Don't wrap in bash/Python scripts

**For modifying EXISTING files:**
- **Code files** → Always use **Read + Edit** (need to understand structure, preserve formatting)
- **Small data files** (< 100 lines) → Read + Edit is fine (changes are visible)
- **Large data files** → Use **bash commands** (`sed`, `awk`, `grep`) for efficiency
- **Critical data files** (genome stats, enriched tables) → Use **bash commands + log file** for auditability

**For understanding or complex edits:**
- ✅ Use **Read + Edit tools**
- ❌ Don't try to do complex logic in sed/awk

**Decision tree:**
1. **Creating new file?** → Use Write tool
2. **Modifying code file?** → Use Read + Edit (always)
3. **Modifying small data file** (< 100 lines)? → Read + Edit is fine
4. **Modifying critical data file?** → Use sed/awk + log commands
5. **Modifying large data file?** → Use sed/awk
6. **Copying/moving files?** → Use cp/mv
7. **Low-cost operation (< 100 lines output)?** → Use Claude context directly

**Ask yourself:**
1. Am I creating a new file? → Write tool
2. Is this a code file (.py, .js, .xml, etc.)? → Read + Edit
3. Is this a small data file (< 100 lines)? → Read + Edit is fine
4. Is this critical data (genome stats, enriched tables)? → bash + log file
5. Is this a large data file? → sed/awk

**Logging pattern for critical data operations:**
```bash
# When modifying critical data files, log all operations
LOG_FILE="data_modifications.log"

# Pattern: Log command before execution
echo "sed -i '' 's/old_value/new_value/g' genome_stats.csv" >> "$LOG_FILE"
sed -i '' 's/old_value/new_value/g' genome_stats.csv

# Or use tee to log and execute
echo "awk '{if (NR==1 || \$3 > 100) print}' data.csv > filtered.csv" | tee -a "$LOG_FILE"
awk '{if (NR==1 || $3 > 100) print}' data.csv > filtered.csv

# Create log if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo "# Data modification log - $(date)" > "$LOG_FILE"
fi
```

**Log file format (simple, just commands):**
```bash
# genome_stats_modifications.log
sed -i '' 's/NA/0/g' genome_stats.csv
awk '{if ($5 != "") print}' genome_stats.csv > genome_stats_filtered.csv
sed -i '' 's/Chromosome/Chr/g' genome_stats.csv
```

---

### 7. Filter Command Output

**For commands that produce large output:**

```bash
# ❌ DON'T: Capture all output
Bash: find / -name "*.py"  # Could return 10,000+ files

# ✅ DO: Limit or filter output
Bash: find /specific/path -name "*.py" | head -50
Bash: find . -name "*.py" -type f | wc -l  # Count first
Bash: find . -name "*.py" -type f | grep "test" | head -20  # Filter

# ❌ DON'T: Run verbose commands without filtering
Bash: ls -laR /  # Recursive listing of entire filesystem!

# ✅ DO: Limit scope and depth
Bash: ls -la
Bash: find . -maxdepth 2 -type f
Bash: tree -L 2  # Limit tree depth
```

---

### 7. Summarize, Don't Dump

**When explaining command output or file contents:**

```
User: "What's in this directory?"

❌ BAD RESPONSE:
[Paste entire 5K token ls -la output with 500 files]

✅ GOOD RESPONSE:
"This directory contains 487 files. Key items:
- 235 Python files (*.py)
- 142 test files in tests/
- 89 config files (*.yaml, *.json)
- Main entry point: main.py
- Documentation in docs/

Would you like to see specific files or file types?"
```

**For code:**
```
User: "What does this script do?"

❌ BAD: [Read entire 500-line file, paste all code]

✅ GOOD:
1. Read: script.py (limit: 50)  # Just the header/imports
2. Grep: "^def " script.py  # List all functions
3. Summarize: "This script has 5 main functions:
   - parse_args(): Command-line argument parsing
   - load_data(): Reads CSV files
   - process_data(): Applies transformations
   - validate_output(): Checks results
   - main(): Orchestrates the workflow

   Would you like details on any specific function?"
```

---

### 8. Use Head/Tail for Large Output

**When commands produce large output:**

```bash
# ✅ Limit output length
Bash: cat large_file.txt | head -100
Bash: cat large_file.txt | tail -100
Bash: docker logs container_name | tail -50

# ✅ Sample from middle
Bash: cat large_file.txt | head -500 | tail -100  # Lines 400-500

# ✅ Check size before reading
Bash: wc -l file.txt
# If > 1000 lines, use head/tail
```

---

### 9. Use JSON/Data Tools Efficiently

**For JSON, YAML, XML files:**

```bash
# ❌ DON'T: Read entire file
Read: large_config.json  # Could be 50K tokens

# ✅ DO: Extract specific fields
Bash: cat large_config.json | jq '.metadata'
Bash: cat large_config.json | jq 'keys'  # Just see top-level keys
Bash: cat config.yaml | yq '.database.host'

# For XML
Bash: xmllint --xpath '//database/host' config.xml
```

**For CSV files:**
```bash
# ❌ DON'T: Read entire CSV
Read: large_data.csv  # Could be millions of rows

# ✅ DO: Sample and analyze
Bash: head -20 large_data.csv  # See header and sample rows
Bash: wc -l large_data.csv  # Count rows
Bash: csvstat large_data.csv  # Get statistics (if csvkit installed)
```

---

### 10. Optimize Code Reading

**For understanding codebases:**

```bash
# ✅ STEP 1: Get overview
Bash: find . -name "*.py" | head -20  # List files
Bash: grep -r "^class " --include="*.py" | head -20  # List classes
Bash: grep -r "^def " --include="*.py" | wc -l  # Count functions

# ✅ STEP 2: Read structure only
Read: main.py (limit: 100)  # Just imports and main structure

# ✅ STEP 3: Search for specific code
Grep: "class MyClass" src/

# ✅ STEP 4: Read only relevant sections
Read: src/mymodule.py (offset: 150, limit: 50)  # Just the relevant class

# ❌ DON'T: Read entire files sequentially
Read: file1.py  # 30K tokens
Read: file2.py  # 30K tokens
Read: file3.py  # 30K tokens
```

---

### 11. Use Task Tool for Exploratory Searches

When exploring a codebase to understand patterns or find information (not needle queries for specific files):

**❌ Inefficient approach (many tool calls, large context)**:
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

**✅ Efficient approach (single consolidated response)**:
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

**When to use Task/Explore**:
- "How does X work in this codebase?"
- "Where are errors from Y handled?"
- "What is the structure of Z?"
- Searching for patterns across multiple files
- Need context from multiple locations
- Exploring unfamiliar codebases

**When to use direct tools instead**:
- "Read file at specific path X" → Use `Read`
- "Find class definition Foo" → Use `Glob("**/foo.py")` or `Grep("class Foo")`
- "Search for specific string in file X" → Use `Grep(pattern, path="file.py")`
- You know exactly which file to check

**Token savings**:
- Task tool: ~5-10K tokens for consolidated response
- Direct exploration: ~30-50K tokens (many tool calls + context accumulation)
- **Savings: 70-80%** for exploratory searches

**Example comparison**:

```python
# ❌ Inefficient: Exploring workflow patterns manually
Grep("workflow", output_mode="content")  # 15K tokens
Read("workflow1.py")  # 20K tokens
Read("workflow2.py")  # 18K tokens
Grep("error handling", output_mode="content")  # 12K tokens
# Total: ~65K tokens

# ✅ Efficient: Using Task tool
Task(
    subagent_type="Explore",
    description="Understand workflow error handling",
    prompt="Explore how workflows handle errors. Return patterns and file locations."
)
# Total: ~8K tokens (single consolidated response)
# Savings: 88%
```

---

### 12. Efficient Scientific Literature Searches

When searching for data across multiple species (karyotypes, traits, etc.):

**❌ Inefficient**: Sequential searches
```python
for species in species_list:
    search(species)  # One at a time
```

**✅ Efficient**: Parallel searches in batches
```python
# Make 5 searches simultaneously
WebSearch("species1 karyotype")
WebSearch("species2 karyotype")
WebSearch("species3 karyotype")
WebSearch("species4 karyotype")
WebSearch("species5 karyotype")
```

**Benefits**:
- 5x faster for user
- Same token usage per search
- Better user experience
- Allows quick progress saves before session limits

**Best practices**:
- Batch 3-5 related searches together
- Group by taxonomy or data type
- Save results immediately after each batch
- Document "not found" species to avoid re-searching

### Dealing with Session Interruptions

When user warns about daily limits:

1. **Immediately save progress**:
   - Write findings to file
   - Update CSV/database with confirmed data
   - Create detailed progress document

2. **Document search status**:
   - Which species searched
   - Which confirmed/not found
   - Which remain to search
   - Next steps with priority order

3. **Create resume file** with:
   - Current totals
   - Completed work
   - Pending tasks with priorities
   - Recommendations for next session

**Example**: `PROGRESS_YYYYMMDD.md` file with clear resumption instructions

### Search Term Iteration

When initial searches fail, refine systematically:

1. **First try**: Specific scientific terms
   - "Anas acuta karyotype 2n"

2. **Second try**: Common name + scientific
   - "northern pintail Anas acuta chromosome number"

3. **Third try**: Genus-level patterns
   - "Anas genus karyotype waterfowl"

4. **Fourth try**: Family-level studies
   - "Anatidae chromosome evolution cytogenetics"

**Don't**: Keep searching the same terms repeatedly
**Do**: Escalate to higher taxonomic levels or comparative studies

---

## Token Savings Examples

### Example 1: Status Check
**Scenario:** User asks "What's the status of my application?"

**❌ Wasteful approach (50K tokens):**
```bash
Read: /var/log/app.log  # 40K tokens
Bash: systemctl status myapp  # 10K tokens
```

**✅ Efficient approach (3K tokens):**
```bash
Bash: systemctl status myapp --no-pager | head -20  # 1K tokens
Bash: tail -50 /var/log/app.log  # 2K tokens
```
**Savings: 94%**

---

### Example 2: Debugging Errors
**Scenario:** User says "My script is failing, help debug"

**❌ Wasteful approach (200K tokens):**
```bash
Read: debug.log  # 150K tokens
Read: script.py  # 30K tokens
Read: config.json  # 20K tokens
```

**✅ Efficient approach (8K tokens):**
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

**❌ Wasteful approach (500K tokens):**
```bash
Read: file1.py
Read: file2.py
Read: file3.py
Read: file4.py
# ... reads 20+ files
```

**✅ Efficient approach (20K tokens):**
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

## Analysis File Organization (Iteration 2)

### Problem
Large Jupyter notebooks (4+ MB) consume excessive tokens when loaded for context:
- Full notebook: ~1,135,000 tokens
- Even with selective reading, difficult to load just figure analysis

### Solution: Separate Analysis Files

Create `analysis_files/` directory with individual markdown files for each analysis component:

```
project/
├── analysis_files/
│   ├── MANIFEST.md
│   ├── Method.md
│   └── figures/
│       ├── 01_figure_name.md
│       ├── 02_figure_name.md
│       └── ...
├── notebooks/ (keep for code execution)
└── figures/ (actual PNG/PDF files)
```

**Token Savings**:
- Before: ~1,135,000 tokens (full notebooks)
- After: ~22,000 tokens (analysis files)
- **Savings: 98% reduction**

### What to Include in Analysis Files

Each figure analysis file should contain **only publication-ready text**:
- Figure description (formatted as figure legend)
- Analysis framework and interpretation
- Statistical methods and results
- Mechanistic explanations
- Context from other metrics
- Biological/technical considerations

**DO NOT include**:
- TODOs or placeholders
- Draft notes or scratch work
- Code or computational details
- Incomplete sections

### Managing TODOs Separately

Track analysis TODOs in your note-taking system (Obsidian, etc.), not in the analysis files:

**Obsidian TODO note example**:
```markdown
# Figure Analysis TODOs

## Figure 1: Scaffold N50
- [ ] Run Kruskal-Wallis test
- [ ] Get sample sizes for each category
- [ ] Fill in p-values
- [ ] Write interpretation

## Figure 2: Gap Density
- [ ] Calculate gap density metric
- [ ] Run statistical comparisons
...
```

**Analysis file stays clean**:
```markdown
# Figure 1: Scaffold N50 Analysis

## Figure Description
[Publication-ready description]

## Analysis
[Complete, polished analysis text]
```

### Benefits

1. **Modular loading**: Load only the figure(s) being worked on
2. **Publication-ready**: Text can go directly into manuscript
3. **Easy maintenance**: Update individual analyses without touching notebooks
4. **Collaborative**: Easier to review/edit specific sections
5. **Notebook simplification**: Final notebook becomes just TOC + links to analysis files

### Implementation Pattern

1. Read existing notebook and paper draft to understand style
2. Create clean analysis files matching that style
3. Track TODOs separately in Obsidian/notes
4. Link figures MANIFEST to analysis files
5. Update root MANIFEST to reference analysis_files/

### Usage in Claude Sessions

**Load specific analysis (~5-10 KB)**:
```bash
cat analysis_files/figures/02_scaffold_consolidation.md
```

**Instead of full notebook (~4,200 KB)**:
```bash
cat Curation_Analysis_3Categories.ipynb  # Avoid this!
```

### Integration with Notebooks

**Future workflow**: Create streamlined manuscript notebook that:
- Contains only TOC, intro, conclusions
- Displays figures: `![Figure 1](figures/01_name.png)`
- Links to analysis files for text content
- Executes minimal code for figure generation only

---

## When to Override These Guidelines

**Override efficiency rules when:**

1. **User explicitly requests full output:**
   - "Show me the entire log file"
   - "Read the full source code"
   - "I don't care about token cost"

2. **Filtered output lacks necessary context:**
   - Error message references line numbers not in filtered output
   - Need to understand full data flow
   - Debugging requires seeing complete state

3. **File is known to be small:**
   - File is < 200 lines
   - Config files with minimal content
   - Small documentation files

4. **Learning code structure and architecture (IMPORTANT):**
   - User is exploring a new codebase to understand its organization
   - Learning coding patterns, idioms, or best practices from existing code
   - Understanding how modules/classes are structured
   - Studying implementation approaches for educational purposes
   - Reading example code or reference implementations
   - Initial exploration phase before making changes

   **Key indicators for learning mode:**
   - User says: "help me understand this codebase", "how does X work?", "show me how this is implemented"
   - User is asking conceptual questions: "what patterns are used?", "how is this organized?"
   - User wants to learn from the code, not just debug or modify it
   - User is new to the project or technology

   **In learning mode:**
   ```
   ✅ DO: Read full files to show complete patterns and structure
   ✅ DO: Read multiple related files to show how components interact
   ✅ DO: Show full function/class implementations as examples
   ✅ DO: Explain code in detail with context

   ⚠️ BALANCE: Still use strategic efficiency (don't read 50 files at once)
   - Apply strategic file selection (see section below)
   - Read 2-5 key files fully to establish understanding
   - Use grep to find other relevant examples
   - Summarize patterns found across many files
   ```

   **After learning phase, return to efficient mode for implementation.**

**In cases 1-3, explain to the user:**
```
"This will use approximately [X]K tokens. Should I proceed?
Or would you prefer a filtered/summarized view first?"
```

**In learning mode (case 4), prioritize understanding over token efficiency, but still be strategic about which files to read fully (see Strategic File Selection below).**

---

## Strategic File Selection for Learning Mode

When entering learning mode, **first determine if this is broad exploration or targeted learning**, then apply the appropriate strategy.

### Learning Mode Types

**Type 1: Broad Exploration** - "Help me understand this codebase", "How is this organized?"
→ Use repository-based strategies below (identify type, read key files)

**Type 2: Targeted Pattern Learning** - "How do I implement X?", "Show me examples of Y"
→ Use targeted concept search (see Targeted Pattern Learning section below)

---

## Targeted Pattern Learning

When user asks about a **specific technique or pattern**, use this focused approach instead of broad exploration.

### Examples of Targeted Learning Queries

- "How do variable number of outputs work in Galaxy wrappers?"
- "Show me how to fetch invocation data from Galaxy API"
- "How do I implement conditional parameters in Galaxy tools?"
- "How does error handling work in this codebase?"
- "Show me examples of async function patterns"
- "How are tests structured for workflow X?"

### Targeted Learning Workflow

**STEP 1: Identify the Specific Concept**

Extract the key concept from user's question:
```
User: "How do variable number of outputs work in Galaxy wrappers?"
→ Concept: "variable number of outputs" OR "dynamic outputs"
→ Context: "Galaxy tool wrappers"
→ File types: ".xml" (Galaxy tool wrappers)
```

User: "How to fetch invocation data from Galaxy API?"
→ Concept: "fetch invocation" OR "invocation data" OR "get invocation"
→ Context: "Galaxy API calls"
→ File types: ".py" with Galaxy API usage
```

**STEP 2: Search for Examples**

Use targeted searches to find relevant code:

```bash
# For Galaxy variable outputs example
grep -r "discover_datasets\|collection_type.*list" --include="*.xml" | head -20
grep -r "<outputs>" --include="*.xml" -A 10 | grep -i "collection\|discover"

# For Galaxy invocation fetching
grep -r "invocation" --include="*.py" -B 2 -A 5 | head -50
grep -r "show_invocation\|get_invocation" --include="*.py" -l

# For conditional parameters
grep -r "<conditional" --include="*.xml" -l | head -10

# For error handling patterns
grep -r "try:\|except\|raise" --include="*.py" -l | xargs grep -l "class.*Error"
```

**STEP 3: Rank and Select Examples**

**Selection criteria (in priority order):**

1. **Documentation/Comments** - Files with good comments explaining the pattern
   ```bash
   # Find well-documented examples
   grep -r "pattern-keyword" --include="*.py" -B 5 | grep -E "^\s*#|^\s*\"\"\"" | wc -l
   ```

2. **Simplicity** - Simpler examples are better for learning
   ```bash
   # Find shorter files (likely simpler)
   grep -rl "pattern-keyword" --include="*.py" | xargs wc -l | sort -n | head -5
   ```

3. **Recency** - Recent code shows current best practices
   ```bash
   # Find recent examples
   grep -rl "pattern-keyword" --include="*.py" | xargs ls -lt | head -5
   ```

4. **Multiple variations** - Show different approaches if they exist
   ```bash
   # Compare different implementations
   grep -r "pattern-keyword" --include="*.py" -l | head -3
   ```

**STEP 4: Read Examples Fully**

Read 2-3 selected examples **completely** to understand the pattern:

```bash
# Example: Variable outputs in Galaxy
# After finding: tools/tool1.xml, tools/tool2.xml, tools/advanced.xml

Read: tools/tool1.xml  # Simple example
Read: tools/tool2.xml  # Standard example
Read: tools/advanced.xml  # Complex variation (if needed)
```

**STEP 5: Extract and Explain the Pattern**

After reading examples, explain:
1. **The core pattern** - How it works conceptually
2. **Required elements** - What's needed to implement it
3. **Common variations** - Different ways to use it
4. **Common pitfalls** - What to avoid
5. **Best practices** - Recommended approach

---

### Targeted Learning Examples

#### Example 1: Variable Number of Outputs in Galaxy Wrappers

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

#### Example 2: Fetching Invocation Data from Galaxy API

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
```python
invocation = gi.invocations.show_invocation(invocation_id)
state = invocation['state']  # 'ok', 'running', 'failed', 'cancelled'
```

**Detailed invocation with steps:**
```python
invocation = gi.invocations.show_invocation(invocation_id, include_workflow_steps=True)
steps = invocation.get('steps', {})
for step_id, step_data in steps.items():
    step_state = step_data['state']
    job_id = step_data.get('job_id')
```

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

Which pattern do you need for your use case?
```

---

#### Example 3: Conditional Parameters in Galaxy Tools

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
```xml
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
```

**In command block (Cheetah syntax):**
```xml
#if $output_choice.output_type == "single":
    --format ${output_choice.format}
#else:
    --collection-type ${output_choice.collection_type}
#end if
```

**Advanced: Nested conditionals** (advanced_conditional.xml:67-120):
- Conditionals can contain other conditionals
- Each <when> is independent
- Access nested values: ${outer.inner.value}

Would you like to see nested examples or specific use case?
```

---

### When to Use Targeted Learning

**Use targeted learning when user:**
- ✅ Asks "how do I..." about specific feature
- ✅ Requests "show me examples of X"
- ✅ Wants to learn specific pattern/technique
- ✅ Has focused technical question
- ✅ References specific concept/API/feature

**Don't use for:**
- ❌ "Understand this codebase" (use broad exploration)
- ❌ "What does this project do?" (use documentation reading)
- ❌ "Debug this error" (use debugging mode, not learning mode)

---

### Key Principles for Targeted Learning

1. **Search first, read second**
   - Use grep to find relevant examples
   - Rank by quality/simplicity/recency
   - Then read selected examples fully

2. **Read 2-3 examples, not 20**
   - Simple example (minimal working code)
   - Standard example (common usage)
   - Complex example (advanced features) - optional

3. **Extract the pattern**
   - Don't just show code, explain the pattern
   - Highlight key elements and structure
   - Show variations and alternatives

4. **Provide context**
   - Where this pattern is used
   - When to use it vs alternatives
   - Common pitfalls and best practices

5. **Confirm understanding**
   - Ask if user needs specific variation
   - Offer to show related patterns
   - Check if explanation answered their question

---

## General Exploration vs Targeted Learning

**When user says → Use this approach:**

| User Request | Approach | Strategy |
|--------------|----------|----------|
| "Help me understand this codebase" | **General Exploration** | Identify repo type → Read key files |
| "How is this project organized?" | **General Exploration** | Read docs → Entry points → Architecture |
| "Show me how to implement X" | **Targeted Learning** | Search for X → Read examples → Extract pattern |
| "How does feature Y work?" | **Targeted Learning** | Grep for Y → Find best examples → Explain |
| "What patterns are used here?" | **General Exploration** | Read core files → Identify patterns |
| "How do I use API method Z?" | **Targeted Learning** | Search for Z usage → Show examples |

---

## Broad Repository Exploration

When entering broad exploration mode, **first identify the repository context**, then apply the appropriate exploration strategy.

### STEP 1: Identify Repository Type

**Ask these questions or check indicators:**

```bash
# Check for multiple independent tools/packages
ls -d */ | wc -l  # Many directories at root level?
ls recipes/ tools/ packages/ 2>/dev/null  # Collection structure?

# Check for submission/contribution guidelines
ls -la | grep -i "contrib\|guideline\|submiss"
cat CONTRIBUTING.md README.md 2>/dev/null | grep -i "structure\|organization\|layout"

# Check for monolithic vs modular structure
find . -name "setup.py" -o -name "package.json" -o -name "Cargo.toml" | wc -l
# 1 = monolithic, many = multi-package

# Check for specific patterns
ls -la | grep -E "recipes/|tools/|workflows/|plugins/|examples/"
```

**Repository type indicators:**

1. **Tool Library / Recipe Collection** (bioconda, tool collections)
   - Multiple independent directories at same level
   - Each subdirectory is self-contained
   - Examples: `recipes/tool1/`, `recipes/tool2/`, `workflows/workflow-a/`
   - Indicator files: `recipes/`, `tools/`, `packages/`, multiple `meta.yaml` or `package.json`

2. **Monolithic Application** (single integrated codebase)
   - One main entry point
   - Hierarchical module structure
   - Shared dependencies and utilities
   - Examples: `src/`, `lib/`, single `setup.py`, `main.py`
   - Indicator files: Single `setup.py`, `main.py`, `__init__.py`, `src/` directory

3. **Framework / SDK** (extensible system)
   - Core framework + plugins/extensions
   - Base classes and interfaces
   - Examples: `core/`, `plugins/`, `extensions/`, `base/`
   - Indicator files: `core/`, `plugins/`, documentation on extending

4. **Example / Template Repository**
   - Multiple example implementations
   - Each directory shows different pattern
   - Examples: `examples/`, `samples/`, `templates/`
   - Indicator files: `examples/`, `README` in each subdirectory

---

### STEP 2: Apply Context-Specific Strategy

#### Strategy A: Tool Library / Recipe Collection

**Goal:** Learn the pattern from representative examples

**Approach:**
```bash
# 1. Find most recently modified (shows current best practices)
ls -lt recipes/ | head -10  # or tools/, workflows/, etc.

# 2. Find most common patterns
find recipes/ -name "meta.yaml" -o -name "*.xml" | head -1 | xargs dirname

# 3. Read submission guidelines first
cat CONTRIBUTING.md README.md | grep -A 20 -i "structure\|format\|template"

# 4. Read 2-3 representative examples
# Pick: 1 recent, 1 complex, 1 simple
ls -lt recipes/ | head -3
```

**Files to read (in order):**
1. `CONTRIBUTING.md` or submission guidelines → Learn required structure
2. Recent tool/recipe → Current best practices
3. Well-established tool/recipe → Proven patterns
4. Template or example → Base structure

**Example:**
```bash
# For bioconda-style repository
Read: CONTRIBUTING.md
ls -lt recipes/ | head -5  # Pick a recent one
Read: recipes/recent-tool/meta.yaml
Read: recipes/established-tool/meta.yaml  # Compare patterns
```

---

#### Strategy B: Monolithic Application

**Goal:** Understand execution flow and architecture

**Approach:**
```bash
# 1. Find entry point
find . -name "main.py" -o -name "app.py" -o -name "run*.py" | grep -v test | head -5

# 2. Find most imported modules (core components)
grep -r "^import\|^from" --include="*.py" . | \
  sed 's/.*import //' | cut -d' ' -f1 | cut -d'.' -f1 | \
  sort | uniq -c | sort -rn | head -10

# 3. Find orchestrators/managers
find . -name "*manager.py" -o -name "*orchestrator.py" -o -name "*controller.py"

# 4. Check recent changes (active development areas)
git log --name-only --pretty=format: --since="1 month ago" | \
  sort | uniq -c | sort -rn | head -10
```

**Files to read (in order):**
1. `README.md` → Overview and architecture
2. Entry point (`main.py`, `run_all.py`) → Execution flow
3. Core orchestrator/manager → Main logic
4. Most-imported utility module → Common patterns
5. One domain-specific module → Implementation details

**Example:**
```bash
# For Python application
Read: README.md
Read: main.py  # Entry point
grep -r "^from.*import" main.py | head -10  # See what it imports
Read: src/orchestrator.py  # Core component
Read: src/utils.py  # Common utilities
```

---

#### Strategy C: Framework / SDK

**Goal:** Understand core abstractions and extension points

**Approach:**
```bash
# 1. Find base classes and interfaces
grep -r "^class.*Base\|^class.*Interface\|^class.*Abstract" --include="*.py" | head -10

# 2. Find core module
ls -la | grep -E "core/|base/|framework/"

# 3. Find plugin/extension examples
ls -la | grep -E "plugins?/|extensions?/|examples?/"

# 4. Check documentation for architecture
find . -name "*.md" | xargs grep -l -i "architecture\|design\|pattern" | head -5
```

**Files to read (in order):**
1. Architecture documentation → Design philosophy
2. Base/core classes → Fundamental abstractions
3. Simple plugin/extension → How to extend
4. Complex plugin/extension → Advanced patterns

**Example:**
```bash
# For plugin-based framework
Read: docs/architecture.md
Read: core/base.py  # Base classes
Read: plugins/simple-example/  # How to extend
Read: plugins/advanced-example/  # Advanced usage
```

---

#### Strategy D: Example / Template Repository

**Goal:** Learn different patterns and use cases

**Approach:**
```bash
# 1. List all examples
ls -d examples/*/ samples/*/ templates/*/

# 2. Read index/catalog if available
cat examples/README.md examples/INDEX.md

# 3. Pick representative examples
# - Simple/basic example
# - Medium complexity
# - Advanced/complete example
```

**Files to read (in order):**
1. `examples/README.md` → Overview of examples
2. Basic example → Minimal working pattern
3. Advanced example → Full-featured pattern
4. Compare differences → Learn progression

---

### STEP 3: Execution Strategy Template

**For ANY repository type, use this workflow:**

```bash
# PHASE 1: Context Discovery (always token-efficient)
ls -la  # Repository structure
cat README.md  # Overview
ls -la .github/ docs/ | head -20  # Find documentation
cat CONTRIBUTING.md 2>/dev/null | head -50  # Submission guidelines

# PHASE 2: Identify Type (ask user if unclear)
"I see this repository has [X structure]. Is this:
A) A tool library where each tool is independent?
B) A monolithic application with integrated components?
C) A framework with core + plugins?
D) A collection of examples/templates?

This helps me choose the best files to learn from."

# PHASE 3: Strategic Reading (based on type)
[Apply appropriate strategy A/B/C/D from above]
Read 2-5 key files fully
Grep for patterns across remaining files

# PHASE 4: Summarize and Confirm
"Based on [files read], I understand:
- Pattern/architecture: [summary]
- Key components: [list]
- Common patterns: [examples]

Is this the area you want to focus on, or should I explore [other aspect]?"
```

---

### File Selection Priorities (General Rules)

**Priority 1: Documentation**
```bash
README.md, CONTRIBUTING.md, docs/architecture.md
# These explain intent, not just implementation
```

**Priority 2: Entry Points**
```bash
# Monolithic: main.py, app.py, run.py, __main__.py
# Library: Most recent example in collection
```

**Priority 3: Core Components**
```bash
# Most imported modules
grep -r "import" | cut -d: -f2 | sort | uniq -c | sort -rn

# "Manager", "Controller", "Orchestrator", "Core", "Base"
find . -name "*manager*" -o -name "*core*" -o -name "*base*"
```

**Priority 4: Representative Examples**
```bash
# Recent files (current best practices)
ls -lt directory/ | head -5

# Medium complexity (not too simple, not too complex)
wc -l **/*.py | sort -n | awk 'NR > 10 && NR < 20'
```

**Priority 5: Active Development Areas**
```bash
# Git history (if available)
git log --name-only --since="1 month ago" --pretty=format: | sort | uniq -c | sort -rn
```

---

### Practical Examples

**Example 1: Learning bioconda recipe patterns**
```bash
# Step 1: Identify type
ls recipes/ | wc -l
# Output: 3000+ → Tool library

# Step 2: Check guidelines
Read: CONTRIBUTING.md  # Learn structure requirements

# Step 3: Find representative recipes
ls -lt recipes/ | head -5  # Get recent ones
# Pick one that was updated recently (current practices)
Read: recipes/recent-tool/meta.yaml

# Pick one established recipe for comparison
Read: recipes/samtools/meta.yaml

# Step 4: Summarize pattern
"I see bioconda recipes follow this structure:
- Jinja2 variables at top
- package/source/build/requirements/test/about sections
- Current practice: use pip install for Python packages
- sha256 checksums required
Should I look at any specific type of recipe (Python/R/compiled)?"
```

**Example 2: Learning VGP pipeline orchestration**
```bash
# Step 1: Identify type
ls *.py
# Output: run_all.py, orchestrator.py → Monolithic application

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

**Example 3: Learning Galaxy workflow patterns**
```bash
# Step 1: Identify type
ls -d */  # Shows category directories
# Output: transcriptomics/, genome-assembly/, etc. → Example collection

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

### Key Principle for Learning Mode

**Balance understanding with efficiency:**
- ✅ Read 2-5 **strategic** files fully (based on context)
- ✅ Use grep/head/tail for **pattern discovery** across many files
- ✅ **Ask user** which aspect to focus on after initial exploration
- ✅ **Summarize** findings before reading more

**Don't:**
- ❌ Read 20+ files sequentially without strategy
- ❌ Read files without understanding their role
- ❌ Ignore repository context and documentation

---

## Quick Reference Card

**Model Selection (First Priority):**
- 🎓 **Learning/Understanding** → Use Opus
- 🔧 **Development/Debugging/Implementation** → Use Sonnet (default)

**Before ANY file operation, ask yourself:**

1. **Am I creating a NEW file?** → Use Write tool directly (don't wrap in bash/Python)
2. **Is this a LOW-COST operation?** (< 100 lines output) → Use Claude context directly
3. **Am I modifying a CODE file?** → Use Read + Edit (always, regardless of size)
4. **Am I modifying a SMALL data file?** (< 100 lines) → Read + Edit is fine
5. **Am I modifying CRITICAL DATA?** (genome stats, enriched tables) → Use bash + log file
6. **Am I modifying a LARGE data file?** → Use bash commands (sed, awk, grep) → 99%+ token savings
7. **Am I copying/merging files?** → Use cp/cat, not Read/Write
8. **Can I check metadata first?** (file size, line count, modification time)
9. **Can I filter before reading?** (grep, head, tail)
10. **Can I read just the structure?** (first 50 lines, function names)
11. **Can I summarize instead of showing raw data?**
12. **Does the user really need the full content?**

**Default strategy for file operations:**
```bash
# CREATING NEW FILES: Use Write tool
Write: /path/to/new-file.md
# Content here...
# (Not: python3 << 'EOF' ... write file ... EOF)

# LOW-COST OPERATIONS: Use directly
ls -la                                   # 20 lines is fine
Read: small-config.yaml                  # < 100 lines is fine

# MODIFYING CODE FILES: Always use Read + Edit
Read: script.py                          # Any size - need to understand structure
Edit: script.py                          # Preserve indentation, see changes

# MODIFYING SMALL DATA FILES: Read + Edit is fine
Read: config.yaml                        # < 100 lines
Edit: config.yaml                        # Changes are visible

# MODIFYING LARGE DATA FILES: Use bash commands
sed -i '' 's/old/new/g' large-data.txt   # Efficient for large data files
cp source.txt dest.txt                    # Instead of Read + Write
cat file1.txt file2.txt > combined.txt   # Merge files

# MODIFYING CRITICAL DATA: Use bash + log
echo "sed -i '' 's/NA/0/g' genome_stats.csv" >> data_modifications.log
sed -i '' 's/NA/0/g' genome_stats.csv     # Log for auditability

# LARGE FILES: Filter first
wc -l file.txt                           # Check size first
head -20 file.txt                        # Read sample
grep "pattern" file.txt | head -50       # Filter before reading

# COMPLEX EDITS: Use Read + Edit
# Only when you need to understand code structure or apply complex logic
```

---

## Cost Impact

**Conservative estimate for typical usage:**

| Approach | Tokens/Week | Claude Pro | Claude Team | Notes |
|----------|-------------|------------|-------------|-------|
| **Wasteful** (Read/Edit/Write everything) | 500K | ⚠️ At risk of limits | ✅ OK | Reading files unnecessarily |
| **Moderate** (filtered reads only) | 200K | ✅ Comfortable | ✅ Very comfortable | Grep/head/tail usage |
| **Efficient** (bash commands + filters) | 30-50K | ✅ Very comfortable | ✅ Excellent | Using cp/sed/awk instead of Read |

**Applying these rules reduces costs by 90-95% on average.**

**Bash commands optimization alone:**
- File operations: 99%+ token savings (e.g., 50K tokens → 50 tokens)
- Most impactful single optimization
- Zero learning curve (standard bash commands)

---

## Implementation

**This skill automatically applies these optimizations when:**
- Reading log files
- Executing commands with large output
- Navigating codebases
- Debugging errors
- Checking system status

**You can always override by saying:**
- "Show me the full output"
- "Read the entire file"
- "I want verbose mode"
- "Don't worry about tokens"

---

## Task Management Patterns

### TodoWrite for Sequential File Processing

When processing multiple files sequentially (e.g., populating analysis files, updating documentation):

**Efficient pattern**:
```
1. Create todos for all files at start
2. Mark ONLY ONE as in_progress at a time
3. Complete the file
4. Mark as completed IMMEDIATELY (don't batch)
5. Mark next file as in_progress
6. Repeat
```

**Example from analysis file population**:
```json
[
  {"content": "Fill in Figure 1 analysis", "status": "completed", "activeForm": "Filling in Figure 1 analysis"},
  {"content": "Fill in Figure 2 analysis", "status": "in_progress", "activeForm": "Filling in Figure 2 analysis"},
  {"content": "Fill in Figure 3 analysis", "status": "pending", "activeForm": "Filling in Figure 3 analysis"},
  ...
]
```

**Why this matters**:
- **Provides clear progress tracking** for multi-step tasks (7/7 files completed)
- **Prevents skipping files** or losing track of position
- **Shows user real-time progress** as files are completed
- **Maintains focus** on one file at a time
- **Creates completion satisfaction** as todos are checked off
- **Enables context resumption** if session is interrupted

**Token efficiency benefit**:
- Minimal token cost (~100-200 tokens per update)
- Massive value in maintaining task context and preventing rework
- User can see progress without asking "what's done?"
- Eliminates need for progress explanations in every response

**Anti-pattern**:
❌ Don't mark multiple todos as completed at once
❌ Don't skip updating todos between files
❌ Don't have multiple in_progress tasks simultaneously

**Best practices**:
- Create all todos upfront for visibility into total work
- Update status immediately after each completion
- Use descriptive `content` for what needs to be done
- Use present continuous `activeForm` for in-progress display

---

## Managing Long-Running Background Processes

### Best Practices for Background Tasks

When running scripts that take hours, properly manage background processes to prevent resource leaks and enable clean session transitions:

**1. Run in background** with Bash tool `run_in_background: true`

**2. Document the process** in status files:
```markdown
## Background Processes
- Script: comprehensive_search.py
- Process ID: Available via BashOutput tool
- Status: Running (~6% complete)
- How to check: BashOutput tool with bash_id
```

**3. Kill cleanly** before session end:
```python
# Before ending session:
# 1. Kill all background processes
KillShell(shell_id="abc123")

# 2. Create resume documentation (see claude-collaboration skill)
# 3. Document current progress (files, counts, status)
# 4. Save intermediate results
```

**4. Design scripts to be resumable** (see Python Environment Management skill):
- Check for existing output files (skip if present)
- Load existing results and append new ones
- Save progress incrementally (not just at end)
- Track completion status in structured format

### Avoiding Unnecessary Polling

**Problem**: Repeatedly checking background process output wastes tokens when results aren't ready yet.

**When to run in background**:
- Process will take >30 seconds (planemo test, long builds, large data downloads)
- User doesn't need immediate results
- Process can be checked asynchronously

**Token-efficient pattern**:
1. Start process in background, capture shell ID
2. Update todo list with shell ID for reference
3. Inform user once: "Running in background, shell ID: XXXXX"
4. Don't repeatedly check output unless user asks
5. User can interrupt and say "check later" - acknowledge and stop polling

**Example**:
```python
# Start background process
Bash(command="planemo test ...", run_in_background=true)
# Returns shell_id: "09584f"

# Update todos ONCE with reference
TodoWrite([{
  "content": "Check test results later (shell ID: 09584f)",
  "status": "pending"
}])

# Tell user ONCE
"Test running in background (ID: 09584f). Let me know when to check results."

# DON'T repeatedly poll BashOutput unless user asks
# AVOID: Multiple BashOutput calls every few seconds
```

**Token savings**: Avoiding 15-20 repeated BashOutput checks (200 tokens each) = ~3000-4000 tokens saved per long-running process.

### Pre-Interruption Checklist

Before ending a session with running processes:

1. ✅ Check background process status
2. ✅ Kill all background processes cleanly
3. ✅ Create resume documentation (RESUME_HERE.md)
4. ✅ Document current progress with metrics
5. ✅ Save intermediate results to disk
6. ✅ Verify resume commands in documentation

### Token Efficiency Benefit

Properly managing background processes:
- **Prevents context pollution** - Old process output doesn't leak into new sessions
- **Enables clean handoff** - Resume docs allow fresh session without re-explaining
- **Avoids redundant work** - Resumable scripts don't repeat completed tasks

---

## Repository Organization for Long Projects

### Problem
Data enrichment and analysis projects generate many intermediate files, scripts, and logs that clutter the root directory, making it hard to:
- Find the current working dataset
- Identify which scripts are actively used
- Navigate the project structure
- Maintain focus on important files

### Solution: Organize Early and Often

**Create dedicated subfolders at project start:**
```bash
mkdir -p python_scripts/ logs/ tables/
```

**Organization strategy:**
- `python_scripts/` - All analysis and processing scripts (16+ scripts in VGP project)
- `logs/` - All execution logs from script runs (38+ logs in VGP project)
- `tables/` - Intermediate results, old versions, and archived data
- Root directory - Only main working dataset and current outputs

**Benefits:**
- Reduces cognitive load when scanning directory
- Makes git status cleaner and more readable
- Easier to exclude intermediate files from version control
- Faster file navigation with autocomplete
- Professional project structure for collaboration

**When to organize:**
- At project start (ideal)
- After accumulating 5+ scripts or logs (acceptable)
- Before sharing project with collaborators (essential)

**Example cleanup script:**
```bash
# Move all Python scripts
mkdir -p python_scripts
mv *.py python_scripts/

# Move all logs
mkdir -p logs
mv *.log logs/

# Move intermediate tables (keep main dataset in root)
mkdir -p tables
mv *_intermediate.csv *_backup.csv *_old.csv tables/
```

**Token efficiency impact:**
- Cleaner `ls` outputs (fewer lines to process)
- Easier to target specific directories with Glob
- Reduced cognitive overhead when navigating
- Faster file location with autocomplete

---

## Project Navigation Patterns

### MANIFEST System for Large Projects

**Problem**: Large projects require reading many files (notebooks, data, scripts) for orientation, consuming 15,000-23,000 tokens per session startup.

**Solution**: Create MANIFEST.md files (lightweight project indexes) that provide complete context in 2,000-2,500 tokens.

#### Token Impact

- **Without MANIFESTs**: 15,000-23,000 tokens for project orientation
- **With MANIFESTs**: 2,000-2,500 tokens for complete context
- **Savings**: 85-90% reduction in session startup cost

#### Implementation

1. **Create MANIFEST.md in each major directory** (root, data/, figures/, scripts/, documentation/)
2. **Include essential sections**:
   - Quick Reference (entry points, key outputs, dependencies)
   - File Inventory (with descriptions, sizes, purposes)
   - Workflow Dependencies (how files relate)
   - Notes for Resuming Work (status, next steps, issues)
   - Metadata (tags, environment, Obsidian links)

3. **Use commands for maintenance**:
   - `/generate-manifest` - Create new MANIFESTs
   - `/update-manifest` - Quick updates after sessions

4. **Target token counts**:
   - Root MANIFEST: 1,000-2,000 tokens
   - Subdirectory MANIFEST: 500-1,000 tokens

#### Session Workflow

**Start session**:
```bash
# Read MANIFESTs for context (2,000 tokens vs 15,000)
cat MANIFEST.md                # Project overview
cat figures/MANIFEST.md        # If working on figures
```

**End session**:
```bash
# Capture session progress
/update-manifest
```

#### When to Use

- Projects with 3+ notebooks
- Multiple data files and directories
- Many generated figures (10+)
- Long-term research projects
- Team collaboration

#### Benefits

- **For Claude**: 85-90% fewer tokens for session startup
- **For Users**: Quick work resumption without reading files
- **For Teams**: Faster onboarding, shared understanding

See `folder-organization` skill for complete MANIFEST system documentation including templates, workflows, and best practices.

### Obsidian Link Verification

**Pattern:** Use Python script for vault-wide broken link detection

**Token Impact:**
- Manual verification: 500-1000 tokens per file × N files
- Automated script: ~100 tokens total
- **Savings: 98-99% for large vaults**

**When to use:**
- After vault reorganization
- Before project sharing
- After major file moves/renames
- Periodically for large vaults

**Implementation:** See obsidian skill "Link Management and Verification" section for full script

**Example:**
- 74 broken links across 15 files
- Manual: 7,500-15,000 tokens
- Script: 100 tokens
- Time: 2 seconds vs 20+ minutes

### Efficient Session Startup with MANIFEST System

**Pattern**: Use `/read-manifest` at session start instead of manually reading files

**Token Savings**:
- Traditional approach: Reading 3-4 large notebooks + data files = ~15,000-50,000 tokens
- MANIFEST approach: Root MANIFEST + 2-3 subdirectory MANIFESTs = ~2,500-5,000 tokens
- **Savings**: 70-90% token reduction while getting 80% of needed context

**Example from session** (2026-02-25):
```bash
# User started session with /read-manifest
# Loaded:
#   - Root MANIFEST.md (~500 tokens)
#   - clade_analyses/MANIFEST.md (~1,000 tokens)
#   - clade_analyses/ALL_CLADES_COMPLETE.md (~3,500 tokens)
#   - analysis_files/MANIFEST.md (~2,000 tokens)
# Total: ~7,000 tokens
#
# Alternative (reading actual files):
#   - Curation_Impact_Analysis.ipynb (4.2 MB = ~1,050,000 tokens)
#   - Curation_Analysis_3Categories.ipynb (338 KB = ~85,000 tokens)
#   - Multiple data files (500-1000 tokens each)
# Total: ~1,135,000+ tokens
#
# Savings: ~99% reduction (7K vs 1,135K tokens)
```

**Best Practice**:
1. Projects with MANIFESTs: **Always** start with `/read-manifest`
2. Let command present main document options
3. Load only relevant subdirectory MANIFESTs based on work focus
4. Read actual files only when editing them

**When to use**:
- ✅ Session startup in MANIFEST-enabled projects
- ✅ Switching between tasks in same project
- ✅ Returning to project after time away
- ❌ Don't use if MANIFEST doesn't exist (generate first with `/generate-manifest`)

---

## Efficient File Operations

### Moving Multiple Files Safely

When moving files where some might not exist, use loops with file existence checks to avoid errors and provide clean execution:

**Inefficient (fails on missing files):**
```bash
mv file1.py file2.py file3.py destination/  # Fails if any missing
```

**Efficient (handles missing files gracefully):**
```bash
for f in file1.py file2.py file3.py; do
  if [ -f "$f" ]; then
    mv "$f" destination/ && echo "Moved $f"
  fi
done
```

**For pattern-based moves:**
```bash
# Instead of: mv fix_*.py deprecated/  # Might error
for f in fix_*.py; do
  [ -f "$f" ] && mv "$f" deprecated/
done
```

**Benefits:**
- No errors from missing files
- Clean output showing what was actually moved
- Safe for batch operations with partial file lists
- Easy to adapt for copy, remove, or other operations

**Token efficiency:**
- Single-pass execution (no retry needed for errors)
- Clean output (only successful operations logged)
- Scriptable and reliable for automation

### File Reorganization

When reorganizing project files into directories, use direct mv commands with patterns instead of reading file contents:

**Efficient approach:**
```bash
# Create all directories first
mkdir -p figures data tests notebooks docs archives

# Move files by pattern (fast, no file reads needed)
mv fig*.png figures/
mv *.json *.tsv *.csv data/
mv test_*.py tests/
mv *.ipynb notebooks/
mv *.md docs/
```

**Avoid:**
- Reading each file to determine where it belongs
- One-by-one file moves with individual commands
- Checking file contents when filename pattern is clear

**Token savings**: For reorganizing 50+ files, this approach uses ~1K tokens vs. 5-10K tokens if reading files to determine categorization.

**Benefits:**
- Fast execution with pattern matching
- No unnecessary file reads
- Clear, maintainable commands
- Easy to verify with file counts

**Example verification:**
```bash
# Count moved files efficiently
for dir in figures data tests notebooks; do
  echo "$dir: $(ls $dir | wc -l) files"
done
```

### Safe Directory Removal

**Always use `rmdir` instead of `rm -rf` when removing directories you expect to be empty:**

```bash
# Good - safe, fails if directory not empty
rmdir old-folder/

# Avoid - dangerous, silently removes everything
rm -rf old-folder/
```

**Benefits:**
- Prevents accidental deletion of files
- Alerts you if directory unexpectedly contains files
- Forces you to handle hidden files (.DS_Store, etc.)

**Handling .DS_Store files:**
```bash
# Remove .DS_Store, then remove directory
rm Galaxy/.DS_Store && rmdir Galaxy/

# Or check first
ls -la Galaxy/  # Shows hidden files
```

**When to use rm -rf:**
- Only when explicitly removing directories with content
- With user confirmation first
- Never as default for cleanup

**Token efficiency:**
- Prevents error recovery conversations when wrong directory deleted
- One-pass execution (rmdir fails safely, alerts immediately)
- No need for backup/restore discussions

### Searching Jupyter Notebooks Efficiently

Notebooks contain embedded output data that inflates file size. Use grep instead of Read:

```bash
# Instead of reading entire 4MB notebook:
# Read(notebook.ipynb)  # DON'T - wastes tokens on output data

# Use targeted grep:
grep "Image(filename" notebook.ipynb          # Find image references
grep "read_csv" notebook.ipynb                 # Find data file usage
grep -A 5 "^## Methods" notebook.ipynb        # Get specific sections
```

**Token savings**: Reading a 4MB notebook with outputs = ~50K tokens. Grep for specific patterns = ~500 tokens. **100x reduction**.

**Best practices:**
- Only use Read tool for notebooks if you need to see cell structure or outputs
- For finding references (figures, data files, imports), always use grep
- For extracting sections, use grep with context (-A, -B, -C flags)

---

## Summary

**Core motto: Right model. Right tool. Filter first. Read selectively. Summarize intelligently.**

**Model selection (highest impact):**
- **Use Opus for learning/understanding** (one-time investment)
- **Use Sonnet for development/debugging/implementation** (default)
- This alone can save ~50% cost vs using Opus for everything

**Tool selection (primary optimization):**
- **Creating NEW files** → Use Write tool directly (don't wrap in bash/Python)
- **LOW-COST operations** (< 100 lines) → Use Claude context directly
- **Modifying CODE files** → Use Read + Edit (always, regardless of size)
- **Modifying SMALL data files** (< 100 lines) → Read + Edit is fine
- **Modifying LARGE data files** → Use bash commands (sed, awk, grep)
- **Modifying CRITICAL DATA** → Use bash commands + log file
- **Complex edits** → Use Read + Edit tools

**When to use bash commands:**
- ✅ Large data files (efficiency)
- ✅ Critical data files (auditability - log all operations)
- ✅ Copying/moving files (cp, mv)
- ✅ Filtering/searching (grep)
- ❌ NOT for creating new files with structured content
- ❌ NOT for code files (always use Read + Edit to understand structure)
- ❌ NOT for small data files (< 100 lines - Read + Edit is clearer)

**Secondary rules:**
- Filter before reading (grep, head, tail)
- Read with limits when needed
- Summarize instead of showing raw output
- Use quiet modes for commands
- Strategic file selection for learning

By following these guidelines, users can get 5-10x more value from their Claude subscription while maintaining high-quality assistance.
