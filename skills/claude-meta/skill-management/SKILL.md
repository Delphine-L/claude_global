---
name: claude-skill-management
description: Expert guide for managing Claude Code global skills and commands. Use when creating new skills, symlinking to projects, updating existing skills, or organizing the centralized skill repository.
---

# Claude Code Skill Management Expert

Expert knowledge for managing Claude Code skills and commands using the centralized repository pattern with `$CLAUDE_METADATA`.

## Supporting Documentation

This skill is split across multiple files for maintainability. Read these as needed:
- **[symlinking-guide.md](symlinking-guide.md)** - Linking skills/commands to projects, recommended global skills, setup methods
- **[updating-and-syncing.md](updating-and-syncing.md)** - Updating existing skills, syncing projects with global changes
- **[repository-organization.md](repository-organization.md)** - Directory layout, naming conventions, documentation requirements
- **[version-control.md](version-control.md)** - Git workflows, team collaboration, Claude's git restrictions
- **[troubleshooting.md](troubleshooting.md)** - Broken symlinks, activation issues, common fixes
- **[best-practices.md](best-practices.md)** - Focused skills, maintenance cadence, templates
- **[quick-reference.md](quick-reference.md)** - Cheat-sheet commands, common workflows, repository maintenance, summary

## When to Use This Skill

- Creating new global skills or commands
- Setting up skills for a new project
- Synchronizing projects with updated global skills
- Organizing the centralized skill repository
- Troubleshooting skill discovery or activation issues
- Understanding the skill lifecycle

## Environment Setup

### Required Environment Variable

**`$CLAUDE_METADATA`** must be set to your centralized skills directory.

**Check if set:**
```bash
echo $CLAUDE_METADATA
# Should output your claude_data directory path
```

**If not set, add to `~/.zshrc` (or `~/.bashrc`):**
```bash
export CLAUDE_METADATA="$HOME/path/to/claude_data"  # Adjust to your actual path
```

**Apply immediately:**
```bash
source ~/.zshrc  # or source ~/.bashrc
```

### Verify Directory Structure

```bash
ls -la $CLAUDE_METADATA/
# Should show:
# ├── skills/       # Global skills
# ├── commands/     # Global commands
# ├── hooks/        # Claude Code hooks (symlinked to ~/.claude/hooks/)
# ├── README.md
# └── QUICK_REFERENCE.md
```

### Complete Setup from Scratch

If setting up a centralized skill repository for the first time:

1. **Create directory structure**:
   ```bash
   mkdir -p $CLAUDE_METADATA/{skills,commands}
   cd $CLAUDE_METADATA
   ```

2. **Set environment variable** (add to `~/.zshrc` or `~/.bashrc`):
   ```bash
   echo 'export CLAUDE_METADATA="$HOME/path/to/claude_data"  # Adjust to your actual path' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Verify setup**:
   ```bash
   echo $CLAUDE_METADATA
   # Should output your claude_data directory path
   ```

4. **Create initial documentation**:
   ```bash
   # Create README and QUICK_REFERENCE
   # (use templates from claude-skill-management skill)
   ```

5. **Initialize git** (recommended):
   ```bash
   cd $CLAUDE_METADATA
   git init
   git add .
   git commit -m "Initial centralized skill repository"
   ```

6. **Create your first skill**:
   ```bash
   mkdir -p $CLAUDE_METADATA/skills/my-first-skill
   # Create SKILL.md with frontmatter
   ```

7. **Link to first project**:
   ```bash
   cd ~/Workdir/my-project
   mkdir -p .claude/skills
   ln -s $CLAUDE_METADATA/skills/my-first-skill .claude/skills/
   ```

**Environment variable best practices:**
- Use `$HOME` not hardcoded paths for portability
- Source shell config after adding: `source ~/.zshrc`
- Verify in new terminals: `echo $CLAUDE_METADATA`
- Document for team members in README.md

---

## Creating New Skills

### Step 1: Create Skill Directory

```bash
mkdir -p $CLAUDE_METADATA/skills/your-skill-name
```

**Naming conventions:**
- Use `kebab-case` (lowercase with hyphens)
- Be descriptive but concise
- Examples: `galaxy-tool-wrapping`, `python-testing`, `docker-workflows`

### Step 2: Create SKILL.md with Frontmatter

```bash
cat > $CLAUDE_METADATA/skills/your-skill-name/SKILL.md << 'EOF'
---
name: your-skill-name
description: Brief description that helps Claude decide when to activate this skill (1-2 sentences)
---

# Your Skill Name

Detailed instructions for Claude when this skill is activated.

## When to Use This Skill

- Specific use case 1
- Specific use case 2
- Specific use case 3

## Core Concepts

### Concept 1

Explanation and examples...

### Concept 2

Explanation and examples...

## Best Practices

- Practice 1
- Practice 2

## Common Issues and Solutions

### Issue 1

**Problem:** Description
**Solution:** How to fix it

## Examples

### Example 1: Task Name

Description and code examples...
EOF
```

**Frontmatter fields:**
- `name` (required): Must match directory name
- `description` (required): Clear, concise description for activation
- `version` (optional): Semantic versioning (e.g., `1.0.0`)
- `dependencies` (optional): Required tools/packages

### Step 3: Add Supporting Files (Optional)

```bash
# Add detailed reference documentation
cat > $CLAUDE_METADATA/skills/your-skill-name/reference.md << 'EOF'
# Reference Documentation

Detailed technical information, API references, etc.
EOF

# Add examples directory
mkdir -p $CLAUDE_METADATA/skills/your-skill-name/examples

# Add templates directory
mkdir -p $CLAUDE_METADATA/skills/your-skill-name/templates
```

### Step 4: Test the Skill

```bash
# Create a test project
mkdir -p /tmp/test-skill-project/.claude/skills

# Symlink the new skill
ln -s $CLAUDE_METADATA/skills/your-skill-name /tmp/test-skill-project/.claude/skills/your-skill-name

# Start Claude Code in test project
cd /tmp/test-skill-project
# Tell Claude: "Use the your-skill-name skill to [test task]"
```

---

## Creating New Commands

### Step 1: Choose or Create Category Directory

```bash
# Use existing category
ls $CLAUDE_METADATA/commands/
# Or create new category
mkdir -p $CLAUDE_METADATA/commands/your-category
```

**Common categories:**
- `vgp-pipeline/` - VGP workflow commands
- `git-workflows/` - Git-related commands
- `testing/` - Testing-related commands
- `deployment/` - Deployment commands

### Step 2: Create Command File

```bash
cat > $CLAUDE_METADATA/commands/your-category/command-name.md << 'EOF'
---
name: command-name
description: Brief description shown in /help
---

Your command prompt here. This will be expanded when the user types /command-name.

You can include:
- Multi-line instructions
- Variable references: {{variable_name}}
- Markdown formatting
- Code blocks

Example:
Check the status of all workflows for species {{species_name}}.
Show me which workflows are complete, running, or failed.
EOF
```

**Naming conventions:**
- Use `kebab-case`
- Start with verb: `check-status`, `debug-failed`, `update-skills`
- Be specific: `deploy-production` not just `deploy`

### Step 3: Test the Command

```bash
# Symlink to test project
ln -s $CLAUDE_METADATA/commands/your-category/command-name.md /tmp/test-project/.claude/commands/

# Start Claude Code and test
# Type: /command-name
```

---

## Command Help System

### Viewing Command Documentation

Use `/command-help` to view documentation for Claude Code commands (similar to `--help` in traditional CLI tools):

```bash
# List all available commands
/command-help list

# Show specific command help
/command-help share-project

# Show full details including implementation steps
/command-help share-project --full
```

### Command Help Implementation

**Location**: `$CLAUDE_METADATA/commands/global/command-help.md`

**Features**:
- Lists global and project commands with descriptions
- Shows usage, parameters, and examples
- Can display full implementation steps with `--full` flag
- Searches in both global and project command directories

### Command Frontmatter Format

Commands should include frontmatter for the help system:

```markdown
---
description: Brief one-line description
usage: /command-name [arguments]
parameters: |
  arg1: Description of argument 1
  arg2: Description of argument 2
examples: |
  /command-name example1
  /command-name example2 --option
---

[Command implementation steps...]
```

### Creating Help-Enabled Commands

**Template for new commands:**

```markdown
---
name: my-command
description: Brief description of what this command does
usage: /my-command [required-arg] [optional-arg]
parameters: |
  required-arg: Description of required argument
  optional-arg: (Optional) Description of optional argument
examples: |
  /my-command basic-example
  /my-command advanced-example --flag
---

# Command Implementation

Step 1: [First step description]

Step 2: [Second step description]

[Continue with detailed steps...]
```

**Best practices for command documentation:**
1. Keep description to 1 line (shows in list view)
2. Document all parameters clearly
3. Provide realistic examples
4. Include expected output in steps
5. Note any prerequisites or dependencies

---

For additional details, see the supporting files listed at the top of this document:
- Symlinking and project setup: **symlinking-guide.md**
- Updating and syncing: **updating-and-syncing.md**
- Repository organization: **repository-organization.md**
- Version control and git: **version-control.md**
- Troubleshooting: **troubleshooting.md**
- Best practices: **best-practices.md**
- Quick reference and workflows: **quick-reference.md**
