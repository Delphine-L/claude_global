# Token Efficiency - Detailed Strategies

This file contains detailed bash command strategies, file operation patterns, and technical reference for token-efficient operations. See [SKILL.md](SKILL.md) for core rules.

---

## 1. Use Quiet/Minimal Output Modes

**For commands with `--quiet`, `--silent`, or `-q` flags:**

```bash
# DON'T: Use verbose mode by default
command --verbose

# DO: Use quiet mode by default
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

## 2. NEVER Read Entire Log Files

**Log files can be 50-200K tokens. ALWAYS filter before reading.**

```bash
# NEVER DO THIS:
Read: /var/log/application.log
Read: debug.log
Read: error.log

# ALWAYS DO ONE OF THESE:

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

## 3. Check Lightweight Sources First

**Before reading large files, check if info is available in smaller sources:**

**For Git repositories:**
```bash
# Check status first (small output)
Bash: git status --short
Bash: git log --oneline -10

# Don't immediately read
Read: .git/logs/HEAD  # Can be large
```

**For Python/Node projects:**
```bash
# Check package info (small files)
Bash: cat package.json | jq '.dependencies'
Bash: cat requirements.txt | head -20

# Don't immediately read
Read: node_modules/  # Huge directory
Read: venv/  # Large virtual environment
```

**For long-running processes:**
```bash
# Check process status
Bash: ps aux | grep python
Bash: top -b -n 1 | head -20

# Don't read full logs immediately
Read: /var/log/syslog
```

---

## 4. Use Grep Instead of Reading Files

**When searching for specific content:**

```bash
# DON'T: Read file then manually search
Read: large_file.py  # 30K tokens
# Then manually look for "def my_function"

# DO: Use Grep to find it
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

## 4.5. Safe Glob Patterns (Avoiding Syntax Errors)

**Problem**: This pattern fails when no files match:
```bash
# WRONG - causes syntax error if no *.md files
for file in *.md 2>/dev/null; do
    cp "$file" backup/
done
```

**Error**: `syntax error near unexpected token '2'`

**Solution**: Use `nullglob` shell option:
```bash
# CORRECT - safely handles no matches
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

## 5. Read Files with Limits

**If you must read a file, use offset and limit parameters:**

```bash
# Read first 100 lines to understand structure
Read: large_file.py (limit: 100)

# Read specific section
Read: large_file.py (offset: 500, limit: 100)

# Read just the imports/header
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

## 6. Use Bash Commands Instead of Reading Files

**CRITICAL OPTIMIZATION:** For file operations, use bash commands directly instead of reading files into Claude's context.

**Reading files costs tokens. Bash commands don't.**

### Copy File Contents

```bash
# DON'T: Read and write (costs tokens for file content)
Read: source_file.txt
Write: destination_file.txt (with content from source_file.txt)

# DO: Use cp command (zero token cost for file content)
Bash: cp source_file.txt destination_file.txt
```

### Replace Text in Files

```bash
# DON'T: Read, edit, write (costs tokens for entire file)
Read: config.yaml
Edit: config.yaml (old_string: "old_value", new_string: "new_value")

# DO: Use sed in-place (zero token cost for file content)
Bash: sed -i '' 's/old_value/new_value/g' config.yaml
# or
Bash: sed -i.bak 's/old_value/new_value/g' config.yaml  # with backup

# For literal strings with special characters
Bash: sed -i '' 's|old/path|new/path|g' config.yaml  # Use | as delimiter
```

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

### Append to Files

```bash
# DON'T: Read and write entire file
Read: log.txt
Write: log.txt (with existing content + new line)

# DO: Use echo or append
Bash: echo "New log entry" >> log.txt
Bash: cat >> log.txt << 'EOF'
Multiple lines
of content
EOF
```

### Delete Lines from Files

```bash
# DON'T: Read, filter, write
Read: data.txt
Write: data.txt (without lines containing "DELETE")

# DO: Use sed or grep
Bash: sed -i '' '/DELETE/d' data.txt
# or
Bash: grep -v "DELETE" data.txt > data_temp.txt && mv data_temp.txt data.txt
```

### Directory Size Analysis

```bash
# DON'T: ls -lh and manually sum (requires reading many files)

# DO: Use du for directory sizes
Bash: du -sh */  # All subdirectories with human-readable sizes
Bash: du -sh */ | sort -h  # Sorted by size (smallest to largest)

# Example output:
#  23M  data/
#  15M  figures/
# 138M  venv/
# 293M  telomeres/
```

### Extract Specific Lines

```bash
# DON'T: Read entire file to get a few lines
Read: large_file.txt (find lines 100-110)

# DO: Use sed or awk
Bash: sed -n '100,110p' large_file.txt
Bash: awk 'NR>=100 && NR<=110' large_file.txt
Bash: head -110 large_file.txt | tail -11
```

### Rename Files in Bulk

```bash
# DON'T: Read directory, loop in Claude, execute renames

# DO: Use bash loop or rename command
Bash: for f in *.txt; do mv "$f" "${f%.txt}.md"; done
Bash: rename 's/\.txt$/.md/' *.txt  # if rename command available
```

### Merge Files

```bash
# DON'T: Read multiple files and write combined
Read: file1.txt
Read: file2.txt
Write: combined.txt

# DO: Use cat
Bash: cat file1.txt file2.txt > combined.txt
# or append
Bash: cat file2.txt >> file1.txt
```

### Count Lines/Words/Characters

```bash
# DON'T: Read file to count

# DO: Use wc
Bash: wc -l document.txt  # Lines
Bash: wc -w document.txt  # Words
Bash: wc -c document.txt  # Characters
```

### Check if File Contains Text

```bash
# DON'T: Read file to search

# DO: Use grep with exit code
Bash: grep -q "search_term" config.yaml && echo "Found" || echo "Not found"
# or just check exit code
Bash: grep -q "search_term" config.yaml  # Exit 0 if found, 1 if not
```

### Sort File Contents

```bash
# DON'T: Read, sort in memory, write

# DO: Use sort command
Bash: sort unsorted.txt > sorted.txt
Bash: sort -u unsorted.txt > sorted_unique.txt  # Unique sorted
Bash: sort -n numbers.txt > sorted_numbers.txt  # Numeric sort
```

### Remove Duplicate Lines

```bash
# DON'T: Read and deduplicate manually

# DO: Use sort -u or uniq
Bash: sort -u file_with_dupes.txt > file_no_dupes.txt
# or preserve order
Bash: awk '!seen[$0]++' file_with_dupes.txt > file_no_dupes.txt
```

### Find and Replace Across Multiple Files

```bash
# DON'T: Read each file, edit, write back (repeat for many files)

# DO: Use sed with find or loop
Bash: find . -name "*.py" -exec sed -i '' 's/old_text/new_text/g' {} +
# or
Bash: for f in *.py; do sed -i '' 's/old_text/new_text/g' "$f"; done
```

### Create File with Template Content

```bash
# DON'T: Use Write tool for static content

# DO: Use heredoc or echo
Bash: cat > template.txt << 'EOF'
Multi-line
template
content
EOF

# or for simple content
Bash: echo "Single line content" > file.txt
```

---

## When to Break These Rules

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
# CORRECT: Creating new file with structured content
Write: /path/to/new-file.md
# Content here...

# OVER-ENGINEERED: Wrapping in Python/bash for no reason
Bash: python3 << 'EOF'
with open('/path/to/new-file.md', 'w') as f:
    f.write('Content here...')
EOF
```

**Use Claude's context for low-cost operations:**
```bash
# FINE: Simple directory listing (10-20 lines)
ls -la

# FINE: Read and edit small files (< 100 lines)
Read: config.yaml  # 50 lines
Edit: config.yaml  # Changes are clear and visible

# WASTEFUL: Large log files, huge directories
Read: /var/log/app.log  # 50K lines
ls -laR /  # Entire filesystem
```

**Use bash + logging for critical data files:**
```bash
# CORRECT: Modifying genome statistics table
LOG_FILE="genome_stats_modifications.log"
echo "sed -i '' 's/NA/0/g' genome_stats.csv" >> "$LOG_FILE"
sed -i '' 's/NA/0/g' genome_stats.csv

# The log file tracks all operations for reproducibility
```

---

## Jupyter Notebook Manipulation Without nbformat

**Problem**: nbformat may not be available in all environments, requiring conda/pip install

**Solution**: Use Python's built-in json module for notebook manipulation

```python
# EFFICIENT: Use json module (no dependencies)
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

**When to use each approach:**

| Task | json module | nbformat |
|------|-------------|----------|
| Path verification | Preferred | Overkill |
| Source code modifications | Preferred | Overkill |
| Simple cell edits | Preferred | Overkill |
| Cell execution | Can't do | Required |
| Format migration (v3->v4) | Can't do | Required |
| Metadata validation | Limited | Better |

**Benefits of json approach:**
- No external dependencies
- More portable across environments
- Faster (no parsing overhead)
- Direct access to notebook structure
- Fewer tokens (no module import errors)

---

## Find CSV Column Indices

```bash
# DON'T: Read entire CSV file to find column numbers

# DO: Extract and number header row
Bash: head -1 file.csv | tr ',' '\n' | nl

# DO: Find specific columns by pattern
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

**Token savings: 100% of file content** - Only see column headers, not data rows.

---

## Python Data Filtering Pattern

```bash
# Create separate filtered files rather than overwriting
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

---

## Handling Shell Aliases in Python Scripts

**Problem**: Python's `subprocess.run()` doesn't expand shell aliases.

```python
# FAILS if 'datasets' is an alias
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

## Key Principle for File Operations

**The Right Tool for the Job:**

**For creating NEW files with known content:**
- Use **Write tool** directly
- Don't wrap in bash/Python scripts

**For modifying EXISTING files:**
- **Code files** -> Always use **Read + Edit** (need to understand structure, preserve formatting)
- **Small data files** (< 100 lines) -> Read + Edit is fine (changes are visible)
- **Large data files** -> Use **bash commands** (`sed`, `awk`, `grep`) for efficiency
- **Critical data files** (genome stats, enriched tables) -> Use **bash commands + log file** for auditability

**Logging pattern for critical data operations:**
```bash
# When modifying critical data files, log all operations
LOG_FILE="data_modifications.log"

# Pattern: Log command before execution
echo "sed -i '' 's/old_value/new_value/g' genome_stats.csv" >> "$LOG_FILE"
sed -i '' 's/old_value/new_value/g' genome_stats.csv

# Create log if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo "# Data modification log - $(date)" > "$LOG_FILE"
fi
```

---

## Filter Command Output

**For commands that produce large output:**

```bash
# DON'T: Capture all output
Bash: find / -name "*.py"  # Could return 10,000+ files

# DO: Limit or filter output
Bash: find /specific/path -name "*.py" | head -50
Bash: find . -name "*.py" -type f | wc -l  # Count first
Bash: find . -name "*.py" -type f | grep "test" | head -20  # Filter

# DON'T: Run verbose commands without filtering
Bash: ls -laR /  # Recursive listing of entire filesystem!

# DO: Limit scope and depth
Bash: ls -la
Bash: find . -maxdepth 2 -type f
Bash: tree -L 2  # Limit tree depth
```

---

## Summarize, Don't Dump

**When explaining command output or file contents:**

```
User: "What's in this directory?"

BAD RESPONSE:
[Paste entire 5K token ls -la output with 500 files]

GOOD RESPONSE:
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

BAD: [Read entire 500-line file, paste all code]

GOOD:
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

## Optimize Code Reading

**For understanding codebases:**

```bash
# STEP 1: Get overview
Bash: find . -name "*.py" | head -20  # List files
Bash: grep -r "^class " --include="*.py" | head -20  # List classes
Bash: grep -r "^def " --include="*.py" | wc -l  # Count functions

# STEP 2: Read structure only
Read: main.py (limit: 100)  # Just imports and main structure

# STEP 3: Search for specific code
Grep: "class MyClass" src/

# STEP 4: Read only relevant sections
Read: src/mymodule.py (offset: 150, limit: 50)  # Just the relevant class

# DON'T: Read entire files sequentially
Read: file1.py  # 30K tokens
Read: file2.py  # 30K tokens
Read: file3.py  # 30K tokens
```

---

## Use JSON/Data Tools Efficiently

**For JSON, YAML, XML files:**

```bash
# DON'T: Read entire file
Read: large_config.json  # Could be 50K tokens

# DO: Extract specific fields
Bash: cat large_config.json | jq '.metadata'
Bash: cat large_config.json | jq 'keys'  # Just see top-level keys
Bash: cat config.yaml | yq '.database.host'

# For XML
Bash: xmllint --xpath '//database/host' config.xml
```

**For CSV files:**
```bash
# DON'T: Read entire CSV
Read: large_data.csv  # Could be millions of rows

# DO: Sample and analyze
Bash: head -20 large_data.csv  # See header and sample rows
Bash: wc -l large_data.csv  # Count rows
Bash: csvstat large_data.csv  # Get statistics (if csvkit installed)
```

---

## Efficient Scientific Literature Searches

When searching for data across multiple species (karyotypes, traits, etc.):

**Inefficient**: Sequential searches
```python
for species in species_list:
    search(species)  # One at a time
```

**Efficient**: Parallel searches in batches
```python
# Make 5 searches simultaneously
WebSearch("species1 karyotype")
WebSearch("species2 karyotype")
WebSearch("species3 karyotype")
WebSearch("species4 karyotype")
WebSearch("species5 karyotype")
```

**Best practices**:
- Batch 3-5 related searches together
- Group by taxonomy or data type
- Save results immediately after each batch
- Document "not found" species to avoid re-searching

### Dealing with Session Interruptions

When user warns about daily limits:

1. **Immediately save progress**: Write findings to file, update CSV/database
2. **Document search status**: Which species searched, confirmed/not found, remaining
3. **Create resume file** with current totals, completed work, pending tasks, priorities

### Search Term Iteration

When initial searches fail, refine systematically:

1. **First try**: Specific scientific terms - "Anas acuta karyotype 2n"
2. **Second try**: Common name + scientific - "northern pintail Anas acuta chromosome number"
3. **Third try**: Genus-level patterns - "Anas genus karyotype waterfowl"
4. **Fourth try**: Family-level studies - "Anatidae chromosome evolution cytogenetics"

**Don't**: Keep searching the same terms repeatedly
**Do**: Escalate to higher taxonomic levels or comparative studies

---

## Searching Jupyter Notebooks Efficiently

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
