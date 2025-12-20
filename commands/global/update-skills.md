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
   - Show git diff for each change if in git repo
   - Commit with clear, descriptive messages

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
6. If in git repo, offer to commit with message:
   ```
   Update [skill-name]: [brief description of change]

   - Added [specific addition]
   - [Why it matters]
   ```

## Token Efficiency Note

When reading skill files for updates:
- Use targeted reads (grep for section names first)
- Read only the sections being modified
- Don't read entire 500+ line files unnecessarily
- Follow token-efficiency skill guidelines
