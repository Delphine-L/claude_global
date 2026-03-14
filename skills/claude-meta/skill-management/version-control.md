# Version Control with Git

## Initialize Git Repository

```bash
cd $CLAUDE_METADATA
git init
git add .
git commit -m "Initial commit: centralized skills and commands"
```

## Track Changes

```bash
# After updating skills
cd $CLAUDE_METADATA
git status          # See what changed
git diff            # Review changes

# Commit updates
git add skills/skill-name/SKILL.md
git commit -m "Add troubleshooting section for XYZ issue"

# Optional: Push to remote for team sharing
git push origin main
```

## Team Collaboration

**Setup shared repository:**
```bash
# Create GitHub/GitLab repo
git remote add origin git@github.com:your-team/claude-metadata.git
git push -u origin main
```

**Team members clone:**
```bash
git clone git@github.com:your-team/claude-metadata.git ~/path/to/claude_data
export CLAUDE_METADATA="$HOME/path/to/claude_data"  # Adjust to your actual path
```

**Pull updates:**
```bash
cd $CLAUDE_METADATA
git pull  # All projects with symlinks auto-update!
```

## Good Commit Messages

**Good:**
```bash
git commit -m "Add token optimization for VGP log files (96% savings)"
git commit -m "Document WF8 failure pattern when Hi-C R2 missing"
git commit -m "Create galaxy-tool-wrapping skill for tool development"
```

**Bad:**
```bash
git commit -m "update"
git commit -m "changes"
git commit -m "fix stuff"
```

## Claude's Role in Git Operations

### CRITICAL: NEVER PERFORM GIT OPERATIONS

**Claude must NEVER perform ANY git operations** (add, commit, push, stash, tag, rebase, merge, etc.) **under ANY circumstances**.

**This rule applies to:**
- All changes in `$CLAUDE_METADATA/`
- ALL project directories
- Even if the user explicitly asks for it
- Even if the user says "yes, commit them"

**What Claude MUST do instead:**
1. Make the file changes
2. Show what files were changed (summary or `git status`)
3. **STOP** - Do NOT add, commit, or push
4. The user will handle git themselves

**What Claude CAN do:**
- Check git status (`git status --porcelain`)
- Show uncommitted changes (`git diff`)
- Suggest git commands (e.g., "You could run: git commit -m '...'")
- NEVER run git add, commit, push, or any other write operation

**If user asks for git operations:**
```
User: "commit these changes"
Claude: "I've made the changes to [files]. You can commit them with:
  git add [files]
  git commit -m 'your message'

I don't perform git operations - you have full control over commits."
```

**Rationale**: The user wants complete control over:
- What gets committed and when
- Commit messages and structure
- Git history organization
- All git operations without exception
