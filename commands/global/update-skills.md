---
name: update-skills
description: Review session and suggest skill updates to $CLAUDE_METADATA
---

You are reviewing our conversation to identify knowledge that should be captured in skill files.

## Your Task

1. **Analyze today's conversation** for:
   - New patterns or solutions discovered
   - Solutions to problems we solved
   - Troubleshooting tips for common issues
   - Token optimizations that proved effective
   - Configuration patterns that worked well
   - Commands or procedures that could be standardized
   - Error patterns and their fixes
   - Best practices identified

2. **Categorize findings** by relevant skill file in `$CLAUDE_METADATA`:

   **Project-specific skills** (`$CLAUDE_METADATA/skills/`):
   - **vgp-pipeline/SKILL.md**: VGP pipeline workflows and orchestration
   - **galaxy-tool-wrapping/SKILL.md**: Galaxy tool wrapper development
   - **galaxy-workflow-development/skill.md**: Galaxy workflow creation
   - **conda-recipe/SKILL.md**: Conda/bioconda recipe building
   - **claude-skill-management/SKILL.md**: Skill management patterns
   - Any other project-specific skills

   **Global skills** (`$CLAUDE_METADATA/.claude/skills/`):
   - **token-efficiency/SKILL.md**: Token optimization techniques
   - **claude-collaboration/SKILL.md**: Team collaboration patterns

3. **For each finding, provide**:
   - **What we learned**: Clear summary of the knowledge
   - **Why it matters**: Impact and importance
   - **Which skill to update**: Specific file path in `$CLAUDE_METADATA`
   - **Proposed text**: Draft markdown to add
   - **Location**: Suggested section in the skill file

4. **Prioritize updates**:
   - **High priority**: Repeated issues with proven solutions, significant time/token savings
   - **Medium priority**: Useful optimizations and patterns, improved workflows
   - **Low priority**: Nice-to-know information, minor improvements
   - **Skip**: One-time issues, obvious information, already documented

5. **Ask for approval** before making any changes:
   - Present all suggestions organized by priority
   - Let user review and select which to apply
   - Update only approved changes
   - Show diff for each change made
   - **CRITICAL**: NEVER perform git operations (add, commit, push) - user manages git themselves

## IMPORTANT: Skill File Locations

**All skill files are in the global directory `$CLAUDE_METADATA`:**

- **Project skills**: `$CLAUDE_METADATA/skills/skill-name/SKILL.md`
- **Global skills**: `$CLAUDE_METADATA/.claude/skills/skill-name/SKILL.md`
- **Templates**: Use `$CLAUDE_METADATA/templates/` for creating new skills

**For new skills:**
1. Use `$CLAUDE_METADATA/templates/create-skill.sh` or templates
2. Create in `$CLAUDE_METADATA/skills/new-skill-name/`
3. Symlink to projects where needed

**DO NOT** create skills in project `.claude/skills/` - always use central repository.

## Step 6: Audit Project Permissions → Suggest Global Patterns

After analyzing skill updates, also check the project's permission settings for rules that should be promoted to broad global patterns.

### How to audit

1. **Read the project-level settings** (at the git root):
   ```bash
   PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
   cat "$PROJECT_ROOT/.claude/settings.local.json" 2>/dev/null
   ```

2. **Read the global settings**:
   ```bash
   cat ~/.claude/settings.local.json
   ```

3. **Identify hyper-specific rules** in the project settings that could be replaced or covered by broader wildcard patterns in the global settings. Common symptoms:
   - Multi-line bash fragments: `Bash(then echo "...")`, `Bash(fi)`, `Bash(done)`
   - One-shot commands: `Bash([ -f "specific-file" ])`, `Bash(NOTE_PATH="...")`
   - Tool-specific subcommands that a broader pattern would cover: individual `mcp__Server__tool` entries when `mcp__Server__*` would work
   - Domain-specific WebFetch when `WebFetch(domain:*)` is already global

4. **Suggest broad patterns** to add to `~/.claude/settings.local.json` (the global file) that would cover these cases across all projects. Format:

   ```
   🔑 **Permission Suggestions for Global Settings**

   New patterns to add to ~/.claude/settings.local.json:
   - `Bash(sed:*)` — seen in project as specific sed commands
   - `Bash(diff:*)` — seen in project as specific diff commands
   - `mcp__NewServer__*` — covers all tools from NewServer MCP

   Hyper-specific rules to clean from project settings:
   - `Bash(then echo "BROKEN: $cmd")` → already covered by `Bash(echo:*)`
   - `Bash([ -f "backup_project.sh" ])` → already covered by `Bash([:*)`
   ```

5. **Only suggest patterns that are safe to allow globally** — read-only or low-risk commands. Do NOT suggest broad patterns for destructive commands (`rm`, `git push`, etc.).

6. **Apply approved changes**:
   - Add new broad patterns to `~/.claude/settings.local.json`
   - Remove redundant hyper-specific rules from the project settings
   - Do NOT remove project-specific rules that aren't covered by a global pattern

## Output Format

Present findings organized by priority:

### High Priority Updates

For each high-priority update:
```
📚 **Skill**: $CLAUDE_METADATA/path/to/SKILL.md
📝 **Section**: Section Name (or "New Section: Title")
💡 **Learning**: Brief summary of what we learned

**Proposed Addition**:
```markdown
[draft text to add with proper markdown formatting]
```

**Rationale**: Why this is high priority (e.g., "Saves 2 hours on common task", "Prevents frequent error X")
```

### Medium Priority Updates

[Same format]

### Low Priority Updates

[Same format]

---

**Then ask**: "Which updates would you like me to apply? You can say 'all high priority', 'all', or select specific ones."

## After Approval

For each approved update:
1. Read the current skill file
2. Add the new content to the appropriate section
3. If creating a new section, place it logically
4. Maintain consistent formatting
5. Show the diff

## ⛔ CRITICAL: Git Management - DO NOT COMMIT

**NEVER perform ANY git operations** (add, commit, push, stash, etc.) for the `$CLAUDE_METADATA` directory.

The user **always** manages git themselves. After making skill updates:
- Show what files were changed (e.g., with `ls` or summary)
- Summarize the updates made
- **STOP** - do not add, commit, or push anything
- The user will handle git when they're ready

**This applies to**:
- All changes to `$CLAUDE_METADATA/skills/`
- All changes to `$CLAUDE_METADATA/commands/`
- All changes to `$CLAUDE_METADATA/.claude/`
- Any files in the `$CLAUDE_METADATA` directory tree

**NO EXCEPTIONS** for the metadata directory. The user wants full control over git commits there.

## After Creating New Skills

If you created any NEW skills (not just updated existing ones), ask about symlinking:

**For each new skill created:**

```
✅ New skill created: [skill-name]
   Location: $CLAUDE_METADATA/skills/[category]/[skill-name]/

Would you like to symlink this skill to the current project?

- **Yes** - Useful for this project's work
- **No** - Only for other projects (use /sync-skills later)
- **Ask me** - Need more context to decide
```

**If user says Yes:**
```bash
# Create symlink
ln -s $CLAUDE_METADATA/skills/[category]/[skill-name] .claude/skills/[skill-name]

# Verify
ls -la .claude/skills/[skill-name]
```

**If user says No:**
```
The skill is available globally. To use it in other projects, run:
  cd /path/to/other-project
  /sync-skills
```

**If user says "Ask me":**
```
This skill contains: [brief description]

This project is: [detected type - notebook analysis, Galaxy workflows, etc.]

Recommendation: [Yes/No based on relevance]
- Yes: The skill's [specific feature] is directly relevant to [project aspect]
- No: This skill is more suited for [other project type]
```

### Symlinking Multiple New Skills

If multiple skills were created, ask about all of them together:

```
Created 3 new skills. Which would you like to symlink to this project?

1. [ ] skill-name-1 - [one-line description]
2. [ ] skill-name-2 - [one-line description]
3. [ ] skill-name-3 - [one-line description]

You can say:
- "all" - Symlink all 3
- "1 and 3" - Symlink specific ones
- "none" - Don't symlink any (available via /sync-skills later)
```

### Important Notes

- **Only prompt for NEW skills** created during this session
- **Don't prompt for updated skills** that are already symlinked
- **Check if skill already exists** in `.claude/skills/` before prompting
- **Provide context** about what the skill does and project type

### Example Workflow

```
User: "Update skills with today's learnings"
Claude: [Analyzes, proposes updates, gets approval, applies updates]
Claude: [Commits to git]
Claude:
  ✅ Created new skill: cleanup-verification
     Location: $CLAUDE_METADATA/skills/project-management/cleanup-verification/

  This skill helps with: Verifying notebook dependencies before cleanup
  This project has: 2 Jupyter notebooks with figure dependencies

  Recommendation: Yes - Directly relevant to this project

  Would you like to symlink it to this project? (yes/no/ask me)
```

## Token Efficiency Note

When reading skill files for updates:
- Use targeted reads (grep for section names first)
- Read only the sections being modified
- Don't read entire 500+ line files unnecessarily
- Follow token-efficiency skill guidelines
