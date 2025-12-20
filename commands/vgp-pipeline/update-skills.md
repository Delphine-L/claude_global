---
description: Review session and suggest skill updates
---

You are reviewing our conversation to identify knowledge that should be captured in skill files.

## Your Task

1. **Analyze today's conversation** for:
   - New VGP workflow patterns discovered
   - Solutions to problems we solved
   - Troubleshooting tips for common issues
   - Token optimizations that proved effective
   - Configuration patterns that worked well
   - Commands or procedures that could be standardized
   - Error patterns and their fixes

2. **Categorize findings** by skill file:
   - **$CLAUDE_METADATA/skills/vgp-pipeline/SKILL.md**: VGP pipeline knowledge
     - Workflow procedures
     - Troubleshooting guides
     - Code architecture insights
     - Implementation patterns
     - Error handling improvements

   - **$CLAUDE_METADATA/skills/galaxy-tool-wrapping/SKILL.md**: Galaxy tool development
     - Tool wrapper patterns
     - Planemo testing strategies
     - XML debugging tips
     - Best practices

   - **$CLAUDE_METADATA/.claude/skills/token-efficiency/SKILL.md**: General token optimization
     - New optimization techniques
     - Token savings measurements
     - Efficiency patterns

   - **$CLAUDE_METADATA/.claude/skills/claude-collaboration/SKILL.md**: Collaboration patterns
     - New skill management patterns
     - Team workflow improvements
     - Knowledge capture strategies

3. **For each finding, provide**:
   - **What we learned**: Clear summary of the knowledge
   - **Why it matters**: Impact and importance
   - **Which skill to update**: Specific file path
   - **Proposed text**: Draft markdown to add
   - **Location**: Suggested section in the skill file

4. **Prioritize updates**:
   - High priority: Repeated issues with proven solutions
   - Medium priority: Useful optimizations and patterns
   - Low priority: Nice-to-know information
   - Skip: One-time issues or obvious information

5. **Ask for approval** before making any changes:
   - Present all suggestions
   - Let user review and select which to apply
   - Update only approved changes
   - Commit with clear messages if using git

## IMPORTANT: Creating New Skills

**All new skill files MUST be created in the global claude skill directory ($CLAUDE_METADATA):**

- **Location**: `$CLAUDE_METADATA/skills/`
- **Structure**: Each skill in its own subdirectory with `SKILL.md`
- **Linking**: Symlink to projects where needed

**Workflow for new skills:**

1. **Create in global directory**:
   ```bash
   mkdir -p $CLAUDE_METADATA/skills/new-skill-name
   # Create SKILL.md with proper frontmatter
   ```

2. **Link to projects that need it**:
   ```bash
   cd ~/Workdir/your-project
   ln -s $CLAUDE_METADATA/skills/new-skill-name .claude/skills/new-skill-name
   ```

3. **DO NOT** create skills directly in `.claude/skills/` - always use the central repository and symlink

**Skill frontmatter format**:
```markdown
---
name: skill-name
description: Brief description for Claude to decide when to activate
---

# Skill Name

Detailed instructions...
```

## Output Format

For each suggested update:
```
📚 **Skill**: path/to/skill-file.md
📝 **Section**: Section Name
⭐ **Priority**: High/Medium/Low
💡 **Learning**: Brief summary

**Proposed Addition**:
```markdown
[draft text to add]
```

**Rationale**: Why this should be captured
```

Then ask: "Which updates would you like me to apply?"
