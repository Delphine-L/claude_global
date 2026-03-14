# Version Control and Sharing Skills

## Version Control for Skills

### Why Version Control Skills?

1. **Track evolution** - See how knowledge grows over time
2. **Review changes** - Understand what was added and why
3. **Rollback mistakes** - Undo bad updates
4. **Share with team** - Everyone uses same skills
5. **Audit trail** - Know who added what when

### Setup Git for Global Skills

```bash
cd $CLAUDE_METADATA
git init
git add .claude/
git commit -m "Initial skills: token-efficiency, claude-collaboration"

# Optional: Push to GitHub for team sharing
git remote add origin git@github.com:your-team/claude-skills.git
git push -u origin main
```

### Workflow for Skill Updates

```bash
# Before making changes
cd $CLAUDE_METADATA
git status  # See current state

# After Claude updates a skill
git diff  # Review changes

# If changes look good
git add .claude/skills/
git commit -m "Add WF8 Hi-C troubleshooting pattern"
git push

# If changes are wrong
git checkout -- .claude/skills/token-efficiency/SKILL.md  # Undo
```

### Team Collaboration

```bash
# Team member pulls latest skills
cd $CLAUDE_METADATA
git pull

# All symlinked projects auto-update!

# Team member adds their own learning
# (Claude updates skill based on their session)
git add .
git commit -m "Add HPC-specific cron patterns"
git push

# Other team members pull and benefit
git pull
```

---

## Sharing Skills with Team

### Method 1: Git Repository (Recommended)

**Setup:**
```bash
# Create shared skills repo
mkdir claude-team-skills
cd claude-team-skills
mkdir -p .claude/skills

# Add initial skills
cp -r $CLAUDE_METADATA/skills/* .claude/skills/

# Initialize git
git init
git add .
git commit -m "Initial team skills"
git remote add origin git@github.com:your-org/claude-team-skills.git
git push -u origin main
```

**Team members use:**
```bash
# Clone shared skills
git clone git@github.com:your-org/claude-team-skills.git ~/claude-team-skills

# Link to their projects
cd /path/to/project
ln -s ~/claude-team-skills/.claude/skills/token-efficiency .claude/skills/token-efficiency

# Stay updated
cd ~/claude-team-skills
git pull  # Periodically pull updates
```

### Method 2: Shared Network Drive

**Setup:**
```bash
# Create skills on shared drive
mkdir /mnt/shared/claude-skills/.claude/skills

# Team members symlink
ln -s /mnt/shared/claude-skills/.claude/skills/token-efficiency .claude/skills/token-efficiency
```

**Pros:** Simple, immediate updates
**Cons:** No version control, risk of conflicts

### Method 3: Copy-Based (Simple but Manual)

**Setup:**
```bash
# Share skills file via email/Slack
# Team members copy to their projects
cp received-skill.md .claude/skills/my-skill/SKILL.md
```

**Pros:** Simple, no infrastructure needed
**Cons:** No automatic updates, easy to diverge

### Method 4: Skill Package (Zip Archive)

For sharing a curated set of skills with collaborators who don't have access to your central repository:

1. **Select skills** relevant to the collaborator's work
2. **Create a directory** with the skill SKILL.md files, preserving folder names
3. **Add an INSTALL.md** with symlink instructions
4. **Include supporting files** (reusable prompts, READMEs)
5. **Zip the package**: `zip -r skills-package.zip skills-directory/`

**Example package structure:**
```
gta-track-update-skills/
├── INSTALL.md                    # Setup instructions
├── README.md                     # Process documentation
├── GTA-track-update-prompt.md    # Reusable prompt template
├── training-material/SKILL.md    # Domain skill
├── workflow-development/SKILL.md # Domain skill
└── automation/SKILL.md           # Domain skill
```

**When to use which method:**
- **Git repo (Method 1)**: Team works on same codebase long-term
- **Zip package (Method 4)**: One-time sharing, onboarding collaborators, or sharing across organizations
- **`/sync-skills`**: For projects within your own centralized repo

**Pros:** Self-contained, no infrastructure needed, includes context (README, prompts)
**Cons:** No automatic updates, recipient must manually install
