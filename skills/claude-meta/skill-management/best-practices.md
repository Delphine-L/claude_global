# Best Practices

## 1. Keep Skills Focused

**Good:** One skill per domain
- `galaxy-tool-wrapping/SKILL.md` - Only Galaxy tools
- `vgp-pipeline/SKILL.md` - Only VGP workflows

**Bad:** Kitchen sink skill
- `everything/SKILL.md` - Galaxy + VGP + Docker + Python + ...

## 2. Use Clear, Specific Descriptions

**Good descriptions:**
```yaml
description: Expert in Galaxy tool wrapper development, XML schemas, and Planemo testing
description: VGP genome assembly pipeline orchestration, debugging, and workflow management
```

**Bad descriptions:**
```yaml
description: Helps with stuff
description: Development skill
```

## 3. Regular Maintenance

**Weekly:**
- Review session learnings
- Update skills with new patterns
- Commit changes with clear messages

**Monthly:**
- Audit all skills for conflicts
- Remove outdated information
- Reorganize if needed

## 4. Document Rationale

Include "why" not just "what":

```markdown
## Use --quiet Mode for Status Checks

**Why:** Status checks with verbose output produce 15K tokens, but only 2K
with --quiet mode. Over a typical workflow (10 checks), this saves 130K tokens
(87% reduction).

**When to override:** User explicitly requests detailed output, or debugging
requires full logs.
```

## 5. Version Control Everything

```bash
# Always use git
cd $CLAUDE_METADATA
git add .
git commit -m "Descriptive message"

# Never work without version control
# You'll want to undo changes eventually!
```

## 6. Share with Team

```bash
# Use git for team collaboration
git push origin main

# Team members stay updated
cd $CLAUDE_METADATA && git pull
```

## 7. Symlink, Don't Copy

**Good:**
```bash
ln -s $CLAUDE_METADATA/skills/my-skill .claude/skills/my-skill
```

**Bad:**
```bash
cp -r $CLAUDE_METADATA/skills/my-skill .claude/skills/my-skill
```

**Why:** Symlinks mean updates propagate automatically. Copies create maintenance nightmares.

## 8. Template-Based Script Generation

When creating reusable installers or scripts that need customization across repositories:

**Use placeholders in templates:**
```bash
# Template with placeholders
TEMPLATE='
MAIN_FILE="__MAIN_FILE__"
BACKUP_DIR="__BACKUP_BASE_DIR__"
DAYS="__DAYS_TO_KEEP__"
'

# Substitute with actual values
echo "$TEMPLATE" | \
  sed "s|__MAIN_FILE__|$ACTUAL_FILE|g" | \
  sed "s|__BACKUP_BASE_DIR__|$ACTUAL_DIR|g" | \
  sed "s|__DAYS_TO_KEEP__|$ACTUAL_DAYS|g" \
  > final_script.sh
```

**Benefits:**
- Reusable across projects
- Single source of truth for logic
- Easy to maintain and update
- Parameter validation in one place
- Reduces duplication

**Example use case:**
Creating a global installer for backup systems that can be customized for any data file and directory structure. The template contains all the logic, and sed substitution customizes it for each project.

**Alternative: Template files:**
```bash
# Store template in file
cat > template.sh << 'EOF'
MAIN_FILE="__MAIN_FILE__"
BACKUP_DIR="__BACKUP_BASE_DIR__"
EOF

# Generate from template
sed "s|__MAIN_FILE__|data.csv|g" template.sh > backup.sh
```

## 9. Adopting External Commands from Other Repos

When evaluating skills/commands from other Claude Code users' GitHub repos:

1. **Browse the repo tree** with `gh api "repos/OWNER/REPO/git/trees/main?recursive=1" --jq '.tree[].path'`
2. **Fetch file contents** with `gh api "repos/OWNER/REPO/contents/PATH" --jq '.content' | base64 -d`
3. **Evaluate relevance** — skip project-specific items (e.g., Galaxy vitest helpers for a non-Galaxy user)
4. **Adapt to local conventions**:
   - Add proper YAML frontmatter (`name`, `description`, `allowed-tools`)
   - Set `context: fork` on heavy analysis commands
   - Adjust OS-specific tools (e.g., `pbcopy` for macOS)
   - Rename for clarity if the original name is too project-specific
5. **Cite sources** in the README attribution block
6. **Do NOT copy verbatim** — tailor prompts to your workflow and conventions

## 10. Hook Development Safety

### Never hold file descriptors in background processes

Synchronous hooks must release stdout/stderr before Claude Code considers them "done":

```bash
# Any background work MUST detach from parent stdio
( background_work ) </dev/null >/dev/null 2>&1 &
```

### Synchronous UserPromptSubmit hooks need crash protection

These hooks can silently swallow user input if they exit non-zero:

```bash
set -uo pipefail  # Avoid -e (errexit)
trap 'echo "{\"continue\": true}"; exit 0' ERR
```

### Keep installed hooks in sync with source

If hooks are copied (not symlinked) from `$CLAUDE_METADATA`, fixes to the source won't propagate. After fixing a hook:

```bash
# Check if installed hook is a copy or symlink
ls -la ~/.claude/hooks/safety/script.sh
# If not a symlink, manually update the installed copy
```
