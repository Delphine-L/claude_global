# Skill and Command Templates

This directory contains standardized templates for creating new Claude Code skills and commands with consistent structure and best practices.

---

## Available Templates

### Skill Templates

1. **`skill-basic.md`** - Simple skill template
   - Use for: Single-file skills without extensive documentation
   - Includes: Core concepts, best practices, examples, quick reference
   - Best for: Straightforward topics, simple tools, basic workflows

2. **`skill-with-references.md`** - Advanced skill with supporting docs
   - Use for: Complex topics requiring detailed documentation
   - Includes: Progressive disclosure structure, references to supporting docs
   - Best for: Complex APIs, large frameworks, multi-faceted topics
   - Requires: Additional `reference.md` and `troubleshooting.md` files

### Supporting Documentation Templates

3. **`reference.md`** - Comprehensive technical reference
   - Complete API documentation
   - All configuration options
   - Advanced usage patterns
   - Edge cases and limitations
   - Platform-specific details
   - Performance considerations

4. **`troubleshooting.md`** - Detailed troubleshooting guide
   - Common errors and solutions
   - Debugging workflows
   - Platform-specific issues
   - Performance troubleshooting
   - FAQ

### Command Template

5. **`command.md`** - Slash command template
   - Clear task instructions
   - Expected output format
   - Parameter handling
   - Usage examples

---

## When to Use Which Template

### Use `skill-basic.md` when:
- ✅ Topic can be covered in 200-400 lines
- ✅ No complex troubleshooting needed
- ✅ Standard patterns and practices
- ✅ Simple examples sufficient
- ✅ Minimal platform-specific considerations

**Examples:**
- `conda-recipe` - Recipe building patterns
- `git-workflows` - Git command patterns
- `docker-basics` - Docker container basics

### Use `skill-with-references.md` when:
- ✅ Topic requires > 400 lines of documentation
- ✅ Complex API with many options
- ✅ Extensive troubleshooting needed
- ✅ Multiple platform considerations
- ✅ Advanced and basic usage differ significantly

**Examples:**
- `galaxy-tool-wrapping` - Complex XML schema, many options
- `vgp-pipeline` - Large codebase, complex workflows
- `kubernetes-deployment` - Many concepts, platform-specific

---

## Using the Templates

### Method 1: Manual Copy (Recommended for Learning)

```bash
# Navigate to skills directory
cd $CLAUDE_METADATA/skills

# Create new skill directory
mkdir my-new-skill

# Copy appropriate template
cp ../templates/skill-basic.md my-new-skill/SKILL.md

# Edit the template
vim my-new-skill/SKILL.md

# Replace placeholders:
# - SKILL-NAME-HERE → my-new-skill
# - Skill Title → My New Skill
# - Fill in all sections
```

### Method 2: Using Helper Script (Quick Setup)

```bash
# From $CLAUDE_METADATA directory
./templates/create-skill.sh my-new-skill "Brief description"

# Creates:
# - skills/my-new-skill/SKILL.md (from skill-basic.md)
# - Automatically replaces skill name
# - Opens in editor for completion
```

### Method 3: Ask Claude

```
Create a new skill called 'my-new-skill' using the basic template from $CLAUDE_METADATA/templates/skill-basic.md. The skill should cover [topic description].
```

Claude will:
1. Copy the appropriate template
2. Replace placeholders with actual values
3. Customize sections based on topic
4. Create supporting files if needed

---

## Template Customization Guide

### Step-by-Step: Creating a New Skill

#### 1. Choose Template

**Decision tree:**
```
Does the topic need extensive documentation?
├─ No  → Use skill-basic.md
└─ Yes → Use skill-with-references.md
         └─ Also create reference.md and troubleshooting.md
```

#### 2. Replace Placeholders

**Required replacements:**
```yaml
---
name: SKILL-NAME-HERE          # → actual-skill-name (kebab-case)
description: [placeholder]      # → One-sentence description
version: 1.0.0                 # Keep as 1.0.0 for new skills
---
```

**In content:**
- `# Skill Title` → Actual title (Title Case)
- `SKILL-NAME` → actual-skill-name (all occurrences)
- `Brief introduction paragraph` → Your introduction

#### 3. Fill in Sections

**Minimum required sections:**
1. **When to Use This Skill** - Be specific
   ```markdown
   ## When to Use This Skill

   - Creating new [specific tool/pattern]
   - Debugging [specific issue type]
   - Understanding [specific concept]
   ```

2. **Core Concepts** - 2-4 main concepts
   - Each concept should have examples
   - Show code or command examples
   - Explain key principles

3. **Best Practices** - Top 3-5 practices
   - Explain why, not just what
   - Show good vs bad examples
   - Link to common issues if relevant

4. **Examples** - 2-3 realistic examples
   - Use actual scenarios
   - Show complete workflows
   - Include expected results

**Optional sections (remove if not needed):**
- Quick Reference
- Notes
- Supporting Documentation references

#### 4. Add Supporting Documentation (if using advanced template)

**reference.md:**
- Complete API/command reference
- All options and flags
- Advanced patterns
- Edge cases

**troubleshooting.md:**
- Top 10 most common errors
- Diagnostic workflows
- Platform-specific issues

**examples/ directory:**
```bash
mkdir my-new-skill/examples
# Add realistic example files
```

#### 5. Test the Skill

```bash
# Create test project
mkdir -p /tmp/test-skill/.claude/skills

# Symlink new skill
ln -s $CLAUDE_METADATA/skills/my-new-skill /tmp/test-skill/.claude/skills/

# Start Claude Code in test project
cd /tmp/test-skill

# Test activation
# Tell Claude: "Use the my-new-skill skill to [relevant task]"
```

#### 6. Refine Description

**The description is critical for activation!**

**Good descriptions:**
```yaml
description: Expert in Galaxy tool wrapper development, XML schemas, and Planemo testing

description: VGP genome assembly pipeline orchestration, debugging, and workflow management

description: Token optimization best practices for cost-effective Claude Code usage
```

**Bad descriptions:**
```yaml
description: Helps with things  # Too vague

description: Development skill  # Not specific enough

description: Use this when you need to build and test Galaxy tool wrappers with Planemo, including XML schema validation, dependency management via conda, handling of test data, and troubleshooting common build errors and linting issues  # Too long!
```

**Guidelines:**
- 1-2 sentences max
- Include key technologies/tools
- Mention primary use cases
- Be specific enough for matching
- Include action verbs (developing, debugging, creating, etc.)

---

## Creating Commands

### Basic Command

```bash
# Copy template
cp $CLAUDE_METADATA/templates/command.md \
   $CLAUDE_METADATA/commands/category/my-command.md

# Edit
vim $CLAUDE_METADATA/commands/category/my-command.md
```

### Command Best Practices

1. **Clear task description**
   ```markdown
   Check the status of all VGP workflows for this project.
   ```

2. **Specific instructions**
   ```markdown
   ## Instructions for Claude

   1. Read metadata/results_run.json
   2. For each species, determine:
      - Current workflow stage
      - Invocation states
   3. Summarize in table format
   ```

3. **Expected output format**
   ```markdown
   ## Output Format

   ```
   Species | Current WF | Status | Next Step
   --------|-----------|--------|----------
   sp1     | WF4       | ✅ OK  | Launch WF8
   ```
   ```

4. **Efficiency considerations**
   ```markdown
   ## Notes

   - Use --quiet mode for commands
   - Read metadata before logs
   - Summarize, don't dump raw output
   ```

---

## Template Maintenance

### When to Update Templates

**Update templates when you discover:**
- Better organizational patterns
- Common sections missing
- Confusing placeholder names
- Better example structures

### How to Update Templates

1. **Edit template file**
   ```bash
   vim $CLAUDE_METADATA/templates/skill-basic.md
   ```

2. **Document changes**
   ```bash
   # In this README
   ## Template Changelog

   ### 2024-12-19
   - Added "Related Skills" section
   - Improved frontmatter documentation
   ```

3. **Don't update existing skills automatically**
   - Templates are starting points
   - Each skill evolves independently
   - Update existing skills on a case-by-case basis

---

## Examples of Well-Structured Skills

### Simple Skill (skill-basic.md pattern)

**`conda-recipe`:**
- ✅ Clear "When to Use" section
- ✅ Focused on core concepts
- ✅ Practical examples
- ✅ Common issues covered
- ✅ Quick reference for frequent commands
- ✅ Single file, ~270 lines

### Advanced Skill (skill-with-references.md pattern)

**`galaxy-tool-wrapping`:**
- ✅ Main SKILL.md with essentials
- ✅ reference.md with complete XML reference
- ✅ troubleshooting.md with error solutions
- ✅ dependency-debugging.md for conda issues
- ✅ Progressive disclosure - read what you need
- ✅ Total ~800 lines across files

---

## Quick Reference

### Create Basic Skill

```bash
cd $CLAUDE_METADATA/skills
mkdir new-skill
cp ../templates/skill-basic.md new-skill/SKILL.md
vim new-skill/SKILL.md  # Edit and customize
```

### Create Advanced Skill with References

```bash
cd $CLAUDE_METADATA/skills
mkdir new-advanced-skill
cp ../templates/skill-with-references.md new-advanced-skill/SKILL.md
cp ../templates/reference.md new-advanced-skill/reference.md
cp ../templates/troubleshooting.md new-advanced-skill/troubleshooting.md
vim new-advanced-skill/SKILL.md  # Edit and customize
```

### Create Command

```bash
cd $CLAUDE_METADATA/commands
mkdir category  # If doesn't exist
cp ../templates/command.md category/command-name.md
vim category/command-name.md  # Edit and customize
```

### Test New Skill

```bash
mkdir -p /tmp/test/.claude/skills
ln -s $CLAUDE_METADATA/skills/new-skill /tmp/test/.claude/skills/
cd /tmp/test
# Start Claude Code and test
```

---

## Tips for Writing Great Skills

### 1. Start Small, Grow Organically

- Begin with skill-basic.md
- Add real examples as you use it
- Split into advanced template only when > 400 lines
- Let skills evolve based on actual usage

### 2. Focus on Patterns, Not Details

**Good (pattern-focused):**
```markdown
## Conditional Parameters

Use <conditional> when user needs to select from options:
```xml
<conditional name="output_type">
    <param name="type" type="select">
        <option value="single">Single File</option>
        <option value="collection">Collection</option>
    </param>
    <when value="single">
        <!-- Single file parameters -->
    </when>
    <when value="collection">
        <!-- Collection parameters -->
    </when>
</conditional>
```
```

**Bad (too detailed):**
```markdown
List all 47 possible parameter types and their attributes...
[walls of specifications]
```

### 3. Use Real Examples

- Real file paths: `batch_vgp_run/orchestrator.py:250`
- Actual error messages: `CondaBuildException: Found a build.sh...`
- Tested commands: `bioconda-utils build --packages tool`
- Working code snippets

### 4. Include Common Pitfalls

Every skill should have "Common Issues" section:
```markdown
## Common Issues

### Issue: Tests Fail with "Output not found"

**Cause:** Output label mismatch

**Solution:**
Check output label in test exactly matches tool XML:
```yaml
# test.yml
outputs:
    output_name: ...  # Must match <data name="output_name"> in XML
```
```

### 5. Make It Scannable

Use:
- ✅ Clear headers
- ✅ Code blocks with syntax highlighting
- ✅ Bullet points for lists
- ✅ Tables for comparisons
- ✅ Icons for status (✅ ⚠️ ❌)

Avoid:
- ❌ Long paragraphs without structure
- ❌ Walls of text
- ❌ Missing examples
- ❌ Vague instructions

---

## Getting Help with Templates

**Ask Claude:**
```
Help me create a new skill for [topic] using the templates in $CLAUDE_METADATA/templates.
The skill should cover [specific aspects].
```

Claude will:
1. Choose appropriate template
2. Customize for your topic
3. Fill in relevant sections
4. Suggest examples based on topic
5. Create supporting files if needed

---

## Contributing Template Improvements

Found a better pattern? Improve the templates:

1. Update template file
2. Document the change in this README
3. Consider updating 1-2 existing skills as examples
4. Share improvements with team (if using git)

Remember: Templates are living documents that improve with use!
