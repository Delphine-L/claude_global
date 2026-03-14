# VGP Pipeline Skill Migration Guide

## Version 2.0.0 - Skill Split (2025-01-XX)

### What Changed

The `vgp-pipeline` skill has been refactored in version 2.0.0 to improve modularity and reusability:

**Before (v1.0.0):**
- Single skill containing both generic BioBlend/Planemo knowledge AND VGP-specific logic
- ~400 lines mixing universal Galaxy automation patterns with VGP orchestration details

**After (v2.0.0):**
- **`galaxy-automation`** (new global skill): Universal BioBlend and Planemo knowledge for any Galaxy automation project
- **`vgp-pipeline`** (refactored): VGP-specific orchestration logic only, depends on `galaxy-automation`

### Why This Change

1. **Reusability**: BioBlend/Planemo knowledge is now available to all Galaxy automation projects, not just VGP
2. **Clarity**: VGP-specific patterns (workflow sequences, metadata structure, expected failures) are now clearly separated
3. **Maintainability**: Updates to general Galaxy automation patterns benefit all projects
4. **Smaller Context**: Each skill is more focused and easier to understand

### Migration Steps for Existing VGP Projects

#### Step 1: Symlink the New Global Skill

```bash
# From your VGP project directory
ln -s $CLAUDE_METADATA/.claude/skills/galaxy-automation .claude/skills/galaxy-automation
```

#### Step 2: Verify Your Setup

```bash
ls -la .claude/skills/
# Should show:
# - vgp-pipeline -> $CLAUDE_METADATA/skills/vgp-pipeline
# - galaxy-automation -> $CLAUDE_METADATA/.claude/skills/galaxy-automation (new!)
# - token-efficiency -> ...
# - claude-collaboration -> ...
```

#### Step 3: Test (Optional)

The vgp-pipeline skill now automatically loads galaxy-automation as a dependency. Test by asking Claude:

```
Show me how to check the status of a Galaxy workflow invocation
```

Claude should use knowledge from `galaxy-automation` (for general BioBlend patterns) and `vgp-pipeline` (for VGP-specific context).

### What's Backward Compatible

✅ **All VGP-specific functionality remains**: Workflow sequences, metadata structure, error handling patterns
✅ **No code changes needed**: Your VGP orchestration codebase doesn't need any modifications
✅ **Existing symlinks work**: Your current `.claude/skills/vgp-pipeline` symlink continues to work
✅ **Same commands**: `/check-status`, `/debug-failed`, etc. all work identically

### What's New

🆕 **Dependency declaration**: vgp-pipeline now declares `galaxy-automation` as a dependency
🆕 **Clearer scope**: "When to Use" and "When NOT to Use" sections are more explicit
🆕 **References to galaxy-automation**: Generic patterns now reference the global skill for details
🆕 **VGP-specific focus**: All remaining content is explicitly VGP-specific (workflow sequences, assembly IDs, GenomeArk integration, etc.)

### Automatic Migration

If you use `/sync-skills` or `/setup-project` commands, they will automatically:
1. Detect your VGP project (run_all.py + batch_vgp_run/)
2. Symlink `galaxy-automation` as an essential global skill
3. Notify you that vgp-pipeline depends on galaxy-automation (already symlinked ✅)

### Manual Migration (If Needed)

If for some reason the automatic migration doesn't work:

```bash
# 1. Create skills directory if needed
mkdir -p .claude/skills

# 2. Symlink galaxy-automation from global skills
ln -s $CLAUDE_METADATA/.claude/skills/galaxy-automation .claude/skills/galaxy-automation

# 3. Verify vgp-pipeline symlink still exists
ls -la .claude/skills/vgp-pipeline

# 4. If git repository, commit the change
git add .claude/skills/galaxy-automation
git commit -m "Add galaxy-automation skill dependency for vgp-pipeline v2.0.0"
```

### Frequently Asked Questions

**Q: Do I need to update my VGP orchestration code?**
A: No, this is purely a Claude Code skill restructuring. Your Python code remains unchanged.

**Q: What if I don't symlink galaxy-automation?**
A: The vgp-pipeline skill will still work, but Claude won't have access to detailed BioBlend/Planemo patterns when needed. It's strongly recommended to symlink it.

**Q: Can I use galaxy-automation for non-VGP Galaxy projects?**
A: Yes! That's the whole point. The galaxy-automation skill is now a universal resource for any Galaxy workflow automation using BioBlend/Planemo.

**Q: Will this affect my existing VGP runs?**
A: No, this is only about Claude Code's knowledge base. Your running workflows, metadata, and orchestration scripts are unaffected.

**Q: Do I need to re-read the skill documentation?**
A: Not necessarily. The VGP-specific content you're familiar with is still there. The main difference is that generic BioBlend/Planemo content has been moved to galaxy-automation.

### Version History

- **v1.0.0** (2024): Initial VGP pipeline skill with mixed generic + specific content
- **v2.0.0** (2025): Split into galaxy-automation (global) + vgp-pipeline (specific)

### Getting Help

If you encounter issues after migration:

1. Run `/sync-skills` to verify all dependencies are properly linked
2. Run `/list-skills` to see current skill status
3. Check that both `vgp-pipeline` and `galaxy-automation` appear as linked
4. Ask Claude: "Show me the vgp-pipeline skill dependencies"

### Related Changes

This migration is part of a broader effort to create reusable global skills:
- `token-efficiency` (v1.3.0): Token optimization strategies
- `claude-collaboration` (v1.0.0): Team best practices
- `galaxy-automation` (v1.0.0): BioBlend & Planemo for Galaxy automation (NEW!)

All VGP projects should now have all four global skills symlinked.
