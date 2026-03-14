# Skill Maintenance and Effectiveness

## Best Practices for Skill Maintenance

### 1. Regular Review Sessions

**Weekly quick review:**
```
"Review this week's work and suggest skill updates"
```

**Monthly deep review:**
```
"Analyze patterns from this month's sessions and propose major skill improvements"
```

### 2. Clear Update Messages

**Good commit messages:**
```
git commit -m "Add token optimization for VGP log files (96% savings)"
git commit -m "Document WF8 failure pattern when Hi-C R2 missing"
git commit -m "Add HPC cron job environment setup"
```

**Bad commit messages:**
```
git commit -m "update skill"
git commit -m "fixes"
git commit -m "stuff"
```

### 3. Keep Skills Focused

**Good:** One skill per topic
- `token-efficiency.md` - Only token optimization
- `vgp-troubleshooting.md` - Only VGP issues
- `deployment.md` - Only deployment procedures

**Bad:** Kitchen sink skills
- `everything.md` - Token optimization + VGP + deployment + testing + ...
- Hard to maintain, hard to use

### 4. Document Rationale

**Include "why" not just "what":**

```markdown
## Use --quiet Mode by Default

**Why:** VGP status checks produce 15K tokens of output with verbose mode,
but only 2K with --quiet mode. Over a typical workflow (10 status checks),
this saves 130K tokens (87% reduction).

**When to override:** User explicitly requests detailed output, or debugging
requires seeing all intermediate steps.
```

### 5. Prioritize High-Impact Knowledge

**Capture first:**
- Patterns that save significant time/tokens
- Solutions to common, repeated problems
- Critical configuration requirements
- Team-wide standards

**Capture later:**
- Nice-to-know information
- Rarely-used edge cases
- Obvious procedures

### 6. Separating TODOs from Work Products

**Pattern**: Keep work products publication-ready by moving TODOs to tracking system

**Example from data analysis project**:

**Work product** (analysis_files/figures/01_scaffold_n50.md):
```markdown
# Figure 1: Scaffold N50 Analysis
## Analysis
[Complete, publication-ready text with no TODOs]
```

**Tracking document** (Obsidian vault or similar):
```markdown
# Figure Analysis TODOs
## Figure 1: Scaffold N50
- [ ] Run Kruskal-Wallis test
- [ ] Get sample sizes (n=XXX)
- [ ] Fill in p-values
- [ ] Complete interpretation
```

**Benefits**:
- Work products always presentable
- Easy to share analysis files with collaborators
- Clear separation between "what's done" and "what's next"
- TODOs don't clutter the actual content

---

## Measuring Skill Effectiveness

### Signs Your Skills Are Working

1. **Fewer repeated questions** - Claude knows the answer from skills
2. **Consistent behavior** - Claude follows team patterns automatically
3. **Faster onboarding** - New team members get instant context
4. **Token efficiency** - Optimizations applied automatically
5. **Better debugging** - Known issues resolved quickly

### Signs Skills Need Improvement

1. **Claude ignores guidelines** - Skills aren't clear or prominent enough
2. **Repeated manual corrections** - Patterns not captured in skills
3. **Team divergence** - Different team members do things differently
4. **Outdated information** - Skills reference old tools/patterns
5. **Too verbose** - Skills are too long, key info buried

### Metrics to Track

**Before/after comparison:**
```
Before token-efficiency skill:
- Average status check: 15K tokens
- Weekly VGP monitoring: 60K tokens

After token-efficiency skill:
- Average status check: 2K tokens (87% reduction)
- Weekly VGP monitoring: 8K tokens (87% reduction)
```

**Knowledge retention:**
```
Before skill updates:
- Same question asked 5 times over 2 months

After skill update:
- Question answered correctly from skill every time
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Forgetting to Update Skills

**Problem:** Valuable knowledge stays in conversation, gets lost

**Solution:** End-of-session ritual
```
Last message every session:
"What did we learn today that should go in our skills?"
```

### Pitfall 2: Skills Become Too Long

**Problem:** Skills are 10,000+ lines, Claude can't find key info

**Solution:** Split into focused sub-skills
```
Before: vgp-everything.md (10K lines)
After:
  - vgp-setup.md (2K lines)
  - vgp-troubleshooting.md (3K lines)
  - vgp-optimization.md (2K lines)
```

### Pitfall 3: Skills Conflict

**Problem:** Multiple skills give contradictory advice

**Solution:** Regular conflict audits
```
"Review all my skills and identify any conflicting guidelines"
```

### Pitfall 4: No Version Control

**Problem:** Can't undo bad changes, can't see history

**Solution:** Set up git from day one
```bash
cd $CLAUDE_METADATA
git init
git add .claude/
git commit -m "Initial skills"
```

### Pitfall 5: Skills Not Shared

**Problem:** Each team member has different skills, inconsistent behavior

**Solution:** Use shared git repo or symlinks
```bash
# Team repo for skills
git clone git@github.com:team/claude-skills.git ~/claude-team-skills

# Each project links to shared skills
ln -s ~/claude-team-skills/.claude/skills/* .claude/skills/
```
