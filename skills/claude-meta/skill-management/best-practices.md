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
