---
name: list-skills
description: List all available skills in $CLAUDE_METADATA with descriptions
---

List all available Claude Code skills in `$CLAUDE_METADATA` with their descriptions and status.

## Your Task

1. **Scan for skills** in both locations:
   ```bash
   # Project-specific skills
   find $CLAUDE_METADATA/skills -name "SKILL.md" -o -name "skill.md"

   # Global skills
   find $CLAUDE_METADATA/.claude/skills -name "SKILL.md"
   ```

2. **For each skill, extract**:
   - Skill name (from frontmatter `name:` field)
   - Description (from frontmatter `description:` field)
   - Version (from frontmatter `version:` field, if present)
   - Location (full path to SKILL.md)
   - Status: ✅ Linked (if symlinked in current project) or ⬜ Available

3. **Check current project** for existing symlinks:
   ```bash
   ls -la .claude/skills/ 2>/dev/null
   ```

4. **Present in organized table format**:

## Output Format

```
# Available Claude Code Skills

## Global Skills (Recommended for all projects)

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| token-efficiency | Token optimization best practices... | 1.2.0 | ✅ Linked |
| claude-collaboration | Best practices for team collaboration... | 1.0.0 | ⬜ Available |

## Project-Specific Skills

### Bioinformatics

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| vgp-pipeline | VGP genome assembly pipeline... | 1.0.0 | ⬜ Available |
| galaxy-tool-wrapping | Galaxy tool wrapper development... | 1.0.0 | ✅ Linked |
| galaxy-workflow-development | Galaxy workflow development... | - | ⬜ Available |

### Development Tools

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| conda-recipe | Conda/bioconda recipe building... | 1.0.0 | ⬜ Available |

### Management

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| claude-skill-management | Managing Claude Code skills... | 1.0.0 | ✅ Linked |

---

**Legend**:
- ✅ Linked: Already symlinked in this project
- ⬜ Available: Can be symlinked with `ln -s $CLAUDE_METADATA/skills/[name] .claude/skills/[name]`

**To link a skill**:
```bash
ln -s $CLAUDE_METADATA/skills/skill-name .claude/skills/skill-name
# or for global skills:
ln -s $CLAUDE_METADATA/.claude/skills/skill-name .claude/skills/skill-name
```

**Recommended**: Always include token-efficiency and claude-collaboration in new projects.
```

## Token Efficiency

- Use grep to extract frontmatter efficiently
- Don't read full skill files, just frontmatter (first ~10 lines)
- Cache skill list for session if called multiple times
