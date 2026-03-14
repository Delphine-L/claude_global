---
name: token-efficiency
description: Token optimization best practices for cost-effective Claude Code usage. Automatically applies efficient file reading, command execution, and output handling strategies. Includes model selection guidance (Opus for learning, Sonnet for development/debugging). Prefers bash commands over reading files.
version: 1.5.0
allowed-tools: Read, Grep, Glob, Bash
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
- Learning new codebases - Understanding architecture, code structure, design patterns
- Broad exploration - Identifying key files, understanding repository organization
- Deep analysis - Analyzing complex algorithms, performance optimization
- Reading and understanding - When you need to comprehend existing code before making changes
- Very complex debugging - Only when Sonnet can't solve it or issue is architectural

### Sonnet - For Regular Development Tasks (DEFAULT)

**Use Sonnet (default) for:**
- Writing code, editing and fixing, debugging, testing, documentation, deployment, general questions

**Typical session pattern:**
1. **Start with Opus** - Spend 10-15 minutes understanding the codebase (one-time investment)
2. **Switch to Sonnet** - Use for ALL implementation, debugging, and routine work
3. **Return to Opus** - Only when explicitly needed for deep architectural understanding

**Savings: ~50% token cost vs all-Opus usage.**

---

## Skills and Token Efficiency

**Myth:** Having many skills in `.claude/skills/` increases token usage.

**Reality:** Skills use **progressive disclosure** - Claude sees only skill descriptions at session start (~155 tokens for 4 skills). Full skill content loaded only when activated.

**It's safe to symlink multiple skills to a project.** Token waste comes from reading large files unnecessarily, not from having skills available.

---

## Token Optimization Rules (Quick Reference)

### 1. Use Quiet/Minimal Output Modes
Use `--quiet`, `-q`, `--silent` flags by default. Only use verbose when user explicitly asks.

### 2. NEVER Read Entire Log Files
Always filter before reading: `tail -100`, `grep -i "error"`, specific time ranges.

### 3. Check Lightweight Sources First
Check `git status --short`, `package.json`, `requirements.txt` before reading large files.

### 4. Use Grep Instead of Reading Files
Search for specific content with Grep tool instead of reading entire files.

### 5. Read Files with Limits
Use offset and limit parameters. Check file size with `wc -l` first.

### 6. Use Bash Commands Instead of Reading Files
**CRITICAL OPTIMIZATION.** Reading files costs tokens. Bash commands don't.

| Operation | Wasteful | Efficient |
|-----------|----------|-----------|
| Copy file | Read + Write | `cp source dest` |
| Replace text | Read + Edit | `sed -i '' 's/old/new/g' file` |
| Append | Read + Write | `echo "text" >> file` |
| Delete lines | Read + Write | `sed -i '' '/pattern/d' file` |
| Merge files | Read + Read + Write | `cat file1 file2 > combined` |
| Count lines | Read file | `wc -l file` |
| Check content | Read file | `grep -q "term" file` |

**When to break this rule:** Complex logic, code-aware changes, validation needed, interactive review. For details, see [strategies.md](strategies.md).

### 7. Filter Command Output
Limit scope: `head -50`, `find . -maxdepth 2`, `tree -L 2`.

### 8. Summarize, Don't Dump
Provide structured summaries of directory contents, code structure, command output.

### 9. Use Head/Tail for Large Output
`head -100`, `tail -50`, sample from middle with `head -500 | tail -100`.

### 10. Use JSON/Data Tools Efficiently
Extract specific fields: `jq '.metadata'`, `jq 'keys'`. For CSV: `head -20`, `wc -l`.

### 11. Optimize Code Reading
Get overview first (find, grep for classes/functions), read structure only, search for specific code, read only relevant sections.

### 12. Use Task Tool for Exploratory Searches
Use Task/Explore subagent for broad codebase exploration. Saves 70-80% tokens vs direct multi-file exploration.

### 13. Efficient Scientific Literature Searches
Batch 3-5 related searches in parallel. Save results immediately. Document "not found" items.

For detailed strategies, bash patterns, and extensive examples, see [strategies.md](strategies.md).

---

## Decision Tree for File Operations

**Ask yourself:**
1. **Creating new file?** -> Write tool
2. **Low-cost operation** (< 100 lines output)? -> Use Claude context directly
3. **Modifying code file** (.py, .js, .xml)? -> Read + Edit (always)
4. **Modifying small data file** (< 100 lines)? -> Read + Edit is fine
5. **Modifying critical data** (genome stats, enriched tables)? -> bash + log file
6. **Modifying large data file?** -> sed/awk
7. **Copying/moving files?** -> cp/mv

---

## When to Override These Guidelines

**Override efficiency rules when:**

1. **User explicitly requests full output** ("Show me the entire log file")
2. **Filtered output lacks necessary context** (error references missing line numbers)
3. **File is known to be small** (< 200 lines)
4. **Learning code structure and architecture** - Prioritize understanding over efficiency

**In learning mode:**
- Read 2-5 key files fully to establish understanding
- Use grep to find other relevant examples
- Summarize patterns found across many files
- After learning phase, return to efficient mode for implementation
- For detailed learning mode strategies, see [learning-mode.md](learning-mode.md)

**In cases 1-3, explain token cost to user and offer filtered view first.**

---

## Quick Reference Card

**Model Selection (First Priority):**
- **Learning/Understanding** -> Use Opus
- **Development/Debugging/Implementation** -> Use Sonnet (default)

**Before ANY file operation, ask yourself:**

1. Am I creating a NEW file? -> Write tool directly
2. Is this a LOW-COST operation? (< 100 lines) -> Use Claude context directly
3. Am I modifying a CODE file? -> Read + Edit (always)
4. Am I modifying a SMALL data file? (< 100 lines) -> Read + Edit is fine
5. Am I modifying CRITICAL DATA? -> bash + log file
6. Am I modifying a LARGE data file? -> bash commands (99%+ savings)
7. Am I copying/merging files? -> cp/cat, not Read/Write
8. Can I check metadata first? (file size, line count)
9. Can I filter before reading? (grep, head, tail)
10. Can I read just the structure? (first 50 lines, function names)
11. Can I summarize instead of showing raw data?
12. Does the user really need the full content?

---

## Cost Impact

| Approach | Tokens/Week | Notes |
|----------|-------------|-------|
| **Wasteful** (Read/Edit/Write everything) | 500K | Reading files unnecessarily |
| **Moderate** (filtered reads only) | 200K | Grep/head/tail usage |
| **Efficient** (bash commands + filters) | 30-50K | Using cp/sed/awk instead of Read |

**Applying these rules reduces costs by 90-95% on average.**

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

## Supporting Files

| File | Content | When to load |
|------|---------|-------------|
| [strategies.md](strategies.md) | Detailed bash command strategies, file operation patterns, sed/awk examples, Jupyter notebook manipulation, safe glob patterns, macOS/Linux compatibility | When implementing specific file operations or need detailed bash patterns |
| [learning-mode.md](learning-mode.md) | Strategic file selection, targeted pattern learning workflows, broad repository exploration strategies, repository type identification | When entering learning mode or exploring a new codebase |
| [examples.md](examples.md) | Extensive token savings examples with before/after comparisons, targeted learning examples (Galaxy wrappers, API patterns), cost calculations | When demonstrating token savings or learning from examples |
| [project-patterns.md](project-patterns.md) | Analysis file organization, task management with TodoWrite, background process management, repository organization, MANIFEST system, efficient file operations | When organizing projects, managing long-running tasks, or setting up navigation patterns |

---

## Summary

**Core motto: Right model. Right tool. Filter first. Read selectively. Summarize intelligently.**

**Model selection (highest impact):**
- **Use Opus for learning/understanding** (one-time investment)
- **Use Sonnet for development/debugging/implementation** (default)

**Tool selection (primary optimization):**
- **Creating NEW files** -> Write tool directly
- **LOW-COST operations** (< 100 lines) -> Claude context directly
- **Modifying CODE files** -> Read + Edit (always)
- **Modifying SMALL data files** (< 100 lines) -> Read + Edit is fine
- **Modifying LARGE data files** -> bash commands (sed, awk, grep)
- **Modifying CRITICAL DATA** -> bash commands + log file
- **Complex edits** -> Read + Edit tools

**Secondary rules:**
- Filter before reading (grep, head, tail)
- Read with limits when needed
- Summarize instead of showing raw output
- Use quiet modes for commands
- Strategic file selection for learning

By following these guidelines, users can get 5-10x more value from their Claude subscription while maintaining high-quality assistance.
